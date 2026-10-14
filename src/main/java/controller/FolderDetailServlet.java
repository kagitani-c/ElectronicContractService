package controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.dao.ContractDocumentDAO;
import model.dao.FolderDAO;
import model.entity.ContractDocument;
import model.entity.Folder;
import model.entity.FolderHistory;
import model.entity.User;

@WebServlet("/FolderDetailServlet")
public class FolderDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. ログインチェック
        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect("Login");
            return;
        }

        // 2. パラメータ取得とバリデーション
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect("FolderListServlet");
            return;
        }

        int folderId = Integer.parseInt(idStr);

        // 3. フォルダ基本情報の取得
        FolderDAO dao = new FolderDAO();
        Folder folder = dao.getFolderById(folderId);

        if (folder == null) {
            response.sendRedirect("FolderListServlet");
            return;
        }

        // 4. 契約書ドキュメントを「有効な最新版」と「削除・差替履歴」に分けて取得
        ContractDocumentDAO docDao = new ContractDocumentDAO();
        List<ContractDocument> activeDocumentList = docDao.getActiveDocumentsByFolderId(folderId);
        List<ContractDocument> historyDocumentList = docDao.getHistoryDocumentsByFolderId(folderId);

        request.setAttribute("activeDocumentList", activeDocumentList);
        request.setAttribute("historyDocumentList", historyDocumentList);

        // 5. フォルダ情報自体の変更履歴を取得
        List<FolderHistory> historyList = dao.getFolderHistories(folderId);
        request.setAttribute("historyList", historyList);

        // 6. JSPへフォワード
        request.setAttribute("folder", folder);
        request.getRequestDispatcher("/WEB-INF/jsp/folderDetail.jsp").forward(request, response);
    }
}