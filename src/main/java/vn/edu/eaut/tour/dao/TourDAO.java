package vn.edu.eaut.tour.dao;
import vn.edu.eaut.tour.model.Tour;
import vn.edu.eaut.tour.model.TourItinerary;
import vn.edu.eaut.tour.model.TourIncident;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
public class TourDAO {
    private static volatile List<Tour> cachedDefaultTours = null;
    private static volatile List<String> cachedCountries = null;
    private static volatile long lastCacheTime = 0;
    private static final long CACHE_TTL_MS = 180_000; // 3 minutes cache

    public static void invalidateCache() {
        cachedDefaultTours = null;
        cachedCountries = null;
        lastCacheTime = 0;
    }

    public List<Tour> getAllTours() {
        if (cachedDefaultTours != null && (System.currentTimeMillis() - lastCacheTime) < CACHE_TTL_MS) {
            return new ArrayList<>(cachedDefaultTours);
        }
        List<Tour> list = new ArrayList<>();
        String sql = "SELECT * FROM tours WHERE status = 'APPROVED'";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(toTour(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public List<Tour> searchUserTours(String keyword, String origin, String destination, String duration, Double maxPrice) {
        return searchUserTours(keyword, origin, destination, duration, maxPrice, null);
    }

    public List<Tour> searchUserTours(String keyword, String origin, String destination, String duration, Double maxPrice, String country) {
        boolean isDefault = (keyword == null || keyword.isBlank())
                && (origin == null || origin.isBlank())
                && (destination == null || destination.isBlank())
                && (duration == null || duration.isBlank())
                && (country == null || country.isBlank() || "all".equalsIgnoreCase(country.trim()))
                && (maxPrice == null || maxPrice >= 100_000_000L);

        if (isDefault && cachedDefaultTours != null && (System.currentTimeMillis() - lastCacheTime) < CACHE_TTL_MS) {
            return new ArrayList<>(cachedDefaultTours);
        }

        List<Tour> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM tours WHERE status = 'APPROVED'");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (name LIKE ? OR description LIKE ? OR destination LIKE ? OR origin LIKE ? OR country LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw); params.add(kw); params.add(kw); params.add(kw);
        }
        if (country != null && !country.trim().isEmpty() && !"all".equalsIgnoreCase(country.trim())) {
            sql.append(" AND country = ?");
            params.add(country.trim());
        }
        if (origin != null && !origin.trim().isEmpty()) {
            sql.append(" AND origin LIKE ?");
            params.add("%" + origin.trim() + "%");
        }
        if (destination != null && !destination.trim().isEmpty()) {
            sql.append(" AND destination LIKE ?");
            params.add("%" + destination.trim() + "%");
        }
        if (duration != null && !duration.trim().isEmpty()) {
            sql.append(" AND duration LIKE ?");
            params.add("%" + duration.trim() + "%");
        }
        if (maxPrice != null && maxPrice > 0) {
            sql.append(" AND (CASE WHEN original_price > price AND (discount_end_date IS NULL OR discount_end_date > NOW()) THEN price ELSE (CASE WHEN original_price > 0 THEN original_price ELSE price END) END) <= ?");
            params.add(maxPrice);
        }
        sql.append(" ORDER BY start_date ASC, id DESC");

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(toTour(rs));
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        if (isDefault && !list.isEmpty()) {
            cachedDefaultTours = new ArrayList<>(list);
            lastCacheTime = System.currentTimeMillis();
        }
        return list;
    }

    public boolean addReview(int userId, int tourId, int rating, String comment) {
        String sql = "INSERT INTO reviews (user_id, tour_id, rating, comment, visible) VALUES (?, ?, ?, ?, true)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, tourId);
            ps.setInt(3, rating);
            ps.setString(4, comment);
            return ps.executeUpdate() == 1;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public List<Tour> searchTours(String keyword, String availability, int page, int pageSize) {
        List<Tour> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM tours WHERE name LIKE ?");
        if ("available".equals(availability)) sql.append(" AND available_seats > 0");
        if ("soldout".equals(availability)) sql.append(" AND available_seats = 0");
        sql.append(" ORDER BY start_date ASC, id DESC LIMIT ? OFFSET ?");
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setString(1, "%" + (keyword == null ? "" : keyword.trim()) + "%");
            ps.setInt(2, pageSize); ps.setInt(3, Math.max(0, page - 1) * pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(toTour(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public int countTours(String keyword, String availability) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM tours WHERE name LIKE ?");
        if ("available".equals(availability)) sql.append(" AND available_seats > 0");
        if ("soldout".equals(availability)) sql.append(" AND available_seats = 0");
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setString(1, "%" + (keyword == null ? "" : keyword.trim()) + "%");
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? rs.getInt(1) : 0; }
        } catch (Exception e) { e.printStackTrace(); return 0; }
    }

    public Tour getById(int id) {
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement("SELECT * FROM tours WHERE id = ?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? toTour(rs) : null; }
        } catch (Exception e) { e.printStackTrace(); return null; }
    }

    public boolean save(Tour tour) {
        String sql = tour.getId() == 0
            ? "INSERT INTO tours (name, description, price, original_price, available_seats, start_date, image_url, origin, destination, duration, discount_end_date, country, status, approval_note) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
            : "UPDATE tours SET name = ?, description = ?, price = ?, original_price = ?, available_seats = ?, start_date = ?, image_url = ?, origin = ?, destination = ?, duration = ?, discount_end_date = ?, country = ?, status = ?, approval_note = ? WHERE id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tour.getName()); ps.setString(2, tour.getDescription()); ps.setDouble(3, tour.getPrice()); ps.setDouble(4, tour.getOriginalPrice());
            ps.setInt(5, tour.getAvailableSeats()); ps.setDate(6, tour.getStartDate()); ps.setString(7, tour.getImageUrl()); ps.setString(8, tour.getOrigin()); ps.setString(9, tour.getDestination()); ps.setString(10, tour.getDuration());
            ps.setTimestamp(11, tour.getDiscountEndDate());
            ps.setString(12, tour.getCountry());
            ps.setString(13, tour.getStatus() != null ? tour.getStatus() : "PENDING");
            ps.setString(14, tour.getApprovalNote());
            if (tour.getId() != 0) ps.setInt(15, tour.getId());
            return ps.executeUpdate() == 1;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean updateStatus(int tourId, String status, String note) {
        String sql = "UPDATE tours SET status = ?, approval_note = ? WHERE id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, note);
            ps.setInt(3, tourId);
            boolean ok = ps.executeUpdate() > 0;
            if (ok) invalidateCache();
            return ok;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public List<String> getDistinctCountries() {
        if (cachedCountries != null) return new ArrayList<>(cachedCountries);
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT country FROM tours WHERE country IS NOT NULL AND country <> '' ORDER BY CASE WHEN country = 'Việt Nam' THEN 0 ELSE 1 END, country ASC";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(rs.getString(1));
        } catch (Exception e) { e.printStackTrace(); }
        if (!list.isEmpty()) cachedCountries = new ArrayList<>(list);
        return list;
    }

    public boolean delete(int id) {
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement("DELETE FROM tours WHERE id = ? AND NOT EXISTS (SELECT 1 FROM bookings WHERE tour_id = ?)")) {
            ps.setInt(1, id); ps.setInt(2, id);
            boolean ok = ps.executeUpdate() == 1;
            if (ok) invalidateCache();
            return ok;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    private Tour toTour(ResultSet rs) throws SQLException {
        Tour tour = new Tour(rs.getInt("id"), rs.getString("name"), rs.getString("description"), rs.getDouble("price"), rs.getInt("available_seats"), rs.getDate("start_date"));
        tour.setOriginalPrice(rs.getDouble("original_price")); tour.setImageUrl(rs.getString("image_url")); tour.setOrigin(rs.getString("origin")); tour.setDestination(rs.getString("destination")); tour.setDuration(rs.getString("duration"));
        try {
            tour.setDiscountEndDate(rs.getTimestamp("discount_end_date"));
        } catch (SQLException ignored) {}
        try {
            String c = rs.getString("country");
            tour.setCountry(c != null && !c.isBlank() ? c : "Việt Nam");
        } catch (SQLException ignored) {}
        try {
            String st = rs.getString("status");
            if (st != null && !st.isBlank()) tour.setStatus(st);
            tour.setApprovalNote(rs.getString("approval_note"));
        } catch (SQLException ignored) {}
        return tour;
    }

    public boolean reduceSeat(int tourId) {
        String sql = "UPDATE tours SET available_seats = available_seats - 1 WHERE id = ? AND available_seats > 0";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tourId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean restoreSeat(int tourId) {
        String sql = "UPDATE tours SET available_seats = available_seats + 1 WHERE id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tourId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    // Itineraries
    public List<TourItinerary> getItineraries(int tourId) {
        List<TourItinerary> list = new ArrayList<>();
        String sql = "SELECT * FROM tour_itineraries WHERE tour_id = ? ORDER BY day_number ASC";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tourId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new TourItinerary(
                        rs.getInt("id"),
                        rs.getInt("tour_id"),
                        rs.getInt("day_number"),
                        rs.getString("title"),
                        rs.getString("description"),
                        rs.getString("meals"),
                        rs.getString("accommodation"),
                        rs.getString("transport")
                    ));
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public boolean addItinerary(TourItinerary item) {
        String sql = "INSERT INTO tour_itineraries (tour_id, day_number, title, description, meals, accommodation, transport) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, item.getTourId());
            ps.setInt(2, item.getDayNumber());
            ps.setString(3, item.getTitle());
            ps.setString(4, item.getDescription());
            ps.setString(5, item.getMeals());
            ps.setString(6, item.getAccommodation());
            ps.setString(7, item.getTransport());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    // Incidents
    public List<TourIncident> getIncidents(Integer tourId) {
        List<TourIncident> list = new ArrayList<>();
        String sql = (tourId == null || tourId == 0)
            ? "SELECT ti.*, u.full_name as reporter_name FROM tour_incidents ti LEFT JOIN users u ON u.id = ti.reported_by ORDER BY ti.reported_at DESC"
            : "SELECT ti.*, u.full_name as reporter_name FROM tour_incidents ti LEFT JOIN users u ON u.id = ti.reported_by WHERE ti.tour_id = ? ORDER BY ti.reported_at DESC";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            if (tourId != null && tourId != 0) ps.setInt(1, tourId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new TourIncident(
                        rs.getInt("id"),
                        rs.getInt("tour_id"),
                        rs.getInt("reported_by"),
                        rs.getString("reporter_name"),
                        rs.getString("incident_type"),
                        rs.getString("description"),
                        rs.getString("severity"),
                        rs.getString("status"),
                        rs.getString("resolution"),
                        rs.getTimestamp("reported_at"),
                        rs.getTimestamp("resolved_at")
                    ));
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public boolean addIncident(TourIncident inc) {
        String sql = "INSERT INTO tour_incidents (tour_id, reported_by, incident_type, description, severity, status) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, inc.getTourId());
            ps.setInt(2, inc.getReportedBy() > 0 ? inc.getReportedBy() : 1);
            ps.setString(3, inc.getIncidentType() != null ? inc.getIncidentType() : "Khác");
            ps.setString(4, inc.getDescription());
            ps.setString(5, inc.getSeverity() != null ? inc.getSeverity() : "MEDIUM");
            ps.setString(6, inc.getStatus() != null ? inc.getStatus() : "OPEN");
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean resolveIncident(int incidentId, String resolution) {
        String sql = "UPDATE tour_incidents SET status = 'RESOLVED', resolution = ?, resolved_at = CURRENT_TIMESTAMP WHERE id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, resolution);
            ps.setInt(2, incidentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public List<Tour> getAllToursAdmin() {
        List<Tour> list = new ArrayList<>();
        String sql = "SELECT id, name, start_date, duration, available_seats, price, status FROM tours ORDER BY start_date ASC, id DESC";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Tour t = new Tour();
                t.setId(rs.getInt("id"));
                t.setName(rs.getString("name"));
                t.setStartDate(rs.getDate("start_date"));
                t.setDuration(rs.getString("duration"));
                t.setAvailableSeats(rs.getInt("available_seats"));
                t.setPrice(rs.getDouble("price"));
                t.setStatus(rs.getString("status"));
                list.add(t);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}