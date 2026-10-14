package controller;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.dao.ContractDocumentDAO;
import model.entity.ContractDocument;
import model.entity.User;

@WebServlet("/DownloadPdfServlet")
public class DownloadPdfServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect("Login");
            return;
        }

        String docIdStr = request.getParameter("docId");
        if (docIdStr == null || docIdStr.isEmpty()) {
            response.sendRedirect("FolderListServlet");
            return;
        }

        try {
            int docId = Integer.parseInt(docIdStr);
            ContractDocumentDAO docDao = new ContractDocumentDAO();
            ContractDocument doc = docDao.getDocumentById(docId);

            if (doc == null || doc.getFilePath() == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "契約書データが見つかりません。");
                return;
            }

            File pdfFile = new File(doc.getFilePath());
            if (!pdfFile.exists()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "サーバー上にPDFファイルが存在しません。");
                return;
            }

            // ダウンロード時のファイル名成形（日本語ファイル名対応）
            String downloadFileName = doc.getTitle();
            if (!downloadFileName.toLowerCase().endsWith(".pdf")) {
                downloadFileName += ".pdf";
            }
            String encodedFileName = URLEncoder.encode(downloadFileName, StandardCharsets.UTF_8).replaceAll("\\+", "%20");

            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "attachment; filename*=UTF-8''" + encodedFileName);
            response.setContentLengthLong(pdfFile.length());

            try (FileInputStream fis = new FileInputStream(pdfFile);
                 OutputStream os = response.getOutputStream()) {
                fis.transferTo(os);
                os.flush();
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("FolderListServlet");
        }
    }
}