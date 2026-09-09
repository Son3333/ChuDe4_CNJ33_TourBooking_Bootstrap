package vn.edu.eaut.tour.dao;

import vn.edu.eaut.tour.util.CryptoUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AuditDAO {
    public void record(int userId, int bookingId, String action, String oldStatus, String newStatus, String ipAddress) {
        record(userId, "SYSTEM", "bookings", bookingId, action, oldStatus, newStatus, ipAddress);
    }

    public void record(int userId, String userRole, String targetTable, int targetId, String action, String oldValue, String newValue, String ipAddress) {
        String sql = "INSERT INTO audit_logs (user_id, user_role, target_table, target_id, booking_id, action, old_value, new_value, old_status, new_status, ip_address) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, userRole != null ? userRole : "UNKNOWN");
            ps.setString(3, targetTable != null ? targetTable : "general");
            ps.setInt(4, targetId);
            if ("bookings".equalsIgnoreCase(targetTable) && targetId > 0) {
                ps.setInt(5, targetId);
            } else {
                ps.setNull(5, Types.INTEGER);
            }
            ps.setString(6, action);

            ps.setString(7, oldValue != null ? oldValue : "");
            ps.setString(8, newValue != null ? newValue : "");
            ps.setString(9, oldValue != null ? oldValue : "");
            ps.setString(10, newValue != null ? newValue : "");
            ps.setString(11, ipAddress != null ? ipAddress : "127.0.0.1");
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    public List<Map<String, Object>> getLogs() {
        List<Map<String, Object>> rows = new ArrayList<>();
        String sql = "SELECT a.id, a.user_id, a.user_role, a.target_table, a.target_id, a.booking_id, a.action, a.old_value, a.new_value, a.old_status, a.new_status, a.ip_address, a.created_at, u.username, u.full_name " +
                     "FROM audit_logs a LEFT JOIN users u ON u.id=a.user_id ORDER BY a.created_at DESC LIMIT 100";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getInt("id"));
                row.put("userId", rs.getInt("user_id"));
                row.put("userRole", rs.getString("user_role"));
                row.put("targetTable", rs.getString("target_table"));
                row.put("targetId", rs.getInt("target_id"));
                row.put("bookingId", rs.getInt("booking_id"));
                row.put("action", rs.getString("action"));
                
                String oldVal = rs.getString("old_value");
                if (oldVal == null || oldVal.isEmpty()) oldVal = rs.getString("old_status");
                row.put("oldStatus", oldVal);
                row.put("oldValue", oldVal);

                String newVal = rs.getString("new_value");
                if (newVal == null || newVal.isEmpty()) newVal = rs.getString("new_status");
                row.put("newStatus", newVal);
                row.put("newValue", newVal);

                row.put("ipAddress", rs.getString("ip_address"));
                row.put("createdAt", rs.getTimestamp("created_at"));
                
                String uName = rs.getString("username");
                if (uName != null && uName.startsWith("ENC:")) {
                    row.put("username", CryptoUtil.maskUsername(CryptoUtil.decrypt(uName)));
                } else {
                    row.put("username", uName);
                }
                row.put("fullName", rs.getString("full_name"));
                rows.add(row);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return rows;
    }
}