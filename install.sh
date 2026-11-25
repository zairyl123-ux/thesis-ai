
#!/usr/bin/env bash
set -Eeuo pipefail

# ==========================================
# CONFIGURATION
# ==========================================

REPO="https://raw.githubusercontent.com/zairyl123-ux/thesis-ai/main"
PROJECT_DIR="${PWD}/thesis-ai"

CPU_URL="https://download.pytorch.org/whl/cpu"
CUDA_URL="https://download.pytorch.org/whl/cu128"

REQUIRED_FILES=("ai1.py" "transferbest.pth" "requirements.txt")

cd "$PWD"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# ==========================================
# FILE DETECTION
# ==========================================

check_files() {
    local missing=0

    echo
    echo "Checking project files..."

    for file in "${REQUIRED_FILES[@]}"; do
        if [[ -s "$file" ]]; then
            echo "[OK]      $file"
        else
            echo "[MISSING] $file"
            ((missing+=1))
        fi
    done

    if [[ -d predict_images ]]; then
        echo "[OK]      predict_images/"
    else
        echo "[MISSING] predict_images/"
    fi

    if [[ -x .venv/bin/python ]]; then
        echo "[OK]      .venv/"
    else
        echo "[MISSING] .venv/"
    fi

    return "$missing"
}

# ==========================================
# DOWNLOAD
# ==========================================

download_file() {
    local name="$1"
    local tmp="${name}.tmp"

    echo "Downloading $name..."

    rm -f "$tmp"

    if ! curl -fL --retry 3 "$REPO/$name" -o "$tmp"; then
        rm -f "$tmp"
        echo "ERROR: Failed to download $name."
        return 1
    fi

    if [[ ! -s "$tmp" ]]; then
        rm -f "$tmp"
        echo "ERROR: Downloaded file is empty: $name"
        return 1
    fi

    mv -f "$tmp" "$name"
    echo "[OK] $name downloaded."
}

download_project() {
    for file in "${REQUIRED_FILES[@]}"; do
        download_file "$file"
    done

    mkdir -p predict_images
}

download_missing() {
    for file in "${REQUIRED_FILES[@]}"; do
        if [[ ! -s "$file" ]]; then
            download_file "$file"
        fi
    done

    mkdir -p predict_images
}

# ==========================================
# PYTHON CHECK
# ==========================================

check_python() {
    PYTHON="$(command -v python3 || true)"

    if [[ -z "$PYTHON" ]]; then
        echo "ERROR: Python 3 not found."
        return 1
    fi

    if ! "$PYTHON" -c 'import sys; sys.exit(0 if sys.version_info >= (3,10) else 1)'; then
        echo "ERROR: Python 3.10 or newer is required."
        return 1
    fi

    "$PYTHON" --version
}

# ==========================================
# DEPENDENCIES
# ==========================================

check_dependencies() {
    .venv/bin/python -c '
import importlib.util
mods = ["numpy", "pandas", "matplotlib", "PIL",
        "onnx", "onnxscript", "torch", "torchvision"]
missing = [m for m in mods if importlib.util.find_spec(m) is None]
print("Missing:", ", ".join(missing) if missing else "None")
raise SystemExit(bool(missing))
'
}

install_dependencies() {
    check_python

    if [[ ! -x .venv/bin/python ]]; then
        "$PYTHON" -m venv .venv
    fi

    PY=".venv/bin/python"

    "$PY" -m pip install --upgrade pip
    "$PY" -m pip install -r requirements.txt

    if ! "$PY" -c 'import torch, torchvision' 2>/dev/null; then
        echo
        echo "[1] CPU only"
        echo "[2] NVIDIA CUDA 12.8"

        read -r -p "Select PyTorch installation: " choice

        case "$choice" in
            1)
                "$PY" -m pip install torch torchvision --index-url "$CPU_URL"
                ;;
            2)
                "$PY" -m pip install torch torchvision --index-url "$CUDA_URL"
                ;;
            *)
                echo "Invalid selection."
                return 1
                ;;
        esac
    fi

    echo
    echo "Dependencies installed successfully."
}

# ==========================================
# INSTALL / UPDATE
# ==========================================

install_update() {
    download_project
    install_dependencies
    verify_installation
}

# ==========================================
# REPAIR / REINSTALL
# ==========================================

repair_installation() {
    echo
    read -r -p "Recreate the Python environment? [y/N] " answer

    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        return
    fi

    rm -rf .venv

    download_missing
    install_dependencies
    verify_installation
}

# ==========================================
# VERIFICATION
# ==========================================

verify_installation() {
    echo
    echo "Verifying installation..."

    for file in "${REQUIRED_FILES[@]}"; do
        if [[ ! -s "$file" ]]; then
            echo "ERROR: Missing or empty file: $file"
            return 1
        fi
    done

    if [[ ! -x .venv/bin/python ]]; then
        echo "ERROR: Python environment is missing."
        return 1
    fi

    if ! check_dependencies; then
        echo "ERROR: Some Python dependencies are missing."
        return 1
    fi

    .venv/bin/python -c '
import torch, torchvision
print("PyTorch:", torch.__version__)
print("Torchvision:", torchvision.__version__)
print("CUDA:", torch.cuda.is_available())
print("Device:", torch.cuda.get_device_name(0)
      if torch.cuda.is_available() else "CPU")
'

    echo
    echo "Installation verified."
}

# ==========================================
# UNINSTALL
# ==========================================

uninstall() {
    echo
    echo "This will remove the Python environment."

    read -r -p "Also remove ai1.py, model and requirements? [y/N] " answer

    rm -rf .venv

    if [[ "$answer" =~ ^[Yy]$ ]]; then
        rm -f ai1.py transferbest.pth requirements.txt
    fi

    echo
    echo "Uninstallation complete."
    echo "predict_images/ has been preserved."
}

# ==========================================
# LAUNCH
# ==========================================

launch() {
    echo
    echo "Checking files before launch..."

    if [[ ! -s ai1.py || ! -s transferbest.pth || ! -s requirements.txt ]]; then
        echo "ERROR: Required project files are missing or empty."
        return 1
    fi

    if [[ ! -x .venv/bin/python ]]; then
        echo "ERROR: Environment not installed. Choose Install first."
        return 1
    fi

    if ! check_dependencies; then
        echo "ERROR: Dependencies are incomplete. Choose Repair."
        return 1
    fi

    .venv/bin/python ai1.py
}

# ==========================================
# STARTUP FILE SCAN
# ==========================================

echo
echo "=========================================="
echo "          THESIS AI INSTALLER"
echo "=========================================="

if ! check_files; then
    echo
    read -r -p "Download missing project files now? [Y/n] " answer

    if [[ ! "$answer" =~ ^[Nn]$ ]]; then
        download_missing
    fi
fi

# ==========================================
# MAIN MENU
# ==========================================

while true; do
    echo
    echo "=========================================="
    echo "              THESIS AI"
    echo "=========================================="
    echo
    echo "[1] Install / Update"
    echo "[2] Repair / Reinstall"
    echo "[3] Uninstall"
    echo "[4] Launch"
    echo "[5] Check project files"
    echo "[6] Exit"
    echo

    read -r -p "Select an option: " choice

    case "$choice" in
        1) install_update ;;
        2) repair_installation ;;
        3) uninstall ;;
        4) launch ;;
        5) check_files || true ;;
        6) echo "Thank you for using Thesis AI!"; exit 0 ;;
        *) echo "Invalid selection." ;;
    esac
done
