@ECHO OFF
REM *********************************************************
REM * Copyright: Qlik (c) 2023                              *
REM * Author: Pedro Bergo - pedro.bergo@qlik.com            *
REM * Purpose: Install QDI version                          *
REM * This file intend to move data folder to new server    *
REM * both installed on EC2                                 *
REM * Contains a section for using different DOMAIN servers *
REM *********************************************************

SETLOCAL

SET volume=D
SET dvolume=%volume%:\Attunity\
SET datafolder=%dvolume%data
SET userfile=%dvolume%users.json

SET adminuser=repadmin
SET adminpwd=Qlik1234!
SET mukpwd=QlikReplicateNovember2022MaskterKey
SET mkpwd=QlikReplicateNovember2022MaskterUserKey

IF EXIST "%datafolder%" (
    ECHO Data Folder detected, set default installation to Node 2 !
    ECHO Before to install Replicate, you may need to review the users file !
    SET node=2
) else (
    SET node=1
)

ECHO ************************************************
ECHO **********      WARNING!!!!!         ***********
ECHO This script will install QDI files:
ECHO - Qlik Replicate - 2022.11 SR2
ECHO .
:PROMPT
SET /P node=Which node will be installed (1/2) - Default "%node%" ?
ECHO Installing node %node%...

ECHO Cleaning log files...
CD "%homepath%\Downloads"
DEL /S /Q *.LOG

ECHO Checking Utils...
CD "%homepath%\Downloads"
IF NOT EXIST %homepath%\Downloads\QLIKWGET.EXE GOTO :INSTALLUTILS
GOTO :INSTALLUTILS

:INSTALLUTILS
ECHO Creating tempfile DownloadWget...
ECHO $url = "https://github.com/pbergo/QMI_scripts/raw/master/Utils/wget.exe"   > %homepath%\Downloads\TempDownloadUtils.ps1
ECHO $output = "C:\Users\Administrator\Downloads\Qlikwget.exe"                  >> %homepath%\Downloads\TempDownloadUtils.ps1
ECHO $start_time = Get-Date                                                     >> %homepath%\Downloads\TempDownloadUtils.ps1
ECHO Import-Module BitsTransfer                                                 >> %homepath%\Downloads\TempDownloadUtils.ps1
ECHO Start-BitsTransfer -Source $url -Destination $output                       >> %homepath%\Downloads\TempDownloadUtils.ps1

ECHO Downloading Util files...
CD "%homepath%\Downloads"
POWERSHELL %homepath%\Downloads\TempDownloadUtils.ps1 > %homepath%\Downloads\InstallQDI.log
IF NOT EXIST %homepath%\Downloads\QlikUNZIP.EXE %homepath%\Downloads\QlikWGET -O %homepath%\Downloads\QlikUNZIP.EXE https://github.com/pbergo/QMI_scripts/raw/master/Utils/unzip.exe --append-output=%homepath%\Downloads\InstallQDI.log
GOTO :INSTVOL

:INSTVOL
ECHO Checking %volume% volume...
IF /I "%node%" == "1" (
    ECHO Enabling volume %volume%...
    ECHO select disk 1 				            			>  %homepath%\Downloads\TempEnableVolumeD.txt
    ECHO attributes disk clear readonly 	    					>> %homepath%\Downloads\TempEnableVolumeD.txt
    ECHO online disk noerr				        			>> %homepath%\Downloads\TempEnableVolumeD.txt
    ECHO convert mbr 				            			>> %homepath%\Downloads\TempEnableVolumeD.txt
    ECHO create partition primary 			    				>> %homepath%\Downloads\TempEnableVolumeD.txt
    ECHO format quick fs=ntfs label="QLIKREP" 					>> %homepath%\Downloads\TempEnableVolumeD.txt
    ECHO assign letter="D"				        			>> %homepath%\Downloads\TempEnableVolumeD.txt

    DISKPART /s %homepath%\Downloads\TempEnableVolumeD.txt  			>> %homepath%\Downloads\InstallQDI.log
    GOTO :CHECKVOL
) ELSE (
    ECHO Enabling volume %volume%......
    ECHO select disk 1 				            			>  %homepath%\Downloads\TempEnableVolumeD.txt
    ECHO attributes disk clear readonly 	    					>> %homepath%\Downloads\TempEnableVolumeD.txt
    ECHO online disk noerr				        			>> %homepath%\Downloads\TempEnableVolumeD.txt

    DISKPART /s %homepath%\Downloads\TempEnableVolumeD.txt  			>> %homepath%\Downloads\InstallQDI.log
    GOTO :CHECKVOL    
)

