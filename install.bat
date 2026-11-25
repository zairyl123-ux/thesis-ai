
@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Thesis AI Installation Manager
color 0B

:: ==========================================
:: CONFIGURATION
:: ==========================================

set "REPO=https://raw.githubusercontent.com/zairyl123-ux/thesis-ai/main"
set "ROOT=%~dp0thesis-ai"

set "CPU_URL=https://download.pytorch.org/whl/cpu"
set "CUDA_URL=https://download.pytorch.org/whl/cu128"

if not exist "%ROOT%" mkdir "%ROOT%"
cd /d "%ROOT%" || goto ERROR

:: ==========================================
:: STARTUP FILE DETECTION
:: ==========================================

echo.
echo ==========================================
echo          THESIS AI INSTALLER
echo ==========================================
echo.
echo Checking project files...

call :CHECK_FILES

if not "!MISSING!"=="0" (
    echo.
    choice /C YN /M "Download missing project files now"

    if errorlevel 2 goto MENU

    call :DOWNLOAD_MISSING
    if errorlevel 1 goto ERROR
)

goto MENU

:: ==========================================
:: FILE CHECK
:: ==========================================

:CHECK_FILES
set "MISSING=0"

call :CHECK_ONE ai1.py
call :CHECK_ONE transferbest.pth
call :CHECK_ONE requirements.txt

if exist "predict_images\" (
    echo [OK]      predict_images\
) else (
    echo [MISSING] predict_images\
)

if exist ".venv\Scripts\python.exe" (
    echo [OK]      .venv\
) else (
    echo [MISSING] .venv\
)

exit /b 0

:CHECK_ONE
if not exist "%~1" (
    echo [MISSING] %~1
    set /a MISSING+=1
    exit /b 0
)

for %%F in ("%~1") do (
    if %%~zF LEQ 0 (
        echo [EMPTY]   %~1
        set /a MISSING+=1
        exit /b 0
    )
)

echo [OK]      %~1
exit /b 0

:: ==========================================
:: DOWNLOAD FUNCTIONS
:: ==========================================

:DOWNLOAD_ONE
set "FILE=%~1"

echo Downloading !FILE!...

if exist "!FILE!.tmp" del /q "!FILE!.tmp"

curl.exe -fL --retry 3 "%REPO%/!FILE!" -o "!FILE!.tmp"
if errorlevel 1 (
    if exist "!FILE!.tmp" del /q "!FILE!.tmp"
    echo ERROR: Download failed: !FILE!
    exit /b 1
)

for %%F in ("!FILE!.tmp") do (
    if %%~zF LEQ 0 (
        del /q "!FILE!.tmp"
        echo ERROR: Downloaded file is empty.
        exit /b 1
    )
)

move /y "!FILE!.tmp" "!FILE!" >nul
if errorlevel 1 exit /b 1

echo [OK] !FILE! downloaded.
exit /b 0

:DOWNLOAD_MISSING
if not exist "ai1.py" call :DOWNLOAD_ONE ai1.py
if errorlevel 1 exit /b 1

if exist "ai1.py" (
    for %%F in ("ai1.py") do if %%~zF LEQ 0 call :DOWNLOAD_ONE ai1.py
)

if not exist "transferbest.pth" call :DOWNLOAD_ONE transferbest.pth
if errorlevel 1 exit /b 1

if exist "transferbest.pth" (
    for %%F in ("transferbest.pth") do if %%~zF LEQ 0 call :DOWNLOAD_ONE transferbest.pth
)

if not exist "requirements.txt" call :DOWNLOAD_ONE requirements.txt
if errorlevel 1 exit /b 1

if exist "requirements.txt" (
    for %%F in ("requirements.txt") do if %%~zF LEQ 0 call :DOWNLOAD_ONE requirements.txt
)

if not exist "predict_images" mkdir predict_images
exit /b 0

:DOWNLOAD_ALL
call :DOWNLOAD_ONE ai1.py
if errorlevel 1 exit /b 1

call :DOWNLOAD_ONE transferbest.pth
if errorlevel 1 exit /b 1

call :DOWNLOAD_ONE requirements.txt
if errorlevel 1 exit /b 1

if not exist "predict_images" mkdir predict_images
exit /b 0

:: ==========================================
:: PYTHON CHECK
:: ==========================================

:CHECK_PYTHON
where python >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found.
    echo https://www.python.org/downloads/
    exit /b 1
)

python -c "import sys; sys.exit(0 if sys.version_info >= (3,10) else 1)"
if errorlevel 1 (
    echo ERROR: Python 3.10 or newer is required.
    exit /b 1
)

python --version
exit /b 0

:: ==========================================
:: DEPENDENCY CHECK
:: ==========================================

:CHECK_DEPS
".venv\Scripts\python.exe" -c "import importlib.util as u; m=['numpy','pandas','matplotlib','PIL','onnx','onnxscript','torch','torchvision']; x=[p for p in m if u.find_spec(p) is None]; print('Missing:', ', '.join(x) if x else 'None'); raise SystemExit(bool(x))"
exit /b %ERRORLEVEL%

