@ECHO OFF
SETLOCAL
SET confirm=N
ECHO ***************************************
ECHO **********    WARNING!!!!!  ***********
ECHO This script will update QDI files
ECHO - Qlik Replicate - 2021.11 SR1
ECHO - Qlik Enterprise Manager - 2021.11 SR1
ECHO - Qlik Compose - 2021.08 SR2
:PROMPT
SET /P confirm=Are you sure (Y/[N])?
IF /I "%confirm%" NEQ "Y" GOTO ENDBYUSER

ECHO Cleaning log files...
CD "c:\Users\Administrator\Downloads"
DEL /S /Q *.LOG

ECHO Checking Utils...
CD "c:\Users\Administrator\Downloads"
IF NOT EXIST WGET.EXE {
    IF NOT EXIST DownloadUtils.bat (
        ECHO Creating tempfile DownloadUtils...
        ECHO $url = "https://raw.githubusercontent.com/pbergo/QMI_scripts/master/DownloadUtils.bat"    > C:\Users\Administrator\Downloads\TempDownloadUtils.ps1
        ECHO $output = "C:\Users\Administrator\Downloads\DownloadUtils.bat"                            >> C:\Users\Administrator\Downloads\TempDownloadUtils.ps1
        ECHO $start_time = Get-Date                                                                    >> C:\Users\Administrator\Downloads\TempDownloadUtils.ps1
        ECHO Import-Module BitsTransfer                                                                >> C:\Users\Administrator\Downloads\TempDownloadUtils.ps1
        ECHO Download Utils...
        POWERSHELL c:\Users\Administrator\Downloads\TempDownloadUtils.ps1 >> C:\Users\Administrator\Downloads\UpdateQDI.log
    )
    CALL "C:\Users\Administrator\Downloads\DownloadUtils.bat"
}

ECHO Download Qlik Replicate...
IF EXIST QlikReplicate.zip DEL /S /Q QlikReplicate.zip
WGET -O QlikReplicate.zip https://da3hntz84uekx.cloudfront.net/QlikReplicate/2021.11/2/_MSI/QlikReplicate_2021.11.0.165_X64.zip --append-output=UpdateQDI.log

ECHO Download Qlik Enterprise Manager...
IF EXIST QlikEM.zip DEL /S /Q QlikEM.zip
WGET -O QlikEM.zip https://da3hntz84uekx.cloudfront.net/QlikEnterpriseManager/2021.11/2/_MSI/QlikEnterpriseManager_2021.11.0.198_X64.zip --append-output=UpdateQDI.log

ECHO Download Qlik Compose...
IF EXIST QlikCompose.zip DEL /S /Q QlikCompose.zip
WGET -O QlikCompose.zip https://da3hntz84uekx.cloudfront.net/QlikCompose/2021.8.0/6/_MSI/Qlik_Compose_2021.8.0.336.zip --append-output=UpdateQDI.log

ECHO Download Bookmarks...
IF EXIST ChromeBookmarks.zip DEL /S /Q ChromeBookmarks.zip
WGET -O ChromeBookmarks.zip https://github.com/pbergo/QMI_scripts/raw/master/ChromeBookmarks.zip --append-output=UpdateQDI.log

ECHO Unzip Qlik Replicate...
UNZIP -O QlikReplicate.zip >> C:\Users\Administrator\Downloads\UpdateQDI.log
ECHO Upgrading Qlik Replicate...
QlikReplicate_2021.11.0.165_X64.exe

ECHO Unzip Qlik Compose...
UNZIP -O QlikCompose.zip >> C:\Users\Administrator\Downloads\UpdateQDI.log
ECHO Upgrading Qlik Compose...
Qlik_Compose_2021.8.0.336.exe

ECHO Unzip Qlik Enterprise Manager...
UNZIP -O QlikEM.zip >> C:\Users\Administrator\Downloads\UpdateQDI.log
ECHO Installing Qlik Enterprise Manager...
QlikEnterpriseManager_2021.11.0.198_X64.exe

ECHO Unzip Bookmarks...
UNZIP -O ChromeBookmarks.zip >> C:\Users\Administrator\Downloads\UpdateQDI.log
ECHO Installing Bookmarks...
SET CHROMEBASE=%LOCALAPPDATA%\Google\Chrome\User Data\Default\
SET CHROMEBACKUPDIR=C:\Users\Administrator\Downloads\ChromeBookmarks
IF EXIST "%CHROMEBACKUPDIR%" XCOPY "%CHROMEBACKUPDIR%" "%CHROMEBASE%" /E /Q /Y


GOTO :CLEANFILES

:ENDBYUSER
ECHO QDI will not be updated !
GOTO :END

:CLEANFILES
ECHO Deleting tempfiles...
DEL /s /q C:\Users\Administrator\Downloads\TempDownloadUtils.ps1  >nul 2>&1
DEL /s /q C:\Users\Administrator\Downloads\Qlik*.zip  >nul 2>&1
DEL /s /q C:\Users\Administrator\Downloads\*.exe
GOTO :END

:END 
ECHO ***************************************
ECHO Process terminated !
PAUSE

ENDLOCAL
