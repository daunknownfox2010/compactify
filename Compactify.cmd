@ECHO OFF


REM Set up some variables here
SET BAT_CWD=
SET BAT_USER_CHOICE=


REM Cancel out the script if we don't find compact.exe
IF NOT EXIST "%SystemRoot%\System32\compact.exe" (
    COLOR 04
    ECHO Warning: COMPACT was not found in the system root directory.
    ECHO Make sure you're using a full Windows 10 install.
    TIMEOUT /T -1 2>&1 >NUL
    GOTO EOF
)

REM Change the current working directory to where the script was executed
CD /D "%~dp0"
FOR /F "delims=" %%I IN ('CD') DO SET BAT_CWD=%%I

REM Change the console colors
COLOR 1F

REM Go to the main menu
GOTO MENU_MAIN


REM Function to display the header
:FUNC_DISPLAY_HEADER
ECHO +----------------------------+
ECHO ^|        Compactify          ^|
ECHO ^|      by 'Jai the Fox'      ^|
ECHO ^|                            ^|
ECHO ^| Worry no more about space! ^|
ECHO +----------------------------+
ECHO.
EXIT /B

REM Function to call COMPACT
:FUNC_COMPACT
SET COMPACT_FILENAME=%~2
SET COMPACT_COMPRESSION=%~3
SETLOCAL ENABLEDELAYEDEXPANSION
COMPACT %~1
ENDLOCAL
SET COMPACT_FILENAME=
SET COMPACT_COMPRESSION=
EXIT /B


REM Displays the compress options menu
:MENU_COMPRESSOPTS
SET COMPACT_PARAMETERS="/C /A /I /Q /EXE:!COMPACT_COMPRESSION! !COMPACT_FILENAME!"
CLS
CALL :FUNC_DISPLAY_HEADER
ECHO Do you want COMPACT to recursively query all subdirectories?
SET COMPACT_SUBDIRECTORIES=
SET BAT_USER_CHOICE=n
SET /P BAT_USER_CHOICE="Yes / No (Y/N)? "
IF /I "%BAT_USER_CHOICE%"=="y" SET COMPACT_SUBDIRECTORIES=1
ECHO.
ECHO Do you want COMPACT to force compression ^& recompress compressed files?
SET COMPACT_FORCE=
SET BAT_USER_CHOICE=n
SET /P BAT_USER_CHOICE="Yes / No (Y/N)? "
IF /I "%BAT_USER_CHOICE%"=="y" SET COMPACT_FORCE=1
IF DEFINED COMPACT_SUBDIRECTORIES (
    IF DEFINED COMPACT_FORCE (
        SET COMPACT_PARAMETERS="/C /S /A /I /F /Q /EXE:!COMPACT_COMPRESSION! !COMPACT_FILENAME!"
        SET COMPACT_SUBDIRECTORIES=
        SET COMPACT_FORCE=
    ) ELSE (
        SET COMPACT_PARAMETERS="/C /S /A /I /Q /EXE:!COMPACT_COMPRESSION! !COMPACT_FILENAME!"
        SET COMPACT_SUBDIRECTORIES=
    )
)
IF DEFINED COMPACT_FORCE (
    SET COMPACT_PARAMETERS="/C /A /I /F /Q /EXE:!COMPACT_COMPRESSION! !COMPACT_FILENAME!"
    SET COMPACT_FORCE=
)
ECHO.
ECHO What compression do you want COMPACT to use?
ECHO Reminder! [LZX] has heavy overhead, it's recommended you use [XPRESS16K] instead.
SET COMPACT_COMPRESSION="XPRESS4K"
SET BAT_USER_CHOICE=xpress4k
SET /P BAT_USER_CHOICE="Compression (XPRESS4K/XPRESS8K/XPRESS16K/LZX) [XPRESS4K]: "
IF /I "%BAT_USER_CHOICE%"=="xpress8k" SET COMPACT_COMPRESSION="XPRESS8K"
IF /I "%BAT_USER_CHOICE%"=="xpress16k" SET COMPACT_COMPRESSION="XPRESS16K"
IF /I "%BAT_USER_CHOICE%"=="lzx" SET COMPACT_COMPRESSION="LZX"
ECHO.
SET BAT_USER_CHOICE=
SET /P BAT_USER_CHOICE="Optionally enter a file/folder name or pattern (multiple allowed): "
ECHO.
ECHO Compressing using COMPACT...
ECHO ============================
ECHO.
ECHO.
CALL :FUNC_COMPACT %COMPACT_PARAMETERS% "%BAT_USER_CHOICE%" %COMPACT_COMPRESSION%
SET COMPACT_PARAMETERS=
SET COMPACT_COMPRESSION=
ECHO.
PAUSE
GOTO MENU_MAIN

