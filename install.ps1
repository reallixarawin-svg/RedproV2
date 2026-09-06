# ==========================================================
# Redpro Setting V2 - Fast Bootstrap Installer & Launcher
# ==========================================================

$repoName  = "RedproV2"
$targetDir = "$env:LOCALAPPDATA\$repoName"
$appFile   = "$targetDir\RedproV2.ps1"
$verFile   = "$targetDir\version.txt"
$icoFile   = "$targetDir\Redpro.ico"
$dddFile   = "$targetDir\ddd.jpg"

# URLs encoded as Byte Arrays
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
# 1. Check Administrator
# ==========================================================

$currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)

$isAdmin = $currentPrincipal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

if (-not $isAdmin) {
    Write-Host "Elevating to Administrator..." -ForegroundColor Yellow

    Start-Process powershell.exe `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm '$rawUrl' | iex`"" `
        -Verb RunAs

    exit
}

# TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


# ==========================================================
# Function: Hide installation folder normally
#
# Hidden ONLY
# No System attribute
# No attrib.exe
# ==========================================================

function Hide-RedproFolder {
    try {
        if (Test-Path -LiteralPath $targetDir) {
            $folder = Get-Item -LiteralPath $targetDir -Force

            $folder.Attributes = (
                $folder.Attributes -bor [System.IO.FileAttributes]::Hidden
            )
        }
    }
    catch {
        # Hiding failure should not stop the program
    }
}


# ==========================================================
# Function: Create Desktop Shortcut
# ==========================================================

function Ensure-DesktopShortcut {
    try {
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        $shortcutPath = Join-Path $desktopPath "Redpro Setting V2.lnk"

        $ws = New-Object -ComObject WScript.Shell
        $shortcut = $ws.CreateShortcut($shortcutPath)

        $shortcut.TargetPath = "powershell.exe"

        $shortcut.Arguments = `
            "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$appFile`""

        $shortcut.WorkingDirectory = $targetDir

        if (Test-Path -LiteralPath $icoFile) {
            $shortcut.IconLocation = "$icoFile,0"
        }

        $shortcut.Save()

        # Set shortcut to Run as Administrator
        if (Test-Path -LiteralPath $shortcutPath) {
            $bytes = [System.IO.File]::ReadAllBytes($shortcutPath)

            if ($bytes.Length -gt 0x15) {
                $bytes[0x15] = $bytes[0x15] -bor 0x20

                [System.IO.File]::WriteAllBytes(
                    $shortcutPath,
                    $bytes
                )
            }
        }

        Write-Host ">> Desktop icon ready!" -ForegroundColor Yellow
    }
    catch {
        Write-Host ">> Could not create Desktop shortcut." `
            -ForegroundColor DarkYellow
    }
}


# ==========================================================
# Function: Launch Redpro
# ==========================================================

function Start-RedproApp {
    if (-not (Test-Path -LiteralPath $appFile)) {
        Write-Host ">> RedproV2.ps1 not found." -ForegroundColor Red
        exit 1
    }

    Write-Host ">> Launching Redpro Setting V2..." `
        -ForegroundColor Green

    Set-Location -LiteralPath $targetDir

    Start-Process powershell.exe `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$appFile`""

    exit
}


# ==========================================================
# 2. Check Existing Installation + Version
# ==========================================================

