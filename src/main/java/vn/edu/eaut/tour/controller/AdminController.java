package vn.edu.eaut.tour.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.eaut.tour.dao.TourDAO;
import vn.edu.eaut.tour.model.User;
import vn.edu.eaut.tour.model.Tour;
import vn.edu.eaut.tour.model.TourIncident;
import vn.edu.eaut.tour.dao.AdminDAO;
import vn.edu.eaut.tour.dao.AuditDAO;
import vn.edu.eaut.tour.dao.BookingDAO;
import vn.edu.eaut.tour.dao.CouponDAO;
import vn.edu.eaut.tour.dao.UserDAO;
import vn.edu.eaut.tour.dao.SystemSettingDAO;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@WebServlet("/admin")
public class AdminController extends HttpServlet {
    private static final int PAGE_SIZE = 5;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        if (!user.isAdmin() && !user.isManager() && !user.isStaff()) {
            resp.sendRedirect(req.getContextPath() + "/tours");
            return;
        }

        AdminDAO adminDAO = new AdminDAO();
        if ("exportBookings".equals(req.getParameter("action"))) {
            if (!user.isManager() && !user.isAdmin()) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            resp.setContentType("text/csv; charset=UTF-8");
            resp.setHeader("Content-Disposition", "attachment; filename=\"BaoCaoDonHang_TourBooking.csv\"");
            resp.setCharacterEncoding("UTF-8");
            PrintWriter writer = resp.getWriter();
            writer.write("\uFEFF");
            writer.println("Mã đơn,Khách hàng,Tài khoản,Tên Tour,Ngày đặt,Tổng tiền (VNĐ),Trạng thái,Thanh toán");
            for (Map<String, Object> b : adminDAO.getBookings()) {
                writer.println(String.format("\"#%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%.0f\",\"%s\",\"%s\"",
                        b.get("id"),
                        cleanCsv(b.get("customer")),
                        cleanCsv(b.get("username")),
                        cleanCsv(b.get("tour")),
                        b.get("date"),
                        b.get("total"),
                        b.get("status"),
                        b.get("paymentStatus")));
            }
            writer.flush();
            return;
        }

        TourDAO tourDAO = new TourDAO();
        AuditDAO auditDAO = new AuditDAO();
        UserDAO userDAO = new UserDAO();
        BookingDAO bookingDAO = new BookingDAO();
        CouponDAO couponDAO = new CouponDAO();
        SystemSettingDAO systemSettingDAO = new SystemSettingDAO();

        String keyword = req.getParameter("q");
        String availability = req.getParameter("availability");
        int page = parsePage(req.getParameter("page"));
        int total = tourDAO.countTours(keyword, availability);
        int totalPages = Math.max(1, (int) Math.ceil(total / (double) PAGE_SIZE));
        page = Math.min(page, totalPages);

        req.setAttribute("tours", tourDAO.searchTours(keyword, availability, page, PAGE_SIZE));
        req.setAttribute("allToursSimple", tourDAO.getAllToursAdmin());
        req.setAttribute("keyword", keyword == null ? "" : keyword);
        req.setAttribute("availability", availability == null ? "" : availability);
        req.setAttribute("page", page);
        req.setAttribute("totalPages", totalPages);

        req.setAttribute("coupons", couponDAO.getAllCoupons());
        req.setAttribute("aiSettings", systemSettingDAO.getAllSettings());
        req.setAttribute("monthlyRevenue", bookingDAO.getMonthlyRevenue());
        req.setAttribute("statusCounts", bookingDAO.getBookingStatusCounts());
        req.setAttribute("topSellingTours", bookingDAO.getTopSellingTours());
        req.setAttribute("seasonStats", bookingDAO.getSeasonStatistics());

        req.setAttribute("stats", adminDAO.getStats());
        req.setAttribute("bookings", adminDAO.getBookings());
        req.setAttribute("users", adminDAO.getUsers());
        req.setAttribute("reviews", adminDAO.getReviews());
        req.setAttribute("auditLogs", auditDAO.getLogs());
        req.setAttribute("loginHistory", userDAO.getLoginHistory(100));
        req.setAttribute("incidents", tourDAO.getIncidents(0));

        // Checkin passengers for specific tour
        String checkinTourIdParam = req.getParameter("checkinTourId");
        if (checkinTourIdParam != null && !checkinTourIdParam.isBlank()) {
            try {
                int checkinTourId = Integer.parseInt(checkinTourIdParam);
                req.setAttribute("checkinTourId", checkinTourId);
                req.setAttribute("checkinPassengers", bookingDAO.getPassengersByTour(checkinTourId));
            } catch (NumberFormatException ignored) {}
        }

