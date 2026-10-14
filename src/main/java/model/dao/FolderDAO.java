package model.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import model.entity.Folder;
import model.entity.FolderHistory;

public class FolderDAO {
    private final String URL = "jdbc:h2:./data/esign_db;AUTO_SERVER=TRUE";
    private final String USER = "sa";
    private final String PASS = "";

    private void ensureTablesExist(Connection conn) throws SQLException {
        String createFolderTableSql = "CREATE TABLE IF NOT EXISTS folder ("
                + "folder_id INT AUTO_INCREMENT PRIMARY KEY, "
                + "created_by INT, "
                + "invited_user_id INT, "
                + "folder_name VARCHAR(255), "
                + "target_company_name VARCHAR(255), "
                + "target_department_name VARCHAR(255), "
                + "target_user_name VARCHAR(255), "
                + "target_email VARCHAR(255), "
                + "token VARCHAR(255), "
                + "is_cert_issuance_allowed BOOLEAN, "
                + "status VARCHAR(20) DEFAULT 'DRAFT', "
                + "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
                + "updated_by INT"
                + ")";
        try (Statement stmt = conn.createStatement()) {
            stmt.execute(createFolderTableSql);
            stmt.execute("ALTER TABLE folder ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'DRAFT'");
            stmt.execute("ALTER TABLE folder ADD COLUMN IF NOT EXISTS invited_user_id INT");
        }
    }

