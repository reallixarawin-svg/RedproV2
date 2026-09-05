@echo off

fsutil dirty query %systemdrive% >nul 2>&1
if %errorLevel% neq 0 (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /b
)

for /f "tokens=*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}" /v "*SpeedDuplex" /s ^| findstr "HKEY"') do (
    Reg.exe add "%%a" /v "*ReceiveBuffers" /t REG_SZ /d "2048" /f >nul 2>&1
    Reg.exe add "%%a" /v "*TransmitBuffers" /t REG_SZ /d "2048" /f >nul 2>&1
    Reg.exe add "%%a" /v "*DeviceSleepOnDisconnect" /t REG_SZ /d "0" /f >nul 2>&1
    Reg.exe add "%%a" /v "*EEE" /t REG_SZ /d "0" /f >nul 2>&1
    Reg.exe add "%%a" /v "*FlowControl" /t REG_SZ /d "0" /f >nul 2>&1
    Reg.exe add "%%a" /v "*IPChecksumOffloadIPv4" /t REG_SZ /d "3" /f >nul 2>&1
    Reg.exe add "%%a" /v "*InterruptModeration" /t REG_SZ /d "0" /f >nul 2>&1
    Reg.exe add "%%a" /v "*LsoV2IPv4" /t REG_SZ /d "0" /f >nul 2>&1
    Reg.exe add "%%a" /v "*LsoV2IPv6" /t REG_SZ /d "0" /f >nul 2>&1
    Reg.exe add "%%a" /v "*NumRssQueues" /t REG_SZ /d "2" /f >nul 2>&1
    Reg.exe add "%%a" /v "*PMARPOffload" /t REG_SZ /d "1" /f >nul 2>&1
    Reg.exe add "%%a" /v "*PMNSOffload" /t REG_SZ /d "1" /f >nul 2>&1
    Reg.exe add "%%a" /v "*PriorityVLANTag" /t REG_SZ /d "1" /f >nul 2>&1
    Reg.exe add "%%a" /v "*RSS" /t REG_SZ /d "1" /f >nul 2>&1
    Reg.exe add "%%a" /v "*WakeOnMagicPacket" /t REG_SZ /d "0" /f >nul 2>&1
    Reg.exe add "%%a" /v "AutoPowerSaveModeEnabled" /t REG_SZ /d "0" /f >nul 2>&1
    Reg.exe add "%%a" /v "*WakeOnPattern" /t REG_SZ /d "0" /f >nul 2>&1
    Reg.exe add "%%a" /v "*TCPChecksumOffloadIPv4" /t REG_SZ /d "3" /f >nul 2>&1
    Reg.exe add "%%a" /v "*TCPChecksumOffloadIPv6" /t REG_SZ /d "3" /f >nul 2>&1
    Reg.exe add "%%a" /v "*UDPChecksumOffloadIPv4" /t REG_SZ /d "3" /f >nul 2>&1
    Reg.exe add "%%a" /v "*UDPChecksumOffloadIPv6" /t REG_SZ /d "3" /f >nul 2>&1
    Reg.exe add "%%a" /v "DMACoalescing" /t REG_SZ /d "0" /f >nul 2>&1
    Reg.exe add "%%a" /v "EEELinkAdvertisement" /t REG_SZ /d "0" /f >nul 2>&1
    Reg.exe add "%%a" /v "EeePhyEnable" /t REG_SZ /d "0" /f >nul 2>&1
    Reg.exe add "%%a" /v "ITR" /t REG_SZ /d "0" /f >nul 2>&1
    Reg.exe add "%%a" /v "ReduceSpeedOnPowerDown" /t REG_SZ /d "0" /f >nul 2>&1
    Reg.exe add "%%a" /v "PowerDownPll" /t REG_SZ /d "0" /f >nul 2>&1
    Reg.exe add "%%a" /v "WaitAutoNegComplete" /t REG_SZ /d "0" /f >nul 2>&1
    Reg.exe add "%%a" /v "WakeOnLink" /t REG_SZ /d "0" /f >nul 2>&1
    Reg.exe add "%%a" /v "WakeOnSlot" /t REG_SZ /d "0" /f >nul 2>&1
    Reg.exe add "%%a" /v "WakeUpModeCap" /t REG_SZ /d "0" /f >nul 2>&1
    Reg.exe add "%%a" /v "AdvancedEEE" /t REG_SZ /d "0" /f >nul 2>&1
    Reg.exe add "%%a" /v "EnableGreenEthernet" /t REG_SZ /d "0" /f >nul 2>&1
    Reg.exe add "%%a" /v "GigaLite" /t REG_SZ /d "0" /f >nul 2>&1
    Reg.exe add "%%a" /v "PnPCapabilities" /t REG_DWORD /d "24" /f >nul 2>&1
    Reg.exe add "%%a" /v "PowerSavingMode" /t REG_SZ /d "0" /f >nul 2>&1
    Reg.exe add "%%a" /v "ULPMode" /t REG_SZ /d "0" /f >nul 2>&1
    Reg.exe add "%%a" /v "Ultra Low Power Mode" /t REG_SZ /d "Disabled" /f >nul 2>&1
    Reg.exe add "%%a" /v "System Idle Power Saver" /t REG_SZ /d "Disabled" /f >nul 2>&1
    Reg.exe add "%%a" /v "Selective Suspend" /t REG_SZ /d "Disabled" /f >nul 2>&1
    Reg.exe add "%%a" /v "Selective Suspend Idle Timeout" /t REG_SZ /d "60" /f >nul 2>&1
    Reg.exe add "%%a" /v "Link Speed Battery Saver" /t REG_SZ /d "Disabled" /f >nul 2>&1
    Reg.exe add "%%a" /v "*SelectiveSuspend" /t REG_SZ /d "0" /f >nul 2>&1
    Reg.exe add "%%a" /v "EnableLLI" /t REG_SZ /d "1" /f >nul 2>&1
)

