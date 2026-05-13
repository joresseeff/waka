from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db, User
from schemas import UserOut, DriverOut, UpdateDriverProfile, UpdateOnlineStatus
from auth import get_current_user, require_driver
from typing import List

router = APIRouter(prefix="/users", tags=["Utilisateurs"])

@router.get("/me", response_model=UserOut, summary="Mon profil")
def get_me(user: User = Depends(get_current_user)):
    return user

@router.put("/me/driver-profile", response_model=UserOut, summary="Mettre à jour véhicule")
def update_driver_profile(
    data: UpdateDriverProfile,
    user: User = Depends(require_driver),
    db: Session = Depends(get_db)
):
    for field, value in data.model_dump(exclude_none=True).items():
        setattr(user, field, value)
    db.commit()
    db.refresh(user)
    return user

@router.put("/me/online", response_model=UserOut, summary="Statut en ligne")
def set_online(
    data: UpdateOnlineStatus,
    user: User = Depends(require_driver),
    db: Session = Depends(get_db)
):
    user.is_online = data.is_online
    db.commit()
    db.refresh(user)
    return user

@router.get("/drivers/available", response_model=List[DriverOut], summary="Conducteurs disponibles")
def get_available_drivers(
    db: Session = Depends(get_db),
    _: User = Depends(get_current_user)
):
    return db.query(User).filter(
        User.role == "driver",
        User.is_online == True,
        User.is_active == True
    ).order_by(User.rating.desc()).all()

@router.get("/drivers", response_model=List[DriverOut], summary="Tous les conducteurs")
def get_all_drivers(
    db: Session = Depends(get_db),
    _: User = Depends(get_current_user)
):
    return db.query(User).filter(
        User.role == "driver",
        User.is_active == True
    ).order_by(User.is_online.desc(), User.rating.desc()).all()
