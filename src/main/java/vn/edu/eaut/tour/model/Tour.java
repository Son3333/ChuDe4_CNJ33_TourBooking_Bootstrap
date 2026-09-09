package vn.edu.eaut.tour.model;
import java.sql.Date;
public class Tour {
    private int id; private String name, description, imageUrl, origin, destination, duration, country; private double price, originalPrice; private int availableSeats; private Date startDate;
    private java.sql.Timestamp discountEndDate;
    private String status = "APPROVED";
    private String approvalNote;
    public Tour() {}
    public Tour(int id, String name, String description, double price, int availableSeats, Date startDate) {
        this.id = id; this.name = name; this.description = description; this.price = price; this.availableSeats = availableSeats; this.startDate = startDate;
    }
    public int getId() { return id; } public void setId(int id) { this.id = id; }
    public String getName() { return name; } public void setName(String name) { this.name = name; }
    public String getDescription() { return description; } public void setDescription(String description) { this.description = description; }
    public double getPrice() { return price; } public void setPrice(double price) { this.price = price; }
    public int getAvailableSeats() { return availableSeats; } public void setAvailableSeats(int availableSeats) { this.availableSeats = availableSeats; }
    public Date getStartDate() { return startDate; } public void setStartDate(Date startDate) { this.startDate = startDate; }
    public double getOriginalPrice() { return originalPrice; } public void setOriginalPrice(double originalPrice) { this.originalPrice = originalPrice; }
    public String getImageUrl() { return imageUrl; } public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public String getOrigin() { return origin; } public void setOrigin(String origin) { this.origin = origin; }
    public String getDestination() { return destination; } public void setDestination(String destination) { this.destination = destination; }
    public String getDuration() { return duration; } public void setDuration(String duration) { this.duration = duration; }
    public String getCountry() { return country != null && !country.isBlank() ? country : "Việt Nam"; }
    public void setCountry(String country) { this.country = country; }
    public java.sql.Timestamp getDiscountEndDate() { return discountEndDate; }
    public void setDiscountEndDate(java.sql.Timestamp discountEndDate) { this.discountEndDate = discountEndDate; }
    public String getStatus() { return status != null ? status : "APPROVED"; }
    public void setStatus(String status) { this.status = status; }
    public String getApprovalNote() { return approvalNote; }
    public void setApprovalNote(String approvalNote) { this.approvalNote = approvalNote; }

    public boolean isDiscountActive() {
        if (originalPrice <= price) return false;
        if (discountEndDate == null) return true;
        return discountEndDate.after(new java.util.Date());
    }

    public double getEffectivePrice() {
        return isDiscountActive() ? price : (originalPrice > 0 ? originalPrice : price);
    }

    public int getDiscountPercent() {
        if (isDiscountActive() && originalPrice > 0) {
            return (int) Math.round((originalPrice - price) * 100.0 / originalPrice);
        }
        return 0;
    }
}