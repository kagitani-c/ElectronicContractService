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
	// 変更後（H2用）
    private final String URL = "jdbc:h2:file:C:/data/esign_db;AUTO_SERVER=TRUE";
    private final String USER = "sa";
    private final String PASS = ""; // パスワードは空欄なので空文字

    /**
     * ユーザーIDをキーにして、関連する全フォルダを取得する
     */
    public List<Folder> getFoldersByUserId(int currentUserId) {
        List<Folder> folderList = new ArrayList<>();
        
        // 面接ドヤ顔ポイント：OR条件を使って送信分と受信分（引き継ぎデータ）を一度に取得
        String sql = "SELECT * FROM folder WHERE created_by = ? OR invited_user_id = ?";

        try {
            // ここでドライバを読み込みます（ここでtryの中にいれるのが正解！）
            Class.forName("org.h2.Driver");
        
	        try (Connection conn = DriverManager.getConnection(URL, USER, PASS);
	             PreparedStatement pstmt = conn.prepareStatement(sql)) {
	
	            pstmt.setInt(1, currentUserId);
	            pstmt.setInt(2, currentUserId);
	
	            try (ResultSet rs = pstmt.executeQuery()) {
	                while (rs.next()) {
	                    Folder folder = new Folder();
	                    folder.setFolderId(rs.getInt("folder_id"));
	                    folder.setCreatedBy(rs.getInt("created_by"));
	                    
	                    // invitedUserIdはNullの可能性があるため、チェックしてセット
	                    int invitedId = rs.getInt("invited_user_id");
	                    if (!rs.wasNull()) {
	                        folder.setInvitedUserId(invitedId);
	                    }
	                    
	                    folder.setFolderName(rs.getString("folder_name"));
	                    // ※その他のフィールドもrsから取得してセット（省略）
	                    
	                    folderList.add(folder);
	                }
	            }
            
	        }
        }catch (ClassNotFoundException e) {
            System.out.println("H2ドライバが見つかりません: " + e.getMessage());
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return folderList;
    }
    
    /**
     * 新規フォルダをデータベースに登録する（INSERT処理）
     * @param folder 登録するフォルダ情報が詰まったエンティティ
     * @return 登録成功時に自動採番された folder_id (失敗時は -1)
     */
    public int insertFolder(Folder folder) {
        // プロのテクニック①：プレースホルダ（?）を使ってSQLインジェクションを防ぐ
        String sql = "INSERT INTO folder "
                   + "(created_by, invited_user_id, folder_name, target_company_name, target_department_name, target_user_name, target_email, token, is_cert_issuance_allowed) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        int generatedId = -1; // 成功したかどうか、及び採番されたIDを返すための変数

        try {
            Class.forName("org.h2.Driver");
            
            // プロのテクニック②：Statement.RETURN_GENERATED_KEYS で自動採番されたIDを取得する
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS);
                 PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

                // 1. 各「?」に実際のデータをセットしていく
                pstmt.setInt(1, folder.getCreatedBy());
                
                // invitedUserId は Null の可能性があるため、分岐処理を入れる
                if (folder.getInvitedUserId() != null) {
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

                // 2. SQLを実行（executeUpdate は書き換えられた行数を返す。成功なら1）
                int affectedRows = pstmt.executeUpdate();

                // 3. 成功した場合、H2データベースが自動で割り振った「folder_id」を取得する
                if (affectedRows > 0) {
                    try (ResultSet rs = pstmt.getGeneratedKeys()) {
                        if (rs.next()) {
                            generatedId = rs.getInt(1); // 1番目のカラム（folder_id）を取得
                        }
                    }
                }
            }
        } catch (ClassNotFoundException e) {
            System.out.println("H2ドライバが見つかりません: " + e.getMessage());
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return generatedId;
    }
    
    /**
     * フォルダIDを指定して、1件のフォルダ情報を取得する
     */
    public Folder getFolderById(int folderId) {
        Folder folder = null;
        String sql = "SELECT * FROM folder WHERE folder_id = ?";

        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS);
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {

                // ? に folderId をセット
                pstmt.setInt(1, folderId);

                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        folder = new Folder();
                        folder.setFolderId(rs.getInt("folder_id"));
                        folder.setCreatedBy(rs.getInt("created_by"));
                        
                        int invitedId = rs.getInt("invited_user_id");
                        if (!rs.wasNull()) {
                            folder.setInvitedUserId(invitedId);
                        }
                        
                        folder.setFolderName(rs.getString("folder_name"));
                        folder.setTargetCompanyName(rs.getString("target_company_name"));
                        folder.setTargetDepartmentName(rs.getString("target_department_name"));
                        folder.setTargetUserName(rs.getString("target_user_name"));
                        folder.setTargetEmail(rs.getString("target_email"));
                        folder.setToken(rs.getString("token"));
                        folder.setCertIssuanceAllowed(rs.getBoolean("is_cert_issuance_allowed"));
                     // ↓↓↓ ここから追加 ↓↓↓
                        // 更新日時を取得
                        folder.setUpdatedAt(rs.getTimestamp("updated_at"));
                        
                        // 更新者IDを取得（Nullの可能性を考慮した安全な書き方）
                        int updatedBy = rs.getInt("updated_by");
                        if (!rs.wasNull()) {
                            folder.setUpdatedBy(updatedBy);
                        }
                        // ↑↑↑ ここまで追加 ↑↑↑
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return folder;
    }
    
    /**
     * フォルダ情報を更新し、同時に履歴テーブルに変更内容を記録する（トランザクション処理）
     */
    public boolean updateFolder(Folder folder) {
        String updateSql = "UPDATE folder SET folder_name = ?, target_company_name = ?, target_department_name = ?, target_user_name = ?, target_email = ?, is_cert_issuance_allowed = ?, updated_at = CURRENT_TIMESTAMP, updated_by = ? WHERE folder_id = ?";
        
        String historySql = "INSERT INTO folder_history (folder_id, folder_name, target_company_name, target_department_name, target_user_name, target_email, is_cert_issuance_allowed, changed_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {
                
                // ★プロの技：自動保存をオフにしてトランザクションを開始する
                conn.setAutoCommit(false);
                
                try (PreparedStatement pstmt1 = conn.prepareStatement(updateSql);
                     PreparedStatement pstmt2 = conn.prepareStatement(historySql)) {
                    
                    // 1. 本体の更新 (UPDATE)
                    pstmt1.setString(1, folder.getFolderName());
                    pstmt1.setString(2, folder.getTargetCompanyName());
                    pstmt1.setString(3, folder.getTargetDepartmentName());
                    pstmt1.setString(4, folder.getTargetUserName());
                    pstmt1.setString(5, folder.getTargetEmail());
                    pstmt1.setBoolean(6, folder.isCertIssuanceAllowed());
                    pstmt1.setInt(7, folder.getUpdatedBy());
                    pstmt1.setInt(8, folder.getFolderId());
                    pstmt1.executeUpdate();

                    // 2. 履歴の保存 (INSERT)
                    pstmt2.setInt(1, folder.getFolderId());
                    pstmt2.setString(2, folder.getFolderName());
                    pstmt2.setString(3, folder.getTargetCompanyName());
                    pstmt2.setString(4, folder.getTargetDepartmentName());
                    pstmt2.setString(5, folder.getTargetUserName());
                    pstmt2.setString(6, folder.getTargetEmail());
                    pstmt2.setBoolean(7, folder.isCertIssuanceAllowed());
                    pstmt2.setInt(8, folder.getUpdatedBy());
                    pstmt2.executeUpdate();

                    // 3. 両方成功したら、ここで確定（コミット）する
                    conn.commit();
                    return true;
                    
                } catch (Exception e) {
                    // 途中で失敗したら、変更を無かったことにする（ロールバック）
                    conn.rollback();
                    e.printStackTrace();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    

    /**
     * 指定したフォルダの変更履歴を新しい順に取得する
     */
    public List<FolderHistory> getFolderHistories(int folderId) {
        List<FolderHistory> list = new ArrayList<>();
        // changed_at DESC で新しい履歴が上に来るように並び替えます
        String sql = "SELECT * FROM folder_history WHERE folder_id = ? ORDER BY changed_at DESC";

        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS);
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {

                pstmt.setInt(1, folderId);
                try (ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) {
                        FolderHistory h = new FolderHistory();
                        h.setHistoryId(rs.getInt("history_id"));
                        h.setFolderId(rs.getInt("folder_id"));
                        h.setFolderName(rs.getString("folder_name"));
                        h.setTargetCompanyName(rs.getString("target_company_name"));
                        h.setTargetDepartmentName(rs.getString("target_department_name"));
                        h.setTargetUserName(rs.getString("target_user_name"));
                        h.setTargetEmail(rs.getString("target_email"));
                        h.setCertIssuanceAllowed(rs.getBoolean("is_cert_issuance_allowed"));
                        h.setChangedAt(rs.getTimestamp("changed_at"));
                        h.setChangedBy(rs.getInt("changed_by"));
                        list.add(h);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}