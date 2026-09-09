package vn.edu.eaut.tour.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Map;

public class SystemSettingDAO {
    static {
        ensureTableExists();
    }

    private static void ensureTableExists() {
        String createTableSql = "CREATE TABLE IF NOT EXISTS system_settings (" +
                "setting_key VARCHAR(100) PRIMARY KEY, " +
                "setting_value TEXT NOT NULL, " +
                "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
        try (Connection conn = DBContext.getConnection(); Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(createTableSql);

            // Seed default settings if not exists
            String seedSql = "INSERT IGNORE INTO system_settings (setting_key, setting_value) VALUES " +
                    "('gemini_api_key', 'YOUR_GEMINI_API_KEY_HERE'), " +
                    "('gemini_model', 'gemini-3.7-flash'), " +
                    "('ai_assistant_name', 'Nhân viên AI Hịn Hò')";
            stmt.executeUpdate(seedSql);
        } catch (Exception ignored) {}
    }

    public String getSetting(String key, String defaultValue) {
        String sql = "SELECT setting_value FROM system_settings WHERE setting_key = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, key);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String val = rs.getString("setting_value");
                    if (val != null && !val.trim().isEmpty()) {
                        return val.trim();
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return defaultValue;
    }

    public boolean saveSetting(String key, String value) {
        String sql = "INSERT INTO system_settings (setting_key, setting_value) VALUES (?, ?) " +
                "ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, key);
            ps.setString(2, value != null ? value.trim() : "");
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public Map<String, String> getAllSettings() {
        Map<String, String> map = new HashMap<>();
        String sql = "SELECT setting_key, setting_value FROM system_settings";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getString("setting_key"), rs.getString("setting_value"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }
}
