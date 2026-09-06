# Keep startup errors visible even when the launcher hides its console.
trap {
    $startupFailure = $_
    $startupLog = Join-Path ([IO.Path]::GetTempPath()) 'RedproV2-startup-error.log'
    try {
        $details = [DateTime]::Now.ToString('s') + "`r`n" + ($startupFailure | Out-String) + "`r`n" + $startupFailure.ScriptStackTrace
        [IO.File]::AppendAllText($startupLog, $details + "`r`n", [Text.Encoding]::UTF8)
    } catch {}
    try {
        Add-Type -AssemblyName PresentationFramework
        [Windows.MessageBox]::Show("RedproV2 could not start.`n" + $startupFailure.Exception.Message + "`n`nLog: " + $startupLog, 'RedproV2 startup error') | Out-Null
    } catch { Write-Host $startupFailure -ForegroundColor Red }
    exit 1
}

# ==========================================================
# Redpro Setting V2 - Fast Bootstrap Installer & Launcher
# ==========================================================

$ErrorActionPreference = 'Stop'

$repoName  = "RedproV2"
$targetDir = "$env:LOCALAPPDATA\$repoName"
$appFile   = "$targetDir\RedproV2.ps1"
$verFile   = "$targetDir\version.txt"
$icoFile   = "$targetDir\Redpro.ico"

# ซ่อน URL ด้วย Byte Array
$rawUrl    = [System.Text.Encoding]::UTF8.GetString([byte[]]@(104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,114,101,97,108,108,105,120,97,114,97,119,105,110,45,115,118,103,47,82,101,100,112,114,111,86,50,47,109,97,105,110,47,105,110,115,116,97,108,108,46,112,115,49))
$zipUrl    = [System.Text.Encoding]::UTF8.GetString([byte[]]@(104,116,116,112,115,58,47,47,103,105,116,104,117,98,46,99,111,109,47,114,101,97,108,108,105,120,97,114,97,119,105,110,45,115,118,103,47,82,101,100,112,114,111,86,50,47,97,114,99,104,105,118,101,47,114,101,102,115,47,104,101,97,100,115,47,109,97,105,110,46,122,105,112))
$verUrl    = [System.Text.Encoding]::UTF8.GetString([byte[]]@(104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,114,101,97,108,108,105,120,97,114,97,119,105,110,45,115,118,103,47,82,101,100,112,114,111,86,50,47,109,97,105,110,47,118,101,114,115,105,111,110,46,116,120,116))

# 1. ตรวจสอบสิทธิ์ Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Elevating to Administrator..." -ForegroundColor Yellow
    if ($PSCommandPath) {
        Start-Process powershell.exe -WindowStyle Hidden -ArgumentList "-NoProfile -STA -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    } else {
        Start-Process powershell.exe -WindowStyle Hidden -ArgumentList "-NoProfile -STA -ExecutionPolicy Bypass -Command `"irm $rawUrl | iex`"" -Verb RunAs
    }
    exit
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ฟังก์ชันสร้าง Shortcut บนหน้า Desktop พร้อมไอคอนและสิทธิ์ Admin
function Ensure-DesktopShortcut {
    try {
        $desktopPath = [Environment]::GetFolderPath('Desktop')
        $shortcutPath = Join-Path $desktopPath "Redpro Setting V2.lnk"

        $ws = New-Object -ComObject WScript.Shell
        $shortcut = $ws.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = "powershell.exe"
        # Launch the online installer, not the cached application.
        $launchCommand = "try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-RestMethod -Uri '$rawUrl' -ErrorAction Stop | Invoke-Expression } catch { Add-Type -AssemblyName PresentationFramework; [Windows.MessageBox]::Show(`$_.Exception.Message, 'RedproV2 update failed') | Out-Null }"
        $shortcut.Arguments = "-NoProfile -STA -ExecutionPolicy Bypass -WindowStyle Hidden -Command `"$launchCommand`""
        # Keep the working directory outside the installation being replaced.
        $shortcut.WorkingDirectory = [IO.Path]::GetTempPath()
        if (Test-Path $icoFile) {
            $shortcut.IconLocation = "$icoFile,0"
        }
        $shortcut.Save()

        # ตั้งค่า Run as Administrator ในตัวไอคอน Shortcut
        $bytes = [System.IO.File]::ReadAllBytes($shortcutPath)
        $bytes[0x15] = $bytes[0x15] -bor 0x20
        [System.IO.File]::WriteAllBytes($shortcutPath, $bytes)
        Write-Host ">> Desktop icon ready!" -ForegroundColor Yellow
    } catch { throw }
}

# ฟังก์ชันเปิดโปรแกรม
function Start-RedproApp {
    Write-Host ">> Launching Redpro Setting V2..." -ForegroundColor Green
    Set-Location -Path $targetDir
    Start-Process powershell.exe -ArgumentList "-NoProfile -STA -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$appFile`""
    exit
}