if (Test-Path -LiteralPath $appFile) {

    Ensure-DesktopShortcut

    # Keep installation folder hidden normally
    Hide-RedproFolder

    $needUpdate = $false

    try {
        $remoteVer = (
            Invoke-RestMethod `
                -Uri $verUrl `
                -TimeoutSec 2 `
                -UseBasicParsing
        ).ToString().Trim()

        if (Test-Path -LiteralPath $verFile) {
            $localVer = (
                Get-Content `
                    -LiteralPath $verFile `
                    -Raw
            ).Trim()
        }
        else {
            $localVer = "1.0.0"
        }

        if (
            -not [string]::IsNullOrWhiteSpace($remoteVer) -and
            ($remoteVer -ne $localVer)
        ) {
            Write-Host `
                ">> Found new update: v$remoteVer (Current: v$localVer)" `
                -ForegroundColor Yellow

            $needUpdate = $true
        }
    }
    catch {
        # If version check fails/offline,
        # launch the currently installed version.
        $needUpdate = $false
    }

    if (-not $needUpdate) {
        Start-RedproApp
    }
}


# ==========================================================
# 3. Download Repository ZIP
# ==========================================================

$zipPath = "$env:TEMP\$repoName.zip"

Write-Host ">> Downloading components..." -ForegroundColor Cyan

$ProgressPreference = "SilentlyContinue"

if (Test-Path -LiteralPath $zipPath) {
    Remove-Item `
        -LiteralPath $zipPath `
        -Force `
        -ErrorAction SilentlyContinue
}

try {
    Invoke-WebRequest `
        -Uri $zipUrl `
        -OutFile $zipPath `
        -UseBasicParsing `
        -ErrorAction Stop
}
catch {
    Write-Host ">> Download failed." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor DarkRed
    exit 1
}


# ==========================================================
# 4. Extract ZIP
# ==========================================================

Write-Host ">> Extracting files..." -ForegroundColor Cyan

$extractDir = "$env:TEMP\redpro_extract"

if (Test-Path -LiteralPath $extractDir) {
    Remove-Item `
        -LiteralPath $extractDir `
        -Recurse `
        -Force `
        -ErrorAction SilentlyContinue
}

try {
    New-Item `
        -ItemType Directory `
        -Path $extractDir `
        -Force |
    Out-Null

    Add-Type -AssemblyName System.IO.Compression.FileSystem

    [System.IO.Compression.ZipFile]::ExtractToDirectory(
        $zipPath,
        $extractDir
    )
}
catch {
    Write-Host ">> Extraction failed." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor DarkRed

    Remove-Item `
        -LiteralPath $zipPath `
        -Force `
        -ErrorAction SilentlyContinue

    exit 1
}


# ==========================================================
# 5. Remove Old Installation
#
# Remove-Item -Force can remove normal Hidden folders.
# No need to unhide it first.
# ==========================================================

if (Test-Path -LiteralPath $targetDir) {
    try {
        Remove-Item `
            -LiteralPath $targetDir `
            -Recurse `
            -Force `
            -ErrorAction Stop
    }
    catch {
        Write-Host `
            ">> Could not remove old installation." `
            -ForegroundColor Red

        Write-Host $_.Exception.Message `
            -ForegroundColor DarkRed

        exit 1
    }
}


# ==========================================================
# Locate Extracted Repository
# ==========================================================

$extractedFolder = Join-Path `
    $extractDir `
    "$repoName-main"

if (-not (Test-Path -LiteralPath $extractedFolder)) {

    $possibleFolder = Get-ChildItem `
        -LiteralPath $extractDir `
        -Directory `
        -ErrorAction SilentlyContinue |
    Select-Object -First 1

    if ($null -ne $possibleFolder) {
        $extractedFolder = $possibleFolder.FullName
    }
}

if (-not (Test-Path -LiteralPath $extractedFolder)) {
    Write-Host `
        ">> Extracted program folder was not found." `
        -ForegroundColor Red

    exit 1
}


# ==========================================================
# 6. Move New Version
# ==========================================================

try {
    Move-Item `
        -LiteralPath $extractedFolder `
        -Destination $targetDir `
        -Force `
        -ErrorAction Stop
}
catch {
    Write-Host `
        ">> Installation failed while moving files." `
        -ForegroundColor Red

    Write-Host $_.Exception.Message `
        -ForegroundColor DarkRed

    exit 1
}


# ==========================================================
# 7. Cleanup Temporary Files
# ==========================================================

Remove-Item `
    -LiteralPath $zipPath `
    -Force `
    -ErrorAction SilentlyContinue

Remove-Item `
    -LiteralPath $extractDir `
    -Recurse `
    -Force `
    -ErrorAction SilentlyContinue


# ==========================================================
# 8. Unblock Downloaded Files
# ==========================================================

try {
    Get-ChildItem `
        -LiteralPath $targetDir `
        -Recurse `
        -Force `
        -File `
        -ErrorAction SilentlyContinue |
    ForEach-Object {
        Unblock-File `
            -LiteralPath $_.FullName `
            -ErrorAction SilentlyContinue
    }
}
catch {
}


# ==========================================================
# Verify Main Application
# ==========================================================

if (-not (Test-Path -LiteralPath $appFile)) {
    Write-Host `
        ">> Installation completed, but RedproV2.ps1 was not found." `
        -ForegroundColor Red

    exit 1
}


# ==========================================================
# 9. Hide installation folder normally
#
# File Explorer:
# Hidden items OFF = RedproV2 not visible
# Hidden items ON  = RedproV2 visible
#
# Only the RedproV2 root folder needs Hidden.
# ==========================================================

Hide-RedproFolder


# ==========================================================
# 10. Create Desktop Shortcut
# ==========================================================

Ensure-DesktopShortcut


# ==========================================================
# 11. Launch Redpro
# ==========================================================

Start-RedproApp
