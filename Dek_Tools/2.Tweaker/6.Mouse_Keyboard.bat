@echo off
setlocal EnableDelayedExpansion

fsutil dirty query %systemdrive% >nul 2>&1
if %errorLevel% neq 0 (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /b
)

reg add "HKCU\Control Panel\Keyboard" /v KeyboardDelay /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Keyboard" /v KeyboardSpeed /t REG_SZ /d "31" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v AutoRepeatDelay /t REG_SZ /d "200" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v AutoRepeatRate /t REG_SZ /d "6" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v BounceTime /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v DelayBeforeAcceptance /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v MouseHoverTime /t REG_SZ /d "10" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v ForegroundLockTimeout /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v KeyboardDataQueueSize /t REG_DWORD /d 16 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v MouseDataQueueSize /t REG_DWORD /d 16 /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 38 /f
reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f

echo Mouse and Keyboard Successfully!
timeout /t 2 >nul
exit
