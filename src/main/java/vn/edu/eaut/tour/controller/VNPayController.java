package vn.edu.eaut.tour.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.eaut.tour.config.VNPayConfig;
import vn.edu.eaut.tour.dao.AuditDAO;
import vn.edu.eaut.tour.dao.BookingDAO;
import vn.edu.eaut.tour.model.User;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;

@WebServlet(urlPatterns = {"/payment/vnpay-create", "/payment/vnpay-return"})
public class VNPayController extends HttpServlet {
    private final BookingDAO bookingDAO = new BookingDAO();
    private final AuditDAO auditDAO = new AuditDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        if ("/payment/vnpay-create".equals(path)) {
            handleCreatePayment(req, resp);
        } else if ("/payment/vnpay-return".equals(path)) {
            handleReturn(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/my-bookings");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }

    private void handleCreatePayment(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String bookingIdParam = req.getParameter("bookingId");
        if (bookingIdParam == null || bookingIdParam.isBlank()) {
            req.getSession().setAttribute("error", "Mã đơn hàng không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/my-bookings");
            return;
        }

        int bookingId;
        try {
            bookingId = Integer.parseInt(bookingIdParam.replaceAll("[^0-9]", ""));
        } catch (Exception e) {
            req.getSession().setAttribute("error", "Mã đơn hàng không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/my-bookings");
            return;
        }

        double amount = bookingDAO.getBookingAmount(bookingId);
        if (amount <= 0) {
            req.getSession().setAttribute("error", "Không tìm thấy thông tin giá tiền cho đơn hàng #" + bookingId);
            resp.sendRedirect(req.getContextPath() + "/my-bookings");
            return;
        }

        long vnpAmount = (long) (amount * 100);
        String vnp_TxnRef = bookingId + "T" + System.currentTimeMillis();
        String vnp_IpAddr = VNPayConfig.getIpAddress(req);

        String scheme = req.getHeader("X-Forwarded-Proto");
        if (scheme == null || scheme.isBlank()) scheme = req.getScheme();
        String host = req.getHeader("X-Forwarded-Host");
        if (host == null || host.isBlank()) host = req.getHeader("Host");
        if (host == null || host.isBlank()) host = req.getServerName();

        String contextPath = req.getContextPath();
        String baseUrl = scheme + "://" + host + (contextPath != null ? contextPath : "");
        String vnp_ReturnUrl = baseUrl + "/payment/vnpay-return";

        Map<String, String> vnp_Params = new HashMap<>();
        vnp_Params.put("vnp_Version", VNPayConfig.VNP_VERSION);
        vnp_Params.put("vnp_Command", VNPayConfig.VNP_COMMAND);
        vnp_Params.put("vnp_TmnCode", VNPayConfig.VNP_TMN_CODE);
        vnp_Params.put("vnp_Amount", String.valueOf(vnpAmount));
        vnp_Params.put("vnp_CurrCode", "VND");
        vnp_Params.put("vnp_TxnRef", vnp_TxnRef);
        vnp_Params.put("vnp_OrderInfo", "Thanh toan don dat tour BK" + bookingId);
        vnp_Params.put("vnp_OrderType", "other");
        vnp_Params.put("vnp_Locale", "vn");
        vnp_Params.put("vnp_ReturnUrl", vnp_ReturnUrl);
        vnp_Params.put("vnp_IpAddr", vnp_IpAddr);

        TimeZone vnTz = TimeZone.getTimeZone("Asia/Ho_Chi_Minh");
        Calendar cld = Calendar.getInstance(vnTz);
        SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
        formatter.setTimeZone(vnTz);
        String vnp_CreateDate = formatter.format(cld.getTime());
        vnp_Params.put("vnp_CreateDate", vnp_CreateDate);

        cld.add(Calendar.MINUTE, 15);
        String vnp_ExpireDate = formatter.format(cld.getTime());
        vnp_Params.put("vnp_ExpireDate", vnp_ExpireDate);

        List<String> fieldNames = new ArrayList<>(vnp_Params.keySet());
        Collections.sort(fieldNames);
        StringBuilder hashData = new StringBuilder();
        StringBuilder query = new StringBuilder();
        boolean first = true;
        for (String fieldName : fieldNames) {
            String fieldValue = vnp_Params.get(fieldName);
            if (fieldValue != null && !fieldValue.isEmpty()) {
                if (!first) {
                    hashData.append('&');
                    query.append('&');
                }
                hashData.append(fieldName).append('=').append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                query.append(URLEncoder.encode(fieldName, StandardCharsets.US_ASCII.toString()))
                     .append('=')
                     .append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                first = false;
            }
        }
        String queryUrl = query.toString();
        String vnp_SecureHash = VNPayConfig.hmacSHA512(VNPayConfig.VNP_HASH_SECRET, hashData.toString());
        queryUrl += "&vnp_SecureHash=" + vnp_SecureHash;
        String paymentUrl = VNPayConfig.VNP_PAY_URL + "?" + queryUrl;

        resp.sendRedirect(paymentUrl);
    }

    private void handleReturn(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = (User) req.getSession().getAttribute("user");
        int userId = user != null ? user.getId() : 0;

        Map<String, String> fields = new HashMap<>();
        for (Enumeration<String> params = req.getParameterNames(); params.hasMoreElements(); ) {
            String fieldName = params.nextElement();
            String fieldValue = req.getParameter(fieldName);
            if ((fieldValue != null) && (fieldValue.length() > 0)) {
                fields.put(fieldName, fieldValue);
            }
        }

        String vnp_SecureHash = req.getParameter("vnp_SecureHash");
        fields.remove("vnp_SecureHashType");
        fields.remove("vnp_SecureHash");

        String signValue = VNPayConfig.hashAllFields(fields);
        if (signValue.equalsIgnoreCase(vnp_SecureHash)) {
            String vnp_ResponseCode = req.getParameter("vnp_ResponseCode");
            String vnp_TxnRef = req.getParameter("vnp_TxnRef");
            int bookingId = 0;
            if (vnp_TxnRef != null) {
                try {
                    if (vnp_TxnRef.contains("T")) {
                        bookingId = Integer.parseInt(vnp_TxnRef.split("T")[0]);
                    } else if (vnp_TxnRef.contains("_")) {
                        bookingId = Integer.parseInt(vnp_TxnRef.split("_")[0]);
                    }
                } catch (Exception ignored) {}
            }

            if ("00".equals(vnp_ResponseCode)) {
                if (bookingId > 0) {
                    bookingDAO.confirmPayment(bookingId);
                    String transactionNo = req.getParameter("vnp_TransactionNo");
                    auditDAO.record(userId, bookingId, "VNPAY_SUCCESS", "PENDING", "PAID: " + transactionNo, req.getRemoteAddr());
                    req.getSession().setAttribute("msg", "Thanh toán thành công qua VNPAY cho đơn hàng BK" + bookingId + "! Hợp đồng điện tử và vé của bạn đã được kích hoạt.");
                } else {
                    req.getSession().setAttribute("msg", "Thanh toán thành công qua VNPAY!");
                }
            } else {
                req.getSession().setAttribute("error", "Giao dịch thanh toán VNPAY không thành công (Mã phản hồi: " + vnp_ResponseCode + "). Vui lòng thử lại hoặc chọn hình thức khác.");
            }
        } else {
            req.getSession().setAttribute("error", "Chữ ký bảo mật VNPAY không hợp lệ hoặc dữ liệu giao dịch đã bị chỉnh sửa.");
        }

        resp.sendRedirect(req.getContextPath() + "/my-bookings");
    }
}
