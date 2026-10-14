package controller;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.cert.X509Certificate;
import java.security.interfaces.RSAPrivateCrtKey;
import java.security.spec.RSAPublicKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.dao.ContractDocumentDAO;
import model.dao.FolderDAO;
import model.entity.ContractDocument;
import model.entity.Folder;
import model.entity.User;
import util.PadesSignatureUtil;
import util.SignatureUtil;

@WebServlet("/SignPdfServlet")
public class SignPdfServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.sendRedirect("Login");
            return;
        }

        int docId = Integer.parseInt(request.getParameter("docId"));
        int folderId = Integer.parseInt(request.getParameter("folderId"));

        FolderDAO folderDao = new FolderDAO();
        Folder folder = folderDao.getFolderById(folderId);

        ContractDocumentDAO docDao = new ContractDocumentDAO();
        ContractDocument doc = docDao.getDocumentById(docId);

        if (folder == null || doc == null) {
            response.sendRedirect("FolderListServlet");
            return;
        }

        if (loginUser.getCertificatePath() == null) {
            response.sendRedirect("FolderDetailServlet?id=" + folderId + "&error=no_cert");
            return;
        }

        File certFile = new File(loginUser.getCertificatePath());
        File pdfFile = new File(doc.getFilePath());

        if (!certFile.exists()) {
            response.sendRedirect("FolderDetailServlet?id=" + folderId + "&error=cert_not_found");
            return;
        }
        if (!pdfFile.exists()) {
            response.sendRedirect("FolderDetailServlet?id=" + folderId + "&error=file_not_found");
            return;
        }

        try {
            // 1. 証明書テキストファイルから秘密鍵を復元
            String certText = Files.readString(certFile.toPath(), StandardCharsets.UTF_8);
            String privateKeyBase64 = extractPrivateKey(certText);
            PrivateKey privateKey = SignatureUtil.stringToPrivateKey(privateKeyBase64);

            // 2. 公開鍵を取得してKeyPairを復元
            PublicKey publicKey = extractPublicKeyFromTextOrKey(certText, privateKey);
            KeyPair keyPair = new KeyPair(publicKey, privateKey);

            // 3. 署名者の身元を証明するX.509証明書オブジェクトを発行
            String signerName = (loginUser.getUserName() != null && !loginUser.getUserName().isEmpty())
                    ? loginUser.getUserName() : "User_" + loginUser.getUserId();
            X509Certificate x509Cert = SignatureUtil.generateX509Certificate(keyPair, signerName);

            boolean isCreator = (loginUser.getUserId() == folder.getCreatedBy());
            String reason = isCreator ? "契約書送信者の承認署名" : "契約締結の合意署名";

            // 4. PAdES規格の電子署名をPDFバイナリに書き込む（一時ファイル経由で安全に上書き）
            File tempSignedFile = new File(pdfFile.getParentFile(), "temp_signed_" + System.currentTimeMillis() + ".pdf");
            PadesSignatureUtil.signPdfPades(pdfFile, tempSignedFile, privateKey, x509Cert, reason, "Tokyo, Japan");

            // 署名済み一時ファイルを正式な原本ファイルに置き換え
            Files.move(tempSignedFile.toPath(), pdfFile.toPath(), StandardCopyOption.REPLACE_EXISTING);

            // 5. 【修正箇所】署名完了後の最新PDFから、ハッシュ値とRSA暗号署名データを生成
            String latestFileHash = SignatureUtil.calculateFileHash(pdfFile);
            String signatureData = SignatureUtil.signPdf(pdfFile, privateKey);

            if (isCreator) {
                // 送信者の署名
                docDao.saveSignature(docId, signatureData, latestFileHash, loginUser.getUserId());
                folderDao.updateFolderStatus(folderId, "WAITING_SIGN");
            } else {
                // 招待ユーザーの署名（最新ハッシュと招待者署名を保存）
                docDao.saveInvitedSignature(docId, signatureData, loginUser.getUserId());
                // ※原本ファイルハッシュも最終署名後の最新ハッシュへ更新
                docDao.updateFileHash(docId, latestFileHash);
                folderDao.updateFolderStatus(folderId, "COMPLETED");
            }

            response.sendRedirect("FolderDetailServlet?id=" + folderId + "&signed=true");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("FolderDetailServlet?id=" + folderId + "&error=sign_failed");
        }
    }

    private PublicKey extractPublicKeyFromTextOrKey(String certText, PrivateKey privateKey) throws Exception {
        String marker = "[PUBLIC KEY]";
        int startIndex = certText.indexOf(marker);
        if (startIndex != -1) {
            int endIndex = certText.indexOf("[PRIVATE KEY]");
            String keyPart = (endIndex != -1) ? certText.substring(startIndex + marker.length(), endIndex)
                                              : certText.substring(startIndex + marker.length());

            String cleanKey = keyPart.replaceAll("-----BEGIN[^-]+-----", "")
                                     .replaceAll("-----END[^-]+-----", "")
                                     .replaceAll("[^A-Za-z0-9+/=]", "");
            while (cleanKey.length() % 4 != 0) {
                cleanKey += "=";
            }

            byte[] keyBytes = Base64.getDecoder().decode(cleanKey);
            X509EncodedKeySpec spec = new X509EncodedKeySpec(keyBytes);
            KeyFactory kf = KeyFactory.getInstance("RSA");
            return kf.generatePublic(spec);
        }

        if (privateKey instanceof RSAPrivateCrtKey crtKey) {
            RSAPublicKeySpec spec = new RSAPublicKeySpec(crtKey.getModulus(), crtKey.getPublicExponent());
            KeyFactory kf = KeyFactory.getInstance("RSA");
            return kf.generatePublic(spec);
        }

        throw new IllegalStateException("公開鍵を抽出できませんでした。");
    }

    private String extractPrivateKey(String certText) {
        String marker = "[PRIVATE KEY]";
        int startIndex = certText.indexOf(marker);
        if (startIndex == -1) {
            return null;
        }

        String keyPart = certText.substring(startIndex + marker.length()).trim();
        int delimiterIndex = keyPart.indexOf("===");
        if (delimiterIndex != -1) {
            keyPart = keyPart.substring(0, delimiterIndex).trim();
        }

        String cleanKey = keyPart.replaceAll("-----BEGIN[^-]+-----", "")
                                 .replaceAll("-----END[^-]+-----", "")
                                 .replaceAll("[^A-Za-z0-9+/=]", "");

        while (cleanKey.length() % 4 != 0) {
            cleanKey += "=";
        }

        return cleanKey;
    }
}