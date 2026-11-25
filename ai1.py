
import sys
import argparse
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

BASE_DIR = Path(__file__).resolve().parent
DEFAULT_WEIGHTS = BASE_DIR / "transferbest.pth"
DEFAULT_IMAGE_DIR = BASE_DIR / "predict_images"


# ==========================================
# MODEL ARCHITECTURE
# ==========================================

def build_mobilenet_v2():
    model = models.mobilenet_v2(weights=None)

    in_features = model.classifier[1].in_features

    model.classifier[1] = nn.Linear(
        in_features,
        len(CIFAR_CLASSES)
    )

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
            raise FileNotFoundError(
                f"Model checkpoint not found: {weights_path}"
            )

        print(f"Loading checkpoint: {weights_path}")
        print(f"Using device: {self.device}")

        self.model = build_mobilenet_v2()

       checkpoint = torch.load(
    weights_path,
    map_location=self.device,
    weights_only=False
)

        if "model_state_dict" not in checkpoint:
            raise KeyError(
                "Checkpoint does not contain model_state_dict."
            )

        self.model.load_state_dict(
            checkpoint["model_state_dict"]
        )

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

        image_path = Path(image_path)

        if not image_path.is_file():
            raise FileNotFoundError(
                f"Image not found: {image_path}"
            )

        with Image.open(image_path) as img:
            img = img.convert("RGB")
            img_tensor = self.transform(img).unsqueeze(0)

        img_tensor = img_tensor.to(self.device)

        with torch.inference_mode():
            outputs = self.model(img_tensor)

            probabilities = torch.softmax(
                outputs[0],
                dim=0
            )

            confidence, class_idx = torch.max(
                probabilities,
                dim=0
            )

        return (
            CIFAR_CLASSES[class_idx.item()],
            confidence.item()
        )


# ==========================================
# IMAGE PROCESSING
# ==========================================

def process_image(predictor, image_path):

    label, confidence = predictor.predict(image_path)

    print(
        f"{Path(image_path).name:30} "
        f"{label:12} "
        f"{confidence * 100:6.2f}%"
    )


def process_folder(predictor, folder):

    folder = Path(folder).expanduser().resolve()

    folder.mkdir(parents=True, exist_ok=True)

    supported = {
        ".jpg", ".jpeg", ".png",
        ".bmp", ".webp"
    }

    images = sorted(
        p for p in folder.iterdir()
        if p.is_file() and p.suffix.lower() in supported
    )

    if not images:
        print(f"No supported images found in: {folder}")
        print("Place JPG or PNG images inside this folder.")
        return

    print(f"\nFound {len(images)} images.\n")

    print(f"{'FILENAME':30} {'PREDICTION':12} CONFIDENCE")
    print("-" * 65)

    for image in images:
        try:
            process_image(predictor, image)
        except Exception as error:
            print(f"{image.name}: ERROR - {error}")


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

    parser.add_argument(
        "--image",
        help="Predict one image"
    )

    parser.add_argument(
        "--input-dir",
        default=str(DEFAULT_IMAGE_DIR),
        help="Folder containing images for batch prediction"
    )

    args = parser.parse_args()

    print("=" * 55)
    print("             THESIS AI PREDICTOR")
    print("=" * 55)

    try:
        predictor = CIFAR10Predictor(args.weights)

        if args.image:
            process_image(predictor, args.image)
        else:
            process_folder(predictor, args.input_dir)

    except Exception as error:
        print(f"\nERROR: {error}")
        sys.exit(1)


if __name__ == "__main__":
    main()
