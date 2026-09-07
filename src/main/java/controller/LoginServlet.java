package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.dao.UserDAO;
import model.entity.User;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    // GETリクエスト：ログイン画面を表示するだけ
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(request, response);
    }

    // POSTリクエスト：ログインボタンが押された時の認証処理
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. 画面から送られてきた値を受け取る
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // 2. DAOを使ってDBを検索
        UserDAO dao = new UserDAO();
        User user = dao.findByEmailAndPassword(email, password);

        // 3. 認証結果による分岐
        if (user != null) {
            // 【大成功】セッション（サーバー側の記憶領域）にユーザー情報を保存
            HttpSession session = request.getSession();
            session.setAttribute("loginUser", user);
            
            // フォルダ一覧画面へリダイレクト（PRGパターン）
            response.sendRedirect("FolderListServlet");
        } else {
            // 【失敗】エラーメッセージをセットして、もう一度ログイン画面を表示
            request.setAttribute("errorMsg", "メールアドレスまたはパスワードが間違っています。");
            request.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(request, response);
        }
    }
}