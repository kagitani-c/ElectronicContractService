<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>電子署名・改ざん検証ビューアー - ${doc.title}</title>
    <style>
        :root {
            --primary: #0d6efd;
            --primary-dark: #0a58ca;
            --success: #198754;
            --success-bg: #d1e7dd;
            --danger: #dc3545;
            --danger-bg: #f8d7da;
            --gray-bg: #f8f9fa;
            --border-color: #dee2e6;
            --text-dark: #212529;
            --text-muted: #6c757d;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            margin: 30px auto;
            background-color: #f4f6f9;
            color: var(--text-dark);
            line-height: 1.6;
        }

        .container {
            background: #fff;
            border-radius: 12px;
            padding: 35px 40px;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.06);
            max-width: 1140px;
            margin: 0 auto;
        }

        /* 1. パンくずリスト */
        .breadcrumb-nav {
            margin-bottom: 25px;
            padding: 10px 16px;
            background-color: var(--gray-bg);
            border-radius: 6px;
            border: 1px solid var(--border-color);
        }
        .breadcrumb-list {
            display: flex;
            align-items: center;
            list-style: none;
            margin: 0;
            padding: 0;
            font-size: 13px;
        }
        .breadcrumb-item a {
            color: var(--primary);
            text-decoration: none;
            font-weight: 500;
        }
        .breadcrumb-item a:hover {
            text-decoration: underline;
        }
        .breadcrumb-separator {
            margin: 0 10px;
            color: #adb5bd;
            user-select: none;
        }
        .breadcrumb-item.current {
            color: var(--text-dark);
            font-weight: 600;
        }

        /* ページヘッダー */
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            border-bottom: 2px solid var(--primary);
            padding-bottom: 15px;
            margin-bottom: 25px;
        }
        .page-header h2 {
            margin: 0;
            font-size: 24px;
            color: var(--text-dark);
        }
        .page-header .subtitle {
            font-size: 13px;
            color: var(--text-muted);
            margin-top: 5px;
        }

        /* 文書メタデータバー */
        .doc-meta-card {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background-color: var(--gray-bg);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 16px 20px;
            margin-bottom: 30px;
        }
        .doc-meta-info {
            display: flex;
            gap: 20px;
            font-size: 14px;
        }
        .meta-tag {
            background: #e9ecef;
            padding: 3px 8px;
            border-radius: 4px;
            font-weight: bold;
            color: #495057;
            font-size: 12px;
        }
        .doc-actions {
            display: flex;
            gap: 10px;
        }

        /* ボタンスタイル */
        .btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 14px;
            font-size: 13px;
            font-weight: 600;
            border-radius: 6px;
            text-decoration: none;
            cursor: pointer;
            border: 1px solid transparent;
            transition: all 0.2s;
        }
        .btn-outline-primary {
            background: #fff;
            border-color: var(--primary);
            color: var(--primary);
        }
        .btn-outline-primary:hover {
            background: var(--primary);
            color: #fff;
        }
        .btn-primary {
            background: var(--primary);
            color: #fff;
        }
        .btn-primary:hover {
            background: var(--primary-dark);
        }

        /* セクション共通 */
        .section-title {
            font-size: 18px;
            font-weight: 700;
            margin-top: 35px;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 8px;
            color: var(--text-dark);
        }

        /* 2. ロジック解説・対比表 */
        .logic-card {
            background: #fff;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 20px 24px;
            margin-bottom: 30px;
        }
        .logic-desc {
            font-size: 14px;
            color: #495057;
            margin-bottom: 18px;
            line-height: 1.7;
        }
        .comparison-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }
        .comparison-table th, .comparison-table td {
            border: 1px solid var(--border-color);
            padding: 10px 14px;
            text-align: left;
        }
        .comparison-table th {
            background-color: #f1f3f5;
            width: 25%;
        }
        .comparison-table td {
            width: 37.5%;
        }
        .highlight-col {
            background-color: #f8fbff;
        }

        /* 3. 暗号学的証明パネル（生データ対比） */
        .crypto-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }
        .crypto-box {
            background: #ffffff;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 18px;
        }
        .crypto-box h4 {
            margin: 0 0 12px 0;
            font-size: 15px;
            color: var(--text-dark);
            border-bottom: 1px solid #eee;
            padding-bottom: 6px;
        }
        .field-label {
            font-size: 12px;
            font-weight: 600;
            color: var(--text-muted);
            margin-bottom: 6px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .hash-code {
            font-family: SFMono-Regular, Consolas, "Liberation Mono", Menlo, monospace;
            background: #212529;
            color: #79c0ff;
            border-radius: 6px;
            padding: 10px 12px;
            font-size: 12px;
            word-break: break-all;
            line-height: 1.5;
            margin-bottom: 12px;
        }
        .copy-btn {
            background: #495057;
            color: #fff;
            border: none;
            border-radius: 4px;
            padding: 2px 6px;
            font-size: 11px;
            cursor: pointer;
        }
        .copy-btn:hover { background: #343a40; }

        /* 検証結果バナー */
        .status-banner {
            padding: 16px 20px;
            border-radius: 8px;
            font-size: 15px;
            font-weight: bold;
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 35px;
        }
        .status-banner.success {
            background-color: var(--success-bg);
            color: var(--success);
            border: 1px solid #badbcc;
        }
        .status-banner.failure {
            background-color: var(--danger-bg);
            color: var(--danger);
            border: 1px solid #f5c2c7;
        }

        /* 4. 改ざん検知ラボ（アップロード実証） */
        .lab-card {
            background: var(--gray-bg);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 25px;
        }
        .lab-steps {
            background: #fff;
            border-left: 4px solid var(--primary);
            padding: 12px 18px;
            border-radius: 0 6px 6px 0;
            margin-bottom: 20px;
            font-size: 13px;
            color: #495057;
        }
        .lab-steps ol {
            margin: 6px 0 0 0;
            padding-left: 20px;
        }
        .drop-zone {
            border: 2px dashed var(--primary);
            border-radius: 8px;
            padding: 35px 20px;
            text-align: center;
            background: #fff;
            cursor: pointer;
            transition: all 0.2s ease;
            max-width: 600px;
            margin: 0 auto 20px auto;
        }
        .drop-zone.dragover {
            background-color: #e7f1ff;
            border-color: var(--primary-dark);
            transform: scale(1.01);
        }
        .drop-zone-icon { font-size: 36px; margin-bottom: 6px; }
        .drop-zone-text { color: var(--text-dark); font-size: 14px; }
        .file-selected-msg {
            margin-top: 10px;
            font-weight: bold;
            color: var(--primary);
            font-size: 13px;
        }

        /* アップロード結果対比枠 */
        .lab-result-box {
            background: #fff;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 20px;
            margin-top: 20px;
        }

        .back-link {
            display: inline-block;
            margin-top: 30px;
            color: var(--primary);
            text-decoration: none;
            font-weight: 600;
            font-size: 14px;
        }
        .back-link:hover { text-decoration: underline; }
    </style>
</head>
<body>

<div class="container">

    <!-- 1. パンくずリストナビゲーション -->
    <nav class="breadcrumb-nav">
        <ul class="breadcrumb-list">
            <li class="breadcrumb-item">
                <a href="FolderListServlet">ダッシュボード</a>
            </li>
            <li class="breadcrumb-separator">›</li>
            <li class="breadcrumb-item">
                <a href="FolderListServlet">契約フォルダー一覧</a>
            </li>
            <li class="breadcrumb-separator">›</li>
            <li class="breadcrumb-item">
                <a href="FolderDetailServlet?id=${doc.folderId}">フォルダ詳細</a>
            </li>
            <li class="breadcrumb-separator">›</li>
            <li class="breadcrumb-item current" aria-current="page">
                電子署名・改ざん検証ビューアー
            </li>
        </ul>
    </nav>

    <!-- ページタイトルヘッダー -->
    <div class="page-header">
        <div>
            <h2>電子署名・改ざん検証ビューアー</h2>
            <div class="subtitle">原本性証明エンジン ＆ 改ざん検知インタラクティブラボ</div>
        </div>
    </div>

    <!-- 文書メタデータバー -->
    <div class="doc-meta-card">
        <div class="doc-meta-info">
            <div><strong>対象契約書:</strong> ${doc.title}</div>
            <div><span class="meta-tag">第 ${doc.version} 版</span></div>
            <div><strong>署名日時:</strong> ${doc.signedAt}</div>
        </div>
        <div class="doc-actions">
            <!-- 別タブプレビュー -->
            <a href="ViewPdfServlet?docId=${doc.documentId}" target="_blank" class="btn btn-outline-primary">
                📄 PDFを閲覧
            </a>
            <!-- 実験用ダウンロード -->
            <a href="ViewPdfServlet?docId=${doc.documentId}" download="${doc.title}" class="btn btn-primary">
                📥 原本PDFをダウンロード
            </a>
        </div>
    </div>

    <!-- 2. ロジック解説セクション（対比説明） -->
    <div class="section-title">
        💡 電子署名アーキテクチャの解説
    </div>
    <div class="logic-card">
        <div class="logic-desc">
            一般的な実務の電子署名では、第三者認証局（CA）発行の証明書を使用し、PDF内部に署名データをバイナリ埋め込み（PAdES規格）することで、Adobe Acrobat等の外部リーダー単体での検証を可能にしています。<br>
            本サービスでは、鍵・証明書を自前生成する構成を採りつつも、<strong>暗号アルゴリズム（RSA-2048 / SHA-256）の数学的原理と非改ざん性証明プロセスをそのまま再現</strong>しています。
        </div>

        <table class="comparison-table">
            <thead>
                <tr>
                    <th>比較項目</th>
                    <th>一般的な実務電子署名（商用CA）</th>
                    <th class="highlight-col">本システム（ポートフォリオ実装）</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <th>電子証明書の発行元</th>
                    <td>公的な第三者認証局（CA）が厳格に審査・発行</td>
                    <td class="highlight-col"><strong>システム内部でRSA鍵ペア・X.509証明書を自動生成</strong></td>
                </tr>
                <tr>
                    <th>署名データの構造</th>
                    <td>PDFファイル内部に署名辞書として埋め込み</td>
                    <td class="highlight-col"><strong>PDFBox・BouncyCastleによるPAdES準拠署名 ＆ DB保持</strong></td>
                </tr>
                <tr>
                    <th>改ざん検証のアプローチ</th>
                    <td>Acrobatなどの外部PDFリーダーで自己完結検証</td>
                    <td class="highlight-col"><strong>外部リーダー検証に加え、当ビューアーでハッシュ生データを可視化</strong></td>
                </tr>
            </tbody>
        </table>
    </div>

    <!-- 3. 暗号学的証明パネル（生データ照合） -->
    <div class="section-title">
        🔐 原本性証明データ（サーバー上データの数学的照合）
    </div>

    <div class="crypto-grid">
        <!-- 署名生成時データ -->
        <div class="crypto-box">
            <h4>■ 署名時に確定したデータ</h4>
            
            <div class="field-label">
                <span>原本PDFから算出したハッシュ値 (SHA-256)</span>
                <button type="button" class="copy-btn" onclick="copyText('hashOriginal', this)">コピー</button>
            </div>
            <div class="hash-code" id="hashOriginal">${doc.fileHash}</div>

            <div class="field-label">
                <span>暗号化された電子署名データ (Base64)</span>
                <button type="button" class="copy-btn" onclick="copyText('sigData', this)">コピー</button>
            </div>
            <div class="hash-code" id="sigData" style="max-height: 80px; overflow-y: auto;">${doc.signatureData}</div>
        </div>

        <!-- 現在の検証データ -->
        <div class="crypto-box">
            <h4>■ 署名検証プロセス（公開鍵による復号）</h4>

            <div class="field-label">
                <span>電子署名を署名者の公開鍵で復号したハッシュ値</span>
                <button type="button" class="copy-btn" onclick="copyText('hashDecrypted', this)">コピー</button>
            </div>
            <div class="hash-code" id="hashDecrypted">${decryptedHash}</div>

            <div class="field-label">
                <span>サーバー上のPDF実体から再計算した現在のハッシュ値</span>
                <button type="button" class="copy-btn" onclick="copyText('hashCurrent', this)">コピー</button>
            </div>
            <div class="hash-code" id="hashCurrent">${currentFileHash}</div>
        </div>
    </div>

    <!-- 判定バナー -->
    <c:choose>
        <c:when test="${isVerified && (doc.fileHash == decryptedHash) && (currentFileHash == decryptedHash)}">
            <div class="status-banner success">
                <div>
                    ✔ 暗号学的検証に成功：原本ハッシュと復号ハッシュが完全一致（MATCH）しました<br>
                    <span style="font-size: 13px; font-weight: normal;">電子署名が付与されて以降、サーバー上のPDFは1バイトも改ざんされておらず、真正性が証明されています。</span>
                </div>
                <div style="font-size: 20px; font-family: monospace;">VERIFIED</div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="status-banner failure">
                <div>
                    ⚠ 検証不一致：原本ハッシュと復号ハッシュが一致しません（MISMATCH）<br>
                    <span style="font-size: 13px; font-weight: normal;">PDFファイルが改ざんされたか、異なる証明書鍵で復号された可能性があります。</span>
                </div>
                <div style="font-size: 20px; font-family: monospace;">FAILED</div>
            </div>
        </c:otherwise>
    </c:choose>

    <!-- 4. 改ざん検知・検証ラボ（手元ファイル実証） -->
    <div class="section-title">
        🛠️ 改ざん検知検証ラボ（手元ファイルでの実証テスト）
    </div>

    <div class="lab-card">
        <div class="lab-steps">
            <strong>【改ざん検知の実験手順】</strong>
            <ol>
                <li>上部の「📥 原本PDFをダウンロード」からファイルを保存します。</li>
                <li>手元のメモ帳などのテキストエディタでPDFを開き、<strong>適当な文字を1文字だけ打ち換えて上書き保存</strong>します。</li>
                <li>改ざんしたファイルを下のエリアにドラッグ＆ドロップすると、SHA-256ハッシュが雪崩のように変化して検証が失敗する挙動をテストできます。</li>
            </ol>
        </div>

        <form id="verifyUploadForm" action="VerifySignatureServlet" method="POST" enctype="multipart/form-data">
            <input type="hidden" name="docId" value="${doc.documentId}">
            <input type="file" id="pdfFileInput" name="uploadPdfFile" accept="application/pdf" style="display: none;" required>

            <div class="drop-zone" id="dropZone">
                <div class="drop-zone-icon">📄</div>
                <div class="drop-zone-text">
                    ここに手元で編集したPDFを<strong>ドラッグ＆ドロップ</strong><br>
                    またはクリックしてファイルを選択
                </div>
                <div class="file-selected-msg" id="fileSelectedMsg" style="display: none;"></div>
                <button type="submit" class="btn btn-primary" id="uploadRunBtn" style="display: none; margin-top: 15px;">
                    アップロードして改ざん検知を実行
                </button>
            </div>
        </form>

        <!-- アップロード検証結果の表示 -->
        <c:if test="${not empty uploadedFileHash}">
            <div class="lab-result-box">
                <h4 style="margin-top: 0; font-size: 15px;">■ アップロードされたファイルの照合結果</h4>
                
                <div class="field-label">
                    <span>アップロードファイル名</span>
                </div>
                <div style="font-size: 13px; font-weight: bold; margin-bottom: 10px;">${uploadedFileName}</div>

                <div class="field-label">
                    <span>アップロードされたファイルから算出したハッシュ値 (SHA-256)</span>
                    <button type="button" class="copy-btn" onclick="copyText('uploadHash', this)">コピー</button>
                </div>
                <div class="hash-code" id="uploadHash">${uploadedFileHash}</div>

                <div class="field-label">
                    <span>署名復号ハッシュ値（原本の正解データ）</span>
                </div>
                <div class="hash-code" style="color: #adb5bd;">${decryptedHash}</div>

                <!-- 判定結果 -->
                <div style="margin-top: 15px; padding: 12px 16px; border-radius: 6px; font-size: 14px; font-weight: bold; ${uploadedIsVerified ? 'background: #d1e7dd; color: #0f5132;' : 'background: #f8d7da; color: #842029;'}">
                    <c:choose>
                        <c:when test="${uploadedIsVerified}">
                            ✔ 検証成功：アップロードされたファイルは原本と完全一致しており、改ざんされていません。
                        </c:when>
                        <c:otherwise>
                            ⚠ 検証失敗（改ざん検知）：ファイルハッシュが原本署名の復号値と一致しません。ファイルが1バイト以上書き換えられています。
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </c:if>
    </div>

    <a href="FolderDetailServlet?id=${doc.folderId}" class="back-link">← フォルダ詳細画面へ戻る</a>
</div>

<script>
    // クリップボードコピー
    function copyText(elementId, btn) {
        const text = document.getElementById(elementId).innerText.trim();
        navigator.clipboard.writeText(text).then(function() {
            const originalText = btn.innerText;
            btn.innerText = '✔ 完了';
            setTimeout(function() { btn.innerText = originalText; }, 1500);
        });
    }

    // ドラッグ＆ドロップ連動
    const dropZone = document.getElementById('dropZone');
    const fileInput = document.getElementById('pdfFileInput');
    const fileSelectedMsg = document.getElementById('fileSelectedMsg');
    const uploadRunBtn = document.getElementById('uploadRunBtn');

    dropZone.addEventListener('click', (e) => {
        if (e.target !== uploadRunBtn) {
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
                showSelectedFile(files[0]);
            } else {
                alert('PDFファイルのみドロップ可能です。');
            }
        }
    });

    fileInput.addEventListener('change', () => {
        if (fileInput.files.length > 0) {
            showSelectedFile(fileInput.files[0]);
        }
    });

    function showSelectedFile(file) {
        fileSelectedMsg.textContent = '選択中: ' + file.name + ' (' + (file.size / 1024).toFixed(1) + ' KB)';
        fileSelectedMsg.style.display = 'block';
        uploadRunBtn.style.display = 'inline-block';
    }
</script>

</body>
</html>