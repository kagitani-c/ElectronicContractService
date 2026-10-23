<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>フォルダ詳細 - ${folder.folderName}</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; margin: 30px 40px; background-color: #f8f9fa; color: #333; }
        .container { background: #fff; border-radius: 8px; padding: 30px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); max-width: 1100px; margin: 0 auto; }
        h2, h3 { color: #212529; }
        table { width: 100%; border-collapse: collapse; margin-top: 12px; margin-bottom: 20px; background: #fff; }
        th, td { border: 1px solid #dee2e6; padding: 10px 12px; font-size: 14px; text-align: left; vertical-align: middle; }
        th { background-color: #f1f3f5; }
        
        /* ドラッグ＆ドロップエリア */
        .drop-zone {
            border: 2px dashed #007bff;
            border-radius: 8px;
            padding: 30px;
            text-align: center;
            background-color: #fdfdfd;
            cursor: pointer;
            transition: all 0.2s ease;
            max-width: 550px;
        }
        .drop-zone.dragover { background-color: #e3f2fd; border-color: #0056b3; transform: scale(1.01); }
        .drop-zone-icon { font-size: 32px; margin-bottom: 6px; }
        .drop-zone-text { color: #495057; font-size: 14px; line-height: 1.5; }
        .file-info { margin-top: 10px; font-weight: bold; color: #28a745; font-size: 13px; display: none; }
        
        .btn { display: inline-block; padding: 6px 12px; border-radius: 4px; font-size: 13px; font-weight: bold; cursor: pointer; text-decoration: none; border: none; }
        .btn-primary { background-color: #007bff; color: white; }
        .btn-primary:hover { background-color: #0056b3; }
        .btn-success { background-color: #28a745; color: white; }
        .btn-success:hover { background-color: #218838; }
        .btn-info { background-color: #17a2b8; color: white; }
        .btn-info:hover { background-color: #117a8b; }
        
        /* モーダルダイアログ */
        dialog { border: none; border-radius: 8px; padding: 25px; width: 440px; box-shadow: 0 4px 20px rgba(0,0,0,0.15); }
        dialog::backdrop { background: rgba(0, 0, 0, 0.4); }

        .back-link { display: inline-block; margin-top: 25px; color: #007bff; text-decoration: none; font-weight: bold; }
        .back-link:hover { text-decoration: underline; }
        
        /* 招待URL用スタイル */
        .copy-input {
            width: 70%;
            padding: 6px 10px;
            border: 1px solid #ced4da;
            border-radius: 4px;
            font-size: 13px;
            background-color: #f8f9fa;
        }
        .btn-copy {
            padding: 6px 12px;
            background-color: #6c757d;
            color: #fff;
            border: none;
            border-radius: 4px;
            font-size: 12px;
            cursor: pointer;
            margin-left: 8px;
            transition: background 0.2s;
        }
        .btn-copy:hover { background-color: #5a6268; }
        .btn-copy.copied { background-color: #28a745; }
    </style>
</head>
<body>

<div class="container">
    <h2>契約フォルダ詳細</h2>

    <!-- 通知バナー -->
    <c:if test="${param.signed == 'true'}">
        <p style="color: #155724; font-weight: bold; background: #d4edda; padding: 10px; border-radius: 4px; border: 1px solid #c3e6cb;">
            ✔ 電子署名の付与（RSA暗号化とハッシュ保存）が完了しました。
        </p>
    </c:if>
    <c:if test="${not empty param.error}">
        <p style="color: #721c24; font-weight: bold; background: #f8d7da; padding: 10px; border-radius: 4px; border: 1px solid #f5c6cb;">
            <c:choose>
                <c:when test="${param.error == 'no_cert'}">⚠ 電子証明書が登録されていません。ダッシュボードまたはユーザー管理画面で発行してください。</c:when>
                <c:when test="${param.error == 'cert_not_found'}">⚠ 証明書ファイルが存在しません。</c:when>
                <c:when test="${param.error == 'file_not_found'}">⚠ 対象のPDFファイルが見つかりません。</c:when>
                <c:otherwise>⚠ 処理に失敗しました。</c:otherwise>
            </c:choose>
        </p>
    </c:if>

    <!-- フォルダ基本情報 -->
    <table>
        <tr><th style="width: 25%;">フォルダ名</th><td>${folder.folderName} (ID: ${folder.folderId})</td></tr>
        <tr><th>宛先企業名</th><td>${folder.targetCompanyName}</td></tr>
        <tr><th>宛先部署名</th><td>${folder.targetDepartmentName}</td></tr>
        <tr><th>担当者名</th><td>${folder.targetUserName}</td></tr>
        <tr><th>メールアドレス</th><td>${folder.targetEmail}</td></tr>
        <tr><th>電子証明書発行の許可</th><td>${folder.certIssuanceAllowed ? '許可する' : '許可しない'}</td></tr>
        <tr>
            <th>招待用 URL（トークン付き）</th>
            <td>
                <!-- ★★★ Renderのドメインに修正 ★★★ -->
                <input type="text" id="inviteUrlInput" class="copy-input" 
                       value="https://electroniccontractservice.onrender.com/GuestLoginServlet?token=${folder.token}" readonly>
                <button type="button" id="copyBtn" class="btn-copy" onclick="copyInviteUrl()">📋 URLをコピー</button>
            </td>
        </tr>
    </table>

    <div style="font-size: 13px; color: #6c757d; margin-bottom: 15px;">
        <c:if test="${not empty folder.updatedAt}">
            最終更新: ${folder.updatedAt} (更新者ID: ${folder.updatedBy}) &nbsp;|&nbsp;
        </c:if>
        <a href="EditFolderServlet?id=${folder.folderId}">[契約フォルダ情報を変更する]</a>
    </div>

    <!-- フォルダ情報変更履歴 -->
    <details style="margin-bottom: 25px; border: 1px solid #dee2e6; border-radius: 6px; padding: 10px; background: #fdfdfd;">
        <summary style="font-size: 13px; font-weight: bold; cursor: pointer; color: #6c757d;">
            フォルダ情報の変更履歴（${empty historyList ? 0 : historyList.size()} 件）
        </summary>
        <c:if test="${not empty historyList}">
            <table style="font-size: 12px; margin-top: 10px; color: #555;">
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
        <c:if test="${empty historyList}"><p style="font-size: 12px; color: #999; margin: 8px 0 0 0;">※ 変更履歴はありません。</p></c:if>
    </details>

    <hr style="border: 0; border-top: 1px solid #eee; margin: 25px 0;">

    <!-- 契約書PDF新規アップロード -->
    <h3>契約書PDFの新規アップロード</h3>
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

        <button type="submit" class="btn btn-primary" id="submitBtn" style="display: none; margin-top: 12px;">
            アップロードを実行する
        </button>
    </form>

    <hr style="border: 0; border-top: 1px solid #eee; margin: 30px 0;">

    <!-- 登録済みの有効な契約書テーブル -->
    <h3>登録済みの契約書データ</h3>
    <c:choose>
        <c:when test="${not empty activeDocumentList}">
            <table>
                <tr style="background-color: #f1f3f5;">
                    <th>ファイル名</th>
                    <th style="width: 18%;">版数</th>
                    <th style="width: 25%;">電子署名ステータス</th>
                    <th style="width: 25%;">操作</th>
                </tr>
                <c:forEach var="doc" items="${activeDocumentList}">
                    <tr>
                        <td><strong>${doc.title}</strong></td>
                        <td>
                            第 ${doc.version} 版
                            <c:choose>
                                <c:when test="${doc.version > 1}">
                                    <span style="font-size: 11px; color: #007bff; background: #e7f1ff; padding: 2px 6px; border-radius: 3px; font-weight: bold; margin-left: 4px;">
                                        差替 ${doc.version - 1} 回
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span style="font-size: 11px; color: #6c757d; margin-left: 4px;">(初版)</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${not empty doc.signatureData}">
                                    <span style="color: #28a745; font-weight: bold;">✔ 署名済み</span>
                                    <c:if test="${not empty doc.signedAt}">
                                        <span style="font-size: 11px; color: #6c757d;">(${doc.signedAt})</span>
                                    </c:if>
                                    <br>
                                    <a href="VerifySignatureServlet?docId=${doc.documentId}" class="btn btn-info" style="font-size: 11px; padding: 2px 6px; margin-top: 4px;">
                                        🔍 署名・ハッシュを検証
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <form action="SignPdfServlet" method="POST" style="margin: 0; display: inline;">
                                        <input type="hidden" name="docId" value="${doc.documentId}">
                                        <input type="hidden" name="folderId" value="${folder.folderId}">
                                        <c:choose>
                                            <c:when test="${not empty sessionScope.loginUser.certificatePath}">
                                                <button type="submit" class="btn btn-success" style="padding: 4px 8px;">✍️ 電子署名を付与</button>
                                            </c:when>
                                            <c:otherwise>
                                                <button type="button" disabled style="padding: 4px 8px; background: #ccc; border: none; border-radius: 4px; color: #666; cursor: not-allowed;" title="先にダッシュボードで証明書を発行してください">
                                                    署名不可 (証明書未登録)
                                                </button>
                                            </c:otherwise>
                                        </c:choose>
                                    </form>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <a href="ViewPdfServlet?docId=${doc.documentId}" target="_blank" style="color: #007bff; text-decoration: none; font-weight: bold;">📄 閲覧</a>
                            &nbsp;|&nbsp;
                            <button type="button" onclick="openReplaceModal(${doc.documentId}, '${doc.title}', ${doc.version})" style="background: none; border: none; color: #007bff; font-weight: bold; cursor: pointer; text-decoration: underline; padding: 0;">
                                🔄 差し替え
                            </button>
                            &nbsp;|&nbsp;
                            <form action="DeletePdfServlet" method="POST" style="display: inline; margin: 0;">
                                <input type="hidden" name="docId" value="${doc.documentId}">
                                <input type="hidden" name="folderId" value="${folder.folderId}">
                                <button type="submit" onclick="return confirm('契約書を削除しますか？\n（削除後は下の履歴テーブルに保管されます）');" style="background: none; border: none; color: #dc3545; font-weight: bold; cursor: pointer; text-decoration: underline; padding: 0;">
                                    🗑️ 削除
                                </button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
            </table>
        </c:when>
        <c:otherwise>
            <p style="color: #6c757d;">※ 現在有効な契約書はありません。上のエリアからPDFをアップロードしてください。</p>
        </c:otherwise>
    </c:choose>

    <!-- 削除・差し替え履歴テーブル（折りたたみ） -->
    <details style="margin-top: 25px; border: 1px solid #ced4da; border-radius: 6px; padding: 12px; background: #fafafa;">
        <summary style="font-weight: bold; cursor: pointer; color: #495057;">
            📜 削除・差し替え履歴を確認する（${empty historyDocumentList ? 0 : historyDocumentList.size()} 件）
        </summary>
        <div style="margin-top: 12px;">
            <c:choose>
                <c:when test="${not empty historyDocumentList}">
                    <table style="font-size: 13px; background: #fff; margin-bottom: 0;">
                        <tr style="background-color: #f1f3f5;">
                            <th>ファイル名</th>
                            <th>版数</th>
                            <th>処理日時</th>
                            <th>操作者ID</th>
                            <th>証拠PDF</th>
                        </tr>
                        <c:forEach var="hDoc" items="${historyDocumentList}">
                            <tr style="color: #6c757d;">
                                <td><del>${hDoc.title}</del></td>
                                <td>第 ${hDoc.version} 版</td>
                                <td>${hDoc.deletedAt}</td>
                                <td>ユーザーID: ${hDoc.deletedBy}</td>
                                <td>
                                    <a href="ViewPdfServlet?docId=${hDoc.documentId}" target="_blank" style="color: #6c757d;">
                                        📄 閲覧
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                    </table>
                </c:when>
                <c:otherwise>
                    <p style="font-size: 13px; color: #888; margin: 5px 0 0 0;">※ 過去の履歴データはありません。</p>
                </c:otherwise>
            </c:choose>
        </div>
    </details>

    <!-- 契約書差し替えモーダルダイアログ -->
    <dialog id="replaceDialog">
        <form action="ReplacePdfServlet" method="POST" enctype="multipart/form-data">
            <input type="hidden" name="folderId" value="${folder.folderId}">
            <input type="hidden" id="modalOldDocId" name="oldDocId" value="">

            <h3 style="margin-top: 0; font-size: 18px;">契約書PDFの差し替え</h3>
            <p style="font-size: 13px; color: #555; line-height: 1.5;">
                対象: <strong id="modalTargetTitle"></strong><br>
                差し替え後は <strong id="modalNextVersion" style="color: #007bff;"></strong> として登録され、現在の版は履歴にアーカイブ保存されます。
            </p>

            <div style="margin: 20px 0;">
                <label style="display: block; font-weight: bold; margin-bottom: 6px; font-size: 13px;">差し替え用PDFファイル:</label>
                <input type="file" name="replacementFile" accept="application/pdf" required style="width: 100%;">
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px;">
                <button type="button" onclick="document.getElementById('replaceDialog').close();" class="btn" style="background: #e9ecef; color: #333;">
                    キャンセル
                </button>
                <button type="submit" class="btn btn-primary">
                    差し替えて登録
                </button>
            </div>
        </form>
    </dialog>

    <a href="FolderListServlet" class="back-link">← フォルダ一覧へ戻る</a>
</div>

<script>
    // URLコピー処理
    function copyInviteUrl() {
        const copyInput = document.getElementById('inviteUrlInput');
        copyInput.select();
        copyInput.setSelectionRange(0, 99999); // モバイル対応

        navigator.clipboard.writeText(copyInput.value).then(() => {
            const copyBtn = document.getElementById('copyBtn');
            const originalText = copyBtn.innerText;
            copyBtn.innerText = '✔ コピー完了！';
            copyBtn.classList.add('copied');
            setTimeout(() => {
                copyBtn.innerText = originalText;
                copyBtn.classList.remove('copied');
            }, 2000);
        }).catch(err => {
            alert('URLのコピーに失敗しました。手動でコピーしてください。');
        });
    }

    // ドラッグ＆ドロップ用スクリプト
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

    // 差し替えダイアログ制御
    function openReplaceModal(docId, title, currentVersion) {
        document.getElementById('modalOldDocId').value = docId;
        document.getElementById('modalTargetTitle').textContent = title + ' (第' + currentVersion + '版)';
        document.getElementById('modalNextVersion').textContent = '第 ' + (currentVersion + 1) + ' 版 (差替 ' + currentVersion + ' 回)';
        document.getElementById('replaceDialog').showModal();
    }
</script>

</body>
</html>