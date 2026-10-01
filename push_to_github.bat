@echo off
setlocal

cd /d "%~dp0"
set "REMOTE_URL=git@github.com:manishdatt-edu/biostats.git"
set GIT_SSH_COMMAND=ssh -i "%~dp0deploy_key" -o IdentitiesOnly=yes

where git >nul 2>&1
if errorlevel 1 (
    echo Git was not found on PATH.
    exit /b 1
)

if not exist ".git" (
    git init
    if errorlevel 1 goto :failed
)

git remote get-url origin >nul 2>&1
if errorlevel 1 (
    git remote add origin "%REMOTE_URL%"
) else (
    git remote set-url origin "%REMOTE_URL%"
)
if errorlevel 1 goto :failed

git add -A
if errorlevel 1 goto :failed

git diff --cached --quiet
if errorlevel 2 goto :failed
if errorlevel 1 (
    git commit -m "Update biostats files"
    if errorlevel 1 goto :failed
) else (
    echo No changes to commit.
)

git branch -M main
if errorlevel 1 goto :failed

git push -u origin main
if errorlevel 1 goto :failed

echo Push completed successfully.
exit /b 0

:failed
echo Push setup or Git operation failed. Check the output above and verify the deploy key has write access on GitHub.
exit /b 1