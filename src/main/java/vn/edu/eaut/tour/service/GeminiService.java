package vn.edu.eaut.tour.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import vn.edu.eaut.tour.dao.CouponDAO;
import vn.edu.eaut.tour.dao.TourDAO;
import vn.edu.eaut.tour.model.Coupon;
import vn.edu.eaut.tour.model.Tour;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.text.NumberFormat;
import java.time.Duration;
import java.util.List;
import java.util.Locale;

/**
 * Service kết nối Google Gemini API (Gemini 3.6 / 3.7 / 3.8 Flash)
 * Đóng vai trò là Trợ lý Ảo Tư Vấn Du Lịch TourBooking 24/7.
 */
public class GeminiService {
    private static final String DEFAULT_API_KEY = "";
    private static final String[] PREFERRED_MODELS = {
            "gemini-3.8-flash",
            "gemini-3.7-flash",
            "gemini-3.6-flash"
    };

    private static volatile long quotaBlockedUntil = 0;

    private static final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();
    private static final ObjectMapper mapper = new ObjectMapper();
    private static final NumberFormat currencyFmt = NumberFormat.getInstance(new Locale("vi", "VN"));

    private final TourDAO tourDAO = new TourDAO();
    private final CouponDAO couponDAO = new CouponDAO();
    private final vn.edu.eaut.tour.dao.SystemSettingDAO systemSettingDAO = new vn.edu.eaut.tour.dao.SystemSettingDAO();

    public String askAssistant(String userQuestion, List<String> chatHistory) {
        String apiKey = getApiKey();
        String contextPrompt = buildKnowledgeContext();
        String preferredModel = systemSettingDAO.getSetting("gemini_model", "gemini-3.8-flash");

        // Nếu API key vừa bị Google chặn 429 do hết quota trong vòng 60s, phản hồi ngay lập tức bằng Fallback (không để khách chờ)
        if (System.currentTimeMillis() < quotaBlockedUntil) {
            return getSmartFallbackResponse(userQuestion);
        }

        java.util.List<String> modelOrder = new java.util.ArrayList<>();
        if (preferredModel != null && !preferredModel.isBlank()) {
            modelOrder.add(preferredModel.trim());
        }
        for (String m : PREFERRED_MODELS) {
            if (!modelOrder.contains(m)) {
                modelOrder.add(m);
            }
        }

        // 1. Thử gọi lần lượt các mô hình Gemini được ưu tiên
        for (String model : modelOrder) {
            try {
                String response = callGeminiApi(model, apiKey, contextPrompt, userQuestion, chatHistory);
                if (response != null && !response.trim().isEmpty()) {
                    return response;
                }
            } catch (QuotaExceededException qe) {
                // Đánh dấu quota Google bị cạn kiệt trong 60s để fail-fast các request kế tiếp
                quotaBlockedUntil = System.currentTimeMillis() + 60_000;
                break;
            } catch (Exception e) {
                System.err.println("[GeminiService] Model " + model + " error: " + e.getMessage());
            }
        }

        // 2. Nếu API gặp sự cố hoặc hết quota, dùng bộ tư vấn thông minh nội bộ (Fallback)
        return getSmartFallbackResponse(userQuestion);
    }

