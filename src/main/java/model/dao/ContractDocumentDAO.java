package model.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import model.entity.ContractDocument;

public class ContractDocumentDAO {
    // URLはH2データベースの環境に合わせています
    private final String URL = "jdbc:h2:C:/data/esign_db;AUTO_SERVER=TRUE";
    private final String USER = "sa";
    private final String PASS = "";

    /**
     * アップロードされた契約書ドキュメントの情報をDBに登録する
     */
    public int insertDocument(ContractDocument doc) {
        int generatedId = -1;
        // versionはデフォルトで1（送信時）とするようDB側で設定済みですが、明示的に入れます
        String sql = "INSERT INTO contract_document (folder_id, title, file_path, version) VALUES (?, ?, ?, 1)";

        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS);
                 PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

                pstmt.setInt(1, doc.getFolderId());
                pstmt.setString(2, doc.getTitle());
                pstmt.setString(3, doc.getFilePath());

                int affectedRows = pstmt.executeUpdate();

                if (affectedRows > 0) {
                    try (ResultSet rs = pstmt.getGeneratedKeys()) {
                        if (rs.next()) {
                            generatedId = rs.getInt(1);
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return generatedId;
    }
    
    /**
     * 指定したフォルダIDに紐づく契約書ドキュメントの一覧を取得する
     */
    public List<ContractDocument> getDocumentsByFolderId(int folderId) {
        List<ContractDocument> list = new ArrayList<>();
        String sql = "SELECT * FROM contract_document WHERE folder_id = ? ORDER BY document_id ASC";

        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS);
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {

                pstmt.setInt(1, folderId);
                try (ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) {
                        ContractDocument doc = new ContractDocument();
                        doc.setDocumentId(rs.getInt("document_id"));
                        doc.setFolderId(rs.getInt("folder_id"));
                        doc.setTitle(rs.getString("title"));
                        doc.setFilePath(rs.getString("file_path"));
                        doc.setVersion(rs.getInt("version"));
                     // ↓↓↓ 今回追加する箇所 ↓↓↓
                        // 1. 削除フラグ（boolean）
                        doc.setDeleted(rs.getBoolean("is_deleted"));
                        
                        // 2. 削除日時（Timestamp）
                        doc.setDeletedAt(rs.getTimestamp("deleted_at"));
                        
                        // 3. 削除したユーザーID（Nullの可能性を考慮するプロの書き方）
                        int deletedBy = rs.getInt("deleted_by");
                        if (!rs.wasNull()) {
                            doc.setDeletedBy(deletedBy);
                        }
                        // ↑↑↑ 今回追加する箇所ここまで ↑↑↑
                        list.add(doc);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * ドキュメントIDから特定の契約書情報を1件取得する（ファイル配信のため）
     */
    public ContractDocument getDocumentById(int documentId) {
        ContractDocument doc = null;
        String sql = "SELECT * FROM contract_document WHERE document_id = ?";

        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS);
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {

                pstmt.setInt(1, documentId);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        doc = new ContractDocument();
                        doc.setDocumentId(rs.getInt("document_id"));
                        doc.setFolderId(rs.getInt("folder_id"));
                        doc.setTitle(rs.getString("title"));
                        doc.setFilePath(rs.getString("file_path"));
                        doc.setVersion(rs.getInt("version"));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return doc;
    }
    
    /**
     * ドキュメントを論理削除する（履歴を残す）
     */
    public boolean logicalDelete(int documentId, int userId) {
        // DELETE文ではなくUPDATE文を使います
        String sql = "UPDATE contract_document SET is_deleted = TRUE, deleted_at = CURRENT_TIMESTAMP, deleted_by = ? WHERE document_id = ?";
        
        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS);
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {
                
                pstmt.setInt(1, userId);
                pstmt.setInt(2, documentId);
                
                int result = pstmt.executeUpdate();
                return result > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}