    /**
     * 新規フォルダをデータベースに登録する
     */
    public int insertFolder(Folder folder) {
        String sql = "INSERT INTO folder "
                   + "(created_by, invited_user_id, folder_name, target_company_name, target_department_name, target_user_name, target_email, token, is_cert_issuance_allowed, status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'DRAFT')";
        
        int generatedId = -1;

        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {
                ensureTablesExist(conn);

                try (PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                    pstmt.setInt(1, folder.getCreatedBy());
                    
                    if (folder.getInvitedUserId() != null && folder.getInvitedUserId() != 0) {
                        pstmt.setInt(2, folder.getInvitedUserId());
                    } else {
                        pstmt.setNull(2, java.sql.Types.INTEGER);
                    }
                    
                    pstmt.setString(3, folder.getFolderName());
                    pstmt.setString(4, folder.getTargetCompanyName());
                    pstmt.setString(5, folder.getTargetDepartmentName());
                    pstmt.setString(6, folder.getTargetUserName());
                    pstmt.setString(7, folder.getTargetEmail());
                    pstmt.setString(8, folder.getToken());
                    pstmt.setBoolean(9, folder.isCertIssuanceAllowed());

                    int affectedRows = pstmt.executeUpdate();
                    if (affectedRows > 0) {
                        try (ResultSet rs = pstmt.getGeneratedKeys()) {
                            if (rs.next()) {
                                generatedId = rs.getInt(1);
                            }
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
     * フォルダ基本情報を更新し、同時に変更履歴（folder_history）へ記録する
     */
    public boolean updateFolder(Folder folder) {
        String updateFolderSql = "UPDATE folder SET "
                   + "folder_name = ?, "
                   + "target_company_name = ?, "
                   + "target_department_name = ?, "
                   + "target_user_name = ?, "
                   + "target_email = ?, "
                   + "is_cert_issuance_allowed = ?, "
                   + "updated_at = CURRENT_TIMESTAMP, "
                   + "updated_by = ? "
                   + "WHERE folder_id = ?";

        String insertHistorySql = "INSERT INTO folder_history "
                   + "(folder_id, changed_by, folder_name, target_company_name, target_department_name, target_user_name, target_email) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        String createHistoryTableSql = "CREATE TABLE IF NOT EXISTS folder_history ("
                + "history_id INT AUTO_INCREMENT PRIMARY KEY, "
                + "folder_id INT, "
                + "changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
                + "changed_by INT, "
                + "folder_name VARCHAR(255), "
                + "target_company_name VARCHAR(255), "
                + "target_department_name VARCHAR(255), "
                + "target_user_name VARCHAR(255), "
                + "target_email VARCHAR(255)"
                + ")";

        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {
                ensureTablesExist(conn);
                try (Statement stmt = conn.createStatement()) {
                    stmt.execute(createHistoryTableSql);
                }

                // トランザクション開始（更新と履歴記録を不可分にする）
                conn.setAutoCommit(false);

                try (PreparedStatement pstmt = conn.prepareStatement(updateFolderSql);
                     PreparedStatement histStmt = conn.prepareStatement(insertHistorySql)) {

                    // 1. フォルダ情報の更新
                    pstmt.setString(1, folder.getFolderName());
                    pstmt.setString(2, folder.getTargetCompanyName());
                    pstmt.setString(3, folder.getTargetDepartmentName());
                    pstmt.setString(4, folder.getTargetUserName());
                    pstmt.setString(5, folder.getTargetEmail());
                    pstmt.setBoolean(6, folder.isCertIssuanceAllowed());
                    pstmt.setInt(7, folder.getUpdatedBy());
                    pstmt.setInt(8, folder.getFolderId());
                    int affectedRows = pstmt.executeUpdate();

                    // 2. 変更履歴の登録
                    histStmt.setInt(1, folder.getFolderId());
                    histStmt.setInt(2, folder.getUpdatedBy());
                    histStmt.setString(3, folder.getFolderName());
                    histStmt.setString(4, folder.getTargetCompanyName());
                    histStmt.setString(5, folder.getTargetDepartmentName());
                    histStmt.setString(6, folder.getTargetUserName());
                    histStmt.setString(7, folder.getTargetEmail());
                    histStmt.executeUpdate();

                    conn.commit();
                    return affectedRows > 0;

                } catch (Exception e) {
                    conn.rollback();
                    e.printStackTrace();
                    return false;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * ユーザーIDに紐づくフォルダ一覧を取得する（作成または招待されたフォルダ）
     */
    public List<Folder> getFoldersByUserId(int userId) {
        List<Folder> list = new ArrayList<>();
        String sql = "SELECT * FROM folder WHERE created_by = ? OR invited_user_id = ? ORDER BY folder_id DESC";

        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {
                ensureTablesExist(conn);
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, userId);
                    pstmt.setInt(2, userId);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        while (rs.next()) {
                            list.add(mapResultSetToFolder(rs));
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * フォルダIDからフォルダ情報を1件取得する
     */
    public Folder getFolderById(int folderId) {
        Folder folder = null;
        String sql = "SELECT * FROM folder WHERE folder_id = ?";

        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {
                ensureTablesExist(conn);
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, folderId);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        if (rs.next()) {
                            folder = mapResultSetToFolder(rs);
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return folder;
    }

    /**
     * トークンからフォルダ情報を1件取得する
     */
    public Folder getFolderByToken(String token) {
        Folder folder = null;
        String sql = "SELECT * FROM folder WHERE token = ?";

        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {
                ensureTablesExist(conn);
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, token);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        if (rs.next()) {
                            folder = mapResultSetToFolder(rs);
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return folder;
    }

    /**
     * フォルダのステータス（DRAFT, WAITING_SIGN, COMPLETED）を更新する
     */
    public boolean updateFolderStatus(int folderId, String status) {
        String sql = "UPDATE folder SET status = ? WHERE folder_id = ?";
        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {
                ensureTablesExist(conn);
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, status);
                    pstmt.setInt(2, folderId);
                    return pstmt.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * フォルダに招待されたユーザーIDを紐付ける
     */
    public boolean updateInvitedUserId(int folderId, int invitedUserId) {
        String sql = "UPDATE folder SET invited_user_id = ? WHERE folder_id = ?";
        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {
                ensureTablesExist(conn);
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, invitedUserId);
                    pstmt.setInt(2, folderId);
                    return pstmt.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * フォルダ情報の変更履歴一覧を取得する
     */
    public List<FolderHistory> getFolderHistories(int folderId) {
        List<FolderHistory> list = new ArrayList<>();
        String createHistoryTableSql = "CREATE TABLE IF NOT EXISTS folder_history ("
                + "history_id INT AUTO_INCREMENT PRIMARY KEY, "
                + "folder_id INT, "
                + "changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
                + "changed_by INT, "
                + "folder_name VARCHAR(255), "
                + "target_company_name VARCHAR(255), "
                + "target_department_name VARCHAR(255), "
                + "target_user_name VARCHAR(255), "
                + "target_email VARCHAR(255)"
                + ")";

        String sql = "SELECT * FROM folder_history WHERE folder_id = ? ORDER BY changed_at DESC";

        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {
                try (Statement stmt = conn.createStatement()) {
                    stmt.execute(createHistoryTableSql);
                }
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, folderId);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        while (rs.next()) {
                            FolderHistory h = new FolderHistory();
                            h.setHistoryId(rs.getInt("history_id"));
                            h.setFolderId(rs.getInt("folder_id"));
                            h.setChangedAt(rs.getTimestamp("changed_at"));
                            h.setChangedBy(rs.getInt("changed_by"));
                            h.setFolderName(rs.getString("folder_name"));
                            h.setTargetCompanyName(rs.getString("target_company_name"));
                            h.setTargetDepartmentName(rs.getString("target_department_name"));
                            h.setTargetUserName(rs.getString("target_user_name"));
                            h.setTargetEmail(rs.getString("target_email"));
                            list.add(h);
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    /**
     * 招待ユーザー（ゲスト）に対して電子証明書のワンクリック発行が許可されているかを判定する
     */
    public boolean isCertIssuanceAllowedByInvitedUserId(int userId) {
        String sql = "SELECT is_cert_issuance_allowed FROM folder "
                   + "WHERE invited_user_id = ? OR target_email = (SELECT email FROM users WHERE user_id = ?) "
                   + "ORDER BY folder_id DESC";
        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {
                ensureTablesExist(conn);
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, userId);
                    pstmt.setInt(2, userId);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        if (rs.next()) {
                            return rs.getBoolean("is_cert_issuance_allowed");
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private Folder mapResultSetToFolder(ResultSet rs) throws SQLException {
        Folder folder = new Folder();
        folder.setFolderId(rs.getInt("folder_id"));
        folder.setCreatedBy(rs.getInt("created_by"));

        int invitedId = rs.getInt("invited_user_id");
        if (!rs.wasNull()) folder.setInvitedUserId(invitedId);

        folder.setFolderName(rs.getString("folder_name"));
        folder.setTargetCompanyName(rs.getString("target_company_name"));
        folder.setTargetDepartmentName(rs.getString("target_department_name"));
        folder.setTargetUserName(rs.getString("target_user_name"));
        folder.setTargetEmail(rs.getString("target_email"));
        folder.setToken(rs.getString("token"));
        folder.setCertIssuanceAllowed(rs.getBoolean("is_cert_issuance_allowed"));

        String status = rs.getString("status");
        folder.setStatus(status != null ? status : "DRAFT");

        folder.setUpdatedAt(rs.getTimestamp("updated_at"));
        int updatedBy = rs.getInt("updated_by");
        if (!rs.wasNull()) folder.setUpdatedBy(updatedBy);

        return folder;
    }
}