package vn.edu.eaut.tour.listener;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import vn.edu.eaut.tour.dao.BookingDAO;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@WebListener
public class BookingExpiryListener implements ServletContextListener {
    private ScheduledExecutorService scheduler;

    public void contextInitialized(ServletContextEvent event) {
        scheduler = Executors.newSingleThreadScheduledExecutor();
        scheduler.scheduleAtFixedRate(new BookingDAO()::expirePendingBookings, 1, 5, TimeUnit.MINUTES);
    }

    public void contextDestroyed(ServletContextEvent event) {
        if (scheduler != null) scheduler.shutdownNow();
    }
}