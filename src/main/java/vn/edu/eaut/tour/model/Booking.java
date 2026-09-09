package vn.edu.eaut.tour.model;
import java.sql.Timestamp;
public class Booking {
    private int id; private int userId; private int tourId; private Timestamp bookingDate; private String status;
    private String paymentStatus; private String refundStatus; private String refundTransactionId;
    private Tour tour; // For displaying tour info in booking list
    public Booking() {}
    public int getId() { return id; } public void setId(int id) { this.id = id; }
    public int getUserId() { return userId; } public void setUserId(int userId) { this.userId = userId; }
    public int getTourId() { return tourId; } public void setTourId(int tourId) { this.tourId = tourId; }
    public Timestamp getBookingDate() { return bookingDate; } public void setBookingDate(Timestamp bookingDate) { this.bookingDate = bookingDate; }
    public String getStatus() { return status; } public void setStatus(String status) { this.status = status; }
    public String getPaymentStatus() { return paymentStatus; } public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
    public String getRefundStatus() { return refundStatus; } public void setRefundStatus(String refundStatus) { this.refundStatus = refundStatus; }
    public String getRefundTransactionId() { return refundTransactionId; } public void setRefundTransactionId(String refundTransactionId) { this.refundTransactionId = refundTransactionId; }
    public Tour getTour() { return tour; } public void setTour(Tour tour) { this.tour = tour; }
}