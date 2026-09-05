@echo off
setlocal EnableExtensions EnableDelayedExpansion

fltmc >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo Cleaning Temp files...

del /f /s /q "%TEMP%\*" >nul 2>&1
for /d %%x in ("%TEMP%\*") do rd /s /q "%%x" >nul 2>&1
del /f /s /q "C:\Windows\Temp\*" >nul 2>&1
for /d %%x in ("C:\Windows\Temp\*") do rd /s /q "%%x" >nul 2>&1

del /f /s /q "C:\ProgramData\Microsoft\Windows\WER\ReportArchive\*" >nul 2>&1
for /d %%x in ("C:\ProgramData\Microsoft\Windows\WER\ReportArchive\*") do rd /s /q "%%x" >nul 2>&1
del /f /s /q "C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*" >nul 2>&1
for /d %%x in ("C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*") do rd /s /q "%%x" >nul 2>&1

powershell -command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1

del /f /s /q "C:\Windows\Minidump\*" >nul 2>&1
del /f /q "C:\Windows\MEMORY.DMP" >nul 2>&1
del /f /s /q "%localappdata%\CrashDumps\*" >nul 2>&1

echo Temp Cleaned Successfully!
pause
exit
