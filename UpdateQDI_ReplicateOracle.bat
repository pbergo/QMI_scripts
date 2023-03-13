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
ECHO .
ECHO It also disable Qlik Compose and import Sakila and
ECHO Employees DB to MySQL local instance.
ECHO .
:PROMPT
SET /P confirm=Are you sure (Y/[N])?
IF /I "%confirm%" NEQ "Y" GOTO ENDBYUSER

ECHO Cleaning log files...
CD "%homepath%\Downloads"
DEL /S /Q *.LOG

ECHO Checking Utils...
CD "%homepath%\Downloads"
IF NOT EXIST QLIKWGET.EXE GOTO :INSTALLUTILS
GOTO :UPDATEQDI

:INSTALLUTILS
ECHO Creating tempfile DownloadWget...
ECHO $url = "https://github.com/pbergo/QMI_scripts/raw/master/Utils/wget.exe"   > %homepath%\Downloads\TempDownloadUtils.ps1
ECHO $output = "C:\Users\Administrator\Downloads\Qlikwget.exe"                  >> %homepath%\Downloads\TempDownloadUtils.ps1
ECHO $start_time = Get-Date                                                     >> %homepath%\Downloads\TempDownloadUtils.ps1
ECHO Import-Module BitsTransfer                                                 >> %homepath%\Downloads\TempDownloadUtils.ps1
ECHO Start-BitsTransfer -Source $url -Destination $output                       >> %homepath%\Downloads\TempDownloadUtils.ps1

ECHO Downloading Util files...
CD "%homepath%\Downloads"
POWERSHELL %homepath%\Downloads\TempDownloadUtils.ps1 > %homepath%\Downloads\UpdateQDI.log
IF NOT EXIST QlikUNZIP.EXE QlikWGET -O QlikUNZIP.EXE https://github.com/pbergo/QMI_scripts/raw/master/Utils/unzip.exe --append-output=UpdateQDI.log
GOTO :UPDATEQDI

:UPDATEQDI
ECHO Downloading Qlik Replicate...
IF EXIST QlikReplicate.zip DEL /S /Q QlikReplicate.zip
QlikWGET -O QlikReplicate.zip https://da3hntz84uekx.cloudfront.net/QlikReplicate/2021.11/2/_MSI/QlikReplicate_2021.11.0.165_X64.zip --append-output=UpdateQDI.log

ECHO Downloading Qlik Enterprise Manager...
IF EXIST QlikEM.zip DEL /S /Q QlikEM.zip
QlikWGET -O QlikEM.zip https://da3hntz84uekx.cloudfront.net/QlikEnterpriseManager/2021.11/2/_MSI/QlikEnterpriseManager_2021.11.0.198_X64.zip --append-output=UpdateQDI.log

ECHO Downloading Bookmarks...
IF EXIST QlikBookmarks.zip DEL /S /Q QlikBookmarks.zip
QlikWGET -O QlikBookmarks.zip https://github.com/pbergo/QMI_scripts/raw/master/ChromeBookmarks.zip --append-output=UpdateQDI.log

ECHO Unpacking Qlik Replicate...
QlikUNZIP -o QlikReplicate.zip >> %homepath%\Downloads\UpdateQDI.log
ECHO Upgrading Qlik Replicate...
QlikReplicate_2021.11.0.165_X64.exe

ECHO Stopping Qlik Compose Service to save memory...
"C:\Program Files\Qlik\Compose\bin\ComposeCtl.exe" service stop

ECHO Unpacking Qlik Enterprise Manager...
QlikUNZIP -o QlikEM.zip >> %homepath%\Downloads\UpdateQDI.log
ECHO Installing Qlik Enterprise Manager...
QlikEnterpriseManager_2021.11.0.198_X64.exe

