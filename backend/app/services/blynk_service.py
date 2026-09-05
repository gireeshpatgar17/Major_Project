import os
import requests
from dotenv import load_dotenv

load_dotenv()

BLYNK_SERVER = os.getenv("BLYNK_SERVER")
BLYNK_TOKEN = os.getenv("BLYNK_TOKEN")


def get_blynk_value(pin: str):
    url = f"{BLYNK_SERVER}/external/api/get?token={BLYNK_TOKEN}&{pin}"

    response = requests.get(
        url,
        timeout=10
    )

    response.raise_for_status()

    return response.text


def update_blynk_value(pin: str, value):
    url = f"{BLYNK_SERVER}/external/api/update"

    response = requests.get(
        url,
        params={
            "token": BLYNK_TOKEN,
            pin: value
        },
        timeout=10
    )

    response.raise_for_status()

    return response.text