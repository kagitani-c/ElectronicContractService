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
import model.entity.User;

@WebServlet("/UserManageServlet")
public class UserManageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect("Login");
            return;
        }

        // ★招待ユーザーの電子証明書発行許可フラグを判定
        FolderDAO folderDao = new FolderDAO();
        boolean canIssueCert = true;
        if (loginUser.isGuest()) {
            canIssueCert = folderDao.isCertIssuanceAllowedByInvitedUserId(loginUser.getUserId());
        }
        request.setAttribute("canIssueCert", canIssueCert);

        request.getRequestDispatcher("/WEB-INF/jsp/userManage.jsp").forward(request, response);
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

        String userName = request.getParameter("userName");
        String companyName = request.getParameter("companyName");
        String email = request.getParameter("email");

        if (userName == null || userName.trim().isEmpty()) {
            response.sendRedirect("UserManageServlet?error=empty_name");
            return;
        }
        if (email == null || email.trim().isEmpty()) {
            response.sendRedirect("UserManageServlet?error=empty_email");
            return;
        }

        userName = userName.trim();
        email = email.trim();
        if (companyName != null) {
            companyName = companyName.trim();
        }

        UserDAO userDao = new UserDAO();

        if (!email.equalsIgnoreCase(loginUser.getEmail())) {
            User existingUser = userDao.findByEmail(email);
            if (existingUser != null && existingUser.getUserId() != loginUser.getUserId()) {
                response.sendRedirect("UserManageServlet?error=duplicate_email");
                return;
            }
        }

        loginUser.setUserName(userName);
        loginUser.setCompanyName(companyName);
        loginUser.setEmail(email);

        boolean isSuccess = userDao.updateUser(loginUser);
        if (isSuccess) {
            session.setAttribute("loginUser", loginUser);
            response.sendRedirect("UserManageServlet?updated=true");
        } else {
            response.sendRedirect("UserManageServlet?error=update_failed");
        }
    }
}