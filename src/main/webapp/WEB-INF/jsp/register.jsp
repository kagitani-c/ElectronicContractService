<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>新規アカウント登録 - 電子契約サービス</title>
    <style>
        :root {
            --primary: #0284c7;
            --primary-hover: #0369a1;
            --sidebar-bg: #0f172a;
            --sidebar-text: #94a3b8;
            --sidebar-active: #38bdf8;
            --sidebar-hover-bg: #1e293b;
            --bg-page: #f8fafc;
            --card-bg: #ffffff;
            --text-main: #1e293b;
            --text-sub: #64748b;
            --border: #e2e8f0;
            --danger: #dc2626;
            --danger-bg: #fee2e2;
            --success: #16a34a;
            --success-bg: #dcfce7;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            min-height: 100vh;
            display: flex;
            background-color: var(--sidebar-bg);
            color: var(--text-main);
        }

        .layout {
            display: flex;
            width: 100vw;
            min-height: 100vh;
        }

        /* 左側：ブランド・技術仕様パネル */
        .brand-panel {
            flex: 1.1;
            background-color: var(--sidebar-bg);
            color: #f8fafc;
            padding: 60px 48px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            border-right: 1px solid #334155;
            position: relative;
            overflow: hidden;
        }

        .brand-panel::after {
            content: "";
            position: absolute;
            bottom: -80px;
            right: -80px;
            width: 320px;
            height: 320px;
            background: radial-gradient(circle, rgba(56, 189, 248, 0.08) 0%, transparent 70%);
            pointer-events: none;
        }

        .brand-header {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 20px;
            font-weight: 700;
            letter-spacing: 0.5px;
        }

        .brand-body {
            max-width: 480px;
        }

        .brand-title {
            font-size: 28px;
            font-weight: 700;
            line-height: 1.35;
            margin-bottom: 16px;
            color: #f8fafc;
        }

        .brand-title span {
            color: var(--sidebar-active);
        }

        .brand-desc {
            font-size: 14.5px;
            color: var(--sidebar-text);
            line-height: 1.6;
            margin-bottom: 32px;
        }

        .feature-list {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 14px;
        }

        .feature-item {
            display: flex;
            align-items: flex-start;
            gap: 12px;
            font-size: 13.5px;
            color: #cbd5e1;
        }

        .feature-icon {
            color: var(--sidebar-active);
            font-weight: 700;
            line-height: 1.4;
        }

        .brand-footer {
            font-size: 12px;
            color: #64748b;
        }

        /* 右側：新規登録フォームパネル */
        .form-panel {
            flex: 0.9;
            background-color: var(--bg-page);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 32px;
        }

        .form-container {
            width: 100%;
            max-width: 400px;
        }

        .form-header {
            margin-bottom: 28px;
        }

        .form-title {
            font-size: 24px;
            font-weight: 700;
            color: var(--text-main);
            margin-bottom: 6px;
        }

        .form-subtitle {
            font-size: 13px;
            color: var(--text-sub);
        }

        /* アラートバナー */
        .alert {
            padding: 12px 14px;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 20px;
        }
        .alert-danger {
            background: var(--danger-bg);
            color: var(--danger);
            border: 1px solid #fca5a5;
        }
        .alert-success {
            background: var(--success-bg);
            color: var(--success);
            border: 1px solid #86efac;
            margin-top: 18px;
            margin-bottom: 0;
            line-height: 1.5;
            text-align: center;
        }

        /* フォームグループ */
        .form-group {
            margin-bottom: 18px;
        }

        .form-label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: var(--text-main);
            margin-bottom: 6px;
        }

        .form-control {
            width: 100%;
            padding: 11px 13px;
            font-size: 14px;
            border: 1px solid var(--border);
            border-radius: 6px;
            background: #ffffff;
            color: var(--text-main);
            transition: border-color 0.2s, box-shadow 0.2s;
        }

        .form-control:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(2, 132, 199, 0.15);
        }

        .form-control:disabled {
            background-color: #f1f5f9;
            color: var(--text-sub);
            cursor: not-allowed;
        }

        .form-hint {
            font-size: 12px;
            color: var(--text-sub);
            margin-top: 5px;
        }

        /* 送信ボタン */
        .btn-submit {
            width: 100%;
            padding: 12px;
            background-color: var(--primary);
            color: #ffffff;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s;
            margin-top: 10px;
        }

        .btn-submit:hover {
            background-color: var(--primary-hover);
        }

        .btn-submit:disabled {
            background-color: #94a3b8;
            cursor: not-allowed;
        }

        /* ログイン画面への戻り導線 */
        .form-footer {
            margin-top: 24px;
            text-align: center;
            font-size: 13px;
            color: var(--text-sub);
        }

        .login-link {
            color: var(--primary);
            text-decoration: none;
            font-weight: 600;
            margin-left: 4px;
        }

        .login-link:hover {
            text-decoration: underline;
            color: var(--primary-hover);
        }

        @media (max-width: 860px) {
            .layout {
                flex-direction: column;
            }
            .brand-panel {
                padding: 40px 24px;
                flex: none;
            }
            .form-panel {
                padding: 40px 24px;
            }
        }
    </style>
