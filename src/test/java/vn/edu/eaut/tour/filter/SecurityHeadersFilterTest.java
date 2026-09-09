package vn.edu.eaut.tour.filter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.io.IOException;

import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("SecurityHeadersFilter Unit Tests")
class SecurityHeadersFilterTest {

    private SecurityHeadersFilter filter;

    @Mock
    private HttpServletRequest request;

    @Mock
    private HttpServletResponse response;

    @Mock
    private FilterChain chain;

    @BeforeEach
    void setUp() {
        filter = new SecurityHeadersFilter();
    }

    @Test
    @DisplayName("doFilter adds required security headers and continues chain")
    void doFilter_SetsSecurityHeadersAndProceeds() throws IOException, ServletException {
        filter.doFilter(request, response, chain);

        verify(response).setHeader("X-Content-Type-Options", "nosniff");
        verify(response).setHeader("X-Frame-Options", "DENY");
        verify(response).setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
        verify(response).setHeader(eq("Content-Security-Policy"), contains("default-src 'self'"));
        verify(chain).doFilter(request, response);
    }
}