ECHO Unpacking Bookmarks...
QlikUNZIP -o QlikBookmarks.zip >> %homepath%\Downloads\UpdateQDI.log
:CHKCHROMEOPEN
ECHO Installing Bookmarks...
TASKLIST /FI "IMAGENAME eq chrome.exe" | FINDSTR "chrome.exe" > nul
IF %ERRORLEVEL% == 0 (
CALL :CHROMEISOPEN
GOTO :CHKCHROMEOPEN
)
SET CHROMEBASE=%LOCALAPPDATA%\Google\Chrome\User Data\Default\
SET CHROMEBACKUPDIR=%homepath%\Downloads\ChromeBookmarks
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
ECHO Downloding DB files...
IF EXIST Qliksakila-db.zip DEL /S /Q Qliksakila-db.zip 
QlikWGET -O Qliksakila-db.zip https://downloads.mysql.com/docs/sakila-db.zip
IF EXIST Qlikemployee-db.zip DEL /S /Q Qliksakila-db.zip 
QlikWGET -O Qlikemployee-db.zip https://github.com/datacharmer/test_db/archive/refs/heads/master.zip

ECHO Unpacking sakila...
QlikUNZIP -o Qliksakila-db.zip >> %homepath%\Downloads\UpdateQDI.log
ECHO Creating tempfile ImportSakila...
ECHO DROP SCHEMA IF EXISTS sakila;                                                  > %homepath%\Downloads\TempImportSakila.sql
ECHO SOURCE C:/Users/Administrator/Downloads/sakila-db/sakila-schema.sql;           >> %homepath%\Downloads\TempImportSakila.sql
ECHO SOURCE C:/Users/Administrator/Downloads/sakila-db/sakila-data.sql;             >> %homepath%\Downloads\TempImportSakila.sql
ECHO GRANT SUPER ON *.* TO compose;                                                 >> %homepath%\Downloads\TempImportSakila.sql
ECHO GRANT ALL ON *.* TO compose;                                                   >> %homepath%\Downloads\TempImportSakila.sql
ECHO Installing sakila database...
"C:\Program Files\MySQL\MySQL Server 5.7\bin\mysql" -u root < %homepath%\Downloads\TempImportSakila.sql >> %homepath%\Downloads\UpdateQDI.log

ECHO Unpacking employee...
QlikUNZIP -o Qlikemployee-db.zip >> %homepath%\Downloads\UpdateQDI.log
ECHO Adding grant security to standard ImportEmployee...
ECHO GRANT SUPER ON *.* TO compose;                                                 >> %homepath%\Downloads\test_db-master\employees.sql
ECHO GRANT ALL ON *.* TO compose;                                                   >> %homepath%\Downloads\test_db-master\employees.sql
ECHO Installing employee database...
CD "%homepath%\Downloads\test_db-master"
"C:\Program Files\MySQL\MySQL Server 5.7\bin\mysql" -u root < %homepath%\Downloads\test_db-master\employees.sql >> %homepath%\Downloads\UpdateQDI.log
CD "%homepath%\Downloads"

ECHO Updating Info Files...
CD "%homepath%\Desktop"
DEL /S /Q *.txt
DEL /S /Q *.url
IF NOT EXIST Lab_Env_Information.txt QlikWGET -O Lab_Env_Information.txt https://github.com/pbergo/QMI_scripts/raw/master/QlikReplicate_Lab_Env_Information.txt --append-output=UpdateQDI.log

GOTO :CLEANFILES

:ENDBYUSER
ECHO QDI will not be updated !
GOTO :END

:CLEANFILES
ECHO Deleting tempfiles...
DEL /s /q %homepath%\Downloads\Temp*.ps1  >nul 2>&1
DEL /s /q %homepath%\Downloads\Temp*.sql  >nul 2>&1
DEL /s /q %homepath%\Downloads\Qlik*.zip  >nul 2>&1
DEL /s /q %homepath%\Downloads\Qlik*.exe  >nul 2>&1
DEL /s /q %homepath%\Downloads\.wget-hsts  >nul 2>&1
RMDIR /s /q %homepath%\Downloads\ChromeBookmarks >nul 2>&1
RMDIR /s /q %homepath%\Downloads\sakila-db >nul 2>&1
RMDIR /s /q %homepath%\Downloads\test_db-master >nul 2>&1
GOTO :END

:END 
ECHO Update QDI Process terminated !
ECHO You will need to update Qlik licensing !
ECHO ************************************************
PAUSE

ENDLOCAL
