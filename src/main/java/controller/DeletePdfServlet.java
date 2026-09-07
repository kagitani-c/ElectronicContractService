package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.dao.ContractDocumentDAO;
import model.entity.User;

@WebServlet("/DeletePdfServlet")
public class DeletePdfServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect("LoginServlet");
            return;
        }

        int documentId = Integer.parseInt(request.getParameter("docId"));
        int folderId = Integer.parseInt(request.getParameter("folderId"));

        ContractDocumentDAO dao = new ContractDocumentDAO();
        // 削除（UPDATE）を実行し、誰が消したかの履歴を残す
        dao.logicalDelete(documentId, loginUser.getUserId());

        // フォルダ詳細画面へ戻る
        response.sendRedirect("FolderDetailServlet?id=" + folderId);
    }
}