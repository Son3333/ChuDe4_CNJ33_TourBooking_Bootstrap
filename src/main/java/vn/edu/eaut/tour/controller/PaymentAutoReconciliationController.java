package vn.edu.eaut.tour.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.eaut.tour.dao.AuditDAO;
import vn.edu.eaut.tour.dao.BookingDAO;
import vn.edu.eaut.tour.model.User;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@WebServlet(urlPatterns = {"/payment/check", "/api/payment/webhook"})
public class PaymentAutoReconciliationController extends HttpServlet {
    private final BookingDAO bookingDAO = new BookingDAO();
    private final AuditDAO auditDAO = new AuditDAO();
    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");
        String bookingIdParam = req.getParameter("bookingId");
        int bookingId = 0;
        try {
            if (bookingIdParam != null) {
                bookingId = Integer.parseInt(bookingIdParam.replaceAll("[^0-9]", ""));
            }
        } catch (Exception ignored) {}

        Map<String, Object> responseData = new HashMap<>();

        if (bookingId <= 0) {
            responseData.put("success", false);
            responseData.put("message", "Mã đơn hàng không hợp lệ.");
            mapper.writeValue(resp.getWriter(), responseData);
            return;
        }

        // 1. Kiểm tra trạng thái đơn hàng (Polling)
        if ("checkStatus".equalsIgnoreCase(action)) {
            String status = bookingDAO.getBookingStatus(bookingId);
            responseData.put("success", true);
            responseData.put("status", status != null ? status : "NOT_FOUND");
            responseData.put("isPaid", "CONFIRMED".equalsIgnoreCase(status) || "COMPLETED".equalsIgnoreCase(status));
            mapper.writeValue(resp.getWriter(), responseData);
            return;
        }

        // 2. Đối soát trạng thái thanh toán (Auto-Reconcile Check)
        if ("autoReconcile".equalsIgnoreCase(action)) {
            User user = (User) req.getSession().getAttribute("user");
            int userId = user != null ? user.getId() : 0;
            boolean isAdmin = user != null && ("ADMIN".equalsIgnoreCase(user.getRole()) || "MANAGER".equalsIgnoreCase(user.getRole()));
            boolean isStaffOverride = "true".equalsIgnoreCase(req.getParameter("staffOverride")) && isAdmin;

            String currentStatus = bookingDAO.getBookingStatus(bookingId);
            if ("CONFIRMED".equalsIgnoreCase(currentStatus) || "COMPLETED".equalsIgnoreCase(currentStatus)) {
                responseData.put("success", true);
                responseData.put("isPaid", true);
                responseData.put("status", currentStatus);
                responseData.put("message", "Đơn hàng đã được xác nhận thanh toán thành công!");
                mapper.writeValue(resp.getWriter(), responseData);
                return;
            }

            // Chỉ Admin hoặc Manager mới có quyền duyệt test nếu có tham số staffOverride
            if (isStaffOverride) {
                boolean confirmed = bookingDAO.confirmPayment(bookingId);
                if (confirmed) {
                    auditDAO.record(userId, bookingId, "STAFF_MANUAL_APPROVE", "PENDING", "CONFIRMED", req.getRemoteAddr());
                    responseData.put("success", true);
                    responseData.put("isPaid", true);
                    responseData.put("status", "CONFIRMED");
                    responseData.put("message", "Quản trị viên đã duyệt đơn #BK" + bookingId + " thành công.");
                } else {
                    responseData.put("success", false);
                    responseData.put("isPaid", false);
                    responseData.put("message", "Không thể duyệt đơn hàng này.");
                }
                mapper.writeValue(resp.getWriter(), responseData);
                return;
            }

            // Đối với khách hàng thông thường: Tuyệt đối không duyệt bừa khi chưa có tiền từ Webhook
            responseData.put("success", false);
            responseData.put("isPaid", false);
            responseData.put("status", currentStatus != null ? currentStatus : "PENDING");
            responseData.put("message", "Hệ thống chưa ghi nhận tiền về từ ngân hàng cho mã đơn #BK" + bookingId + ". Nếu bạn vừa quét mã chuyển khoản, xin vui lòng đợi 30 giây đến 1 phút để hệ thống ngân hàng đồng bộ tín hiệu, hoặc liên hệ nhân viên.");
            mapper.writeValue(resp.getWriter(), responseData);
            return;
        }

        responseData.put("success", false);
        responseData.put("message", "Yêu cầu không hợp lệ.");
        mapper.writeValue(resp.getWriter(), responseData);
    }

    /**
     * Webhook nhận tín hiệu tự động từ Ngân hàng / SePAY / Casso / VietQR Webhook
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = req.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }

        Map<String, Object> result = new HashMap<>();
        try {
            String rawJson = sb.toString();
            JsonNode root = mapper.readTree(rawJson);

            // Tìm nội dung chuyển khoản từ các trường phổ biến (content, description, memo)
            String content = "";
            if (root.has("content")) content = root.get("content").asText();
            else if (root.has("description")) content = root.get("description").asText();
            else if (root.has("memo")) content = root.get("memo").asText();

            // Tìm mã đơn hàng dạng BK<số>
            Pattern pattern = Pattern.compile("BK(\\d+)", Pattern.CASE_INSENSITIVE);
            Matcher matcher = pattern.matcher(content);

            if (matcher.find()) {
                int bookingId = Integer.parseInt(matcher.group(1));
                boolean ok = bookingDAO.confirmPayment(bookingId);
                if (ok) {
                    auditDAO.record(0, bookingId, "WEBHOOK_AUTO_CONFIRM", "PENDING", "CONFIRMED", req.getRemoteAddr());
                    result.put("success", true);
                    result.put("message", "Đã tự động xác nhận đơn BK" + bookingId);
                    mapper.writeValue(resp.getWriter(), result);
                    return;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        result.put("success", false);
        result.put("message", "Không tìm thấy mã đơn hàng khớp trong nội dung chuyển khoản.");
        mapper.writeValue(resp.getWriter(), result);
    }
}

