<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ログイン - 電子契約サービス</title>
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

        .login-layout {
            display: flex;
            width: 100vw;
            min-height: 100vh;
        }

        /* ===================================================
           左側：ブランド・技術概要パネル
        =================================================== */
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

        /* ===================================================
           右側：ログインフォームパネル
        =================================================== */
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
            background: var(--danger-bg);
            color: var(--danger);
            border: 1px solid #fca5a5;
        }

        /* フォームグループ */
        .form-group {
            margin-bottom: 20px;
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
            margin-top: 8px;
        }

        .btn-submit:hover {
            background-color: var(--primary-hover);
        }

        /* 新規登録リンクフッター */
        .form-footer {
            margin-top: 24px;
            text-align: center;
            font-size: 13px;
            color: var(--text-sub);
        }

        .register-link {
            color: var(--primary);
            text-decoration: none;
            font-weight: 600;
            margin-left: 4px;
        }

        .register-link:hover {
            text-decoration: underline;
            color: var(--primary-hover);
        }

        @media (max-width: 860px) {
            .login-layout {
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

    <div class="login-layout">

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

        <!-- 右側：ログインフォーム -->
        <div class="form-panel">
            <div class="form-container">

                <div class="form-header">
                    <h2 class="form-title">ログイン</h2>
                    <p class="form-subtitle">登録済みのメールアドレスとパスワードを入力してください</p>
                </div>

                <!-- 認証エラー通知 -->
                <c:if test="${not empty param.error}">
                    <div class="alert">
                        ⚠ メールアドレスまたはパスワードが正しくありません。
                    </div>
                </c:if>

                <form action="Login" method="POST">
                    <div class="form-group">
                        <label class="form-label" for="email">メールアドレス / ログインID</label>
                        <input type="email" id="email" name="email" class="form-control" placeholder="user@example.com" required autofocus>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="password">パスワード</label>
                        <input type="password" id="password" name="password" class="form-control" placeholder="••••••••" required>
                    </div>

                    <button type="submit" class="btn-submit">ログイン</button>
                </form>

                <!-- 新規登録導線 -->
                <div class="form-footer">
                    アカウントをお持ちでないですか？
                    <a href="RegisterServlet" class="register-link">新規アカウント登録</a>
                </div>

            </div>
        </div>

    </div>

</body>
</html>