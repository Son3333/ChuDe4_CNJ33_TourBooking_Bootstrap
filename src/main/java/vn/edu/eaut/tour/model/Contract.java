package vn.edu.eaut.tour.model;

import java.sql.Timestamp;

public class Contract {
    private int id;
    private int bookingId;
    private String contractCode;
    private double totalAmount;
    private String status;
    private String termsContent;
    private String qrCodeData;
    private Timestamp signedAt;

    // Additional display properties
    private String customerName;
    private String customerPhone;
    private String tourName;

    public Contract() {}

    public Contract(int id, int bookingId, String contractCode, double totalAmount, String status, String termsContent, String qrCodeData, Timestamp signedAt) {
        this.id = id;
        this.bookingId = bookingId;
        this.contractCode = contractCode;
        this.totalAmount = totalAmount;
        this.status = status;
        this.termsContent = termsContent;
        this.qrCodeData = qrCodeData;
        this.signedAt = signedAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }

    public String getContractCode() { return contractCode; }
    public void setContractCode(String contractCode) { this.contractCode = contractCode; }

    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getTermsContent() { return termsContent; }
    public void setTermsContent(String termsContent) { this.termsContent = termsContent; }
    public String getTerms() { return termsContent; }
    public void setTerms(String terms) { this.termsContent = terms; }

    public String getQrCodeData() { return qrCodeData; }
    public void setQrCodeData(String qrCodeData) { this.qrCodeData = qrCodeData; }
    public String getQrCodeHash() { return qrCodeData; }
    public void setQrCodeHash(String hash) { this.qrCodeData = hash; }

    public Timestamp getSignedAt() { return signedAt; }
    public void setSignedAt(Timestamp signedAt) { this.signedAt = signedAt; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getCustomerPhone() { return customerPhone; }
    public void setCustomerPhone(String customerPhone) { this.customerPhone = customerPhone; }

    public String getTourName() { return tourName; }
    public void setTourName(String tourName) { this.tourName = tourName; }
}

