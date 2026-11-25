@echo off
setlocal

cd /d "%~dp0"
set "REMOTE_NAME=gitlab"
set "REMOTE_URL=git@gitlab.com:bioinfo-guru-group/biostat.git"
set GIT_SSH_COMMAND=ssh -i "%~dp0deploy_key" -o IdentitiesOnly=yes

where git >nul 2>&1
if errorlevel 1 (
    echo Git was not found on PATH.
    exit /b 1
)

if not exist ".git" (
    echo This folder is not a Git repository.
    exit /b 1
)

git remote get-url %REMOTE_NAME% >nul 2>&1
if errorlevel 1 (
    git remote add %REMOTE_NAME% "%REMOTE_URL%"
) else (
    git remote set-url %REMOTE_NAME% "%REMOTE_URL%"
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

for /f %%b in ('git branch --show-current') do set "BRANCH=%%b"
if not defined BRANCH (
    echo Could not determine the current branch.
    goto :failed
)

git push -u %REMOTE_NAME% %BRANCH%
if errorlevel 1 goto :failed

echo Push to GitLab completed successfully.
exit /b 0

:failed
echo GitLab push failed. Check the output above and verify your SSH key has write access to the GitLab project.
exit /b 1
