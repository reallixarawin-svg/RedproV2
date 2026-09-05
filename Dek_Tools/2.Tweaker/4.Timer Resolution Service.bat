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

set "svcFolder=%ProgramFiles%\TimerResolutionSvc"
set "svcExe=%svcFolder%\TimerResolutionSvc.exe"
set "csFile=%temp%\TimerResolutionSvc.cs"

if not exist "%svcFolder%" mkdir "%svcFolder%"

> "%csFile%" echo using System;
>> "%csFile%" echo using System.Runtime.InteropServices;
>> "%csFile%" echo using System.ServiceProcess;
>> "%csFile%" echo public class TimerResolutionService : ServiceBase {
>> "%csFile%" echo     [DllImport("ntdll.dll", SetLastError = true)]
>> "%csFile%" echo     public static extern int NtQueryTimerResolution(out uint MinimumResolution, out uint MaximumResolution, out uint CurrentResolution);
>> "%csFile%" echo     [DllImport("ntdll.dll", SetLastError = true)]
>> "%csFile%" echo     public static extern int NtSetTimerResolution(uint DesiredResolution, bool SetResolution, out uint CurrentResolution);
>> "%csFile%" echo     public TimerResolutionService() { this.ServiceName = "Set Timer Resolution Service"; }
>> "%csFile%" echo     protected override void OnStart(string[] args) { uint min, max, current; NtQueryTimerResolution(out min, out max, out current); NtSetTimerResolution(max, true, out current); }
>> "%csFile%" echo     protected override void OnStop() { uint min, max, current; NtQueryTimerResolution(out min, out max, out current); NtSetTimerResolution(max, false, out current); }
>> "%csFile%" echo     public static void Main() { ServiceBase.Run(new TimerResolutionService()); }
>> "%csFile%" echo }

"%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\csc.exe" /nologo /target:winexe /reference:System.ServiceProcess.dll /out:"%svcExe%" "%csFile%" >nul 2>&1

if exist "%svcExe%" (
    sc create "Set Timer Resolution Service" binPath= "%svcExe%" start= auto obj= LocalSystem >nul 2>&1
    sc start "Set Timer Resolution Service" >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v GlobalTimerResolutionRequests /t REG_DWORD /d 1 /f >nul 2>&1
)

if exist "%csFile%" del "%csFile%" >nul 2>&1

echo Timer Resolution Service Successfully!
timeout /t 2 >nul
exit
