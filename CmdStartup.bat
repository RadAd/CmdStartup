@echo off
Rem does cmd line contain "/C" and therefore will not enter interactive mode
((echo. "%CMDCMDLINE%" | findstr /I /C:" /C ") > NUL 2> NUL) && goto :eof

echo.
echo CmdStartup installed
echo See %0
