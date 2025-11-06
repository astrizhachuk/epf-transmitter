@echo off

chcp 65001 > nul

setlocal

echo [BUILD] Checking .env file and environment variables...
if not exist .env (
    echo [ERROR] .env file not found. Copy env.example to .env and fill it out.
    exit /b 1
)

for /f "tokens=1* delims==" %%a in (.env) do (
  set "%%a=%%b"
)

echo [BUILD] Loading environment variables from .env...

call scripts\check-env.bat
if %errorlevel% neq 0 (
    echo [ERROR] Environment check failed.
    exit /b 1
)

echo [BUILD] Starting database initialization...
docker-compose up --build -d init

echo [BUILD] Initialization complete. Removing temporary containers...
docker-compose rm -fs init ras

echo [BUILD] Build completed successfully!
