package controller;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.dao.ContractDocumentDAO;
import model.entity.ContractDocument;
import model.entity.User;

@WebServlet("/ViewPdfServlet")
public class ViewPdfServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // セキュリティ: ログインしていない人は見られないようにする
        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "ログインが必要です");
            return;
        }

        // 1. 見たいPDFのIDを受け取る
        String idStr = request.getParameter("docId");
        if (idStr == null || idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ドキュメントIDが指定されていません");
            return;
        }

        int docId = Integer.parseInt(idStr);

        // 2. DAOを使って、データベースから「ファイルの保存先（Cドライブのパス）」を取得
        ContractDocumentDAO dao = new ContractDocumentDAO();
        ContractDocument doc = dao.getDocumentById(docId);

        if (doc == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "ドキュメントが見つかりません");
            return;
        }

        // 3. 実際のファイルをCドライブから読み込む
        File pdfFile = new File(doc.getFilePath());
        if (!pdfFile.exists()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "実体ファイルが存在しません");
            return;
        }

        // 4. ブラウザに「今から送るのはPDFデータですよ」と教える設定（プロのテクニック）
        response.setContentType("application/pdf");
        
        // ※ "inline" にするとブラウザ上で直接表示され、"attachment" にするとダウンロード保存になります
        // ファイル名が文字化けしないように設定
        String headerValue = String.format("inline; filename=\"%s\"", java.net.URLEncoder.encode(doc.getTitle(), "UTF-8"));
        response.setHeader("Content-Disposition", headerValue);

        // 5. Cドライブのファイルをブラウザへ直接ストリーミング（転送）する
        Files.copy(pdfFile.toPath(), response.getOutputStream());
    }
}