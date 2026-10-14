package controller;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.security.MessageDigest;
import java.security.cert.X509Certificate;
import java.util.Base64;
import java.util.Collection;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.interactive.digitalsignature.PDSignature;
import org.bouncycastle.asn1.ASN1OctetString;
import org.bouncycastle.asn1.cms.Attribute;
import org.bouncycastle.asn1.cms.CMSAttributes;
import org.bouncycastle.cert.X509CertificateHolder;
import org.bouncycastle.cert.jcajce.JcaX509CertificateConverter;
import org.bouncycastle.cms.CMSProcessableByteArray;
import org.bouncycastle.cms.CMSSignedData;
import org.bouncycastle.cms.SignerInformation;
import org.bouncycastle.cms.SignerInformationStore;
import org.bouncycastle.cms.jcajce.JcaSimpleSignerInfoVerifierBuilder;

import model.entity.User;

@WebServlet("/SignatureLab")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1MB
    maxFileSize = 10485760L,             // 10MB
    maxRequestSize = 20971520L           // 20MB
)
public class SignatureLabServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect("Login");
            return;
        }

        request.getRequestDispatcher("/WEB-INF/jsp/signatureLab.jsp").forward(request, response);
    }

    @Override
    @SuppressWarnings("unchecked")
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect("Login");
            return;
        }

        Part filePart = request.getPart("pdfFile");
        if (filePart == null || filePart.getSize() == 0) {
            response.sendRedirect("SignatureLab");
            return;
        }

        byte[] pdfBytes = filePart.getInputStream().readAllBytes();

        try (PDDocument document = PDDocument.load(new ByteArrayInputStream(pdfBytes))) {
            List<PDSignature> signatures = document.getSignatureDictionaries();

            if (signatures.isEmpty()) {
                request.setAttribute("analyzed", true);
                request.setAttribute("isValid", false);
                request.setAttribute("signerName", "未署名ファイル（署名枠が存在しません）");
                request.setAttribute("extractedPublicKey", "N/A");
                request.setAttribute("extractedSignature", "N/A");
                request.setAttribute("originalHash", "未署名のため原本ハッシュなし");
                request.setAttribute("currentHash", calculateSha256(pdfBytes));
                request.getRequestDispatcher("/WEB-INF/jsp/signatureLab.jsp").forward(request, response);
                return;
            }

            // 最新の署名辞書を取得
            PDSignature latestSignature = signatures.get(signatures.size() - 1);

            // 1. PDF内部の署名バイナリ（/Contents）をパース済み辞書から直接取得（引数なしで呼ぶことで構文エラーを防止）
            byte[] signatureContents = latestSignature.getContents();
            // 署名対象範囲（/ByteRange）の本文バイト列を取得
            byte[] signedByteRange = latestSignature.getSignedContent(new ByteArrayInputStream(pdfBytes));

            // 分離署名（Detached）のため、本文データ（signedByteRange）を一緒に渡してCMSSignedDataを構築
            CMSProcessableByteArray processable = new CMSProcessableByteArray(signedByteRange);
            CMSSignedData cms = new CMSSignedData(processable, signatureContents);
            SignerInformationStore signers = cms.getSignerInfos();
            SignerInformation signer = signers.getSigners().iterator().next();

            // 2. 署名パケットから署名者のX.509証明書と公開鍵を抽出
            Collection<X509CertificateHolder> matches = cms.getCertificates().getMatches(signer.getSID());
            X509CertificateHolder certHolder = matches.iterator().next();
            X509Certificate cert = new JcaX509CertificateConverter().getCertificate(certHolder);

            String signerName = latestSignature.getName() != null ? latestSignature.getName() : cert.getSubjectX500Principal().getName();
            String extractedPublicKey = Base64.getEncoder().encodeToString(cert.getPublicKey().getEncoded());
            String extractedSignature = Base64.getEncoder().encodeToString(signer.getSignature());

            // 3. 署名属性（SignedAttributes）から原本ハッシュ値を直接抽出
            String originalHash = "N/A";
            if (signer.getSignedAttributes() != null) {
                Attribute messageDigestAttr = signer.getSignedAttributes().get(CMSAttributes.messageDigest);
                if (messageDigestAttr != null) {
                    ASN1OctetString octet = (ASN1OctetString) messageDigestAttr.getAttrValues().getObjectAt(0);
                    originalHash = toHexString(octet.getOctets());
                }
            }

            // 4. アップロードされたPDFの署名対象バイト範囲から現在のハッシュ値を再計算
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] currentDigest = md.digest(signedByteRange);
            String currentHash = toHexString(currentDigest);

            // 5. Bouncy Castleによる暗号数学的検証（署名者の公開鍵で署名を検証）
            boolean isCryptoValid = false;
            try {
                isCryptoValid = signer.verify(new JcaSimpleSignerInfoVerifierBuilder().build(cert));
            } catch (Exception e) {
                e.printStackTrace();
                isCryptoValid = false;
            }

            // 原本ハッシュと現在ハッシュが一致し、かつ公開鍵暗号検証も通っていること
            boolean isValid = isCryptoValid && originalHash.equalsIgnoreCase(currentHash);

            // 画面表示用スコープにセット
            request.setAttribute("analyzed", true);
            request.setAttribute("isValid", isValid);
            request.setAttribute("signerName", signerName);
            request.setAttribute("extractedPublicKey", extractedPublicKey);
            request.setAttribute("extractedSignature", extractedSignature);
            request.setAttribute("originalHash", originalHash);
            request.setAttribute("currentHash", currentHash);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("analyzed", true);
            request.setAttribute("isValid", false);
            request.setAttribute("signerName", "解析エラー（破損したPDFまたは未対応形式）");
            request.setAttribute("extractedPublicKey", "Error: " + e.getMessage());
            request.setAttribute("extractedSignature", "Error");
            request.setAttribute("originalHash", "Error");
            request.setAttribute("currentHash", "Error");
        }

        request.getRequestDispatcher("/WEB-INF/jsp/signatureLab.jsp").forward(request, response);
    }

    private String toHexString(byte[] bytes) {
        if (bytes == null) return "N/A";
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }

    private String calculateSha256(byte[] data) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            return toHexString(md.digest(data));
        } catch (Exception e) {
            return "N/A";
        }
    }
}