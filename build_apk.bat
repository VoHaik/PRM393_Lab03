@echo off
title Journal Trend Analyzer - APK Builder
color 0A
cls
echo =======================================================
echo          SCIENTIA ANALYTICS - APK BUILDER             
echo =======================================================
echo.
echo [1/3] Cleaning previous build cache...
call flutter clean
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo ERROR: Flutter clean failed. Please make sure Flutter is installed and added to your system PATH.
    pause
    exit /b %errorlevel%
)
echo.
echo [2/3] Resolving project dependencies (flutter pub get)...
call flutter pub get
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo ERROR: Flutter pub get failed.
    pause
    exit /b %errorlevel%
)
echo.
echo [3/3] Building Release APK (this might take a few minutes)...
call flutter build apk --release --dart-define-from-file=.env.json
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo ERROR: Flutter build failed.
    pause
    exit /b %errorlevel%
)

color 0E
echo.
echo =======================================================
echo SUCCESS: Release APK has been built successfully!      
echo =======================================================
echo.
echo Output Path: build\app\outputs\flutter-apk\app-release.apk
echo.
set /p open_folder="Do you want to open the output folder in File Explorer? (Y/N): "
if /i "%open_folder%"=="Y" (
    explorer build\app\outputs\flutter-apk
)
echo.
echo Build process complete. Goodbye!
pause
