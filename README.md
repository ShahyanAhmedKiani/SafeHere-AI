# 🛡️ SafeHer AI

**A personal safety companion that turns a single press into a full emergency response.**

SafeHer AI is a cross-platform mobile safety application (Flutter) backed by a production Python API (FastAPI) that lets users trigger an SOS in seconds, automatically notify their trusted circle with a live location link, capture and preserve evidence to the cloud, and share journeys with real-time deviation alerts — all before, during, and after an incident.

Built for students, commuters, night-shift workers, and anyone who wants to move through the world with a safety net — and for the families, friends, and responders who want real visibility without constant check-in calls.

---

## 📑 Table of Contents

1. [Overview](#-overview)
2. [Key Features](#-key-features)
3. [System Architecture](#-system-architecture)
4. [Tech Stack](#-tech-stack)
5. [Project Structure](#-project-structure)
6. [Prerequisites](#-prerequisites)
7. [Backend Setup (FastAPI)](#-backend-setup-fastapi)
8. [Frontend Setup (Flutter)](#-frontend-setup-flutter)
9. [Environment Variables](#-environment-variables)
10. [Google Drive Evidence Integration](#-google-drive-evidence-integration)
11. [Deployment (Azure)](#-deployment-azure)
12. [API Reference](#-api-reference)
13. [App Screens](#-app-screens)
14. [Known Limitations](#-known-limitations)
15. [Roadmap](#-roadmap)
16. [Contributing](#-contributing)
17. [License](#-license)

---

## 📌 Overview

| | |
|---|---|
| **Problem** | Personal safety incidents happen fast, evidence is often lost, and trusted contacts find out too late to help. |
| **Solution** | A one-tap SOS system with live tracking, automatic cloud-backed evidence capture, journey monitoring with deviation detection, and a community safety map. |
| **Audience** | Individuals (students, commuters, solo travelers), families/guardians, and institutions (campuses, workplaces). |
| **Status** | Fully working backend (deployed live on Azure) + a 12-screen Flutter mobile app covering the entire user flow. |

---

## ✨ Key Features

### 🚨 Emergency SOS
- Press-and-hold SOS button (1.6s hold, prevents accidental triggers)
- Instantly emails all trusted contacts a **live tracking link**
- Starts continuous photo / video / audio evidence capture
- Evidence auto-uploads in **60-second cycles** — segments survive even if the phone is destroyed or lost
- Evidence is synced to a **private Google Drive folder**, not just local server storage
- GPS location broadcast every ~12 seconds, independent of the upload cycle
- One tap ("I Am Safe") stops capture and resolves the emergency

### 🧭 Journeys
- Plan a journey and share live location with **multiple trusted contacts** at once
- Server-side **route-deviation detection** (cross-track-distance algorithm) — contacts are alerted automatically if the user strays off the expected path
- Shareable **public live-tracking link** (no login required) for contacts to follow along

### 👥 Trusted Circle
- Add / manage trusted contacts with auto-invite-linking
- Designate emergency contacts who receive SOS alerts

### 🗺️ Safety Map
- Interactive map (OpenStreetMap / `flutter_map`) showing nearby police, fire, and hospital services via an **Overpass API** proxy, with national emergency-number fallback
- Community-reported **incidents** power a live safety score per area: Safe / Caution / High Risk

### 📄 Incident Reports
- Server-side, professionally formatted **PDF incident reports** (ReportLab) — generated on the backend, not the client

### 🤖 AI Safety Assistant
- Optional AI-powered chat assistant (Anthropic Claude) for safety guidance

### 📡 Live Guardian / Monitor Dashboard
- Real-time **WebSocket** feed so a guardian/monitor can watch an active emergency unfold live

### 🔐 Security & Data
- JWT authentication with access + refresh tokens
- Email OTP verification and forgot/reset password flow
- Real multipart/form-data file uploads streamed directly to disk — **zero Base64** anywhere in the system

---

## 🏗️ System Architecture

```
┌─────────────────────────────┐
│   Flutter Mobile App        │
│   (Android + iOS)           │
└───────────────┬──────────────┘
                │  REST + WebSocket (JWT)
                ▼
┌─────────────────────────────┐
│   FastAPI Backend            │
│   (hosted on Azure App Svc)  │
└───┬─────────┬─────────┬──────┘
    │         │         │
    ▼         ▼         ▼
┌────────┐ ┌───────────────┐ ┌─────────────────────┐
│Database│ │ External APIs │ │ Guardian Dashboard   │
│(SQLite/│ │ Google Drive  │ │ (Live WebSocket feed)│
│Postgres│ │ SMTP Email    │ └─────────────────────┘
│)       │ │ OSM Overpass  │
└────────┘ │ Claude AI     │
           └───────────────┘
```

> The mobile app talks **only** to the backend. All external integrations (Google Drive, email, maps, AI) are handled server-side — the app never connects to third-party services directly.

### SOS Emergency Flow

```
Hold SOS (1.6s)
      │
      ▼
Drive folder created + trusted contacts alerted (tracking link emailed)
      │
      ▼
Evidence capture begins (photo / video / audio)
      │
      ▼
┌──► 60-second upload cycle (segment uploads, next segment starts immediately) ──┐
│                                                                                  │
└──────────────────────────────────────────────────────────────────────────────┘
      │ (first upload complete → Drive folder link emailed once)
      ▼
User taps "I Am Safe" → capture & location sharing stop → emergency resolved
```
*(GPS location updates every ~12 seconds throughout, independent of the upload cycle.)*

### Data Model (core entities)

```
User ──< TrustedContact
User ──< Journey
User ──< EmergencyEvent
User ──< Incident
```

---

## 🧰 Tech Stack

### Backend
| Component | Technology |
|---|---|
| Framework | FastAPI |
| ORM | SQLAlchemy |
| Database | SQLite (dev) → PostgreSQL recommended for production |
| Auth | JWT (access + refresh tokens), OTP email verification |
| File uploads | Native multipart/form-data (streamed to disk) |
| PDF generation | ReportLab |
| Nearby services | OpenStreetMap Overpass API |
| Real-time | WebSocket broadcast hub |
| Email | SMTP (falls back to local logging if unconfigured) |
| Cloud storage | Google Drive API (OAuth 2.0) |
| AI Assistant | Anthropic Claude API (optional) |
| Server | Gunicorn + Uvicorn workers (ASGI) |
| Hosting | Microsoft Azure App Service |

### Frontend (Mobile)
| Component | Technology |
|---|---|
| Framework | Flutter (cross-platform: Android + iOS from one codebase) |
| State management | Provider |
| Routing | go_router (with auth guards) |
| Networking | Dio (with automatic token refresh) |
| Location | geolocator |
| Maps | flutter_map (OpenStreetMap tiles) |
| Evidence capture | camera + record packages (real files, no Base64) |
| Haptics | flutter/services (built-in `HapticFeedback`) |
| Storage | flutter_secure_storage |

---

## 📁 Project Structure

```
safeher-ai/
├── backend/                     # FastAPI application
│   ├── app/
│   │   ├── main.py              # App entrypoint, router wiring
│   │   ├── models/               # SQLAlchemy models (User, TrustedContact,
│   │   │                        #   Journey, EmergencyEvent, Incident, OTPCode)
│   │   ├── routers/              # auth, users, contacts, journeys,
│   │   │                        #   emergencies, services, incidents,
│   │   │                        #   reports, assistant, tracking, ws
│   │   ├── services/              # email, overpass, storage, gdrive,
│   │   │                        #   ws broadcast, assistant, pdf_report
│   │   ├── schemas/               # Pydantic request/response models
│   │   └── config.py             # Settings / environment variables
│   ├── scripts/
│   │   └── gdrive_auth.py        # One-time Google Drive OAuth setup script
│   ├── requirements.txt
│   ├── .env.example
│   └── .gitignore
│
└── mobile/                       # Flutter application
    ├── lib/
    │   ├── core/                 # theme, constants, routing
    │   ├── models/               # Dart data models
    │   ├── services/             # API client, auth, contacts, journeys,
    │   │                        #   emergencies, evidence capture, websocket
    │   ├── providers/            # State management (Provider)
    │   └── features/
    │       ├── auth/             # Login, Register, OTP, Reset Password
    │       ├── onboarding/
    │       ├── home/             # SOS button, safety score, quick actions
    │       ├── emergency/        # Emergency Active screen
    │       ├── safety_map/
    │       ├── journey/          # Journey planning + active tracking
    │       ├── trusted_circle/
    │       ├── assistant/        # AI Assistant chat
    │       ├── profile/
    │       └── monitor/          # Live Guardian dashboard
    ├── android/
    ├── ios/
    └── pubspec.yaml
```

---

## ✅ Prerequisites

Install these before you begin:

| Tool | Purpose | Link |
|---|---|---|
| Python 3.11+ | Backend | [python.org](https://www.python.org/) |
| Flutter SDK (3.x) | Mobile app | [flutter.dev](https://docs.flutter.dev/get-started/install) |
| Android Studio / Xcode | Emulator + platform SDKs | — |
| Git | Version control | — |
| VS Code (recommended) | Editor for both projects | — |

> ⚠️ On Windows, tick **"Add Python to PATH"** during Python installation. Run `flutter doctor` after installing Flutter and resolve any issues it reports before continuing.

---

## ⚙️ Backend Setup (FastAPI)

```bash
# 1. Navigate into the backend folder
cd backend

# 2. Create and activate a virtual environment
python -m venv venv
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Configure environment variables
cp .env.example .env
# then edit .env — see "Environment Variables" section below

# 5. Run the server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The API will be live at `http://localhost:8000`, with interactive Swagger docs at `http://localhost:8000/docs`.

> `--host 0.0.0.0` is required if you want other devices on your network (e.g. a phone or a teammate's laptop) to reach the backend — using just `uvicorn app.main:app --reload` restricts access to your own machine.

**Testing from a device on a different network:** use a tunneling tool such as [ngrok](https://ngrok.com/) (`ngrok http 8000`) to get a temporary public URL.

---

## 📱 Frontend Setup (Flutter)

```bash
# 1. Navigate into the mobile folder
cd mobile

# 2. Get dependencies
flutter pub get

# 3. Point the app at your backend
# Either edit lib/core/constants.dart directly, or pass it at run-time:
flutter run --dart-define=API_BASE_URL=http://<YOUR_BACKEND_IP_OR_URL>:8000

# 4. Run on an emulator or connected device
flutter run
```

**Notes:**
- If running the backend locally and testing on the **Android emulator**, use `http://10.0.2.2:8000` as the API base URL (this maps to your host machine's `localhost`).
- If testing on a **physical device**, both devices must be on the same Wi-Fi network, and you must use your machine's local IP (find it via `ipconfig` on Windows / `ifconfig` on macOS/Linux).
- If the device is on a **different network entirely**, point the app at your deployed backend URL (Azure) or a temporary `ngrok` tunnel.
- Run `flutter analyze` and `flutter clean && flutter pub get` if you hit stale-build or plugin errors after pulling new code.

---

## 🔑 Environment Variables

Set these in `backend/.env` for local development, or in your hosting platform's **Application Settings / Environment Variables** for production (e.g. Azure Configuration).

| Variable | Required | Description |
|---|---|---|
| `SECRET_KEY` | ✅ | Long random string used to sign JWTs |
| `DATABASE_URL` | ✅ | e.g. `sqlite:///./safeher.db` (dev) or a PostgreSQL connection string (production) |
| `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASSWORD` | Optional | Enables real email sending (OTP, alerts). If unset, emails are logged locally instead — the app still works in dev. |
| `ANTHROPIC_API_KEY` | Optional | Enables the AI Assistant feature; omit and it falls back to a generic response |
| `MEDIA_ROOT` | ✅ | Local folder for storing uploaded evidence files |
| `PUBLIC_BASE_URL` | ✅ | Public base URL of the backend (used to build tracking/report links). Set to your Azure URL in production. |
| `GOOGLE_DRIVE_CLIENT_JSON` | Optional | Full contents of your OAuth `client_secret.json` (see below) |
| `GOOGLE_DRIVE_TOKEN_JSON` | Optional | Token JSON generated by `scripts/gdrive_auth.py` |

> 🔒 **Never commit** `client_secret.json` or `token.json` to version control — they are already excluded via `.gitignore`.

---

## ☁️ Google Drive Evidence Integration

Evidence captured during an SOS is synced to a private Google Drive folder so it survives even if the device is lost. Setup is optional — without it, evidence is still saved to the backend's local storage.

1. Create a project at [console.cloud.google.com](https://console.cloud.google.com/), enable the **Google Drive API**.
2. Configure the **OAuth consent screen** → External → add your app name and support email.
3. Add any Google account that needs to run the auth script to the **Test users** list.
4. Create an **OAuth Client ID** → Application type: **Desktop app** → download the JSON as `backend/scripts/client_secret.json`.
5. Run the one-time authorization script:
   ```bash
   pip install google-auth-oauthlib
   python scripts/gdrive_auth.py
   ```
6. Approve access in the browser window that opens. Copy the resulting token JSON into `GOOGLE_DRIVE_TOKEN_JSON`, and the client secret JSON into `GOOGLE_DRIVE_CLIENT_JSON`.

> Evidence is stored in the Drive account of whichever Google account approves the OAuth prompt — choose deliberately (typically the project owner's account).

---

## 🚀 Deployment (Azure)

The backend is designed to deploy directly to **Azure App Service** via GitHub Actions.

1. Connect your GitHub repo to an Azure App Service (Linux, Python stack).
2. In **Configuration → General settings → Startup Command**, set:
   ```bash
   gunicorn --bind=0.0.0.0 --timeout 600 --workers 2 -k uvicorn.workers.UvicornWorker app.main:app
   ```
3. In **Configuration → Application settings**, add all environment variables listed above.
4. Enable **Web sockets** (`Configuration → General settings → Web sockets → On`) — required for the live Monitor dashboard.
5. Push to `main` — GitHub Actions will build and deploy automatically. Verify with:
   ```
   https://<your-app-name>.azurewebsites.net/health
   ```
   should return `{"status":"healthy"}`.

> ⚠️ SQLite is fine for testing, but Azure's filesystem is not guaranteed persistent across restarts/scaling. For production, switch `DATABASE_URL` to a managed PostgreSQL instance (e.g. Azure Database for PostgreSQL) — no code changes needed.

---

## 📡 API Reference

Base URL (production): `https://safehar-ai-f2eddne4c6gtd4ga.southindia-01.azurewebsites.net`

All endpoints except registration/login require the header:
```
Authorization: Bearer <access_token>
```

Full interactive documentation is always available at `/docs` (Swagger UI) on any running instance.

| Category | Method | Endpoint | Description |
|---|---|---|---|
| Auth | `POST` | `/auth/register` | Register a new user, sends OTP |
| Auth | `POST` | `/auth/verify-otp` | Verify email OTP |
| Auth | `POST` | `/auth/login` | Login, returns access + refresh tokens |
| Auth | `POST` | `/auth/refresh` | Refresh access token |
| Auth | `POST` | `/auth/forgot-password` | Send password reset OTP |
| Auth | `POST` | `/auth/reset-password` | Reset password with OTP |
| Users | `GET` | `/users/me` | Get current user profile |
| Users | `PATCH` | `/users/me` | Update profile |
| Trusted Contacts | `GET` | `/contacts` | List trusted contacts |
| Trusted Contacts | `POST` | `/contacts` | Add a trusted contact |
| Trusted Contacts | `DELETE` | `/contacts/{id}` | Remove a contact |
| Journeys | `POST` | `/journeys` | Start a journey (multi-contact) |
| Journeys | `PATCH` | `/journeys/{id}/location` | Update live location (deviation check) |
| Journeys | `POST` | `/journeys/{id}/complete` | Mark journey complete |
| Emergencies | `POST` | `/emergencies/activate` | Trigger SOS |
| Emergencies | `POST` | `/emergencies/{id}/evidence` | Upload evidence (multipart) |
| Emergencies | `POST` | `/emergencies/{id}/resolve` | Resolve/close SOS |
| Nearby Services | `GET` | `/services/nearby` | Nearby police/fire/hospital (Overpass) |
| Incidents | `POST` | `/incidents` | Report a safety incident |
| Incidents | `GET` | `/incidents/nearby` | Get area safety score |
| Reports | `GET` | `/reports/{emergency_id}/pdf` | Generate PDF incident report |
| Assistant | `POST` | `/assistant/chat` | AI safety assistant chat |
| Public Tracking | `GET` | `/track/{token}` | Public live-tracking page (no auth) |
| WebSocket | `WS` | `/ws/monitor` | Live Monitor dashboard feed |

> Exact request/response bodies for each endpoint are documented live at `/docs`.

---

## 📲 App Screens

Login · Register · OTP Verification · Forgot/Reset Password · Onboarding · Home (SOS button, safety score, trusted circle preview) · Emergency Active (GPS tracking, evidence checklist, quick-dial, nearby services, share location) · Safety Map · Journey Planning & Active Tracking (with deviation alerts) · Trusted Circle & Add Contact · AI Assistant · Profile · Guardian / Monitor Dashboard

---

## ⚠️ Known Limitations

- **Safety score** on the Home screen currently uses a simplified placeholder metric — a production-grade risk model would require a historical incident data pipeline.
- **Evidence capture** alternates between front/back camera rather than true simultaneous dual-camera capture, since most devices don't support this without specialized native plugins.
- The Flutter codebase was written carefully but not compiled/verified against the Flutter SDK during initial development — run `flutter analyze` before your first build to catch any environment-specific issues.
- SQLite is suitable for development only; use a managed database in production.

---

## 🗺️ Roadmap

- [ ] Historical-data-driven safety scoring model
- [ ] Push notifications (FCM/APNs) in addition to email alerts
- [ ] Multi-language support
- [ ] Offline-first evidence queuing for poor connectivity
- [ ] Admin/institutional dashboard for organizations

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m "Add your feature"`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a Pull Request

---

## 📄 License

This project is provided as-is for educational and hackathon purposes. Add your preferred license (e.g. MIT) here before public release.

---

<p align="center">Built with ❤️ to help people move through the world a little more safely.</p>
