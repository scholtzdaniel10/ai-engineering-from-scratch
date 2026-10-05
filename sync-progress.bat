@echo off
setlocal
cd /d "%~dp0"
echo === Sync AI Engineering course: progress + new lessons ===
echo.

rem Trust this folder if Git says it has "dubious ownership" (it was created by Claude Cowork)
git rev-parse --git-dir >nul 2>&1
if errorlevel 1 git config --global --add safe.directory "%CD:\=/%"

rem The original course is the "upstream" remote (adds it on a fresh clone, e.g. the work PC)
git remote get-url upstream >nul 2>&1
if errorlevel 1 git remote add upstream https://github.com/rohitg00/ai-engineering-from-scratch.git

if exist ".git\index.lock" (
  echo .git\index.lock exists. Close other Git tools. If none are running, delete that file and run this again.
  pause
  exit /b 1
)

echo --- Saving your progress ---
git add -A
git diff --cached --quiet
if errorlevel 1 git commit -m "Update learning progress (%COMPUTERNAME%)"

echo --- Getting new lessons from the original course ---
git pull --no-rebase --no-edit upstream main
if errorlevel 1 goto conflict

echo --- Getting progress from your other PC ---
git pull --no-rebase --no-edit origin main
if errorlevel 1 goto conflict

echo --- Uploading to your GitHub fork ---
git push origin HEAD:main
if errorlevel 1 goto failed

echo.
echo Done. Your progress is on GitHub.
pause
exit /b 0

:conflict
echo.
echo Git hit a merge conflict. Nothing is lost. Copy this window's text and paste it to Claude.
pause
exit /b 1

:failed
echo.
echo Upload failed. Copy this window's text and paste it to Claude.
pause
exit /b 1
