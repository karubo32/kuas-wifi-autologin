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

# 授業開始直後などアクセスが集中してポータルが混雑している時間帯でも
# 諦めずに再試行し続けられるよう、待ち時間を徐々に延ばしながら粘る(合計 約2分)。
$maxAttempts    = 6
$backoffSeconds = @(5, 10, 15, 20, 25)  # 各試行の後の待ち時間(混雑緩和を待つ)

for ($i = 1; $i -le $maxAttempts; $i++) {
    try {
        $resp = Invoke-WebRequest -Uri $PortalUrl -Method Post -Body $body -UseBasicParsing -TimeoutSec 15
        Write-Log ("login POST attempt {0}/{1}: HTTP {2}" -f $i, $maxAttempts, $resp.StatusCode)
        Start-Sleep -Seconds 2
        if (Test-Online) { Write-Log 'login OK - internet reachable'; exit 0 }
    } catch {
        Write-Log ("login POST attempt {0}/{1} failed (server busy?): {2}" -f $i, $maxAttempts, $_.Exception.Message)
    }
    if ($i -lt $maxAttempts) {
        $wait = $backoffSeconds[$i - 1]
        Write-Log ("waiting {0}s before retry" -f $wait)
        Start-Sleep -Seconds $wait
    }
}
Write-Log 'login FAILED after all attempts (portal may still be congested - it will retry on the next Wi-Fi reconnect)'
exit 1
