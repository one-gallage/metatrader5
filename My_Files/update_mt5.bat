
@echo off
SETLOCAL

set PARENT_DIR_HOME=%CD%
echo "Parent directory=%PARENT_DIR_HOME%"

set COPY_DIR_SRC=%CD%\copy_source
echo "Copy source directory=%COPY_DIR_SRC%"

CALL :DeleteTemp %PARENT_DIR_HOME%\terminal_neo
CALL :CopyUpdates %COPY_DIR_SRC%\Indicators  %PARENT_DIR_HOME%\terminal_neo\MQL5\Indicators
CALL :CopyUpdates %COPY_DIR_SRC%\Experts  %PARENT_DIR_HOME%\terminal_neo\MQL5\Experts

CALL :DeleteTemp %PARENT_DIR_HOME%\terminal_1
CALL :CopyUpdates %COPY_DIR_SRC%\Indicators  %PARENT_DIR_HOME%\terminal_1\MQL5\Indicators
CALL :CopyUpdates %COPY_DIR_SRC%\Experts  %PARENT_DIR_HOME%\terminal_1\MQL5\Experts

CALL :DeleteTemp %PARENT_DIR_HOME%\terminal_2
CALL :CopyUpdates %COPY_DIR_SRC%\Indicators  %PARENT_DIR_HOME%\terminal_2\MQL5\Indicators
CALL :CopyUpdates %COPY_DIR_SRC%\Experts  %PARENT_DIR_HOME%\terminal_2\MQL5\Experts

CALL :DeleteTemp %PARENT_DIR_HOME%\terminal_3
CALL :CopyUpdates %COPY_DIR_SRC%\Indicators  %PARENT_DIR_HOME%\terminal_3\MQL5\Indicators
CALL :CopyUpdates %COPY_DIR_SRC%\Experts  %PARENT_DIR_HOME%\terminal_3\MQL5\Experts

CALL :DeleteTemp %PARENT_DIR_HOME%\terminal_4
CALL :CopyUpdates %COPY_DIR_SRC%\Indicators  %PARENT_DIR_HOME%\terminal_4\MQL5\Indicators
CALL :CopyUpdates %COPY_DIR_SRC%\Experts  %PARENT_DIR_HOME%\terminal_4\MQL5\Experts

CALL :DeleteTemp %PARENT_DIR_HOME%\terminal_5
CALL :CopyUpdates %COPY_DIR_SRC%\Indicators  %PARENT_DIR_HOME%\terminal_5\MQL5\Indicators
CALL :CopyUpdates %COPY_DIR_SRC%\Experts  %PARENT_DIR_HOME%\terminal_5\MQL5\Experts

CALL :DeleteTemp %PARENT_DIR_HOME%\terminal_6
CALL :CopyUpdates %COPY_DIR_SRC%\Indicators  %PARENT_DIR_HOME%\terminal_6\MQL5\Indicators
CALL :CopyUpdates %COPY_DIR_SRC%\Experts  %PARENT_DIR_HOME%\terminal_6\MQL5\Experts

CALL :DeleteTemp %PARENT_DIR_HOME%\terminal_7
CALL :CopyUpdates %COPY_DIR_SRC%\Indicators  %PARENT_DIR_HOME%\terminal_7\MQL5\Indicators
CALL :CopyUpdates %COPY_DIR_SRC%\Experts  %PARENT_DIR_HOME%\terminal_7\MQL5\Experts

EXIT /B %ERRORLEVEL%

:DeleteTemp

echo "-------------------------------- MT5 directory=%~1"

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
