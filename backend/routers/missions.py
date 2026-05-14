from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db, User, Mission
from schemas import MissionCreate, MissionOut, MissionStatusUpdate
from auth import get_current_user, require_driver
from datetime import datetime
from typing import List

router = APIRouter(prefix="/missions", tags=["Missions"])

COMMISSION_RATE = 0.10


@router.post("", response_model=MissionOut, status_code=201)
def create_mission(
    data: MissionCreate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    commission = round(data.price_proposed * COMMISSION_RATE, 2)
    total = round(data.price_proposed + commission, 2)
    mission = Mission(
        client_id=user.id,
        driver_id=data.driver_id,
        service=data.service,
        from_addr=data.from_addr,
        from_landmark=data.from_landmark,
        to_addr=data.to_addr,
        to_landmark=data.to_landmark,
        description=data.description,
        price_proposed=data.price_proposed,
        commission=commission,
        total=total,
        payment=data.payment,
        scheduled=data.scheduled,
    )
    db.add(mission)
    db.commit()
    db.refresh(mission)
    return mission


@router.get("", response_model=List[MissionOut])
def get_my_missions(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    if user.role == "client":
        return db.query(Mission).filter(
            Mission.client_id == user.id
        ).order_by(Mission.created_at.desc()).all()
    else:
        return db.query(Mission).filter(
            Mission.driver_id == user.id
        ).order_by(Mission.created_at.desc()).all()


@router.get("/available", response_model=List[MissionOut])
def get_available_missions(
    db: Session = Depends(get_db),
    user: User = Depends(require_driver),
):
    return db.query(Mission).filter(
        Mission.status == "pending",
        Mission.driver_id == None,
    ).order_by(Mission.created_at.desc()).all()


@router.put("/{mission_id}/status")
def update_status(
    mission_id: str,
    data: MissionStatusUpdate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    mission = db.query(Mission).filter(Mission.id == mission_id).first()
    if not mission:
        raise HTTPException(status_code=404, detail="Mission introuvable")

    mission.status = data.status
    if data.status == "accepted":
        mission.driver_id = user.id
        mission.accepted_at = datetime.utcnow()
    elif data.status == "completed":
        mission.completed_at = datetime.utcnow()

    db.commit()
    return {"message": "Statut mis à jour", "status": data.status}
