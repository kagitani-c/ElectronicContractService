<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<html>
<head>
    <title>契約管理フォルダ一覧</title>
</head>
<body>
    <h2>マイページ：フォルダ一覧</h2>

    <c:if test="${loginUser.planType == 'PREMIUM'}">
        <button style="background-color: gold;">【上位プラン限定】電子証明書の発行を管理する</button>
    </c:if>

    <table border="1">
        <tr>
            <th>フォルダID</th>
            <th>フォルダ名</th>
            <th>宛先企業名</th>
            <th>立場</th>
        </tr>
        
        <c:forEach var="folder" items="${folderList}">
            <tr>
                <td>${folder.folderId}</td>
                <td><a href="FolderDetailServlet?id=${folder.folderId}">${folder.folderName}</a></td>
                <td>${folder.targetCompanyName}</td>
                <td>
                    <c:choose>
                        <c:when test="${folder.createdBy == loginUser.userId}">
                            送信者
                        </c:when>
                        <c:otherwise>
                            受信者（署名者）
                        </c:otherwise>
                    </c:choose>
                </td>
            </tr>
        </c:forEach>
    </table>

    <br>
    <a href="createFolder.jsp">新規フォルダ作成</a>
</body>
</html>