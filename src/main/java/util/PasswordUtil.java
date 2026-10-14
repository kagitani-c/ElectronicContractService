package util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class PasswordUtil {

    // 固定ソルト（安全性を高めるための文字列）
    private static final String SALT = "ElectronicContractSecureSalt2026";

    /**
     * 平文パスワードを SHA-256 でハッシュ化する
     */
    public static String hashPassword(String rawPassword) {
        if (rawPassword == null) {
            return null;
        }
        try {
            // ソルトを付与してレインボーテーブル攻撃を防御
            String saltedPassword = rawPassword + SALT;
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = md.digest(saltedPassword.getBytes(StandardCharsets.UTF_8));

            // バイト配列を16進数文字列（64文字）に変換
            StringBuilder sb = new StringBuilder();
            for (byte b : hashBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();

        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("暗号化アルゴリズムが見つかりません", e);
        }
    }
}