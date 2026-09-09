package vn.edu.eaut.tour.dao;

import vn.edu.eaut.tour.model.Coupon;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CouponDAO {
    static {
        ensureTableExists();
    }

    private static void ensureTableExists() {
        String createTableSql = "CREATE TABLE IF NOT EXISTS coupons (" +
                "id INT AUTO_INCREMENT PRIMARY KEY, " +
                "code VARCHAR(50) NOT NULL UNIQUE, " +
                "discount_type VARCHAR(20) NOT NULL DEFAULT 'PERCENT', " +
                "discount_value DOUBLE NOT NULL, " +
                "min_order_amount DOUBLE DEFAULT 0, " +
                "max_discount_amount DOUBLE DEFAULT 0, " +
                "expiry_date DATE NOT NULL, " +
                "max_usage INT DEFAULT 100, " +
                "used_count INT DEFAULT 0, " +
                "active BOOLEAN DEFAULT TRUE, " +
                "applicable_tour_id INT DEFAULT NULL, " +
                "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
        
        try (Connection conn = DBContext.getConnection(); Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(createTableSql);
            try {
                stmt.executeUpdate("ALTER TABLE coupons ADD COLUMN applicable_tour_id INT DEFAULT NULL");
            } catch (Exception ignored) {}

            // Chèn sẵn một số mã giảm giá mẫu nếu bảng rỗng
            String checkCountSql = "SELECT COUNT(*) FROM coupons";
            try (ResultSet rs = stmt.executeQuery(checkCountSql)) {
                if (rs.next() && rs.getInt(1) == 0) {
                    stmt.executeUpdate("INSERT INTO coupons (code, discount_type, discount_value, min_order_amount, max_discount_amount, expiry_date, max_usage, active) VALUES " +
                            "('HE2026', 'PERCENT', 10, 2000000, 1000000, '2026-12-31', 200, TRUE), " +
                            "('GIAM200K', 'FIXED', 200000, 1500000, 0, '2026-12-31', 100, TRUE), " +
                            "('VIETNAM500K', 'FIXED', 500000, 5000000, 0, '2026-12-31', 50, TRUE)");
                }
            }
        } catch (Exception ignored) {}
    }

    public List<Coupon> getAllCoupons() {
        List<Coupon> list = new ArrayList<>();
        String sql = "SELECT c.id, c.code, c.discount_type, c.discount_value, c.min_order_amount, c.max_discount_amount, " +
                "c.expiry_date, c.max_usage, c.used_count, c.active, c.applicable_tour_id, t.name AS applicable_tour_name " +
                "FROM coupons c " +
                "LEFT JOIN tours t ON c.applicable_tour_id = t.id " +
                "ORDER BY c.id DESC";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapCoupon(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public Coupon getCouponByCode(String code) {
        if (code == null || code.trim().isEmpty()) return null;
        String sql = "SELECT c.id, c.code, c.discount_type, c.discount_value, c.min_order_amount, c.max_discount_amount, " +
                "c.expiry_date, c.max_usage, c.used_count, c.active, c.applicable_tour_id, t.name AS applicable_tour_name " +
                "FROM coupons c " +
                "LEFT JOIN tours t ON c.applicable_tour_id = t.id " +
                "WHERE UPPER(c.code) = UPPER(?) AND c.active = TRUE AND c.expiry_date >= CURDATE()";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Coupon coupon = mapCoupon(rs);
                    if (coupon.getUsedCount() < coupon.getMaxUsage()) {
                        return coupon;
                    }
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public boolean addCoupon(Coupon coupon) {
        String sql = "INSERT INTO coupons (code, discount_type, discount_value, min_order_amount, max_discount_amount, expiry_date, max_usage, active, applicable_tour_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, coupon.getCode().trim().toUpperCase());
            ps.setString(2, coupon.getDiscountType());
            ps.setDouble(3, coupon.getDiscountValue());
            ps.setDouble(4, coupon.getMinOrderAmount());
            ps.setDouble(5, coupon.getMaxDiscountAmount());
            ps.setDate(6, coupon.getExpiryDate());
            ps.setInt(7, coupon.getMaxUsage());
            ps.setBoolean(8, coupon.isActive());
            if (coupon.getApplicableTourId() != null && coupon.getApplicableTourId() > 0) {
                ps.setInt(9, coupon.getApplicableTourId());
            } else {
                ps.setNull(9, Types.INTEGER);
            }
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean toggleCouponStatus(int id) {
        String sql = "UPDATE coupons SET active = NOT active WHERE id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean deleteCoupon(int id) {
        String sql = "DELETE FROM coupons WHERE id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean incrementUsedCount(int couponId) {
        String sql = "UPDATE coupons SET used_count = used_count + 1 WHERE id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, couponId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean useCoupon(String code) {
        if (code == null || code.trim().isEmpty()) return false;
        String sql = "UPDATE coupons SET used_count = used_count + 1 WHERE UPPER(code) = UPPER(?) AND active = TRUE";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code.trim());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    private Coupon mapCoupon(ResultSet rs) throws SQLException {
        Integer applicableTourId = null;
        int tourIdVal = rs.getInt("applicable_tour_id");
        if (!rs.wasNull() && tourIdVal > 0) {
            applicableTourId = tourIdVal;
        }
        String tourName = null;
        try {
            tourName = rs.getString("applicable_tour_name");
        } catch (Exception ignored) {}

        return new Coupon(
                rs.getInt("id"),
                rs.getString("code"),
                rs.getString("discount_type"),
                rs.getDouble("discount_value"),
                rs.getDouble("min_order_amount"),
                rs.getDouble("max_discount_amount"),
                rs.getDate("expiry_date"),
                rs.getInt("max_usage"),
                rs.getInt("used_count"),
                rs.getBoolean("active"),
                applicableTourId,
                tourName
        );
    }
}
