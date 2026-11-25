@echo off
setlocal EnableExtensions
title Thesis AI Installer
color 0B

set "REPO=https://raw.githubusercontent.com/zairyl123-ux/thesis-ai/main"
set "PROJECT=thesis-ai"
set "ROOT=%~dp0%PROJECT%"

echo.
echo ==========================================
echo          THESIS AI INSTALLER
echo ==========================================
echo.

where python >nul 2>&1
if errorlevel 1 (
    echo Python was not found. Install Python 3.10 or newer:
    echo https://www.python.org/downloads/
    pause
    exit /b 1
)

python --version
python -c "import sys; raise SystemExit(0 if sys.version_info >= (3,10) else 1)"
if errorlevel 1 (
    echo Python 3.10 or newer is required.
    pause
    exit /b 1
)

if not exist "%ROOT%" mkdir "%ROOT%"
cd /d "%ROOT%"

echo.
echo Creating isolated virtual environment...
if not exist ".venv\Scripts\python.exe" (
    python -m venv .venv
    if errorlevel 1 goto fail
)
set "PY=%CD%\.venv\Scripts\python.exe"

echo.
echo Downloading dependency list...
curl.exe -fL "%REPO%/requirements.txt" -o requirements.txt
if errorlevel 1 goto download_fail

echo.
echo Checking installed packages...
"%PY%" -c "import importlib.util; mods=['numpy','pandas','matplotlib','PIL','onnx','onnxscript','torch','torchvision']; missing=[m for m in mods if importlib.util.find_spec(m) is None]; print('Missing:', ', '.join(missing) if missing else 'None'); raise SystemExit(1 if missing else 0)"
if errorlevel 1 (
    echo.
    choice /C YN /M "Some dependencies are missing. Install them now"
    if errorlevel 2 (
        echo Skipping dependency installation. The project may not run until dependencies are installed.
        goto get_files
    )

    echo.
    echo Choose PyTorch build:
    echo [1] CPU only
    echo [2] NVIDIA CUDA 12.8 - compatible NVIDIA GPU and driver required
    choice /C 12 /M "Select CPU or CUDA"

    "%PY%" -m pip install --upgrade pip
    if errorlevel 1 goto fail

    if errorlevel 2 (
        "%PY%" -m pip install torch torchvision --index-url https://download.pytorch.org/whl/cu128
    ) else (
        "%PY%" -m pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu
    )
    if errorlevel 1 goto fail

    "%PY%" -m pip install -r requirements.txt
    if errorlevel 1 goto fail
) else (
    echo All dependencies appear to be installed.
)

:get_files
echo.
echo Downloading project files...
curl.exe -fL "%REPO%/ai1.py" -o ai1.py
if errorlevel 1 goto download_fail

curl.exe -fL "%REPO%/transferbest.pth" -o transferbest.pth
if errorlevel 1 goto download_fail

echo.
echo Verifying PyTorch...
"%PY%" -c "import torch; print('PyTorch:', torch.__version__); print('CUDA available:', torch.cuda.is_available()); print('Device:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'CPU')"
if errorlevel 1 echo WARNING: PyTorch verification failed. Check dependencies.

echo.
echo Installation files are in:
echo %ROOT%
choice /C YN /M "Launch Thesis AI now"
if errorlevel 2 goto done

"%PY%" ai1.py

:done
echo.
echo Finished.
pause
exit /b 0

:download_fail
echo.
echo ERROR: A download failed. Check the repository URL and internet connection.
pause
exit /b 1

:fail
echo.
echo ERROR: Setup failed. Read the error above.
pause
exit /b 1
