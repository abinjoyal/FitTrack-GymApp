from ultralytics import YOLO

# correct model path
model = YOLO("runs/classify/train/weights/best.pt")

def detect_food(image):

    results = model(image)

    cls_id = int(results[0].probs.top1)

    confidence = float(results[0].probs.top1conf)

    name = model.names[cls_id]

    if confidence < 0.6:
        return None

    return name