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
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect("LoginServlet");
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
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");

        // 1. フォームから送信された値を受け取る
        int folderId = Integer.parseInt(request.getParameter("folderId"));
        String folderName = request.getParameter("folderName");
        String companyName = request.getParameter("companyName");
        String departmentName = request.getParameter("departmentName");
        String userName = request.getParameter("userName");
        String email = request.getParameter("email");
        boolean isAllow = Boolean.parseBoolean(request.getParameter("allowCert"));

        // 2. エンティティに詰め込む（更新に必要な情報だけセットします）
        Folder folder = new Folder();
        folder.setFolderId(folderId);
        folder.setFolderName(folderName);
        folder.setTargetCompanyName(companyName);
        folder.setTargetDepartmentName(departmentName);
        folder.setTargetUserName(userName);
        folder.setTargetEmail(email);
        folder.setCertIssuanceAllowed(isAllow);
        
        // ★重要：誰が更新したか（履歴）を記録する
        folder.setUpdatedBy(loginUser.getUserId());

        // 3. DAOを呼び出してデータベースを更新（UPDATE）
        FolderDAO dao = new FolderDAO();
        dao.updateFolder(folder);

        // 4. 更新が終わったら、そのフォルダの詳細画面へ戻る
        response.sendRedirect("FolderDetailServlet?id=" + folderId);
    }
}