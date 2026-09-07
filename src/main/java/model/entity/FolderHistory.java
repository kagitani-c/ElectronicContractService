package model.entity;

import java.sql.Timestamp;

public class FolderHistory {
    private int historyId;
    private int folderId;
    private String folderName;
    private String targetCompanyName;
    private String targetDepartmentName;
    private String targetUserName;
    private String targetEmail;
    private boolean isCertIssuanceAllowed;
    private Timestamp changedAt;
    private int changedBy;
    
    // ※右クリック → ソース → GetterおよびSetterの生成 を実行して、
    // すべてのフィールドのGetter/Setterを追加してください。

	public int getHistoryId() {
		return historyId;
	}
	public void setHistoryId(int historyId) {
		this.historyId = historyId;
	}
	public int getFolderId() {
		return folderId;
	}
	public void setFolderId(int folderId) {
		this.folderId = folderId;
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
	public boolean isCertIssuanceAllowed() {
		return isCertIssuanceAllowed;
	}
	public void setCertIssuanceAllowed(boolean isCertIssuanceAllowed) {
		this.isCertIssuanceAllowed = isCertIssuanceAllowed;
	}
	public Timestamp getChangedAt() {
		return changedAt;
	}
	public void setChangedAt(Timestamp changedAt) {
		this.changedAt = changedAt;
	}
	public int getChangedBy() {
		return changedBy;
	}
	public void setChangedBy(int changedBy) {
		this.changedBy = changedBy;
	}

}