:CHECKVOL
IF EXIST "%dvolume%" (
    ECHO Volume %volume% is enabled, continuing installation...
    GOTO :INSTUSERS
) ELSE (
    ECHO Volume %volume% is not enabled, finishing installation...
    GOTO :END
)

:INSTUSERS
ECHO Adding a Local User repadmin...
NET USER %adminuser% %adminpwd% /add                                                    >> %homepath%\Downloads\InstallQDI.log
ECHO Adding a Local Group QlikReplicateAdmins...
NET LOCALGROUP QlikReplicateAdmins /Comment:"Qlik Replicate Administrators" /add    >> %homepath%\Downloads\InstallQDI.log
ECHO Adding local user %adminuser% to Local Group QlikReplicateAdmins...
NET LOCALGROUP QlikReplicateAdmins %adminuser% /add                                    >> %homepath%\Downloads\InstallQDI.log
GOTO :INSTALLQDI

:INSTALLQDI
ECHO Downloading Qlik Replicate...
IF EXIST %homepath%\Downloads\QlikReplicate.zip DEL /S /Q %homepath%\Downloads\QlikReplicate.zip
%homepath%\Downloads\QlikWGET -O %homepath%\Downloads\QlikReplicate.zip https://github.com/qlik-download/replicate/releases/download/v2022.11.1/QlikReplicate_2022.11.0.394_X64.zip --append-output=%homepath%\Downloads\InstallQDI.log

ECHO Unpacking Qlik Replicate...
%homepath%\Downloads\QlikUNZIP -o %homepath%\Downloads\QlikReplicate.zip >> %homepath%\Downloads\InstallQDI.log

ECHO Generating Response file from Qlik Replicate...
ECHO [{9C614355-28A0-4C2A-98DF-DB9FD674826F}-DlgOrder]                       > %homepath%\Downloads\QlikRepResponseFile.iss
ECHO Dlg0={9C614355-28A0-4C2A-98DF-DB9FD674826F}-SdWelcome-0                 >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO Count=7                                                                 >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO Dlg1={9C614355-28A0-4C2A-98DF-DB9FD674826F}-SdLicenseAgreement-0        >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO Dlg2={9C614355-28A0-4C2A-98DF-DB9FD674826F}-SdAskDestPath-0             >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO Dlg3={9C614355-28A0-4C2A-98DF-DB9FD674826F}-SdAskDestPath-1             >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO Dlg4={9C614355-28A0-4C2A-98DF-DB9FD674826F}-AskOptions-0                >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO Dlg5={9C614355-28A0-4C2A-98DF-DB9FD674826F}-SdStartCopy-0               >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO Dlg6={9C614355-28A0-4C2A-98DF-DB9FD674826F}-SdFinish-0                  >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO [{9C614355-28A0-4C2A-98DF-DB9FD674826F}-SdWelcome-0]                    >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO Result=1                                                                >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO [{9C614355-28A0-4C2A-98DF-DB9FD674826F}-SdLicenseAgreement-0]           >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO Result=1                                                                >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO [{9C614355-28A0-4C2A-98DF-DB9FD674826F}-SdAskDestPath-0]                >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO szDir=C:\Program Files\Attunity\Replicate                               >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO Result=1                                                                >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO [{9C614355-28A0-4C2A-98DF-DB9FD674826F}-SdAskDestPath-1]                >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO szDir=%datafolder%                                                      >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO Result=1                                                                >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO [{9C614355-28A0-4C2A-98DF-DB9FD674826F}-AskOptions-0]                   >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO Result=1                                                                >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO Sel-0=1                                                                 >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO Sel-1=0                                                                 >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO [{9C614355-28A0-4C2A-98DF-DB9FD674826F}-SdStartCopy-0]                  >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO Result=1                                                                >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO [{9C614355-28A0-4C2A-98DF-DB9FD674826F}-SdFinish-0]                     >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO Result=1                                                                >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO bOpt1=0                                                                 >> %homepath%\Downloads\QlikRepResponseFile.iss
ECHO bOpt2=0                                                                 >> %homepath%\Downloads\QlikRepResponseFile.iss

REM For node 2, copy datafolder and create new one to be used by default installation
IF /I "%node%" == "1" (
    ECHO Installing as default...
) else (
    ECHO Renaming data folder to new name name to avoid installation conflit...
    MOVE %datafolder% %datafolder%_srv1
)

