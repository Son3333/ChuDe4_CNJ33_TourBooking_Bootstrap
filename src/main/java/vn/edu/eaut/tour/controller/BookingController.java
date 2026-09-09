package vn.edu.eaut.tour.controller;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import vn.edu.eaut.tour.dao.BookingDAO;
import vn.edu.eaut.tour.dao.AuditDAO;
import vn.edu.eaut.tour.dao.BookingDAO;
import vn.edu.eaut.tour.dao.CouponDAO;
import vn.edu.eaut.tour.dao.TourDAO;
import vn.edu.eaut.tour.dao.UserDAO;
import vn.edu.eaut.tour.model.User;
import java.io.IOException;
import java.util.UUID;

@WebServlet(urlPatterns = {"/user/bookings", "/my-bookings"})
public class BookingController extends HttpServlet {
    private BookingDAO bookingDAO = new BookingDAO();
    private TourDAO tourDAO = new TourDAO();
    private AuditDAO auditDAO = new AuditDAO();
    private CouponDAO couponDAO = new CouponDAO();

    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        String action = req.getParameter("action");
        if (req.getSession().getAttribute("csrfToken") == null) {
            req.getSession().setAttribute("csrfToken", UUID.randomUUID().toString());
        }
        req.setAttribute("myBookings", bookingDAO.getBookingsByUser(user.getId()));
        req.getRequestDispatcher("/my-bookings.jsp").forward(req, resp);
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        if (!validToken(req)) {
            req.getSession().setAttribute("error", "Phiên làm việc hết hạn hoặc yêu cầu không hợp lệ. Vui lòng thử lại.");
        } else if ("cancel".equals(req.getParameter("action"))) {
            cancelBooking(req, resp, user);
            return;
        } else if ("review".equals(req.getParameter("action"))) {
            submitReview(req, resp, user);
            return;
        } else {
            try {
                int tourId = Integer.parseInt(req.getParameter("tourId"));
                String couponCode = req.getParameter("couponCode");
                if (bookingDAO.addBooking(user.getId(), tourId)) {
                    int bookingId = bookingDAO.getLatestBookingId(user.getId(), tourId);
                    if (couponCode != null && !couponCode.trim().isEmpty()) {
                        couponDAO.useCoupon(couponCode.trim());
                    }
                    auditDAO.record(user.getId(), bookingId, "BOOK", "NONE", "PENDING", req.getRemoteAddr());
                    req.getSession().setAttribute("msg", "Đã giữ chỗ thành công! Vui lòng hoàn tất thanh toán.");
                } else req.getSession().setAttribute("error", "Tour đã hết chỗ!");
            } catch (NumberFormatException e) { req.getSession().setAttribute("error", "Mã tour không hợp lệ."); }
        }
        resp.sendRedirect(req.getContextPath() + "/user/bookings");
    }

    private void submitReview(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        try {
            int tourId = Integer.parseInt(req.getParameter("tourId"));
            int rating = Integer.parseInt(req.getParameter("rating"));
            String comment = req.getParameter("comment");
            if (comment == null || comment.trim().isEmpty()) {
                req.getSession().setAttribute("error", "Vui lòng nhập nội dung đánh giá.");
            } else if (rating < 1 || rating > 5) {
                req.getSession().setAttribute("error", "Số sao đánh giá phải từ 1 đến 5.");
            } else {
                boolean ok = tourDAO.addReview(user.getId(), tourId, rating, comment.trim());
                if (ok) {
                    auditDAO.record(user.getId(), 0, "ADD_REVIEW", "", "TOUR:" + tourId + " RATING:" + rating, req.getRemoteAddr());
                    req.getSession().setAttribute("msg", "Cảm ơn bạn đã gửi đánh giá chuyến đi!");
                } else {
                    req.getSession().setAttribute("error", "Không thể gửi đánh giá. Vui lòng thử lại sau.");
                }
            }
        } catch (Exception e) {
            req.getSession().setAttribute("error", "Dữ liệu đánh giá không hợp lệ.");
        }
        resp.sendRedirect(req.getContextPath() + "/user/bookings");
    }

    private void cancelBooking(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        try {
            int bookingId = Integer.parseInt(req.getParameter("bookingId"));
            if (bookingDAO.cancelBooking(bookingId, user.getId())) {
                auditDAO.record(user.getId(), bookingId, "CANCEL", "PENDING", "CANCELLED", req.getRemoteAddr());
                req.getSession().setAttribute("msg", "Đã hủy tour thành công! Yêu cầu hoàn tiền đã được gửi tới quản trị viên.");
            } else {
                req.getSession().setAttribute("error", "Không thể hủy tour hoặc đơn đặt này đã bị hủy trước đó.");
            }
        } catch (NumberFormatException e) {
            req.getSession().setAttribute("error", "Mã đặt tour không hợp lệ.");
        }
        resp.sendRedirect(req.getContextPath() + "/user/bookings");
    }

    private boolean validToken(HttpServletRequest req) {
        String expected = (String) req.getSession().getAttribute("csrfToken");
        String actual = req.getParameter("csrfToken");
        if (expected == null || expected.isEmpty()) {
            expected = UUID.randomUUID().toString();
            req.getSession().setAttribute("csrfToken", expected);
            return true;
        }
        return expected.equals(actual);
    }
}