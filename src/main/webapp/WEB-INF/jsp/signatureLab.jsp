<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>ハッシュ値確認・改ざん検知シミュレーター - 電子契約サービス</title>
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
            --code-bg: #0f172a;
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

        /* ===================================================
           左サイドバー
        =================================================== */
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

        /* ===================================================
           右メインコンテンツ
        =================================================== */
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

        /* ページヘッダー */
        .page-header {
            margin-bottom: 24px;
            border-bottom: 2px solid var(--border);
            padding-bottom: 14px;
        }
        .page-header h2 {
            margin: 0 0 6px 0;
            font-size: 22px;
            color: var(--text-main);
            font-weight: 700;
        }
        .page-header p {
            margin: 0;
            font-size: 13px;
            color: var(--text-sub);
        }

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
            border-bottom: 1px solid var(--border);
            padding-bottom: 10px;
        }

        /* 1. 上部：ロジック解説 */
        .diagram-area {
            border: 2px dashed #cbd5e1;
            border-radius: 6px;
            background: #f8fafc;
            padding: 24px 20px;
            text-align: center;
            color: var(--text-sub);
            margin-bottom: 20px;
        }
        .logic-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            font-size: 13px;
        }
        .logic-box {
            background: #f8fafc;
            border: 1px solid var(--border);
            border-radius: 6px;
            padding: 15px;
        }
        .logic-box h4 {
            margin: 0 0 6px 0;
            color: var(--primary);
            font-size: 14px;
        }
        .logic-box p {
            margin: 0;
            line-height: 1.5;
            color: var(--text-sub);
        }

        /* 2. 中部：ドロップゾーン ＆ 解析結果 */
        .drop-zone {
            border: 2px dashed var(--primary);
            border-radius: 8px;
            padding: 32px 20px;
            text-align: center;
            background-color: #f8fafc;
            cursor: pointer;
            transition: all 0.2s ease;
            margin-bottom: 20px;
        }
        .drop-zone:hover, .drop-zone.dragover {
            background-color: #e0f2fe;
            border-color: #0369a1;
        }
        .drop-zone-icon { font-size: 36px; margin-bottom: 6px; }
        .drop-zone-text { font-size: 14.5px; font-weight: 600; color: var(--text-main); }
        .drop-zone-subtext { font-size: 12.5px; color: var(--text-sub); margin-top: 4px; }
        .file-name-display {
            margin-top: 10px;
            font-weight: 600;
            color: var(--primary);
            font-size: 13px;
        }
        .btn-analyze {
            margin-top: 14px;
            background-color: var(--primary);
            color: #ffffff;
            border: none;
            padding: 8px 20px;
            border-radius: 6px;
            font-weight: 600;
            font-size: 13px;
            cursor: pointer;
            transition: background 0.2s;
        }
        .btn-analyze:hover {
            background-color: var(--primary-hover);
        }

        /* 生データ表示カードグリッド */
        .data-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 18px;
            margin-top: 20px;
        }
        .data-card {
            background: #f8fafc;
            border: 1px solid var(--border);
            border-radius: 6px;
            padding: 14px 16px;
        }
        .data-label {
            font-size: 12px;
            font-weight: 700;
            color: var(--text-sub);
            margin-bottom: 6px;
        }
        .data-code {
            font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
            background: var(--code-bg);
            color: #38bdf8;
            padding: 8px 10px;
            border-radius: 4px;
            font-size: 12px;
            word-break: break-all;
            line-height: 1.4;
        }

        /* 判定バナー */
        .result-banner {
            margin-top: 20px;
            padding: 16px 20px;
            border-radius: 6px;
            font-weight: 600;
            font-size: 14px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .result-success {
            background: var(--success-bg);
            color: var(--success);
            border: 1px solid #86efac;
        }
        .result-failure {
            background: var(--danger-bg);
            color: var(--danger);
            border: 1px solid #fca5a5;
        }

        /* 3. 下部：改ざん手順説明 */
        .tamper-guide {
            background: #f8fafc;
            border-left: 4px solid #f59e0b;
            padding: 16px 20px;
            border-radius: 0 6px 6px 0;
            font-size: 13px;
            line-height: 1.6;
        }
        .tamper-guide ol {
            margin: 8px 0 0 0;
            padding-left: 20px;
        }
        .tamper-guide li {
            margin-bottom: 6px;
        }
    </style>
</head>
<body>

    <!-- ===================================================
       左サイドバー
    =================================================== -->
    <aside class="sidebar">
        <a href="FolderListServlet" class="sidebar-brand">
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
                <a href="FolderListServlet">📊 ダッシュボード</a>
            </li>
            <li class="sidebar-menu-item">
                <a href="FolderListServlet">📂 契約フォルダー一覧</a>
            </li>
            <li class="sidebar-menu-item">
                <a href="UserManageServlet">👤 ユーザー情報管理</a>
            </li>
            <li class="sidebar-menu-item active">
                <a href="SignatureLab">🔏 ハッシュ値確認・改ざん検知シミュレーター</a>
            </li>
        </ul>
    </aside>

    <!-- ===================================================
       右メインコンテンツ
    =================================================== -->
    <main class="main-wrapper">
        <div class="container">

            <!-- 1. パンくずリスト -->
            <div class="breadcrumb">
                <a href="FolderListServlet">ダッシュボード</a> &gt; 
                <span>ハッシュ値確認・改ざん検知シミュレーター</span>
            </div>

            <!-- 2. ページヘッダー -->
            <div class="page-header">
                <h2>ハッシュ値確認・改ざん検知シミュレーター</h2>
                <p>PDFバイナリから抽出した電子署名・公開鍵・ハッシュ値の照合と、改ざん検知ロジックの実証</p>
            </div>

            <!-- ===================================================
               セクション1：ロジック解説（常時表示）
            =================================================== -->
            <div class="card">
                <div class="section-heading">
                    💡 STEP 1：公開鍵暗号とハッシュ値による非改ざん性証明の原理
                </div>

                <!-- Canva図解 挿入エリア -->
                <div class="diagram-area">
                    <strong>【図解イメージ 挿入エリア】</strong><br>
                    <span style="font-size: 12.5px;">作成したインフォグラフィック画像（<code>step_logic_flow.png</code> 等）をここに配置できます。</span>
                </div>

                <div class="logic-grid">
                    <div class="logic-box">
                        <h4>① 署名の付与（署名者側）</h4>
                        <p>原本PDFの全データから<strong>SHA-256</strong>を用いてハッシュ値を算出。署名者の<strong>秘密鍵</strong>で暗号化して電子署名を生成し、署名者の<strong>公開鍵（証明書）</strong>と共にPDFバイナリ内部に埋め込みます。</p>
                    </div>
                    <div class="logic-box">
                        <h4>② 改ざんの検証（検証者・Acrobat側）</h4>
                        <p>PDF内部の署名データを公開鍵で復号した<strong>【署名時のハッシュ A】</strong>と、現在のPDF本文から再計算した<strong>【現在のハッシュ B】</strong>を照合。1文字でも変更があれば雪崩効果で A ≠ B となり、改ざんを検知します。</p>
                    </div>
                </div>
            </div>

            <!-- ===================================================
               セクション2：実ファイル検証プレイグラウンド
            =================================================== -->
            <div class="card">
                <div class="section-heading">
                    🔬 STEP 2：署名済みPDFのデータ抽出 ＆ 検証テスト
                </div>

                <form id="labUploadForm" action="SignatureLab" method="POST" enctype="multipart/form-data">
                    <input type="file" id="labPdfFile" name="pdfFile" accept="application/pdf" style="display: none;" required>

                    <div class="drop-zone" id="labDropZone">
                        <div class="drop-zone-icon">📄</div>
                        <div class="drop-zone-text">検証したいPDFファイルをここにドラッグ＆ドロップ</div>
                        <div class="drop-zone-subtext">またはクリックしてファイルを選択（署名済み原本、または改ざんしたPDF）</div>
                        <div class="file-name-display" id="selectedFileName" style="display: none;"></div>
                        <button type="submit" class="btn-analyze" id="analyzeBtn" style="display: none;">PDFを解析して検証を実行</button>
                    </div>
                </form>

                <!-- 解析結果の表示エリア -->
                <c:if test="${not empty analyzed}">
                    <div class="data-grid">
                        <div class="data-card">
                            <div class="data-label">■ PDFから抽出した署名者情報・公開鍵</div>
                            <div style="font-size: 13px; font-weight: bold; margin-bottom: 6px;">署名者: ${signerName}</div>
                            <div class="data-label">公開鍵 (SubjectPublicKeyInfo)</div>
                            <div class="data-code" style="max-height: 80px; overflow-y: auto;">${extractedPublicKey}</div>
                        </div>

                        <div class="data-card">
                            <div class="data-label">■ PDF内部から抽出した電子署名データ (Base64)</div>
                            <div class="data-code" style="max-height: 110px; overflow-y: auto;">${extractedSignature}</div>
                        </div>

                        <div class="data-card">
                            <div class="data-label">■ 公開鍵で復号した原本ハッシュ値 (SHA-256)</div>
                            <div class="data-code">${originalHash}</div>
                        </div>

                        <div class="data-card">
                            <div class="data-label">■ アップロードされたPDFから再計算した現在のハッシュ値</div>
                            <div class="data-code">${currentHash}</div>
                        </div>
                    </div>

                    <!-- 判定バナー -->
                    <c:choose>
                        <c:when test="${isValid}">
                            <div class="result-banner result-success">
                                <div>
                                    ✔ 検証成功：原本ハッシュと現在ハッシュが完全一致（MATCH）<br>
                                    <span style="font-size: 12.5px; font-weight: normal;">電子署名が付与されて以降、ファイルは改ざんされていません。</span>
                                </div>
                                <div style="font-size: 20px; font-family: monospace;">VERIFIED</div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="result-banner result-failure">
                                <div>
                                    ⚠ 改ざん検知：ハッシュ値が一致しません（MISMATCH）<br>
                                    <span style="font-size: 12.5px; font-weight: normal;">ファイルが改変されたため、ハッシュ値が不一致となりました。</span>
                                </div>
                                <div style="font-size: 20px; font-family: monospace;">FAILED</div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </c:if>
            </div>

            <!-- ===================================================
               セクション3：テキストエディタでの改ざん方法説明
            =================================================== -->
            <div class="card">
                <div class="section-heading">
                    🛠️ STEP 3：手元のテキストエディタを用いた改ざん実験手順
                </div>

                <div class="tamper-guide">
                    <strong>【改ざん検知テストの手順】</strong>
                    <ol>
                        <li>契約フォルダ詳細画面から、署名済みの<strong>原本PDFをダウンロード</strong>します。</li>
                        <li>ダウンロードしたPDFを右クリックし、<strong>「プログラムから開く」 ➔ 「メモ帳」</strong>等で開きます。</li>
                        <li>ファイル内の英数字を<strong>1文字だけ打ち換えるか、半角スペースを1つ挿入</strong>して上書き保存（Ctrl + S）します。</li>
                        <li>そのファイルを上記 STEP 2 のエリアにドロップすると、<strong>「⚠ FAILED（改ざん検知）」</strong>となる挙動を確認できます。</li>
                    </ol>
                </div>
            </div>

        </div>
    </main>

    <script>
        const dropZone = document.getElementById('labDropZone');
        const fileInput = document.getElementById('labPdfFile');
        const fileNameDisplay = document.getElementById('selectedFileName');
        const analyzeBtn = document.getElementById('analyzeBtn');

        dropZone.addEventListener('click', (e) => {
            if (e.target !== analyzeBtn) {
                fileInput.click();
            }
        });

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
                    showFile(files[0]);
                } else {
                    alert('PDFファイルのみドロップ可能です。');
                }
            }
        });

        fileInput.addEventListener('change', () => {
            if (fileInput.files.length > 0) {
                showFile(fileInput.files[0]);
            }
        });

        function showFile(file) {
            fileNameDisplay.textContent = '選択中: ' + file.name + ' (' + (file.size / 1024).toFixed(1) + ' KB)';
            fileNameDisplay.style.display = 'block';
            analyzeBtn.style.display = 'inline-block';
        }
    </script>

</body>
</html>