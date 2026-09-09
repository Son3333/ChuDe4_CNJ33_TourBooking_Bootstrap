package vn.edu.eaut.tour.util;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("PasswordUtil Unit Tests")
class PasswordUtilTest {

    @Nested
    @DisplayName("hash() tests")
    class HashTests {

        @Test
        @DisplayName("Positive: Hash should return non-null formatted string with PBKDF2 prefix")
        void hash_ValidPassword_ReturnsPbkdf2FormattedString() {
            String rawPassword = "mySecurePassword123!";
            String hashed = PasswordUtil.hash(rawPassword);

            assertNotNull(hashed);
            assertTrue(hashed.startsWith("PBKDF2$600000$"), "Hash should start with PBKDF2$600000$");
            String[] parts = hashed.split("\\$", -1);
            assertEquals(4, parts.length, "Hash structure must be PREFIX$ITERATIONS$SALT$DERIVED");
        }

        @Test
        @DisplayName("Edge Case: Hashing the same password twice yields different hashes due to random salt")
        void hash_SamePassword_ReturnsDifferentHashesDueToSalt() {
            String rawPassword = "samePassword123";
            String hash1 = PasswordUtil.hash(rawPassword);
            String hash2 = PasswordUtil.hash(rawPassword);

            assertNotEquals(hash1, hash2, "Hashes of same password must differ due to unique salts");
        }

        @Test
        @DisplayName("Edge Case: Hashing empty password string should work")
        void hash_EmptyPassword_ReturnsValidHash() {
            String hashed = PasswordUtil.hash("");
            assertNotNull(hashed);
            assertTrue(PasswordUtil.isHashed(hashed));
            assertTrue(PasswordUtil.matches("", hashed));
        }

        @ParameterizedTest
        @ValueSource(strings = {
                "mậtKhẩuTiếngViệt123@#$",
                "🔒PassworD_With_Emojis_🚀",
                "   spaces_around   ",
                "VeryLongPasswordTextWith1234567890!@#$%^&*()_+-=[]{}|;:',.<>?/`~"
        })
        @DisplayName("Positive: Hashing complex, special, or unicode passwords")
        void hash_SpecialCharactersAndUnicode_HashesSuccessfully(String rawPassword) {
            String hashed = PasswordUtil.hash(rawPassword);
            assertNotNull(hashed);
            assertTrue(PasswordUtil.matches(rawPassword, hashed));
        }

        @Test
        @DisplayName("Negative Case: Null password should throw Exception")
        void hash_NullPassword_ThrowsNullPointerException() {
            assertThrows(NullPointerException.class, () -> PasswordUtil.hash(null));
        }
    }

    @Nested
    @DisplayName("matches() tests")
    class MatchesTests {

        @Test
        @DisplayName("Positive: Password matches its own PBKDF2 hash")
        void matches_CorrectPasswordWithHashed_ReturnsTrue() {
            String rawPassword = "CorrectPassword456";
            String hashed = PasswordUtil.hash(rawPassword);

            assertTrue(PasswordUtil.matches(rawPassword, hashed));
        }

        @Test
        @DisplayName("Negative: Wrong password does not match PBKDF2 hash")
        void matches_IncorrectPasswordWithHashed_ReturnsFalse() {
            String rawPassword = "CorrectPassword456";
            String hashed = PasswordUtil.hash(rawPassword);

            assertFalse(PasswordUtil.matches("WrongPassword456", hashed));
        }

        @Test
        @DisplayName("Positive: Legacy/Plaintext password matches stored plaintext")
        void matches_PlaintextPasswordMatch_ReturnsTrue() {
            String plainPassword = "plainPassword123";
            assertTrue(PasswordUtil.matches(plainPassword, plainPassword));
        }

        @Test
        @DisplayName("Negative: Legacy/Plaintext password mismatch")
        void matches_PlaintextPasswordMismatch_ReturnsFalse() {
            assertFalse(PasswordUtil.matches("inputPassword", "differentStoredPassword"));
        }

        @Test
        @DisplayName("Negative: Null raw password returns false")
        void matches_NullPassword_ReturnsFalse() {
            String hashed = PasswordUtil.hash("password");
            assertFalse(PasswordUtil.matches(null, hashed));
            assertFalse(PasswordUtil.matches(null, "plainText"));
        }

        @Test
        @DisplayName("Negative: Null stored password returns false")
        void matches_NullStored_ReturnsFalse() {
            assertFalse(PasswordUtil.matches("password", null));
        }

        @Test
        @DisplayName("Negative: Both raw and stored passwords null returns false")
        void matches_BothNull_ReturnsFalse() {
            assertFalse(PasswordUtil.matches(null, null));
        }

        @Test
        @DisplayName("Edge Case: Malformed PBKDF2 iteration string returns false gracefully")
        void matches_MalformedPbkdf2Header_ReturnsFalse() {
            String malformedHash = "PBKDF2$not_a_number$salt$hash";
            assertFalse(PasswordUtil.matches("password", malformedHash));
        }

        @Test
        @DisplayName("Edge Case: Incomplete PBKDF2 format returns false gracefully")
        void matches_IncompletePbkdf2Header_ReturnsFalse() {
            String incompleteHash = "PBKDF2$600000$onlySalt";
            assertFalse(PasswordUtil.matches("password", incompleteHash));
        }

        @Test
        @DisplayName("Edge Case: Invalid Base64 in salt or hash returns false gracefully")
        void matches_InvalidBase64_ReturnsFalse() {
            String invalidBase64Hash = "PBKDF2$600000$***InvalidBase64Salt***$derived";
            assertFalse(PasswordUtil.matches("password", invalidBase64Hash));
        }
    }

    @Nested
    @DisplayName("isHashed() & hashMarker() tests")
    class UtilityMethodTests {

        @Test
        @DisplayName("Positive: isHashed returns true for PBKDF2 prefix")
        void isHashed_ValidPrefix_ReturnsTrue() {
            assertTrue(PasswordUtil.isHashed("PBKDF2$600000$salt$derived"));
            assertTrue(PasswordUtil.isHashed("PBKDF2$anything"));
        }

        @Test
        @DisplayName("Negative: isHashed returns false for non-PBKDF2 or null")
        void isHashed_InvalidOrNull_ReturnsFalse() {
            assertFalse(PasswordUtil.isHashed(null));
            assertFalse(PasswordUtil.isHashed(""));
            assertFalse(PasswordUtil.isHashed("plaintext_password"));
            assertFalse(PasswordUtil.isHashed("MD5$123456"));
        }

        @Test
        @DisplayName("Positive: hashMarker returns [protected]")
        void hashMarker_ReturnsProtectedConstant() {
            assertEquals("[protected]", PasswordUtil.hashMarker());
        }
    }
}
