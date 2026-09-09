package vn.edu.eaut.tour.model;

public class TourItinerary {
    private int id;
    private int tourId;
    private int dayNumber;
    private String title;
    private String description;
    private String meals;
    private String accommodation;
    private String transport;

    public TourItinerary() {}

    public TourItinerary(int id, int tourId, int dayNumber, String title, String description, String meals, String accommodation, String transport) {
        this.id = id;
        this.tourId = tourId;
        this.dayNumber = dayNumber;
        this.title = title;
        this.description = description;
        this.meals = meals;
        this.accommodation = accommodation;
        this.transport = transport;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getTourId() { return tourId; }
    public void setTourId(int tourId) { this.tourId = tourId; }

    public int getDayNumber() { return dayNumber; }
    public void setDayNumber(int dayNumber) { this.dayNumber = dayNumber; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getMeals() { return meals; }
    public void setMeals(String meals) { this.meals = meals; }

    public String getAccommodation() { return accommodation; }
    public void setAccommodation(String accommodation) { this.accommodation = accommodation; }
    public String getHotel() { return accommodation; }
    public void setHotel(String hotel) { this.accommodation = hotel; }

    public String getTransport() { return transport; }
    public void setTransport(String transport) { this.transport = transport; }
}

