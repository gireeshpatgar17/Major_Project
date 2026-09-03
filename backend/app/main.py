from fastapi import FastAPI

from app.database import supabase
from app.api.farm import router as farm_router
from app.api.irrigation import router as irrigation_router
from app.api.disease import router as disease_router
from app.api.sensor import router as sensor_router

app = FastAPI(
    title="Smart Agriculture API",
    version="1.0.0"
)


app.include_router(farm_router)
app.include_router(irrigation_router)
app.include_router(disease_router)
app.include_router(sensor_router)

@app.get("/")
def root():
    return {
        "message": "Smart Agriculture API is running"
    }


@app.get("/test-supabase")
def test_supabase():
    response = supabase.table("farms").select("*").execute()

    return {
        "message": "Supabase connection successful",
        "farms": response.data
    }