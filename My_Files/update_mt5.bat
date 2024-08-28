
@echo off
setlocal

set PARENT_DIR_HOME=%CD%
echo Parent directory = %PARENT_DIR_HOME%

set COPY_DIR_SRC=%CD%\copy_source
echo Source directory = %COPY_DIR_SRC%

:: Process the each MT5 directory here

::CALL :ProcessMT5 %PARENT_DIR_HOME%\meta5
CALL :ProcessMT5 %PARENT_DIR_HOME%\terminal_2
CALL :ProcessMT5 %PARENT_DIR_HOME%\terminal_3
CALL :ProcessMT5 %PARENT_DIR_HOME%\terminal_4
CALL :ProcessMT5 %PARENT_DIR_HOME%\terminal_5
CALL :ProcessMT5 %PARENT_DIR_HOME%\terminal_6
CALL :ProcessMT5 %PARENT_DIR_HOME%\terminal_7


EXIT /B %ERRORLEVEL%


:ProcessMT5

if exist "%~1" (

	echo ------------------------------------------
	echo 	MT5 directory = %~1
	CALL :DeleteBases %~1
	CALL :DeleteTemp %~1
	CALL :CopyUpdates %COPY_DIR_SRC%\Indicators  %~1\MQL5\Indicators
	CALL :CopyUpdates %COPY_DIR_SRC%\Experts  %~1\MQL5\Experts

)

EXIT /B 0

:DeleteBases

:: Loop through all subdirectories in the base directory
for /d %%D in ("%~1\Bases\*") do (
	
	echo 	cleaning directory = %%D
	
	if exist "%%D\history" (
		RMDIR "%%D\history" /S /Q		
		PING localhost -n 2 >NUL
	)
	
	if exist "%%D\ticks" (
		RMDIR "%%D\ticks" /S /Q		
		PING localhost -n 2 >NUL
	)

	if exist "%%D\trades" (
		RMDIR "%%D\trades" /S /Q		
		PING localhost -n 2 >NUL
	)
	
)

EXIT /B 0

:DeleteTemp

if exist "%~1\logs" (
	echo 	deleting directory = %~1\logs
	RMDIR "%~1\logs" /S /Q	
	PING localhost -n 2 >NUL
) 

if exist "%~1\MQL5\Logs" (
	echo 	deleting directory = %~1\MQL5\Logs
	RMDIR "%~1\MQL5\Logs" /S /Q	
	PING localhost -n 2 >NUL
) 

if exist "%~1\Tester" (
	echo 	deleting directory = %~1\Tester
	RMDIR "%~1\Tester" /S /Q	
	PING localhost -n 2 >NUL
) 

if exist "%~1\MQL5\Profiles\Tester" (
	RMDIR "%~1\MQL5\Profiles\Tester" /S /Q
	PING localhost -n 2 >NUL
) 

if exist "%~1\Bases\Custom" (
	echo 	deleting directory = %~1\Bases\Custom
	RMDIR "%~1\Bases\Custom" /S /Q	
	PING localhost -n 2 >NUL
)

EXIT /B 0

:CopyUpdates

if exist "%~1" (

	if exist "%~2\Tilly" (
		echo 	deleting directory = %~2\Tilly
		RMDIR "%~2\Tilly" /S /Q		
		PING localhost -n 2 >NUL
	) 

	if exist "%~1\Tilly" (
		echo 	copying directory = %~1\Tilly to the directory = %~2
		XCOPY %~1 %~2 /E		
		PING localhost -n 2 >NUL
	) 

)


EXIT /B 0

endlocal
pause

