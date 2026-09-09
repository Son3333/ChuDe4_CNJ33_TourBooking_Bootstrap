package vn.edu.eaut.tour.dao;
import vn.edu.eaut.tour.model.Booking;
import vn.edu.eaut.tour.model.Tour;
import vn.edu.eaut.tour.model.BookingPassenger;
import vn.edu.eaut.tour.model.Contract;
import vn.edu.eaut.tour.model.CancellationRequest;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.LinkedHashMap;

public class BookingDAO {
    public boolean addBooking(int userId, int tourId) {
        return addBookingWithPassengers(userId, tourId, null, null) > 0;
    }

    public int addBookingWithPassengers(int userId, int tourId, List<BookingPassenger> passengers, Contract contract) {
        int seatsToDeduct = (passengers != null && !passengers.isEmpty()) ? passengers.size() : 1;
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement seat = conn.prepareStatement("UPDATE tours SET available_seats = available_seats - ? WHERE id = ? AND available_seats >= ?")) {
                    seat.setInt(1, seatsToDeduct);
                    seat.setInt(2, tourId);
                    seat.setInt(3, seatsToDeduct);
                    if (seat.executeUpdate() != 1) {
                        conn.rollback();
                        return -1;
                    }
                }

                int bookingId = -1;
                try (PreparedStatement booking = conn.prepareStatement("INSERT INTO bookings (user_id, tour_id, status, payment_status) VALUES (?, ?, 'PENDING', 'PENDING')", Statement.RETURN_GENERATED_KEYS)) {
                    booking.setInt(1, userId);
                    booking.setInt(2, tourId);
                    booking.executeUpdate();
                    try (ResultSet rs = booking.getGeneratedKeys()) {
                        if (rs.next()) bookingId = rs.getInt(1);
                    }
                }

                if (bookingId <= 0) {
                    conn.rollback();
                    return -1;
                }

                if (passengers != null && !passengers.isEmpty()) {
                    String passSql = "INSERT INTO booking_passengers (booking_id, full_name, gender, birth_date, id_card, phone, checked_in) VALUES (?, ?, ?, ?, ?, ?, 0)";
                    try (PreparedStatement psPass = conn.prepareStatement(passSql)) {
                        for (BookingPassenger p : passengers) {
                            psPass.setInt(1, bookingId);
                            psPass.setString(2, p.getFullName());
                            psPass.setString(3, p.getGender() != null ? p.getGender() : "Nam");
                            psPass.setDate(4, p.getBirthDate());
                            psPass.setString(5, p.getIdCard());
                            psPass.setString(6, p.getPhone());
                            psPass.addBatch();
                        }
                        psPass.executeBatch();
                    }
                }

                if (contract != null) {
                    contract.setBookingId(bookingId);
                    String contractSql = "INSERT INTO contracts (booking_id, contract_code, total_amount, status, terms_content, qr_code_data) VALUES (?, ?, ?, 'ACTIVE', ?, ?)";
                    try (PreparedStatement psCont = conn.prepareStatement(contractSql)) {
                        psCont.setInt(1, bookingId);
                        psCont.setString(2, contract.getContractCode());
                        psCont.setDouble(3, contract.getTotalAmount());
                        psCont.setString(4, contract.getTermsContent());
                        psCont.setString(5, contract.getQrCodeData());
                        psCont.executeUpdate();
                    }
                }

