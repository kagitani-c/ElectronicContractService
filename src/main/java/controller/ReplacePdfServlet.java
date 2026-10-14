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

import model.dao.ContractDocumentDAO;
import model.entity.ContractDocument;
import model.entity.User;

@WebServlet("/ReplacePdfServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 10485760L, maxRequestSize = 20971520L)
public class ReplacePdfServlet extends HttpServlet {
    private final String UPLOAD_DIR = "./data/uploads";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.sendRedirect("Login");
            return;
        }

        int folderId = Integer.parseInt(request.getParameter("folderId"));
        int oldDocId = Integer.parseInt(request.getParameter("oldDocId"));
        Part filePart = request.getPart("replacementFile");

        if (filePart == null || filePart.getSize() == 0) {
            response.sendRedirect("FolderDetailServlet?id=" + folderId);
            return;
        }

        ContractDocumentDAO dao = new ContractDocumentDAO();
        ContractDocument oldDoc = dao.getDocumentById(oldDocId);
        if (oldDoc == null) {
            response.sendRedirect("FolderDetailServlet?id=" + folderId);
            return;
        }

        // ファイル保存処理
        String originalFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        File uploadDir = new File(UPLOAD_DIR);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        String saveFileName = System.currentTimeMillis() + "_" + originalFileName;
        File targetFile = new File(uploadDir, saveFileName);
        filePart.write(targetFile.getAbsolutePath());

        // 新バージョンのエンティティ構築
        ContractDocument newDoc = new ContractDocument();
        newDoc.setFolderId(folderId);
        newDoc.setTitle(originalFileName);
        newDoc.setFilePath(UPLOAD_DIR + "/" + saveFileName);
        newDoc.setVersion(oldDoc.getVersion() + 1); // バージョンをカウントアップ

        // 旧版の論理削除と新版登録を実行
        dao.replaceDocument(oldDocId, newDoc, loginUser.getUserId());

        response.sendRedirect("FolderDetailServlet?id=" + folderId);
    }
}