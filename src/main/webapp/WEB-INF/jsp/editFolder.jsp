<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<html>
<head>
    <title>フォルダ情報の変更</title>
</head>
<body>
    <h2>契約フォルダ情報の変更</h2>

    <form action="EditFolderServlet" method="POST">
        <input type="hidden" name="folderId" value="${folder.folderId}">

        <table border="1">
            <tr>
                <th>フォルダ名（必須）</th>
                <td><input type="text" name="folderName" value="${folder.folderName}" required></td>
            </tr>
            <tr>
                <th>宛先企業名</th>
                <td><input type="text" name="companyName" value="${folder.targetCompanyName}"></td>
            </tr>
            <tr>
                <th>宛先部署名</th>
                <td><input type="text" name="departmentName" value="${folder.targetDepartmentName}"></td>
            </tr>
            <tr>
                <th>担当者名</th>
                <td><input type="text" name="userName" value="${folder.targetUserName}"></td>
            </tr>
            <tr>
                <th>メールアドレス</th>
                <td><input type="email" name="email" value="${folder.targetEmail}"></td>
            </tr>
            <tr>
                <th>証明書発行の許可</th>
                <td>
                    <input type="radio" name="allowCert" value="true" 
                        <c:if test="${folder.certIssuanceAllowed}">checked</c:if>> 許可する
                    <input type="radio" name="allowCert" value="false" 
                        <c:if test="${!folder.certIssuanceAllowed}">checked</c:if>> 許可しない
                </td>
            </tr>
        </table>
        <br>
        <button type="submit">変更を保存する</button>
    </form>

    <br>
    <a href="FolderDetailServlet?id=${folder.folderId}">キャンセルして戻る</a>
</body>
</html>