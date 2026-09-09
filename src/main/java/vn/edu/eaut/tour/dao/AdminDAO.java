package vn.edu.eaut.tour.dao;

import vn.edu.eaut.tour.util.CryptoUtil;
import java.sql.*;
import java.util.*;

public class AdminDAO {
    public Map<String, Object> getStats() {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT (SELECT COALESCE(SUM(t.price),0) FROM bookings b JOIN tours t ON t.id=b.tour_id WHERE b.status IN ('CONFIRMED','COMPLETED') AND MONTH(b.booking_date)=MONTH(CURRENT_DATE()) AND YEAR(b.booking_date)=YEAR(CURRENT_DATE())) revenue, (SELECT COUNT(*) FROM tours WHERE available_seats > 0) running_tours, (SELECT COUNT(*) FROM bookings WHERE status='PENDING') pending_bookings, (SELECT COUNT(*) FROM bookings WHERE status='CANCELLED') cancelled, (SELECT COUNT(*) FROM bookings) total";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) { stats.put("revenue", rs.getDouble("revenue")); stats.put("runningTours", rs.getInt("running_tours")); stats.put("pendingBookings", rs.getInt("pending_bookings")); stats.put("cancelRate", rs.getInt("total") == 0 ? 0 : Math.round(rs.getInt("cancelled") * 100f / rs.getInt("total"))); }
        } catch (Exception e) { e.printStackTrace(); }
        return stats;
    }

    public List<Map<String, Object>> getBookings() {
        List<Map<String, Object>> rows = new ArrayList<>();
        String sql = "SELECT b.id, b.booking_date, b.status, b.payment_status, b.refund_status, b.refund_transaction_id, u.full_name, u.username, t.name, t.price FROM bookings b JOIN users u ON u.id=b.user_id JOIN tours t ON t.id=b.tour_id ORDER BY b.booking_date DESC LIMIT 100";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> row=new HashMap<>();
                row.put("id",rs.getInt("id"));
                row.put("date",rs.getTimestamp("booking_date"));
                row.put("status",rs.getString("status"));
                row.put("paymentStatus",rs.getString("payment_status"));
                row.put("refundStatus",rs.getString("refund_status"));
                row.put("refundTransactionId",rs.getString("refund_transaction_id"));
                row.put("customer",rs.getString("full_name"));
                String rawU = rs.getString("username");
                row.put("username", CryptoUtil.maskUsername(CryptoUtil.decrypt(rawU)));
                row.put("tour",rs.getString("name"));
                row.put("total",rs.getDouble("price"));
                rows.add(row);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return rows;
    }

    public List<Map<String, Object>> getUsers() {
        List<Map<String, Object>> rows = new ArrayList<>();
        String sql = "SELECT u.id,u.full_name,u.username,u.role,u.blocked,COUNT(b.id) bookings,COALESCE(SUM(CASE WHEN b.status IN ('CONFIRMED','COMPLETED') THEN t.price ELSE 0 END),0) spent FROM users u LEFT JOIN bookings b ON b.user_id=u.id LEFT JOIN tours t ON t.id=b.tour_id GROUP BY u.id ORDER BY u.id DESC";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> row=new HashMap<>();
                row.put("id",rs.getInt("id"));
                row.put("name",rs.getString("full_name"));
                String rawU = rs.getString("username");
                row.put("username", CryptoUtil.maskUsername(CryptoUtil.decrypt(rawU)));
                row.put("rawUsername", rawU);
                row.put("role",rs.getString("role"));
                row.put("blocked",rs.getBoolean("blocked"));
                row.put("bookings",rs.getInt("bookings"));
                row.put("spent",rs.getDouble("spent"));
                rows.add(row);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return rows;
    }


    public boolean updateBookingStatus(int id, String status, String paymentStatus) {
        String selectSql = "SELECT tour_id, status, payment_status, refund_status FROM bookings WHERE id = ? FOR UPDATE";
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement psSel = conn.prepareStatement(selectSql)) {
                psSel.setInt(1, id);
                try (ResultSet rs = psSel.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return false;
                    }
                    int tourId = rs.getInt("tour_id");
                    String oldStatus = rs.getString("status");
                    String oldRefundStatus = rs.getString("refund_status");

                    boolean wasCancelled = "CANCELLED".equalsIgnoreCase(oldStatus);
                    boolean isCancelled = "CANCELLED".equalsIgnoreCase(status);

                    // 1. Đồng bộ số chỗ ngồi khả dụng trong bảng tours
                    if (!wasCancelled && isCancelled) {
                        // Đổi sang HỦY: Hoàn trả 1 chỗ ngồi cho tour
                        try (PreparedStatement psSeat = conn.prepareStatement("UPDATE tours SET available_seats = available_seats + 1 WHERE id = ?")) {
                            psSeat.setInt(1, tourId);
                            psSeat.executeUpdate();
                        }
                    } else if (wasCancelled && !isCancelled) {
                        // Khôi phục từ HỦY sang trạng thái hoạt động: Giảm 1 chỗ ngồi (nếu còn chỗ)
                        try (PreparedStatement psSeat = conn.prepareStatement("UPDATE tours SET available_seats = available_seats - 1 WHERE id = ? AND available_seats > 0")) {
                            psSeat.setInt(1, tourId);
                            int rows = psSeat.executeUpdate();
                            if (rows == 0) {
                                // Tour đã hết chỗ, không thể khôi phục đơn
                                conn.rollback();
                                return false;
                            }
                        }
                    }

                    // 2. Đồng bộ trạng thái hoàn tiền (refund_status)
                    String newRefundStatus = oldRefundStatus;
                    if (isCancelled) {
                        if ("PAID".equalsIgnoreCase(paymentStatus)) {
                            if (newRefundStatus == null || newRefundStatus.isBlank()) {
                                newRefundStatus = "PENDING";
                            }
                        }
                    } else {
                        // Khôi phục đơn không còn hủy thì xóa trạng thái hoàn tiền
                        newRefundStatus = null;
                    }

                    // 3. Cập nhật trạng thái đơn đặt
                    String updateSql = "UPDATE bookings SET status = ?, payment_status = ?, refund_status = ? WHERE id = ?";
                    try (PreparedStatement psUpd = conn.prepareStatement(updateSql)) {
                        psUpd.setString(1, status);
                        psUpd.setString(2, paymentStatus);
                        psUpd.setString(3, newRefundStatus);
                        psUpd.setInt(4, id);
                        boolean ok = psUpd.executeUpdate() == 1;
                        if (ok) {
                            conn.commit();
                            return true;
                        } else {
                            conn.rollback();
                            return false;
                        }
                    }
                }
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    public boolean completeRefund(int id, String transactionId) {
        try (Connection conn=DBContext.getConnection(); PreparedStatement ps=conn.prepareStatement("UPDATE bookings SET refund_status='COMPLETED', refund_transaction_id=? WHERE id=? AND status='CANCELLED'")) { ps.setString(1,transactionId);ps.setInt(2,id);return ps.executeUpdate()==1; } catch(Exception e){e.printStackTrace();return false;}
    }
    public boolean toggleUser(int id) {
        try (Connection conn=DBContext.getConnection(); PreparedStatement ps=conn.prepareStatement("UPDATE users SET blocked=NOT blocked WHERE id=? AND role <> 'ADMIN'")) {ps.setInt(1,id);return ps.executeUpdate()==1;}catch(Exception e){e.printStackTrace();return false;}
    }

    public List<Map<String, Object>> getReviews() {
        List<Map<String,Object>> rows=new ArrayList<>();
        String sql="SELECT r.id,r.rating,r.comment,r.visible,r.admin_reply,r.created_at,u.full_name,t.name FROM reviews r JOIN users u ON u.id=r.user_id JOIN tours t ON t.id=r.tour_id ORDER BY r.created_at DESC LIMIT 100";
        try(Connection c=DBContext.getConnection();PreparedStatement p=c.prepareStatement(sql);ResultSet rs=p.executeQuery()){while(rs.next()){Map<String,Object> row=new HashMap<>();row.put("id",rs.getLong("id"));row.put("rating",rs.getInt("rating"));row.put("comment",rs.getString("comment"));row.put("visible",rs.getBoolean("visible"));row.put("reply",rs.getString("admin_reply"));row.put("customer",rs.getString("full_name"));row.put("tour",rs.getString("name"));rows.add(row);}}catch(Exception e){e.printStackTrace();}return rows;
    }
    public boolean updateReview(long id, boolean visible, String reply) {
        try(Connection c=DBContext.getConnection();PreparedStatement p=c.prepareStatement("UPDATE reviews SET visible=?, admin_reply=? WHERE id=?")){p.setBoolean(1,visible);p.setString(2,reply);p.setLong(3,id);return p.executeUpdate()==1;}catch(Exception e){e.printStackTrace();return false;}
    }
}