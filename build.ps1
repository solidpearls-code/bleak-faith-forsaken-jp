# Bleak Faith: Forsaken JP localization - build pak from PakSource/
# Packs the PakSource/ tree into BleakFaithForsaken_JP_P.pak using Tools/bin/repak.exe.
# Run:  ./build.ps1   (in PowerShell)
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

$pak  = 'BleakFaithForsaken_JP_P.pak'
$repak = '.\Tools\bin\repak.exe'

if (-not (Test-Path $repak))      { throw 'Tools\bin\repak.exe not found' }
if (-not (Test-Path '.\PakSource')) { throw 'PakSource folder not found' }

& $repak pack PakSource $pak --mount-point ../../../ --version V11

Write-Host "Built: $pak" -ForegroundColor Green
Write-Host "Deploy to: <game>/Forsaken/Content/Paks/~mods/" -ForegroundColor Cyan
