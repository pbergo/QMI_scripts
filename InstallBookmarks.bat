@ECHO OFF
SETLOCAL
SET confirm=N
ECHO ***************************************
ECHO **********    WARNING!!!!!  ***********
ECHO This script will create Chrome Bookmarks 
ECHO It will overwrite any Bookmarks at 
ECHO Google Chrome.
:PROMPT
SET /P confirm=Are you sure (Y/[N])?
IF /I "%confirm%" NEQ "Y" GOTO ENDBYUSER

ECHO Creating tempfile DownloadBookmarks...
ECHO $url = "https://qliktechnologies365-my.sharepoint.com/:u:/g/personal/ide_qlik_com/EQ7BYHsuHXFMl_5yc6V8HJIBT5lH9DrJoHE4VFiolv9Qjw?e=ZdWM6H" > C:\Users\Administrator\Downloads\TempDownloadBookmarks.ps1
ECHO $output = "C:\Users\Administrator\Downloads\ChromeBookmarks.zip"                                                                           >> C:\Users\Administrator\Downloads\TempDownloadBookmarks.ps1
ECHO $start_time = Get-Date                                                                                                                     >> C:\Users\Administrator\Downloads\TempDownloadBookmarks.ps1
ECHO Import-Module BitsTransfer                                                                                                                 >> C:\Users\Administrator\Downloads\TempDownloadBookmarks.ps1
ECHO Start-BitsTransfer -Source $url -Destination $output                                                                                       >> C:\Users\Administrator\Downloads\TempDownloadBookmarks.ps1

ECHO Creating tempfile UnzipBookmark...
ECHO $shell = New-Object -ComObject Shell.Application                                     > C:\Users\Administrator\Downloads\TempUnzipBookmarks.ps1
ECHO $zipFile = $shell.NameSpace("C:\Users\Administrator\Downloads\ChromeBookmarks.zip")  >> C:\Users\Administrator\Downloads\TempUnzipBookmarks.ps1
ECHO $destinationFolder = $shell.NameSpace("C:\Users\Administrator\Downloads\ChromeBookmarks\")            >> C:\Users\Administrator\Downloads\TempUnzipBookmarks.ps1
ECHO $destinationFolder.CopyHere($zipFile.Items())                                          >> C:\Users\Administrator\Downloads\TempUnzipBookmarks.ps1

ECHO Downloading bookmarks files...
CD "c:\Users\Administrator\Downloads"
POWERSHELL c:\Users\Administrator\Downloads\TempDownloadBookmarks.ps1 > C:\Users\Administrator\Downloads\DownloadBookmarks.log

ECHO Unpacking sakila files...
CD "c:\Users\Administrator\Downloads"
POWERSHELL c:\Users\Administrator\Downloads\TempUnzipBookmarks.ps1> C:\Users\Administrator\Downloads\UnzipBookmarks.log

ECHO Installing Bookmarks...
SET CHROMEBASE=%LOCALAPPDATA%\Google\Chrome\User Data\Default\
SET CHROMEBACKUPDIR=C:\Users\Administrator\Downloads\ChromeBookmarks
REM IF EXIST "%CHROMEBACKUPDIR%" XCOPY "%CHROMEBACKUPDIR%" "%CHROMEBASE%" /E /Q /Y

GOTO :END

:ENDBYUSER
ECHO Bookmarks will not be updated !
GOTO :END

:CLEANFILES
ECHO Deleting tempfiles...
DEL /s /q C:\Users\Administrator\Downloads\Temp*.ps1  >nul 2>&1
DEL /s /q C:\Users\Administrator\Downloads\Qlik*.zip  >nul 2>&1
GOTO :END

:END 
ECHO ***************************************
ECHO Process terminated !
PAUSE

ENDLOCAL
