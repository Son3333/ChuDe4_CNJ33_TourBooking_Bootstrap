package vn.edu.eaut.tour.filter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import vn.edu.eaut.tour.model.User;

import java.io.IOException;

import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("AuthFilter Unit Tests")
class AuthFilterTest {

    private AuthFilter authFilter;

    @Mock
    private HttpServletRequest request;

    @Mock
    private HttpServletResponse response;

    @Mock
    private HttpSession session;

    @Mock
    private FilterChain chain;

    @BeforeEach
    void setUp() {
        authFilter = new AuthFilter();
        when(request.getSession()).thenReturn(session);
        lenient().when(request.getContextPath()).thenReturn("/app");
    }

    @Test
    @DisplayName("Negative: Unauthenticated user is redirected to login page")
    void doFilter_NoUserInSession_RedirectsToLogin() throws IOException, ServletException {
        when(session.getAttribute("user")).thenReturn(null);

        authFilter.doFilter(request, response, chain);

        verify(response).sendRedirect("/app/login");
        verify(chain, never()).doFilter(request, response);
    }

    @Test
    @DisplayName("Edge Case: Admin user accessing user route is redirected to admin dashboard")
    void doFilter_AdminUser_RedirectsToAdmin() throws IOException, ServletException {
        User adminUser = new User(1, "admin", "pass", "Admin User", "ADMIN");
        when(session.getAttribute("user")).thenReturn(adminUser);

        authFilter.doFilter(request, response, chain);

        verify(response).sendRedirect("/app/admin");
        verify(chain, never()).doFilter(request, response);
    }

    @Test
    @DisplayName("Edge Case: Admin user with lowercase role 'admin' is redirected to admin dashboard")
    void doFilter_AdminUserLowercaseRole_RedirectsToAdmin() throws IOException, ServletException {
        User adminUser = new User(1, "admin", "pass", "Admin User", "admin");
        when(session.getAttribute("user")).thenReturn(adminUser);

        authFilter.doFilter(request, response, chain);

        verify(response).sendRedirect("/app/admin");
        verify(chain, never()).doFilter(request, response);
    }

    @Test
    @DisplayName("Positive: Normal user is allowed to proceed down the filter chain")
    void doFilter_NormalUser_AllowsChainToProceed() throws IOException, ServletException {
        User normalUser = new User(2, "john", "pass", "John Doe", "USER");
        when(session.getAttribute("user")).thenReturn(normalUser);

        authFilter.doFilter(request, response, chain);

        verify(chain).doFilter(request, response);
        verify(response, never()).sendRedirect(anyString());
    }
}