    private String callGeminiApi(String model, String apiKey, String systemContext, String userQuestion, List<String> history) throws Exception {
        String url = "https://generativelanguage.googleapis.com/v1beta/models/" + model + ":generateContent?key=" + apiKey;

        ObjectNode rootNode = mapper.createObjectNode();

        // System Instruction cung cấp ngữ cảnh toàn bộ tour & chính sách website
        ObjectNode systemInstruction = mapper.createObjectNode();
        ArrayNode sysParts = systemInstruction.putArray("parts");
        sysParts.addObject().put("text", systemContext);
        rootNode.set("systemInstruction", systemInstruction);

        // Contents (lịch sử và câu hỏi hiện tại)
        ArrayNode contents = rootNode.putArray("contents");

        if (history != null) {
            for (String h : history) {
                if (h != null && !h.isBlank()) {
                    ObjectNode histItem = contents.addObject();
                    histItem.put("role", "user");
                    histItem.putArray("parts").addObject().put("text", h);
                }
            }
        }

        ObjectNode currentMsg = contents.addObject();
        currentMsg.put("role", "user");
        currentMsg.putArray("parts").addObject().put("text", userQuestion);

        // Generation Config
        ObjectNode genConfig = rootNode.putObject("generationConfig");
        genConfig.put("temperature", 0.7);
        genConfig.put("maxOutputTokens", 1500);

        String jsonPayload = mapper.writeValueAsString(rootNode);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Content-Type", "application/json; charset=utf-8")
                .timeout(Duration.ofSeconds(15))
                .POST(HttpRequest.BodyPublishers.ofString(jsonPayload, StandardCharsets.UTF_8))
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        if (response.statusCode() == 200) {
            JsonNode resJson = mapper.readTree(response.body());
            JsonNode candidates = resJson.path("candidates");
            if (candidates.isArray() && candidates.size() > 0) {
                JsonNode parts = candidates.get(0).path("content").path("parts");
                if (parts.isArray() && parts.size() > 0) {
                    return parts.get(0).path("text").asText();
                }
            }
            throw new RuntimeException("Gemini trả về HTTP 200 nhưng không có nội dung text");
        } else if (response.statusCode() == 429) {
            System.err.println("[GeminiService] HTTP 429: Quota Google Free Tier đã hết cho model " + model);
            throw new QuotaExceededException("Quota exceeded 429");
        } else {
            System.err.println("[GeminiService] HTTP " + response.statusCode() + ": " + response.body());
            throw new RuntimeException("Gemini API (HTTP " + response.statusCode() + "): " + response.body());
        }
    }

    private static class QuotaExceededException extends RuntimeException {
        QuotaExceededException(String msg) { super(msg); }
    }

