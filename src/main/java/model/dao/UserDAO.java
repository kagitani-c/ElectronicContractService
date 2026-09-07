package model.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import model.entity.User;

public class UserDAO {
    // ※URLはご自身の環境に合わせてください（;AUTO_SERVER=TRUE を推奨）
    private final String URL = "jdbc:h2:C:/data/esign_db;AUTO_SERVER=TRUE";
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
}