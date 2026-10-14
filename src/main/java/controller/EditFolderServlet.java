package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.dao.FolderDAO;
import model.entity.Folder;
import model.entity.User;

@WebServlet("/EditFolderServlet")
public class EditFolderServlet extends HttpServlet {

    // 【画面表示】変更画面を開くときの処理
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect("Login");
            return;
        }

        // 変更したいフォルダのIDを受け取る
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect("FolderListServlet");
            return;
        }

        int folderId = Integer.parseInt(idStr);
        FolderDAO dao = new FolderDAO();
        Folder folder = dao.getFolderById(folderId);

        if (folder == null) {
            response.sendRedirect("FolderListServlet");
            return;
        }

        // 現在のデータを画面に渡す
        request.setAttribute("folder", folder);
        request.getRequestDispatcher("/WEB-INF/jsp/editFolder.jsp").forward(request, response);
    }

    // 【更新処理】「変更を保存する」ボタンが押されたときの処理
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

        // 1. フォームから送信された値を受け取る（両方のパラメータ名に対応）
        int folderId = Integer.parseInt(request.getParameter("folderId"));
        String folderName = request.getParameter("folderName");

        // 企業名（targetCompanyName または companyName）
        String companyName = request.getParameter("targetCompanyName");
        if (companyName == null) {
            companyName = request.getParameter("companyName");
        }

        // 部署名（targetDepartmentName または departmentName）
        String departmentName = request.getParameter("targetDepartmentName");
        if (departmentName == null) {
            departmentName = request.getParameter("departmentName");
        }

        // 担当者名（targetUserName または userName）
        String userName = request.getParameter("targetUserName");
        if (userName == null) {
            userName = request.getParameter("userName");
        }

        // メールアドレス（targetEmail または email）
        String email = request.getParameter("targetEmail");
        if (email == null) {
            email = request.getParameter("email");
        }

        // 証明書発行許可フラグ（certIssuanceAllowed または allowCert）
        String allowParam = request.getParameter("certIssuanceAllowed");
        if (allowParam == null) {
            allowParam = request.getParameter("allowCert");
        }
        boolean isAllow = Boolean.parseBoolean(allowParam);

        // 2. エンティティに詰め込む
        Folder folder = new Folder();
        folder.setFolderId(folderId);
        folder.setFolderName(folderName);
        folder.setTargetCompanyName(companyName);
        folder.setTargetDepartmentName(departmentName);
        folder.setTargetUserName(userName);
        folder.setTargetEmail(email);
        folder.setCertIssuanceAllowed(isAllow);
        
        // 更新実行者の記録
        folder.setUpdatedBy(loginUser.getUserId());

        // 3. DAOを呼び出してデータベースを更新（UPDATE）
        FolderDAO dao = new FolderDAO();
        dao.updateFolder(folder);

        // 4. 更新完了後、フォルダ詳細画面へリダイレクト
        response.sendRedirect("FolderDetailServlet?id=" + folderId);
    }
}