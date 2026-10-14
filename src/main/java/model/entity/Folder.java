package model.entity;

import java.sql.Timestamp; // 上部に追加

/**
 * 契約管理フォルダを表すエンティティクラス（DTO / JavaBean）
 * DBの「Folder」テーブルの1レコード分のデータを保持します。
 */
public class Folder {

    // -----------------------------------------------------
    // 1. フィールド定義（カプセル化のためすべて private）
    // -----------------------------------------------------
    private int folderId;
    private int createdBy;
    private Integer invitedUserId; // 未招待（Null）を許容するため、intではなくラッパークラスのIntegerを使用
    private String folderName;
    private String targetCompanyName;
    private String targetDepartmentName; // クラス図で定義していた宛先部署名
    private String targetUserName;
    private String targetEmail;
    private String token;
    private boolean isCertIssuanceAllowed;
    

	private Timestamp updatedAt;
    private Integer updatedBy; // Nullを許容するためInteger
    
    // Folder.java への追加分
    private String status; // DRAFT, WAITING_SIGN, COMPLETED

    // -----------------------------------------------------
    // 2. コンストラクタ
    // -----------------------------------------------------
    // 引数なしのデフォルトコンストラクタ（JavaBeansの仕様として必須）
    public Folder() {
    }

    // -----------------------------------------------------
    // 3. Getter / Setter メソッド
    // -----------------------------------------------------
    
    public int getFolderId() {
        return folderId;
    }

    public void setFolderId(int folderId) {
        this.folderId = folderId;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public Integer getInvitedUserId() {
        return invitedUserId;
    }

    public void setInvitedUserId(Integer invitedUserId) {
        this.invitedUserId = invitedUserId;
    }

    public String getFolderName() {
        return folderName;
    }

    public void setFolderName(String folderName) {
        this.folderName = folderName;
    }

    public String getTargetCompanyName() {
        return targetCompanyName;
    }

    public void setTargetCompanyName(String targetCompanyName) {
        this.targetCompanyName = targetCompanyName;
    }

    public String getTargetDepartmentName() {
        return targetDepartmentName;
    }

    public void setTargetDepartmentName(String targetDepartmentName) {
        this.targetDepartmentName = targetDepartmentName;
    }

    public String getTargetUserName() {
        return targetUserName;
    }

    public void setTargetUserName(String targetUserName) {
        this.targetUserName = targetUserName;
    }

    public String getTargetEmail() {
        return targetEmail;
    }

    public void setTargetEmail(String targetEmail) {
        this.targetEmail = targetEmail;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    // boolean型のgetterは「get～」ではなく「is～」とするのがJavaの一般的な慣習です
    public boolean isCertIssuanceAllowed() {
        return isCertIssuanceAllowed;
    }

    public void setCertIssuanceAllowed(boolean certIssuanceAllowed) {
        isCertIssuanceAllowed = certIssuanceAllowed;
    }
    
    public Timestamp getUpdatedAt() {
		return updatedAt;
	}

	public void setUpdatedAt(Timestamp updatedAt) {
		this.updatedAt = updatedAt;
	}

	public Integer getUpdatedBy() {
		return updatedBy;
	}

	public void setUpdatedBy(Integer updatedBy) {
		this.updatedBy = updatedBy;
	}
	
	public String getStatus() {
		return status;
	
	}
    public void setStatus(String status) {
    	this.status = status;
    }

}