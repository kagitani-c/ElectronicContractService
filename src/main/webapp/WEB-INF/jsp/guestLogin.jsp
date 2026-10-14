<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>契約書類の確認・ログイン</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background-color: #f4f6f9; margin: 0; padding: 40px 20px; color: #333; }
        .card { max-width: 550px; margin: 0 auto; background: #fff; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.08); padding: 35px; }
        h2 { margin-top: 0; color: #007bff; font-size: 22px; border-bottom: 2px solid #007bff; padding-bottom: 12px; }
        .info-box { background-color: #e9ecef; border-radius: 6px; padding: 15px 20px; margin: 20px 0; font-size: 14px; line-height: 1.6; }
        .form-group { margin-bottom: 20px; }
        label { display: block; font-weight: bold; margin-bottom: 8px; font-size: 14px; }
        input[type="text"], input[type="password"] { width: 100%; padding: 10px 12px; border: 1px solid #ced4da; border-radius: 4px; box-sizing: border-box; font-size: 15px; }
        input[readonly] { background-color: #e9ecef; cursor: not-allowed; }
        .submit-btn { width: 100%; padding: 12px; background-color: #28a745; color: white; border: none; border-radius: 4px; font-size: 16px; font-weight: bold; cursor: pointer; transition: background 0.2s; }
        .submit-btn:hover { background-color: #218838; }
        .error-msg { color: #dc3545; background: #ffebee; padding: 10px; border-radius: 4px; margin-bottom: 20px; font-weight: bold; font-size: 14px; }
        .note { font-size: 12px; color: #6c757d; margin-top: 15px; line-height: 1.5; }
    </style>
</head>
<body>

<div class="card">
    <h2>電子契約の確認・ログイン</h2>

    <c:if test="${not empty errorMessage}">
        <div class="error-msg">⚠ ${errorMessage}</div>
    </c:if>

    <c:choose>
        <c:when test="${not empty folder}">
            <div class="info-box">
                <strong>契約フォルダ名:</strong> ${folder.folderName}<br>
                <strong>宛先企業名:</strong> ${folder.targetCompanyName}<br>
                <strong>宛先担当者名:</strong> ${folder.targetUserName} 様
            </div>

            <form action="GuestLoginServlet" method="POST">
                <input type="hidden" name="token" value="${folder.token}">

                <div class="form-group">
                    <label>招待先メールアドレス</label>
                    <input type="text" value="${folder.targetEmail}" readonly>
                </div>

                <div class="form-group">
                    <label for="password">パスワード</label>
                    <input type="password" id="password" name="password" placeholder="パスワードを入力してください" required autofocus>
                </div>

                <button type="submit" class="submit-btn">契約内容を確認する</button>

                <div class="note">
                    ※ 初めてご利用の場合は、入力したパスワードでアカウントが自動作成されます。<br>
                    ※ 既にアカウントをお持ちの場合は、ご登録時のパスワードを入力してください。
                </div>
            </form>
        </c:when>
        <c:otherwise>
            <p style="color: #666;">契約情報が見つかりませんでした。送信元にURLを再度ご確認ください。</p>
            <a href="Login" style="color: #007bff;">ログイン画面へ</a>
        </c:otherwise>
    </c:choose>
</div>

</body>
</html>