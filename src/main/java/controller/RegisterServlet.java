package controller; // ※ servlet パッケージの場合は package servlet; に変更してください

import java.io.IOException;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import model.dao.UserDAO; // または import model.UserDAO;
// ご自身の構成に合わせて import パスを確認してください
import model.entity.User; // または import model.User;

@WebServlet("/Register")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // 画面の表示（GETリクエスト）
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/jsp/register.jsp");
        dispatcher.forward(request, response);
    }

    // 登録ボタンが押されたときの処理（POSTリクエスト）
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // 入力値の簡易チェック
        if (name == null || email == null || password == null ||
            name.isBlank() || email.isBlank() || password.isBlank()) {
            request.setAttribute("errorMsg", "すべての項目を入力してください。");
            RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/jsp/register.jsp");
            dispatcher.forward(request, response);
            return;
        }

        // ユーザーオブジェクトを作成
        User user = new User();
        user.setUserName(name);
        user.setEmail(email);
        user.setPassword(password);

        UserDAO dao = new UserDAO();
        boolean isSuccess = dao.registerUser(user);

        if (isSuccess) {
            // 登録成功時はログイン画面へリダイレクト
            response.sendRedirect(request.getContextPath() + "/Login");
        } else {
            // メールアドレス重複などのエラー時
            request.setAttribute("errorMsg", "登録に失敗しました。既に同じメールアドレスが登録されている可能性があります。");
            RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/jsp/register.jsp");
            dispatcher.forward(request, response);
        }
    }
}