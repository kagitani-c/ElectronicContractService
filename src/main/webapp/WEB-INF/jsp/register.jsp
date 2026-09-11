<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>新規アカウント登録 - ElectronicContractService</title>
<style>
  body { font-family: sans-serif; margin: 40px; background-color: #f4f6f9; }
  .card { max-width: 400px; margin: 0 auto; background: #fff; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
  h2 { text-align: center; margin-bottom: 20px; color: #333; }
  .form-group { margin-bottom: 15px; }
  label { display: block; margin-bottom: 5px; font-weight: bold; font-size: 14px; }
  input[type="text"], input[type="email"], input[type="password"] {
    width: 100%; padding: 10px; box-sizing: border-box; border: 1px solid #ccc; border-radius: 4px;
  }
  button { width: 100%; padding: 10px; background-color: #007bff; color: white; border: none; border-radius: 4px; font-size: 16px; cursor: pointer; margin-top: 10px; }
  button:hover { background-color: #0056b3; }
  .error-msg { color: #dc3545; font-size: 14px; margin-bottom: 15px; text-align: center; }
  .link-area { text-align: center; margin-top: 15px; font-size: 14px; }
</style>
</head>
<body>

<div class="card">
  <h2>新規アカウント登録</h2>

  <% String errorMsg = (String) request.getAttribute("errorMsg"); %>
  <% if (errorMsg != null) { %>
    <div class="error-msg"><%= errorMsg %></div>
  <% } %>

  <form action="<%= request.getContextPath() %>/Register" method="post">
    <div class="form-group">
      <label for="name">お名前</label>
      <input type="text" id="name" name="name" required placeholder="山田 太郎">
    </div>
    <div class="form-group">
      <label for="email">メールアドレス</label>
      <input type="email" id="email" name="email" required placeholder="test@example.com">
    </div>
    <div class="form-group">
      <label for="password">パスワード</label>
      <input type="password" id="password" name="password" required placeholder="パスワードを入力">
    </div>
    <button type="submit">アカウントを作成する</button>
  </form>

  <div class="link-area">
    <a href="<%= request.getContextPath() %>/Login">ログイン画面へ戻る</a>
  </div>
</div>

</body>
</html>