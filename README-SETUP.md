# Thesis AI — Setup Guide

## Windows

1. Install Python 3.10 or newer.
2. Run `install.bat`.
3. Choose Install / Update.
4. After setup, choose Launch.

The predictor starts in interactive mode when launched from a terminal.

### Drag-and-drop prediction

When you see:

```text
Image path >
```

Drag an image from File Explorer into the terminal and press Enter. The predicted CIFAR-10 class and confidence will be printed. The program then waits for another image.

Commands:
- `folder` — enter a directory and classify its images.
- `help` — show instructions.
- `q` — exit.

You can also paste a complete path. JPG, JPEG, PNG, BMP, and WEBP are supported.

## Linux

Run:

```bash
chmod +x install.sh
./install.sh
```

Then choose Launch. Drag-and-drop works in terminal emulators that paste dropped file paths into the prompt.

## Google Colab

Open `colab_setup.ipynb` and run its cells. For batch inference, place images in `predict_images/` and run the prediction cell. The interactive terminal prompt is intended for local terminals.

## Model checkpoint

The predictor expects `transferbest.pth` and a checkpoint containing `model_state_dict`. Do not rename or replace the checkpoint unless you have another compatible trained model.

## Troubleshooting

- **Checkpoint not found:** place `transferbest.pth` beside `ai1.py`.
- **Unsupported image:** use JPG, JPEG, PNG, BMP, or WEBP.
- **Path not found:** make sure the dropped path points to an existing file.
- **CUDA unavailable:** CPU inference is used automatically.
