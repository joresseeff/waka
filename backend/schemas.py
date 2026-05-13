"""
schemas.py
----------
Schémas Pydantic pour l'API Waka.
"""

from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime


# ── AUTH ──────────────────────────────────────────────────────────────────────

class RegisterRequest(BaseModel):
    first_name: str
    last_name: str
    email: EmailStr
    phone: str
    country: str = "Gabon"
    city: str = "Libreville"
    language: str = "fr"
    password: str
    role: str = "client"


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: "UserOut"


# ── USER ──────────────────────────────────────────────────────────────────────

class UserOut(BaseModel):
    id: str
    first_name: str
    last_name: str
    email: str
    phone: str
    country: str
    city: str
    language: str
    role: str
    rating: float
    total_missions: int
    is_certified: bool
    is_online: bool
    vehicle_type: Optional[str]
    vehicle_brand: Optional[str]
    vehicle_model: Optional[str]
    vehicle_color: Optional[str]
    vehicle_plate: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True


class DriverOut(BaseModel):
    id: str
    first_name: str
    last_name: str
    phone: str
    rating: float
    total_missions: int
    is_certified: bool
    is_online: bool
    vehicle_type: Optional[str]
    vehicle_brand: Optional[str]
    vehicle_model: Optional[str]
    vehicle_color: Optional[str]
    vehicle_plate: Optional[str]

    class Config:
        from_attributes = True


class UpdateDriverProfile(BaseModel):
    vehicle_type: Optional[str]
    vehicle_brand: Optional[str]
    vehicle_model: Optional[str]
    vehicle_color: Optional[str]
    vehicle_plate: Optional[str]


class UpdateOnlineStatus(BaseModel):
    is_online: bool


# ── MISSION ───────────────────────────────────────────────────────────────────

class MissionCreate(BaseModel):
    service: str
    from_addr: str
    from_landmark: Optional[str] = None
    to_addr: str
    to_landmark: Optional[str] = None
    from_lat: Optional[float] = None
    from_lng: Optional[float] = None
    to_lat: Optional[float] = None
    to_lng: Optional[float] = None
    description: Optional[str] = None
    price_proposed: float
    payment: str = "airtel_money"
    scheduled: str = "now"
    driver_id: Optional[str] = None


class MissionOut(BaseModel):
    id: str
    service: str
    status: str
    from_addr: str
    from_landmark: Optional[str]
    to_addr: str
    to_landmark: Optional[str]
    description: Optional[str]
    price_proposed: float
    price_counter: Optional[float]
    price_final: Optional[float]
    commission: float
    total: float
    payment: str
    scheduled: str
    created_at: datetime
    accepted_at: Optional[datetime]
    completed_at: Optional[datetime]
    client: Optional[DriverOut]
    driver: Optional[DriverOut]

    class Config:
        from_attributes = True


class MissionStatusUpdate(BaseModel):
    status: str


# ── NÉGOCIATION ───────────────────────────────────────────────────────────────

class NegotiationCreate(BaseModel):
    mission_id: str
    price: float
    message: Optional[str] = None


class NegotiationOut(BaseModel):
    id: str
    mission_id: str
    user_id: str
    price: float
    message: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True


# ── RATING ────────────────────────────────────────────────────────────────────

class RatingCreate(BaseModel):
    mission_id: str
    rated_id: str
    stars: int
    compliments: Optional[str] = None
    comment: Optional[str] = None


class RatingOut(BaseModel):
    id: str
    stars: int
    compliments: Optional[str]
    comment: Optional[str]
    created_at: datetime
    rater: Optional[DriverOut]

    class Config:
        from_attributes = True


# ── MESSAGE ───────────────────────────────────────────────────────────────────

class MessageCreate(BaseModel):
    mission_id: str
    content: str


class MessageOut(BaseModel):
    id: str
    mission_id: str
    sender_id: str
    content: str
    is_read: bool
    created_at: datetime

    class Config:
        from_attributes = True


Token.model_rebuild()
