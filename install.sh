#!/usr/bin/env bash
set -euo pipefail

REPO="https://raw.githubusercontent.com/zairyl123-ux/thesis-ai/main"
PROJECT_DIR="${PWD}/thesis-ai"

echo "=========================================="
echo "          THESIS AI INSTALLER"
echo "=========================================="

PYTHON="$(command -v python3 || true)"
if [[ -z "$PYTHON" ]]; then
  echo "Python 3 was not found. Install Python 3.10 or newer first."
  exit 1
fi

"$PYTHON" -c 'import sys; assert sys.version_info >= (3,10), "Python 3.10+ required"'
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

if [[ ! -x ".venv/bin/python" ]]; then
  "$PYTHON" -m venv .venv
fi
PY=".venv/bin/python"

echo "Downloading requirements..."
curl -fL "$REPO/requirements.txt" -o requirements.txt

echo
echo "Choose PyTorch build:"
echo "[1] CPU only"
echo "[2] NVIDIA CUDA 12.8 (compatible GPU/driver required)"
read -r -p "Select 1 or 2: " choice

"$PY" -m pip install --upgrade pip
case "$choice" in
  1) "$PY" -m pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu ;;
  2) "$PY" -m pip install torch torchvision --index-url https://download.pytorch.org/whl/cu128 ;;
  *) echo "Invalid choice"; exit 1 ;;
esac

"$PY" -m pip install -r requirements.txt

echo "Downloading project files..."
curl -fL "$REPO/ai1.py" -o ai1.py
curl -fL "$REPO/transferbest.pth" -o transferbest.pth

echo
"$PY" -c 'import torch; print("PyTorch:", torch.__version__); print("CUDA available:", torch.cuda.is_available())'
echo
read -r -p "Launch Thesis AI now? [y/N] " launch
if [[ "$launch" =~ ^[Yy]$ ]]; then
  "$PY" ai1.py
fi
