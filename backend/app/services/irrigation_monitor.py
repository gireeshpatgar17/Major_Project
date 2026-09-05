import asyncio
from datetime import datetime, timezone

from app.services.blynk_service import get_blynk_value
from app.database import supabase


# ============================================================
# CONFIGURATION
# ============================================================

FARM_ID = 1
CHECK_INTERVAL_SECONDS = 2


# ============================================================
# CURRENT IRRIGATION STATE
# ============================================================

previous_pump_status = None
active_irrigation = None


# ============================================================
# READ BLYNK PUMP STATUS
# ============================================================

def get_pump_status():
    """
    Read only the pump status from Blynk.
    V6 = Pump Status
    """
    return get_blynk_value("V6").strip().upper()


# ============================================================
# READ SENSOR SNAPSHOT
# ============================================================

def get_sensor_snapshot():
    """
    Read all values needed when irrigation starts.
    """

    return {
        "soil_raw": int(float(get_blynk_value("V0"))),
        "soil_moisture": float(get_blynk_value("V1")),
        "temperature": float(get_blynk_value("V2")),
        "humidity": float(get_blynk_value("V3")),

        "rain_status": get_blynk_value("V4"),
        "water_status": get_blynk_value("V5"),

        "control_mode": int(float(get_blynk_value("V7"))),
    }


# ============================================================
# START IRRIGATION
# ============================================================

def start_irrigation(snapshot):
    global active_irrigation

    if snapshot["control_mode"] == 0:
        mode = "AUTO"
        trigger_reason = "Automatic irrigation"
    else:
        mode = "MANUAL"
        trigger_reason = "Manual irrigation"

    active_irrigation = {
        "farm_id": FARM_ID,

        "start_time": datetime.now(timezone.utc),

        "mode": mode,
        "trigger_reason": trigger_reason,

        "soil_moisture_at_start":
            snapshot["soil_moisture"],

        "soil_raw_at_start":
            snapshot["soil_raw"],

        "temperature_at_start":
            snapshot["temperature"],

        "humidity_at_start":
            snapshot["humidity"],

        "rain_detected_at_start":
            snapshot["rain_status"].strip().upper() == "RAIN",

        "water_available_at_start":
            snapshot["water_status"].strip().upper() == "AVAILABLE",
    }

    print()
    print("========================================")
    print("IRRIGATION STARTED")
    print("========================================")
    print(f"Farm: {FARM_ID}")
    print(f"Mode: {mode}")
    print(f"Trigger: {trigger_reason}")
    print(f"Soil moisture: {snapshot['soil_moisture']}")
    print(f"Soil raw: {snapshot['soil_raw']}")
    print(f"Temperature: {snapshot['temperature']}")
    print(f"Humidity: {snapshot['humidity']}")
    print(f"Rain: {snapshot['rain_status']}")
    print(f"Water: {snapshot['water_status']}")
    print("========================================")
    print()


# ============================================================
# END IRRIGATION
# ============================================================

def end_irrigation():
    global active_irrigation

    if active_irrigation is None:
        return

    end_time = datetime.now(timezone.utc)

    start_time = active_irrigation["start_time"]

    duration_seconds = (
        end_time - start_time
    ).total_seconds()

    duration_minutes = duration_seconds / 60.0

    data = {
        "farm_id": active_irrigation["farm_id"],

        "start_time": start_time.isoformat(),
        "end_time": end_time.isoformat(),

        "duration_minutes": duration_minutes,

        "mode": active_irrigation["mode"],
        "trigger_reason": active_irrigation["trigger_reason"],

        "soil_moisture_at_start":
            active_irrigation["soil_moisture_at_start"],

        "soil_raw_at_start":
            active_irrigation["soil_raw_at_start"],

        "temperature_at_start":
            active_irrigation["temperature_at_start"],

        "humidity_at_start":
            active_irrigation["humidity_at_start"],

        "rain_detected_at_start":
            active_irrigation["rain_detected_at_start"],

        "water_available_at_start":
            active_irrigation["water_available_at_start"],
    }

    try:
        response = (
            supabase
            .table("irrigation_history")
            .insert(data)
            .execute()
        )

        print()
        print("========================================")
        print("IRRIGATION ENDED")
        print("========================================")
        print(f"Duration: {duration_minutes:.2f} minutes")
        print("Irrigation event saved to database")
        print("========================================")
        print()

    except Exception as e:

        print()
        print("========================================")
        print("ERROR SAVING IRRIGATION EVENT")
        print("========================================")
        print(e)
        print("========================================")
        print()

    active_irrigation = None


# ============================================================
# MAIN MONITOR
# ============================================================

async def monitor_irrigation():
    global previous_pump_status

    print("========================================")
    print("IRRIGATION MONITOR STARTED")
    print("========================================")

    while True:

        try:
            # --------------------------------------------
            # Only read V6 during normal monitoring
            # --------------------------------------------

            current_pump_status = get_pump_status()

            # --------------------------------------------
            # First reading
            # --------------------------------------------

            if previous_pump_status is None:

                previous_pump_status = current_pump_status

                print(
                    f"Initial pump status: "
                    f"{current_pump_status}"
                )

            # --------------------------------------------
            # OFF → ON
            # --------------------------------------------

            elif (
                previous_pump_status == "OFF"
                and current_pump_status == "ON"
            ):

                print(
                    "Pump transition detected: OFF → ON"
                )

                snapshot = get_sensor_snapshot()

                if active_irrigation is None:
                    start_irrigation(snapshot)

            # --------------------------------------------
            # ON → OFF
            # --------------------------------------------

            elif (
                previous_pump_status == "ON"
                and current_pump_status == "OFF"
            ):

                print(
                    "Pump transition detected: ON → OFF"
                )

                if active_irrigation is not None:
                    end_irrigation()

            # --------------------------------------------
            # Remember current state
            # --------------------------------------------

            previous_pump_status = current_pump_status

        except Exception as e:

            print(
                f"Irrigation monitor error: {e}"
            )

        await asyncio.sleep(
            CHECK_INTERVAL_SECONDS
        )