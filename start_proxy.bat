@echo off
echo ========================================
echo OpenAI Local Proxy Startup Script
echo ========================================
echo.

REM Check admin privileges
echo Checking administrator privileges...
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Administrator privileges required!
    echo Please right-click and select "Run as administrator"
    pause
    exit /b 1
)
echo Admin check passed
echo.

REM 1. Backup hosts
echo [1/4] Backing up hosts file...
if exist C:\Windows\System32\drivers\etc\hosts (
    copy /Y C:\Windows\System32\drivers\etc\hosts C:\Windows\System32\drivers\etc\hosts.backup >nul
    echo Hosts file backed up successfully
) else (
    echo ERROR: hosts file not found
    pause
    exit /b 1
)

REM 2. Add hijack rule
echo [2/4] Adding domain hijack...
findstr /C:"api.openai.com" C:\Windows\System32\drivers\etc\hosts >nul 2>&1
if %errorLevel% neq 0 (
    echo 127.0.0.1 api.openai.com >> C:\Windows\System32\drivers\etc\hosts
    echo Domain hijack added successfully
) else (
    echo Domain hijack already exists
)

REM 3. Flush DNS
echo [3/4] Flushing DNS cache...
ipconfig /flushdns >nul
echo DNS cache flushed

REM 4. Start Nginx
echo [4/4] Starting Nginx...
cd /d "%~dp0"
if exist nginx.exe (
    start /B nginx.exe
    echo Nginx started successfully
) else (
    echo ERROR: nginx.exe not found
    pause
    exit /b 1
)

echo.
echo ========================================
echo Proxy started!
echo   - api.openai.com hijacked to localhost
echo   - Nginx is running
echo.
echo Press any key to stop proxy and restore settings...
echo ========================================
pause >nul

REM Stop Nginx
echo.
echo [1/3] Stopping Nginx...
nginx.exe -s quit
timeout /t 2 >nul
echo Nginx stopped

REM Restore hosts
echo [2/3] Restoring hosts file...
if exist C:\Windows\System32\drivers\etc\hosts.backup (
    copy /Y C:\Windows\System32\drivers\etc\hosts.backup C:\Windows\System32\drivers\etc\hosts >nul
    echo Hosts file restored
) else (
    echo WARNING: hosts backup file not found
)

REM Flush DNS
echo [3/3] Flushing DNS cache...
ipconfig /flushdns >nul
echo DNS cache flushed

echo.
echo ========================================
echo Proxy stopped, all settings restored
echo ========================================
pause