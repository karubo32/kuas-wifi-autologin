# タスクスケジューラに自動ログインタスクを登録する(管理者権限不要)
# トリガー: 1) 無線LAN接続イベント (WLAN-AutoConfig 8001)  2) ログオン20秒後
$ScriptPath = Join-Path $PSScriptRoot 'kuas-login.ps1'
$TaskName   = 'KUAS-WiFi-AutoLogin'

$action = New-ScheduledTaskAction -Execute 'powershell.exe' `
    -Argument ('-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "{0}"' -f $ScriptPath)

$eventTrigger = Get-CimClass -ClassName MSFT_TaskEventTrigger -Namespace Root/Microsoft/Windows/TaskScheduler |
    New-CimInstance -ClientOnly
$eventTrigger.Enabled = $true
$eventTrigger.Subscription = '<QueryList><Query Id="0" Path="Microsoft-Windows-WLAN-AutoConfig/Operational"><Select Path="Microsoft-Windows-WLAN-AutoConfig/Operational">*[System[(EventID=8001)]]</Select></Query></QueryList>'

$logonTrigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$logonTrigger.Delay = 'PT20S'

$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
    -StartWhenAvailable -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Minutes 5)

Register-ScheduledTask -TaskName $TaskName -Action $action `
    -Trigger @($eventTrigger, $logonTrigger) -Settings $settings -Force | Out-Null

Write-Host "タスク '$TaskName' を登録しました。" -ForegroundColor Green