REM Displays the compress menu
:MENU_COMPRESS
CLS
CALL :FUNC_DISPLAY_HEADER
ECHO You're about to compress the current directory, are you sure?
ECHO Current working directory: '%BAT_CWD%'
ECHO.
ECHO.
SET BAT_USER_CHOICE=n
SET /P BAT_USER_CHOICE="Compress (Y/N)? "
IF /I "%BAT_USER_CHOICE%"=="y" GOTO MENU_COMPRESSOPTS
IF /I "%BAT_USER_CHOICE%"=="n" GOTO MENU_MAIN
ECHO %BAT_USER_CHOICE%
GOTO MENU_COMPRESS

REM Displays the uncompress options menu
:MENU_UNCOMPRESSOPTS
SET COMPACT_PARAMETERS="/U /A /I /Q /EXE !COMPACT_FILENAME!"
CLS
CALL :FUNC_DISPLAY_HEADER
ECHO Do you want COMPACT to recursively query all subdirectories?
SET COMPACT_SUBDIRECTORIES=
SET BAT_USER_CHOICE=n
SET /P BAT_USER_CHOICE="Yes / No (Y/N)? "
IF /I "%BAT_USER_CHOICE%"=="y" SET COMPACT_SUBDIRECTORIES=1
IF DEFINED COMPACT_SUBDIRECTORIES (
    SET COMPACT_PARAMETERS="/U /S /A /I /Q /EXE !COMPACT_FILENAME!"
    SET COMPACT_SUBDIRECTORIES=
)
ECHO.
SET BAT_USER_CHOICE=
SET /P BAT_USER_CHOICE="Optionally enter a file/folder name or pattern (multiple allowed): "
ECHO.
ECHO Uncompressing using COMPACT...
ECHO ==============================
ECHO.
ECHO.
CALL :FUNC_COMPACT %COMPACT_PARAMETERS% "%BAT_USER_CHOICE%"
SET COMPACT_PARAMETERS=
ECHO.
PAUSE
GOTO MENU_MAIN

REM Displays the uncompress menu
:MENU_UNCOMPRESS
CLS
CALL :FUNC_DISPLAY_HEADER
ECHO You're about to uncompress the current directory, are you sure?
ECHO Current working directory: '%BAT_CWD%'
ECHO.
ECHO.
SET BAT_USER_CHOICE=n
SET /P BAT_USER_CHOICE="Uncompress (Y/N)? "
IF /I "%BAT_USER_CHOICE%"=="y" GOTO MENU_UNCOMPRESSOPTS
IF /I "%BAT_USER_CHOICE%"=="n" GOTO MENU_MAIN
ECHO %BAT_USER_CHOICE%
GOTO MENU_UNCOMPRESS

REM Displays the query menu
:MENU_QUERY
CLS
CALL :FUNC_DISPLAY_HEADER
ECHO Querying COMPACT information...
ECHO ===============================
ECHO.
ECHO.
CALL :FUNC_COMPACT "/S /A /Q"
PAUSE
GOTO MENU_MAIN

REM Displays the CD menu
:MENU_CD
CLS
CALL :FUNC_DISPLAY_HEADER
ECHO Current working directory: '%BAT_CWD%'
ECHO If you wish to change this directory, type the directory below.
ECHO Alternatively, leave it blank to go back without changing it.
ECHO.
ECHO.
SET BAT_USER_CHOICE=
SET /P BAT_USER_CHOICE="New directory: "
IF NOT DEFINED BAT_USER_CHOICE GOTO MENU_MAIN
IF EXIST "%BAT_USER_CHOICE%" (
    CD /D "%BAT_USER_CHOICE%" 2>&1 >NUL
    IF %ERRORLEVEL% EQU 0 (
        FOR /F "delims=" %%I IN ('CD') DO SET BAT_CWD=%%I
        ECHO Directory changed successfully!
        TIMEOUT /T 3 /NOBREAK 2>&1 >NUL
        GOTO MENU_MAIN
    ) ELSE (
        ECHO Failed to change directory.
        TIMEOUT /T 3 /NOBREAK 2>&1 >NUL
        GOTO MENU_CD
    )
) ELSE (
    ECHO Directory does not exist.
    TIMEOUT /T 3 /NOBREAK 2>&1 >NUL
)
GOTO MENU_CD

REM Displays the main menu
:MENU_MAIN
CLS
CALL :FUNC_DISPLAY_HEADER
ECHO Menu selection:
ECHO   [1] Compress
ECHO   [2] Uncompress
ECHO   [3] Query
ECHO   [4] Change directory
ECHO   [5] Quit
ECHO.
ECHO.
SET BAT_USER_CHOICE=0
SET /P BAT_USER_CHOICE="Select: "
IF %BAT_USER_CHOICE% EQU 1 GOTO MENU_COMPRESS
IF %BAT_USER_CHOICE% EQU 2 GOTO MENU_UNCOMPRESS
IF %BAT_USER_CHOICE% EQU 3 GOTO MENU_QUERY
IF %BAT_USER_CHOICE% EQU 4 GOTO MENU_CD
IF %BAT_USER_CHOICE% EQU 5 GOTO EOF
GOTO MENU_MAIN


:EOF
SET BAT_CWD=
SET BAT_USER_CHOICE=
CLS
COLOR
