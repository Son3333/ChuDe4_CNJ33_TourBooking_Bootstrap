package vn.edu.eaut.tour.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ChatDAO {
    static {
        ensureTableExists();
    }

    private static void ensureTableExists() {
        String sql = "CREATE TABLE IF NOT EXISTS chat_messages (" +
                "id BIGINT AUTO_INCREMENT PRIMARY KEY, " +
                "customer_user_id INT NOT NULL, " +
                "sender_user_id INT NOT NULL, " +
                "sender_role VARCHAR(20) NOT NULL, " +
                "content TEXT NOT NULL, " +
                "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                "FOREIGN KEY (customer_user_id) REFERENCES users(id), " +
                "FOREIGN KEY (sender_user_id) REFERENCES users(id), " +
                "INDEX idx_chat_customer_created (customer_user_id, created_at)" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
        try (Connection conn = DBContext.getConnection(); Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(sql);
            try {
                stmt.executeUpdate("ALTER TABLE chat_messages MODIFY COLUMN content TEXT");
            } catch (Exception ignored) {}
        } catch (Exception ignored) {}
    }

    public List<Map<String, Object>> getMessages(int customerId) {
        return getMessages(customerId, null);
    }

    public List<Map<String, Object>> getMessages(int customerId, String channel) {
        List<Map<String, Object>> messages = new ArrayList<>();
        boolean hasChannel = channel != null && !channel.trim().isEmpty() && !"ALL".equalsIgnoreCase(channel.trim());
        String sql = "SELECT id, sender_user_id, sender_role, channel, content, created_at FROM chat_messages WHERE customer_user_id = ?"
                + (hasChannel ? " AND channel = ?" : "")
                + " ORDER BY created_at ASC, id ASC LIMIT 100";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, customerId);
            if (hasChannel) {
                statement.setString(2, channel.trim().toUpperCase());
            }
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    Map<String, Object> message = new HashMap<>();
                    message.put("id", result.getLong("id"));
                    message.put("senderId", result.getInt("sender_user_id"));
                    message.put("senderRole", result.getString("sender_role"));
                    message.put("channel", result.getString("channel"));
                    message.put("content", result.getString("content"));
                    message.put("createdAt", result.getTimestamp("created_at").toString());
                    messages.add(message);
                }
            }
        } catch (Exception exception) { exception.printStackTrace(); }
        return messages;
    }

    public List<Map<String, Object>> getCustomersWithMessages() {
        return getCustomersWithMessages("HUMAN");
    }

    public List<Map<String, Object>> getCustomersWithMessages(String channelFilter) {
        List<Map<String, Object>> customers = new ArrayList<>();
        boolean hasChannel = channelFilter != null && !channelFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(channelFilter.trim());
        String channelCondition = hasChannel ? " WHERE channel = '" + channelFilter.trim().toUpperCase() + "' " : " ";

        String sql = "SELECT u.id, u.full_name, u.username, " +
                "m_last.content AS last_message, " +
                "m_last.created_at AS last_message_at, " +
                "m_last.sender_role AS last_sender_role, " +
                "m_last.channel AS last_channel, " +
                "TIMESTAMPDIFF(MINUTE, m_last.created_at, NOW()) AS inactive_minutes " +
                "FROM users u " +
                "LEFT JOIN (" +
                "   SELECT customer_user_id, MAX(id) AS max_id " +
                "   FROM chat_messages " + channelCondition +
                "   GROUP BY customer_user_id " +
                ") latest ON u.id = latest.customer_user_id " +
                "LEFT JOIN chat_messages m_last ON m_last.id = latest.max_id " +
                "WHERE u.role != 'ADMIN' " +
                "ORDER BY (m_last.id IS NOT NULL) DESC, m_last.created_at DESC, u.id ASC";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql); ResultSet result = statement.executeQuery()) {
            while (result.next()) {
                Map<String, Object> customer = new HashMap<>();
                customer.put("id", result.getInt("id"));
                customer.put("fullName", result.getString("full_name"));
                customer.put("username", result.getString("username"));
                String lastMsg = result.getString("last_message");
                customer.put("lastMessage", lastMsg != null ? lastMsg : "Bắt đầu chat...");
                Timestamp ts = result.getTimestamp("last_message_at");
                customer.put("lastMessageAt", ts != null ? ts.toString() : "");
                customer.put("lastSenderRole", result.getString("last_sender_role"));
                customer.put("lastChannel", result.getString("last_channel"));
                Object inactiveObj = result.getObject("inactive_minutes");
                long inactiveMins = inactiveObj != null ? ((Number) inactiveObj).longValue() : 9999L;
                customer.put("inactiveMinutes", inactiveMins);
                customer.put("isActive", ts != null && inactiveMins < 10);
                customers.add(customer);
            }
        } catch (Exception exception) { exception.printStackTrace(); }
        return customers;
    }

    public List<String> getRecentHistoryStrings(int customerId, int limit) {
        return getRecentHistoryStrings(customerId, "AI", limit);
    }

    public List<String> getRecentHistoryStrings(int customerId, String channel, int limit) {
        List<String> list = new ArrayList<>();
        String sql = "SELECT sender_role, content FROM chat_messages WHERE customer_user_id = ? AND channel = ? ORDER BY id DESC LIMIT ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setString(2, channel != null ? channel.toUpperCase() : "AI");
            ps.setInt(3, limit <= 0 ? 6 : limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String role = rs.getString("sender_role");
                    String text = rs.getString("content");
                    list.add(0, ("USER".equalsIgnoreCase(role) ? "Khách: " : "Tư vấn viên: ") + text);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public long saveMessageAndGetId(int customerId, int senderId, String senderRole, String content) {
        return saveMessageAndGetId(customerId, senderId, senderRole, content, "AI");
    }

    public long saveMessageAndGetId(int customerId, int senderId, String senderRole, String content, String channel) {
        if ("AI".equalsIgnoreCase(senderRole) && senderId <= 0) {
            senderId = 1;
        }
        String ch = (channel != null && !channel.trim().isEmpty()) ? channel.trim().toUpperCase() : "AI";
        String sql = "INSERT INTO chat_messages (customer_user_id, sender_user_id, sender_role, channel, content) VALUES (?, ?, ?, ?, ?)";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setInt(1, customerId);
            statement.setInt(2, senderId);
            statement.setString(3, senderRole);
            statement.setString(4, ch);
            statement.setString(5, content);
            int affected = statement.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = statement.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getLong(1);
                    }
                }
            }
        } catch (Exception exception) {
            exception.printStackTrace();
        }
        return -1;
    }

    public boolean sendMessage(int customerId, int senderId, String senderRole, String content) {
        return saveMessageAndGetId(customerId, senderId, senderRole, content, "AI") > 0;
    }

    public boolean clearCustomerMessages(int customerId) {
        return clearCustomerMessages(customerId, null);
    }

    public boolean clearCustomerMessages(int customerId, String channel) {
        boolean hasChannel = channel != null && !channel.trim().isEmpty() && !"ALL".equalsIgnoreCase(channel.trim());
        String sql = "DELETE FROM chat_messages WHERE customer_user_id = ?" + (hasChannel ? " AND channel = ?" : "");
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, customerId);
            if (hasChannel) {
                statement.setString(2, channel.trim().toUpperCase());
            }
            return statement.executeUpdate() >= 0;
        } catch (Exception exception) {
            exception.printStackTrace();
            return false;
        }
    }
}
