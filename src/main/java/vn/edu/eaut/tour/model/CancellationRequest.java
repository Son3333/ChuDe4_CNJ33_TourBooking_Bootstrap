package vn.edu.eaut.tour.model;

import java.sql.Timestamp;

public class CancellationRequest {
    private int id;
    private int bookingId;
    private int userId;
    private String reason;
    private double refundAmount;
    private String status;
    private Integer processedBy;
    private Timestamp processedAt;
    private Timestamp createdAt;

    // Display fields
    private String userName;
    private String tourName;

    public CancellationRequest() {}

    public CancellationRequest(int id, int bookingId, int userId, String reason, double refundAmount, String status, Integer processedBy, Timestamp processedAt, Timestamp createdAt) {
        this.id = id;
        this.bookingId = bookingId;
        this.userId = userId;
        this.reason = reason;
        this.refundAmount = refundAmount;
        this.status = status;
        this.processedBy = processedBy;
        this.processedAt = processedAt;
        this.createdAt = createdAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public double getRefundAmount() { return refundAmount; }
    public void setRefundAmount(double refundAmount) { this.refundAmount = refundAmount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Integer getProcessedBy() { return processedBy; }
    public void setProcessedBy(Integer processedBy) { this.processedBy = processedBy; }

    public Timestamp getProcessedAt() { return processedAt; }
    public void setProcessedAt(Timestamp processedAt) { this.processedAt = processedAt; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getTourName() { return tourName; }
    public void setTourName(String tourName) { this.tourName = tourName; }
}

