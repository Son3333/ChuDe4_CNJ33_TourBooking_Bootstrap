package vn.edu.eaut.tour.model;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.sql.Timestamp;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("Booking Model Unit Tests")
class BookingTest {

    @Test
    @DisplayName("Setters and getters work correctly")
    void testSettersAndGetters() {
        Booking booking = new Booking();
        Timestamp now = new Timestamp(System.currentTimeMillis());
        Tour tour = new Tour();
        tour.setId(5);
        tour.setName("Phu Quoc Island");

        booking.setId(1);
        booking.setUserId(10);
        booking.setTourId(5);
        booking.setBookingDate(now);
        booking.setStatus("CONFIRMED");
        booking.setTour(tour);

        assertEquals(1, booking.getId());
        assertEquals(10, booking.getUserId());
        assertEquals(5, booking.getTourId());
        assertEquals(now, booking.getBookingDate());
        assertEquals("CONFIRMED", booking.getStatus());
        assertNotNull(booking.getTour());
        assertEquals("Phu Quoc Island", booking.getTour().getName());
    }
}
