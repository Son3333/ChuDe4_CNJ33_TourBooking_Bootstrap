package vn.edu.eaut.tour.model;

import java.sql.Date;
import java.sql.Timestamp;

public class BookingPassenger {
    private int id;
    private int bookingId;
    private String fullName;
    private String gender;
    private Date birthDate;
    private String idCard;
    private String phone;
    private boolean checkedIn;
    private Timestamp checkedInAt;

    public BookingPassenger() {}

    public BookingPassenger(int id, int bookingId, String fullName, String gender, Date birthDate, String idCard, String phone, boolean checkedIn, Timestamp checkedInAt) {
        this.id = id;
        this.bookingId = bookingId;
        this.fullName = fullName;
        this.gender = gender;
        this.birthDate = birthDate;
        this.idCard = idCard;
        this.phone = phone;
        this.checkedIn = checkedIn;
        this.checkedInAt = checkedInAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public Date getBirthDate() { return birthDate; }
    public void setBirthDate(Date birthDate) { this.birthDate = birthDate; }

    public String getIdCard() { return idCard; }
    public void setIdCard(String idCard) { this.idCard = idCard; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public boolean isCheckedIn() { return checkedIn; }
    public void setCheckedIn(boolean checkedIn) { this.checkedIn = checkedIn; }

    public Timestamp getCheckedInAt() { return checkedInAt; }
    public void setCheckedInAt(Timestamp checkedInAt) { this.checkedInAt = checkedInAt; }

    // Compatibility getters
    public boolean isLead() { return id % 3 == 1; }
    public boolean isCheckinStatus() { return checkedIn; }
    public void setCheckinStatus(boolean status) { this.checkedIn = status; }
    public Timestamp getCheckinTime() { return checkedInAt; }
    public void setCheckinTime(Timestamp time) { this.checkedInAt = time; }
}

