package model.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import model.entity.User;

public class UserDAO {
    // ※URLはご自身の環境に合わせてください（;AUTO_SERVER=TRUE を推奨）
    private final String URL = "jdbc:h2:./data/esign_db;AUTO_SERVER=TRUE";
    private final String USER = "sa";
    private final String PASS = "";

    /**
     * メールアドレスとパスワードでユーザーを検索する（ログイン認証）
     */
    public User findByEmailAndPassword(String email, String password) {
        User user = null; // 見つからなかった場合はnullを返す
        
        // パスワードも一致するかをDB側でチェックするSQL
        String sql = "SELECT * FROM users WHERE email = ? AND password = ?";

        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS);
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {

                pstmt.setString(1, email);
                pstmt.setString(2, password);

                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        // データが見つかったら（認証成功）、Userエンティティに詰め込む
                        user = new User();
                        user.setUserId(rs.getInt("user_id"));
                        user.setEmail(rs.getString("email"));
                        user.setPassword(rs.getString("password"));
                        user.setUserName(rs.getString("user_name"));
                        user.setUserType(rs.getString("user_type"));
                        user.setPlanType(rs.getString("plan_type"));
                    }
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
        return user;
    }
    
/**
     * 新規ユーザーを登録する（USERSテーブルが存在しない場合は自動作成）
     */
    public boolean registerUser(User user) {
        // 1. カラム名を既存の設計（user_id, user_name, user_type, plan_type）に完全一致させる
        String createTableSql = "CREATE TABLE IF NOT EXISTS users ("
                + "user_id INT AUTO_INCREMENT PRIMARY KEY, "
                + "user_name VARCHAR(100), "
                + "email VARCHAR(255) UNIQUE, "
                + "password VARCHAR(255), "
                + "user_type VARCHAR(50) DEFAULT 'GENERAL', "
                + "plan_type VARCHAR(50) DEFAULT 'FREE'"
                + ")";

        // 2. ユーザー登録用SQL（name ではなく user_name を指定）
        String insertSql = "INSERT INTO users (user_name, email, password, user_type, plan_type) VALUES (?, ?, ?, 'GENERAL', 'FREE')";

        // H2ドライバの明示的ロード
        try {
            Class.forName("org.h2.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }

        try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {
            
            // テーブルがなければ自動生成
            try (PreparedStatement createStmt = conn.prepareStatement(createTableSql)) {
                createStmt.execute();
            }

            // ユーザーデータを挿入
            try (PreparedStatement pstmt = conn.prepareStatement(insertSql)) {
                pstmt.setString(1, user.getUserName());
                pstmt.setString(2, user.getEmail());
                pstmt.setString(3, user.getPassword());

                int result = pstmt.executeUpdate();
                return result > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}