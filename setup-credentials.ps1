# 初回のみ実行: 大学のUser ID / Passwordを暗号化して保存する
# (Windows DPAPI で暗号化されるため、このPCのこのユーザーでしか復号できません)
$cred = Get-Credential -Message 'KUAS 無線LAN の User ID と Password を入力してください'
$cred | Export-Clixml -Path (Join-Path $PSScriptRoot 'kuas-cred.xml')
Write-Host 'kuas-cred.xml に保存しました。' -ForegroundColor Green
