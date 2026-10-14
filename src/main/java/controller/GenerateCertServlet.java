package controller;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.security.KeyPair;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.dao.FolderDAO;
import model.dao.UserDAO;
import model.entity.User;
import util.SignatureUtil;

@WebServlet("/GenerateCertServlet")
public class GenerateCertServlet extends HttpServlet {

    private static final String CERT_DIR = "./data/certificates";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        // ガード処理：招待ユーザーかつ発行不許可の場合は遮断
        if (loginUser.isGuest()) {
            FolderDAO folderDao = new FolderDAO();
            boolean isAllowed = folderDao.isCertIssuanceAllowedByInvitedUserId(loginUser.getUserId());
            if (!isAllowed) {
                response.sendRedirect(request.getContextPath() + "/DashboardServlet?cert_error=not_allowed");
                return;
            }
        }

        try {
            KeyPair keyPair = SignatureUtil.generateKeyPair();
            String publicKeyBase64 = SignatureUtil.keyToString(keyPair.getPublic().getEncoded());
            String privateKeyBase64 = SignatureUtil.keyToString(keyPair.getPrivate().getEncoded());

            StringBuilder sb = new StringBuilder();
            sb.append("=====================================================\n");
            sb.append("  ELECTRONIC CERTIFICATE (PORTFOLIO DUMMY EDITION)\n");
            sb.append("  Owner: ").append(loginUser.getUserName()).append(" (ID: ").append(loginUser.getUserId()).append(")\n");
            sb.append("  Algorithm: RSA 2048bit / SHA-256\n");
            sb.append("=====================================================\n");
            sb.append("[PUBLIC KEY]\n").append(publicKeyBase64).append("\n\n");
            sb.append("[PRIVATE KEY]\n").append(privateKeyBase64).append("\n");
            sb.append("=====================================================\n");

            String certContent = sb.toString();

            File dir = new File(CERT_DIR);
            if (!dir.exists()) {
                dir.mkdirs();
            }
            String fileName = "cert_user_" + loginUser.getUserId() + "_" + System.currentTimeMillis() + ".txt";
            File certFile = new File(dir, fileName);
            try (FileWriter writer = new FileWriter(certFile, StandardCharsets.UTF_8)) {
                writer.write(certContent);
            }

            String savedRelativePath = CERT_DIR + "/" + fileName;
            UserDAO dao = new UserDAO();
            dao.updateCertificatePath(loginUser.getUserId(), savedRelativePath);
            loginUser.setCertificatePath(savedRelativePath);
            session.setAttribute("loginUser", loginUser);

            response.setContentType("text/plain; charset=UTF-8");
            response.setHeader("Content-Disposition", "attachment; filename=\"dummy_certificate.txt\"");
            
            try (OutputStream os = response.getOutputStream()) {
                os.write(certContent.getBytes(StandardCharsets.UTF_8));
                os.flush();
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/DashboardServlet?error=cert_failed");
        }
    }
}