                conn.commit();
                return bookingId;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        }
    }

    public List<BookingPassenger> getPassengersByBooking(int bookingId) {
        List<BookingPassenger> list = new ArrayList<>();
        String sql = "SELECT * FROM booking_passengers WHERE booking_id = ? ORDER BY id ASC";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new BookingPassenger(
                        rs.getInt("id"),
                        rs.getInt("booking_id"),
                        rs.getString("full_name"),
                        rs.getString("gender"),
                        rs.getDate("birth_date"),
                        rs.getString("id_card"),
                        rs.getString("phone"),
                        rs.getBoolean("checked_in"),
                        rs.getTimestamp("checked_in_at")
                    ));
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public List<Map<String, Object>> getPassengersByTour(int tourId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT bp.*, b.status as booking_status, b.id as booking_id, u.username " +
                     "FROM booking_passengers bp " +
                     "JOIN bookings b ON b.id = bp.booking_id " +
                     "JOIN users u ON u.id = b.user_id " +
                     "WHERE b.tour_id = ? AND b.status IN ('CONFIRMED', 'COMPLETED') " +
                     "ORDER BY bp.checked_in ASC, bp.id ASC";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tourId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", rs.getInt("id"));
                    map.put("bookingId", rs.getInt("booking_id"));
                    map.put("fullName", rs.getString("full_name"));
                    map.put("gender", rs.getString("gender"));
                    map.put("birthDate", rs.getDate("birth_date"));
                    map.put("idCard", rs.getString("id_card"));
                    map.put("phone", rs.getString("phone"));
                    map.put("checkedIn", rs.getBoolean("checked_in"));
                    map.put("checkedInAt", rs.getTimestamp("checked_in_at"));
                    map.put("username", rs.getString("username"));
                    list.add(map);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public boolean updatePassengerCheckIn(int passengerId, boolean checkedIn) {
        String sql = checkedIn
            ? "UPDATE booking_passengers SET checked_in = 1, checked_in_at = CURRENT_TIMESTAMP WHERE id = ?"
            : "UPDATE booking_passengers SET checked_in = 0, checked_in_at = NULL WHERE id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, passengerId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public Contract getContractByBooking(int bookingId) {
        String sql = "SELECT c.*, t.name as tour_name, u.full_name as customer_name " +
                     "FROM contracts c " +
                     "JOIN bookings b ON b.id = c.booking_id " +
                     "JOIN tours t ON t.id = b.tour_id " +
                     "JOIN users u ON u.id = b.user_id " +
                     "WHERE c.booking_id = ? LIMIT 1";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Contract c = new Contract(
                        rs.getInt("id"),
                        rs.getInt("booking_id"),
                        rs.getString("contract_code"),
                        rs.getDouble("total_amount"),
                        rs.getString("status"),
                        rs.getString("terms_content"),
                        rs.getString("qr_code_data"),
                        rs.getTimestamp("signed_at")
                    );
                    c.setTourName(rs.getString("tour_name"));
                    c.setCustomerName(rs.getString("customer_name"));
                    return c;
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public Contract getContractByCode(String code) {
        String sql = "SELECT c.*, t.name as tour_name, u.full_name as customer_name " +
                     "FROM contracts c " +
                     "JOIN bookings b ON b.id = c.booking_id " +
                     "JOIN tours t ON t.id = b.tour_id " +
                     "JOIN users u ON u.id = b.user_id " +
                     "WHERE c.contract_code = ? LIMIT 1";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Contract c = new Contract(
                        rs.getInt("id"),
                        rs.getInt("booking_id"),
                        rs.getString("contract_code"),
                        rs.getDouble("total_amount"),
                        rs.getString("status"),
                        rs.getString("terms_content"),
                        rs.getString("qr_code_data"),
                        rs.getTimestamp("signed_at")
                    );
                    c.setTourName(rs.getString("tour_name"));
                    c.setCustomerName(rs.getString("customer_name"));
                    return c;
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public boolean addCancellationRequest(CancellationRequest req) {
        String sql = "INSERT INTO cancellation_requests (booking_id, user_id, reason, refund_amount, status) VALUES (?, ?, ?, ?, 'PENDING')";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, req.getBookingId());
            ps.setInt(2, req.getUserId());
            ps.setString(3, req.getReason());
            ps.setDouble(4, req.getRefundAmount());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public List<Map<String, Object>> getCancellationRequests() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT cr.*, b.tour_id, t.name as tour_name, t.price, u.full_name as user_name, u.username " +
                     "FROM cancellation_requests cr " +
                     "JOIN bookings b ON b.id = cr.booking_id " +
                     "JOIN tours t ON t.id = b.tour_id " +
                     "JOIN users u ON u.id = cr.user_id " +
                     "ORDER BY cr.created_at DESC";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("id", rs.getInt("id"));
                map.put("bookingId", rs.getInt("booking_id"));
                map.put("userId", rs.getInt("user_id"));
                map.put("userName", rs.getString("user_name"));
                map.put("username", rs.getString("username"));
                map.put("tourName", rs.getString("tour_name"));
                map.put("price", rs.getDouble("price"));
                map.put("reason", rs.getString("reason"));
                map.put("refundAmount", rs.getDouble("refund_amount"));
                map.put("status", rs.getString("status"));
                map.put("processedBy", rs.getInt("processed_by"));
                map.put("createdAt", rs.getTimestamp("created_at"));
                map.put("processedAt", rs.getTimestamp("processed_at"));
                list.add(map);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public boolean updateCancellationRequest(int reqId, String status, int managerId) {
        String sql = "UPDATE cancellation_requests SET status = ?, processed_by = ?, processed_at = CURRENT_TIMESTAMP WHERE id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, managerId);
            ps.setInt(3, reqId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }


    public List<Booking> getBookingsByUser(int userId) {
        List<Booking> list = new ArrayList<>();
        String sql = "SELECT b.*, t.name, t.price, t.start_date FROM bookings b JOIN tours t ON b.tour_id = t.id WHERE b.user_id = ? ORDER BY b.booking_date DESC";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Booking b = new Booking();
                b.setId(rs.getInt("id")); b.setUserId(rs.getInt("user_id")); b.setTourId(rs.getInt("tour_id"));
                b.setBookingDate(rs.getTimestamp("booking_date")); b.setStatus(rs.getString("status"));
                b.setPaymentStatus(rs.getString("payment_status"));
                b.setRefundStatus(rs.getString("refund_status"));
                b.setRefundTransactionId(rs.getString("refund_transaction_id"));
                Tour t = new Tour();
                t.setName(rs.getString("name")); t.setPrice(rs.getDouble("price")); t.setStartDate(rs.getDate("start_date"));
                b.setTour(t);
                list.add(b);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public boolean cancelBooking(int bookingId, int userId) {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            int tourId;
            String paymentStatus = "PENDING";
            try (PreparedStatement find = conn.prepareStatement("SELECT tour_id, payment_status FROM bookings WHERE id = ? AND user_id = ? AND status != 'CANCELLED' FOR UPDATE")) {
                find.setInt(1, bookingId); find.setInt(2, userId);
                try (ResultSet rs = find.executeQuery()) {
                    if (!rs.next()) return false;
                    tourId = rs.getInt("tour_id");
                    paymentStatus = rs.getString("payment_status");
                }
            }
            String refundStatus = "PAID".equalsIgnoreCase(paymentStatus) ? "PENDING" : null;
            try (PreparedStatement cancel = conn.prepareStatement("UPDATE bookings SET status = 'CANCELLED', refund_status = ? WHERE id = ? AND user_id = ?");
                 PreparedStatement restore = conn.prepareStatement("UPDATE tours SET available_seats = available_seats + 1 WHERE id = ?")) {
                cancel.setString(1, refundStatus); cancel.setInt(2, bookingId); cancel.setInt(3, userId); restore.setInt(1, tourId);
                boolean changed = cancel.executeUpdate() == 1;
                if (changed) { restore.executeUpdate(); conn.commit(); } else conn.rollback();
                return changed;
            }
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public void expirePendingBookings() {
        String sql = "SELECT id, user_id FROM bookings WHERE status = 'PENDING' AND (payment_status IS NULL OR payment_status != 'PAID') AND booking_date < DATE_SUB(NOW(), INTERVAL 30 MINUTE)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int bookingId = rs.getInt("id");
                int userId = rs.getInt("user_id");
                if (cancelBooking(bookingId, userId)) new AuditDAO().record(userId, bookingId, "EXPIRE", "PENDING", "CANCELLED", "system");
            }
        } catch (Exception e) { e.printStackTrace(); }
    }

    public int getTourIdByBooking(int bookingId) {
        String sql = "SELECT tour_id FROM bookings WHERE id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("tour_id");
        } catch (Exception e) { e.printStackTrace(); }
        return -1;
    }

    public int getLatestBookingId(int userId, int tourId) {
        String sql = "SELECT id FROM bookings WHERE user_id = ? AND tour_id = ? ORDER BY id DESC LIMIT 1";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId); ps.setInt(2, tourId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? rs.getInt(1) : -1; }
        } catch (Exception e) { e.printStackTrace(); return -1; }
    }

    public Map<Integer, Double> getMonthlyRevenue() {
        Map<Integer, Double> map = new LinkedHashMap<>();
        for (int i = 1; i <= 12; i++) map.put(i, 0.0);
        String sql = "SELECT MONTH(b.booking_date) AS m, SUM(t.price) AS total FROM bookings b JOIN tours t ON b.tour_id = t.id WHERE (b.status = 'CONFIRMED' OR b.status = 'COMPLETED') AND YEAR(b.booking_date) = YEAR(CURDATE()) GROUP BY MONTH(b.booking_date)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getInt("m"), rs.getDouble("total"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return map;
    }

    public Map<String, Integer> getBookingStatusCounts() {
        Map<String, Integer> map = new HashMap<>();
        map.put("CONFIRMED", 0);
        map.put("PENDING", 0);
        map.put("CANCELLED", 0);
        String sql = "SELECT status, COUNT(*) AS count FROM bookings GROUP BY status";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getString("status"), rs.getInt("count"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return map;
    }

    public List<Map<String, Object>> getTopSellingTours() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT t.name, COUNT(b.id) AS total_booked, SUM(t.price) AS total_revenue FROM tours t LEFT JOIN bookings b ON t.id = b.tour_id AND (b.status = 'CONFIRMED' OR b.status = 'COMPLETED') GROUP BY t.id, t.name ORDER BY total_booked DESC, t.id ASC LIMIT 5";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("name", rs.getString("name"));
                item.put("totalBooked", rs.getInt("total_booked"));
                item.put("totalRevenue", rs.getDouble("total_revenue"));
                list.add(item);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public Map<String, Object> getSeasonStatistics() {
        Map<String, Object> map = new HashMap<>();
        String seasonSql = "SELECT " +
            "SUM(CASE WHEN MONTH(booking_date) IN (3,4,5) THEN t.price ELSE 0 END) as spring_rev, " +
            "SUM(CASE WHEN MONTH(booking_date) IN (6,7,8) THEN t.price ELSE 0 END) as summer_rev, " +
            "SUM(CASE WHEN MONTH(booking_date) IN (9,10,11) THEN t.price ELSE 0 END) as autumn_rev, " +
            "SUM(CASE WHEN MONTH(booking_date) IN (12,1,2) THEN t.price ELSE 0 END) as winter_rev, " +
            "COUNT(CASE WHEN t.duration LIKE '%2N%' OR t.duration LIKE '%3N%' THEN 1 END) as short_trips, " +
            "COUNT(CASE WHEN t.duration LIKE '%4N%' OR t.duration LIKE '%5N%' THEN 1 END) as mid_trips, " +
            "COUNT(CASE WHEN t.duration LIKE '%6N%' OR t.duration LIKE '%7N%' THEN 1 END) as long_trips " +
            "FROM bookings b JOIN tours t ON t.id = b.tour_id WHERE b.status IN ('CONFIRMED', 'COMPLETED')";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(seasonSql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                map.put("springRev", rs.getDouble("spring_rev"));
                map.put("summerRev", rs.getDouble("summer_rev"));
                map.put("autumnRev", rs.getDouble("autumn_rev"));
                map.put("winterRev", rs.getDouble("winter_rev"));
                map.put("shortTrips", rs.getInt("short_trips"));
                map.put("midTrips", rs.getInt("mid_trips"));
                map.put("longTrips", rs.getInt("long_trips"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return map;
    }

    public boolean confirmPayment(int bookingId) {
        String sql = "UPDATE bookings SET status = 'CONFIRMED', payment_status = 'PAID' WHERE id = ? AND status = 'PENDING'";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public String getBookingStatus(int bookingId) {
        String sql = "SELECT status FROM bookings WHERE id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString("status");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public double getBookingAmount(int bookingId) {
        String sql = "SELECT COALESCE(c.total_amount, t.price, 0) as amount FROM bookings b LEFT JOIN tours t ON t.id = b.tour_id LEFT JOIN contracts c ON c.booking_id = b.id WHERE b.id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getDouble("amount");
            }
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }
}