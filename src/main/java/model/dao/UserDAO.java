package model.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import model.entity.User;

public class UserDAO {
    private final String URL = "jdbc:h2:./data/esign_db;AUTO_SERVER=TRUE";
    private final String USER = "sa";
    private final String PASS = "";

    /**
     * メールアドレスとパスワードでユーザーを検索する（ログイン認証）
     */
    public User findByEmailAndPassword(String email, String password) {
        User user = null;
        String sql = "SELECT * FROM users WHERE email = ? AND password = ?";
        String hashedPassword = util.PasswordUtil.hashPassword(password);
        
        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS);
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {

                pstmt.setString(1, email);
                pstmt.setString(2, hashedPassword);

                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        user = new User();
                        user.setUserId(rs.getInt("user_id"));
                        user.setEmail(rs.getString("email"));
                        user.setPassword(rs.getString("password"));
                        user.setUserName(rs.getString("user_name"));
                        user.setUserType(rs.getString("user_type"));
                        user.setPlanType(rs.getString("plan_type"));
                        user.setCertificatePath(rs.getString("certificate_path"));
                        
                        try {
                            user.setCompanyName(rs.getString("company_name"));
                        } catch (SQLException ignored) {
                        }
                    }
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
        return user;
    }
    
    /**
     * メールアドレスからユーザーを取得する（存在確認・重複チェック用）
     */
    public User findByEmail(String email) {
        String sql = "SELECT * FROM users WHERE email = ?";
        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS);
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {

                pstmt.setString(1, email);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        User user = new User();
                        user.setUserId(rs.getInt("user_id"));
                        user.setUserName(rs.getString("user_name"));
                        user.setEmail(rs.getString("email"));
                        user.setPassword(rs.getString("password"));
                        user.setUserType(rs.getString("user_type"));
                        user.setPlanType(rs.getString("plan_type"));
                        user.setCertificatePath(rs.getString("certificate_path"));
                        
                        try {
                            user.setCompanyName(rs.getString("company_name"));
                        } catch (SQLException ignored) {
                        }
                        return user;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * 新規ユーザーを登録する（userType, planType の指定を反映）
     */
    public boolean registerUser(User user) {
        String createTableSql = "CREATE TABLE IF NOT EXISTS users ("
                + "user_id INT AUTO_INCREMENT PRIMARY KEY, "
                + "user_name VARCHAR(100), "
                + "company_name VARCHAR(255), "
                + "email VARCHAR(255) UNIQUE, "
                + "password VARCHAR(255), "
                + "user_type VARCHAR(50) DEFAULT 'GENERAL', "
                + "plan_type VARCHAR(50) DEFAULT 'FREE', "
                + "certificate_path VARCHAR(500)"
                + ")";

        String insertSql = "INSERT INTO users (user_name, email, password, user_type, plan_type) VALUES (?, ?, ?, ?, ?)";

        try {
            Class.forName("org.h2.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }

        try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {
            try (PreparedStatement createStmt = conn.prepareStatement(createTableSql)) {
                createStmt.execute();
            }

            try (PreparedStatement pstmt = conn.prepareStatement(insertSql)) {
                String hashedPassword = util.PasswordUtil.hashPassword(user.getPassword());
                String userType = (user.getUserType() != null && !user.getUserType().isEmpty()) ? user.getUserType() : "GENERAL";
                String planType = (user.getPlanType() != null && !user.getPlanType().isEmpty()) ? user.getPlanType() : "FREE";
            	
                pstmt.setString(1, user.getUserName());
                pstmt.setString(2, user.getEmail());
                pstmt.setString(3, hashedPassword);
                pstmt.setString(4, userType);
                pstmt.setString(5, planType);

                int result = pstmt.executeUpdate();
                return result > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * ユーザー情報を更新する
     */
    public boolean updateUser(User user) {
        String alterSql = "ALTER TABLE users ADD COLUMN IF NOT EXISTS company_name VARCHAR(255)";
        String updateSql = "UPDATE users SET user_name = ?, company_name = ?, email = ? WHERE user_id = ?";

        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {
                try (PreparedStatement alterStmt = conn.prepareStatement(alterSql)) {
                    alterStmt.execute();
                }

                try (PreparedStatement pstmt = conn.prepareStatement(updateSql)) {
                    pstmt.setString(1, user.getUserName());
                    pstmt.setString(2, user.getCompanyName());
                    pstmt.setString(3, user.getEmail());
                    pstmt.setInt(4, user.getUserId());
                    return pstmt.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * ユーザーに電子証明書ファイルのパスを紐づける
     */
    public boolean updateCertificatePath(int userId, String certificatePath) {
        String alterSql = "ALTER TABLE users ADD COLUMN IF NOT EXISTS certificate_path VARCHAR(500)";
        String updateSql = "UPDATE users SET certificate_path = ? WHERE user_id = ?";

        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {
                try (PreparedStatement alterStmt = conn.prepareStatement(alterSql)) {
                    alterStmt.execute();
                }
                try (PreparedStatement pstmt = conn.prepareStatement(updateSql)) {
                    pstmt.setString(1, certificatePath);
                    pstmt.setInt(2, userId);
                    return pstmt.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * ユーザーIDから証明書ファイルのパスを取得する
     */
    public String findCertificatePathByUserId(int userId) {
        String sql = "SELECT certificate_path FROM users WHERE user_id = ?";
        try {
            Class.forName("org.h2.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USER, PASS);
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, userId);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        return rs.getString("certificate_path");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}