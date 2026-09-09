package vn.edu.eaut.tour.util;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

/**
 * Tiện ích mã hóa bảo mật toàn diện cho hệ thống:
 * 1. Mã hóa AES-256 cho Username trong CSDL (Không để lộ tài khoản ở dạng plain text).
 * 2. Giải mã phục vụ hiển thị nội bộ có thẩm quyền.
 * 3. Mặt nạ hóa (Masking) username và SĐT khi hiển thị trên giao diện công khai.
 */
public final class CryptoUtil {
    private static final String AES_KEY_STRING = "TourBooking2026@SecureKeySecret!"; // 32 bytes = 256 bits
    private static final String ENC_PREFIX = "ENC:";
    private static final byte[] FIXED_IV = new byte[]{12, 34, 56, 78, 90, 12, 34, 56, 78, 90, 12, 34, 56, 78, 90, 12};

    private CryptoUtil() {}

    /**
     * Mã hóa AES-256 chuỗi ký tự (ví dụ: username).
     * Kết quả trả về có dạng: ENC:Base64String
     */
    public static String encrypt(String plainText) {
        if (plainText == null || plainText.isEmpty()) return plainText;
        if (isEncrypted(plainText)) return plainText;
        try {
            SecretKeySpec secretKey = new SecretKeySpec(AES_KEY_STRING.getBytes(StandardCharsets.UTF_8), "AES");
            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
            cipher.init(Cipher.ENCRYPT_MODE, secretKey, new IvParameterSpec(FIXED_IV));
            byte[] encryptedBytes = cipher.doFinal(plainText.getBytes(StandardCharsets.UTF_8));
            return ENC_PREFIX + Base64.getEncoder().encodeToString(encryptedBytes);
        } catch (Exception e) {
            return plainText;
        }
    }

    /**
     * Giải mã AES-256 chuỗi ký tự đã mã hóa.
     */
    public static String decrypt(String cipherText) {
        if (cipherText == null || !isEncrypted(cipherText)) return cipherText;
        try {
            String rawBase64 = cipherText.substring(ENC_PREFIX.length());
            byte[] cipherBytes = Base64.getDecoder().decode(rawBase64);
            SecretKeySpec secretKey = new SecretKeySpec(AES_KEY_STRING.getBytes(StandardCharsets.UTF_8), "AES");
            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
            cipher.init(Cipher.DECRYPT_MODE, secretKey, new IvParameterSpec(FIXED_IV));
            byte[] decryptedBytes = cipher.doFinal(cipherBytes);
            return new String(decryptedBytes, StandardCharsets.UTF_8);
        } catch (Exception e) {
            return cipherText;
        }
    }

    public static boolean isEncrypted(String value) {
        return value != null && value.startsWith(ENC_PREFIX);
    }

    /**
     * Mặt nạ hóa Username khi hiển thị công khai (tránh lộ thông tin cá nhân)
     * Ví dụ: nguyenvana -> ngu***na, user1 -> us***1, admin -> ad***n
     */
    public static String maskUsername(String username) {
        if (username == null || username.isBlank()) return "";
        String clean = decrypt(username);
        int len = clean.length();
        if (len <= 2) return clean.charAt(0) + "***";
        if (len <= 4) return clean.charAt(0) + "***" + clean.charAt(len - 1);
        int prefixLen = Math.min(2, len / 3);
        int suffixLen = Math.min(2, len / 3);
        return clean.substring(0, prefixLen) + "***" + clean.substring(len - suffixLen);
    }

    /**
     * Mặt nạ hóa Số điện thoại (ví dụ: 0912345678 -> 091****678)
     */
    public static String maskPhone(String phone) {
        if (phone == null || phone.isBlank()) return "";
        String trimmed = phone.trim();
        if (trimmed.length() < 7) return "***";
        return trimmed.substring(0, 3) + "****" + trimmed.substring(trimmed.length() - 3);
    }
}
