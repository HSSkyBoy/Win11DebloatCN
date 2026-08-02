@echo off
setlocal

:: This file is ASCII-only so CMD never misparses Chinese UTF-8 bytes as syntax.
set "wtDefaultPath=%LOCALAPPDATA%\Microsoft\WindowsApps\wt.exe"
set "wtScoopPath=%USERPROFILE%\scoop\apps\windows-terminal\current\wt.exe"
set "logFile=%~dp0Logs\Win11Debloat-Run.log"
set "msgUsingWindowsTerminal=5q2j5Zyo5L2/55SoIFdpbmRvd3Mg57uI56uv5ZCv5YqoIFdpbjExRGVibG9hdC5wczEuLi4="
set "msgWindowsTerminalNotFound=5pyq5om+5YiwIFdpbmRvd3Mg57uI56uv77yM5q2j5Zyo5L2/55So6buY6K6kIFBvd2VyU2hlbGwuLi4="
set "msgUsingDefaultPowerShell=5pyq5om+5YiwIFdpbmRvd3Mg57uI56uv44CC5q2j5Zyo5L2/55So6buY6K6kIFBvd2VyU2hlbGwg5ZCv5YqoIFdpbjExRGVibG9hdC5wczEuLi4="
set "msgHelp=5aaC5p6c5oKo6ZyA6KaB5pu05aSa5biu5Yqp77yM6K+35Zyo5Lul5LiL5L2N572u5o+Q5Lqk6Zeu6aKY77ya"
set "msgLogSaved=5pel5b+X5bey6K6w5b2V5Yiw"

if not exist "%~dp0Logs" mkdir "%~dp0Logs"

if exist "%wtDefaultPath%" (
    set "wtPath=%wtDefaultPath%"
) else if exist "%wtScoopPath%" (
    set "wtPath=%wtScoopPath%"
) else (
    set "wtPath="
)

:: Interpolated into a PS single-quoted string below.
set "SCRIPT_PATH=%~dp0Win11Debloat.ps1"

if defined wtPath (
    call :LogUtf8 "%msgUsingWindowsTerminal%"
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "$p='%SCRIPT_PATH:'=''%'; $w='%wtPath:'=''%'; $q=[char]34; Start-Process -FilePath $w -ArgumentList ('PowerShell -NoProfile -ExecutionPolicy Bypass -File ' + $q + $p + $q) -Verb RunAs" >> "%logFile%" || call :Error "PowerShell command failed"
) else (
    call :WriteUtf8 "%msgWindowsTerminalNotFound%"
    call :LogUtf8 "%msgUsingDefaultPowerShell%"
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "$p='%SCRIPT_PATH:'=''%'; $q=[char]34; Start-Process PowerShell -ArgumentList ('-NoProfile -ExecutionPolicy Bypass -File ' + $q + $p + $q) -Verb RunAs" >> "%logFile%" || call :Error "PowerShell command failed"
)

echo.
call :WriteUtf8 "%msgHelp%"
echo https://github.com/HSSkyBoy/Win11DebloatCN/issues
goto :EOF

:WriteUtf8
PowerShell -NoProfile -Command "$s=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('%~1')); [Console]::OutputEncoding=[Text.UTF8Encoding]::new(); [Console]::WriteLine($s)"
goto :EOF

:LogUtf8
PowerShell -NoProfile -Command "$s=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('%~1')); [Console]::OutputEncoding=[Text.UTF8Encoding]::new(); [Console]::WriteLine($s)" >> "%logFile%"
goto :EOF

:Log
echo(%* >> "%logFile%"
goto :EOF

:Error
echo(ERROR: %*
call :Log ERROR: %*
call :WriteUtf8 "%msgLogSaved%"
echo %logFile%
pause
goto :EOF
