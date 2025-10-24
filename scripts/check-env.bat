@echo off
REM Environment variables checker for docker-compose.yml
REM Usage check-env.bat [--quiet]

setlocal enabledelayedexpansion

REM Required environment variables
set "REQUIRED_VARS=DOCKER_USERNAME ONEC_VERSION NETHASP_PATH WS_PASSWORD"

REM Optional variables removed

REM Check arguments
set "QUIET_MODE="
if "%1"=="--quiet" set "QUIET_MODE=1"

if "%QUIET_MODE%"=="" (
    echo [INFO] Checking environment variables for docker-compose.yml
    echo.
)

REM Check required variables
set "MISSING_VARS="
for %%v in (%REQUIRED_VARS%) do (
    if "!%%v!"=="" (
        set "MISSING_VARS=!MISSING_VARS! %%v"
    )
)

if not "%MISSING_VARS%"=="" (
    echo [ERROR] Missing required environment variables
    for %%v in (%MISSING_VARS%) do (
        if not "%%v"=="" (
            echo    - %%v
        )
    )
    echo.
    echo Set these variables and try again.
    echo You can copy env.example to .env and fill in the values.
    exit /b 1
)

if "%QUIET_MODE%"=="" (
    echo [SUCCESS] All required variables are set
)

REM Optional variables check removed

REM Check docker-compose configuration
if "%QUIET_MODE%"=="" (
    echo [INFO] Checking docker-compose configuration...
)

REM Try to find docker-compose or docker compose
set "COMPOSE_CMD="
docker-compose --version >nul 2>&1
if %errorlevel%==0 (
    set "COMPOSE_CMD=docker-compose"
) else (
    docker compose version >nul 2>&1
    if %errorlevel%==0 (
        set "COMPOSE_CMD=docker compose"
    )
)

if "%COMPOSE_CMD%"=="" (
    echo [ERROR] Docker Compose not found. Install Docker Compose.
    exit /b 1
)

REM Check configuration
%COMPOSE_CMD% config --quiet >nul 2>&1
if not %errorlevel%==0 (
    echo [ERROR] Error in docker-compose.yml configuration
    echo Run %COMPOSE_CMD% config for details
    exit /b 1
)

if "%QUIET_MODE%"=="" (
    echo [SUCCESS] docker-compose.yml configuration is valid
    echo.
    echo You can run docker-compose up
)

exit /b 0
