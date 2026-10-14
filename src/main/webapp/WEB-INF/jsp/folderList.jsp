<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>契約フォルダー一覧 - 電子契約サービス</title>
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
            max-width: 1050px;
            margin: 0 auto;
        }

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

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
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
        .header-actions {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .alert {
            padding: 12px 16px;
            border-radius: 6px;
            font-size: 13.5px;
            font-weight: 600;
            margin-bottom: 20px;
        }
        .alert-danger { background: var(--danger-bg); color: var(--danger); border: 1px solid #fca5a5; }

        .card {
            background: var(--card-bg);
            border-radius: 8px;
            padding: 24px;
            margin-bottom: 25px;
            border: 1px solid var(--border);
            box-shadow: 0 1px 4px rgba(0, 0, 0, 0.04);
        }

        .styled-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13.5px;
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: 6px;
            overflow: hidden;
        }
        .styled-table th, .styled-table td {
            padding: 12px 16px;
            border-bottom: 1px solid var(--border);
            text-align: left;
            vertical-align: middle;
        }
        .styled-table th {
            background-color: #f8fafc;
            color: var(--text-sub);
            font-weight: 600;
        }
        .styled-table tr:last-child th, .styled-table tr:last-child td {
            border-bottom: none;
        }
        .folder-link {
            color: var(--primary);
            text-decoration: none;
            font-weight: 600;
        }
        .folder-link:hover {
            text-decoration: underline;
        }

        .role-badge {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 600;
        }
        .role-sender { background: #e0f2fe; color: #0369a1; }
        .role-receiver { background: #f1f5f9; color: #475569; }

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
        .btn-premium {
            background-color: #ffd700;
            color: #212529;
            border: 1px solid #e0be00;
            font-size: 12px;
            padding: 6px 12px;
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
                <span>契約フォルダー一覧</span>
            </div>

            <!-- 通知メッセージ -->
            <c:if test="${param.error == 'forbidden_guest'}">
                <div class="alert alert-danger">
                    ⚠ 招待されたゲストアカウントでは、新規契約フォルダを作成することはできません。
                </div>
            </c:if>

            <!-- ページヘッダー -->
            <div class="page-header">
                <h2>契約フォルダー一覧</h2>
                <div class="header-actions">
                    <c:if test="${loginUser.planType == 'PREMIUM'}">
                        <button class="btn btn-premium">【上位プラン限定】電子証明書管理</button>
                    </c:if>
                    <c:choose>
                        <c:when test="${sessionScope.loginUser.guest}">
                            <span style="font-size: 12.5px; color: var(--text-sub); padding: 8px 14px; background: #f1f5f9; border: 1px solid var(--border); border-radius: 6px; font-weight: 600;">
                                🔒 招待アカウント（閲覧・署名専用）
                            </span>
                        </c:when>
                        <c:otherwise>
                            <a href="CreateFolderServlet" class="btn btn-primary">＋ 新規フォルダ作成</a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- フォルダー一覧テーブルカード -->
            <div class="card" style="padding: 0; overflow: hidden;">
                <table class="styled-table">
                    <thead>
                        <tr>
                            <th style="width: 14%;">フォルダID</th>
                            <th style="width: 44%;">フォルダ名</th>
                            <th style="width: 27%;">宛先企業名</th>
                            <th style="width: 15%;">立場</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty folderList}">
                                <c:forEach var="folder" items="${folderList}">
                                    <tr>
                                        <td>${folder.folderId}</td>
                                        <td>
                                            <a href="FolderDetailServlet?id=${folder.folderId}" class="folder-link">
                                                ${folder.folderName}
                                            </a>
                                        </td>
                                        <td>${folder.targetCompanyName}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${folder.createdBy == loginUser.userId}">
                                                    <span class="role-badge role-sender">送信者</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="role-badge role-receiver">受信者（署名者）</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="4" style="text-align: center; color: var(--text-sub); padding: 30px;">
                                        登録されているフォルダはありません。<c:if test="${!sessionScope.loginUser.guest}">「＋ 新規フォルダ作成」から作成してください。</c:if>
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

        </div>
    </main>

</body>
</html>