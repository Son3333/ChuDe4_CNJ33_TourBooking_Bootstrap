package vn.edu.eaut.tour.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.eaut.tour.dao.UserDAO;

import java.io.IOException;
import java.util.regex.Pattern;

@WebServlet("/register")
public class RegisterController extends HttpServlet {
    private static final Pattern STRONG_PASSWORD = Pattern.compile("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z\\d]).{8,64}$");
    private static final Pattern USERNAME = Pattern.compile("^[A-Za-z0-9_.-]{3,50}$");

    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("register.jsp").forward(req, resp);
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = value(req.getParameter("username"));
        String fullName = value(req.getParameter("fullName"));
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        if (!USERNAME.matcher(username).matches()) {
            showError(req, resp, "Tài khoản phải dài 3-50 ký tự và chỉ gồm chữ, số, dấu chấm, gạch ngang hoặc gạch dưới.");
            return;
        }
        if (fullName.isBlank() || fullName.length() > 100) {
            showError(req, resp, "Họ tên không được để trống và tối đa 100 ký tự.");
            return;
        }
        if (password == null || !STRONG_PASSWORD.matcher(password).matches()) {
            showError(req, resp, "Mật khẩu cần 8-64 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt.");
            return;
        }
        if (!password.equals(confirmPassword)) {
            showError(req, resp, "Mật khẩu nhập lại không khớp.");
            return;
        }
        if (!new UserDAO().register(username, password, fullName)) {
            showError(req, resp, "Tên tài khoản đã tồn tại hoặc không thể tạo tài khoản.");
            return;
        }
        resp.sendRedirect(req.getContextPath() + "/login?registered=1");
    }

    private void showError(HttpServletRequest req, HttpServletResponse resp, String error) throws ServletException, IOException {
        req.setAttribute("error", error);
        req.getRequestDispatcher("register.jsp").forward(req, resp);
    }

    private String value(String value) {
        return value == null ? "" : value.trim();
    }
}