powershell -Command "Get-NetAdapterBinding -ComponentID ms_tcpip6, vmware_bridge, ms_lldp, ms_lltdio, ms_implat, ms_rspndr, ms_server, ms_msclient | Disable-NetAdapterBinding" >nul 2>&1

netsh int tcp set global dca=enabled >nul 2>&1
netsh int tcp set global netdma=enabled >nul 2>&1
netsh int tcp set heuristics disabled >nul 2>&1
netsh int tcp set global ecncapability=disabled >nul 2>&1
netsh interface isatap set state disabled >nul 2>&1
netsh int tcp set global timestamps=disabled >nul 2>&1
netsh int tcp set global rss=enabled >nul 2>&1
netsh int tcp set global nonsackrttresiliency=disabled >nul 2>&1
netsh int tcp set global initialRto=2000 >nul 2>&1
netsh int tcp set supplemental template=custom icw=10 congestionprovider=cubic >nul 2>&1
netsh interface ip set interface ethernet currenthoplimit=64 >nul 2>&1
netsh int ip set global taskoffload=enabled >nul 2>&1
netsh int tcp set global autotuninglevel=restricted >nul 2>&1
netsh int tcp set global rsc=disabled >nul 2>&1
netsh interface ipv4 set subinterface "Ethernet" mtu=1492 store=persistent >nul 2>&1
netsh interface ipv4 set subinterface "Wi-Fi" mtu=1492 store=persistent >nul 2>&1
ipconfig /flushdns >nul 2>&1

bcdedit /set disabledynamictick Yes >nul 2>&1
bcdedit /set useplatformclock No >nul 2>&1
bcdedit /set useplatformtick No >nul 2>&1
bcdedit /set hypervisorlaunchtype off >nul 2>&1

echo Network Engine Stack  Successfully!
timeout /t 2 >nul
exit