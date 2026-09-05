# ==========================================================
# Redpro Setting V2 - Fast Bootstrap Installer
# ==========================================================

$repoName  = "RedproV2"
$targetDir = "$env:LOCALAPPDATA\$repoName"
$appFile   = "$targetDir\RedproV2.ps1"

# 1. ตรวจสอบสิทธิ์ Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Elevating to Administrator..." -ForegroundColor Yellow
    $rawUrl = [System.Text.Encoding]::UTF8.GetString([byte[]]@(104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,114,101,97,108,108,105,120,97,114,97,119,105,110,45,115,118,103,47,82,101,100,112,114,111,86,50,47,109,97,105,110,47,105,110,115,116,97,108,108,46,112,115,49))
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm $rawUrl | iex`"" -Verb RunAs
    exit
}

# 2. [จุดสำคัญ] ถ้าเครื่องคนนี้เคยลงไว้แล้ว ให้เปิดเลยทันที ไม่ต้องดาวน์โหลดซ้ำ! (ใช้เวลา 0.5 วิ)
if (Test-Path $appFile) {
    Write-Host ">> Found installed files, launching Redpro Setting V2 instantly..." -ForegroundColor Green
    Set-Location -Path $targetDir
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$appFile`""
    exit
}

# 3. หากยังไม่เคยติดตั้ง ดาวน์โหลดไฟล์จาก GitHub (เร่งสปีดปิด Progress Bar)
$zipPath = "$env:TEMP\$repoName.zip"
$zipUrl  = [System.Text.Encoding]::UTF8.GetString([byte[]]@(104,116,116,112,115,58,47,47,103,105,116,104,117,98,46,99,111,109,47,114,101,97,108,108,105,120,97,114,97,119,105,110,45,115,118,103,47,82,101,100,112,114,111,86,50,47,97,114,99,104,105,118,101,47,114,101,102,115,47,104,101,97,100,115,47,109,97,105,110,46,122,105,112))

Write-Host ">> Installing Redpro Setting V2 (First-time setup)..." -ForegroundColor Cyan
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ปิด progress bar เพื่อให้ดาวน์โหลดเต็มสปีดเน็ต (เร็วขึ้น 3-5 เท่า)
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing

# 4. แตกไฟล์
Write-Host ">> Extracting files..." -ForegroundColor Cyan
if (Test-Path $targetDir) { Remove-Item -Path $targetDir -Recurse -Force }
Expand-Archive -Path $zipPath -DestinationPath "$env:TEMP\redpro_extract" -Force

$extractedFolder = Join-Path "$env:TEMP\redpro_extract" "$repoName-main"
Move-Item -Path $extractedFolder -Destination $targetDir -Force
Remove-Item -Path $zipPath -Force
Remove-Item -Path "$env:TEMP\redpro_extract" -Recurse -Force -ErrorAction SilentlyContinue

# 5. ปลดบล็อคไฟล์
Get-ChildItem -Path $targetDir -Recurse | Unblock-File

# 6. สร้างไอคอนบนหน้า Desktop ของคนใช้งานให้อัตโนมัติ!
try {
    $desktopPath = [Environment]::GetFolderPath('Desktop')
    $ws = New-Object -ComObject WScript.Shell
    $shortcut = $ws.CreateShortcut("$desktopPath\Redpro Setting V2.lnk")
    $shortcut.TargetPath = "powershell.exe"
    $shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$appFile`""
    $shortcut.WorkingDirectory = $targetDir
    $shortcut.Save()
    Write-Host ">> Created shortcut on Desktop!" -ForegroundColor Yellow
} catch {}

# 7. เปิดโปรแกรม
Write-Host ">> Launching Redpro Setting V2..." -ForegroundColor Green
Set-Location -Path $targetDir
Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$appFile`""
