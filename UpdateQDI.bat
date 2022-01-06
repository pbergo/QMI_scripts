@ECHO OFF
REM ****************************************************
REM * Copyright: Qlik (c) 2022                         *
REM * Author: Pedro Bergo - pedro.bergo@qlik.com       *
REM * Purpose: Update QDI version of training machines *
REM ****************************************************
SETLOCAL
SET confirm=N
ECHO ************************************************
ECHO **********      WARNING!!!!!         ***********
ECHO This script will update QDI files:
ECHO - Qlik Replicate - 2021.11 SR1
ECHO - Qlik Enterprise Manager - 2021.11 SR1
ECHO - Qlik Compose - 2021.08 SR2
ECHO It also try to import Sakila and Employees DB to
ECHO MySQL local instance.
ECHO .
:PROMPT
SET /P confirm=Are you sure (Y/[N])?
IF /I "%confirm%" NEQ "Y" GOTO ENDBYUSER

ECHO Cleaning log files...
CD "c:\Users\Administrator\Downloads"
DEL /S /Q *.LOG

ECHO Checking Utils...
CD "c:\Users\Administrator\Downloads"
IF NOT EXIST WGET.EXE GOTO :INSTALLUTILS
GOTO :UPDATEQDI

:INSTALLUTILS
ECHO Creating tempfile DownloadWget...
ECHO $url = "https://github.com/pbergo/QMI_scripts/raw/master/Utils/wget.exe"   > C:\Users\Administrator\Downloads\TempDownloadUtils.ps1
ECHO $output = "C:\Users\Administrator\Downloads\wget.exe"                      >> C:\Users\Administrator\Downloads\TempDownloadUtils.ps1
ECHO $start_time = Get-Date                                                     >> C:\Users\Administrator\Downloads\TempDownloadUtils.ps1
ECHO Import-Module BitsTransfer                                                 >> C:\Users\Administrator\Downloads\TempDownloadUtils.ps1
ECHO Start-BitsTransfer -Source $url -Destination $output                       >> C:\Users\Administrator\Downloads\TempDownloadUtils.ps1

ECHO Downloading Util files...
CD "c:\Users\Administrator\Downloads"
POWERSHELL c:\Users\Administrator\Downloads\TempDownloadUtils.ps1 > C:\Users\Administrator\Downloads\UpdateQDI.log
IF NOT EXIST UNZIP.EXE WGET https://github.com/pbergo/QMI_scripts/raw/master/Utils/unzip.exe --append-output=UpdateQDI.log
GOTO :UPDATEQDI

:UPDATEQDI
ECHO Downloading Qlik Replicate...
IF EXIST QlikReplicate.zip DEL /S /Q QlikReplicate.zip
WGET -O QlikReplicate.zip https://da3hntz84uekx.cloudfront.net/QlikReplicate/2021.11/2/_MSI/QlikReplicate_2021.11.0.165_X64.zip --append-output=UpdateQDI.log

ECHO Downloading Qlik Enterprise Manager...
IF EXIST QlikEM.zip DEL /S /Q QlikEM.zip
WGET -O QlikEM.zip https://da3hntz84uekx.cloudfront.net/QlikEnterpriseManager/2021.11/2/_MSI/QlikEnterpriseManager_2021.11.0.198_X64.zip --append-output=UpdateQDI.log

ECHO Downloading Qlik Compose...
IF EXIST QlikCompose.zip DEL /S /Q QlikCompose.zip
WGET -O QlikCompose.zip https://da3hntz84uekx.cloudfront.net/QlikCompose/2021.8.0/6/_MSI/Qlik_Compose_2021.8.0.336.zip --append-output=UpdateQDI.log

ECHO Downloading Bookmarks...
IF EXIST QlikBookmarks.zip DEL /S /Q QlikBookmarks.zip
WGET -O QlikBookmarks.zip https://github.com/pbergo/QMI_scripts/raw/master/ChromeBookmarks.zip --append-output=UpdateQDI.log

ECHO Unzip Qlik Replicate...
UNZIP -o QlikReplicate.zip >> C:\Users\Administrator\Downloads\UpdateQDI.log
ECHO Upgrading Qlik Replicate...
QlikReplicate_2021.11.0.165_X64.exe

ECHO Unzip Qlik Compose...
UNZIP -o QlikCompose.zip >> C:\Users\Administrator\Downloads\UpdateQDI.log
ECHO Stopping Qlik Compose Service to save memory...
"C:\Program Files\Qlik\Compose\bin\ComposeCtl.exe" service stop
REM ECHO Upgrading Qlik Compose...
REM Qlik_Compose_2021.8.0.336.exe

ECHO Unzip Qlik Enterprise Manager...
UNZIP -o QlikEM.zip >> C:\Users\Administrator\Downloads\UpdateQDI.log
ECHO Installing Qlik Enterprise Manager...
QlikEnterpriseManager_2021.11.0.198_X64.exe

ECHO Unzip Bookmarks...
UNZIP -o QlikBookmarks.zip >> C:\Users\Administrator\Downloads\UpdateQDI.log
:CHKCHROMEOPEN
ECHO Installing Bookmarks...
TASKLIST /FI "IMAGENAME eq chrome.exe" | FINDSTR "chrome.exe" > nul
IF %ERRORLEVEL% == 0 (
CALL :CHROMEISOPEN
GOTO :CHKCHROMEOPEN
)
SET CHROMEBASE=%LOCALAPPDATA%\Google\Chrome\User Data\Default\
SET CHROMEBACKUPDIR=C:\Users\Administrator\Downloads\ChromeBookmarks
IF EXIST "%CHROMEBACKUPDIR%" XCOPY "%CHROMEBACKUPDIR%" "%CHROMEBASE%" /E /Q /Y /c
GOTO :INSTALLDBS

:CHROMEISOPEN
ECHO Please close Google Chrome.
ECHO If it appears to be closed but you still get this error please use task manager to end tasks with the name of "chrome.exe".
ECHO I will automatically try again once you continue.
ECHO Press any key to continue...
CHOICE /N /C Y /D Y /T 2 > NUL
PAUSE >NUL
GOTO :INSTALLDBS

:INSTALLDBS
ECHO Installing sakila...
IF EXIST ImportSakila.bat DEL /S /Q ImportSakila.bat
WGET -O ImportSakila.bat https://github.com/pbergo/QMI_scripts/raw/master/ImportSakila.bat --append-output=UpdateQDI.log
CALL ImportSakila.bat

ECHO Installing Employee...
IF EXIST ImportEmployee.bat DEL /S /Q ImportEmployee.bat
WGET -O ImportEmployee.bat https://github.com/pbergo/QMI_scripts/raw/master/ImportEmployee.bat --append-output=UpdateQDI.log
CALL ImportEmployee.bat

GOTO :CLEANFILES
:ENDBYUSER
ECHO QDI will not be updated !
GOTO :END

:CLEANFILES
ECHO Deleting tempfiles...
DEL /s /q C:\Users\Administrator\Downloads\TempDownloadUtils.ps1  >nul 2>&1
DEL /s /q C:\Users\Administrator\Downloads\Qlik*.zip  >nul 2>&1
DEL /s /q C:\Users\Administrator\Downloads\*.exe  >nul 2>&1
RMDIR /s /q C:\Users\Administrator\Downloads\ChromeBookmarks >nul 2>&1
GOTO :END

:END 
ECHO Update QDI Process terminated !
ECHO You will need to update Qlik licensing !
ECHO ************************************************
PAUSE

ENDLOCAL
