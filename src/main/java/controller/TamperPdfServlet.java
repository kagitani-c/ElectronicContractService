package controller;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.nio.file.StandardOpenOption;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import model.dao.ContractDocumentDAO;
import model.entity.ContractDocument;

@WebServlet("/TamperPdfServlet")
public class TamperPdfServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String docIdParam = request.getParameter("docId");
        String action = request.getParameter("action"); // "tamper" または "restore"

        if (docIdParam == null || docIdParam.isEmpty()) {
            response.sendRedirect("FolderListServlet");
            return;
        }

        int docId = Integer.parseInt(docIdParam);
        ContractDocumentDAO docDao = new ContractDocumentDAO();
        ContractDocument doc = docDao.getDocumentById(docId);

        if (doc == null || doc.getFilePath() == null) {
            response.sendRedirect("FolderListServlet");
            return;
        }

        File targetFile = new File(doc.getFilePath());
        File backupFile = new File(doc.getFilePath() + ".bak");

        if ("tamper".equals(action)) {
            // 改ざん処理：バックアップを作成した上で、PDFの末尾にダミーバイトを付加
            if (targetFile.exists()) {
                if (!backupFile.exists()) {
                    Files.copy(targetFile.toPath(), backupFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                }
                // ファイル末尾に1バイトのダミーデータを追記（原本バイナリの書き換えをシミュレート）
                Files.write(targetFile.toPath(), "\n%TAMPERED%".getBytes(), StandardOpenOption.APPEND);
            }
        } else if ("restore".equals(action)) {
            // 復元処理：バックアップファイルを元に戻す
            if (backupFile.exists()) {
                Files.copy(backupFile.toPath(), targetFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                backupFile.delete();
            }
        }

        // 検証画面へリダイレクトして再計算結果を表示
        response.sendRedirect("VerifySignatureServlet?docId=" + docId);
    }
}