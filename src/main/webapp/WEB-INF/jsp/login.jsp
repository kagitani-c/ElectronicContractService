<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>ログイン - 電子契約システム</title>
</head>
<body>
    <h2>電子契約システムへログイン</h2>

    <p style="color: red;">${errorMsg}</p>

    <form action="LoginServlet" method="POST">
        <table border="0">
            <tr>
                <th>メールアドレス:</th>
                <td><input type="email" name="email" required></td>
            </tr>
            <tr>
                <th>パスワード:</th>
                <td><input type="password" name="password" required></td>
            </tr>
        </table>
        <br>
        <button type="submit">ログインする</button>
    </form>
</body>
</html>