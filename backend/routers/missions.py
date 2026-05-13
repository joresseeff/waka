from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db, User, Mission
from schemas import MissionCreate, MissionOut, MissionStatusUpdate
from auth import get_current_user, require_driver
from datetime import datetime
from typing import List, Optional

router = APIRouter(prefix="/missions", tags=["Missions"])

COMMISSION_RATE = 0.20

@router.post("/", response_model=MissionOut, summary="Créer une mission")
def create_mission(
    data: MissionCreate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    commission = round(data.price * COMMISSION_RATE, 2)
    total = round(data.price + commission, 2)
    mission = Mission(
        client_id=user.id,
        driver_id=data.driver_id,
        service=data.service,
        from_addr=data.from_addr,
        to_addr=data.to_addr,
        description=data.description,
        price=data.price,
        commission=commission,
        total=total,
        payment=data.payment,
        scheduled=data.scheduled,
        status="pending" if not data.driver_id else "accepted",
        accepted_at=datetime.utcnow() if data.driver_id else None,
    )
    db.add(mission)
    db.commit()
    db.refresh(mission)
    return mission

@router.get("/", response_model=List[MissionOut], summary="Mes missions")
def get_my_missions(
    status: Optional[str] = None,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    if user.role == "driver":
        q = db.query(Mission).filter(Mission.driver_id == user.id)
    else:
        q = db.query(Mission).filter(Mission.client_id == user.id)
    if status:
        q = q.filter(Mission.status == status)
    return q.order_by(Mission.created_at.desc()).all()

@router.get("/available", response_model=List[MissionOut], summary="Missions disponibles (conducteur)")
def get_available_missions(
    db: Session = Depends(get_db),
    user: User = Depends(require_driver)
):
    return db.query(Mission).filter(
        Mission.status == "pending",
        Mission.driver_id == None
    ).order_by(Mission.created_at.desc()).all()

@router.get("/{mission_id}", response_model=MissionOut, summary="Détail d'une mission")
def get_mission(
    mission_id: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    mission = db.query(Mission).filter(Mission.id == mission_id).first()
    if not mission:
        raise HTTPException(status_code=404, detail="Mission introuvable")
    if mission.client_id != user.id and mission.driver_id != user.id:
        raise HTTPException(status_code=403, detail="Accès refusé")
    return mission

@router.put("/{mission_id}/status", response_model=MissionOut, summary="Mettre à jour le statut")
def update_status(
    mission_id: str,
    data: MissionStatusUpdate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    mission = db.query(Mission).filter(Mission.id == mission_id).first()
    if not mission:
        raise HTTPException(status_code=404, detail="Mission introuvable")

    allowed = {
        "driver": {
            "pending": ["accepted", "cancelled"],
            "accepted": ["in_progress", "cancelled"],
            "in_progress": ["completed"],
        },
        "client": {
            "pending": ["cancelled"],
            "accepted": ["cancelled"],
        }
    }

    role_allowed = allowed.get(user.role, {}).get(mission.status, [])
    if data.status not in role_allowed:
        raise HTTPException(status_code=400, detail=f"Transition '{mission.status}' → '{data.status}' non autorisée.")

    if data.status == "accepted":
        mission.driver_id = user.id
        mission.accepted_at = datetime.utcnow()
    if data.status == "completed":
        mission.completed_at = datetime.utcnow()
        user.total_missions = (user.total_missions or 0) + 1
        client = db.query(User).filter(User.id == mission.client_id).first()
        if client:
            client.total_missions = (client.total_missions or 0) + 1

    mission.status = data.status
    db.commit()
    db.refresh(mission)
    return mission

@router.delete("/{mission_id}", summary="Annuler une mission")
def cancel_mission(
    mission_id: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    mission = db.query(Mission).filter(Mission.id == mission_id).first()
    if not mission:
        raise HTTPException(status_code=404, detail="Mission introuvable")
    if mission.client_id != user.id:
        raise HTTPException(status_code=403, detail="Seul le client peut annuler")
    if mission.status in ["in_progress", "completed"]:
        raise HTTPException(status_code=400, detail="Impossible d'annuler une mission en cours ou terminée")
    mission.status = "cancelled"
    db.commit()
    return {"message": "Mission annulée"}