    /**
     * Tự động trích xuất toàn bộ dữ liệu thực tế từ Database để tạo tri thức cho AI (RAG)
     */
    private String buildKnowledgeContext() {
        StringBuilder sb = new StringBuilder();
        sb.append("Bạn là 'Nhân viên AI Hịn Hò' - nhân viên tư vấn khách hàng trực tuyến của hệ thống đặt tour du lịch TourBooking.\n");
        sb.append("Tính cách: Vui vẻ, lịch sự, thân thiện, trả lời tự nhiên như người thật. Bạn có thể tán gẫu, hỏi thăm, trò chuyện vui vẻ thoải mái với khách hàng.\n\n");

        sb.append("=== QUY TẮC BẢO MẬT & GIỚI HẠN QUYỀN HẠN BẮT BUỘC (QUAN TRỌNG NHẤT) ===\n");
        sb.append("1. BẢO MẬT HỆ THỐNG & TÀI KHOẢN: TUYỆT ĐỐI KHÔNG tiết lộ bất kỳ thông tin nào về: tài khoản admin, mật khẩu admin/user (tk, mk, username, password), API key, cơ sở dữ liệu (database, tables, sql), mã nguồn (source code) hay hệ thống nội bộ.\n");
        sb.append("2. BẢO MẬT TÀI CHÍNH CÔNG TY: TUYỆT ĐỐI KHÔNG tiết lộ doanh thu, lợi nhuận, doanh số bán tour hay bất kỳ số liệu tài chính nội bộ nào của TourBooking.\n");
        sb.append("3. BẢO MẬT MÔ HÌNH AI (GIẤU MODEL): TUYỆT ĐỐI KHÔNG nhắc đến tên mô hình AI kỹ thuật (như Gemini, GPT, OpenAI, Google, LLM, version 3.6, 3.7...). Nếu khách hỏi bạn dùng model gì hay ai làm ra, hãy trả lời tự nhiên: 'Dạ em là Nhân viên AI Hịn Hò - trợ lý tư vấn du lịch trực tuyến của TourBooking ạ!'.\n");
        sb.append("4. TỪ CHỐI LỊCH SỰ KHI BỊ HỎI THÔNG TIN BẢO MẬT: Nếu khách hỏi mật khẩu, tài khoản quản trị, doanh thu, hay thông tin kỹ thuật hệ thống, hãy từ chối lịch sự: 'Dạ đây là thông tin nội bộ bảo mật của TourBooking nên em không được phép chia sẻ ạ! Em có thể hỗ trợ anh/chị tư vấn các tour du lịch hoặc kiểm tra mã giảm giá nhé ạ!'.\n");
        sb.append("5. PHẠM VI HỖ TRỢ: Tư vấn chi tiết các tour du lịch (điểm đến, lịch trình, ngày đi, giá vé, số chỗ trống), hướng dẫn đặt tour, thanh toán VietQR và áp dụng các mã voucher giảm giá hợp lệ.\n");
        sb.append("6. CHÀO HỎI XÃ GIAO: Khi khách chỉ chào hỏi ('xin chào', 'hi', 'alo', 'bạn ơi'): Chỉ chào lại ngắn gọn, niềm nở (1-2 câu) và hỏi khách muốn đi đâu. Không tuôn danh sách tour dài dòng khi khách chỉ chào.\n");
        sb.append("7. TƯ VẤN CHUYÊN NGHIỆP & NHIỆT TÌNH NHƯ CHUYÊN GIA DU LỊCH: Khi khách hỏi tư vấn (ví dụ hỏi tour nước ngoài, tour biển đảo, tour theo mức giá, tour gia đình...): Hãy phân tích kỹ và tư vấn chi tiết, hấp dẫn, đầy đủ thông tin như ứng dụng Gemini: liệt kê các tour nổi bật kèm thời gian, giá vé, điểm nhấn đặc sắc; gợi ý mã giảm giá (như HE2026 giảm 10%); dùng định dạng Markdown in đậm, gạch đầu dòng và emoji sinh động; cuối câu hỏi lại nhu cầu cụ thể của khách để hỗ trợ tốt nhất.\n\n");

        sb.append("=== DANH SÁCH CÁC TOUR DU LỊCH HIỆN CÓ ===\n");
        try {
            List<Tour> tours = tourDAO.getAllTours();
            for (Tour t : tours) {
                sb.append(String.format("- Mã #%d: %s | %s (%s) | Khởi hành: %s | %s | Giá: %s đ",
                        t.getId(), t.getName(), t.getDestination(), t.getCountry(), t.getOrigin(), t.getDuration(),
                        currencyFmt.format(t.getPrice())));
                if (t.isDiscountActive() && t.getOriginalPrice() > t.getPrice()) {
                    sb.append(String.format(" (Gốc: %s đ, -%d%%)", currencyFmt.format(t.getOriginalPrice()), t.getDiscountPercent()));
                }
                sb.append(String.format(" | Còn: %d chỗ | Ngày: %s\n", t.getAvailableSeats(), t.getStartDate()));
            }
        } catch (Exception e) {
            sb.append("(Không tải được danh sách tour)\n");
        }

        sb.append("\n=== CÁC MÃ GIẢM GIÁ (COUPON) ĐANG HOẠT ĐỘNG ===\n");
        try {
            List<Coupon> coupons = couponDAO.getAllCoupons();
            for (Coupon c : coupons) {
                if (c.isActive()) {
                    String discountDesc = "PERCENT".equalsIgnoreCase(c.getDiscountType())
                            ? ("Giảm " + (int) c.getDiscountValue() + "%")
                            : ("Giảm " + currencyFmt.format(c.getDiscountValue()) + " đ");
                    String scope = c.isSpecificTour() ? ("Áp dụng riêng tour #" + c.getApplicableTourId() + ": " + c.getApplicableTourName()) : "Toàn sàn";
                    sb.append(String.format("- Mã '%s': %s (Đơn từ: %s đ, Phạm vi: %s)\n",
                            c.getCode(), discountDesc, currencyFmt.format(c.getMinOrderAmount()), scope));
                }
            }
        } catch (Exception e) {
            sb.append("- Mã 'HE2026': Giảm 10% cho đơn từ 2 triệu\n");
        }

        sb.append("\n=== CHÍNH SÁCH THANH TOÁN & ĐẶT CHỖ ===\n");
        sb.append("- Thanh toán trực tuyến: Hỗ trợ cổng thanh toán VNPay và chuyển khoản VietQR Napas247 BIDV.\n");
        sb.append("- Thông tin tài khoản ngân hàng chính thức của công ty:\n");
        sb.append("  + Ngân hàng: BIDV (Ngân hàng TMCP Đầu tư và Phát triển Việt Nam)\n");
        sb.append("  + Số tài khoản: 8821900777\n");
        sb.append("  + Chủ tài khoản: VŨ DUY THÁI SƠN (VU DUY THAI SON)\n");
        sb.append("  + Cú pháp chuyển khoản: BK<Mã đơn> (Ví dụ: BK12)\n");
        sb.append("- Khách bấm nút 'Đặt ngay' tại chi tiết tour để giữ chỗ và xem vé điện tử tại mục 'Vé của tôi'.\n");
        return sb.toString();
    }

