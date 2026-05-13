"""
database.py
-----------
Modèles SQLAlchemy pour Waka — Transport & Missions au Gabon.

Améliorations africaines :
- Champ landmark (point de repère) en plus de l'adresse
- Mobile Money (Airtel Money, Moov Money) comme paiements principaux
- Mototaxi comme type de service
- Négociation de prix client/conducteur
- Mode hors-ligne : timestamp de synchronisation
- Langue préférée de l'utilisateur
"""

from sqlalchemy import (
    create_engine, Column, String, Integer,
    Float, Boolean, DateTime, Text, ForeignKey
)
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from datetime import datetime
import uuid

SQLALCHEMY_DATABASE_URL = "sqlite:///./waka.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False}
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def generate_id():
    return str(uuid.uuid4())


# ── MODÈLES ───────────────────────────────────────────────────────────────────

class User(Base):
    """Utilisateur Waka — client ou conducteur."""

    __tablename__ = "users"

    id             = Column(String, primary_key=True, default=generate_id)
    first_name     = Column(String, nullable=False)
    last_name      = Column(String, nullable=False)
    email          = Column(String, unique=True, nullable=False, index=True)
    phone          = Column(String, nullable=False)
    country        = Column(String, default="Gabon")
    city           = Column(String, default="Libreville")
    language       = Column(String, default="fr")   # fr | en
    password       = Column(String, nullable=False)
    role           = Column(String, default="client")   # client | driver
    avatar         = Column(String, nullable=True)
    rating         = Column(Float, default=0.0)
    total_missions = Column(Integer, default=0)
    is_active      = Column(Boolean, default=True)
    created_at     = Column(DateTime, default=datetime.utcnow)
    last_seen_at   = Column(DateTime, default=datetime.utcnow)

    # Champs conducteur
    vehicle_type   = Column(String, nullable=True)   # car | moto | tricycle | van
    vehicle_brand  = Column(String, nullable=True)
    vehicle_model  = Column(String, nullable=True)
    vehicle_color  = Column(String, nullable=True)
    vehicle_plate  = Column(String, nullable=True)
    is_certified   = Column(Boolean, default=False)
    is_online      = Column(Boolean, default=False)

    # Relations
    missions_as_client = relationship(
        "Mission", foreign_keys="Mission.client_id", back_populates="client"
    )
    missions_as_driver = relationship(
        "Mission", foreign_keys="Mission.driver_id", back_populates="driver"
    )
    ratings_given    = relationship("Rating", foreign_keys="Rating.rater_id", back_populates="rater")
    ratings_received = relationship("Rating", foreign_keys="Rating.rated_id", back_populates="rated")


class Mission(Base):
    """Mission de transport ou service — cœur de l'application."""

    __tablename__ = "missions"

    id          = Column(String, primary_key=True, default=generate_id)
    client_id   = Column(String, ForeignKey("users.id"), nullable=False)
    driver_id   = Column(String, ForeignKey("users.id"), nullable=True)

    # Type de service — ajout mototaxi et tricycle
    service     = Column(String, nullable=False)
    # transport | mototaxi | livraison | colis | courses | depot | tricycle

    status      = Column(String, default="pending")
    # pending | negotiating | accepted | in_progress | completed | cancelled

    # Adresses avec points de repère (réalité africaine)
    from_addr      = Column(String, nullable=False)
    from_landmark  = Column(String, nullable=True)   # ex: "Près du marché Mont-Bouët"
    to_addr        = Column(String, nullable=False)
    to_landmark    = Column(String, nullable=True)   # ex: "Face à la pharmacie Beauséjour"

    # Coordonnées GPS (optionnelles — réseau parfois absent)
    from_lat    = Column(Float, nullable=True)
    from_lng    = Column(Float, nullable=True)
    to_lat      = Column(Float, nullable=True)
    to_lng      = Column(Float, nullable=True)

    description = Column(Text, nullable=True)

    # Prix — système de négociation
    price_proposed  = Column(Float, nullable=False)   # Prix proposé par le client
    price_counter   = Column(Float, nullable=True)    # Contre-offre du conducteur
    price_final     = Column(Float, nullable=True)    # Prix accepté
    commission      = Column(Float, nullable=False)
    total           = Column(Float, nullable=False)

    # Paiements adaptés au Gabon
    payment     = Column(String, default="airtel_money")
    # airtel_money | moov_money | cash | card | wave

    scheduled   = Column(String, default="now")
    created_at  = Column(DateTime, default=datetime.utcnow)
    accepted_at = Column(DateTime, nullable=True)
    completed_at = Column(DateTime, nullable=True)

    # Synchronisation hors-ligne
    synced_at   = Column(DateTime, nullable=True)

    # Relations
    client  = relationship("User", foreign_keys=[client_id], back_populates="missions_as_client")
    driver  = relationship("User", foreign_keys=[driver_id], back_populates="missions_as_driver")
    ratings = relationship("Rating", back_populates="mission")
    messages = relationship("Message", back_populates="mission")
    negotiations = relationship("PriceNegotiation", back_populates="mission")


class PriceNegotiation(Base):
    """Historique des négociations de prix pour une mission."""

    __tablename__ = "price_negotiations"

    id          = Column(String, primary_key=True, default=generate_id)
    mission_id  = Column(String, ForeignKey("missions.id"), nullable=False)
    user_id     = Column(String, ForeignKey("users.id"), nullable=False)
    price       = Column(Float, nullable=False)
    message     = Column(Text, nullable=True)
    created_at  = Column(DateTime, default=datetime.utcnow)

    mission = relationship("Mission", back_populates="negotiations")


class Rating(Base):
    """Note laissée après une mission."""

    __tablename__ = "ratings"

    id          = Column(String, primary_key=True, default=generate_id)
    mission_id  = Column(String, ForeignKey("missions.id"), nullable=False)
    rater_id    = Column(String, ForeignKey("users.id"), nullable=False)
    rated_id    = Column(String, ForeignKey("users.id"), nullable=False)
    stars       = Column(Integer, nullable=False)
    compliments = Column(String, nullable=True)
    comment     = Column(Text, nullable=True)
    created_at  = Column(DateTime, default=datetime.utcnow)

    mission = relationship("Mission", back_populates="ratings")
    rater   = relationship("User", foreign_keys=[rater_id], back_populates="ratings_given")
    rated   = relationship("User", foreign_keys=[rated_id], back_populates="ratings_received")


class Message(Base):
    """Message entre client et conducteur pendant une mission."""

    __tablename__ = "messages"

    id          = Column(String, primary_key=True, default=generate_id)
    mission_id  = Column(String, ForeignKey("missions.id"), nullable=False)
    sender_id   = Column(String, ForeignKey("users.id"), nullable=False)
    content     = Column(Text, nullable=False)
    is_read     = Column(Boolean, default=False)
    created_at  = Column(DateTime, default=datetime.utcnow)

    mission = relationship("Mission", back_populates="messages")


def create_tables():
    Base.metadata.create_all(bind=engine)
