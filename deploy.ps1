# Bleak Faith: Forsaken JP localization - deploy pak to Steam install
# Locates the game via Steam library folders and copies the pak to ~mods/.
# Run:  ./deploy.bat   (double-click; auto-elevates)
#  or:  PowerShell -ExecutionPolicy Bypass -File deploy.ps1
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

# Self-elevate if not running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $isAdmin) {
    Write-Host 'Requesting administrator rights...' -ForegroundColor Yellow
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

$pak = 'BleakFaithForsaken_JP_P.pak'
if (-not (Test-Path $pak)) { throw "$pak not found in $PSScriptRoot. Run build.ps1 first." }

# 1. Locate Steam install via registry
$steam = $null
foreach ($key in 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam','HKLM:\SOFTWARE\Valve\Steam','HKCU:\Software\Valve\Steam') {
    try {
        $props = Get-ItemProperty -Path $key -ErrorAction Stop
        $val = $props.InstallPath
        if (-not $val) { $val = $props.SteamPath }
        if ($val -and (Test-Path $val)) { $steam = $val; break }
    } catch {}
}
if (-not $steam) { throw 'Steam install path not found in registry (HKLM/HKCU Valve\Steam).' }
Write-Host "Steam: $steam" -ForegroundColor Cyan

# 2. Enumerate all Steam libraries from libraryfolders.vdf
$vdf = Join-Path $steam 'steamapps\libraryfolders.vdf'
if (-not (Test-Path $vdf)) { throw "libraryfolders.vdf not found: $vdf" }
$libs = @($steam)
foreach ($m in [regex]::Matches((Get-Content $vdf -Raw), '"path"\s+"([^"]+)"')) {
    $p = $m.Groups[1].Value -replace '\\\\','\'
    if ((Test-Path $p) -and ($libs -notcontains $p)) { $libs += $p }
}
Write-Host ("Libraries: {0}" -f ($libs -join '; ')) -ForegroundColor DarkGray

# 3. Find the Bleak Faith: Forsaken install dir
# Detect by inner UE project layout (<install>/Forsaken/Content/Paks) — robust to Steam folder naming.
$gameDir = $null
foreach ($lib in $libs) {
    $common = Join-Path $lib 'steamapps\common'
    if (-not (Test-Path $common)) { continue }
    $hit = Get-ChildItem $common -Directory -ErrorAction SilentlyContinue | Where-Object {
        Test-Path (Join-Path $_.FullName 'Forsaken\Content\Paks')
    } | Select-Object -First 1
    if ($hit) { $gameDir = $hit.FullName; break }
}
if (-not $gameDir) { throw 'Bleak Faith: Forsaken install not found under any Steam library (looked for *\Forsaken\Content\Paks).' }
Write-Host "Game:  $gameDir" -ForegroundColor Cyan

# 4. Copy pak to ~mods/ (create if missing)
$modDir = Join-Path $gameDir 'Forsaken\Content\Paks\~mods'
if (-not (Test-Path $modDir)) {
    New-Item -ItemType Directory -Path $modDir -Force | Out-Null
    Write-Host "Created: $modDir" -ForegroundColor Yellow
}
$dest = Join-Path $modDir $pak
Copy-Item -Path $pak -Destination $dest -Force
Write-Host "Deployed: $dest" -ForegroundColor Green
