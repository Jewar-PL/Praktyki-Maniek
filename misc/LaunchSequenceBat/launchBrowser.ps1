param(
    [string]$BaseUrl = "http://localhost"
)

Add-Type -AssemblyName System.Windows.Forms
$monitors = [System.Windows.Forms.Screen]::AllScreens
$primary  = $monitors | Where-Object { $_.Primary }

function Start-ChromeApp($url, $scr) {
    $p = "--window-position=$($scr.Bounds.X),$($scr.Bounds.Y)"
    $s = "--window-size=$($scr.Bounds.Width),$($scr.Bounds.Height)"
    $dataDir = "--user-data-dir=`"c:\$($scr.DeviceName.TrimStart('\\.\').Replace('\','_'))`""

    Start-Process "chrome.exe" @(
        "--new-window",
        "--app=$url",
        $p, $s, "--kiosk", "--incognito",
        "--use-fake-ui-for-media-stream",
        "--autoplay-policy=no-user-gesture-required",
        "--disable-cache",
        $dataDir
    )
}

Write-Output "Detected primary monitor: $($primary.DeviceName)"
Start-ChromeApp "$BaseUrl/index.html" $primary

$secondary = $monitors | Where-Object { -not $_.Primary } | Select-Object -First 1
if ($secondary) {
    Write-Output "Detected secondary monitor: $($secondary.DeviceName)"
    Start-ChromeApp "$BaseUrl/tv-player.php" $secondary
}
