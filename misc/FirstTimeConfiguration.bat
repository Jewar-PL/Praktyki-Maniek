@echo off
setlocal 

cd %~dp0%
SET "WorkingDir=%CD%"
cd ..
SET "RootDir=%CD%"
echo Working directory: %WorkingDir%
echo Root directory: %RootDir%

:install_services
    echo .
    echo Installing services watchdogs
    echo .

    SET "NSSMPath=%WorkingDir%\nssm-2.24\win64\nssm.exe"

    SET "ApacheDirectory=C:\xampp\apache\bin\"
    SET "ApacheExecutable=httpd.exe"
    SET "ApacheExecutablePath=%ApacheDirectory%%ApacheExecutable%"
    SET "ApacheWatchdog=ApacheWatchdog"

    SET "MysqlDirectory=C:\xampp\mysql\bin\"
    SET "MysqlExecutable=mysqld.exe"
    SET "MysqlExecutablePath=%MysqlDirectory%%MysqlExecutable%"
    SET "MysqlWatchdog=MysqlWatchdog"

    if exist %NSSMPath% (
        echo Installing wathchdog for Apache service
        if exist %ApacheExecutablePath% (
            @REM check for watchdog existance
            @REM sc exit code is saved to errorlevel
            sc.exe query "%ApacheWatchdog%" >nul 2>&1
            if %errorlevel%==0 (
                echo Removing old watchdog for Apache
                call %NSSMPath% stop %ApacheWatchdog%
                call %NSSMPath% remove %ApacheWatchdog% confirm
            )

            call %NSSMPath% install %ApacheWatchdog% %ApacheExecutablePath%
            call %NSSMPath% set %ApacheWatchdog% AppDirectory %ApacheDirectory%
            call %NSSMPath% set %ApacheWatchdog% Start SERVICE_AUTO_START
            call %NSSMPath% set %ApacheWatchdog% AppNoConsole 1
            call %NSSMPath% set %ApacheWatchdog% AppExit Default Restart
            call %NSSMPath% set %ApacheWatchdog% AppRestartDelay 1500
        ) else (
            echo No Apache found! 'httpd.exe' Searched in %ApacheDirectory%%ApacheExecutable%
            goto failure
        )

        echo Installing wathchdog for Mysql service
        if exist %MysqlExecutablePath% (
            @REM check for watchdog existance
            @REM sc exit code is saved to errorlevel
            sc.exe query "%MysqlWatchdog%" >nul 2>&1
            if %errorlevel%==0 (
                echo Removing old watchdog for Mysql
                call %NSSMPath% stop %MysqlWatchdog%
                call %NSSMPath% remove %MysqlWatchdog% confirm
            )

            call %NSSMPath% install %MysqlWatchdog% %MysqlExecutablePath%
            call %NSSMPath% set %MysqlWatchdog% AppDirectory %MysqlDirectory%
            call %NSSMPath% set %MysqlWatchdog% Start SERVICE_AUTO_START
            call %NSSMPath% set %MysqlWatchdog% AppNoConsole 1
            call %NSSMPath% set %MysqlWatchdog% AppExit Default Restart
            call %NSSMPath% set %MysqlWatchdog% AppRestartDelay 1500
        ) else (
            echo No Mysql found! Looked for %MysqlDirectory%%MysqlExecutable%
            goto failure
        )
    ) else (
        echo No found %NSSMPath%
        goto failure
    )
@rem :install_services

:set_scheduler
    echo .
    echo Setting up scheduler tasks
    echo .

    @REM Choose one of this two:
    SET "LaunchSequencePath=%WorkingDir%\LaunchSequenceElectron\LaunchSequence.bat"
    @REM SET "LaunchSequencePath=%WorkingDir%\LaunchSequenceBat\LaunchSequence.bat"

    SET "ShutdownSequencePath=%WorkingDir%\AbsouteShutdown.bat"

    echo Checking for ManiekLaunch task
    schtasks /query /tn "ManiekLaunch" >nul 2>&1
    if %errorlevel%==0 (
        echo Removing old ManiekLaunch task
        schtasks /delete /tn "ManiekLaunch" /f
    )

    echo Checking for ManiekShutdown task
    schtasks /query /tn "ManiekShutdown" >nul 2>&1
    if %errorlevel%==0 (
        echo Removing old ManiekShutdown task
        schtasks /delete /tn "ManiekShutdown" /f
    )

    echo Creating ManiekLaunch and ManiekShutdown tasks
    schtasks /create /sc onlogon /tn "ManiekLaunch" /tr "%LaunchSequencePath%"
    schtasks /create /tn "ManiekShutdown" /tr "%ShutdownSequencePath%" /sc daily /st 19:00
@rem :set_scheduler

:check_for_autohotkey
    echo .
    echo Checking for AutoHotkey
    echo .

    SET "AutoHotkeyPath=C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"

    if exist "%AutoHotkeyPath%" (
        echo AutoHotkey found
    ) else (
        echo AutoHotkey not found
        echo Download and install AutoHotkey from https://www.autohotkey.com/
        goto failure
    )
@rem :check_for_autohotkey

:check_for_dualmonitortools
    echo .
    echo Checking for DualMonitorTools
    echo .

    SET "DualMonitorToolsPath=C:\Program Files (x86)\Dual Monitor Tools\DMT.exe"

    if exist "%DualMonitorToolsPath%" (
        echo DualMonitorTools found
    ) else (
        echo DualMonitorTools not found
        echo Download and configure DualMonitorTools as stated in README.md from https://dualmonitortool.sourceforge.net/download.html
        goto failure
    )
@rem :check_for_dualmonitortools

:copy_files_to_xampp_htdocs
    echo .
    echo Copying files to xampp\htdocs
    echo .

    SET "XamppPath=C:\xampp\htdocs"
    SET "ManiekDirPath=%XamppPath%\maniek\Praktyki-Maniek"
    SET "CopyFlagPath=%RootDir%\COPY"

    if exist "%XamppPath%" (
        echo %XamppPath% found
        if exist "%ManiekDirPath%" (
            echo %ManiekDirPath% found
        ) else (
            echo Praktyki-Maniek not found
            echo Creating %ManiekDirPath%
            mkdir "%ManiekDirPath%"
        )

        @rem TODO: add checking if files are already copied

        if not exist %CopyFlagPath% (
            echo Running from wrong directory!
            echo File %CopyFlagPath% not found
            goto failure
        )


        echo Copying files to %ManiekDirPath%
        xcopy "%WorkingDir%\.." "%ManiekDirPath%" /h /i /c /k /e /r /y
    ) else (
        echo Xampp\htdocs not found
        echo Download and install Xampp from https://www.apachefriends.org/download.html
        goto failure
    )
:copy_files_to_xampp_htdocs-end
@rem :copy_files_to_xampp_htdocs

:success
    echo .
    echo Success, Configuration finished successfully
    pause >nul
    endlocal
    exit
@rem :success

:failure
    echo .
    echo Failure, Configuration failed
    pause >nul
    endlocal
    exit
@rem :failure