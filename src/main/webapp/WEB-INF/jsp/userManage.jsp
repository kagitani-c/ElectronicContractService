<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>ユーザー情報管理 - 電子契約サービス</title>
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
            max-width: 900px;
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
        .alert-success { background: var(--success-bg); color: var(--success); border: 1px solid #86efac; }
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
        .form-control[readonly] {
            background-color: #f1f5f9;
            color: var(--text-sub);
            cursor: not-allowed;
        }

        /* ボタン */
        .btn {
            display: inline-block;
            padding: 8px 16px;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            border: none;
            transition: all 0.2s;
        }
        .btn-primary { background-color: var(--primary); color: white; }
        .btn-primary:hover { background-color: var(--primary-hover); }

        /* ステータスバッジ */
        .badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 600;
        }
        .badge-success { background: var(--success-bg); color: var(--success); }
        .badge-danger { background: var(--danger-bg); color: var(--danger); }

        /* 電子証明書パネル用グリッド */
        .cert-options-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-top: 15px;
            border-top: 1px solid var(--border);
            padding-top: 18px;
        }
        .cert-box {
            background: #f8fafc;
            border: 1px solid var(--border);
            border-radius: 6px;
            padding: 16px 20px;
            font-size: 13px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }
        .cert-box h4 {
            margin: 0 0 6px 0;
            font-size: 14px;
            color: var(--text-main);
        }
        .cert-box p {
            margin: 0 0 12px 0;
            color: var(--text-sub);
            line-height: 1.5;
            font-size: 12.5px;
        }
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
            <li class="sidebar-menu-item">
                <a href="FolderListServlet">📂 契約フォルダー一覧</a>
            </li>
            <li class="sidebar-menu-item active">
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
                <span>ユーザー情報管理</span>
            </div>

            <!-- ヘッダー -->
            <div class="page-header">
                <h2>ユーザー情報管理</h2>
            </div>

            <!-- 通知メッセージ -->
            <c:if test="${param.updated == 'true'}">
                <div class="alert alert-success">
                    ✔ ユーザー情報を更新しました。
                </div>
            </c:if>
            <c:if test="${param.error == 'duplicate_email'}">
                <div class="alert alert-danger">
                    ⚠ 入力されたメールアドレスは既に他のアカウントで使用されています。
                </div>
            </c:if>
            <c:if test="${param.error == 'empty_name'}">
                <div class="alert alert-danger">
                    ⚠ 表示名を入力してください。
                </div>
            </c:if>
            <c:if test="${param.error == 'empty_email'}">
                <div class="alert alert-danger">
                    ⚠ メールアドレスを入力してください。
                </div>
            </c:if>

            <!-- 基本情報フォームカード -->
            <div class="card">
                <div class="section-heading">基本アカウント情報</div>
                <form action="UserManageServlet" method="POST">
                    <div class="form-group">
                        <label class="form-label">システム連番ID</label>
                        <input type="text" class="form-control" value="${sessionScope.loginUser.userId}" readonly>
                    </div>

                    <div class="form-group">
                        <label class="form-label">メールアドレス兼ログインID</label>
                        <input type="email" name="email" class="form-control" value="${sessionScope.loginUser.email}" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label">表示名（署名者名として利用されます）</label>
                        <input type="text" name="userName" class="form-control" value="${sessionScope.loginUser.userName}" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label">所属</label>
                        <input type="text" name="companyName" class="form-control" value="${sessionScope.loginUser.companyName}">
                    </div>

                    <button type="submit" class="btn btn-primary">情報を更新する</button>
                </form>
            </div>

            <!-- 電子証明書（署名鍵）ステータス カード -->
            <div class="card">
                <div class="section-heading">電子証明書（署名鍵）ステータス</div>

                <div class="form-group" style="margin-bottom: 0;">
                    <label class="form-label">電子署名用証明書の登録状況</label>
                    <div>
                        <c:choose>
                            <c:when test="${not empty sessionScope.loginUser.certificatePath}">
                                <span class="badge badge-success">✔ 登録済み（契約書への署名が可能です）</span>
                                <div style="font-size: 12px; color: var(--text-sub); margin-top: 6px; word-break: break-all;">
                                    登録ファイル: <code>${sessionScope.loginUser.certificatePath}</code>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <c:choose>
                                    <c:when test="${sessionScope.loginUser.guest && !canIssueCert}">
                                        <span class="badge badge-danger">⚠ 未登録（署名を行うには電子証明書のアップロードが必要です）</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-danger">⚠ 未登録（署名を行うには発行またはアップロードが必要です）</span>
                                    </c:otherwise>
                                </c:choose>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- 発行不許可時は1カラム幅に自動調整 -->
                <div class="cert-options-grid" style="${!canIssueCert ? 'grid-template-columns: 1fr;' : ''}">
                    <!-- 左：ワンクリック発行 -->
                    <c:if test="${canIssueCert}">
                        <div class="cert-box">
                            <div>
                                <h4>【テスト用】ワンクリック即時発行</h4>
                                <p>
                                    システム上で署名者用の鍵ペア・電子証明書を即時生成し、アカウントに紐づけます。事前準備なしですぐに署名機能をテストできます。
                                </p>
                            </div>
                            <div>
                                <a href="<%= request.getContextPath() %>/GenerateCertServlet" 
                                   onclick="setTimeout(function(){ location.reload(); }, 1000);"
                                   class="btn btn-primary" style="font-size: 12.5px;">
                                    証明書を発行して有効化する
                                </a>
                            </div>
                        </div>
                    </c:if>

                    <!-- 右：証明書アップロード -->
                    <div class="cert-box">
                        <div>
                            <h4>【外部連携想定】証明書ファイルの登録</h4>
                            <p>
                                外部で取得済みの証明書（<strong>.p12 / .pfx</strong>）や、別アカウントから書き出した証明書ファイル（<strong>.txt</strong>）を取り込んで紐づけます。
                            </p>
                        </div>
                        <div>
                            <form action="<%= request.getContextPath() %>/UploadCertServlet" method="post" enctype="multipart/form-data" style="margin: 0;">
                                <input type="file" id="certFileSelector" name="certFile" accept=".txt,.p12,.pfx" required onchange="handleCertFileSelect(this)" style="font-size: 12px; margin-bottom: 8px; width: 100%;">
                                
                                <div id="p12PasswordWrapper" style="display: none; margin-bottom: 8px;">
                                    <label style="font-size: 11.5px; color: var(--text-sub); display: block; margin-bottom: 3px;">
                                        PKCS#12 パスワード:
                                    </label>
                                    <input type="password" id="certPassword" name="certPassword" placeholder="インポートパスワード" style="font-size: 12px; width: 100%; padding: 5px 8px; border: 1px solid var(--border); border-radius: 4px;">
                                </div>

                                <button type="submit" class="btn btn-primary" style="font-size: 12.5px; background: #475569;">
                                    アップロードして紐づけ
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </main>

    <script>
        function handleCertFileSelect(input) {
            const wrapper = document.getElementById('p12PasswordWrapper');
            const passInput = document.getElementById('certPassword');
            if (input.files && input.files.length > 0) {
                const fileName = input.files[0].name.toLowerCase();
                if (fileName.endsWith('.p12') || fileName.endsWith('.pfx')) {
                    wrapper.style.display = 'block';
                    passInput.setAttribute('required', 'required');
                } else {
                    wrapper.style.display = 'none';
                    passInput.removeAttribute('required');
                }
            }
        }
    </script>

</body>
</html>