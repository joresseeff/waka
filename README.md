<div align="center">

# 🚕 WAKA

**Transport & Missions au Gabon — Application mobile Flutter + API FastAPI**

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![FastAPI](https://img.shields.io/badge/FastAPI-0.111-009688?logo=fastapi)
![Python](https://img.shields.io/badge/Python-3.11%2B-3776AB?logo=python)
![License](https://img.shields.io/badge/Licence-MIT-yellow)

*Waka — "Aller" en lingala et pidgin africain* 🌍

</div>

---

## 📖 À propos

Waka est une application de transport et de services à la demande conçue
spécifiquement pour le contexte gabonais et africain. Elle met en relation
clients et conducteurs pour des missions de transport, livraison, courses
et plus encore.

**Conçue pour les réalités africaines :**
- 📶 Fonctionne avec une connexion instable (mode hors-ligne)
- 💰 Mobile Money en priorité (Airtel Money, Moov Money)
- 🏍️ Mototaxis et tricycles supportés
- 📍 Points de repère à la place des adresses postales
- 🤝 Système de négociation de prix client/conducteur
- 📱 Optimisée pour les appareils Android bas de gamme (Tecno, Itel, Infinix)

---

## 🛵 Services disponibles

| Service | Description |
|---|---|
| 🚗 **Transport** | Taxi classique, trajet point A → B |
| 🏍️ **Mototaxi** | Rapide et économique en ville |
| 📦 **Livraison** | Livraison de colis et marchandises |
| 🛒 **Courses** | Faire les courses à votre place |
| 🚚 **Tricycle** | Transport de charges lourdes |
| 🏠 **Dépôt** | Stockage temporaire |

---

## 💳 Modes de paiement

| Méthode | Disponibilité |
|---|---|
| 📱 **Airtel Money** | ✅ Principal au Gabon |
| 📱 **Moov Money** | ✅ Disponible |
| 💵 **Cash** | ✅ Toujours accepté |
| 💳 **Carte bancaire** | ✅ Disponible |
| 📱 **Wave** | 🔜 Bientôt |

---

## 🗂 Structure du projet---

## 🌍 Améliorations pour le contexte africain

### 1. Points de repère
Au Gabon et en Afrique, les adresses postales n'existent pas toujours.
Waka permet d'indiquer des repères connus :### 2. Négociation de prix
La négociation est culturellement normale en Afrique.
Waka intègre un système de contre-offres en temps réel :
- Client propose un prix
- Conducteur fait une contre-offre
- Accord automatique si les prix convergent

### 3. Mode hors-ligne
Les coupures réseau sont fréquentes. Waka :
- Sauvegarde les missions en local (SQLite Flutter)
- Synchronise automatiquement à la reconnexion
- Affiche l'état de synchronisation en temps réel

### 4. Optimisation données mobiles
Les forfaits data sont chers au Gabon :
- Compression des images de profil
- Requêtes minimales (pagination agressive)
- Cache local des conducteurs disponibles

---

## 🚀 Installation backend

```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Documentation interactive : **http://localhost:8000/api/docs**

---

## 📱 Installation app Flutter

```bash
# Installer Flutter : https://flutter.dev/docs/get-started/install
cd mobile
flutter pub get
flutter run
```

---

## 📡 Endpoints API principaux

| Méthode | Route | Description |
|---|---|---|
| POST | `/api/auth/register` | Inscription |
| POST | `/api/auth/login` | Connexion |
| GET | `/api/users/me` | Mon profil |
| GET | `/api/users/drivers` | Conducteurs disponibles |
| POST | `/api/missions` | Créer une mission |
| GET | `/api/missions` | Mes missions |
| GET | `/api/missions/available` | Missions dispo (conducteur) |
| PUT | `/api/missions/{id}/status` | Mettre à jour statut |
| POST | `/api/negotiations` | Faire une offre de prix ✨ |
| POST | `/api/negotiations/{id}/accept` | Accepter un prix ✨ |
| POST | `/api/ratings` | Noter après mission |
| POST | `/api/messages` | Envoyer un message |

---

## 🔐 Sécurité

- Mots de passe hashés avec **bcrypt**
- Authentification **JWT** (expiration 30 jours)
- Variable `SECRET_KEY` via `.env` (ne jamais committer)

---

## 📞 Contact

**Waka v2.0** — Libreville, Gabon 🇬🇦 → Afrique 🌍
