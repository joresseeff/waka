"""
main.py
-------
Point d'entrée de l'API Waka — Transport & Missions au Gabon.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os

from database import create_tables
from routers.auth import router as auth_router
from routers.users import router as users_router
from routers.missions import router as missions_router
from routers.ratings import rating_router, message_router
from routers.negotiations import router as negotiation_router

app = FastAPI(
    title="Waka API",
    description="API complète pour Waka — Transport & Missions au Gabon 🇬🇦",
    version="2.0.0",
    docs_url="/api/docs",
    redoc_url="/api/redoc",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router,        prefix="/api")
app.include_router(users_router,       prefix="/api")
app.include_router(missions_router,    prefix="/api")
app.include_router(rating_router,      prefix="/api")
app.include_router(message_router,     prefix="/api")
app.include_router(negotiation_router, prefix="/api")


@app.on_event("startup")
def startup():
    create_tables()
    print("✅ Waka API démarrée")
    print("📖 Docs : http://localhost:8000/api/docs")


@app.get("/api/health", tags=["Système"])
def health():
    return {"status": "ok", "app": "Waka API", "version": "2.0.0", "pays": "Gabon 🇬🇦"}
