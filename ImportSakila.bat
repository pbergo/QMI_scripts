@ECHO OFF
SETLOCAL
SET confirm=N
ECHO ***************************************
ECHO **********    WARNING!!!!!  ***********
ECHO This script will create MySQL sakila 
ECHO database. It will drop and recreate the 
ECHO sakila schema and data set.
:PROMPT
SET /P confirm=Are you sure (Y/[N])?
IF /I "%confirm%" NEQ "Y" GOTO ENDBYUSER

ECHO Creating tempfile DownloadSakila...
ECHO $url = "https://downloads.mysql.com/docs/sakila-db.zip"                        > C:\Users\Administrator\Downloads\TempDownloadSakila.ps1
ECHO $output = "C:\Users\Administrator\Downloads\sakila-db.zip"                     >> C:\Users\Administrator\Downloads\TempDownloadSakila.ps1
ECHO $start_time = Get-Date                                                         >> C:\Users\Administrator\Downloads\TempDownloadSakila.ps1
ECHO Import-Module BitsTransfer                                                     >> C:\Users\Administrator\Downloads\TempDownloadSakila.ps1
ECHO Start-BitsTransfer -Source $url -Destination $output                           >> C:\Users\Administrator\Downloads\TempDownloadSakila.ps1

ECHO Creating tempfile UnzipSakila...
ECHO $shell = New-Object -ComObject Shell.Application                               > C:\Users\Administrator\Downloads\TempUnzipSakila.ps1
ECHO $zipFile = $shell.NameSpace("C:\Users\Administrator\Downloads\sakila-db.zip")  >> C:\Users\Administrator\Downloads\TempUnzipSakila.ps1
ECHO $destinationFolder = $shell.NameSpace("C:\Users\Administrator\Downloads")      >> C:\Users\Administrator\Downloads\TempUnzipSakila.ps1
ECHO $destinationFolder.CopyHere($zipFile.Items())                                  >> C:\Users\Administrator\Downloads\TempUnzipSakila.ps1

ECHO Creating tempfile ImportSakila...
ECHO DROP SCHEMA IF EXISTS sakila;                                                  > C:\Users\Administrator\Downloads\TempImportSakila.sql
ECHO SOURCE C:/Users/Administrator/Downloads/sakila-db/sakila-schema.sql;           >> C:\Users\Administrator\Downloads\TempImportSakila.sql
ECHO SOURCE C:/Users/Administrator/Downloads/sakila-db/sakila-data.sql;             >> C:\Users\Administrator\Downloads\TempImportSakila.sql
ECHO GRANT SUPER ON *.* TO compose;                                                 >> C:\Users\Administrator\Downloads\TempImportSakila.sql
ECHO GRANT ALL ON *.* TO compose;                                                   >> C:\Users\Administrator\Downloads\TempImportSakila.sql

ECHO Downloading sakila files...
CD "c:\Users\Administrator\Downloads"
POWERSHELL c:\Users\Administrator\Downloads\TempDownloadSakila.ps1 > C:\Users\Administrator\Downloads\DownloadSakila.log

ECHO Unpacking sakila files...
CD "c:\Users\Administrator\Downloads"
POWERSHELL c:\Users\Administrator\Downloads\TempUnzipSakila.ps1> C:\Users\Administrator\Downloads\UnzipSakila.log

ECHO Creating MySQL sakila dababase...
CD "C:\Program Files\MySQL\MySQL Server 5.7\bin"
mysql -u root < C:\Users\Administrator\Downloads\TempImportSakila.sql > C:\Users\Administrator\Downloads\ImportSakila.log
GOTO :CLEANFILES

:ENDBYUSER
ECHO Sakila will not be imported !
GOTO :END

:CLEANFILES
ECHO Deleting tempfiles...
DEL /s /q C:\Users\Administrator\Downloads\Temp*.ps1  >nul 2>&1
DEL /s /q C:\Users\Administrator\Downloads\Temp*.sql  >nul 2>&1
DEL /s /q C:\Users\Administrator\Downloads\sakila-db.zip  >nul 2>&1
DEL /s /q C:\Users\Administrator\Downloads\sakila-db >nul 2>&1
RMDIR /s /q C:\Users\Administrator\Downloads\sakila-db >nul 2>&1
GOTO :END

:END 
ECHO ***************************************
ECHO Process terminated !
PAUSE

ENDLOCAL
