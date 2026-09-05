# ==========================================================
# Redpro Setting V2 - Fast Bootstrap Installer & Launcher
# ==========================================================

$repoName  = "RedproV2"
$targetDir = "$env:LOCALAPPDATA\$repoName"
$appFile   = "$targetDir\RedproV2.ps1"
$verFile   = "$targetDir\version.txt"

# ซ่อน URL ด้วย Byte Array
$rawUrl    = [System.Text.Encoding]::UTF8.GetString([byte[]]@(104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,114,101,97,108,108,105,120,97,114,97,119,105,110,45,115,118,103,47,82,101,100,112,114,111,86,50,47,109,97,105,110,47,105,110,115,116,97,108,108,46,112,115,49))
$zipUrl    = [System.Text.Encoding]::UTF8.GetString([byte[]]@(104,116,116,112,115,58,47,47,103,105,116,104,117,98,46,99,111,109,47,114,101,97,108,108,105,120,97,114,97,119,105,110,45,115,118,103,47,82,101,100,112,114,111,86,50,47,97,114,99,104,105,118,101,47,114,101,102,115,47,104,101,97,100,115,47,109,97,105,110,46,122,105,112))
$verUrl    = [System.Text.Encoding]::UTF8.GetString([byte[]]@(104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,114,101,97,108,108,105,120,97,114,97,119,105,110,45,115,118,103,47,82,101,100,112,114,111,86,50,47,109,97,105,110,47,118,101,114,115,105,111,110,46,116,120,116))

# 1. ตรวจสอบสิทธิ์ Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Elevating to Administrator..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm $rawUrl | iex`"" -Verb RunAs
    exit
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 2. ฟังก์ชันช่วยเปิดโปรแกรม
function Start-RedproApp {
    Write-Host ">> Launching Redpro Setting V2..." -ForegroundColor Green
    Set-Location -Path $targetDir
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$appFile`""
    exit
}

# 3. ตรวจสอบเวอร์ชันและการติดตั้งเดิม (ถ้ามีและเป็นเวอร์ชันล่าสุด เปิดทันทีใน 0.3 วินาที)
if (Test-Path $appFile) {
    $needUpdate = $false
    try {
        $remoteVer = (Invoke-RestMethod -Uri $verUrl -TimeoutSec 2 -UseBasicParsing).Trim()
        $localVer  = if (Test-Path $verFile) { (Get-Content -Path $verFile -Raw).Trim() } else { "1.0.0" }
        if ($remoteVer -and ($remoteVer -ne $localVer)) {
            Write-Host ">> Found new update: v$remoteVer (Current: v$localVer)" -ForegroundColor Yellow
            $needUpdate = $true
        }
    } catch {
        # ถ้าไม่มีเน็ตหรือเช็คไม่ได้ ให้เปิดโปรแกรมในเครื่องทันที
    }

    if (-not $needUpdate) {
        Start-RedproApp
    }
}

# 4. ดาวน์โหลดไฟล์ (เร่งสปีดด้วยการปิด Progress Bar)
$zipPath = "$env:TEMP\$repoName.zip"
Write-Host ">> Downloading components..." -ForegroundColor Cyan
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing

# 5. แตกไฟล์ (.NET ZipFile เร็วกว่า Expand-Archive 5-10 เท่า)
Write-Host ">> Extracting files..." -ForegroundColor Cyan
$extractDir = "$env:TEMP\redpro_extract"
if (Test-Path $extractDir) { Remove-Item -Path $extractDir -Recurse -Force -ErrorAction SilentlyContinue }

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $extractDir)

if (Test-Path $targetDir) { Remove-Item -Path $targetDir -Recurse -Force -ErrorAction SilentlyContinue }
$extractedFolder = Join-Path $extractDir "$repoName-main"
Move-Item -Path $extractedFolder -Destination $targetDir -Force

# ล้างไฟล์ชั่วคราว
Remove-Item -Path $zipPath -Force -ErrorAction SilentlyContinue
Remove-Item -Path $extractDir -Recurse -Force -ErrorAction SilentlyContinue

# 6. ปลดบล็อคไฟล์
Get-ChildItem -Path $targetDir -Recurse | Unblock-File

# 7. สร้าง Shortcut บนหน้า Desktop ให้อัตโนมัติ (พร้อมตั้งค่า Run as Administrator ให้เสร็จสรรพ)
try {
    $desktopPath = [Environment]::GetFolderPath('Desktop')
    $shortcutPath = "$desktopPath\Redpro Setting V2.lnk"
    $ws = New-Object -ComObject WScript.Shell
    $shortcut = $ws.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = "powershell.exe"
    $shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$appFile`""
    $shortcut.WorkingDirectory = $targetDir
    $shortcut.Save()

    # ตั้งค่าให้ Shortcut รันเป็น Administrator อัตโนมัติ (ไม่ต้องคลิกขวา Run as Admin)
    $bytes = [System.IO.File]::ReadAllBytes($shortcutPath)
    $bytes[0x15] = $bytes[0x15] -bor 0x20
    [System.IO.File]::WriteAllBytes($shortcutPath, $bytes)
    Write-Host ">> Created Administrator Shortcut on Desktop!" -ForegroundColor Yellow
} catch {}

# 8. เปิดโปรแกรม
Start-RedproApp
