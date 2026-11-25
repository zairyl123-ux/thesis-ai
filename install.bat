
@echo off
setlocal EnableExtensions
title Thesis AI - Installation Manager
color 0B

:: ==========================================
:: CONFIGURATION
:: ==========================================

set "REPO=https://raw.githubusercontent.com/zairyl123-ux/thesis-ai/main"
set "PROJECT=thesis-ai"
set "ROOT=%~dp0%PROJECT%"
set "CUDA_URL=https://download.pytorch.org/whl/cu128"
set "CPU_URL=https://download.pytorch.org/whl/cpu"

echo.
echo ==========================================
echo          THESIS AI INSTALLER
echo ==========================================
echo          Cross-platform project
echo ==========================================
echo.

:: ==========================================
:: 1. SYSTEM REQUIREMENTS
:: ==========================================

echo [1/7] Checking system requirements...
echo.

where python >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python was not found.
    echo.
    echo Please install Python 3.10 or newer:
    echo https://www.python.org/downloads/
    goto fail
)

python --version

python -c "import sys; sys.exit(0 if sys.version_info >= (3,10) else 1)"
if errorlevel 1 (
    echo ERROR: Python 3.10 or newer is required.
    goto fail
)

python -m pip --version
if errorlevel 1 (
    echo ERROR: pip is unavailable.
    goto fail
)

:: ==========================================
:: 2. PROJECT ENVIRONMENT
:: ==========================================

echo.
echo [2/7] Preparing project environment...
echo.

if not exist "%ROOT%" mkdir "%ROOT%"
if errorlevel 1 goto fail

cd /d "%ROOT%"
if errorlevel 1 goto fail

if not exist ".venv\Scripts\python.exe" (
    echo Creating virtual environment...
    python -m venv .venv
    if errorlevel 1 goto fail
) else (
    echo Existing virtual environment found.
)

set "PY=%CD%\.venv\Scripts\python.exe"

:: ==========================================
:: 3. DOWNLOAD REQUIREMENTS
:: ==========================================

echo.
echo [3/7] Retrieving dependency list...
echo.

curl.exe -fL --retry 3 --connect-timeout 15 "%REPO%/requirements.txt" -o requirements.tmp
if errorlevel 1 goto download_fail

move /y requirements.tmp requirements.txt >nul
if errorlevel 1 goto fail

:: ==========================================
:: 4. DEPENDENCY CHECK
:: ==========================================

echo.
echo [4/7] Checking Python dependencies...
echo.

"%PY%" -c "import importlib.util; mods=['numpy','pandas','matplotlib','PIL','onnx','onnxscript','torch','torchvision']; missing=[m for m in mods if importlib.util.find_spec(m) is None]; print('Missing packages:', ', '.join(missing) if missing else 'None'); raise SystemExit(1 if missing else 0)"

if errorlevel 1 goto dependency_prompt

echo All required packages appear to be installed.
goto download_files

:dependency_prompt

echo.
echo ==========================================
echo          DEPENDENCIES MISSING
echo ==========================================
echo.
echo Some required packages are missing.
echo.
choice /C YN /M "Would you like to install dependencies"

if errorlevel 2 (
    echo.
    echo Dependency installation skipped.
    goto download_files
)

:: ==========================================
:: 5. PYTORCH INSTALLATION
:: ==========================================

echo.
echo ==========================================
echo          PYTORCH CONFIGURATION
echo ==========================================
echo.
echo [1] CPU-only installation
echo [2] NVIDIA CUDA 12.8 installation
echo.
echo Note: CUDA requires a compatible NVIDIA GPU,
echo driver, and supported GPU architecture.
echo.

choice /C 12 /M "Select installation type"
set "GPU_CHOICE=%ERRORLEVEL%"

echo.
echo Updating pip...

"%PY%" -m pip install --upgrade pip
if errorlevel 1 goto install_fail

if "%GPU_CHOICE%"=="2" (
    echo.
    echo Installing NVIDIA CUDA PyTorch...
    "%PY%" -m pip install torch torchvision --index-url %CUDA_URL%
) else (
    echo.
    echo Installing CPU-only PyTorch...
    "%PY%" -m pip install torch torchvision --index-url %CPU_URL%
)

if errorlevel 1 goto install_fail

:: Install remaining dependencies
echo.
echo Installing remaining project dependencies...

"%PY%" -m pip install -r requirements.txt
if errorlevel 1 goto install_fail

:: ==========================================
:: 6. DOWNLOAD PROJECT FILES
:: ==========================================

:download_files

echo.
echo ==========================================
echo          DOWNLOADING PROJECT
echo ==========================================
echo.

echo Downloading ai1.py...

curl.exe -fL --retry 3 --connect-timeout 15 "%REPO%/ai1.py" -o ai1.py.tmp
if errorlevel 1 goto download_fail

move /y ai1.py.tmp ai1.py >nul
if errorlevel 1 goto fail

echo.
echo Downloading trained model...

curl.exe -fL --retry 3 --connect-timeout 15 "%REPO%/transferbest.pth" -o transferbest.pth.tmp
if errorlevel 1 goto download_fail

move /y transferbest.pth.tmp transferbest.pth >nul
if errorlevel 1 goto fail

:: ==========================================
:: 7. ENVIRONMENT VERIFICATION
:: ==========================================

echo.
echo ==========================================
echo          SYSTEM VERIFICATION
echo ==========================================
echo.

"%PY%" -c "import torch; print('PyTorch:',torch.__version__); print('CUDA available:',torch.cuda.is_available()); print('Device:',torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'CPU')"

if errorlevel 1 (
    echo WARNING: PyTorch verification failed.
)

echo.
echo ==========================================
echo          INSTALLATION COMPLETE
echo ==========================================
echo.
echo Project location:
echo %ROOT%
echo.
echo Virtual environment:
echo %ROOT%\.venv
echo.

choice /C YN /M "Would you like to launch Thesis AI now"

if errorlevel 2 goto finish

echo.
echo Launching Thesis AI...
echo.

"%PY%" ai1.py

echo.
echo Application exited.

:finish
echo.
echo Thank you for using Thesis AI!
pause
exit /b 0

:: ==========================================
:: ERROR HANDLING
:: ==========================================

:download_fail
echo.
echo ==========================================
echo          DOWNLOAD ERROR
echo ==========================================
echo.
echo Failed to download a project file.
echo Check your internet connection and GitHub repository.
goto exit_error

:install_fail
echo.
echo ==========================================
echo          INSTALLATION ERROR
echo ==========================================
echo.
echo Dependency installation failed.
echo Check your Python version, internet connection,
echo and PyTorch compatibility.
goto exit_error

:fail
echo.
echo ==========================================
echo          SETUP ERROR
echo ==========================================
echo.
echo An error occurred during setup.
goto exit_error

:exit_error
if exist "requirements.tmp" del "requirements.tmp"
if exist "ai1.py.tmp" del "ai1.py.tmp"
if exist "transferbest.pth.tmp" del "transferbest.pth.tmp"
pause
exit /b 1
