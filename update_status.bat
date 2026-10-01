@echo off
setlocal

cd /d "%~dp0"

where git >nul 2>&1
if errorlevel 1 (
    echo Git was not found on PATH.
    exit /b 1
)

git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
    echo This folder is not inside a Git repository.
    exit /b 1
)

echo Fetching latest remote status from origin. No working files will be changed.
git fetch origin
if errorlevel 1 (
    echo Fetch failed. Check your network connection and GitHub access.
    exit /b 1
)

echo.
echo Current branch and working-tree status:
git status --short --branch
if errorlevel 1 exit /b 1

exit /b 0