package vn.edu.eaut.tour.model;

import java.sql.Date;

public class Coupon {
    private int id;
    private String code;
    private String discountType; // "PERCENT" or "FIXED"
    private double discountValue;
    private double minOrderAmount;
    private double maxDiscountAmount;
    private Date expiryDate;
    private int maxUsage;
    private int usedCount;
    private boolean active;

    private Integer applicableTourId; // null or 0 means applicable to ALL tours
    private String applicableTourName; // joined name for UI display

    public Coupon() {}

    public Coupon(int id, String code, String discountType, double discountValue, double minOrderAmount, double maxDiscountAmount, Date expiryDate, int maxUsage, int usedCount, boolean active) {
        this(id, code, discountType, discountValue, minOrderAmount, maxDiscountAmount, expiryDate, maxUsage, usedCount, active, null, null);
    }

    public Coupon(int id, String code, String discountType, double discountValue, double minOrderAmount, double maxDiscountAmount, Date expiryDate, int maxUsage, int usedCount, boolean active, Integer applicableTourId, String applicableTourName) {
        this.id = id;
        this.code = code;
        this.discountType = discountType;
        this.discountValue = discountValue;
        this.minOrderAmount = minOrderAmount;
        this.maxDiscountAmount = maxDiscountAmount;
        this.expiryDate = expiryDate;
        this.maxUsage = maxUsage;
        this.usedCount = usedCount;
        this.active = active;
        this.applicableTourId = applicableTourId;
        this.applicableTourName = applicableTourName;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getDiscountType() { return discountType; }
    public void setDiscountType(String discountType) { this.discountType = discountType; }

    public double getDiscountValue() { return discountValue; }
    public void setDiscountValue(double discountValue) { this.discountValue = discountValue; }

    public double getMinOrderAmount() { return minOrderAmount; }
    public void setMinOrderAmount(double minOrderAmount) { this.minOrderAmount = minOrderAmount; }

    public double getMaxDiscountAmount() { return maxDiscountAmount; }
    public void setMaxDiscountAmount(double maxDiscountAmount) { this.maxDiscountAmount = maxDiscountAmount; }

    public Date getExpiryDate() { return expiryDate; }
    public void setExpiryDate(Date expiryDate) { this.expiryDate = expiryDate; }

    public int getMaxUsage() { return maxUsage; }
    public void setMaxUsage(int maxUsage) { this.maxUsage = maxUsage; }

    public int getUsedCount() { return usedCount; }
    public void setUsedCount(int usedCount) { this.usedCount = usedCount; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public Integer getApplicableTourId() { return applicableTourId; }
    public void setApplicableTourId(Integer applicableTourId) { this.applicableTourId = applicableTourId; }

    public String getApplicableTourName() { return applicableTourName; }
    public void setApplicableTourName(String applicableTourName) { this.applicableTourName = applicableTourName; }

    public boolean isSpecificTour() {
        return applicableTourId != null && applicableTourId > 0;
    }

    public boolean isApplicableTo(int tourId) {
        if (!isSpecificTour()) return true; // áp dụng cho tất cả
        return tourId > 0 && applicableTourId.intValue() == tourId;
    }

    public double calculateDiscount(double orderTotal) {
        if (!active || orderTotal < minOrderAmount) return 0;
        double discount = 0;
        if ("PERCENT".equalsIgnoreCase(discountType)) {
            discount = orderTotal * (discountValue / 100.0);
            if (maxDiscountAmount > 0 && discount > maxDiscountAmount) {
                discount = maxDiscountAmount;
            }
        } else {
            discount = discountValue;
        }
        return Math.min(discount, orderTotal);
    }
}

