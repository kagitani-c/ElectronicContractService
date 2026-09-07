package controller;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import model.dao.ContractDocumentDAO;
import model.entity.ContractDocument;

@WebServlet("/UploadPdfServlet")
// ↓★★★ これがファイルアップロード必須のおまじないです ★★★
@MultipartConfig(
    maxFileSize = 10485760,      // 最大10MBまで許可
    maxRequestSize = 10485760    // リクエスト全体も10MBまで
)
public class UploadPdfServlet extends HttpServlet {

    // 保存先のフォルダ（Cドライブ直下に保存します）
    private static final String UPLOAD_DIR = "C:/data/uploads";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");

        // 1. どのフォルダへのアップロードか（folderId）を受け取る
        int folderId = Integer.parseInt(request.getParameter("folderId"));

        // 2. 送信されたファイルデータ（Part）を受け取る
        Part filePart = request.getPart("pdfFile");
        
        // ファイル名を取得（IE対応などのための安全な取得方法）
        String originalFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

        if (originalFileName == null || originalFileName.isEmpty()) {
            response.sendRedirect("FolderDetailServlet?id=" + folderId);
            return;
        }

        // 3. 保存先のディレクトリが存在しない場合は自動作成する
        File uploadDir = new File(UPLOAD_DIR);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        // 4. ファイル名の重複を防ぐため、システム時間をファイル名の先頭にくっつける
        String saveFileName = System.currentTimeMillis() + "_" + originalFileName;
        String absoluteSavePath = UPLOAD_DIR + File.separator + saveFileName;

        // 5. 実際にCドライブへファイルを書き込む（保存！）
        filePart.write(absoluteSavePath);

        // 6. データベースへ情報を記録する
        ContractDocument doc = new ContractDocument();
        doc.setFolderId(folderId);
        doc.setTitle(originalFileName); // 画面表示用には元のファイル名を使用
        doc.setFilePath(absoluteSavePath); // DBには実際の保存パスを記録

        ContractDocumentDAO dao = new ContractDocumentDAO();
        dao.insertDocument(doc);

        // 7. 元の詳細画面へリダイレクト（PRGパターン）
        response.sendRedirect("FolderDetailServlet?id=" + folderId);
    }
}