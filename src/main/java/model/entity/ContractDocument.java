package model.entity;

import java.sql.Timestamp; // 上部に追加

/**
 * 契約書データ（PDF等の代替データ）を表すエンティティクラス
 */
public class ContractDocument {

    private int documentId;
    private int folderId; // 所属するFolderのID（外部キー）
    private String title;
    private String content; // 契約書の本文データ
    private boolean isDeleted;
    private Timestamp deletedAt;
    private Integer deletedBy;
    
    // --- 電子署名用フィールド ---
    private String signatureData; // Base64エンコードされたRSA署名データ
    private String fileHash;      // PDFのSHA-256ハッシュ値（改ざん検証用）
    private Timestamp signedAt;   // 署名日時
    private Integer signedBy;     // 署名実行ユーザーID   
    
    // 1 = 初期・送信者署名時, 2 = 外部署名アップロード時（双方署名完了）
    private int version; 
    
    // 実際のファイルが保存されているパス
    private String filePath; 
    
    
    private String invitedSignatureData;
    private java.sql.Timestamp invitedSignedAt;
    private Integer invitedSignedBy;

    // デフォルトコンストラクタ
    public ContractDocument() {
    }

    // --- Getter / Setter ---

    public int getDocumentId() {
        return documentId;
    }

    public void setDocumentId(int documentId) {
        this.documentId = documentId;
    }

    public int getFolderId() {
        return folderId;
    }

    public void setFolderId(int folderId) {
        this.folderId = folderId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public int getVersion() {
        return version;
    }

    public void setVersion(int version) {
        this.version = version;
    }

    public String getFilePath() {
        return filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

	public boolean isDeleted() {
		return isDeleted;
	}

	public void setDeleted(boolean isDeleted) {
		this.isDeleted = isDeleted;
	}

	public Timestamp getDeletedAt() {
		return deletedAt;
	}

	public void setDeletedAt(Timestamp deletedAt) {
		this.deletedAt = deletedAt;
	}

	public Integer getDeletedBy() {
		return deletedBy;
	}

	public void setDeletedBy(Integer deletedBy) {
		this.deletedBy = deletedBy;
	}
	
	// --- 電子署名用　追加の Getter / Setter ---
    public String getSignatureData() { return signatureData; }
    public void setSignatureData(String signatureData) { this.signatureData = signatureData; }

    public String getFileHash() { return fileHash; }
    public void setFileHash(String fileHash) { this.fileHash = fileHash; }

    public Timestamp getSignedAt() { return signedAt; }
    public void setSignedAt(Timestamp signedAt) { this.signedAt = signedAt; }

    public Integer getSignedBy() { return signedBy; }
    public void setSignedBy(Integer signedBy) { this.signedBy = signedBy; }
    
    
    public String getInvitedSignatureData() { return invitedSignatureData; }
    public void setInvitedSignatureData(String invitedSignatureData) { this.invitedSignatureData = invitedSignatureData; }

    public java.sql.Timestamp getInvitedSignedAt() { return invitedSignedAt; }
    public void setInvitedSignedAt(java.sql.Timestamp invitedSignedAt) { this.invitedSignedAt = invitedSignedAt; }

    public Integer getInvitedSignedBy() { return invitedSignedBy; }
    public void setInvitedSignedBy(Integer invitedSignedBy) { this.invitedSignedBy = invitedSignedBy; }
}