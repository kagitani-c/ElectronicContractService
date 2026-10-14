package model.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import model.entity.ContractDocument;

public class ContractDocumentDAO {
    private final String URL = "jdbc:h2:./data/esign_db;AUTO_SERVER=TRUE";
    private final String USER = "sa";
    private final String PASS = "";

    private void ensureTableExists(Connection conn) throws SQLException {
        String createTableSql = "CREATE TABLE IF NOT EXISTS contract_document ("
                + "document_id INT AUTO_INCREMENT PRIMARY KEY, "
                + "folder_id INT, "
                + "title VARCHAR(255), "
                + "file_path VARCHAR(500), "
                + "version INT DEFAULT 1, "
                + "is_deleted BOOLEAN DEFAULT FALSE, "
                + "deleted_at TIMESTAMP, "
                + "deleted_by INT, "
                + "signature_data CLOB, "
                + "file_hash VARCHAR(64), "
                + "signed_at TIMESTAMP, "
                + "signed_by INT, "
                + "invited_signature_data CLOB, "
                + "invited_signed_at TIMESTAMP, "
                + "invited_signed_by INT"
                + ")";
        try (Statement stmt = conn.createStatement()) {
            stmt.execute(createTableSql);
            stmt.execute("ALTER TABLE contract_document ADD COLUMN IF NOT EXISTS invited_signature_data CLOB");
            stmt.execute("ALTER TABLE contract_document ADD COLUMN IF NOT EXISTS invited_signed_at TIMESTAMP");
            stmt.execute("ALTER TABLE contract_document ADD COLUMN IF NOT EXISTS invited_signed_by INT");
        }
    }

    public List<ContractDocument> getActiveDocumentsByFolderId(int folderId) {
        List<ContractDocument> list = new ArrayList<>();
        String sql = "SELECT * FROM contract_document WHERE folder_id = ? AND is_deleted = FALSE ORDER BY document_id DESC";

        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {
                ensureTableExists(conn);
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, folderId);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        while (rs.next()) {
                            list.add(mapResultSetToDocument(rs));
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<ContractDocument> getHistoryDocumentsByFolderId(int folderId) {
        List<ContractDocument> list = new ArrayList<>();
        String sql = "SELECT * FROM contract_document WHERE folder_id = ? AND is_deleted = TRUE ORDER BY document_id DESC";

        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {
                ensureTableExists(conn);
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, folderId);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        while (rs.next()) {
                            list.add(mapResultSetToDocument(rs));
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public ContractDocument getDocumentById(int docId) {
        String sql = "SELECT * FROM contract_document WHERE document_id = ?";
        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {
                ensureTableExists(conn);
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, docId);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        if (rs.next()) {
                            return mapResultSetToDocument(rs);
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean insertDocument(ContractDocument doc) {
        String sql = "INSERT INTO contract_document (folder_id, title, file_path, version) VALUES (?, ?, ?, 1)";
        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {
                ensureTableExists(conn);
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, doc.getFolderId());
                    pstmt.setString(2, doc.getTitle());
                    pstmt.setString(3, doc.getFilePath());
                    return pstmt.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean saveSignature(int docId, String signatureData, String fileHash, int userId) {
        String sql = "UPDATE contract_document SET signature_data = ?, file_hash = ?, signed_at = CURRENT_TIMESTAMP, signed_by = ? WHERE document_id = ?";
        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {
                ensureTableExists(conn);
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, signatureData);
                    pstmt.setString(2, fileHash);
                    pstmt.setInt(3, userId);
                    pstmt.setInt(4, docId);
                    return pstmt.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean saveInvitedSignature(int docId, String signatureData, int userId) {
        String sql = "UPDATE contract_document SET invited_signature_data = ?, invited_signed_at = CURRENT_TIMESTAMP, invited_signed_by = ? WHERE document_id = ?";
        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {
                ensureTableExists(conn);
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, signatureData);
                    pstmt.setInt(2, userId);
                    pstmt.setInt(3, docId);
                    return pstmt.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean replaceDocument(int oldDocId, ContractDocument newDoc, int userId) {
        String updateOldSql = "UPDATE contract_document SET is_deleted = TRUE, deleted_at = CURRENT_TIMESTAMP, deleted_by = ? WHERE document_id = ?";
        String insertNewSql = "INSERT INTO contract_document (folder_id, title, file_path, version) VALUES (?, ?, ?, ?)";

        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {
                ensureTableExists(conn);
                conn.setAutoCommit(false);

                try (PreparedStatement pstmt1 = conn.prepareStatement(updateOldSql);
                     PreparedStatement pstmt2 = conn.prepareStatement(insertNewSql)) {

                    pstmt1.setInt(1, userId);
                    pstmt1.setInt(2, oldDocId);
                    pstmt1.executeUpdate();

                    pstmt2.setInt(1, newDoc.getFolderId());
                    pstmt2.setString(2, newDoc.getTitle());
                    pstmt2.setString(3, newDoc.getFilePath());
                    pstmt2.setInt(4, newDoc.getVersion());
                    pstmt2.executeUpdate();

                    conn.commit();
                    return true;
                } catch (Exception e) {
                    conn.rollback();
                    e.printStackTrace();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean logicalDelete(int docId, int userId) {
        String sql = "UPDATE contract_document SET is_deleted = TRUE, deleted_at = CURRENT_TIMESTAMP, deleted_by = ? WHERE document_id = ?";
        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {
                ensureTableExists(conn);
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, userId);
                    pstmt.setInt(2, docId);
                    return pstmt.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private ContractDocument mapResultSetToDocument(ResultSet rs) throws SQLException {
        ContractDocument doc = new ContractDocument();
        doc.setDocumentId(rs.getInt("document_id"));
        doc.setFolderId(rs.getInt("folder_id"));
        doc.setTitle(rs.getString("title"));
        doc.setFilePath(rs.getString("file_path"));
        doc.setVersion(rs.getInt("version"));
        doc.setDeleted(rs.getBoolean("is_deleted"));
        doc.setDeletedAt(rs.getTimestamp("deleted_at"));

        int deletedBy = rs.getInt("deleted_by");
        if (!rs.wasNull()) doc.setDeletedBy(deletedBy);

        doc.setSignatureData(rs.getString("signature_data"));
        doc.setFileHash(rs.getString("file_hash"));
        doc.setSignedAt(rs.getTimestamp("signed_at"));

        int signedBy = rs.getInt("signed_by");
        if (!rs.wasNull()) doc.setSignedBy(signedBy);

        doc.setInvitedSignatureData(rs.getString("invited_signature_data"));
        doc.setInvitedSignedAt(rs.getTimestamp("invited_signed_at"));

        int invitedSignedBy = rs.getInt("invited_signed_by");
        if (!rs.wasNull()) doc.setInvitedSignedBy(invitedSignedBy);

        return doc;
    }
    
    /**
     * 最新のファイルハッシュ値を更新する
     */
    public boolean updateFileHash(int docId, String fileHash) {
        String sql = "UPDATE contract_document SET file_hash = ? WHERE document_id = ?";
        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS);
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, fileHash);
                pstmt.setInt(2, docId);
                return pstmt.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}