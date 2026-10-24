<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>契約フォルダ詳細 - ${folder.folderName}</title>
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
            --warning: #d97706;
            --warning-bg: #fef3c7;
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

        /* ページ見出し */
        .page-header {
            margin-bottom: 24px;
            border-bottom: 2px solid #e2e8f0;
            padding-bottom: 12px;
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

        /* セクション共通カード */
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
            display: flex;
            align-items: center;
            gap: 8px;
        }

        /* テーブル共通 */
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
            padding: 11px 14px;
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

        /* ドラッグ＆ドロップゾーン */
        .drop-zone {
            border: 2px dashed var(--primary);
            border-radius: 8px;
            padding: 28px 20px;
            text-align: center;
            background-color: #f8fafc;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .drop-zone:hover, .drop-zone.dragover {
            background-color: #e0f2fe;
            border-color: #0369a1;
        }
        .drop-zone-icon { font-size: 32px; margin-bottom: 6px; }
        .drop-zone-text { color: var(--text-main); font-size: 14px; }
        .file-info { margin-top: 10px; font-weight: bold; color: var(--primary); font-size: 13px; display: none; }

        /* ボタン群 */
        .btn {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 5px;
            font-size: 12.5px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            border: none;
            transition: all 0.2s;
        }
        .btn-primary { background-color: var(--primary); color: white; }
        .btn-primary:hover { background-color: var(--primary-hover); }
        .btn-success { background-color: var(--success); color: white; }
        .btn-success:hover { background-color: #15803d; }
        .btn-download {
            background-color: #0284c7;
            color: #ffffff;
            border: 1px solid #0369a1;
        }
        .btn-download:hover {
            background-color: #0369a1;
        }
        .btn-link {
            background: none;
            border: none;
            color: var(--primary);
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            padding: 0;
            font-size: 13px;
        }
        .btn-link:hover { text-decoration: underline; }
        .btn-link-danger { color: var(--danger); }
        .btn-link-danger:hover { text-decoration: underline; }

        /* ダイアログ */
        dialog { border: none; border-radius: 8px; padding: 25px; width: 440px; box-shadow: 0 4px 20px rgba(0,0,0,0.15); }
        dialog::backdrop { background: rgba(0, 0, 0, 0.4); }

        .back-link {
            display: inline-block;
            margin-top: 20px;
            color: var(--primary);
            text-decoration: none;
            font-size: 13.5px;
            font-weight: 600;
        }
        .back-link:hover { text-decoration: underline; }
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

            <!-- 1. パンくずリスト -->
            <div class="breadcrumb">
                <a href="DashboardServlet">ダッシュボード</a> &gt; 
                <a href="FolderListServlet">契約フォルダー一覧</a> &gt; 
                <span>契約フォルダ詳細画面</span>
            </div>

            <!-- 2. ページヘッダー -->
            <div class="page-header">
                <h2>契約フォルダ詳細</h2>
            </div>

            <!-- 通知バナー -->
            <c:if test="${param.signed == 'true'}">
                <div class="alert alert-success">
                    ✔ 電子署名の付与が完了しました。
                </div>
            </c:if>
            <c:if test="${not empty param.error}">
                <div class="alert alert-danger">
                    <c:choose>
                        <c:when test="${param.error == 'no_cert'}">⚠ 電子証明書が登録されていません。一覧またはユーザー管理画面で登録してください。</c:when>
                        <c:when test="${param.error == 'cert_not_found'}">⚠ 証明書ファイルが存在しません。</c:when>
                        <c:when test="${param.error == 'file_not_found'}">⚠ 対象のPDFファイルが見つかりません。</c:when>
                        <c:otherwise>⚠ 署名処理に失敗しました。</c:otherwise>
                    </c:choose>
                </div>
            </c:if>

            <!-- 3. フォルダ基本情報カード -->
            <div class="card">
                <table class="styled-table">
                    <tr><th style="width: 25%;">フォルダ名</th><td>${folder.folderName} (ID: ${folder.folderId})</td></tr>
                    <tr><th>宛先企業名</th><td>${folder.targetCompanyName}</td></tr>
                    <tr><th>宛先部署名</th><td>${folder.targetDepartmentName}</td></tr>
                    <tr><th>担当者名</th><td>${folder.targetUserName}</td></tr>
                    <tr><th>メールアドレス</th><td>${folder.targetEmail}</td></tr>
                    
                    <%-- 招待ユーザーには非表示（フォルダ作成者のみ表示） --%>
                    <c:if test="${!sessionScope.loginUser.guest && folder.createdBy == sessionScope.loginUser.userId}">
                        <tr><th>電子証明書発行の許可</th><td>${folder.certIssuanceAllowed ? '許可する' : '許可しない'}</td></tr>
                        <tr>
                            <th>招待用 URL（トークン付き）</th>
                            <td>
                                <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap;">
                                    <!-- ★★★ JavaScriptでアクセス元に合わせて動的にセット ★★★ -->
                                    <code id="inviteUrlText" style="background:#f1f5f9; padding:6px 10px; border-radius:4px; font-size:12px; border: 1px solid var(--border); word-break: break-all;"></code>
                                    <button type="button" class="btn btn-primary" onclick="copyInviteUrl(this)" style="padding: 5px 12px; font-size: 12px; display: inline-flex; align-items: center; gap: 4px;">
                                        📋 URLをコピー
                                    </button>
                                </div>
                            </td>
                        </tr>
                    </c:if>
                </table>

                <div style="font-size: 12.5px; color: var(--text-sub); margin-top: 12px;">
                    <c:if test="${not empty folder.updatedAt}">
                        最終更新: ${folder.updatedAt} (更新者ID: ${folder.updatedBy}) &nbsp;|&nbsp;
                    </c:if>
                    <%-- 招待ユーザーにはフォルダ情報変更リンクも非表示 --%>
                    <c:if test="${!sessionScope.loginUser.guest && folder.createdBy == sessionScope.loginUser.userId}">
                        <a href="EditFolderServlet?id=${folder.folderId}" class="btn-link">[契約フォルダ情報を変更する]</a>
                    </c:if>
                </div>

                <!-- フォルダ情報変更履歴 -->
                <details style="margin-top: 15px; border: 1px solid var(--border); border-radius: 6px; padding: 10px; background: #fdfdfd;">
                    <summary style="font-size: 13px; font-weight: 600; cursor: pointer; color: var(--text-sub);">
                        フォルダ情報の変更履歴（${empty historyList ? 0 : historyList.size()} 件）
                    </summary>
                    <c:if test="${not empty historyList}">
                        <table class="styled-table" style="font-size: 12px; margin-top: 10px;">
                            <tr><th>変更日時</th><th>変更者ID</th><th>フォルダ名</th><th>企業名</th><th>部署名</th><th>担当者名</th><th>メール</th></tr>
                            <c:forEach var="history" items="${historyList}">
                                <tr>
                                    <td>${history.changedAt}</td><td>${history.changedBy}</td><td>${history.folderName}</td>
                                    <td>${history.targetCompanyName}</td><td>${history.targetDepartmentName}</td>
                                    <td>${history.targetUserName}</td><td>${history.targetEmail}</td>
                                </tr>
                            </c:forEach>
                        </table>
                    </c:if>
                    <c:if test="${empty historyList}"><p style="font-size: 12px; color: #94a3b8; margin: 8px 0 0 0;">※ 変更履歴はありません。</p></c:if>
                </details>
            </div>

            <!-- 4. 契約書PDFの新規アップロードカード -->
            <div class="card">
                <div class="section-heading">📤 契約書PDFの新規アップロード</div>
                <form id="uploadForm" action="UploadPdfServlet" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="folderId" value="${folder.folderId}">
                    <input type="file" id="pdfFileInput" name="pdfFile" accept="application/pdf" style="display: none;" required>

                    <div class="drop-zone" id="dropZone">
                        <div class="drop-zone-icon">📄</div>
                        <div class="drop-zone-text">
                            ここに新しい契約書PDFを<strong>ドラッグ＆ドロップ</strong><br>
                            またはクリックしてファイルを選択
                        </div>
                        <div class="file-info" id="fileInfo"></div>
                    </div>

                    <button type="submit" class="btn btn-primary" id="submitBtn" style="display: none; margin-top: 14px;">
                        アップロードを実行する
                    </button>
                </form>
            </div>

            <!-- 5. 登録済みの契約書データカード -->
            <div class="card">
                <div class="section-heading">📑 登録済みの契約書データ</div>
                <c:choose>
                    <c:when test="${not empty activeDocumentList}">
                        <table class="styled-table">
                            <thead>
                                <tr>
                                    <th>ファイル名</th>
                                    <th style="width: 14%;">版数</th>
                                    <th style="width: 38%;">電子署名ステータス</th>
                                    <th style="width: 20%;">操作</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="doc" items="${activeDocumentList}">
                                    <tr>
                                        <td><strong>${doc.title}</strong></td>
                                        <td>
                                            第 ${doc.version} 版
                                            <c:choose>
                                                <c:when test="${doc.version > 1}">
                                                    <span style="font-size: 11px; color: var(--primary); background: #e0f2fe; padding: 2px 6px; border-radius: 3px; font-weight: bold; margin-left: 4px;">
                                                        差替 ${doc.version - 1} 回
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="font-size: 11px; color: var(--text-sub); margin-left: 4px;">(初版)</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <%-- 双方署名完了 --%>
                                                <c:when test="${not empty doc.signatureData && not empty doc.invitedSignatureData}">
                                                    <div style="color: var(--success); font-weight: bold; margin-bottom: 6px;">
                                                        ✔ 双方署名完了 (2/2名)
                                                    </div>
                                                    <a href="DownloadPdfServlet?docId=${doc.documentId}" class="btn btn-download" style="font-size: 11px; padding: 4px 8px;">
                                                        📥 署名済みPDFをダウンロード
                                                    </a>
                                                </c:when>

                                                <%-- 送信者のみ署名完了 --%>
                                                <c:when test="${not empty doc.signatureData && empty doc.invitedSignatureData}">
                                                    <div style="color: var(--primary); font-weight: bold; margin-bottom: 6px;">
                                                        ✔ 送信者署名済 (1/2名)
                                                    </div>
                                                    <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap;">
                                                        <a href="DownloadPdfServlet?docId=${doc.documentId}" class="btn btn-download" style="font-size: 11px; padding: 4px 8px;">
                                                            📥 署名済みPDFをダウンロード
                                                        </a>

                                                        <c:choose>
                                                            <c:when test="${sessionScope.loginUser.userId != folder.createdBy}">
                                                                <form action="SignPdfServlet" method="POST" style="margin: 0; display: inline-block;">
                                                                    <input type="hidden" name="docId" value="${doc.documentId}">
                                                                    <input type="hidden" name="folderId" value="${folder.folderId}">
                                                                    <c:choose>
                                                                        <c:when test="${not empty sessionScope.loginUser.certificatePath}">
                                                                            <button type="submit" class="btn btn-success" style="padding: 4px 8px;">✍️ 署名して締結（合意）</button>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <button type="button" disabled style="padding: 4px 8px; background: #cbd5e1; border: none; border-radius: 4px; color: #64748b; cursor: not-allowed;" title="先に一覧画面で証明書を準備してください">
                                                                                署名不可 (証明書未登録)
                                                                            </button>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </form>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span style="font-size: 12px; color: var(--warning);">※ 相手方の署名待ちです</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </c:when>

                                                <%-- 未署名 --%>
                                                <c:otherwise>
                                                    <c:choose>
                                                        <c:when test="${sessionScope.loginUser.userId == folder.createdBy}">
                                                            <form action="SignPdfServlet" method="POST" style="margin: 0; display: inline;">
                                                                <input type="hidden" name="docId" value="${doc.documentId}">
                                                                <input type="hidden" name="folderId" value="${folder.folderId}">
                                                                <c:choose>
                                                                    <c:when test="${not empty sessionScope.loginUser.certificatePath}">
                                                                        <button type="submit" class="btn btn-success" style="padding: 4px 8px;">✍️ 電子署名を付与（送信者）</button>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <button type="button" disabled style="padding: 4px 8px; background: #cbd5e1; border: none; border-radius: 4px; color: #64748b; cursor: not-allowed;" title="先に一覧画面で証明書を準備してください">
                                                                            署名不可 (証明書未登録)
                                                                        </button>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </form>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span style="font-size: 12px; color: var(--text-sub);">送信者の署名待ち</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <a href="ViewPdfServlet?docId=${doc.documentId}" target="_blank" class="btn-link">📄 閲覧</a>
                                            &nbsp;|&nbsp;
                                            <button type="button" onclick="openReplaceModal(${doc.documentId}, '${doc.title}', ${doc.version})" class="btn-link">
                                                🔄 差し替え
                                            </button>
                                            &nbsp;|&nbsp;
                                            <form action="DeletePdfServlet" method="POST" style="display: inline; margin: 0;">
                                                <input type="hidden" name="docId" value="${doc.documentId}">
                                                <input type="hidden" name="folderId" value="${folder.folderId}">
                                                <button type="submit" onclick="return confirm('契約書を削除しますか？\n（削除後は下の履歴テーブルに保管されます）');" class="btn-link btn-link-danger">
                                                    🗑️ 削除
                                                </button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:when>
                    <c:otherwise>
                        <p style="color: var(--text-sub); font-size: 13.5px; margin: 0;">※ 現在有効な契約書はありません。上のエリアからPDFをアップロードしてください。</p>
                    </c:otherwise>
                </c:choose>

                <!-- 削除・差し替え履歴テーブル -->
                <details style="margin-top: 20px; border: 1px solid var(--border); border-radius: 6px; padding: 12px; background: #fafafa;">
                    <summary style="font-weight: 600; cursor: pointer; color: var(--text-sub); font-size: 13px;">
                        📜 削除・差し替え履歴を確認する（${empty historyDocumentList ? 0 : historyDocumentList.size()} 件）
                    </summary>
                    <div style="margin-top: 10px;">
                        <c:choose>
                            <c:when test="${not empty historyDocumentList}">
                                <table class="styled-table" style="font-size: 12px; background: #ffffff;">
                                    <tr>
                                        <th>ファイル名</th>
                                        <th>版数</th>
                                        <th>処理日時</th>
                                        <th>操作者ID</th>
                                        <th>証拠PDF</th>
                                    </tr>
                                    <c:forEach var="hDoc" items="${historyDocumentList}">
                                        <tr style="color: var(--text-sub);">
                                            <td><del>${hDoc.title}</del></td>
                                            <td>第 ${hDoc.version} 版</td>
                                            <td>${hDoc.deletedAt}</td>
                                            <td>ユーザーID: ${hDoc.deletedBy}</td>
                                            <td>
                                                <a href="ViewPdfServlet?docId=${hDoc.documentId}" target="_blank" class="btn-link">
                                                    📄 閲覧
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </table>
                            </c:when>
                            <c:otherwise>
                                <p style="font-size: 12px; color: #94a3b8; margin: 5px 0 0 0;">※ 過去の履歴データはありません。</p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </details>
            </div>

            <!-- フォルダ一覧へ戻るリンク -->
            <div>
                <a href="FolderListServlet" class="back-link">← フォルダ一覧へ戻る</a>
            </div>

        </div>
    </main>

    <!-- 契約書差し替えモーダルダイアログ -->
    <dialog id="replaceDialog">
        <form action="ReplacePdfServlet" method="POST" enctype="multipart/form-data">
            <input type="hidden" name="folderId" value="${folder.folderId}">
            <input type="hidden" id="modalOldDocId" name="oldDocId" value="">

            <h3 style="margin-top: 0; font-size: 17px; color: var(--text-main);">契約書PDFの差し替え</h3>
            <p style="font-size: 13px; color: var(--text-sub); line-height: 1.5;">
                対象: <strong id="modalTargetTitle"></strong><br>
                差し替え後は <strong id="modalNextVersion" style="color: var(--primary);"></strong> として登録され、現在の版は履歴にアーカイブ保存されます。
            </p>

            <div style="margin: 18px 0;">
                <label style="display: block; font-weight: 600; margin-bottom: 6px; font-size: 13px;">差し替え用PDFファイル:</label>
                <input type="file" name="replacementFile" accept="application/pdf" required style="width: 100%; font-size: 13px;">
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px;">
                <button type="button" onclick="document.getElementById('replaceDialog').close();" class="btn" style="background: #e2e8f0; color: var(--text-main);">
                    キャンセル
                </button>
                <button type="submit" class="btn btn-primary">
                    差し替えて登録
                </button>
            </div>
        </form>
    </dialog>

    <script>
        // ★★★ 画面読み込み時に、現在のアクセス元環境(localhost / Render)に合わせて招待URLを自動生成 ★★★
        document.addEventListener('DOMContentLoaded', () => {
            const inviteElem = document.getElementById('inviteUrlText');
            if (inviteElem) {
                const contextPath = '<%= request.getContextPath() %>';
                const token = '${folder.token}';
                // window.location.origin により http://localhost:8080 または https://electroniccontractservice.onrender.com を自動判別
                inviteElem.textContent = window.location.origin + contextPath + '/GuestLoginServlet?token=' + encodeURIComponent(token);
            }
        });

        const dropZone = document.getElementById('dropZone');
        const fileInput = document.getElementById('pdfFileInput');
        const fileInfo = document.getElementById('fileInfo');
        const submitBtn = document.getElementById('submitBtn');

        dropZone.addEventListener('click', () => fileInput.click());

        ['dragenter', 'dragover'].forEach(name => {
            dropZone.addEventListener(name, (e) => {
                e.preventDefault();
                dropZone.classList.add('dragover');
            });
        });

        ['dragleave', 'drop'].forEach(name => {
            dropZone.addEventListener(name, (e) => {
                e.preventDefault();
                dropZone.classList.remove('dragover');
            });
        });

        dropZone.addEventListener('drop', (e) => {
            const files = e.dataTransfer.files;
            if (files.length > 0) {
                if (files[0].type === 'application/pdf' || files[0].name.toLowerCase().endsWith('.pdf')) {
                    fileInput.files = files;
                    updateDisplay(files[0]);
                } else {
                    alert('PDFファイルのみアップロード可能です。');
                }
            }
        });

        fileInput.addEventListener('change', () => {
            if (fileInput.files.length > 0) {
                updateDisplay(fileInput.files[0]);
            }
        });

        function updateDisplay(file) {
            fileInfo.textContent = '選択中: ' + file.name + ' (' + (file.size / 1024).toFixed(1) + ' KB)';
            fileInfo.style.display = 'block';
            submitBtn.style.display = 'inline-block';
        }

        function openReplaceModal(docId, title, currentVersion) {
            document.getElementById('modalOldDocId').value = docId;
            document.getElementById('modalTargetTitle').textContent = title + ' (第' + currentVersion + '版)';
            document.getElementById('modalNextVersion').textContent = '第 ' + (currentVersion + 1) + ' 版 (差替 ' + currentVersion + ' 回)';
            document.getElementById('replaceDialog').showModal();
        }

        // URLコピー処理
        function copyInviteUrl(btn) {
            const urlText = document.getElementById('inviteUrlText').innerText.trim();
            navigator.clipboard.writeText(urlText).then(() => {
                const originalText = btn.innerHTML;
                btn.innerHTML = '✔ コピー完了！';
                btn.style.backgroundColor = 'var(--success)';
                setTimeout(() => {
                    btn.innerHTML = originalText;
                    btn.style.backgroundColor = '';
                }, 2000);
            }).catch(err => {
                const tempInput = document.createElement('input');
                tempInput.value = urlText;
                document.body.appendChild(tempInput);
                tempInput.select();
                document.execCommand('copy');
                document.body.removeChild(tempInput);
                
                const originalText = btn.innerHTML;
                btn.innerHTML = '✔ コピー完了！';
                btn.style.backgroundColor = 'var(--success)';
                setTimeout(() => {
                    btn.innerHTML = originalText;
                    btn.style.backgroundColor = '';
                }, 2000);
            });
        }
    </script>

</body>
</html>