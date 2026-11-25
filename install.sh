
#!/usr/bin/env bash
set -Eeuo pipefail

# ==========================================
# CONFIGURATION
# ==========================================

REPO="https://raw.githubusercontent.com/zairyl123-ux/thesis-ai/main"
PROJECT_DIR="${PWD}/thesis-ai"

CPU_URL="https://download.pytorch.org/whl/cpu"
CUDA_URL="https://download.pytorch.org/whl/cu128"

echo
echo "=========================================="
echo "          THESIS AI INSTALLER"
echo "=========================================="

# ==========================================
# PYTHON CHECK
# ==========================================

echo
echo "[1/6] Checking Python..."

PYTHON="$(command -v python3 || true)"

if [[ -z "$PYTHON" ]]; then
    echo "ERROR: Python 3 not found."
    exit 1
fi

"$PYTHON" -c 'import sys; assert sys.version_info >= (3,10), "Python 3.10+ required"'

"$PYTHON" --version

# ==========================================
# ENVIRONMENT
# ==========================================

echo
echo "[2/6] Preparing environment..."

mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

if [[ ! -x ".venv/bin/python" ]]; then
    "$PYTHON" -m venv .venv
fi

PY=".venv/bin/python"

"$PY" -m pip install --upgrade pip

# ==========================================
# DEPENDENCIES
# ==========================================

echo
echo "[3/6] Checking dependencies..."

if "$PY" -c '
import importlib.util
mods = ["numpy", "pandas", "matplotlib", "PIL",
        "onnx", "onnxscript", "torch", "torchvision"]
missing = [m for m in mods if importlib.util.find_spec(m) is None]
print("Missing:", ", ".join(missing) if missing else "None")
raise SystemExit(bool(missing))
'; then
    echo "All dependencies are installed."
else
    read -r -p "Install missing dependencies? [Y/n] " answer

    if [[ "$answer" =~ ^[Nn]$ ]]; then
        echo "Skipping dependency installation."
    else
        echo
        echo "Installing additional dependencies..."

        curl -fL --retry 3 "$REPO/requirements.txt" -o requirements.txt

        "$PY" -m pip install -r requirements.txt

        if ! "$PY" -c 'import torch, torchvision' 2>/dev/null; then
            echo
            echo "[1] CPU only"
            echo "[2] NVIDIA CUDA 12.8"

            read -r -p "Select installation: " choice

            case "$choice" in
                1)
                    "$PY" -m pip install torch torchvision --index-url "$CPU_URL"
                    ;;
                2)
                    "$PY" -m pip install torch torchvision --index-url "$CUDA_URL"
                    ;;
                *)
                    echo "Invalid selection."
                    exit 1
                    ;;
            esac
        fi
    fi
fi

# ==========================================
# DOWNLOAD PROJECT
# ==========================================

echo
echo "[4/6] Downloading project..."

download_file() {
    local name="$1"
    local tmp="${name}.tmp"

    curl -fL --retry 3 "$REPO/$name" -o "$tmp"
    mv "$tmp" "$name"
}

download_file ai1.py
download_file transferbest.pth
download_file requirements.txt

mkdir -p predict_images

# ==========================================
# VERIFICATION
# ==========================================

echo
echo "[5/6] Verifying installation..."

"$PY" -c '
import torch, torchvision
print("PyTorch:", torch.__version__)
print("Torchvision:", torchvision.__version__)
print("CUDA:", torch.cuda.is_available())
print("Device:", torch.cuda.get_device_name(0)
      if torch.cuda.is_available() else "CPU")
'

if [[ ! -f transferbest.pth ]]; then
    echo "ERROR: Model checkpoint missing."
    exit 1
fi

# ==========================================
# LAUNCH
# ==========================================

echo
echo "[6/6] Installation complete!"
echo
echo "Project directory: $PROJECT_DIR"

read -r -p "Launch Thesis AI now? [y/N] " launch

if [[ "$launch" =~ ^[Yy]$ ]]; then
    "$PY" ai1.py
fi

echo
echo "Thank you for using Thesis AI!"