    /**
     * Fallback tư vấn thông minh nội bộ khi mất mạng hoặc không gọi được Gemini API
     */
    private String getSmartFallbackResponse(String q) {
        String lower = q == null ? "" : q.toLowerCase();

        // 1. Chặn câu hỏi bảo mật hệ thống, tài khoản admin, doanh thu
        if (lower.contains("mật khẩu") || lower.contains("admin") || lower.contains("doanh thu") ||
            lower.contains("tài khoản admin") || lower.contains("database") || lower.contains("api key") ||
            lower.contains("mk") || lower.contains("source code") || lower.contains("mã nguồn")) {
            return "🔒 Dạ đây là thông tin nội bộ bảo mật của TourBooking nên em không được phép chia sẻ ạ! Em có thể hỗ trợ mình tìm tour du lịch hoặc kiểm tra mã giảm giá nhé!";
        }

        // 2. Chặn câu hỏi lộ tên mô hình AI
        if (lower.contains("mô hình") || lower.contains("model") || lower.contains("gemini") || lower.contains("gpt") || lower.contains("openai")) {
            return "👋 Dạ em là Nhân viên AI Hịn Hò của TourBooking, luôn sẵn sàng hỗ trợ tư vấn tour và giải đáp thông tin du lịch cho mình 24/7 ạ!";
        }

        // 3. Thông tin thanh toán & tài khoản ngân hàng chính thức
        if (lower.contains("thanh toán") || lower.contains("chuyển khoản") || lower.contains("tài khoản ngân hàng") ||
            lower.contains("stk") || lower.contains("bidv") || lower.contains("ngân hàng") || lower.contains("vietqr") || lower.contains("vnpay")) {
            return "💳 **Thông tin thanh toán & tài khoản chính thức của TourBooking:**\n\n" +
                   "🏦 **Ngân hàng:** BIDV (Ngân hàng TMCP Đầu tư & Phát triển Việt Nam)\n" +
                   "🔢 **Số tài khoản:** **`8821900777`**\n" +
                   "👤 **Chủ tài khoản:** **VŨ DUY THÁI SƠN**\n" +
                   "📝 **Nội dung chuyển khoản:** **`BK<Mã đơn>`** (Ví dụ: bạn đặt đơn số 12 thì ghi `BK12`)\n\n" +
                   "✨ **Hình thức hỗ trợ:**\n" +
                   "• **Quét mã VietQR 24/7:** Quét mã trên trang *Vé của tôi*, hệ thống sẽ tự động duyệt đơn tức thì!\n" +
                   "• **Cổng thanh toán VNPay:** Hỗ trợ thẻ ATM 40 ngân hàng nội địa, Visa/Mastercard và VNPAY-QR.";
        }

        // 4. Chào hỏi xã giao
        if (lower.contains("chào") || lower.contains("hi") || lower.contains("hello") || lower.contains("alo") || lower.contains("ơi")) {
            return "👋 Dạ em chào bạn! Em là Nhân viên AI Hịn Hò của TourBooking. Bạn đang quan tâm tour đi đâu hay cần tìm tour theo ngân sách bao nhiêu để em gợi ý cho mình nhé?";
        }

        // 5. Mã giảm giá
        if (lower.contains("mã") || lower.contains("giảm giá") || lower.contains("coupon") || lower.contains("khuyến mãi")) {
            return "🎟️ **Mã giảm giá hot hôm nay:**\n" +
                   "• **`HE2026`**: Giảm ngay 10% (đơn từ 2.000.000đ)\n" +
                   "• **`GIAM200K`**: Giảm 200.000đ (đơn từ 1.500.000đ)\n" +
                   "👉 Bạn chỉ cần nhập mã tại bước thanh toán để được giảm giá tự động nhé!";
        }

        // 5. Tư vấn tour nước ngoài / quốc tế chi tiết
        if (lower.contains("nước ngoài") || lower.contains("quốc tế") || lower.contains("ngoại quốc") ||
            lower.contains("châu âu") || lower.contains("châu á") || lower.contains("hải ngoại") || lower.contains("xuất ngoại") ||
            lower.contains("đi nước ngoài") || lower.contains("tour ngoại")) {
            return "🌏 **Dạ các chùm tour du lịch nước ngoài cực hot bên em hiện đang mở bán:**\n\n" +
                   "📍 **Khu vực Đông Nam Á (Giá siêu tốt):**\n" +
                   "• **Tour Thái Lan 5N4Đ (Bangkok - Pattaya - Đảo Coral)**: Giá chỉ từ **6.990.000 đ**\n" +
                   "• **Tour Singapore - Malaysia 5N4Đ (Marina Bay Sands - Genting)**: Giá từ **11.490.000 đ**\n" +
                   "• **Tour Bali Indonesia 4N3Đ (Cổng trời Lempuyang - Nusa Penida)**: Giá từ **12.900.000 đ**\n\n" +
                   "📍 **Khu vực Đông Bắc Á (Mùa lá đỏ & mùa hoa):**\n" +
                   "• **Tour Trung Quốc 5N4Đ (Trương Gia Giới - Phượng Hoàng Cổ Trấn)**: Giá từ **13.900.000 đ**\n" +
                   "• **Tour Hàn Quốc 5N4Đ (Seoul - Nami - Công viên Everland)**: Giá từ **15.990.000 đ**\n" +
                   "• **Tour Nhật Bản 6N5Đ (Tokyo - Núi Phú Sĩ - Kyoto - Osaka)**: Giá từ **28.900.000 đ**\n\n" +
                   "📍 **Châu Âu & Châu Mỹ (Đẳng cấp 5 sao):**\n" +
                   "• **Tour Tây Âu 3 Nước 9N8Đ (Pháp - Thụy Sĩ - Ý)**: Giá từ **62.900.000 đ**\n" +
                   "• **Tour Bờ Tây Nước Mỹ 8N7Đ (Los Angeles - Las Vegas - San Francisco)**: Giá từ **68.900.000 đ**\n\n" +
                   "🎁 **Ưu đãi kèm theo:** Nhập mã **`HE2026`** để được giảm ngay 10% khi đặt tour trên website!\n" +
                   "👉 Bạn đang dự định đi vào tháng mấy và khởi hành từ Hà Nội hay TP.HCM để em gửi lịch trình chi tiết nhé? ✈️";
        }

        // 6. Tìm kiếm tour theo điểm đến hoặc từ khóa
        try {
            String[] places = {"sapa", "sa pa", "đà nẵng", "da nang", "hạ long", "ha long", "phú quốc", "phu quoc",
                    "nha trang", "ninh bình", "ninh binh", "huế", "hue", "đà lạt", "da lat", "hà nội", "ha noi",
                    "quy nhơn", "hàn quốc", "han quoc", "nhật bản", "nhat ban", "thái lan", "thai lan", "mỹ", "trung quốc",
                    "singapore", "malaysia", "úc", "châu âu"};
            String matchedKw = null;
            for (String p : places) {
                if (lower.contains(p)) {
                    matchedKw = p;
                    break;
                }
            }
            if (matchedKw != null) {
                List<vn.edu.eaut.tour.model.Tour> found = tourDAO.searchUserTours(matchedKw, null, null, null, null);
                if (found != null && !found.isEmpty()) {
                    StringBuilder ans = new StringBuilder("✈️ **Dạ em tìm thấy tour " + matchedKw.toUpperCase() + " cực hot cho mình nè:**\n");
                    int count = 0;
                    for (vn.edu.eaut.tour.model.Tour t : found) {
                        double p = t.getEffectivePrice();
                        ans.append("• **").append(t.getName()).append("**\n");
                        ans.append("  - Giá: **").append(currencyFmt.format(p)).append(" đ**");
                        if (t.getOriginalPrice() > p) {
                            ans.append(" *(Giá gốc: ~").append(currencyFmt.format(t.getOriginalPrice())).append(" đ)*");
                        }
                        ans.append("\n  - Lịch trình: ").append(t.getDuration() != null ? t.getDuration() : "Theo yêu cầu").append("\n");
                        count++;
                        if (count >= 2) break;
                    }
                    ans.append("👉 Bạn bấm vào tour trên trang chủ hoặc nhập mã **`HE2026`** (giảm 10%) khi đặt để nhận ưu đãi nhé!");
                    return ans.toString();
                }
            }
        } catch (Exception ignored) {}

        // 7. Tour giá rẻ / tiết kiệm
        if (lower.contains("rẻ") || lower.contains("tiết kiệm") || lower.contains("dưới 5") || lower.contains("giá tốt")) {
            return "💰 **Gợi ý tour giá tốt:**\n" +
                   "• **Tour Ninh Bình 1 ngày**: chỉ từ **1.350.000 đ**\n" +
                   "• **Tour SaPa 3N2Đ**: chỉ từ **2.590.000 đ**\n" +
                   "👉 Bạn thích khám phá vùng núi mát mẻ hay đi biển thư giãn để em tư vấn chi tiết hơn ạ?";
        }

        return "✈️ Dạ em là Nhân viên AI Hịn Hò! Em có thể hỗ trợ bạn tìm kiếm các tour trong nước (SaPa, Đà Nẵng, Phú Quốc...), tour quốc tế hoặc tra cứu mã giảm giá hot nhất hôm nay. Bạn đang muốn đi du lịch ở đâu ạ?";
    }

