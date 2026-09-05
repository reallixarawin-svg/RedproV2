@echo off
setlocal

fsutil dirty query %systemdrive% >nul 2>&1
if %errorLevel% neq 0 (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /b
)

set "psFile=%temp%\ExtremeKiller.ps1"
> "%psFile%" echo $whitelistPaths = @(
>> "%psFile%" echo     'C:\Windows\*', '*\System32\*', '*\SysWOW64\*',
>> "%psFile%" echo     '*\NVIDIA*', '*\AMD*', '*\Realtek*', '*\Intel*',
>> "%psFile%" echo     '*\Razer*', '*\LGHUB*', '*\Corsair*', '*\SteelSeries*', '*\Logitech*',
>> "%psFile%" echo     '*\FiveM*', '*\Grand Theft Auto V*', '*\Rockstar Games*'
>> "%psFile%" echo )
>> "%psFile%" echo $whitelistNames = @(
>> "%psFile%" echo     'explorer', 'cmd', 'powershell', 'pwsh', 'conhost', 'WindowsTerminal', 'wt', 'taskmgr'
>> "%psFile%" echo )
>> "%psFile%" echo $currentId = $PID
>> "%psFile%" echo Get-Process ^| Where-Object { $_.Path -ne $null -and $_.Id -ne $currentId } ^| ForEach-Object {
>> "%psFile%" echo     $safe = $false
>> "%psFile%" echo     if ($_.Name -in $whitelistNames) { $safe = $true }
>> "%psFile%" echo     if (-not $safe) {
>> "%psFile%" echo         foreach ($path in $whitelistPaths) {
>> "%psFile%" echo             if ($_.Path -like $path) { $safe = $true; break }
>> "%psFile%" echo         }
>> "%psFile%" echo     }
>> "%psFile%" echo     if (-not $safe) {
>> "%psFile%" echo         Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
>> "%psFile%" echo     }
>> "%psFile%" echo }

powershell -NoProfile -ExecutionPolicy Bypass -File "%psFile%"
del "%psFile%" >nul 2>&1

echo Extreme Process Cleanup Successfully!
timeout /t 2 >nul
exit
