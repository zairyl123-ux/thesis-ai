# Thesis AI
### Lightweight Deep Learning for Image Classification

A cross-platform image classification project powered by **PyTorch and MobileNetV2**, trained on the CIFAR-10 dataset.

Thesis AI provides a reusable inference environment for Windows, Linux, and Google Colab.

## Overview

Thesis AI classifies images into the 10 CIFAR-10 categories:

airplane, automobile, bird, cat, deer, dog, frog, horse, ship, and truck.

## Features

- MobileNetV2 image classification.
- CIFAR-10 10-class output.
- Interactive drag-and-drop image prediction in terminal.
- Multiple images can be dropped or pasted in one input.
- Folder-based batch prediction.
- Windows, Linux, and Google Colab setup paths.
- CPU inference and compatible NVIDIA CUDA support.
- Uses the existing `transferbest.pth` checkpoint.

---

# Installation

## Windows

Requirements:
- Windows 10 or newer
- Python 3.10 or newer
- Internet connection

Download `install.bat` from this repository and run it, or use:

```powershell
curl.exe -fL https://raw.githubusercontent.com/zairyl123-ux/thesis-ai/main/install.bat -o install.bat
.\install.bat
```

## Linux

Requirements:
- Python 3.10 or newer
- `python3-venv`
- `curl`

```bash
curl -fL https://raw.githubusercontent.com/zairyl123-ux/thesis-ai/main/install.sh -o install.sh
chmod +x install.sh
./install.sh
```

## Google Colab

1. Open `colab_setup.ipynb` in Google Colab.
2. Select a GPU runtime if desired.
3. Run the setup cell.
4. Put test images in the `predict_images` directory.
5. Run the prediction cell.

---

# Usage

## Interactive drag-and-drop mode

Launch the program from the project directory:

```powershell
.venv\Scripts\python.exe ai1.py
```

When the prompt appears:

```text
Image path >
```

Drag an image from File Explorer into the terminal and press **Enter**. The program prints the predicted class and confidence, then waits for another image.

You can:
- Drag and drop one image.
- Drag and drop multiple images in one input.
- Paste a full image path.
- Type `folder` to scan a directory.
- Type `help` for the available commands.
- Type `q` to quit.

Supported image formats: JPG, JPEG, PNG, BMP, and WEBP.

## Batch prediction

Put images in `predict_images/` and run:

```powershell
.venv\Scripts\python.exe ai1.py --input-dir predict_images
```

## Single-image prediction

```powershell
.venv\Scripts\python.exe ai1.py --image "predict_images\test.jpg"
```

## Custom checkpoint

```powershell
python ai1.py --weights "path\to\model.pth"
```

---

# Project Structure

```text
thesis-ai/
├── ai1.py
├── transferbest.pth
├── requirements.txt
├── install.bat
├── install.sh
├── colab_setup.ipynb
├── README.md
├── README-SETUP.md
└── predict_images/
```

| File | Purpose |
|---|---|
| `ai1.py` | Predictor and interactive terminal |
| `transferbest.pth` | Trained MobileNetV2 checkpoint |
| `requirements.txt` | Python dependencies |
| `install.bat` | Windows installer |
| `install.sh` | Linux installer |
| `colab_setup.ipynb` | Colab setup notebook |
| `predict_images/` | Test image directory |

---

# Technical Information

| Setting | Value |
|---|---|
| Architecture | MobileNetV2 |
| Dataset | CIFAR-10 |
| Input size | 224 × 224 |
| Input channels | RGB |
| Output classes | 10 |
| Framework | PyTorch |
| Checkpoint | `transferbest.pth` |

The predictor keeps the MobileNetV2 classifier structure and checkpoint key expected by the existing trained model. The checkpoint file itself is not modified by this update.

## Notes

- CUDA support depends on the installed PyTorch build, GPU architecture, and NVIDIA driver.
- Older GPUs may need CPU inference.
- Confidence is the model's softmax score; it is not a guarantee that a prediction is correct.
- Keep the checkpoint in the same directory as `ai1.py`, unless you specify another path with `--weights`.

## Repository

[zairyl123-ux/thesis-ai](https://github.com/zairyl123-ux/thesis-ai)
