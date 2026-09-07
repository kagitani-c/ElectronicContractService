package model.entity;

/**
 * ユーザー情報を表すエンティティクラス
 */
public class User {

    private int userId;
    private String email;
    private String password;
    private String userName;
    
    // "REGISTERED" (登録ユーザー), "INVITED" (招待ユーザー)
    private String userType; 
    
    // "PREMIUM" (上位プラン), "LIGHT" (下位プラン), "NONE" (未契約/招待ユーザー)
    private String planType; 
    
    // アップロードされたダミーTXTのファイルパス（未登録時はNull）
    private String certificatePath; 

    // デフォルトコンストラクタ
    public User() {
    }

    // --- Getter / Setter ---

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserType() {
        return userType;
    }

    public void setUserType(String userType) {
        this.userType = userType;
    }

    public String getPlanType() {
        return planType;
    }

    public void setPlanType(String planType) {
        this.planType = planType;
    }

    public String getCertificatePath() {
        return certificatePath;
    }

    public void setCertificatePath(String certificatePath) {
        this.certificatePath = certificatePath;
    }
}