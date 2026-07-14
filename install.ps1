$ErrorActionPreference = 'Stop'

Write-Host '================================================' -ForegroundColor Cyan
Write-Host ' KUAS Wi-Fi 自動ログイン セットアップ' -ForegroundColor Cyan
Write-Host '================================================' -ForegroundColor Cyan
Write-Host ''
Write-Host '[1/2] User ID と Password を登録します。'
Write-Host '      ウィンドウが出たら、いつもWi-Fiログインで使っている'
Write-Host '      User ID と Password を入力してください。'
Write-Host ''

try {
    & (Join-Path $PSScriptRoot 'setup-credentials.ps1')
} catch {
    Write-Host ''
    Write-Host "[エラー] User ID / Password の登録に失敗しました: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host 'Enterキーを押すと閉じます'
    exit 1
}

Write-Host ''
Write-Host '[2/2] 自動実行の設定をします。'
Write-Host ''

try {
    & (Join-Path $PSScriptRoot 'register-task.ps1')
} catch {
    Write-Host ''
    Write-Host "[エラー] 自動実行の登録に失敗しました: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host '        この setup.bat を右クリックして「管理者として実行」からやり直してください。' -ForegroundColor Yellow
    Read-Host 'Enterキーを押すと閉じます'
    exit 1
}

Write-Host ''
Write-Host '================================================' -ForegroundColor Green
Write-Host ' セットアップ完了です!' -ForegroundColor Green
Write-Host ' これで kuas-wlan に繋ぐと自動でログインされます。' -ForegroundColor Green
Write-Host '================================================' -ForegroundColor Green
Read-Host 'Enterキーを押すと閉じます'
