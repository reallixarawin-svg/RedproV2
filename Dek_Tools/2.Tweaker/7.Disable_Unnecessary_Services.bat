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

sc config "DiagTrack" start= disabled >nul 2>&1
net stop "DiagTrack" >nul 2>&1
sc config "dmwappushservice" start= disabled >nul 2>&1
net stop "dmwappushservice" >nul 2>&1
sc config "DPS" start= disabled >nul 2>&1
net stop "DPS" >nul 2>&1
sc config "WdiServiceHost" start= disabled >nul 2>&1
net stop "WdiServiceHost" >nul 2>&1
sc config "WdiSystemHost" start= disabled >nul 2>&1
net stop "WdiSystemHost" >nul 2>&1
sc config "WerSvc" start= disabled >nul 2>&1
net stop "WerSvc" >nul 2>&1
sc config "MapsBroker" start= disabled >nul 2>&1
net stop "MapsBroker" >nul 2>&1
sc config "Fax" start= disabled >nul 2>&1
net stop "Fax" >nul 2>&1
sc config "RetailDemo" start= disabled >nul 2>&1
net stop "RetailDemo" >nul 2>&1
sc config "WMPNetworkSvc" start= disabled >nul 2>&1
net stop "WMPNetworkSvc" >nul 2>&1
sc config "RemoteRegistry" start= disabled >nul 2>&1
net stop "RemoteRegistry" >nul 2>&1
sc config "SmsRouter" start= disabled >nul 2>&1
net stop "SmsRouter" >nul 2>&1
sc config "TrkWks" start= disabled >nul 2>&1
net stop "TrkWks" >nul 2>&1
sc config "EntAppSvc" start= disabled >nul 2>&1
net stop "EntAppSvc" >nul 2>&1

echo Unnecessary Services Disabled Successfully!
timeout /t 2 >nul
exit
