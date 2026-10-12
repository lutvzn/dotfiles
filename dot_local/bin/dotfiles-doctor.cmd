@echo off
where.exe node.exe >nul 2>nul
if errorlevel 1 (
    echo [FAIL] Node is not on PATH. Apply provisioning and open a new terminal. 1>&2
    exit /b 1
)
node.exe "%USERPROFILE%\.config\personalScripts\dotfiles-doctor.cjs" %*
exit /b %errorlevel%
