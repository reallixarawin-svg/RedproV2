# ==========================================================
# Redpro Setting V2 - Fast Bootstrap Installer & Launcher
# ==========================================================

$repoName  = "RedproV2"
$targetDir = "$env:LOCALAPPDATA\$repoName"
$appFile   = "$targetDir\RedproV2.ps1"
$verFile   = "$targetDir\version.txt"
$icoFile   = "$targetDir\Redpro.ico"

# ซ่อน URL ด้วย Byte Array
$rawUrl = [System.Text.Encoding]::UTF8.GetString(
    [byte[]]@(
        104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,
        117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,114,101,
        97,108,108,105,120,97,114,97,119,105,110,45,115,118,103,47,82,101,
        100,112,114,111,86,50,47,109,97,105,110,47,105,110,115,116,97,108,
        108,46,112,115,49
    )
)

$zipUrl = [System.Text.Encoding]::UTF8.GetString(
    [byte[]]@(
        104,116,116,112,115,58,47,47,103,105,116,104,117,98,46,99,111,109,
        47,114,101,97,108,108,105,120,97,114,97,119,105,110,45,115,118,103,
        47,82,101,100,112,114,111,86,50,47,97,114,99,104,105,118,101,47,
        114,101,102,115,47,104,101,97,100,115,47,109,97,105,110,46,122,105,
        112
    )
)

$verUrl = [System.Text.Encoding]::UTF8.GetString(
    [byte[]]@(
        104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,
        117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,114,101,
        97,108,108,105,120,97,114,97,119,105,110,45,115,118,103,47,82,101,
        100,112,114,111,86,50,47,109,97,105,110,47,118,101,114,115,105,111,
        110,46,116,120,116
    )
)

# ==========================================================
# 1. ตรวจสอบสิทธิ์ Administrator
# ==========================================================