# 2. Always remove the previous installation before downloading and launching.
function Remove-PreviousRedproInstallation {
    if ([string]::IsNullOrWhiteSpace($env:LOCALAPPDATA)) {
        throw 'LOCALAPPDATA is unavailable. Installation stopped.'
    }
    $localRoot = [IO.Path]::GetFullPath($env:LOCALAPPDATA).TrimEnd('\')
    $expectedTarget = [IO.Path]::GetFullPath((Join-Path $localRoot 'RedproV2'))
    $resolvedTarget = [IO.Path]::GetFullPath($targetDir).TrimEnd('\')
    if (-not [string]::Equals($resolvedTarget, $expectedTarget, [StringComparison]::OrdinalIgnoreCase) -or
        -not [string]::Equals([IO.Path]::GetDirectoryName($resolvedTarget), $localRoot, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Unexpected installation path. Cleanup stopped.'
    }
    if (Test-Path -LiteralPath $resolvedTarget) {
        $existing = Get-Item -LiteralPath $resolvedTarget -Force -ErrorAction Stop
        if ($existing.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            throw 'RedproV2 is a linked path. Cleanup stopped.'
        }
        Write-Host '>> Removing previous RedproV2 installation...' -ForegroundColor Yellow
        Remove-Item -LiteralPath $resolvedTarget -Recurse -Force -ErrorAction Stop
        if (Test-Path -LiteralPath $resolvedTarget) {
            throw 'Could not remove the previous installation. Close RedproV2 and retry.'
        }
    }
}

Remove-PreviousRedproInstallation

# 3. ดาวน์โหลดไฟล์ (เร่งสปีดด้วยการปิด Progress Bar)
$zipPath = "$env:TEMP\$repoName.zip"
Write-Host ">> Downloading components..." -ForegroundColor Cyan
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing

# 4. แตกไฟล์ (.NET ZipFile เร็วกว่า Expand-Archive 5-10 เท่า)
Write-Host ">> Extracting files..." -ForegroundColor Cyan
$extractDir = "$env:TEMP\redpro_extract"
if (Test-Path $extractDir) { Remove-Item -Path $extractDir -Recurse -Force -ErrorAction SilentlyContinue }

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $extractDir)

if (Test-Path -LiteralPath $targetDir) { throw 'Installation directory reappeared. Close other installers and retry.' }
$extractedFolder = Join-Path $extractDir "$repoName-main"
Move-Item -Path $extractedFolder -Destination $targetDir -Force

# ล้างไฟล์ชั่วคราว
Remove-Item -Path $zipPath -Force -ErrorAction SilentlyContinue
Remove-Item -Path $extractDir -Recurse -Force -ErrorAction SilentlyContinue

# 5. ปลดบล็อคไฟล์
Get-ChildItem -Path $targetDir -Recurse | Unblock-File

# Hide the installation folder from the normal Explorer view.
# This is cosmetic; it does not encrypt or protect the PowerShell source.
$installedDirectory = Get-Item -LiteralPath $targetDir -Force -ErrorAction Stop
$installedDirectory.Attributes = $installedDirectory.Attributes -bor [IO.FileAttributes]::Hidden -bor [IO.FileAttributes]::System

# 6. สร้าง Shortcut บนหน้า Desktop
Ensure-DesktopShortcut

# 7. เปิดโปรแกรม
Start-RedproApp
