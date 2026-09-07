
import model.dao.FolderDAO;
import model.entity.Folder;

public class MainTest {
    public static void main(String[] args) {
        
        System.out.println("データベースへの保存テストを開始します...");

        // 1. 保存したいデータ（Folderエンティティ）を準備する
        Folder folder = new Folder();
        
        // ※注意：H2コンソールで作成した「user_id = 1」のユーザーをセットします
        folder.setCreatedBy(1); 
        
        // その他の適当なダミーデータをセット
        folder.setFolderName("面接用ポートフォリオ契約");
        folder.setTargetCompanyName("株式会社テスト");
        folder.setTargetUserName("採用 太郎");
        folder.setTargetEmail("saiyo@example.com");
        folder.setToken("dummy_token_12345");
        folder.setCertIssuanceAllowed(true);

        // 2. DAOを呼び出してINSERTを実行する
        FolderDAO dao = new FolderDAO();
        int newId = dao.insertFolder(folder);

        // 3. 結果をコンソールに表示する
        if (newId > 0) {
            System.out.println("★大成功！フォルダが保存されました。自動採番されたID: " + newId);
        } else {
            System.out.println("×失敗しました...エラーログを確認してください。");
        }
    }
}