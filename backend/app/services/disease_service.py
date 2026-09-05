import os

import numpy as np
from PIL import Image
import keras


# ==========================================================
# MODEL
# ==========================================================

MODEL_PATH = os.path.abspath(
    os.path.join(
        os.path.dirname(__file__),
        "..",
        "..",
        "models",
        "FinalTest_inceptionv3.h5",
    )
)

CLASS_NAMES = [
    "Brown Spot",
    "Healthy",
    "Leaf Blast",
    "Sheath Blight",
]


_model = None


def get_model():
    """
    Load the disease detection model once and reuse it.
    """
    global _model

    if _model is None:
        _model = keras.models.load_model(
            MODEL_PATH,
            compile=False,
        )

    return _model


# ==========================================================
# IMAGE PREPROCESSING
# ==========================================================

def preprocess_image(image_bytes: bytes):
    """
    Convert uploaded image bytes into the format expected
    by the InceptionV3 model.
    """

    image = Image.open(
        __import__("io").BytesIO(image_bytes)
    ).convert("RGB")

    image = image.resize((224, 224))

    image_array = np.array(image, dtype=np.float32)

    # Same normalization used by the old AI backend:
    # [0, 255] -> [-1, 1]
    image_array = (image_array / 127.5) - 1.0

    image_array = np.expand_dims(image_array, axis=0)

    return image_array


# ==========================================================
# PREDICTION
# ==========================================================

def predict_disease(image_bytes: bytes):
    """
    Run disease prediction on an image.

    Returns:
        disease_name
        confidence
        scale
        all_predictions
    """

    model = get_model()

    image = preprocess_image(image_bytes)

    outputs = model.predict(
        image,
        verbose=0,
    )

    # The model has two outputs:
    #
    # output[0] -> disease classification
    # output[1] -> disease scale/severity
    disease_predictions = outputs[0]
    scale_predictions = outputs[1]

    disease_predictions = np.asarray(
        disease_predictions
    )

    scale_predictions = np.asarray(
        scale_predictions
    )

    predicted_index = int(
        np.argmax(disease_predictions[0])
    )

    confidence = float(
        disease_predictions[0][predicted_index]
    )

    disease_name = CLASS_NAMES[predicted_index]

    scale = float(
        scale_predictions[0][0]
    )

    all_predictions = {
        CLASS_NAMES[i]: float(disease_predictions[0][i])
        for i in range(len(CLASS_NAMES))
    }

    return {
        "disease": disease_name,
        "confidence": confidence,
        "scale": scale,
        "all_predictions": all_predictions,
    }