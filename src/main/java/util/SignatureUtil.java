package util;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.MessageDigest;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.Signature;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;

public class SignatureUtil {

    private static final String KEY_ALGORITHM = "RSA";
    private static final String SIGNATURE_ALGORITHM = "SHA256withRSA";
    private static final int KEY_SIZE = 2048;

    /**
     * 1. RSA鍵ペア（公開鍵・秘密鍵）を新しく生成する
     */
    public static KeyPair generateKeyPair() throws Exception {
        KeyPairGenerator keyGen = KeyPairGenerator.getInstance(KEY_ALGORITHM);
        keyGen.initialize(KEY_SIZE);
        return keyGen.generateKeyPair();
    }

    /**
     * 2. ファイル（PDF）の SHA-256 ハッシュ値を計算して16進数文字列で返す（改ざん比較用）
     */
    public static String calculateFileHash(File file) throws Exception {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        try (InputStream is = new FileInputStream(file)) {
            byte[] buffer = new byte[8192];
            int read;
            while ((read = is.read(buffer)) != -1) {
                md.update(buffer, 0, read);
            }
        }
        byte[] hashBytes = md.digest();
        StringBuilder sb = new StringBuilder();
        for (byte b : hashBytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }

    /**
     * 3. PDFファイルを秘密鍵で暗号化し、電子署名文字列（Base64）を発行する
     */
    public static String signPdf(File pdfFile, PrivateKey privateKey) throws Exception {
        Signature signature = Signature.getInstance(SIGNATURE_ALGORITHM);
        signature.initSign(privateKey);

        try (InputStream is = new FileInputStream(pdfFile)) {
            byte[] buffer = new byte[8192];
            int read;
            while ((read = is.read(buffer)) != -1) {
                signature.update(buffer, 0, read);
            }
        }
        byte[] signatureBytes = signature.sign();
        return Base64.getEncoder().encodeToString(signatureBytes);
    }

    /**
     * 4. 公開鍵を用いて、PDFファイルが改ざんされていないか電子署名を検証する
     */
    public static boolean verifyPdf(File pdfFile, String signatureBase64, PublicKey publicKey) {
        try {
            Signature signature = Signature.getInstance(SIGNATURE_ALGORITHM);
            signature.initVerify(publicKey);

            try (InputStream is = new FileInputStream(pdfFile)) {
                byte[] buffer = new byte[8192];
                int read;
                while ((read = is.read(buffer)) != -1) {
                    signature.update(buffer, 0, read);
                }
            }
            byte[] signatureBytes = Base64.getDecoder().decode(signatureBase64);
            return signature.verify(signatureBytes);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // --- 文字列（DB保存用）と 鍵オブジェクトの相互変換メソッド ---

    public static String keyToString(byte[] keyBytes) {
        return Base64.getEncoder().encodeToString(keyBytes);
    }

    public static PublicKey stringToPublicKey(String base64PublicKey) throws Exception {
        byte[] keyBytes = Base64.getDecoder().decode(base64PublicKey);
        X509EncodedKeySpec spec = new X509EncodedKeySpec(keyBytes);
        KeyFactory kf = KeyFactory.getInstance(KEY_ALGORITHM);
        return kf.generatePublic(spec);
    }

    public static PrivateKey stringToPrivateKey(String keyStr) throws Exception {
        if (keyStr == null || keyStr.isEmpty()) {
            throw new IllegalArgumentException("秘密鍵データが空です。");
        }

        // Base64文字以外を完全除去し、パディング長を4の倍数に補正
        String sanitized = keyStr.replaceAll("[^A-Za-z0-9+/=]", "");
        while (sanitized.length() % 4 != 0) {
            sanitized += "=";
        }

        byte[] keyBytes = Base64.getDecoder().decode(sanitized);
        PKCS8EncodedKeySpec spec = new PKCS8EncodedKeySpec(keyBytes);
        KeyFactory kf = KeyFactory.getInstance("RSA");
        return kf.generatePrivate(spec);
    }
    
    /**
     * RSA鍵ペアとユーザー名から、PAdES署名に必要なX.509自己署名証明書を生成する
     *
     * @param keyPair 署名者の公開鍵・秘密鍵ペア
     * @param commonName 署名者名（例: 田中太郎 または 会社名）
     * @return X509Certificate 証明書オブジェクト
     */
    public static java.security.cert.X509Certificate generateX509Certificate(java.security.KeyPair keyPair, String commonName) throws Exception {
        long now = System.currentTimeMillis();
        java.util.Date startDate = new java.util.Date(now - 24 * 60 * 60 * 1000L); // 昨日常有効化
        java.util.Date endDate = new java.util.Date(now + 365L * 24 * 60 * 60 * 1000L); // 1年間有効

        // 証明書に記載する署名者情報（Distinguished Name）
        org.bouncycastle.asn1.x500.X500Name dn = new org.bouncycastle.asn1.x500.X500Name(
                "CN=" + commonName + ", O=ElectronicContractService, C=JP");
        java.math.BigInteger serialNumber = java.math.BigInteger.valueOf(now);

        org.bouncycastle.asn1.x509.SubjectPublicKeyInfo subPubKeyInfo = 
                org.bouncycastle.asn1.x509.SubjectPublicKeyInfo.getInstance(keyPair.getPublic().getEncoded());

        org.bouncycastle.cert.X509v3CertificateBuilder builder = new org.bouncycastle.cert.X509v3CertificateBuilder(
                dn, serialNumber, startDate, endDate, dn, subPubKeyInfo);

        org.bouncycastle.operator.ContentSigner signer = new org.bouncycastle.operator.jcajce.JcaContentSignerBuilder("SHA256withRSA")
                .build(keyPair.getPrivate());

        return new org.bouncycastle.cert.jcajce.JcaX509CertificateConverter()
                .getCertificate(builder.build(signer));
    }
}