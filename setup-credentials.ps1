# 初回のみ実行: 大学のUser ID / Passwordを暗号化して保存する
# (Windows DPAPI で暗号化されるため、このPCのこのユーザーでしか復号できません)
# Get-Credential はGUIダイアログを別ウィンドウで開き、フォーカスが当たらず
# 操作できなくなることがあるため、同じコンソール画面内で完結する Read-Host を使う。
$userId = Read-Host 'User ID を入力してください'
$securePassword = Read-Host 'Password を入力してください(画面には表示されません)' -AsSecureString
$cred = New-Object System.Management.Automation.PSCredential($userId, $securePassword)
$cred | Export-Clixml -Path (Join-Path $PSScriptRoot 'kuas-cred.xml')
Write-Host 'kuas-cred.xml に保存しました。' -ForegroundColor Green
