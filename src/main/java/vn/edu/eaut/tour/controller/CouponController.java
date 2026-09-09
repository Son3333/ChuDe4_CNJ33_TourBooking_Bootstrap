package vn.edu.eaut.tour.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.eaut.tour.dao.CouponDAO;
import vn.edu.eaut.tour.model.Coupon;
import vn.edu.eaut.tour.model.User;

import java.io.IOException;
import java.sql.Date;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/coupon")
public class CouponController extends HttpServlet {
    private final CouponDAO couponDAO = new CouponDAO();
    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if ("check".equalsIgnoreCase(action)) {
            String code = request.getParameter("code");
            double price = 0;
            try {
                price = Double.parseDouble(request.getParameter("price"));
            } catch (Exception ignored) {}

            int tourId = 0;
            try {
                tourId = Integer.parseInt(request.getParameter("tourId"));
            } catch (Exception ignored) {}

            Coupon coupon = couponDAO.getCouponByCode(code);
            Map<String, Object> result = new HashMap<>();

            if (coupon == null) {
                result.put("valid", false);
                result.put("message", "Mã giảm giá không tồn tại, đã hết hạn hoặc hết lượt sử dụng.");
            } else if (!coupon.isApplicableTo(tourId)) {
                result.put("valid", false);
                String tName = coupon.getApplicableTourName() != null ? coupon.getApplicableTourName() : ("#" + coupon.getApplicableTourId());
                result.put("message", "Mã voucher " + coupon.getCode() + " chỉ áp dụng riêng cho tour: " + tName + ".");
            } else if (price < coupon.getMinOrderAmount()) {
                result.put("valid", false);
                result.put("message", "Đơn hàng tối thiểu phải từ " + String.format("%,.0f", coupon.getMinOrderAmount()) + " VNĐ để áp dụng mã này.");
            } else {
                double discount = coupon.calculateDiscount(price);
                double finalPrice = Math.max(0, price - discount);
                result.put("valid", true);
                result.put("code", coupon.getCode());
                result.put("discountType", coupon.getDiscountType());
                result.put("discountValue", coupon.getDiscountValue());
                result.put("discountAmount", discount);
                result.put("finalPrice", finalPrice);
                result.put("message", "Áp dụng thành công! Đã giảm " + String.format("%,.0f", discount) + " VNĐ.");
            }
            mapper.writeValue(response.getWriter(), result);
            return;
        }

        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        mapper.writeValue(response.getWriter(), Map.of("error", "Invalid request action."));
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || !"ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if ("create".equalsIgnoreCase(action)) {
            try {
                String code = request.getParameter("code");
                String discountType = request.getParameter("discountType");
                double discountValue = Double.parseDouble(request.getParameter("discountValue"));
                double minOrderAmount = Double.parseDouble(request.getParameter("minOrderAmount"));
                double maxDiscountAmount = 0;
                try {
                    maxDiscountAmount = Double.parseDouble(request.getParameter("maxDiscountAmount"));
                } catch (Exception ignored) {}
                Date expiryDate = Date.valueOf(request.getParameter("expiryDate"));
                int maxUsage = Integer.parseInt(request.getParameter("maxUsage"));

                String applicableScope = request.getParameter("applicableScope");
                Integer applicableTourId = null;
                if ("SPECIFIC".equalsIgnoreCase(applicableScope)) {
                    try {
                        int tid = Integer.parseInt(request.getParameter("applicableTourId"));
                        if (tid > 0) applicableTourId = tid;
                    } catch (Exception ignored) {}
                }

                Coupon c = new Coupon(0, code, discountType, discountValue, minOrderAmount, maxDiscountAmount, expiryDate, maxUsage, 0, true, applicableTourId, null);
                couponDAO.addCoupon(c);
                request.getSession().setAttribute("success", "Đã tạo mã giảm giá " + code.toUpperCase() + " thành công!");
            } catch (Exception e) {
                request.getSession().setAttribute("error", "Lỗi tạo mã giảm giá: " + e.getMessage());
            }
        } else if ("toggle".equalsIgnoreCase(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                couponDAO.toggleCouponStatus(id);
                request.getSession().setAttribute("success", "Đã cập nhật trạng thái mã giảm giá!");
            } catch (Exception e) {
                request.getSession().setAttribute("error", "Lỗi: " + e.getMessage());
            }
        } else if ("delete".equalsIgnoreCase(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                couponDAO.deleteCoupon(id);
                request.getSession().setAttribute("success", "Đã xóa mã giảm giá thành công!");
            } catch (Exception e) {
                request.getSession().setAttribute("error", "Lỗi: " + e.getMessage());
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin#coupons");
    }
}

