from fastapi import FastAPI, UploadFile, File
import numpy as np
import cv2

from food_detector import detect_food
from nutrition_db import food_db

app = FastAPI()


@app.post("/analyze-food")
async def analyze_food(file: UploadFile = File(...)):

    contents = await file.read()

    # Convert image bytes → numpy
    nparr = np.frombuffer(contents, np.uint8)
    image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    # If image decode failed
    if image is None:
        return {
            "food": None,
            "foods": []
        }

    # Detect food
    food = detect_food(image)

    # If AI couldn't detect food
    if not food:
        return {
            "food": None,
            "foods": []
        }

    # Convert to lowercase for DB lookup
    food_key = food.lower()

    # If food not in nutrition database
    if food_key not in food_db:
        return {
            "food": None,
            "foods": []
        }

    nutrition = food_db[food_key]

    return {
        "food": food,
        "protein": nutrition.get("protein", 0),
        "carbs": nutrition.get("carbs", 0),
        "calories": nutrition.get("calories", 0)
    }