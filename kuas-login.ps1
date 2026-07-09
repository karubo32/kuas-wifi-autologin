# KUAS 京都太秦キャンパス 無線LAN (kuas-wlan) 自動ログイン
$TargetSsid = 'kuas-wlan'
$PortalUrl  = 'https://uzwlan03.kuas.ac.jp/auth/index.html/u'
$CredFile   = Join-Path $PSScriptRoot 'kuas-cred.xml'
$LogFile    = Join-Path $PSScriptRoot 'kuas-login.log'

function Write-Log([string]$Message) {
    "{0} {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message |
        Add-Content -Path $LogFile -Encoding UTF8
}

function Get-CurrentSsid {
    foreach ($line in (netsh wlan show interfaces)) {
        if ($line -match '^\s+SSID\s+:\s*(.+?)\s*$') { return $Matches[1] }
    }
    return $null
}

function Test-Online {
    try {
        $r = Invoke-WebRequest -Uri 'http://www.msftconnecttest.com/connecttest.txt' -UseBasicParsing -TimeoutSec 5
        return ($r.Content -match 'Microsoft Connect Test')
    } catch { return $false }
}

$ssid = Get-CurrentSsid
if ($ssid -ne $TargetSsid) { exit 0 }  # 学内Wi-Fi以外では何もしない

if (Test-Online) { Write-Log "already online (SSID=$ssid)"; exit 0 }

if (-not (Test-Path $CredFile)) {
    Write-Log 'credential file not found - run setup-credentials.ps1 first'
    exit 1
}
$cred = Import-Clixml -Path $CredFile

[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$body = @{
    user     = $cred.UserName
    password = $cred.GetNetworkCredential().Password
}

$maxAttempts = 5
for ($i = 1; $i -le $maxAttempts; $i++) {
    try {
        $resp = Invoke-WebRequest -Uri $PortalUrl -Method Post -Body $body -UseBasicParsing -TimeoutSec 15
        Write-Log ("login POST attempt {0}: HTTP {1}" -f $i, $resp.StatusCode)
        Start-Sleep -Seconds 2
        if (Test-Online) { Write-Log 'login OK - internet reachable'; exit 0 }
    } catch {
        Write-Log ("login POST attempt {0} failed: {1}" -f $i, $_.Exception.Message)
    }
    Start-Sleep -Seconds 3
}
Write-Log 'login FAILED after all attempts'
exit 1
