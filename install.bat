
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

set "CPU_URL=https://download.pytorch.org/whl/cpu"
set "CUDA_URL=https://download.pytorch.org/whl/cu128"

echo.
echo ==========================================
echo          THESIS AI INSTALLER
echo ==========================================
echo.

:: ==========================================
:: PYTHON CHECK
:: ==========================================

echo [1/6] Checking Python...

where python >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found.
    echo Download Python 3.10 or newer:
    echo https://www.python.org/downloads/
    goto fail
)

python -c "import sys; sys.exit(0 if sys.version_info >= (3,10) else 1)"
if errorlevel 1 (
    echo ERROR: Python 3.10+ required.
    goto fail
)

python --version

:: ==========================================
:: PROJECT DIRECTORY
:: ==========================================

echo.
echo [2/6] Preparing environment...

if not exist "%ROOT%" mkdir "%ROOT%"
if errorlevel 1 goto fail

cd /d "%ROOT%"
if errorlevel 1 goto fail

if not exist ".venv\Scripts\python.exe" (
    python -m venv .venv
    if errorlevel 1 goto fail
)

set "PY=%CD%\.venv\Scripts\python.exe"

"%PY%" -m pip install --upgrade pip
if errorlevel 1 goto fail

:: ==========================================
:: DEPENDENCY CHECK
:: ==========================================

echo.
echo [3/6] Checking dependencies...

"%PY%" -c "import importlib.util as u; m=['numpy','pandas','matplotlib','PIL','onnx','onnxscript','torch','torchvision']; x=[p for p in m if u.find_spec(p) is None]; print('Missing:', ', '.join(x) if x else 'None'); raise SystemExit(bool(x))"

if not errorlevel 1 goto download_files

echo.
echo Some dependencies are missing.

choice /C YN /M "Install missing dependencies now"
if errorlevel 2 goto download_files

:: Install regular dependencies
"%PY%" -m pip install -r "%REPO%/requirements.txt"
if errorlevel 1 goto fail

:: Check PyTorch separately
"%PY%" -c "import importlib.util as u; raise SystemExit(0 if u.find_spec('torch') and u.find_spec('torchvision') else 1)"

if not errorlevel 1 goto download_files

echo.
echo Select PyTorch installation:
echo.
echo [1] CPU only
echo [2] NVIDIA CUDA 12.8
echo.

choice /C 12 /M "Choose installation"

if "%ERRORLEVEL%"=="2" (
    "%PY%" -m pip install torch torchvision --index-url %CUDA_URL%
) else (
    "%PY%" -m pip install torch torchvision --index-url %CPU_URL%
)

if errorlevel 1 goto fail

:: ==========================================
:: DOWNLOAD PROJECT
:: ==========================================

:download_files

echo.
echo [4/6] Downloading project files...

curl.exe -fL --retry 3 "%REPO%/ai1.py" -o ai1.py.tmp
if errorlevel 1 goto download_fail

move /y ai1.py.tmp ai1.py >nul

curl.exe -fL --retry 3 "%REPO%/transferbest.pth" -o transferbest.pth.tmp
if errorlevel 1 goto download_fail

move /y transferbest.pth.tmp transferbest.pth >nul

curl.exe -fL --retry 3 "%REPO%/requirements.txt" -o requirements.tmp
if errorlevel 1 goto download_fail

move /y requirements.tmp requirements.txt >nul

if not exist "predict_images" mkdir predict_images

:: ==========================================
:: VERIFY
:: ==========================================

echo.
echo [5/6] Verifying installation...

"%PY%" -c "import torch, torchvision; print('PyTorch:',torch.__version__); print('Torchvision:',torchvision.__version__); print('CUDA:',torch.cuda.is_available()); print('Device:',torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'CPU')"

if errorlevel 1 goto fail

if not exist "transferbest.pth" goto fail

echo.
echo Model checkpoint found.
echo Installation successful!

:: ==========================================
:: LAUNCH
:: ==========================================

echo.
echo [6/6] Installation complete.
echo.
echo Project directory:
echo %ROOT%
echo.

choice /C YN /M "Launch Thesis AI now"

if errorlevel 2 goto finish

"%PY%" ai1.py

:finish
echo.
echo Thank you for using Thesis AI!
pause
exit /b 0

:: ==========================================
:: ERRORS
:: ==========================================

:download_fail
echo.
echo ERROR: Download failed.
echo Check your internet connection and GitHub files.
goto error_exit

:fail
echo.
echo ERROR: Installation failed.
goto error_exit

:error_exit
if exist ai1.py.tmp del ai1.py.tmp
if exist transferbest.pth.tmp del transferbest.pth.tmp
if exist requirements.tmp del requirements.tmp
pause
exit /b 1
