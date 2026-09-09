package vn.edu.eaut.tour.model;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("User Model Unit Tests")
class UserTest {

    @Test
    @DisplayName("Default constructor and setters/getters work as expected")
    void testDefaultConstructorAndSettersGetters() {
        User user = new User();
        user.setId(10);
        user.setUsername("testuser");
        user.setPassword("secret");
        user.setFullName("Test User");
        user.setRole("USER");

        assertEquals(10, user.getId());
        assertEquals("testuser", user.getUsername());
        assertEquals("secret", user.getPassword());
        assertEquals("Test User", user.getFullName());
        assertEquals("USER", user.getRole());
    }

    @Test
    @DisplayName("Parameterized constructor initializes all fields")
    void testParameterizedConstructor() {
        User user = new User(1, "admin", "admin123", "System Admin", "ADMIN");

        assertEquals(1, user.getId());
        assertEquals("admin", user.getUsername());
        assertEquals("admin123", user.getPassword());
        assertEquals("System Admin", user.getFullName());
        assertEquals("ADMIN", user.getRole());
    }
}
