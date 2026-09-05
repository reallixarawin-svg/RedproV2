# ==========================================================
# Redpro Setting V2 - One-Line Cloud Bootstrap Installer
# ==========================================================

# ซ่อน Raw URL ด้วย Byte Array
$rawUrl = [System.Text.Encoding]::UTF8.GetString([byte[]]@(104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,114,101,97,108,108,105,120,97,114,97,119,105,110,45,115,118,103,47,82,101,100,112,114,111,86,50,47,109,97,105,110,47,105,110,115,116,97,108,108,46,112,115,49))

# 1. ตรวจสอบสิทธิ์ Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Elevating to Administrator..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm $rawUrl | iex`"" -Verb RunAs
    exit
}

$repoName  = "RedproV2"
$targetDir = "$env:LOCALAPPDATA\$repoName"
$zipPath   = "$env:TEMP\$repoName.zip"

# ซ่อน ZIP URL ด้วย Byte Array
$zipUrl    = [System.Text.Encoding]::UTF8.GetString([byte[]]@(104,116,116,112,115,58,47,47,103,105,116,104,117,98,46,99,111,109,47,114,101,97,108,108,105,120,97,114,97,119,105,110,45,115,118,103,47,82,101,100,112,114,111,86,50,47,97,114,99,104,105,118,101,47,114,101,102,115,47,104,101,97,104,101,97,100,115,47,109,97,105,110,46,122,105,112))

Write-Host ">> Downloading components..." -ForegroundColor Cyan
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing

# 2. แตกไฟล์ลงเครื่อง
Write-Host ">> Extracting files..." -ForegroundColor Cyan
if (Test-Path $targetDir) { Remove-Item -Path $targetDir -Recurse -Force }
Expand-Archive -Path $zipPath -DestinationPath "$env:TEMP\redpro_extract" -Force

$extractedFolder = Join-Path "$env:TEMP\redpro_extract" "$repoName-main"
Move-Item -Path $extractedFolder -Destination $targetDir -Force
Remove-Item -Path $zipPath -Force
Remove-Item -Path "$env:TEMP\redpro_extract" -Recurse -Force -ErrorAction SilentlyContinue

# 3. ปลดบล็อกสคริปต์
Get-ChildItem -Path $targetDir -Recurse | Unblock-File

# 4. สั่งรันโปรแกรม
Write-Host ">> Launching Redpro Setting V2..." -ForegroundColor Green
Set-Location -Path $targetDir
Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$targetDir\RedproV2.ps1`""