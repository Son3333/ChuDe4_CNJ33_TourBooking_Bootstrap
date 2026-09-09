package vn.edu.eaut.tour.util;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import java.nio.charset.StandardCharsets;

public final class PasswordUtil {
    private static final String PREFIX = "PBKDF2$";
    private static final int ITERATIONS = 600_000;
    private static final int KEY_LENGTH = 256;
    private static final int SALT_LENGTH = 16;

    private PasswordUtil() { }

    public static String hash(String password) {
        byte[] salt = new byte[SALT_LENGTH];
        new SecureRandom().nextBytes(salt);
        byte[] derived = derive(password, salt, ITERATIONS);
        return PREFIX + ITERATIONS + "$" + encode(salt) + "$" + encode(derived);
    }

    public static boolean matches(String password, String stored) {
        if (password == null || stored == null) return false;
        if (!isHashed(stored)) return MessageDigest.isEqual(password.getBytes(StandardCharsets.UTF_8), stored.getBytes(StandardCharsets.UTF_8));
        try {
            String[] parts = stored.split("\\$", -1);
            int iterations = Integer.parseInt(parts[1]);
            byte[] salt = Base64.getDecoder().decode(parts[2]);
            byte[] expected = Base64.getDecoder().decode(parts[3]);
            return MessageDigest.isEqual(expected, derive(password, salt, iterations));
        } catch (RuntimeException e) {
            return false;
        }
    }

    public static boolean isHashed(String value) {
        return value != null && value.startsWith(PREFIX);
    }

    public static String hashMarker() {
        return "[protected]";
    }

    private static byte[] derive(String password, byte[] salt, int iterations) {
        try {
            PBEKeySpec spec = new PBEKeySpec(password.toCharArray(), salt, iterations, KEY_LENGTH);
            return SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded();
        } catch (GeneralSecurityException e) {
            throw new IllegalStateException("Cannot hash password", e);
        }
    }

    private static String encode(byte[] value) {
        return Base64.getEncoder().withoutPadding().encodeToString(value);
    }
}