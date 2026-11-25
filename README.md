# Thesis AI — cross-platform setup

This kit adds separate setup paths for Windows, Linux, and Google Colab while keeping one project repository.

## Repository files expected

The public GitHub repository must contain these files at its root:

- `ai1.py`
- `transferbest.pth`
- `requirements.txt`

The installer scripts in this kit download those exact paths from the `main` branch.

## Windows CMD / PowerShell

Download `install.bat` and run it:

```powershell
curl.exe -L https://raw.githubusercontent.com/zairyl123-ux/thesis-ai/main/install.bat -o install.bat
.\install.bat
```

The batch installer creates `thesis-ai\\.venv`, prompts before installing missing dependencies, offers CPU or CUDA 12.8 PyTorch, downloads the project files, and optionally launches the script.

## Linux

Put `install.sh` in the repository root, commit it, then run:

```bash
chmod +x install.sh
./install.sh
```

## Google Colab

Open `colab_setup.ipynb` in Colab, select a GPU runtime if desired, and run the setup cell. Colab generally provides PyTorch already, so the notebook preserves its existing Torch installation and installs only `requirements.txt`.

## Important notes

- `requirements.txt` deliberately excludes `torch` and `torchvision`; those are installed separately on local machines to let users choose CPU or CUDA.
- CUDA 12.8 is a selectable example build, not a guarantee that every NVIDIA GPU is supported. Check the current official PyTorch selector for the correct build: https://pytorch.org/get-started/locally/
- A GPU being detected by `nvidia-smi` does not guarantee that the installed PyTorch build supports its architecture.
- The K620 is an older GPU; use CPU mode unless you have independently confirmed a compatible PyTorch/CUDA setup.
- Do not commit API keys, passwords, virtual environments, or unrelated large datasets.
- Before publishing, confirm that `ai1.py` expects the checkpoint filename `transferbest.pth` and that both files really exist at the repository root.
