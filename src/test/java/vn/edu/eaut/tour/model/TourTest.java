package vn.edu.eaut.tour.model;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.sql.Date;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("Tour Model Unit Tests")
class TourTest {

    @Test
    @DisplayName("Default constructor and setters/getters test")
    void testSettersAndGetters() {
        Tour tour = new Tour();
        Date startDate = Date.valueOf("2025-06-01");

        tour.setId(100);
        tour.setName("Ha Long Bay Tour");
        tour.setDescription("Cruising in Ha Long");
        tour.setPrice(150.0);
        tour.setOriginalPrice(200.0);
        tour.setAvailableSeats(20);
        tour.setStartDate(startDate);
        tour.setImageUrl("https://images.unsplash.com/halong.jpg");
        tour.setOrigin("Hanoi");
        tour.setDestination("Ha Long");
        tour.setDuration("3 Days 2 Nights");

        assertEquals(100, tour.getId());
        assertEquals("Ha Long Bay Tour", tour.getName());
        assertEquals("Cruising in Ha Long", tour.getDescription());
        assertEquals(150.0, tour.getPrice());
        assertEquals(200.0, tour.getOriginalPrice());
        assertEquals(20, tour.getAvailableSeats());
        assertEquals(startDate, tour.getStartDate());
        assertEquals("https://images.unsplash.com/halong.jpg", tour.getImageUrl());
        assertEquals("Hanoi", tour.getOrigin());
        assertEquals("Ha Long", tour.getDestination());
        assertEquals("3 Days 2 Nights", tour.getDuration());
    }

    @Test
    @DisplayName("Parameterized constructor test")
    void testParameterizedConstructor() {
        Date startDate = Date.valueOf("2025-07-15");
        Tour tour = new Tour(1, "Da Nang Beach", "Relax in Da Nang", 299.99, 15, startDate);

        assertEquals(1, tour.getId());
        assertEquals("Da Nang Beach", tour.getName());
        assertEquals("Relax in Da Nang", tour.getDescription());
        assertEquals(299.99, tour.getPrice());
        assertEquals(15, tour.getAvailableSeats());
        assertEquals(startDate, tour.getStartDate());
    }
}