:: ==========================================
:: INSTALL DEPENDENCIES
:: ==========================================

:INSTALL_DEPS
call :CHECK_PYTHON
if errorlevel 1 exit /b 1

if not exist ".venv\Scripts\python.exe" (
    python -m venv .venv
    if errorlevel 1 exit /b 1
)

".venv\Scripts\python.exe" -m pip install --upgrade pip
if errorlevel 1 exit /b 1

".venv\Scripts\python.exe" -m pip install -r requirements.txt
if errorlevel 1 exit /b 1

".venv\Scripts\python.exe" -c "import torch, torchvision" >nul 2>&1
if not errorlevel 1 exit /b 0

echo.
echo Select PyTorch installation:
echo.
echo [1] CPU only
echo [2] NVIDIA CUDA 12.8

choice /C 12 /M "Choose installation"

if errorlevel 2 (
    ".venv\Scripts\python.exe" -m pip install torch torchvision --index-url %CUDA_URL%
) else (
    ".venv\Scripts\python.exe" -m pip install torch torchvision --index-url %CPU_URL%
)

if errorlevel 1 exit /b 1
exit /b 0

:: ==========================================
:: VERIFICATION
:: ==========================================

:VERIFY
call :CHECK_FILES

if not "!MISSING!"=="0" (
    echo ERROR: Required files are missing or empty.
    exit /b 1
)

if not exist ".venv\Scripts\python.exe" (
    echo ERROR: Python environment missing.
    exit /b 1
)

call :CHECK_DEPS
if errorlevel 1 (
    echo ERROR: Python dependencies are incomplete.
    exit /b 1
)

".venv\Scripts\python.exe" -c "import torch, torchvision; print('PyTorch:',torch.__version__); print('Torchvision:',torchvision.__version__); print('CUDA:',torch.cuda.is_available()); print('Device:',torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'CPU')"
if errorlevel 1 exit /b 1

echo.
echo Installation verified successfully.
exit /b 0

:: ==========================================
:: INSTALL / UPDATE
:: ==========================================

:INSTALL
echo.
echo Installing / updating Thesis AI...

call :DOWNLOAD_ALL
if errorlevel 1 goto DOWNLOAD_ERROR

call :INSTALL_DEPS
if errorlevel 1 goto ERROR

call :VERIFY
if errorlevel 1 goto ERROR

goto MENU

:: ==========================================
:: REPAIR / REINSTALL
:: ==========================================

:REPAIR
echo.
echo This will recreate the Python environment.
choice /C YN /M "Continue"
if errorlevel 2 goto MENU

if exist ".venv" rmdir /s /q ".venv"

call :DOWNLOAD_MISSING
if errorlevel 1 goto DOWNLOAD_ERROR

call :INSTALL_DEPS
if errorlevel 1 goto ERROR

call :VERIFY
if errorlevel 1 goto ERROR

goto MENU

:: ==========================================
:: UNINSTALL
:: ==========================================

:UNINSTALL
echo.
echo This will remove the Python environment.
choice /C YN /M "Continue"
if errorlevel 2 goto MENU

if exist ".venv" rmdir /s /q ".venv"

echo.
choice /C YN /M "Also remove ai1.py, transferbest.pth and requirements.txt"
if errorlevel 2 goto UNINSTALL_DONE

del /q ai1.py transferbest.pth requirements.txt 2>nul

:UNINSTALL_DONE
echo.
echo Uninstallation complete.
echo predict_images\ has been preserved.
goto MENU

:: ==========================================
:: LAUNCH
:: ==========================================

:LAUNCH
echo.
echo Checking files before launch...

call :VERIFY
if errorlevel 1 goto MENU

".venv\Scripts\python.exe" ai1.py

echo.
pause
goto MENU

:: ==========================================
:: MENU
:: ==========================================

:MENU
echo.
echo ==========================================
echo              THESIS AI
echo ==========================================
echo.
echo [1] Install / Update
echo [2] Repair / Reinstall
echo [3] Uninstall
echo [4] Launch
echo [5] Check project files
echo [6] Exit
echo.

set "OPTION="
set /p OPTION="Select an option: "

if "!OPTION!"=="1" goto INSTALL
if "!OPTION!"=="2" goto REPAIR
if "!OPTION!"=="3" goto UNINSTALL
if "!OPTION!"=="4" goto LAUNCH
if "!OPTION!"=="5" (
    call :CHECK_FILES
    pause
    goto MENU
)
if "!OPTION!"=="6" goto EXIT

echo Invalid selection.
goto MENU

:: ==========================================
:: ERRORS
:: ==========================================

:DOWNLOAD_ERROR
echo.
echo ERROR: A project file could not be downloaded.
echo Check your internet connection and GitHub repository.
pause
goto MENU

:ERROR
echo.
echo ERROR: Operation failed.
pause
goto MENU

:EXIT
echo.
echo Thank you for using Thesis AI!
exit /b 0
