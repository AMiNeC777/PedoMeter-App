@echo off
REM PedoMetre Flutter Rebuild Script
REM This script rebuilds the entire Flutter project from scratch

setlocal enabledelayedexpansion

echo.
echo ========================================
echo   PedoMetre Flutter Project Rebuild
echo ========================================
echo.

REM Step 1: Navigate to project directory
cd /d "c:\Users\pc\Desktop\Projects\PedoMetre\pedo_metreapp"
if errorlevel 1 (
    echo ERROR: Failed to navigate to project directory
    exit /b 1
)

echo [1/6] Cleaning Flutter project...
call flutter clean
if errorlevel 1 (
    echo ERROR: Flutter clean failed
    exit /b 1
)
echo ✓ Flutter cleaned successfully

echo.
echo [2/6] Upgrading dependencies...
call flutter pub upgrade
if errorlevel 1 (
    echo ERROR: Dependency upgrade failed
    exit /b 1
)
echo ✓ Dependencies upgraded

echo.
echo [3/6] Getting dependencies...
call flutter pub get
if errorlevel 1 (
    echo ERROR: Dependency get failed
    exit /b 1
)
echo ✓ Dependencies obtained

echo.
echo [4/6] Cleaning Android build...
cd android
call gradlew clean
if errorlevel 1 (
    echo WARNING: Gradle clean had issues (this may be normal)
)
cd ..
echo ✓ Android build cleaned

echo.
echo [5/6] Running Flutter analysis...
call flutter analyze --no-preamble
echo ✓ Analysis complete

echo.
echo [6/6] Building debug APK...
echo This may take 2-5 minutes on first build...
call flutter build apk --debug
if errorlevel 1 (
    echo ERROR: APK build failed
    exit /b 1
)
echo ✓ APK built successfully

echo.
echo ========================================
echo   Build Complete!
echo ========================================
echo.
echo Your app is ready to run with:
echo   flutter run
echo.
echo Or install the APK:
echo   adb install build\app\outputs\apk\debug\app-debug.apk
echo.

pause
