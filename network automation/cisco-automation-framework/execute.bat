@echo off
REM ============================================================================
REM Execute Cisco Automation Framework (Windows)
REM ============================================================================

setlocal enabledelayedexpansion

set "VAULT_FILE=%USERPROFILE%\.vault_pass"
set "FRAMEWORK_DIR=%~dp0"
set "COMMAND=%1"
set "DEVICE=%2"

if "%DEVICE%"=="" set "DEVICE=all"

if not exist "%VAULT_FILE%" (
    echo Error: Vault password file not found at %VAULT_FILE%
    echo Please create: echo your_password ^> %%USERPROFILE%%\.vault_pass
    exit /b 1
)

if "%COMMAND%"=="day0" (
    echo Executing Day 0: Provisioning
    ansible-playbook "%FRAMEWORK_DIR%site.yml" --tags day0 --vault-password-file "%VAULT_FILE%" -l "%DEVICE%"
) else if "%COMMAND%"=="day1" (
    echo Executing Day 1: Deployment
    ansible-playbook "%FRAMEWORK_DIR%site.yml" --tags day1 --vault-password-file "%VAULT_FILE%" -l "%DEVICE%"
) else if "%COMMAND%"=="day2" (
    echo Executing Day 2: Operations
    ansible-playbook "%FRAMEWORK_DIR%site.yml" --tags day2 --vault-password-file "%VAULT_FILE%" -l "%DEVICE%"
) else if "%COMMAND%"=="backup" (
    echo Executing: Backup Configurations
    ansible-playbook "%FRAMEWORK_DIR%playbooks\backup.yml" --vault-password-file "%VAULT_FILE%" -l "%DEVICE%"
) else if "%COMMAND%"=="drift" (
    echo Executing: Drift Detection
    ansible-playbook "%FRAMEWORK_DIR%playbooks\drift_detection.yml" --vault-password-file "%VAULT_FILE%" -l "%DEVICE%"
) else if "%COMMAND%"=="facts" (
    echo Executing: Collect Facts
    ansible-playbook "%FRAMEWORK_DIR%playbooks\collect_facts.yml" --vault-password-file "%VAULT_FILE%" -l "%DEVICE%"
) else if "%COMMAND%"=="ping" (
    echo Testing connectivity to %DEVICE%
    ansible "%DEVICE%" -i "%FRAMEWORK_DIR%inventory.ini" -m ping --vault-password-file "%VAULT_FILE%"
) else if "%COMMAND%"=="full" (
    echo Executing Full Lifecycle
    ansible-playbook "%FRAMEWORK_DIR%site.yml" --vault-password-file "%VAULT_FILE%" -l "%DEVICE%"
) else if "%COMMAND%"=="check" (
    echo Executing Check Mode (Dry-run)
    ansible-playbook "%FRAMEWORK_DIR%site.yml" --vault-password-file "%VAULT_FILE%" --check -l "%DEVICE%"
) else (
    echo Cisco Automation Framework Executor
    echo.
    echo Usage: %0 [command] [device]
    echo.
    echo Commands:
    echo   day0       - Provisioning (system configuration)
    echo   day1       - Deployment (IOS ^& Firepower configuration)
    echo   day2       - Operations (validation, backup, monitoring)
    echo   full       - Full lifecycle (Day 0 to Day 2)
    echo   backup     - Backup configurations
    echo   drift      - Detect configuration drift
    echo   facts      - Collect device facts
    echo   ping       - Test device connectivity
    echo   check      - Dry-run (check mode)
    echo   help       - Show this help message
    echo.
    echo Examples:
    echo   %0 full
    echo   %0 day1 core-switch-01
    echo   %0 check ios_devices
)

endlocal