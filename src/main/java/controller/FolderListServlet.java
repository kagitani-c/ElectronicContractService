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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.sendRedirect("Login");
            return;
        }

        FolderDAO folderDAO = new FolderDAO();
        List<Folder> folderList = folderDAO.getFoldersByUserId(loginUser.getUserId());

        // ★ワンクリック電子証明書発行が許可されているかを判定
        boolean canIssueCert = true;
        if (loginUser.isGuest()) {
            canIssueCert = folderDAO.isCertIssuanceAllowedByInvitedUserId(loginUser.getUserId());
        }

        request.setAttribute("folderList", folderList);
        request.setAttribute("canIssueCert", canIssueCert);

        request.getRequestDispatcher("/WEB-INF/jsp/folderList.jsp").forward(request, response);
    }
}