</head>
<body>

    <div class="layout">

        <!-- 左側：ブランド・技術仕様パネル -->
        <div class="brand-panel">
            <div class="brand-header">
                📁 電子契約サービス
            </div>

            <div class="brand-body">
                <h1 class="brand-title">
                    法的証拠力と非改ざん性を実証する<br>
                    <span>次世代電子署名プラットフォーム</span>
                </h1>
                <p class="brand-desc">
                    国際標準規格 PAdES（PDF-Advanced Electronic Signatures）に準拠し、公開鍵暗号基盤（PKI）による厳格な署名付与と完全性検証を提供します。
                </p>

                <ul class="feature-list">
                    <li class="feature-item">
                        <span class="feature-icon">✔</span>
                        <div><strong>PAdES規格準拠</strong>：PDFバイナリへの電子署名・証明書の直接埋め込み</div>
                    </li>
                    <li class="feature-item">
                        <span class="feature-icon">✔</span>
                        <div><strong>X.509標準証明書</strong>：PKCS#12（.p12）および正規化鍵フォーマット両対応</div>
                    </li>
                    <li class="feature-item">
                        <span class="feature-icon">✔</span>
                        <div><strong>暗号検証ラボ</strong>：SHA-256ハッシュ照合による1ビット単位の改ざん検知</div>
                    </li>
                </ul>
            </div>

            <div class="brand-footer">
                &copy; 2026 Electronic Contract System. All rights reserved.
            </div>
        </div>

        <!-- 右側：新規登録フォーム -->
        <div class="form-panel">
            <div class="form-container">

                <div class="form-header">
                    <h2 class="form-title">新規アカウント登録</h2>
                    <p class="form-subtitle">基本情報を入力してアカウントを作成してください</p>
                </div>

                <!-- エラーメッセージ通知（JSTLに一本化） -->
                <c:if test="${not empty errorMsg}">
                    <div class="alert alert-danger">
                        ⚠ <c:out value="${errorMsg}"/>
                    </div>
                </c:if>

                <!-- 成功判定フラグ -->
                <c:set var="isRegistered" value="${isSuccess == true || param.success == 'true'}" />

                <form action="<%= request.getContextPath() %>/RegisterServlet" method="post">
                    <div class="form-group">
                        <label class="form-label" for="name">お名前（表示名）</label>
                        <input type="text" id="name" name="name" class="form-control" placeholder="例: 山田 太郎" ${isRegistered ? 'disabled' : 'required autofocus'}>
                        <div class="form-hint">電子署名時の署名者名として利用されます。</div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="email">メールアドレス / ログインID</label>
                        <input type="email" id="email" name="email" class="form-control" placeholder="例: yamada@example.com" ${isRegistered ? 'disabled' : 'required'}>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="password">パスワード</label>
                        <input type="password" id="password" name="password" class="form-control" placeholder="パスワードを入力" ${isRegistered ? 'disabled' : 'required'}>
                    </div>

                    <button type="submit" class="btn-submit" ${isRegistered ? 'disabled' : ''}>アカウントを作成する</button>

                    <!-- 新規登録ボタン下部：完了メッセージ ＆ カウントダウン表示 -->
                    <c:if test="${isRegistered}">
                        <div class="alert alert-success">
                            ✔ 新規アカウント登録が完了しました。<br>
                            <span id="countdownText" style="font-size: 12px; font-weight: normal; margin-top: 4px; display: inline-block;">
                                <strong id="secondsLeft">5</strong> 秒後にログイン画面へ自動移動します...
                            </span>
                        </div>
                    </c:if>
                </form>

                <div class="form-footer">
                    すでにアカウントをお持ちですか？
                    <a href="<%= request.getContextPath() %>/Login" class="login-link">ログイン画面へ戻る</a>
                </div>

            </div>
        </div>

    </div>

    <!-- 登録成功時の5秒自動遷移スクリプト -->
    <c:if test="${isRegistered}">
        <script>
            let remaining = 5;
            const targetUrl = "<%= request.getContextPath() %>/Login";
            const secondsElem = document.getElementById("secondsLeft");

            const timer = setInterval(() => {
                remaining--;
                if (secondsElem) {
                    secondsElem.textContent = remaining;
                }
                if (remaining <= 0) {
                    clearInterval(timer);
                    window.location.href = targetUrl;
                }
            }, 1000);
        </script>
    </c:if>

</body>
</html>