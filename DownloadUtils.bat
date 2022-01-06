@ECHO OFF
SETLOCAL
ECHO ***************************************
ECHO This script will download utils 
ECHO  wget, unzip and curl files.
ECHO Creating tempfile DownloadWget...
ECHO $url = "https://github.com/pbergo/QMI_scripts/raw/master/Utils/wget.exe"   > C:\Users\Administrator\Downloads\TempDownloadUtils.ps1
ECHO $output = "C:\Users\Administrator\Downloads\wget.exe"                      >> C:\Users\Administrator\Downloads\TempDownloadUtils.ps1
ECHO $start_time = Get-Date                                                     >> C:\Users\Administrator\Downloads\TempDownloadUtils.ps1
ECHO Import-Module BitsTransfer                                                 >> C:\Users\Administrator\Downloads\TempDownloadUtils.ps1
ECHO Start-BitsTransfer -Source $url -Destination $output                       >> C:\Users\Administrator\Downloads\TempDownloadUtils.ps1

ECHO Downloading Util files...
CD "c:\Users\Administrator\Downloads"
POWERSHELL c:\Users\Administrator\Downloads\TempDownloadUtils.ps1 > C:\Users\Administrator\Downloads\DownloadUtils.log
CD "c:\Users\Administrator\Downloads"
IF NOT EXIST UNZIP.EXE WGET https://github.com/pbergo/QMI_scripts/raw/master/Utils/unzip.exe --append-output=DownloadUtils.log
REM IF NOT EXIST CURL.EXE  WGET https://github.com/pbergo/QMI_scripts/raw/master/Utils/curl.exe  --append-output=DownloadUtils.log
GOTO :CLEANFILES

:CLEANFILES
ECHO Deleting tempfiles...
DEL /s /q C:\Users\Administrator\Downloads\TempDownloadUtils.ps1  >nul 2>&1
GOTO :END

:END 
ECHO Download Utils terminated !
ECHO ***************************************

ENDLOCAL
