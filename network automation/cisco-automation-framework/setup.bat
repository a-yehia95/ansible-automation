@echo off
REM ============================================================================
REM Setup Script for Cisco Automation Framework (Windows)
REM ============================================================================

echo.
echo ==========================================
echo Cisco Automation Framework Setup (Windows)
echo ==========================================
echo.

REM Check Python
echo [1/7] Checking Python version...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Python not found. Please install Python 3.8+
    exit /b 1
)
python --version
echo.

REM Install packages
echo [2/7] Installing Python packages...
pip install -q -r requirements.txt
echo [OK] Packages installed
echo.

REM Create directories
echo [3/7] Creating required directories...
if not exist "logs" mkdir logs
if not exist "backups" mkdir backups
if not exist "facts" mkdir facts
if not exist "reports" mkdir reports
echo [OK] Directories created
echo.

REM Vault setup
echo [4/7] Vault configuration...
echo Create encrypted vault file:
echo   ansible-vault create group_vars\all\vault.yml
echo Use vault_template.yml as reference
echo.

REM Collections check
echo [5/7] Verifying Ansible collections...
ansible-galaxy collection list | find "cisco.ios" >nul
if %errorlevel% neq 0 (
    echo Note: Installing cisco.ios collection...
    ansible-galaxy collection install cisco.ios cisco.fmc
) else (
    echo [OK] Collections verified
)
echo.

REM Inventory check
echo [6/7] Checking inventory file...
if exist "inventory.ini" (
    echo [OK] inventory.ini found
) else (
    echo Warning: inventory.ini not found. Please create and configure it.
)
echo.

REM Final
echo [7/7] Framework validation complete
echo.
echo ==========================================
echo Setup Complete!
echo ==========================================
echo.
echo Next steps:
echo 1. Update inventory.ini with your devices
echo 2. Create vault.yml: ansible-vault create group_vars\all\vault.yml
echo 3. Test connectivity: ansible ios_devices -m ping --vault-password-file %%USERPROFILE%%\.vault_pass
echo 4. Run provisioning: ansible-playbook site.yml --tags day0
echo.
echo For more info, see README.md and QUICKSTART.md
echo.