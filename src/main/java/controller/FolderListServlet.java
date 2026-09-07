package controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.dao.FolderDAO;
import model.entity.Folder;
import model.entity.User;

@WebServlet("/FolderListServlet")
public class FolderListServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. セッションからログイン中のユーザー情報を取得
        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");

        if (loginUser == null) {
            // login.jspはWEB-INF内にあり直接アクセスできないため、
            // ログイン画面を表示する担当の「LoginServlet」へリダイレクトさせます
            response.sendRedirect("LoginServlet");
            return;
        }

        // 2. DAOを使ってDBからフォルダ一覧を取得
        FolderDAO folderDAO = new FolderDAO();
        List<Folder> folderList = folderDAO.getFoldersByUserId(loginUser.getUserId());

        // 3. 取得したリストをリクエストスコープに保存
        request.setAttribute("folderList", folderList);

        // 4. JSP（ビュー）へフォワード
        request.getRequestDispatcher("/WEB-INF/jsp/folderList.jsp").forward(request, response);
    }
}