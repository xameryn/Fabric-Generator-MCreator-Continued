batch
@echo off
echo Starting build and installation process...

echo.
echo Step 1: Exporting plugin...
call gradlew.bat exportPlugin
if %ERRORLEVEL% neq 0 (
    echo Error exporting plugin. Aborting.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo Step 2: Installing plugin...
call gradlew.bat install
if %ERRORLEVEL% neq 0 (
    echo Error installing plugin. Aborting.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo Step 3: Attempting to run MCreator...
"C:\Program Files\Pylo\MCreator\mcreator.exe"
if %ERRORLEVEL% neq 0 (
    echo Error running MCreator. Please check your MCreator installation path.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo Process completed successfully.
pause
