<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<html>
<head>
    <title>フォルダ詳細 - ${folder.folderName}</title>
</head>
<body>
    <h2>契約フォルダ詳細</h2>

    <table border="1">
        <tr>
            <th>フォルダID</th>
            <td>${folder.folderId}</td>
        </tr>
        <tr>
            <th>フォルダ名</th>
            <td>${folder.folderName}</td>
        </tr>
        <tr>
            <th>宛先企業名</th>
            <td>${folder.targetCompanyName}</td>
        </tr>
        <tr>
            <th>宛先部署名</th>
            <td>${folder.targetDepartmentName}</td>
        </tr>
        <tr>
            <th>担当者名</th>
            <td>${folder.targetUserName}</td>
        </tr>
        <tr>
            <th>メールアドレス</th>
            <td>${folder.targetEmail}</td>
        </tr>
        <tr>
            <th>電子証明書発行の許可</th>
            <td>
                <c:choose>
                    <c:when test="${folder.certIssuanceAllowed}">許可する</c:when>
                    <c:otherwise>許可しない</c:otherwise>
                </c:choose>
            </td>
        </tr>
        <tr>
            <th>招待用 URL（トークン付き）</th>
            <td>
                http://localhost:8080/ElectronicContractService/GuestLoginServlet?token=${folder.token}
            </td>
        </tr>
    </table>
   	<c:if test="${not empty folder.updatedAt}">
        <p style="font-size: 0.8em; color: gray;">
            最終更新: ${folder.updatedAt} (更新者ID: ${folder.updatedBy})
        </p>
    </c:if>
        <a href="EditFolderServlet?id=${folder.folderId}">[契約フォルダ情報を変更する]</a>
    <br>
    <p style="font-size: 0.8em; color: gray;">
    	フォルダ情報の変更履歴
	</p>
    <c:if test="${not empty historyList}">
        <table border="1" style="font-size: 0.8em; color: gray; background-color: #f9f9f9;">
            <tr>
                <th>変更日時</th>
                <th>変更者ID</th>
                <th>フォルダ名</th>
                <th>宛先企業名</th>
                <th>宛先部署名</th>
                <th>担当者名</th>
                <th>メールアドレス</th>
            </tr>
            <c:forEach var="history" items="${historyList}">
                <tr>
                    <td>${history.changedAt}</td>
                    <td>${history.changedBy}</td>
                    <td>${history.folderName}</td>
                    <td>${history.targetCompanyName}</td>
                    <td>${history.targetDepartmentName}</td>
                    <td>${history.targetUserName}</td>
                    <td>${history.targetEmail}</td>
                </tr>
            </c:forEach>
        </table>
    </c:if>
    <c:if test="${empty historyList}">
        <p style="font-size: 0.8em; color: gray;">※ 変更履歴はまだありません。</p>
    </c:if>
    

	<br><hr>
    <h3>契約書PDFのアップロード</h3>
    
    <form action="UploadPdfServlet" method="POST" enctype="multipart/form-data">
        
        <input type="hidden" name="folderId" value="${folder.folderId}">
        
        <input type="file" name="pdfFile" accept="application/pdf" required>
        <button type="submit">アップロード</button>
        
    </form>


    <hr>
	<h3>登録済みの契約書データ</h3>
    
    <c:if test="${not empty documentList}">
        <table border="1">
            <tr>
                <th>ファイル名</th>
                <th>バージョン</th>
                <th>操作</th>
            </tr>
            <c:forEach var="doc" items="${documentList}">
                <tr>
                    <td>${doc.title}</td>
                    <td>第 ${doc.version} 版</td>
                    <td>
                        <a href="ViewPdfServlet?docId=${doc.documentId}" target="_blank">📄 閲覧する</a>
                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${doc.deleted}">
                                <span style="color: red; font-size: 0.9em;">
                                    [削除済み] 削除日時: ${doc.deletedAt} (操作ユーザーID: ${doc.deletedBy})
                                </span>
                            </c:when>
                            <c:otherwise>
                                    <form action="DeletePdfServlet" method="POST" style="display:inline;">
                                    <input type="hidden" name="docId" value="${doc.documentId}">
                                    <input type="hidden" name="folderId" value="${folder.folderId}">
                                    <button type="submit" onclick="return confirm('本当に削除しますか？');">🗑️ 削除</button>
                                </form>
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </c:forEach>
        </table>
    </c:if>
    <c:if test="${empty documentList}">
        <p>※ まだ契約書がアップロードされていません。</p>
    </c:if>
    
    <br><hr><br>

    <br><br>
    <a href="FolderListServlet">← フォルダ一覧へ戻る</a>
</body>
</html>