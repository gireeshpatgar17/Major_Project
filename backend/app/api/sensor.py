from fastapi import APIRouter

from app.services.blynk_service import get_blynk_value
from app.schemas.sensor import SensorData


router = APIRouter(
    prefix="/sensors",
    tags=["Sensors"]
)


@router.get("/", response_model=SensorData)
def get_sensor_data():

    return {
        "soil_raw": int(float(get_blynk_value("V0"))),
        "soil_moisture": float(get_blynk_value("V1")),
        "temperature": float(get_blynk_value("V2")),
        "humidity": float(get_blynk_value("V3")),

        "rain_status": get_blynk_value("V4"),
        "water_status": get_blynk_value("V5"),
        "pump_status": get_blynk_value("V6"),

        "control_mode": int(float(get_blynk_value("V7"))),
        "manual_pump_request": int(float(get_blynk_value("V8"))),
        "rain_lockout": int(float(get_blynk_value("V9"))),
        "lockout_remaining_seconds": int(
            float(get_blynk_value("V10"))
        )
    }