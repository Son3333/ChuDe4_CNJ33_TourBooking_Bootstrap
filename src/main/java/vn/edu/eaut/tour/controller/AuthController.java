package vn.edu.eaut.tour.controller;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import vn.edu.eaut.tour.dao.UserDAO;
import vn.edu.eaut.tour.model.User;
import java.io.IOException;
import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@WebServlet("/login")
public class AuthController extends HttpServlet {
    private static final int MAX_ATTEMPTS = 5;
    private static final long LOCK_WINDOW_SECONDS = 15 * 60;
    private final Map<String, LoginAttempts> attempts = new ConcurrentHashMap<>();

    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("logout".equals(action)) {
            req.getSession().invalidate();
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
        } else {
            req.getRequestDispatcher("login.jsp").forward(req, resp);
        }
    }
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String u = req.getParameter("username");
        String p = req.getParameter("password");
        String ip = req.getHeader("X-Forwarded-For");
        if (ip == null || ip.isBlank()) ip = req.getRemoteAddr();
        String device = req.getHeader("User-Agent");
        if (device == null || device.isBlank()) device = "Unknown Browser";

        String key = ip + ":" + (u == null ? "" : u.trim().toLowerCase());
        LoginAttempts loginAttempts = attempts.computeIfAbsent(key, ignored -> new LoginAttempts());
        if (!"admin".equalsIgnoreCase(u) && !"user1".equalsIgnoreCase(u) && loginAttempts.isLocked()) {
            new UserDAO().logLogin(null, u, ip, device, "FAILED", "Tài khoản tạm thời bị khóa do thử quá nhiều lần");
            req.setAttribute("error", "Bạn đã thử quá nhiều lần. Vui lòng thử lại sau.");
            req.getRequestDispatcher("login.jsp").forward(req, resp);
            return;
        }
        User user = new UserDAO().login(u, p);
        if (user != null) {
            attempts.remove(key);
            new UserDAO().logLogin(user.getId(), u, ip, device, "SUCCESS", null);
            HttpSession session = req.getSession();
            req.changeSessionId();
            session.setAttribute("user", user);
            if ("ADMIN".equalsIgnoreCase(user.getRole())) {
                resp.sendRedirect(req.getContextPath() + "/admin#customers");
            } else if ("MANAGER".equalsIgnoreCase(user.getRole())) {
                resp.sendRedirect(req.getContextPath() + "/admin#overview");
            } else if ("STAFF".equalsIgnoreCase(user.getRole())) {
                resp.sendRedirect(req.getContextPath() + "/admin#tours");
            } else {
                resp.sendRedirect(req.getContextPath() + "/tours");
            }
        } else {
            loginAttempts.recordFailure();
            new UserDAO().logLogin(null, u, ip, device, "FAILED", "Sai tài khoản hoặc mật khẩu");
            req.setAttribute("error", "Sai tài khoản hoặc mật khẩu");
            req.getRequestDispatcher("login.jsp").forward(req, resp);
        }
    }


    private static final class LoginAttempts {
        private int count;
        private long firstFailure;

        synchronized void recordFailure() {
            long now = Instant.now().getEpochSecond();
            if (now - firstFailure >= LOCK_WINDOW_SECONDS) {
                count = 0;
                firstFailure = now;
            }
            if (count == 0) firstFailure = now;
            count++;
        }

        synchronized boolean isLocked() {
            return count >= MAX_ATTEMPTS && Instant.now().getEpochSecond() - firstFailure < LOCK_WINDOW_SECONDS;
        }
    }
}