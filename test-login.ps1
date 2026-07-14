$LogFile = Join-Path $PSScriptRoot 'kuas-login.log'

Write-Host 'kuas-wlan に接続中の状態で、いま手動でログインを試します...'
Write-Host ''

try {
    Start-ScheduledTask -TaskName 'KUAS-WiFi-AutoLogin'
} catch {
    Write-Host "[エラー] タスクが見つかりません。先に setup.bat を実行してください: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host 'Enterキーを押すと閉じます'
    exit 1
}

Start-Sleep -Seconds 8

Write-Host ''
Write-Host '---- kuas-login.log の最後の5行 ----'
if (Test-Path $LogFile) {
    Get-Content $LogFile -Tail 5
} else {
    Write-Host 'まだログがありません(kuas-wlanに接続していない可能性があります)'
}
Write-Host ''
Read-Host 'Enterキーを押すと閉じます'
