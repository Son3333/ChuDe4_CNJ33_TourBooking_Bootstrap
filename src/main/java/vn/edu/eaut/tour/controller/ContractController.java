package vn.edu.eaut.tour.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.eaut.tour.dao.BookingDAO;
import vn.edu.eaut.tour.dao.TourDAO;
import vn.edu.eaut.tour.model.Contract;
import vn.edu.eaut.tour.model.Tour;
import vn.edu.eaut.tour.model.User;
import vn.edu.eaut.tour.model.BookingPassenger;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.List;

@WebServlet("/contract")
public class ContractController extends HttpServlet {
    private final BookingDAO bookingDAO = new BookingDAO();
    private final TourDAO tourDAO = new TourDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String bookingIdStr = req.getParameter("bookingId");
        String code = req.getParameter("code");

        Contract contract = null;
        if (code != null && !code.isBlank()) {
            contract = bookingDAO.getContractByCode(code.trim());
        } else if (bookingIdStr != null && !bookingIdStr.isBlank()) {
            try {
                int bookingId = Integer.parseInt(bookingIdStr);
                contract = bookingDAO.getContractByBooking(bookingId);
                if (contract == null) {
                    // Auto-generate contract if missing for existing booking
                    int tourId = bookingDAO.getTourIdByBooking(bookingId);
                    Tour tour = tourDAO.getById(tourId);
                    User user = (User) req.getSession().getAttribute("user");
                    String cCode = "HD-2026-" + String.format("%04d", bookingId);
                    double amount = tour != null ? tour.getPrice() : 5000000;
                    String terms = "Hợp đồng dịch vụ du lịch lữ hành ký giữa Công ty Du lịch TourBooking và khách hàng. Cam kết thực hiện đầy đủ lịch trình, bảo hiểm du lịch quốc tế và các dịch vụ đi kèm.";
                    String qrData = "VERIFIED-CONTRACT:" + cCode + ":TOUR-" + tourId;
                    contract = new Contract(0, bookingId, cCode, amount, "ACTIVE", terms, qrData, new Timestamp(System.currentTimeMillis()));
                    contract.setTourName(tour != null ? tour.getName() : "Tour Du Lịch");
                    contract.setCustomerName(user != null ? user.getFullName() : "Quý khách hàng");
                }
            } catch (NumberFormatException ignored) {}
        }

        if (contract == null) {
            resp.sendRedirect(req.getContextPath() + "/tours");
            return;
        }

        List<BookingPassenger> passengers = bookingDAO.getPassengersByBooking(contract.getBookingId());
        req.setAttribute("contract", contract);
        req.setAttribute("passengers", passengers);
        req.getRequestDispatcher("/contract.jsp").forward(req, resp);
    }
}

