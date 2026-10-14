package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.dao.FolderDAO;
import model.dao.UserDAO;
import model.entity.Folder;
import model.entity.User;

@WebServlet("/GuestLoginServlet")
public class GuestLoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String token = request.getParameter("token");
        if (token == null || token.trim().isEmpty()) {
            response.sendRedirect("Login");
            return;
        }

        FolderDAO folderDao = new FolderDAO();
        Folder folder = folderDao.getFolderByToken(token);

        if (folder == null) {
            request.setAttribute("errorMessage", "無効または期限切れの招待リンクです。");
            request.getRequestDispatcher("/WEB-INF/jsp/guestLogin.jsp").forward(request, response);
            return;
        }

        request.setAttribute("folder", folder);
        request.getRequestDispatcher("/WEB-INF/jsp/guestLogin.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String token = request.getParameter("token");
        String password = request.getParameter("password");

        if (token == null || token.trim().isEmpty()) {
            response.sendRedirect("Login");
            return;
        }

        FolderDAO folderDao = new FolderDAO();
        Folder folder = folderDao.getFolderByToken(token);

        if (folder == null) {
            response.sendRedirect("Login");
            return;
        }

        if (password == null || password.trim().isEmpty()) {
            request.setAttribute("folder", folder);
            request.setAttribute("errorMessage", "パスワードを入力してください。");
            request.getRequestDispatcher("/WEB-INF/jsp/guestLogin.jsp").forward(request, response);
            return;
        }

        UserDAO userDao = new UserDAO();
        String email = folder.getTargetEmail();

        User existingUser = userDao.findByEmail(email);
        User user = null;

        if (existingUser != null) {
            user = userDao.findByEmailAndPassword(email, password);
            if (user == null) {
                request.setAttribute("folder", folder);
                request.setAttribute("errorMessage", "パスワードが正しくありません。");
                request.getRequestDispatcher("/WEB-INF/jsp/guestLogin.jsp").forward(request, response);
                return;
            }
        } else {
            User newUser = new User();
            newUser.setUserName(folder.getTargetUserName() != null ? folder.getTargetUserName() : "招待ユーザー");
            newUser.setEmail(email);
            newUser.setPassword(password);
            newUser.setUserType("INVITED");
            newUser.setPlanType("NONE");

            boolean registered = userDao.registerUser(newUser);
            if (registered) {
                user = userDao.findByEmailAndPassword(email, password);
            } else {
                request.setAttribute("folder", folder);
                request.setAttribute("errorMessage", "アカウントの登録処理に失敗しました。");
                request.getRequestDispatcher("/WEB-INF/jsp/guestLogin.jsp").forward(request, response);
                return;
            }
        }

        folderDao.updateInvitedUserId(folder.getFolderId(), user.getUserId());

        HttpSession session = request.getSession();
        session.setAttribute("loginUser", user);

        // ★ログイン後はダッシュボードへ遷移
        response.sendRedirect(request.getContextPath() + "/DashboardServlet");
    }
}