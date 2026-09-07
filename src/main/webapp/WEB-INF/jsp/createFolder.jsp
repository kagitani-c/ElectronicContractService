<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>新規フォルダ作成</title>
</head>
<body>
    <h2>新規契約フォルダの作成</h2>

    <form action="CreateFolderServlet" method="POST">
        <table border="1">
            <tr>
                <th>フォルダ名（必須）</th>
                <td><input type="text" name="folderName" required></td>
            </tr>
            <tr>
                <th>宛先企業名</th>
                <td><input type="text" name="companyName"></td>
            </tr>
            <tr>
                <th>宛先部署名</th>
                <td><input type="text" name="departmentName"></td>
            </tr>
            <tr>
                <th>担当者名</th>
                <td><input type="text" name="userName"></td>
            </tr>
            <tr>
                <th>メールアドレス</th>
                <td><input type="email" name="email"></td>
            </tr>
            <tr>
                <th>証明書発行の許可</th>
                <td>
                    <input type="radio" name="allowCert" value="true"> 許可する
                    <input type="radio" name="allowCert" value="false" checked> 許可しない
                </td>
            </tr>
        </table>
        <br>
        <button type="submit">フォルダを作成する</button>
    </form>

    <br>
    <a href="FolderListServlet">一覧へ戻る</a>
</body>
</html>