    public String getApiKey() {
        String dbKey = systemSettingDAO.getSetting("gemini_api_key", null);
        if (dbKey != null && !dbKey.trim().isEmpty()) {
            return dbKey.trim();
        }
        String envKey = System.getenv("GEMINI_API_KEY");
        if (envKey != null && !envKey.trim().isEmpty()) {
            return envKey.trim();
        }
        return DEFAULT_API_KEY;
    }

    public java.util.Map<String, Object> testConnection(String testKey, String testModel) {
        java.util.Map<String, Object> res = new java.util.HashMap<>();
        String key = (testKey != null && !testKey.trim().isEmpty()) ? testKey.trim() : getApiKey();
        String model = (testModel != null && !testModel.trim().isEmpty()) ? testModel.trim() : "gemini-3.6-flash";
        long start = System.currentTimeMillis();
        try {
            String ping = callGeminiApi(model, key, "Bạn là trợ lý test kết nối.", "Xin chào, hãy trả lời 'OK'", null);
            long latency = System.currentTimeMillis() - start;
            if (ping != null && !ping.trim().isEmpty()) {
                res.put("success", true);
                res.put("message", "Kết nối thành công tới mô hình " + model + "! Phản hồi: " + ping.trim());
                res.put("latencyMs", latency);
                res.put("model", model);
                return res;
            }
        } catch (Exception e) {
            long latency = System.currentTimeMillis() - start;
            res.put("success", false);
            res.put("message", "Lỗi kết nối: " + e.getMessage());
            res.put("latencyMs", latency);
            res.put("model", model);
            return res;
        }
        long latency = System.currentTimeMillis() - start;
        res.put("success", false);
        res.put("message", "Không nhận được phản hồi từ Gemini API với mô hình " + model);
        res.put("latencyMs", latency);
        res.put("model", model);
        return res;
    }
}
