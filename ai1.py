import argparse
import shlex
import sys
from pathlib import Path

import torch
import torch.nn as nn
from torchvision import models, transforms
from PIL import Image


# ==========================================
# CONFIGURATION
# ==========================================

CIFAR_CLASSES = [
    "airplane", "automobile", "bird", "cat", "deer",
    "dog", "frog", "horse", "ship", "truck"
]

IMAGE_SIZE = 224
SUPPORTED_IMAGE_TYPES = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}

BASE_DIR = Path(__file__).resolve().parent
DEFAULT_WEIGHTS = BASE_DIR / "transferbest.pth"
DEFAULT_IMAGE_DIR = BASE_DIR / "predict_images"


# ==========================================
# MODEL ARCHITECTURE
# Keep this compatible with the trained checkpoint.
# ==========================================

def build_mobilenet_v2():
    model = models.mobilenet_v2(weights=None)
    in_features = model.classifier[1].in_features
    model.classifier[1] = nn.Linear(in_features, len(CIFAR_CLASSES))
    return model


# ==========================================
# PREDICTOR
# ==========================================

class CIFAR10Predictor:
    def __init__(self, weights_path):
        self.device = torch.device(
            "cuda" if torch.cuda.is_available() else "cpu"
        )

        weights_path = Path(weights_path).expanduser().resolve()
        if not weights_path.is_file():
            raise FileNotFoundError(f"Model checkpoint not found: {weights_path}")

        print(f"Loading checkpoint: {weights_path}")
        print(f"Using device: {self.device}")

        self.model = build_mobilenet_v2()

        checkpoint = torch.load(
            weights_path,
            map_location=self.device,
            weights_only=False
        )

        if not isinstance(checkpoint, dict) or "model_state_dict" not in checkpoint:
            raise KeyError(
                "Checkpoint does not contain the expected 'model_state_dict' key."
            )

        self.model.load_state_dict(checkpoint["model_state_dict"])
        self.model.to(self.device)
        self.model.eval()

        self.transform = transforms.Compose([
            transforms.Resize((IMAGE_SIZE, IMAGE_SIZE)),
            transforms.ToTensor(),
            transforms.Normalize(
                mean=[0.485, 0.456, 0.406],
                std=[0.229, 0.224, 0.225]
            )
        ])

        print("Model loaded successfully!\n")

    def predict(self, image_path):
        image_path = Path(image_path).expanduser().resolve()

        if not image_path.is_file():
            raise FileNotFoundError(f"Image not found: {image_path}")

        with Image.open(image_path) as img:
            img = img.convert("RGB")
            img_tensor = self.transform(img).unsqueeze(0)

        img_tensor = img_tensor.to(self.device)

        with torch.inference_mode():
            outputs = self.model(img_tensor)
            probabilities = torch.softmax(outputs[0], dim=0)
            confidence, class_idx = torch.max(probabilities, dim=0)

        return CIFAR_CLASSES[class_idx.item()], confidence.item()


# ==========================================
# IMAGE PROCESSING
# ==========================================

def process_image(predictor, image_path):
    image_path = Path(image_path).expanduser().resolve()
    label, confidence = predictor.predict(image_path)

    print(
        f"{image_path.name:32} "
        f"{label:12} "
        f"{confidence * 100:6.2f}%"
    )


def process_folder(predictor, folder):
    folder = Path(folder).expanduser().resolve()

    if not folder.is_dir():
        print(f"Folder not found: {folder}")
        return

    images = sorted(
        path for path in folder.iterdir()
        if path.is_file() and path.suffix.lower() in SUPPORTED_IMAGE_TYPES
    )

    if not images:
        print(f"No supported images found in: {folder}")
        return

    print(f"\nFound {len(images)} image(s).\n")
    print(f"{'FILENAME':32} {'PREDICTION':12} CONFIDENCE")
    print("-" * 66)

    for image in images:
        try:
            process_image(predictor, image)
        except Exception as error:
            print(f"{image.name}: ERROR - {error}")


def parse_dropped_paths(raw_input):
    """Parse one or more paths pasted or dragged into the terminal."""
    try:
        parts = shlex.split(raw_input, posix=False)
    except ValueError:
        parts = [raw_input]

    paths = []
    for part in parts:
        part = part.strip().strip('"').strip("'")
        if part:
            paths.append(Path(part).expanduser())

    return paths


# ==========================================
# INTERACTIVE TERMINAL MODE
# ==========================================

def interactive_mode(predictor):
    print("Drag and drop an image file into this terminal, then press Enter.")
    print("You can also paste a full image path or drag in multiple images.")
    print("Commands: folder = scan a folder | help = show help | q = quit\n")

    while True:
        try:
            raw_input = input("Image path > ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nExiting Thesis AI.")
            break

        if not raw_input:
            continue

        command = raw_input.lower()

        if command in {"q", "quit", "exit"}:
            print("Exiting Thesis AI.")
            break

        if command == "help":
            print("Drag an image here and press Enter.")
            print("Type 'folder' to scan a folder, or 'q' to quit.\n")
            continue

        if command == "folder":
            folder_input = input("Folder path > ").strip()
            if folder_input:
                folder_paths = parse_dropped_paths(folder_input)
                if folder_paths:
                    process_folder(predictor, folder_paths[0])
            print()
            continue

        paths = parse_dropped_paths(raw_input)
        for path in paths:
            if path.is_dir():
                process_folder(predictor, path)
            elif path.is_file():
                try:
                    process_image(predictor, path)
                except Exception as error:
                    print(f"ERROR: {error}")
            else:
                print(f"Path not found: {path}")

        print()


# ==========================================
# MAIN
# ==========================================

def main():
    parser = argparse.ArgumentParser(
        description="Thesis AI - MobileNetV2 CIFAR-10 Predictor"
    )
    parser.add_argument(
        "--weights",
        default=str(DEFAULT_WEIGHTS),
        help="Path to model checkpoint"
    )
    parser.add_argument("--image", help="Predict one image")
    parser.add_argument(
        "--input-dir",
        default=str(DEFAULT_IMAGE_DIR),
        help="Folder containing images for batch prediction"
    )
    parser.add_argument(
        "--interactive",
        action="store_true",
        help="Start the drag-and-drop interactive terminal"
    )

    args = parser.parse_args()

    print("=" * 55)
    print("             THESIS AI PREDICTOR")
    print("=" * 55)

    try:
        predictor = CIFAR10Predictor(args.weights)

        if args.image:
            process_image(predictor, args.image)
        elif args.interactive or sys.stdin.isatty():
            interactive_mode(predictor)
        else:
            process_folder(predictor, args.input_dir)

    except Exception as error:
        print(f"\nERROR: {error}")
        sys.exit(1)


if __name__ == "__main__":
    main()
