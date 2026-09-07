package controller;

import java.io.IOException;
import java.util.UUID;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.dao.FolderDAO;
import model.entity.Folder;
import model.entity.User; // ログインユーザーのクラス

@WebServlet("/CreateFolderServlet")
public class CreateFolderServlet extends HttpServlet {

    // 画面を表示するためのGETリクエスト処理
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // 入力画面（JSP）へフォワード
        request.getRequestDispatcher("/WEB-INF/jsp/createFolder.jsp").forward(request, response);
        // ※createFolder.jspをWEB-INF外に置いている場合は、単に response.sendRedirect("createFolder.jsp"); でもOKです。
    }

    // フォームから送信されたデータを受け取るPOSTリクエスト処理
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. 文字化け防止（必ず最初に書く）
        request.setCharacterEncoding("UTF-8");

        // 2. セッションからログイン中のユーザー情報を取得
        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");

        // ※テスト用：ログイン機能が未完成の場合は、強制的に user_id = 1 をセットして進める
        int createdByUserId = 1; 
        if (loginUser != null) {
            createdByUserId = loginUser.getUserId();
        }

        // 3. JSPから送信されたパラメータ（name属性の値）を受け取る
        String folderName = request.getParameter("folderName");
        String companyName = request.getParameter("companyName");
        String departmentName = request.getParameter("departmentName");
        String userName = request.getParameter("userName");
        String email = request.getParameter("email");
        String allowCertStr = request.getParameter("allowCert");

        // 4. 受け取ったデータをエンティティ（Folder）にセットする
        Folder folder = new Folder();
        folder.setCreatedBy(createdByUserId);
        folder.setFolderName(folderName);
        folder.setTargetCompanyName(companyName);
        folder.setTargetDepartmentName(departmentName);
        folder.setTargetUserName(userName);
        folder.setTargetEmail(email);
        
        // true/falseの文字列をboolean型に変換
        boolean isAllow = Boolean.parseBoolean(allowCertStr);
        folder.setCertIssuanceAllowed(isAllow);

        // 共有用URLのためのランダムなトークンを自動生成してセット
        String token = UUID.randomUUID().toString();
        folder.setToken(token);

        // 5. DAOを呼び出してデータベースに保存する
        FolderDAO dao = new FolderDAO();
        int newFolderId = dao.insertFolder(folder);

        // 6. 結果に応じて画面遷移
        if (newFolderId > 0) {
            // 成功時：フォルダ一覧を表示するサーブレットへ「リダイレクト（再リクエスト）」する
            response.sendRedirect("FolderListServlet");
        } else {
            // 失敗時：エラーメッセージをセットして、もう一度入力画面へ戻す
            request.setAttribute("errorMsg", "フォルダの作成に失敗しました。");
            request.getRequestDispatcher("/WEB-INF/jsp/createFolder.jsp").forward(request, response);
        }
    }
}