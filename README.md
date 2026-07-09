# kuas-wifi-autologin

京都先端科学大学(KUAS)太秦キャンパスの無線LAN `kuas-wlan` に接続した際、
キャプティブポータルへのログイン(User ID / Password の入力)を自動化する
Windows PowerShell スクリプト集です。

同じ形式のキャプティブポータル(`user` / `password` フィールドを持つログインフォーム)
であれば、他の環境でも `$TargetSsid` と `$PortalUrl` を書き換えるだけで流用できます。

## できること

- 指定したSSID(既定: `kuas-wlan`)に接続しているときだけ動作
- すでにインターネットに出られる場合は何もしない
- ポータルが必要なら自動でログインPOSTを送信(失敗時は最大5回リトライ)
- Windows タスクスケジューラに登録し、Wi-Fi接続イベント発生時とログオン時に自動実行

## セットアップ

1. このリポジトリをクローン、または zip でダウンロード
2. 認証情報を保存(初回のみ)

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\setup-credentials.ps1
   ```

   入力した User ID / Password は Windows DPAPI で暗号化され、
   `kuas-cred.xml` としてこのフォルダに保存されます(このPC・このユーザーでしか復号不可)。
   このファイルは `.gitignore` で除外されているため、誤ってコミットされません。

3. タスクスケジューラに登録

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\register-task.ps1
   ```

   タスク名 `KUAS-WiFi-AutoLogin` が登録され、以後は自動的に動作します。

## 手動実行・動作確認

```powershell
Start-ScheduledTask -TaskName 'KUAS-WiFi-AutoLogin'
```

実行結果は同フォルダの `kuas-login.log` に記録されます。

## 他の大学・施設のポータルで使う場合

`kuas-login.ps1` 冒頭の以下を書き換えてください。ポータルのPOSTフォームの
フィールド名(`user` / `password` 相当)が異なる場合は `$body` のキーも合わせて変更します。

```powershell
$TargetSsid = 'kuas-wlan'
$PortalUrl  = 'https://uzwlan03.kuas.ac.jp/auth/index.html/u'
```

## 注意事項

- 認証情報は平文でファイルに保存されません(DPAPI暗号化、端末・ユーザー紐付け)。
  他のPCやユーザーにはコピーしても使えません。
- ポータル証明書の検証は無効化していません。証明書エラーで失敗する場合は
  `kuas-login.log` を確認のうえ、必要な範囲で対処してください。
- 自己責任でご利用ください。ポータルの利用規約に従ってください。
