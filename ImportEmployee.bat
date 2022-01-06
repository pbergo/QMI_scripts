@ECHO OFF
SETLOCAL
SET confirm=N
ECHO ***************************************
ECHO **********    WARNING!!!!!  ***********
ECHO This script will create MySQL employee 
ECHO database. It will drop and recreate the 
ECHO employee schema and data set.
:PROMPT
SET /P confirm=Are you sure (Y/[N])?
IF /I "%confirm%" NEQ "Y" GOTO ENDBYUSER

ECHO Creating tempfile DownloadEmployee...
ECHO $url = "https://github.com/datacharmer/test_db/archive/refs/heads/master.zip"       > C:\Users\Administrator\Downloads\TempDownloadEmployee.ps1
ECHO $output = "C:\Users\Administrator\Downloads\test_db-master.zip"                     >> C:\Users\Administrator\Downloads\TempDownloadEmployee.ps1
ECHO $start_time = Get-Date                                                              >> C:\Users\Administrator\Downloads\TempDownloadEmployee.ps1
ECHO Import-Module BitsTransfer                                                          >> C:\Users\Administrator\Downloads\TempDownloadEmployee.ps1
ECHO Start-BitsTransfer -Source $url -Destination $output                                >> C:\Users\Administrator\Downloads\TempDownloadEmployee.ps1

ECHO Creating tempfile UnzipEmployee...
ECHO $shell = New-Object -ComObject Shell.Application                                    > C:\Users\Administrator\Downloads\TempUnzipEmployee.ps1
ECHO $zipFile = $shell.NameSpace("C:\Users\Administrator\Downloads\test_db-master.zip")  >> C:\Users\Administrator\Downloads\TempUnzipEmployee.ps1
ECHO $destinationFolder = $shell.NameSpace("C:\Users\Administrator\Downloads")           >> C:\Users\Administrator\Downloads\TempUnzipEmployee.ps1
ECHO $destinationFolder.CopyHere($zipFile.Items())                                       >> C:\Users\Administrator\Downloads\TempUnzipEmployee.ps1

ECHO Adding grant security to standard ImportEmployee...
ECHO GRANT SUPER ON *.* TO compose;                                                      >> C:\Users\Administrator\Downloads\test_db-master\employees.sql
ECHO GRANT ALL ON *.* TO compose;                                                        >> C:\Users\Administrator\Downloads\test_db-master\employees.sql

ECHO Downloading Employee files...
CD "c:\Users\Administrator\Downloads"
POWERSHELL c:\Users\Administrator\Downloads\TempDownloadEmployee.ps1 > C:\Users\Administrator\Downloads\DownloadEmployee.log

ECHO Unpacking Employee files...
CD "c:\Users\Administrator\Downloads"
POWERSHELL c:\Users\Administrator\Downloads\TempUnzipEmployee.ps1> C:\Users\Administrator\Downloads\UnzipEmployee.log

ECHO Creating MySQL Employee dababase...
CD "C:\Users\Administrator\Downloads\test_db-master"
"C:\Program Files\MySQL\MySQL Server 5.7\bin\mysql" -u root < C:\Users\Administrator\Downloads\test_db-master\employees.sql > C:\Users\Administrator\Downloads\ImportEmployee.log
GOTO :CLEANFILES

:ENDBYUSER
ECHO Employee will not be imported !
GOTO :END

:CLEANFILES
ECHO Deleting tempfiles...
DEL /s /q C:\Users\Administrator\Downloads\Temp*.ps1  >nul 2>&1
DEL /s /q C:\Users\Administrator\Downloads\Temp*.sql  >nul 2>&1
DEL /s /q C:\Users\Administrator\Downloads\test_db-master.zip  >nul 2>&1
DEL /s /q C:\Users\Administrator\Downloads\test_db-master >nul 2>&1
RMDIR /s /q C:\Users\Administrator\Downloads\test_db-master >nul 2>&1
GOTO :END

:END 
ECHO ***************************************
ECHO Process terminated !
PAUSE

ENDLOCAL
