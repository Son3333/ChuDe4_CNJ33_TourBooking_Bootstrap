package vn.edu.eaut.tour.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import vn.edu.eaut.tour.dao.UserDAO;
import vn.edu.eaut.tour.model.User;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.*;
import java.nio.charset.StandardCharsets;
import java.util.UUID;

public class OAuthController extends HttpServlet {
    private static final ObjectMapper JSON = new ObjectMapper();
    private final HttpClient http = HttpClient.newHttpClient();

    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        String path = req.getPathInfo();
        String provider = path.substring(path.lastIndexOf('/') + 1);
        if (!"google".equals(provider)) { resp.sendError(HttpServletResponse.SC_NOT_FOUND); return; }
        if (path.startsWith("/callback/")) { callback(req, resp, provider); return; }
        redirectToProvider(req, resp, provider);
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        String path = req.getPathInfo();
        if (!path.endsWith("/google")) { resp.sendError(HttpServletResponse.SC_NOT_FOUND); return; }
        callback(req, resp, path.substring(path.lastIndexOf('/') + 1));
    }

    private void redirectToProvider(HttpServletRequest req, HttpServletResponse resp, String provider) throws IOException, ServletException {
        String clientId = config(provider, "CLIENT_ID");
        if (clientId == null) { fail(req, resp, "OAuth chưa được cấu hình. Hãy đặt OAUTH_" + provider.toUpperCase() + "_CLIENT_ID."); return; }
        String state = UUID.randomUUID().toString();
        req.getSession().setAttribute("oauthState", state);
        String callback = callbackUrl(req, provider);
        String url = "https://accounts.google.com/o/oauth2/v2/auth?client_id=" + enc(clientId) + "&redirect_uri=" + enc(callback) + "&response_type=code&scope=openid%20email%20profile&state=" + enc(state);
        resp.sendRedirect(url);
    }

    private void callback(HttpServletRequest req, HttpServletResponse resp, String provider) throws IOException, ServletException {
        String expected = (String) req.getSession().getAttribute("oauthState");
        if (expected == null || !expected.equals(req.getParameter("state"))) { fail(req, resp, "OAuth state không hợp lệ."); return; }
        req.getSession().removeAttribute("oauthState");
        try {
            JsonNode identity = googleIdentity(req, provider);
            User user = new UserDAO().findOrCreateOAuthUser(provider, identity.get("sub").asText(), identity.path("email").asText(""), identity.path("name").asText(""));
            if (user == null) throw new IllegalStateException("Cannot create OAuth user");
            req.changeSessionId(); req.getSession().setAttribute("user", user);
            resp.sendRedirect(req.getContextPath() + ("ADMIN".equalsIgnoreCase(user.getRole()) ? "/admin" : "/tours"));
        } catch (Exception e) { e.printStackTrace(); fail(req, resp, "Đăng nhập OAuth thất bại."); }
    }

    private JsonNode googleIdentity(HttpServletRequest req, String provider) throws Exception {
        String token = exchangeCode(req, provider);
        HttpRequest request = HttpRequest.newBuilder(URI.create("https://openidconnect.googleapis.com/v1/userinfo")).header("Authorization", "Bearer " + token).GET().build();
        return JSON.readTree(http.send(request, HttpResponse.BodyHandlers.ofString()).body());
    }

    private String exchangeCode(HttpServletRequest req, String provider) throws Exception {
        String callback = callbackUrl(req, provider), code = req.getParameter("code");
        String body = "client_id=" + enc(config(provider, "CLIENT_ID")) + "&client_secret=" + enc(config(provider, "CLIENT_SECRET")) + "&code=" + enc(code) + "&grant_type=authorization_code&redirect_uri=" + enc(callback);
        HttpRequest request = HttpRequest.newBuilder(URI.create("https://oauth2.googleapis.com/token")).header("Content-Type", "application/x-www-form-urlencoded").POST(HttpRequest.BodyPublishers.ofString(body)).build();
        JsonNode response = JSON.readTree(http.send(request, HttpResponse.BodyHandlers.ofString()).body());
        return response.get("access_token").asText();
    }

    private String callbackUrl(HttpServletRequest req, String provider) { return req.getScheme() + "://" + req.getServerName() + ":" + req.getServerPort() + req.getContextPath() + "/oauth/callback/" + provider; }
    private String config(String provider, String suffix) { return System.getenv("OAUTH_" + provider.toUpperCase() + "_" + suffix); }
    private String enc(String value) { return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8); }
    private void fail(HttpServletRequest req, HttpServletResponse resp, String message) throws ServletException, IOException { req.setAttribute("error", message); req.getRequestDispatcher("/login.jsp").forward(req, resp); }
}