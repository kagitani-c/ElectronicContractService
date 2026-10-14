package util;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.security.PrivateKey;
import java.security.cert.Certificate;
import java.security.cert.X509Certificate;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.interactive.digitalsignature.PDSignature;
import org.apache.pdfbox.pdmodel.interactive.digitalsignature.SignatureInterface;
import org.apache.pdfbox.pdmodel.interactive.digitalsignature.SignatureOptions;
import org.bouncycastle.cert.jcajce.JcaCertStore;
import org.bouncycastle.cms.CMSProcessableByteArray;
import org.bouncycastle.cms.CMSSignedData;
import org.bouncycastle.cms.CMSSignedDataGenerator;
import org.bouncycastle.cms.jcajce.JcaSignerInfoGeneratorBuilder;
import org.bouncycastle.operator.ContentSigner;
import org.bouncycastle.operator.jcajce.JcaContentSignerBuilder;
import org.bouncycastle.operator.jcajce.JcaDigestCalculatorProviderBuilder;

public class PadesSignatureUtil {

    /**
     * 原本PDFに対してPAdES規格の電子署名を付与し、署名済みPDFを生成する
     *
     * @param srcFile    原本PDFファイル
     * @param signedFile 署名後に保存するPDFファイル
     * @param privateKey 署名者の秘密鍵
     * @param cert       署名者の電子証明書（X.509）
     * @param reason     署名理由（例: "契約締結の合意証明"）
     * @param location   署名場所（例: "Tokyo, Japan"）
     */
    public static void signPdfPades(File srcFile, File signedFile, PrivateKey privateKey,
                                    Certificate cert, String reason, String location) throws Exception {

        try (PDDocument document = PDDocument.load(srcFile);
             FileOutputStream fos = new FileOutputStream(signedFile)) {

            // 1. PDF内に署名用の枠（PDSignature）を設定
            PDSignature signature = new PDSignature();
            signature.setFilter(PDSignature.FILTER_ADOBE_PPKLITE); // Adobe標準フィルタ
            signature.setSubFilter(PDSignature.SUBFILTER_ADBE_PKCS7_DETACHED); // PAdES基本形式
            signature.setName("電子契約システム署名者");
            signature.setLocation(location);
            signature.setReason(reason);
            signature.setSignDate(Calendar.getInstance());

            // 2. 署名オプションの設定（視覚的スタンプなし、メタデータ署名枠）
            SignatureOptions signatureOptions = new SignatureOptions();
            signatureOptions.setPreferredSignatureSize(SignatureOptions.DEFAULT_SIGNATURE_SIZE * 2);

            // 3. BouncyCastleを用いた署名インターフェースを登録
            SignatureInterface signingImplementation = new SignatureInterface() {
                @Override
                public byte[] sign(InputStream content) throws java.io.IOException {
                    try {
                        List<Certificate> certList = new ArrayList<>();
                        certList.add(cert);
                        JcaCertStore certs = new JcaCertStore(certList);

                        // SHA-256 + RSA 署名生成エンジンの組み立て
                        ContentSigner sha256Signer = new JcaContentSignerBuilder("SHA256withRSA")
                                .build(privateKey);

                        CMSSignedDataGenerator gen = new CMSSignedDataGenerator();
                        gen.addSignerInfoGenerator(new JcaSignerInfoGeneratorBuilder(
                                new JcaDigestCalculatorProviderBuilder().build())
                                .build(sha256Signer, (X509Certificate) cert));
                        gen.addCertificates(certs);

                        // PDFの対象バイト列を読み込んで署名データ（CMS）を生成
                        byte[] pdfContentBytes = content.readAllBytes();
                        CMSProcessableByteArray msg = new CMSProcessableByteArray(pdfContentBytes);
                        CMSSignedData signedData = gen.generate(msg, false);

                        return signedData.getEncoded();
                    } catch (Exception e) {
                        throw new java.io.IOException("署名生成に失敗しました", e);
                    }
                }
            };

            // 署名枠をドキュメントに追加し、ストリーム出力
            document.addSignature(signature, signingImplementation, signatureOptions);
            document.saveIncremental(fos);
        }
    }
}