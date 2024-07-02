
@echo off
SETLOCAL

set PARENT_DIR_HOME=%CD%
echo "Parent directory=%PARENT_DIR_HOME%"

set COPY_DIR_SRC=%CD%\copy_source
echo "Copy source directory=%COPY_DIR_SRC%"

CALL :DeleteTemp %PARENT_DIR_HOME%\meta5

REM CALL :DeleteTemp %PARENT_DIR_HOME%\terminal_aaa
REM CALL :CopyUpdates %COPY_DIR_SRC%\Indicators  %PARENT_DIR_HOME%\terminal_aaa\MQL5\Indicators
REM CALL :CopyUpdates %COPY_DIR_SRC%\Experts  %PARENT_DIR_HOME%\terminal_aaa\MQL5\Experts

REM CALL :DeleteTemp %PARENT_DIR_HOME%\terminal_bbb
REM CALL :CopyUpdates %COPY_DIR_SRC%\Indicators  %PARENT_DIR_HOME%\terminal_bbb\MQL5\Indicators
REM CALL :CopyUpdates %COPY_DIR_SRC%\Experts  %PARENT_DIR_HOME%\terminal_bbb\MQL5\Experts

REM CALL :DeleteTemp %PARENT_DIR_HOME%\terminal_ccc
REM CALL :CopyUpdates %COPY_DIR_SRC%\Indicators  %PARENT_DIR_HOME%\terminal_ccc\MQL5\Indicators
REM CALL :CopyUpdates %COPY_DIR_SRC%\Experts  %PARENT_DIR_HOME%\terminal_ccc\MQL5\Experts

REM CALL :DeleteTemp %PARENT_DIR_HOME%\terminal_ddd
REM CALL :CopyUpdates %COPY_DIR_SRC%\Indicators  %PARENT_DIR_HOME%\terminal_ddd\MQL5\Indicators
REM CALL :CopyUpdates %COPY_DIR_SRC%\Experts  %PARENT_DIR_HOME%\terminal_ddd\MQL5\Experts

REM CALL :DeleteTemp %PARENT_DIR_HOME%\terminal_eee
REM CALL :CopyUpdates %COPY_DIR_SRC%\Indicators  %PARENT_DIR_HOME%\terminal_eee\MQL5\Indicators
REM CALL :CopyUpdates %COPY_DIR_SRC%\Experts  %PARENT_DIR_HOME%\terminal_eee\MQL5\Experts

REM CALL :DeleteTemp %PARENT_DIR_HOME%\terminal_fff
REM CALL :CopyUpdates %COPY_DIR_SRC%\Indicators  %PARENT_DIR_HOME%\terminal_fff\MQL5\Indicators
REM CALL :CopyUpdates %COPY_DIR_SRC%\Experts  %PARENT_DIR_HOME%\terminal_fff\MQL5\Experts

REM CALL :DeleteTemp %PARENT_DIR_HOME%\terminal_ggg
REM CALL :CopyUpdates %COPY_DIR_SRC%\Indicators  %PARENT_DIR_HOME%\terminal_ggg\MQL5\Indicators
REM CALL :CopyUpdates %COPY_DIR_SRC%\Experts  %PARENT_DIR_HOME%\terminal_ggg\MQL5\Experts


EXIT /B %ERRORLEVEL%

:DeleteTemp

echo "---------------------- MT5 directory=%~1"

if exist "%~1\logs" (
	DEL "%~1\logs\*.*" /S /Q
	PING localhost -n 2 >NUL
) 

if exist "%~1\MQL5\logs" (
	DEL "%~1\MQL5\logs\*.*" /S /Q
	PING localhost -n 2 >NUL
) 

if exist "%~1\Tester" (
	RMDIR "%~1\Tester" /S /Q
	PING localhost -n 2 >NUL
) 

if exist "%~1\MQL5\Profiles\Tester" (
	RMDIR "%~1\MQL5\Profiles\Tester" /S /Q
	PING localhost -n 2 >NUL
) 

if exist "%~1\Bases\Custom" (
	RMDIR "%~1\Bases\Custom" /S /Q
	PING localhost -n 2 >NUL
)

EXIT /B 0

:CopyUpdates

if exist "%~2\Tilly" (
	RMDIR "%~2\Tilly" /S /Q
	echo "deleted directory=%~2\Tilly"
	PING localhost -n 2 >NUL
) 

if exist "%~1\Tilly" (
	XCOPY %~1 %~2 /E
	echo "copied directory=%~1\Tilly to the directory=%~2"
	PING localhost -n 2 >NUL
) 

EXIT /B 0
