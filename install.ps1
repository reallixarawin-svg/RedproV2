# ==========================================================
# Redpro Setting V2 - One-Line Cloud Bootstrap Installer
# ==========================================================

$repoOwner = "reallixarawin-svg"
$repoName  = "RedproV2"
$branch    = "main"
$rawUrl    = "https://raw.githubusercontent.com/$repoOwner/$repoName/$branch/install.ps1"

# 1. ตรวจสอบสิทธิ์ Administrator (ถ้ายังไม่ใช่ ให้ขอสิทธิ์ใหม่อัตโนมัติ)
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Elevating to Administrator..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm $rawUrl | iex`"" -Verb RunAs
    exit
}

$targetDir = "$env:LOCALAPPDATA\$repoName"
$zipPath   = "$env:TEMP\$repoName.zip"
$zipUrl    = "https://github.com/$repoOwner/$repoName/archive/refs/heads/$branch.zip"

Write-Host ">> Downloading $repoName from GitHub..." -ForegroundColor Cyan
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing

# 3. แตกไฟล์ลงเครื่อง
Write-Host ">> Extracting files..." -ForegroundColor Cyan
if (Test-Path $targetDir) { Remove-Item -Path $targetDir -Recurse -Force }
Expand-Archive -Path $zipPath -DestinationPath "$env:TEMP\redpro_extract" -Force

$extractedFolder = Join-Path "$env:TEMP\redpro_extract" "$repoName-$branch"
Move-Item -Path $extractedFolder -Destination $targetDir -Force
Remove-Item -Path $zipPath -Force
Remove-Item -Path "$env:TEMP\redpro_extract" -Recurse -Force -ErrorAction SilentlyContinue

# 4. ปลดบล็อกสคริปต์ (Unblock-File) เพื่อให้รันได้ไม่ติด Windows Security
Get-ChildItem -Path $targetDir -Recurse | Unblock-File

# 5. สั่งรัน RedproV2.ps1 ทันที
Write-Host ">> Launching Redpro Setting V2..." -ForegroundColor Green
Set-Location -Path $targetDir
Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$targetDir\RedproV2.ps1`""