package controller;

import java.io.IOException;
import java.util.UUID;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.dao.FolderDAO;
import model.entity.Folder;
import model.entity.User;

@WebServlet("/CreateFolderServlet")
public class CreateFolderServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect("Login");
            return;
        }

        // ★ガード処理：招待ユーザーは新規フォルダ作成画面を開けない
        if (loginUser.isGuest()) {
            response.sendRedirect("FolderListServlet?error=forbidden_guest");
            return;
        }

        request.getRequestDispatcher("/WEB-INF/jsp/createFolder.jsp").forward(request, response);
    }

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

        // ★ガード処理：招待ユーザーによる不正POSTを拒絶
        if (loginUser.isGuest()) {
            response.sendRedirect("FolderListServlet?error=forbidden_guest");
            return;
        }

        String folderName = request.getParameter("folderName");
        String targetCompanyName = request.getParameter("targetCompanyName");
        String targetDepartmentName = request.getParameter("targetDepartmentName");
        String targetUserName = request.getParameter("targetUserName");
        String targetEmail = request.getParameter("targetEmail");
        boolean certIssuanceAllowed = "true".equals(request.getParameter("certIssuanceAllowed"));

        if (folderName == null || folderName.trim().isEmpty() ||
            targetCompanyName == null || targetCompanyName.trim().isEmpty() ||
            targetUserName == null || targetUserName.trim().isEmpty() ||
            targetEmail == null || targetEmail.trim().isEmpty()) {
            response.sendRedirect("CreateFolderServlet?error=empty_fields");
            return;
        }

        Folder folder = new Folder();
        folder.setCreatedBy(loginUser.getUserId());
        folder.setFolderName(folderName.trim());
        folder.setTargetCompanyName(targetCompanyName.trim());
        folder.setTargetDepartmentName(targetDepartmentName != null ? targetDepartmentName.trim() : "");
        folder.setTargetUserName(targetUserName.trim());
        folder.setTargetEmail(targetEmail.trim());
        folder.setCertIssuanceAllowed(certIssuanceAllowed);
        folder.setToken(UUID.randomUUID().toString());

        FolderDAO folderDao = new FolderDAO();
        int newFolderId = folderDao.insertFolder(folder);

        if (newFolderId > 0) {
            response.sendRedirect("FolderDetailServlet?id=" + newFolderId);
        } else {
            response.sendRedirect("CreateFolderServlet?error=create_failed");
        }
    }
}