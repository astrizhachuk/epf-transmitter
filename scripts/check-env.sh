#!/bin/bash

# Environment variables checker for docker-compose.yml
# Usage: ./check-env.sh [--quiet]

set -e

# Plain logging (ASCII-only)

# Required environment variables
REQUIRED_VARS=(
    "DOCKER_USERNAME"
    "ONEC_VERSION" 
    "NETHASP_PATH"
    "IB_NAME"
    "DB_NAME"
    "WS_PASSWORD"
)

# Optional variables removed

# Logging helpers
log_info() {
    if [ "$1" != "--quiet" ]; then
        echo "[INFO] $2"
    fi
}

log_warn() {
    if [ "$1" != "--quiet" ]; then
        echo "[WARN] $2"
    fi
}

log_error() {
    echo "[ERROR] $2"
}

# Check required variables
check_required_vars() {
    local missing_vars=()
    
    for var in "${REQUIRED_VARS[@]}"; do
        if [ -z "${!var}" ]; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        log_error "" "Missing required environment variables"
        for var in "${missing_vars[@]}"; do
            echo "   - $var"
        done
        echo ""
        echo "Set these variables and try again."
        echo "You can copy env.example to .env and fill in the values."
        return 1
    fi
    
    return 0
}

# Optional variables check removed

# Validate docker-compose configuration
validate_compose_config() {
    if command -v docker-compose >/dev/null 2>&1; then
        COMPOSE_CMD="docker-compose"
    elif command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
        COMPOSE_CMD="docker compose"
    else
        log_error "" "Docker Compose not found. Install Docker Compose."
        return 1
    fi
    
    log_info "$1" "Checking docker-compose configuration..."
    
    if ! $COMPOSE_CMD config --quiet 2>/dev/null; then
        log_error "" "Error in docker-compose.yml configuration"
        echo "Run $COMPOSE_CMD config for details"
        return 1
    fi
    
    return 0
}

# Main
main() {
    local quiet_mode=""
    if [ "$1" = "--quiet" ]; then
        quiet_mode="--quiet"
    fi
    
    log_info "$quiet_mode" "Checking environment variables for docker-compose.yml"
    echo ""
    
    # Проверка обязательных переменных
    if ! check_required_vars; then
        exit 1
    fi
    
    log_info "$quiet_mode" "SUCCESS All required variables are set"
    
    # Optional variables check removed
    
    # Validate configuration
    if ! validate_compose_config "$quiet_mode"; then
        exit 1
    fi
    
    log_info "$quiet_mode" "SUCCESS docker-compose.yml configuration is valid"
    
    if [ "$quiet_mode" = "" ]; then
        echo ""
        echo "You can run docker-compose up"
    fi
}

# Запуск
main "$@"
