from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db, User
from schemas import RegisterRequest, LoginRequest, Token, UserOut
from auth import hash_password, verify_password, create_token

router = APIRouter(prefix="/auth", tags=["Authentification"])

@router.post("/register", response_model=Token, summary="Inscription")
def register(data: RegisterRequest, db: Session = Depends(get_db)):
    if db.query(User).filter(User.email == data.email).first():
        raise HTTPException(status_code=400, detail="Cet email est déjà utilisé.")
    user = User(
        first_name=data.first_name,
        last_name=data.last_name,
        email=data.email,
        phone=data.phone,
        country=data.country,
        password=hash_password(data.password),
        role=data.role,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return Token(access_token=create_token(user.id), user=UserOut.model_validate(user))

@router.post("/login", response_model=Token, summary="Connexion")
def login(data: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == data.email).first()
    if not user or not verify_password(data.password, user.password):
        raise HTTPException(status_code=401, detail="Email ou mot de passe incorrect.")
    return Token(access_token=create_token(user.id), user=UserOut.model_validate(user))
