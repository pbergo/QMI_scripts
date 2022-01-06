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

ECHO Creating tempfile DownloadFiles...
ECHO $url = "https://da3hntz84uekx.cloudfront.net/QlikReplicate/2021.11/2/_MSI/QlikReplicate_2021.11.0.165_X64.zip"                 > C:\Users\Administrator\Downloads\TempDownloadQDI.ps1
ECHO $output = "C:\Users\Administrator\Downloads\QlikReplicate.zip"                                                                 >> C:\Users\Administrator\Downloads\TempDownloadQDI.ps1
ECHO $start_time = Get-Date                                                                                                         >> C:\Users\Administrator\Downloads\TempDownloadQDI.ps1
ECHO Import-Module BitsTransfer                                                                                                     >> C:\Users\Administrator\Downloads\TempDownloadQDI.ps1
ECHO Start-BitsTransfer -Source $url -Destination $output                                                                           >> C:\Users\Administrator\Downloads\TempDownloadQDI.ps1
ECHO $url = "https://da3hntz84uekx.cloudfront.net/QlikEnterpriseManager/2021.11/2/_MSI/QlikEnterpriseManager_2021.11.0.198_X64.zip" >> C:\Users\Administrator\Downloads\TempDownloadQDI.ps1
ECHO $output = "C:\Users\Administrator\Downloads\QlikEM.zip"                                                                        >> C:\Users\Administrator\Downloads\TempDownloadQDI.ps1
ECHO $start_time = Get-Date                                                                                                         >> C:\Users\Administrator\Downloads\TempDownloadQDI.ps1
ECHO Import-Module BitsTransfer                                                                                                     >> C:\Users\Administrator\Downloads\TempDownloadQDI.ps1
ECHO Start-BitsTransfer -Source $url -Destination $output                                                                           >> C:\Users\Administrator\Downloads\TempDownloadQDI.ps1
ECHO $url = "https://da3hntz84uekx.cloudfront.net/QlikCompose/2021.8.0/6/_MSI/Qlik_Compose_2021.8.0.336.zip"                        >> C:\Users\Administrator\Downloads\TempDownloadQDI.ps1
ECHO $output = "C:\Users\Administrator\Downloads\QlikCompose.zip"                                                                   >> C:\Users\Administrator\Downloads\TempDownloadQDI.ps1
ECHO $start_time = Get-Date                                                                                                         >> C:\Users\Administrator\Downloads\TempDownloadQDI.ps1
ECHO Import-Module BitsTransfer                                                                                                     >> C:\Users\Administrator\Downloads\TempDownloadQDI.ps1
ECHO Start-BitsTransfer -Source $url -Destination $output                                                                           >> C:\Users\Administrator\Downloads\TempDownloadQDI.ps1

ECHO Creating tempfile UnzipQDI...
ECHO $shell = New-Object -ComObject Shell.Application                                       > C:\Users\Administrator\Downloads\TempUnzipQDI.ps1
ECHO $zipFile = $shell.NameSpace("C:\Users\Administrator\Downloads\QlikReplicate.zip")      >> C:\Users\Administrator\Downloads\TempUnzipQDI.ps1
ECHO $destinationFolder = $shell.NameSpace("C:\Users\Administrator\Downloads")              >> C:\Users\Administrator\Downloads\TempUnzipQDI.ps1
ECHO $destinationFolder.CopyHere($zipFile.Items())                                          >> C:\Users\Administrator\Downloads\TempUnzipQDI.ps1
ECHO $shell = New-Object -ComObject Shell.Application                                       >> C:\Users\Administrator\Downloads\TempUnzipQDI.ps1
ECHO $zipFile = $shell.NameSpace("C:\Users\Administrator\Downloads\QlikEM.zip")             >> C:\Users\Administrator\Downloads\TempUnzipQDI.ps1
ECHO $destinationFolder = $shell.NameSpace("C:\Users\Administrator\Downloads")              >> C:\Users\Administrator\Downloads\TempUnzipQDI.ps1
ECHO $destinationFolder.CopyHere($zipFile.Items())                                          >> C:\Users\Administrator\Downloads\TempUnzipQDI.ps1
ECHO $shell = New-Object -ComObject Shell.Application                                       >> C:\Users\Administrator\Downloads\TempUnzipQDI.ps1
ECHO $zipFile = $shell.NameSpace("C:\Users\Administrator\Downloads\QlikCompose.zip")        >> C:\Users\Administrator\Downloads\TempUnzipQDI.ps1
ECHO $destinationFolder = $shell.NameSpace("C:\Users\Administrator\Downloads")              >> C:\Users\Administrator\Downloads\TempUnzipQDI.ps1
ECHO $destinationFolder.CopyHere($zipFile.Items())                                          >> C:\Users\Administrator\Downloads\TempUnzipQDI.ps1

ECHO Downloading QDI files...
CD "c:\Users\Administrator\Downloads"
POWERSHELL c:\Users\Administrator\Downloads\TempDownloadQDI.ps1 > C:\Users\Administrator\Downloads\DownloadQDI.log

ECHO Unpacking QDI files...
CD "c:\Users\Administrator\Downloads"
POWERSHELL c:\Users\Administrator\Downloads\TempUnzipQDI.ps1> C:\Users\Administrator\Downloads\UnzipQDI.log

GOTO :CLEANFILES

:ENDBYUSER
ECHO QDI will not be updated !
GOTO :END

:CLEANFILES
ECHO Deleting tempfiles...
DEL /s /q C:\Users\Administrator\Downloads\Temp*.ps1  >nul 2>&1
DEL /s /q C:\Users\Administrator\Downloads\Temp*.sql  >nul 2>&1
DEL /s /q C:\Users\Administrator\Downloads\Qlik*.zip  >nul 2>&1
RMDIR /s /q C:\Users\Administrator\Downloads\QlikReplicate >nul 2>&1
RMDIR /s /q C:\Users\Administrator\Downloads\QlikEM >nul 2>&1
RMDIR /s /q C:\Users\Administrator\Downloads\QlikCompose >nul 2>&1
GOTO :END

:END 
ECHO ***************************************
ECHO Process terminated !
PAUSE

ENDLOCAL
