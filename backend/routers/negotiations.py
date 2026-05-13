"""
routers/negotiations.py
-----------------------
Négociation de prix entre client et conducteur.

Fonctionnement :
1. Client crée une mission avec price_proposed
2. Conducteur fait une contre-offre (price_counter)
3. Client accepte ou fait une nouvelle offre
4. Accord → mission passe en accepted
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime

from database import get_db, Mission, PriceNegotiation, User
from schemas import NegotiationCreate, NegotiationOut
from auth import get_current_user

router = APIRouter(prefix="/negotiations", tags=["Négociations"])


@router.post("", response_model=NegotiationOut, status_code=201)
def make_offer(
    body: NegotiationCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Soumettre une offre de prix pour une mission.

    Le client ou le conducteur peut faire une offre.
    Si les deux parties ont soumis le même prix, la mission est acceptée.
    """
    mission = db.query(Mission).filter(Mission.id == body.mission_id).first()
    if not mission:
        raise HTTPException(status_code=404, detail="Mission introuvable")

    is_client = str(mission.client_id) == str(current_user.id)
    is_driver = str(mission.driver_id) == str(current_user.id)

    if not is_client and not is_driver:
        raise HTTPException(status_code=403, detail="Non autorisé")

    negotiation = PriceNegotiation(
        mission_id=body.mission_id,
        user_id=current_user.id,
        price=body.price,
        message=body.message,
    )
    db.add(negotiation)

    # Mise à jour du prix sur la mission
    if is_driver:
        mission.price_counter = body.price
        mission.status = "negotiating"
    else:
        mission.price_proposed = body.price

    # Accord automatique si même prix
    if mission.price_counter and abs(mission.price_proposed - mission.price_counter) < 0.01:
        mission.price_final = body.price
        mission.total = body.price * 1.1
        mission.commission = body.price * 0.1
        mission.status = "accepted"
        mission.accepted_at = datetime.utcnow()

    db.commit()
    db.refresh(negotiation)
    return negotiation


@router.post("/{mission_id}/accept", status_code=200)
def accept_price(
    mission_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Accepter le dernier prix proposé par l'autre partie."""
    mission = db.query(Mission).filter(Mission.id == mission_id).first()
    if not mission:
        raise HTTPException(status_code=404, detail="Mission introuvable")

    is_client = str(mission.client_id) == str(current_user.id)
    is_driver = str(mission.driver_id) == str(current_user.id)

    if not is_client and not is_driver:
        raise HTTPException(status_code=403, detail="Non autorisé")

    accepted_price = mission.price_counter if is_client else mission.price_proposed
    mission.price_final = accepted_price
    mission.total = accepted_price * 1.1
    mission.commission = accepted_price * 0.1
    mission.status = "accepted"
    mission.accepted_at = datetime.utcnow()

    db.commit()
    return {"message": "Prix accepté", "price_final": accepted_price}


@router.get("/{mission_id}", response_model=list[NegotiationOut])
def get_negotiations(
    mission_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Récupérer l'historique des négociations d'une mission."""
    return db.query(PriceNegotiation).filter(
        PriceNegotiation.mission_id == mission_id
    ).order_by(PriceNegotiation.created_at).all()
