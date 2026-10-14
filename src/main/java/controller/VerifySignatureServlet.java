package controller;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.security.MessageDigest;
import java.security.PublicKey;
import java.util.Arrays;
import java.util.Base64;

import javax.crypto.Cipher;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import model.dao.ContractDocumentDAO;
import model.dao.UserDAO;
import model.entity.ContractDocument;
import util.SignatureUtil;

@WebServlet("/VerifySignatureServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 10485760L, maxRequestSize = 20971520L)
public class VerifySignatureServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processVerification(request, response, null, null);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        Part filePart = request.getPart("uploadPdfFile");

        String uploadedFileHash = null;
        String uploadedFileName = null;

        if (filePart != null && filePart.getSize() > 0) {
            uploadedFileName = filePart.getSubmittedFileName();
            try {
                MessageDigest digest = MessageDigest.getInstance("SHA-256");
                try (InputStream is = filePart.getInputStream()) {
                    byte[] buffer = new byte[8192];
                    int bytesRead;
                    while ((bytesRead = is.read(buffer)) != -1) {
                        digest.update(buffer, 0, bytesRead);
                    }
                }
                byte[] hashBytes = digest.digest();
                StringBuilder sb = new StringBuilder();
                for (byte b : hashBytes) {
                    sb.append(String.format("%02x", b));
                }
                uploadedFileHash = sb.toString();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        processVerification(request, response, uploadedFileHash, uploadedFileName);
    }

    private void processVerification(HttpServletRequest request, HttpServletResponse response,
                                    String uploadedFileHash, String uploadedFileName)
            throws ServletException, IOException {

        String docIdParam = request.getParameter("docId");
        if (docIdParam == null || docIdParam.isEmpty()) {
            response.sendRedirect("FolderListServlet");
            return;
        }

        int docId = Integer.parseInt(docIdParam);
        ContractDocumentDAO docDao = new ContractDocumentDAO();
        ContractDocument doc = docDao.getDocumentById(docId);

        if (doc == null || doc.getSignatureData() == null) {
            response.sendRedirect("FolderListServlet");
            return;
        }

        try {
            File pdfFile = new File(doc.getFilePath());
            String currentFileHash = pdfFile.exists() ? SignatureUtil.calculateFileHash(pdfFile) : "ファイルが存在しません";

            UserDAO userDao = new UserDAO();
            int signerId = doc.getSignedBy() != null ? doc.getSignedBy() : 0;
            String certPath = userDao.findCertificatePathByUserId(signerId);

            PublicKey publicKey = null;
            String publicKeyBase64 = null;
            if (certPath != null && new File(certPath).exists()) {
                String certText = Files.readString(new File(certPath).toPath(), StandardCharsets.UTF_8);
                publicKeyBase64 = extractPublicKey(certText);
                if (publicKeyBase64 != null) {
                    publicKey = SignatureUtil.stringToPublicKey(publicKeyBase64);
                }
            }

            boolean isVerified = false;
            String decryptedHash = null;

            if (publicKey != null && pdfFile.exists()) {
                isVerified = SignatureUtil.verifyPdf(pdfFile, doc.getSignatureData(), publicKey);

                try {
                    Cipher cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding");
                    cipher.init(Cipher.DECRYPT_MODE, publicKey);
                    byte[] decryptedBytes = cipher.doFinal(Base64.getDecoder().decode(doc.getSignatureData()));
                    if (decryptedBytes.length >= 32) {
                        byte[] hashBytes = Arrays.copyOfRange(decryptedBytes, decryptedBytes.length - 32, decryptedBytes.length);
                        StringBuilder sb = new StringBuilder();
                        for (byte b : hashBytes) {
                            sb.append(String.format("%02x", b));
                        }
                        decryptedHash = sb.toString();
                    }
                } catch (Exception e) {
                    if (isVerified) {
                        decryptedHash = doc.getFileHash();
                    }
                }
            }

            request.setAttribute("doc", doc);
            request.setAttribute("currentFileHash", currentFileHash);
            request.setAttribute("publicKeyBase64", publicKeyBase64);
            request.setAttribute("decryptedHash", decryptedHash);
            request.setAttribute("isVerified", isVerified);

            // 画面からアップロードされたファイル情報
            request.setAttribute("uploadedFileHash", uploadedFileHash);
            request.setAttribute("uploadedFileName", uploadedFileName);
            if (uploadedFileHash != null && decryptedHash != null) {
                request.setAttribute("uploadedIsVerified", uploadedFileHash.equalsIgnoreCase(decryptedHash));
            }

            request.getRequestDispatcher("/WEB-INF/jsp/verifySignature.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("FolderListServlet");
        }
    }

    private String extractPublicKey(String certText) {
        String marker = "[PUBLIC KEY]";
        int startIndex = certText.indexOf(marker);
        if (startIndex == -1) return null;
        startIndex += marker.length();
        int endIndex = certText.indexOf("[PRIVATE KEY]", startIndex);
        if (endIndex == -1) endIndex = certText.length();
        return certText.substring(startIndex, endIndex).replaceAll("\\s+", "");
    }
}