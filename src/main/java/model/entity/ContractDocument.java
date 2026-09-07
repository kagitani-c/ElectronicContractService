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
    
    // 1 = 初期・送信者署名時, 2 = 外部署名アップロード時（双方署名完了）
    private int version; 
    
    // 実際のファイルが保存されているパス
    private String filePath; 

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
    
}