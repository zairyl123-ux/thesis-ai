import os
import torch
import torch.nn as nn
from torchvision import models, transforms
from PIL import Image
import sys
from pathlib import Path

CIFAR_CLASSES = ['airplane', 'automobile', 'bird', 'cat', 'deer', 'dog', 'frog', 'horse', 'ship', 'truck']
IMAGE_SIZE = 224

def build_mobilenet_v2():
    model = models.mobilenet_v2(weights=None)
    in_features = model.classifier[1].in_features
    model.classifier[1] = nn.Linear(in_features, len(CIFAR_CLASSES))
    return model

class CIFAR10Predictor:
    def __init__(self, weights_path):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.model = build_mobilenet_v2()
        checkpoint = torch.load(weights_path, map_location=self.device)
        self.model.load_state_dict(checkpoint["model_state_dict"])
        self.model.to(self.device)
        self.model.eval()
        
        self.transform = transforms.Compose([
            transforms.Resize((IMAGE_SIZE, IMAGE_SIZE)),
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
        ])
        
    def predict(self, image_path):
        img = Image.open(image_path).convert("RGB")
        img_tensor = self.transform(img).unsqueeze(0).to(self.device)
        with torch.no_grad():
            outputs = self.model(img_tensor)
            probabilities = torch.nn.functional.softmax(outputs[0], dim=0)
            confidence, class_idx = torch.max(probabilities, 0)
        return CIFAR_CLASSES[class_idx.item()], confidence.item()


if __name__ == "__main__":
    # Cross-platform paths relative to this script
    BASE_DIR = Path(__file__).resolve().parent

    default_weights = BASE_DIR / "transferbest.pth"
    default_predict_folder = BASE_DIR / "predict_images"

    if len(sys.argv) == 1:
        print("Thesis AI - Image Predictor")
        print("Checking model weights...")

        if not default_weights.exists():
            print(f"ERROR: Model weights not found: {default_weights}")
            sys.exit(1)

        print(f"Loading model: {default_weights}")

        predictor = CIFAR10Predictor(str(default_weights))

        default_predict_folder.mkdir(exist_ok=True)

        supported = (".jpg", ".jpeg", ".png", ".bmp", ".webp")

        images = [
            p for p in default_predict_folder.iterdir()
            if p.suffix.lower() in supported
        ]

        if not images:
            print(f"No images found in {default_predict_folder}")
            print("Place JPG or PNG images inside predict_images.")
        else:
            print(f"Found {len(images)} images.")
            print()

            for img_path in images:
                label, conf = predictor.predict(img_path)
                print(
                    f"File: {img_path.name} -> "
                    f"Prediction: {label} "
                    f"({conf*100:.2f}% confidence)"
                )

    elif len(sys.argv) == 3:
        weights = Path(sys.argv[1])
        image = Path(sys.argv[2])

        predictor = CIFAR10Predictor(str(weights))
        label, conf = predictor.predict(str(image))

        print(
            f"File: {image.name} -> "
            f"Prediction: {label} "
            f"({conf*100:.2f}% confidence)"
        )

    else:
        print("Usage:")
        print("  python ai1.py")
        print("  python ai1.py <weights.pth> <image_path>")