        if (req.getParameter("edit") != null) {
            try { req.setAttribute("editTour", tourDAO.getById(Integer.parseInt(req.getParameter("edit")))); } catch (NumberFormatException ignored) { }
        }
        if (req.getSession().getAttribute("csrfToken") == null) req.getSession().setAttribute("csrfToken", UUID.randomUUID().toString());
        req.getRequestDispatcher("admin.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null || (!user.isAdmin() && !user.isManager() && !user.isStaff())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        String expected = (String) req.getSession().getAttribute("csrfToken");
        if (expected == null || !expected.equals(req.getParameter("csrfToken"))) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        TourDAO dao = new TourDAO();
        AdminDAO adminDAO = new AdminDAO();
        AuditDAO auditDAO = new AuditDAO();
        BookingDAO bookingDAO = new BookingDAO();
        String action = req.getParameter("action");
        String tab = req.getParameter("tab");

        try {
            if ("approveTour".equals(action)) {
                if (!user.isManager() && !user.isAdmin()) { resp.sendError(HttpServletResponse.SC_FORBIDDEN); return; }
                int tourId = parseInt(req.getParameter("id"));
                dao.updateStatus(tourId, "APPROVED", "Đã duyệt bởi " + user.getFullName());
                auditDAO.record(user.getId(), user.getRole(), "tours", tourId, "APPROVE_TOUR", "PENDING", "APPROVED", req.getRemoteAddr());
                req.getSession().setAttribute("success", "Đã phê duyệt và mở bán Tour #" + tourId);
                tab = "tours";
            } else if ("rejectTour".equals(action)) {
                if (!user.isManager() && !user.isAdmin()) { resp.sendError(HttpServletResponse.SC_FORBIDDEN); return; }
                int tourId = parseInt(req.getParameter("id"));
                String note = req.getParameter("note");
                dao.updateStatus(tourId, "REJECTED", note != null ? note : "Từ chối kiểm duyệt");
                auditDAO.record(user.getId(), user.getRole(), "tours", tourId, "REJECT_TOUR", "PENDING", "REJECTED: " + note, req.getRemoteAddr());
                req.getSession().setAttribute("success", "Đã từ chối duyệt Tour #" + tourId);
                tab = "tours";
            } else if ("toggleCheckin".equals(action)) {
                int passengerId = parseInt(req.getParameter("id"));
                boolean checkedIn = Boolean.parseBoolean(req.getParameter("checkedIn"));
                bookingDAO.updatePassengerCheckIn(passengerId, checkedIn);
                auditDAO.record(user.getId(), user.getRole(), "booking_passengers", passengerId, "TOGGLE_CHECKIN", checkedIn ? "ABSENT" : "CHECKED_IN", checkedIn ? "CHECKED_IN" : "ABSENT", req.getRemoteAddr());
                req.getSession().setAttribute("success", checkedIn ? "Đã điểm danh hành khách lên xe!" : "Đã hủy điểm danh hành khách!");
                tab = "checkin";
            } else if ("resolveIncident".equals(action)) {
                int incidentId = parseInt(req.getParameter("id"));
                String resolution = req.getParameter("resolution");
                dao.resolveIncident(incidentId, resolution);
                auditDAO.record(user.getId(), user.getRole(), "tour_incidents", incidentId, "RESOLVE_INCIDENT", "OPEN", "RESOLVED: " + resolution, req.getRemoteAddr());
                req.getSession().setAttribute("success", "Đã lưu phương án giải quyết sự cố thành công!");
                tab = "incidents";
            } else if ("reportIncident".equals(action)) {
                int tourId = parseInt(req.getParameter("tourId"));
                String incidentType = req.getParameter("incidentType");
                String severity = req.getParameter("severity");
                String description = req.getParameter("description");
                TourIncident inc = new TourIncident(0, tourId, user.getId(), user.getFullName(), incidentType, description, severity, "OPEN", null, null, null);
                dao.addIncident(inc);
                auditDAO.record(user.getId(), user.getRole(), "tour_incidents", tourId, "REPORT_INCIDENT", "", incidentType + ": " + description, req.getRemoteAddr());
                req.getSession().setAttribute("success", "Đã gửi báo cáo sự cố thành công!");
                tab = "incidents";
            } else if ("bookingStatus".equals(action)) {
                handleBookingStatus(req, adminDAO, auditDAO, user);
            } else if ("refundComplete".equals(action)) {
                handleRefundComplete(req, adminDAO, auditDAO, user);
            } else if ("toggleUser".equals(action)) {
                handleToggleUser(req, adminDAO, auditDAO, user);
            } else if ("updateRole".equals(action)) {
                handleUpdateRole(req, auditDAO, user);
                tab = "customers";
            } else if ("review".equals(action)) {
                handleReview(req, adminDAO, auditDAO, user);
            } else if ("delete".equals(action)) {
                handleDelete(req, dao, auditDAO, user);
            } else if ("save".equals(action)) {
                handleSave(req, dao, auditDAO, user);
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("error", "Dữ liệu nhập vào không hợp lệ hoặc có lỗi xảy ra.");
        }

        if (tab == null || tab.isBlank()) {
            if ("bookingStatus".equals(action)) tab = "bookings";
            else if ("refundComplete".equals(action)) tab = "refunds";
            else if ("toggleUser".equals(action)) tab = "customers";
            else if ("review".equals(action)) tab = "reviews";
            else if ("toggleCheckin".equals(action)) tab = "checkin";
            else if ("resolveIncident".equals(action) || "reportIncident".equals(action)) tab = "incidents";
            else tab = "tours";
        }

        String checkinTourIdParam = req.getParameter("tourId");
        if ("toggleCheckin".equals(action) && checkinTourIdParam != null && !checkinTourIdParam.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/admin?checkinTourId=" + checkinTourIdParam + "#" + tab);
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin#" + tab);
        }
    }

    private void handleBookingStatus(HttpServletRequest req, AdminDAO adminDAO, AuditDAO auditDAO, User user) throws Exception {
        int bookingId = parseInt(req.getParameter("id"));
        String status = req.getParameter("status");
        String paymentStatus = req.getParameter("paymentStatus");
        adminDAO.updateBookingStatus(bookingId, status, paymentStatus);
        auditDAO.record(user.getId(), user.getRole(), "bookings", bookingId, "UPDATE_BOOKING_STATUS", "", status + "/" + paymentStatus, req.getRemoteAddr());
        req.getSession().setAttribute("success", "Cập nhật trạng thái đơn đặt thành công!");
    }

    private void handleRefundComplete(HttpServletRequest req, AdminDAO adminDAO, AuditDAO auditDAO, User user) throws Exception {
        int bookingId = parseInt(req.getParameter("id"));
        adminDAO.completeRefund(bookingId, req.getParameter("transactionId"));
        auditDAO.record(user.getId(), user.getRole(), "bookings", bookingId, "COMPLETE_REFUND", "PENDING", "COMPLETED", req.getRemoteAddr());
        req.getSession().setAttribute("success", "Xác nhận hoàn tiền thành công!");
    }

    private void handleToggleUser(HttpServletRequest req, AdminDAO adminDAO, AuditDAO auditDAO, User user) throws Exception {
        int targetUserId = parseInt(req.getParameter("id"));
        adminDAO.toggleUser(targetUserId);
        auditDAO.record(user.getId(), user.getRole(), "users", targetUserId, "TOGGLE_USER_STATUS", "", "USER_ID:" + targetUserId, req.getRemoteAddr());
        req.getSession().setAttribute("success", "Cập nhật trạng thái tài khoản thành công!");
    }

    private void handleUpdateRole(HttpServletRequest req, AuditDAO auditDAO, User user) throws Exception {
        if (!user.isAdmin()) {
            req.getSession().setAttribute("error", "Chỉ Quản trị viên (Admin) mới có quyền phân quyền!");
            return;
        }
        int targetUserId = parseInt(req.getParameter("id"));
        String newRole = req.getParameter("role");
        if (newRole != null && (newRole.equals("USER") || newRole.equals("STAFF") || newRole.equals("MANAGER"))) {
            new UserDAO().updateRole(targetUserId, newRole);
            auditDAO.record(user.getId(), user.getRole(), "users", targetUserId, "UPDATE_ROLE", "", newRole, req.getRemoteAddr());
            req.getSession().setAttribute("success", "Phân quyền tài khoản thành công sang vai trò: " + newRole + "!");
        }
    }

    private void handleReview(HttpServletRequest req, AdminDAO adminDAO, AuditDAO auditDAO, User user) throws Exception {
        long reviewId = Long.parseLong(req.getParameter("id"));
        adminDAO.updateReview(reviewId, "true".equals(req.getParameter("visible")), req.getParameter("reply"));
        auditDAO.record(user.getId(), user.getRole(), "reviews", (int) reviewId, "UPDATE_REVIEW", "", "REVIEW_ID:" + reviewId, req.getRemoteAddr());
        req.getSession().setAttribute("success", "Cập nhật đánh giá thành công!");
    }

    private void handleDelete(HttpServletRequest req, TourDAO dao, AuditDAO auditDAO, User user) throws Exception {
        int tourId = parseInt(req.getParameter("id"));
        boolean ok = dao.delete(tourId);
        if (ok) {
            auditDAO.record(user.getId(), user.getRole(), "tours", tourId, "DELETE_TOUR", "", "TOUR_ID:" + tourId, req.getRemoteAddr());
            req.getSession().setAttribute("success", "Đã xóa tour thành công!");
        } else {
            req.getSession().setAttribute("error", "Không thể xóa tour (tour đang có đơn đặt hàng).");
        }
    }

    private void handleSave(HttpServletRequest req, TourDAO dao, AuditDAO auditDAO, User user) throws Exception {
        Tour tour = new Tour();
        int tourId = parseInt(req.getParameter("id"));
        tour.setId(tourId);
        String name = req.getParameter("name");
        tour.setName(name != null ? name.trim() : "");
        tour.setDescription(req.getParameter("description"));
        tour.setPrice(Double.parseDouble(req.getParameter("price")));
        tour.setOriginalPrice(parseDouble(req.getParameter("originalPrice")));
        tour.setAvailableSeats(Integer.parseInt(req.getParameter("availableSeats")));
        tour.setStartDate(Date.valueOf(req.getParameter("startDate")));
        String imageUrl = cleanImageUrl(req.getParameter("imageUrl"));
        tour.setImageUrl(imageUrl);
        tour.setOrigin(req.getParameter("origin"));
        tour.setDestination(req.getParameter("destination"));
        tour.setDuration(req.getParameter("duration"));
        String country = req.getParameter("country");
        tour.setCountry(country != null && !country.isBlank() ? country.trim() : "Việt Nam");

        // Set status based on role and request
        String status = req.getParameter("status");
        if (status != null && !status.isBlank()) {
            tour.setStatus(status);
        } else if (tourId == 0) {
            tour.setStatus("PENDING");
        } else {
            Tour existing = dao.getById(tourId);
            if (existing != null && existing.getStatus() != null) {
                tour.setStatus(existing.getStatus());
            } else {
                tour.setStatus("PENDING");
            }
        }

        String discountEndDateStr = req.getParameter("discountEndDate");
        if (discountEndDateStr != null && !discountEndDateStr.isBlank()) {
            try {
                String normalized = discountEndDateStr.replace('T', ' ');
                if (normalized.length() == 16) {
                    normalized += ":00";
                }
                tour.setDiscountEndDate(java.sql.Timestamp.valueOf(normalized));
            } catch (Exception ignored) {
                tour.setDiscountEndDate(null);
            }
        } else {
            tour.setDiscountEndDate(null);
        }
        if (tour.getName().isBlank() || tour.getPrice() < 0 || tour.getAvailableSeats() < 0) throw new IllegalArgumentException("Invalid data");
        boolean ok = dao.save(tour);
        if (ok) {
            auditDAO.record(user.getId(), user.getRole(), "tours", tourId, tourId == 0 ? "CREATE_TOUR" : "UPDATE_TOUR", "", tour.getName(), req.getRemoteAddr());
            req.getSession().setAttribute("success", tourId == 0 ? "Thêm tour mới thành công (Trạng thái: " + tour.getStatus() + ")!" : "Cập nhật tour thành công!");
        } else {
            req.getSession().setAttribute("error", "Không thể lưu tour vào cơ sở dữ liệu.");
        }
    }

    private int parsePage(String value) { try { return Math.max(1, Integer.parseInt(value)); } catch (Exception e) { return 1; } }
    private int parseInt(String value) { try { return Integer.parseInt(value); } catch (Exception e) { return 0; } }
    private double parseDouble(String value) { try { return Double.parseDouble(value); } catch (Exception e) { return 0; } }
    private String cleanCsv(Object val) { return val == null ? "" : val.toString().replace("\"", "\"\""); }

    private String cleanImageUrl(String url) {
        if (url == null) return null;
        url = url.trim().replaceAll("^['\"`<“‘\\s]+|['\"`>”’\\s]+$", "");
        if (url.startsWith("id/OIP.") || url.startsWith("/id/OIP.") || url.startsWith("id/")) {
            url = "https://th.bing.com/th/" + url.replaceAll("^/+", "");
        } else if (url.startsWith("th/id/") || url.startsWith("/th/id/")) {
            url = "https://th.bing.com/" + url.replaceAll("^/+", "");
        } else if (url.startsWith("th?id=") || url.startsWith("/th?id=")) {
            url = "https://th.bing.com/th" + (url.startsWith("/") ? "" : "/") + url;
        } else if (url.startsWith("//")) {
            url = "https:" + url;
        } else if (!url.startsWith("http://") && !url.startsWith("https://") && !url.startsWith("data:") && !url.startsWith("/")) {
            if (url.contains(".") && !url.contains(" ")) {
                url = "https://" + url;
            }
        }
        if (url.contains("google.") && url.contains("imgurl=")) {
            try {
                int start = url.indexOf("imgurl=") + 7;
                int end = url.indexOf('&', start);
                String raw = end != -1 ? url.substring(start, end) : url.substring(start);
                url = cleanImageUrl(java.net.URLDecoder.decode(raw, java.nio.charset.StandardCharsets.UTF_8));
            } catch (Exception ignored) {}
        }
        return url;
    }
}