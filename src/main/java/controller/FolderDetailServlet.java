package controller;

import java.io.IOException;
import java.util.List;                // ← クラスの一番上でimportしてください

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.dao.ContractDocumentDAO; // ← クラスの一番上でimportしてください
import model.dao.FolderDAO;
import model.entity.ContractDocument; // ← クラスの一番上でimportしてください
import model.entity.Folder;
import model.entity.FolderHistory; // ← クラスの一番上でimportしてください
import model.entity.User;


@WebServlet("/FolderDetailServlet")
public class FolderDetailServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. ログインチェック（一覧画面と同じ定石）
        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect("LoginServlet");
            return;
        }

        // 2. URLにくっついてきた「id」を受け取る（例: ?id=3 なら "3" を取得）
        String idStr = request.getParameter("id");
        
        if (idStr == null || idStr.isEmpty()) {
            // 万が一IDが送られてこなかった場合は、一覧へ強制送還
            response.sendRedirect("FolderListServlet");
            return;
        }

        // String型をint型に変換
        int folderId = Integer.parseInt(idStr);

        // 3. DAOを使って、該当するIDのフォルダ情報をデータベースから取得
        FolderDAO dao = new FolderDAO();
        Folder folder = dao.getFolderById(folderId);

        if (folder == null) {
            // 該当するフォルダが見つからなかった場合も一覧へ強制送還
            response.sendRedirect("FolderListServlet");
            return;
        }
        
     // ↓↓↓ ここから追加 ↓↓↓
        // 4. このフォルダに紐づく「アップロードされたPDF一覧」を取得
        ContractDocumentDAO docDao = new ContractDocumentDAO();
        List<ContractDocument> documentList = docDao.getDocumentsByFolderId(folderId);
        
        // 取得したPDF一覧もリクエストスコープに保存する
        request.setAttribute("documentList", documentList);
        // ↑↑↑ ここまで追加 ↑↑↑
        
     // ↓↓↓ ここから追加 ↓↓↓
        // 5. フォルダの変更履歴を取得
        List<FolderHistory> historyList = dao.getFolderHistories(folderId);
        request.setAttribute("historyList", historyList);
        // ↑↑↑ ここまで追加 ↑↑↑

     // --- 既存のフォワード処理（これを下敷きにする） ---
        // 4. 取得したフォルダ情報をリクエストスコープに保存して、JSPへ渡す
        request.setAttribute("folder", folder);
        request.getRequestDispatcher("/WEB-INF/jsp/folderDetail.jsp").forward(request, response);
    }
}