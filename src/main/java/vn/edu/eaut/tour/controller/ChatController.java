package vn.edu.eaut.tour.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.eaut.tour.dao.ChatDAO;
import vn.edu.eaut.tour.model.User;
import vn.edu.eaut.tour.service.GeminiService;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/chat")
public class ChatController extends HttpServlet {
    private final ChatDAO chatDAO = new ChatDAO();
    private final GeminiService geminiService = new GeminiService();
    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            write(response, HttpServletResponse.SC_UNAUTHORIZED, Map.of("error", "Vui lòng đăng nhập để chat."));
            return;
        }

        String action = request.getParameter("action");
        if ("contacts".equals(action)) {
            if (!"ADMIN".equalsIgnoreCase(user.getRole())) {
                write(response, HttpServletResponse.SC_FORBIDDEN, Map.of("error", "Không có quyền."));
                return;
            }
            String channelFilter = request.getParameter("channel");
            write(response, HttpServletResponse.SC_OK, chatDAO.getCustomersWithMessages(channelFilter != null ? channelFilter : "HUMAN"));
            return;
        }

        int customerId = "ADMIN".equalsIgnoreCase(user.getRole()) ? parseId(request.getParameter("customerId")) : user.getId();
        if (customerId <= 0) {
            write(response, HttpServletResponse.SC_BAD_REQUEST, Map.of("error", "Chưa chọn khách hàng."));
            return;
        }
        String channel = request.getParameter("channel");
        write(response, HttpServletResponse.SC_OK, chatDAO.getMessages(customerId, channel));
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            write(response, HttpServletResponse.SC_UNAUTHORIZED, Map.of("error", "Vui lòng đăng nhập để chat."));
            return;
        }

        String action = request.getParameter("action");

        // 1. Chuyển đổi chế độ chat (AI hoặc HUMAN)
        if ("setMode".equals(action)) {
            String mode = request.getParameter("mode");
            if (mode == null || (!"AI".equalsIgnoreCase(mode) && !"HUMAN".equalsIgnoreCase(mode))) {
                mode = "AI";
            }
            request.getSession().setAttribute("chatMode", mode.toUpperCase());
            write(response, HttpServletResponse.SC_OK, Map.of("chatMode", mode.toUpperCase()));
            return;
        }

        // 2. Xóa lịch sử chat (cho channel hiện tại)
        if ("clearHistory".equals(action)) {
            int targetCustomerId = "ADMIN".equalsIgnoreCase(user.getRole()) ? parseId(request.getParameter("customerId")) : user.getId();
            String clearChannel = request.getParameter("channel");
            boolean cleared = chatDAO.clearCustomerMessages(targetCustomerId, clearChannel);
            write(response, HttpServletResponse.SC_OK, Map.of("cleared", cleared));
            return;
        }

        // 3. Gửi tin nhắn
        String content = request.getParameter("content");
        content = content == null ? "" : content.trim();
        if (content.isEmpty() || content.length() > 2000) {
            write(response, HttpServletResponse.SC_BAD_REQUEST, Map.of("error", "Tin nhắn phải từ 1 đến 2000 ký tự."));
            return;
        }

        int customerId = "ADMIN".equalsIgnoreCase(user.getRole()) ? parseId(request.getParameter("customerId")) : user.getId();
        if (customerId <= 0) {
            write(response, HttpServletResponse.SC_BAD_REQUEST, Map.of("error", "Chưa chọn khách hàng."));
            return;
        }

        Map<String, Object> result = new HashMap<>();

        if ("ADMIN".equalsIgnoreCase(user.getRole())) {
            // Admin nhắn tin trực tiếp cho khách trong luồng HUMAN (hoặc channel chỉ định)
            String targetChannel = request.getParameter("channel");
            if (targetChannel == null || targetChannel.isBlank()) targetChannel = "HUMAN";
            long sentId = chatDAO.saveMessageAndGetId(customerId, user.getId(), "ADMIN", content, targetChannel);
            result.put("sent", sentId > 0);
            result.put("messageId", sentId);
            result.put("senderRole", "ADMIN");
            result.put("channel", targetChannel);
            write(response, sentId > 0 ? HttpServletResponse.SC_CREATED : HttpServletResponse.SC_INTERNAL_SERVER_ERROR, result);
        } else {
            // Xác định luồng gửi tin nhắn của khách: AI hay HUMAN
            String channelParam = request.getParameter("channel");
            if (channelParam == null || channelParam.isBlank()) {
                channelParam = request.getParameter("mode");
            }
            if (channelParam == null || (!"AI".equalsIgnoreCase(channelParam) && !"HUMAN".equalsIgnoreCase(channelParam))) {
                channelParam = "AI";
            }
            String currentChannel = channelParam.toUpperCase();

            // Khách hàng gửi tin nhắn vào đúng channel đã chọn
            long userMsgId = chatDAO.saveMessageAndGetId(customerId, user.getId(), "USER", content, currentChannel);
            if (userMsgId <= 0) {
                write(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, Map.of("error", "Không thể lưu tin nhắn."));
                return;
            }

            result.put("sent", true);
            result.put("userMsgId", userMsgId);
            result.put("channel", currentChannel);

            if ("AI".equalsIgnoreCase(currentChannel)) {
                // CHỈ khi ở luồng AI thì AI mới trả lời
                List<String> history = chatDAO.getRecentHistoryStrings(customerId, "AI", 6);
                String aiReply = geminiService.askAssistant(content, history);
                if (aiReply != null && !aiReply.trim().isEmpty()) {
                    long aiMsgId = chatDAO.saveMessageAndGetId(customerId, 1, "AI", aiReply, "AI");
                    result.put("aiReply", aiReply);
                    result.put("aiMsgId", aiMsgId);
                }
            } else {
                // Ở luồng HUMAN: AI TUYỆT ĐỐI KHÔNG CAN THIỆP. Chỉ đợi nhân viên người thật trả lời.
                result.put("humanWaiting", true);
            }

            write(response, HttpServletResponse.SC_CREATED, result);
        }
    }

    private int parseId(String value) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException exception) {
            return -1;
        }
    }

    private void write(HttpServletResponse response, int status, Object body) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        mapper.writeValue(response.getWriter(), body);
    }
}
