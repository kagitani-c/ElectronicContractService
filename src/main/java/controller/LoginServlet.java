package controller;

import java.io.IOException;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.dao.UserDAO;
import model.entity.User;

@WebServlet({"/Login", "/LoginServlet"})
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // ログイン画面の表示（GET）
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 既にログイン済みの場合はダッシュボードへ直行
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("loginUser") != null) {
            response.sendRedirect(request.getContextPath() + "/DashboardServlet");
            return;
        }

        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/jsp/login.jsp");
        dispatcher.forward(request, response);
    }

    // ログイン認証処理（POST）
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // 入力値チェック
        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/Login?error=true");
            return;
        }

        email = email.trim();
        password = password.trim();

        // DB認証
        UserDAO dao = new UserDAO();
        User loginUser = dao.findByEmailAndPassword(email, password);

        if (loginUser != null) {
            // 認証成功：セッションを生成してユーザー情報を保持
            HttpSession session = request.getSession(true);
            session.setAttribute("loginUser", loginUser);

            // ★ログイン成功後はダッシュボードへリダイレクト
            response.sendRedirect(request.getContextPath() + "/DashboardServlet");
        } else {
            // 認証失敗：エラーパラメータ付きでログイン画面へ戻す
            response.sendRedirect(request.getContextPath() + "/Login?error=true");
        }
    }
}