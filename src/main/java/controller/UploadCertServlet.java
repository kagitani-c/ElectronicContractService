package controller;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import model.dao.UserDAO;
import model.entity.User;

@WebServlet("/UploadCertServlet")
@MultipartConfig(
    maxFileSize = 1048576, // 最大1MB
    maxRequestSize = 1048576
)
public class UploadCertServlet extends HttpServlet {

    private static final String CERT_DIR = "./data/certificates";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        // リクエスト送信元（ダッシュボードまたはユーザー管理画面）の特定
        String referer = request.getHeader("referer");
        String redirectTarget = request.getContextPath() + "/DashboardServlet";
        if (referer != null && referer.contains("UserManageServlet")) {
            redirectTarget = request.getContextPath() + "/UserManageServlet";
        }

        Part filePart = request.getPart("certFile");
        if (filePart == null || filePart.getSize() == 0) {
            response.sendRedirect(redirectTarget + "?cert_error=empty");
            return;
        }

        String originalFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        if (originalFileName == null || originalFileName.trim().isEmpty()) {
            response.sendRedirect(redirectTarget + "?cert_error=empty");
            return;
        }

        try {
            // 保存ディレクトリの確認・作成
            File dir = new File(CERT_DIR);
            if (!dir.exists()) {
                dir.mkdirs();
            }

            // 重複防止ファイル名で保存
            String saveFileName = "uploaded_user_" + loginUser.getUserId() + "_" + System.currentTimeMillis() + "_" + originalFileName;
            File targetFile = new File(dir, saveFileName);
            filePart.write(targetFile.getAbsolutePath());

            // データベースとセッション情報を更新
            String relativePath = CERT_DIR + "/" + saveFileName;
            UserDAO dao = new UserDAO();
            dao.updateCertificatePath(loginUser.getUserId(), relativePath);

            loginUser.setCertificatePath(relativePath);
            session.setAttribute("loginUser", loginUser);

            // JSPの通知条件（param.cert_success == 'true'）に合わせてリダイレクト
            response.sendRedirect(redirectTarget + "?cert_success=true");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(redirectTarget + "?cert_error=upload_failed");
        }
    }
}