ECHO Installing Qlik Replicate...
%homepath%\Downloads\QlikReplicate_2022.11.0.394_X64.exe /s -f1%homepath%\Downloads\QlikRepResponseFile.iss -f2%homepath%\Downloads\InstallQDI.log
GOTO :REPCONF

:REPCONF
REM If node 1 then export users and set Masterkey, else import users and confirm Userkey
IF /I "%node%" == "1" (
    ECHO Setting Masterkey and User Masterkey...
    "C:\Program Files\Attunity\Replicate\bin\repctl.exe" -d %datafolder% setmasterkey master_key=QlikReplicateNov22MasterKey2023 master_key_scope=1    >> %homepath%\Downloads\InstallQDI.log
    "C:\Program Files\Attunity\Replicate\bin\repUiCtl.exe" -d %datafolder% masterukey set -p QlikReplicateNov22MasterUserKey2023    >> %homepath%\Downloads\InstallQDI.log

    ECHO Restarting Replicate Services...
    "C:\Program Files\Attunity\Replicate\bin\stopserver.cmd"  >> %homepath%\Downloads\InstallQDI.log
    timeout 20 > nul
    "C:\Program Files\Attunity\Replicate\bin\startserver.cmd" >> %homepath%\Downloads\InstallQDI.log
    timeout 20 > nul

    ECHO Exporting users...
    "C:\Program Files\Attunity\Replicate\bin\repuictl.exe" -d %datafolder% repository export_acl -f %userfile% >> %homepath%\Downloads\InstallQDI.log

    GOTO :CLEANFILES
) else (
    ECHO Setting User Masterkey...
    "C:\Program Files\Attunity\Replicate\bin\repUiCtl.exe" -d %datafolder% masterukey set -p QlikReplicateNov22MasterUserKey2023    >> %homepath%\Downloads\InstallQDI.log

    ECHO Stopping Replicate Services...
    "C:\Program Files\Attunity\Replicate\bin\stopserver.cmd"  >> %homepath%\Downloads\InstallQDI.log
    timeout 20 > nul

    ECHO Restore data folder to default name...
    MOVE %datafolder% %datafolder%_srv2             >> %homepath%\Downloads\InstallQDI.log
    MOVE %datafolder%_srv1 %datafolder%              >> %homepath%\Downloads\InstallQDI.log
    
    REM ****************************************
    REM Mandatory for diferent DOMAIN
    REM Copy the old muk.dat to be used on new server
    COPY %datafolder%_srv2\muk.dat %datafolder%     >> %homepath%\Downloads\InstallQDI.log

    ECHO Please change the user.json file with current server file name then press ENTER
    PAUSE
    ECHO Importing users...
    "C:\Program Files\Attunity\Replicate\bin\repuictl.exe" -d %datafolder% repository import_acl -f %userfile%  >> %homepath%\Downloads\InstallQDI.log
    REM END Mandatory for diferent DOMAIN
    REM ****************************************

    ECHO Delete ServiceConfiguration file to use serve new name
    DEL %datafolder%\ServiceConfiguration.xml >> %homepath%\Downloads\InstallQDI.log

    ECHO Starting Replicate Services...
    "C:\Program Files\Attunity\Replicate\bin\startserver.cmd" >> %homepath%\Downloads\InstallQDI.log
    timeout 20 > nul

    GOTO :CLEANFILES
)

:ENDBYUSER
ECHO QDI will not be installed !
GOTO :END

:CLEANFILES
ECHO Deleting tempfiles...
DEL /s /q %homepath%\Downloads\Temp*.ps1  >nul 2>&1
DEL /s /q %homepath%\Downloads\Temp*.iss  >nul 2>&1
DEL /s /q %homepath%\Downloads\Temp*.txt  >nul 2>&1
DEL /s /q %homepath%\Downloads\Temp*.sql  >nul 2>&1
DEL /s /q %homepath%\Downloads\Qlik*.zip  >nul 2>&1
DEL /s /q %homepath%\Downloads\Qlik*.exe  >nul 2>&1
DEL /s /q %homepath%\Downloads\.wget-hsts  >nul 2>&1
GOTO :END

:END 
ECHO Installing QDI Process terminated !
ECHO You will need to update Qlik licensing !
ECHO ************************************************
PAUSE

ENDLOCAL
