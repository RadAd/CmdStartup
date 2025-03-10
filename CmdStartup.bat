@echo off
Rem does cmd line contain "/C" and therefore will no enter interactive mode
((echo. "%CMDCMDLINE%" | findstr /I /C:" /C ") > NUL 2> NUL) && goto :of

echo.
echo CmdStartup installed
echo See %0
