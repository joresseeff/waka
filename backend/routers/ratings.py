from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db, User, Mission, Rating, Message
from schemas import RatingCreate, RatingOut, MessageCreate, MessageOut
from auth import get_current_user
from typing import List

# ── RATINGS ───────────────────────────────────────────────────────────────────

rating_router = APIRouter(prefix="/ratings", tags=["Notation"])

@rating_router.post("/", response_model=RatingOut, summary="Noter après mission")
def create_rating(
    data: RatingCreate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    mission = db.query(Mission).filter(Mission.id == data.mission_id).first()
    if not mission:
        raise HTTPException(status_code=404, detail="Mission introuvable")
    if mission.status != "completed":
        raise HTTPException(status_code=400, detail="La mission doit être terminée pour noter")
    if mission.client_id != user.id and mission.driver_id != user.id:
        raise HTTPException(status_code=403, detail="Vous ne faites pas partie de cette mission")
    existing = db.query(Rating).filter(
        Rating.mission_id == data.mission_id,
        Rating.rater_id == user.id
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="Vous avez déjà noté cette mission")
    if not 1 <= data.stars <= 5:
        raise HTTPException(status_code=400, detail="La note doit être entre 1 et 5")

    rating = Rating(
        mission_id=data.mission_id,
        rater_id=user.id,
        rated_id=data.rated_id,
        stars=data.stars,
        compliments=data.compliments,
        comment=data.comment,
    )
    db.add(rating)

    # Recalculate average rating for rated user
    rated_user = db.query(User).filter(User.id == data.rated_id).first()
    if rated_user:
        all_ratings = db.query(Rating).filter(Rating.rated_id == data.rated_id).all()
        total_stars = sum(r.stars for r in all_ratings) + data.stars
        rated_user.rating = round(total_stars / (len(all_ratings) + 1), 1)

    db.commit()
    db.refresh(rating)
    return rating

@rating_router.get("/user/{user_id}", response_model=List[RatingOut], summary="Avis d'un utilisateur")
def get_user_ratings(
    user_id: str,
    db: Session = Depends(get_db),
    _: User = Depends(get_current_user)
):
    return db.query(Rating).filter(Rating.rated_id == user_id).order_by(Rating.created_at.desc()).all()

# ── MESSAGES ──────────────────────────────────────────────────────────────────

message_router = APIRouter(prefix="/messages", tags=["Messages"])

@message_router.post("/", response_model=MessageOut, summary="Envoyer un message")
def send_message(
    data: MessageCreate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    mission = db.query(Mission).filter(Mission.id == data.mission_id).first()
    if not mission:
        raise HTTPException(status_code=404, detail="Mission introuvable")
    if mission.client_id != user.id and mission.driver_id != user.id:
        raise HTTPException(status_code=403, detail="Accès refusé")
    msg = Message(mission_id=data.mission_id, sender_id=user.id, content=data.content)
    db.add(msg)
    db.commit()
    db.refresh(msg)
    return msg

@message_router.get("/{mission_id}", response_model=List[MessageOut], summary="Messages d'une mission")
def get_messages(
    mission_id: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    mission = db.query(Mission).filter(Mission.id == mission_id).first()
    if not mission:
        raise HTTPException(status_code=404, detail="Mission introuvable")
    if mission.client_id != user.id and mission.driver_id != user.id:
        raise HTTPException(status_code=403, detail="Accès refusé")
    return db.query(Message).filter(Message.mission_id == mission_id).order_by(Message.created_at).all()