if (-not (
    [Security.Principal.WindowsPrincipal]
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)) {
    Write-Host "Elevating to Administrator..." -ForegroundColor Yellow

    Start-Process powershell.exe `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm $rawUrl | iex`"" `
        -Verb RunAs

    exit
}

[Net.ServicePointManager]::SecurityProtocol = `
    [Net.SecurityProtocolType]::Tls12


# ==========================================================
# ฟังก์ชันซ่อน Redpro
# ใช้ attrib +h +s
# ==========================================================

function Hide-RedproFiles {

    if (-not (Test-Path $targetDir)) {
        return
    }

    try {
        # ซ่อน root folder
        & attrib.exe +h +s "$targetDir"

        # ซ่อนไฟล์และโฟลเดอร์ทั้งหมดด้านใน
        & attrib.exe +h +s "$targetDir\*" /s /d

    } catch {
        # ไม่ให้การซ่อนไฟล์ทำให้ Launcher หยุดทำงาน
    }
}


# ==========================================================
# ฟังก์ชันสร้าง Shortcut บน Desktop
# ==========================================================

function Ensure-DesktopShortcut {

    try {

        $desktopPath  = [Environment]::GetFolderPath('Desktop')
        $shortcutPath = Join-Path $desktopPath "Redpro Setting V2.lnk"

        $ws = New-Object -ComObject WScript.Shell
        $shortcut = $ws.CreateShortcut($shortcutPath)

        $shortcut.TargetPath = "powershell.exe"

        $shortcut.Arguments = `
            "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$appFile`""

        $shortcut.WorkingDirectory = $targetDir

        if (Test-Path $icoFile) {
            $shortcut.IconLocation = "$icoFile,0"
        }

        $shortcut.Save()

        # ตั้ง Shortcut ให้ Run as Administrator
        $bytes = [System.IO.File]::ReadAllBytes($shortcutPath)

        if ($bytes.Length -gt 0x15) {
            $bytes[0x15] = $bytes[0x15] -bor 0x20

            [System.IO.File]::WriteAllBytes(
                $shortcutPath,
                $bytes
            )
        }

        Write-Host ">> Desktop icon ready!" `
            -ForegroundColor Yellow

    } catch {

    }
}


# ==========================================================
# ฟังก์ชันเปิด Redpro
# ==========================================================

function Start-RedproApp {

    Write-Host `
        ">> Launching Redpro Setting V2..." `
        -ForegroundColor Green

    Set-Location -Path $targetDir

    Start-Process powershell.exe `
        -ArgumentList `
        "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$appFile`""

    exit
}


# ==========================================================
# 2. ตรวจสอบการติดตั้งเดิม + Version
# ==========================================================

if (Test-Path $appFile) {

    Ensure-DesktopShortcut

    # ตั้ง Hidden + System ทุกครั้ง
    Hide-RedproFiles

    $needUpdate = $false

    try {

        $remoteVer = (
            Invoke-RestMethod `
                -Uri $verUrl `
                -TimeoutSec 2 `
                -UseBasicParsing
        ).Trim()

        $localVer = if (Test-Path $verFile) {
            (Get-Content -Path $verFile -Raw).Trim()
        }
        else {
            "1.0.0"
        }

        if (
            $remoteVer -and
            ($remoteVer -ne $localVer)
        ) {

            Write-Host `
                ">> Found new update: v$remoteVer (Current: v$localVer)" `
                -ForegroundColor Yellow

            $needUpdate = $true
        }

    }
    catch {

        # ถ้าเช็ก Version ไม่ได้
        # ใช้ตัวที่ติดตั้งอยู่ทันที
    }

    if (-not $needUpdate) {

        Start-RedproApp
    }
}


# ==========================================================
# 3. Download
# ==========================================================

$zipPath = "$env:TEMP\$repoName.zip"

Write-Host `
    ">> Downloading components..." `
    -ForegroundColor Cyan

$ProgressPreference = 'SilentlyContinue'

# ลบ ZIP เก่าก่อน
if (Test-Path $zipPath) {
    Remove-Item `
        -Path $zipPath `
        -Force `
        -ErrorAction SilentlyContinue
}

Invoke-WebRequest `
    -Uri $zipUrl `
    -OutFile $zipPath `
    -UseBasicParsing


# ==========================================================
# 4. Extract
# ==========================================================

Write-Host `
    ">> Extracting files..." `
    -ForegroundColor Cyan

$extractDir = "$env:TEMP\redpro_extract"

if (Test-Path $extractDir) {

    Remove-Item `
        -Path $extractDir `
        -Recurse `
        -Force `
        -ErrorAction SilentlyContinue
}

Add-Type `
    -AssemblyName System.IO.Compression.FileSystem

[System.IO.Compression.ZipFile]::ExtractToDirectory(
    $zipPath,
    $extractDir
)


# ==========================================================
# ลบ Version เก่า
# ==========================================================

if (Test-Path $targetDir) {

    # เอา Hidden/System ออกก่อนลบ
    # ป้องกันบางกรณีที่ไฟล์เดิมลบไม่หมด

    & attrib.exe -h -s "$targetDir" 2>$null
    & attrib.exe -h -s "$targetDir\*" /s /d 2>$null

    Remove-Item `
        -Path $targetDir `
        -Recurse `
        -Force `
        -ErrorAction SilentlyContinue
}


# ==========================================================
# ย้าย Version ใหม่
# ==========================================================

$extractedFolder = Join-Path `
    $extractDir `
    "$repoName-main"

Move-Item `
    -Path $extractedFolder `
    -Destination $targetDir `
    -Force


# ==========================================================
# ล้างไฟล์ชั่วคราว
# ==========================================================

Remove-Item `
    -Path $zipPath `
    -Force `
    -ErrorAction SilentlyContinue

Remove-Item `
    -Path $extractDir `
    -Recurse `
    -Force `
    -ErrorAction SilentlyContinue


# ==========================================================
# 5. Unblock
# ==========================================================

Get-ChildItem `
    -Path $targetDir `
    -Recurse `
    -Force `
    -ErrorAction SilentlyContinue |
    Unblock-File `
        -ErrorAction SilentlyContinue


# ==========================================================
# 6. ซ่อนโปรแกรมด้วย attrib +h +s
# ==========================================================

Hide-RedproFiles


# ==========================================================
# 7. สร้าง Desktop Shortcut
# ==========================================================

Ensure-DesktopShortcut


# ==========================================================
# 8. เปิดโปรแกรม
# ==========================================================

Start-RedproApp
