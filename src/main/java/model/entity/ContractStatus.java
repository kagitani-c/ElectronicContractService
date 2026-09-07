package model.entity;

import java.sql.Timestamp;

/**
 * 契約管理フォルダの現在のステータスを表すエンティティクラス
 */
public class ContractStatus {

    private int folderId; // 主キー 兼 Folderの外部キー
    
    // "SHARED", "WAITING_EXT_UPLOAD", "WAITING_CERT_REG", "WAITING_SIGN", "COMPLETED" など
    private String status; 
    
    // ステータスが最後に更新された日時
    private Timestamp updatedAt; 

    // デフォルトコンストラクタ
    public ContractStatus() {
    }

    // --- Getter / Setter ---

    public int getFolderId() {
        return folderId;
    }

    public void setFolderId(int folderId) {
        this.folderId = folderId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}