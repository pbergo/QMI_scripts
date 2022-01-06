@ECHO OFF
SETLOCAL
SET confirm=N
ECHO ***************************************
ECHO **********    WARNING!!!!!  ***********
ECHO This script will download utils 
ECHO  wget, unzip and curl files.
:PROMPT
SET /P confirm=Are you sure (Y/[N])?
IF /I "%confirm%" NEQ "Y" GOTO ENDBYUSER

ECHO Creating tempfile DownloadUtils...
ECHO $url = "https://github.com/pbergo/QMI_scripts/raw/master/Utils/wget.exe"   > C:\Users\Administrator\Downloads\TempDownloadUtils.ps1
ECHO $output = "C:\Users\Administrator\Downloads\wget.exe"                      >> C:\Users\Administrator\Downloads\TempDownloadUtils.ps1
ECHO $start_time = Get-Date                                                     >> C:\Users\Administrator\Downloads\TempDownloadUtils.ps1
ECHO Import-Module BitsTransfer                                                 >> C:\Users\Administrator\Downloads\TempDownloadUtils.ps1
ECHO Start-BitsTransfer -Source $url -Destination $output                       >> C:\Users\Administrator\Downloads\TempDownloadUtils.ps1

ECHO Downloading Util files...
CD "c:\Users\Administrator\Downloads"
POWERSHELL c:\Users\Administrator\Downloads\TempDownloadUtils.ps1 > C:\Users\Administrator\Downloads\TempDownloadUtils.log

GOTO :CLEANFILES

:ENDBYUSER
ECHO Utils will not be downloaded !
GOTO :END

:CLEANFILES
ECHO Deleting tempfiles...
DEL /s /q C:\Users\Administrator\Downloads\Temp*.ps1  >nul 2>&1
GOTO :END

:END 
ECHO ***************************************
ECHO Process terminated !
PAUSE

ENDLOCAL
