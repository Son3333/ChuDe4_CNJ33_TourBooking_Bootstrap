package vn.edu.eaut.tour.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.eaut.tour.dao.SystemSettingDAO;
import vn.edu.eaut.tour.model.User;
import vn.edu.eaut.tour.service.GeminiService;

import java.io.IOException;
import java.util.Map;

@WebServlet("/admin/ai-config")
public class AIConfigController extends HttpServlet {
    private final SystemSettingDAO settingDAO = new SystemSettingDAO();
    private final GeminiService geminiService = new GeminiService();
    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || !"ADMIN".equalsIgnoreCase(user.getRole())) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            writeJson(response, Map.of("error", "Không có quyền truy cập."));
            return;
        }

        String action = request.getParameter("action");
        if ("test".equalsIgnoreCase(action)) {
            String apiKey = request.getParameter("apiKey");
            String model = request.getParameter("model");
            Map<String, Object> testResult = geminiService.testConnection(apiKey, model);
            writeJson(response, testResult);
            return;
        }

        writeJson(response, settingDAO.getAllSettings());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || !"ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if ("test".equalsIgnoreCase(action)) {
            String apiKey = request.getParameter("apiKey");
            String model = request.getParameter("model");
            Map<String, Object> testResult = geminiService.testConnection(apiKey, model);
            writeJson(response, testResult);
            return;
        }

        if ("save".equalsIgnoreCase(action)) {
            String apiKey = request.getParameter("apiKey");
            String model = request.getParameter("model");
            String assistantName = request.getParameter("assistantName");

            if (apiKey != null && !apiKey.trim().isEmpty()) {
                settingDAO.saveSetting("gemini_api_key", apiKey.trim());
            }
            if (model != null && !model.trim().isEmpty()) {
                settingDAO.saveSetting("gemini_model", model.trim());
            }
            if (assistantName != null && !assistantName.trim().isEmpty()) {
                settingDAO.saveSetting("ai_assistant_name", assistantName.trim());
            }

            request.getSession().setAttribute("success", "Đã cập nhật cấu hình API Key & Trợ lý AI Gemini thành công!");
            response.sendRedirect(request.getContextPath() + "/admin#ai-config");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin#ai-config");
    }

    private void writeJson(HttpServletResponse response, Object data) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        mapper.writeValue(response.getWriter(), data);
    }
}
