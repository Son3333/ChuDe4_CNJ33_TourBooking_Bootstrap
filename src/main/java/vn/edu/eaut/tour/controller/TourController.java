package vn.edu.eaut.tour.controller;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import vn.edu.eaut.tour.dao.TourDAO;
import java.io.IOException;
import java.util.UUID;

@WebServlet("/tours")
public class TourController extends HttpServlet {
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (req.getSession().getAttribute("csrfToken") == null) {
            req.getSession().setAttribute("csrfToken", UUID.randomUUID().toString());
        }
        String q = req.getParameter("q");
        String origin = req.getParameter("origin");
        String destination = req.getParameter("destination");
        String duration = req.getParameter("duration");
        String country = req.getParameter("country");
        String maxPriceStr = req.getParameter("maxPrice");
        Double maxPrice = null;
        if (maxPriceStr != null && !maxPriceStr.trim().isEmpty()) {
            try { maxPrice = Double.parseDouble(maxPriceStr.trim()); } catch (NumberFormatException ignored) {}
        }

        TourDAO tourDAO = new TourDAO();
        req.setAttribute("tours", tourDAO.searchUserTours(q, origin, destination, duration, maxPrice, country));
        req.setAttribute("countries", tourDAO.getDistinctCountries());
        req.setAttribute("country", country != null ? country : "");
        req.setAttribute("q", q != null ? q : "");
        req.setAttribute("origin", origin != null ? origin : "");
        req.setAttribute("destination", destination != null ? destination : "");
        req.setAttribute("duration", duration != null ? duration : "");
        req.setAttribute("maxPrice", maxPrice != null ? (long) maxPrice.doubleValue() : 100000000L);
        req.getRequestDispatcher("tours.jsp").forward(req, resp);
    }
}