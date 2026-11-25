# Thesis AI
### Lightweight Deep Learning for Image Classification

A cross-platform image classification project powered by **PyTorch and MobileNetV2**, trained on the CIFAR-10 dataset.

Thesis AI provides a reusable inference environment with automated installation for Windows, Linux, and Google Colab.

---

## Overview

Thesis AI uses MobileNetV2 to classify images into 10 CIFAR-10 categories.

The project is designed to make model deployment and testing accessible across different computing environments, including machines with limited hardware resources.

### Supported classification categories

| Class | Class | Class |
|---|---|---|
| Airplane | Automobile | Bird |
| Cat | Deer | Dog |
| Frog | Horse | Ship |
| Truck | | |

## Features

- **MobileNetV2 architecture** – Lightweight convolutional neural network.
- **CIFAR-10 classification** – Supports 10 image categories.
- **Cross-platform support** – Windows, Linux, and Google Colab.
- **Automatic environment setup** – Virtual environment and dependency installation.
- **CPU and CUDA support** – Selectable PyTorch installation on local machines.
- **Batch image prediction** – Process multiple images from a folder.
- **Custom image inference** – Predict individual JPG, PNG, and other supported image formats.
- **GitHub distribution** – Download project files directly from the repository.

---

# Installation

Choose the installation method for your environment.

## 1. Windows (CMD / PowerShell)

**Requirements**
- Windows 10 or newer
- Python 3.10 or newer
- Internet connection

Open PowerShell or Command Prompt and execute:

```powershell
curl.exe -fL https://raw.githubusercontent.com/zairyl123-ux/thesis-ai/main/install.bat -o install.bat
.\install.bat
```

The installer will:

1. Check your Python installation.
2. Create an isolated Python virtual environment.
3. Check required dependencies.
4. Ask permission before installing missing packages.
5. Let you select CPU or NVIDIA CUDA installation.
6. Download the project files.
7. Verify PyTorch and available GPU hardware.
8. Offer to launch Thesis AI.

## 2. Linux

**Requirements**
- Python 3.10 or newer
- `python3-venv`
- `curl`
- Internet connection

Clone or download the installer from the repository:

```bash
curl -fL https://raw.githubusercontent.com/zairyl123-ux/thesis-ai/main/install.sh -o install.sh
chmod +x install.sh
./install.sh
```

The installer creates an isolated `.venv` environment and downloads the required project files.

## 3. Google Colab

Google Colab provides a cloud-based Python environment with optional GPU acceleration.

1. Open `colab_setup.ipynb` from this repository.
2. Open it using Google Colab.
3. Select **Runtime → Change runtime type**.
4. Select an available GPU if desired.
5. Run the setup cell.
6. Run the prediction cell.

Colab uses its existing PyTorch installation where available rather than replacing it unnecessarily.

---

# Usage

## Default batch prediction

After installation, place your images inside:

```text
thesis-ai/
└── predict_images/
    ├── image1.jpg
    ├── image2.png
    └── image3.jpg
```

Run:

```bash
python ai1.py
```

The application automatically loads `transferbest.pth` and processes supported images in the prediction directory.

## Single-image prediction

You can also classify an individual image:

```bash
python ai1.py --image predict_images/test.jpg
```

## Custom model checkpoint

To use another compatible checkpoint:

```bash
python ai1.py --weights another_model.pth
```

## Custom input directory

```bash
python ai1.py --input-dir my_images
```

---

# Project Structure

```text
thesis-ai/
│
├── README.md
├── README-SETUP.md
├── requirements.txt
│
├── ai1.py
├── install.bat
├── install.sh
├── colab_setup.ipynb
│
├── transferbest.pth
│
└── predict_images/
```

| File | Description |
|---|---|
| `ai1.py` | Main image classification application |
| `transferbest.pth` | Trained MobileNetV2 checkpoint |
| `requirements.txt` | Additional Python dependencies |
| `install.bat` | Windows installer |
| `install.sh` | Linux installer |
| `colab_setup.ipynb` | Google Colab setup notebook |
| `predict_images/` | Directory for custom prediction images |

---

# Technical Information

### Model Architecture

**MobileNetV2**

MobileNetV2 is a lightweight convolutional neural network architecture designed for efficient image recognition.

### Dataset

**CIFAR-10**

The CIFAR-10 dataset contains 60,000 color images divided into 10 categories.

- 50,000 training images
- 10,000 test images
- 10 classification categories
- Original image resolution: 32 × 32 pixels

### Inference Configuration

| Configuration | Value |
|---|---|
| Architecture | MobileNetV2 |
| Input resolution | 224 × 224 |
| Input channels | RGB (3) |
| Output classes | 10 |
| Normalization | ImageNet mean and standard deviation |
| Framework | PyTorch |
| Deployment format | PyTorch checkpoint (`.pth`) |

---

# Hardware Compatibility

Thesis AI supports CPU inference and compatible NVIDIA CUDA environments.

| Environment | Support |
|---|---|
| CPU | Supported |
| Compatible NVIDIA GPU | Supported |
| Google Colab GPU | Supported |
| Older NVIDIA GPUs | Compatibility varies |

**Note:** CUDA availability depends on the GPU architecture, NVIDIA driver, and installed PyTorch build. Having an NVIDIA graphics card does not automatically guarantee CUDA compatibility.

For CUDA installation options, consult the official [PyTorch installation guide](https://pytorch.org/get-started/locally/).

---

# Dependencies

The project uses:

- PyTorch
- Torchvision
- NumPy
- Pandas
- Matplotlib
- Pillow
- ONNX
- ONNX Script

PyTorch and Torchvision are installed separately by the local installers to allow CPU or CUDA selection.

---

# Troubleshooting

### Python not found

Install Python 3.10 or newer from:

https://www.python.org/downloads/

Make sure Python is added to your system PATH.

### Model checkpoint not found

Ensure that `transferbest.pth` is located in the same directory as `ai1.py`, or specify another checkpoint using `--weights`.

### CUDA unavailable

Check your NVIDIA driver and PyTorch installation. If CUDA is unsupported, use CPU inference.

### Missing dependencies

Activate your project's virtual environment and install the requirements:

**Windows:**

```powershell
.venv\Scripts\activate
pip install -r requirements.txt
```

**Linux:**

```bash
source .venv/bin/activate
pip install -r requirements.txt
```

---

# License and Project Information

**Project:** Thesis AI  
**Repository:** [zairyl123-ux/thesis-ai](https://github.com/zairyl123-ux/thesis-ai)

Developed as part of an academic thesis project exploring lightweight deep learning and image classification.

---

*Thesis AI — Lightweight AI. Cross-platform deployment.*
