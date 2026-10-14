<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>新規フォルダ作成 - 電子契約サービス</title>
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
            --success: #16a34a;
            --success-bg: #dcfce7;
            --danger: #dc2626;
            --danger-bg: #fee2e2;
        }

        * {
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: var(--bg-page);
            color: var(--text-main);
            display: flex;
            min-height: 100vh;
        }

        /* 左サイドバー */
        .sidebar {
            width: 260px;
            background-color: var(--sidebar-bg);
            color: var(--sidebar-text);
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
            border-right: 1px solid #334155;
        }

        .sidebar-brand {
            padding: 24px 20px;
            font-size: 18px;
            font-weight: 700;
            color: #f8fafc;
            border-bottom: 1px solid #1e293b;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
            letter-spacing: 0.5px;
        }
        .sidebar-brand:hover {
            color: var(--sidebar-active);
        }

        .sidebar-user {
            padding: 16px 20px;
            background-color: #1e293b;
            border-bottom: 1px solid #334155;
            font-size: 12px;
        }
        .sidebar-user-label {
            color: #64748b;
            margin-bottom: 4px;
        }
        .sidebar-user-name {
            color: #f8fafc;
            font-size: 14px;
            font-weight: 600;
            word-break: break-all;
        }

        .sidebar-menu {
            list-style: none;
            margin: 12px 0 0 0;
            padding: 0;
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        .sidebar-menu-item a {
            display: flex;
            align-items: center;
            padding: 12px 20px;
            color: var(--sidebar-text);
            text-decoration: none;
            font-size: 13.5px;
            font-weight: 500;
            transition: all 0.2s;
            border-left: 3px solid transparent;
        }
        .sidebar-menu-item a:hover {
            background-color: var(--sidebar-hover-bg);
            color: #f8fafc;
        }
        .sidebar-menu-item.active a {
            background-color: #1e293b;
            color: var(--sidebar-active);
            border-left-color: var(--sidebar-active);
            font-weight: 600;
        }

        /* サイドバー最下部のログアウト固定エリア */
        .sidebar-footer {
            margin-top: auto;
            padding: 16px 20px;
            border-top: 1px solid #334155;
        }

        .logout-link {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #ffffff;
            text-decoration: none;
            font-size: 13.5px;
            font-weight: 600;
            padding: 10px 12px;
            border-radius: 6px;
            transition: all 0.2s;
        }

        .logout-link:hover {
            background-color: rgba(239, 68, 68, 0.15);
            color: #ef4444;
        }

        /* 右メインコンテンツ */
        .main-wrapper {
            flex: 1;
            padding: 30px 40px;
            overflow-y: auto;
        }

        .container {
            max-width: 850px;
            margin: 0 auto;
        }

        /* パンくずリスト */
        .breadcrumb {
            font-size: 13px;
            color: var(--text-sub);
            margin-bottom: 16px;
        }
        .breadcrumb a {
            color: var(--primary);
            text-decoration: none;
        }
        .breadcrumb a:hover {
            text-decoration: underline;
        }

        /* ページヘッダー */
        .page-header {
            margin-bottom: 24px;
            border-bottom: 2px solid var(--border);
            padding-bottom: 14px;
        }
        .page-header h2 {
            margin: 0;
            font-size: 22px;
            color: var(--text-main);
            font-weight: 700;
        }

        /* 通知バナー */
        .alert {
            padding: 12px 16px;
            border-radius: 6px;
            font-size: 13.5px;
            font-weight: 600;
            margin-bottom: 20px;
        }
        .alert-danger { background: var(--danger-bg); color: var(--danger); border: 1px solid #fca5a5; }

        /* カード */
        .card {
            background: var(--card-bg);
            border-radius: 8px;
            padding: 24px;
            margin-bottom: 25px;
            border: 1px solid var(--border);
            box-shadow: 0 1px 4px rgba(0, 0, 0, 0.04);
        }
        .section-heading {
            font-size: 16px;
            font-weight: 700;
            margin-top: 0;
            margin-bottom: 16px;
            color: var(--text-main);
            border-bottom: 1px solid var(--border);
            padding-bottom: 10px;
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
        .form-label .required-badge {
            background: #ef4444;
            color: #ffffff;
            font-size: 10.5px;
            padding: 2px 6px;
            border-radius: 3px;
            margin-left: 6px;
            font-weight: 600;
        }
        .form-control {
            width: 100%;
            padding: 10px 12px;
            font-size: 14px;
            border: 1px solid var(--border);
            border-radius: 6px;
            background: #ffffff;
            color: var(--text-main);
        }
        .form-control:focus {
            outline: none;
            border-color: var(--primary);
        }
        .form-hint {
            font-size: 12px;
            color: var(--text-sub);
            margin-top: 5px;
        }

        /* チェックボックスエリア */
        .checkbox-container {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-top: 6px;
            font-size: 13.5px;
            cursor: pointer;
        }
        .checkbox-container input {
            width: 16px;
            height: 16px;
            cursor: pointer;
        }

        /* ボタン群 */
        .btn-group {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-top: 24px;
        }
        .btn {
            display: inline-block;
            padding: 10px 22px;
            border-radius: 6px;
            font-size: 13.5px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            border: none;
            transition: all 0.2s;
        }
        .btn-primary { background-color: var(--primary); color: white; }
        .btn-primary:hover { background-color: var(--primary-hover); }
        .btn-cancel {
            background-color: #f1f5f9;
            color: var(--text-sub);
            border: 1px solid var(--border);
        }
        .btn-cancel:hover { background-color: #e2e8f0; color: var(--text-main); }
    </style>
</head>
<body>

    <!-- 左サイドバー -->
    <aside class="sidebar">
        <a href="DashboardServlet" class="sidebar-brand">
            📁 電子契約サービス
        </a>

        <div class="sidebar-user">
            <div class="sidebar-user-label">ログインユーザー :</div>
            <div class="sidebar-user-name">
                <c:choose>
                    <c:when test="${not empty sessionScope.loginUser.userName}">
                        ${sessionScope.loginUser.userName} さん
                    </c:when>
                    <c:otherwise>
                        ユーザーID: ${sessionScope.loginUser.userId} さん
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <ul class="sidebar-menu">
            <li class="sidebar-menu-item">
                <a href="DashboardServlet">📊 ダッシュボード</a>
            </li>
            <li class="sidebar-menu-item active">
                <a href="FolderListServlet">📂 契約フォルダー一覧</a>
            </li>
            <li class="sidebar-menu-item">
                <a href="UserManageServlet">👤 ユーザー情報管理</a>
            </li>
            <li class="sidebar-menu-item">
                <a href="SignatureLab">🔏 ハッシュ値確認・改ざん検知シミュレーター</a>
            </li>
        </ul>

        <div class="sidebar-footer">
            <a href="<%= request.getContextPath() %>/LogoutServlet" 
               class="logout-link" 
               onclick="return confirm('ログアウトしてもよろしいですか？');">
                🚪 ログアウト
            </a>
        </div>
    </aside>

    <!-- 右メインコンテンツ -->
    <main class="main-wrapper">
        <div class="container">

            <!-- パンくずリスト -->
            <div class="breadcrumb">
                <a href="DashboardServlet">ダッシュボード</a> &gt; 
                <a href="FolderListServlet">契約フォルダー一覧</a> &gt; 
                <span>新規フォルダ作成</span>
            </div>

            <!-- ヘッダー -->
            <div class="page-header">
                <h2>新規契約フォルダ作成</h2>
            </div>

            <!-- エラー通知バナー -->
            <c:if test="${not empty param.error}">
                <div class="alert alert-danger">
                    <c:choose>
                        <c:when test="${param.error == 'empty_fields'}">⚠ 必須項目（フォルダ名、宛先企業名、担当者名、メールアドレス）をすべて入力してください。</c:when>
                        <c:otherwise>⚠ フォルダの作成に失敗しました。もう一度お試しください。</c:otherwise>
                    </c:choose>
                </div>
            </c:if>

            <!-- 作成フォームカード -->
            <div class="card">
                <div class="section-heading">契約案件・送信先情報</div>

                <form action="CreateFolderServlet" method="POST">
                    <div class="form-group">
                        <label class="form-label">
                            フォルダ名（案件管理名）
                            <span class="required-badge">必須</span>
                        </label>
                        <input type="text" name="folderName" class="form-control" placeholder="例: 業務委託基本契約書_202610" required>
                        <div class="form-hint">社内および相手方に表示される契約フォルダの識別名です。</div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">
                            宛先（相手方）企業名
                            <span class="required-badge">必須</span>
                        </label>
                        <input type="text" name="targetCompanyName" class="form-control" placeholder="例: 株式会社サンプル" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label">宛先部署名</label>
                        <input type="text" name="targetDepartmentName" class="form-control" placeholder="例: 総務部 / 営業本部">
                    </div>

                    <div class="form-group">
                        <label class="form-label">
                            宛先担当者名
                            <span class="required-badge">必須</span>
                        </label>
                        <input type="text" name="targetUserName" class="form-control" placeholder="例: 鈴木 一郎" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label">
                            宛先メールアドレス
                            <span class="required-badge">必須</span>
                        </label>
                        <input type="email" name="targetEmail" class="form-control" placeholder="例: suzuki@sample.co.jp" required>
                        <div class="form-hint">相手方への招待通知・署名依頼に利用されます。</div>
                    </div>

                    <div class="form-group" style="margin-top: 22px;">
                        <label class="form-label">相手方の電子証明書発行設定</label>
                        <label class="checkbox-container">
                            <input type="checkbox" name="certIssuanceAllowed" value="true" checked>
                            <span>招待先ゲストによるワンクリック電子証明書の発行を許可する</span>
                        </label>
                        <div class="form-hint">チェックを外すと、相手方は外部からアップロードした証明書のみで署名することになります（通常はON推奨）。</div>
                    </div>

                    <div class="btn-group">
                        <button type="submit" class="btn btn-primary">契約フォルダを作成する</button>
                        <a href="FolderListServlet" class="btn btn-cancel">キャンセル</a>
                    </div>
                </form>
            </div>

        </div>
    </main>

</body>
</html>