# Neighborhood Hero

A hyperlocal community assistance platform built with Flutter and Supabase.

## Features

- **User Authentication**: Secure sign up and login with Supabase Auth
- **Geolocation-based Discovery**: Find nearby help requests using PostGIS
- **Real-time Map**: Interactive map showing nearby requests
- **Karma System**: Earn points by helping neighbors
- **Request Management**: Create, accept, complete, and cancel requests
- **User Profiles**: Track your activity and reputation

## Tech Stack

- **Frontend**: Flutter 3.x
- **Backend**: Node.js with Express
- **Database**: PostgreSQL with PostGIS
- **Auth & Storage**: Supabase
- **Maps**: OpenStreetMap (flutter_map)

## Setup Instructions

### Prerequisites

- Flutter SDK 3.0+
- Node.js 18+
- PostgreSQL with PostGIS extension
- Supabase account

### Database Setup

1. Create a new Supabase project
2. Enable the PostGIS extension in the SQL editor:
   ```sql
   CREATE EXTENSION IF NOT EXISTS postgis;
   ```
3. Run the schema from `database/schema.sql`

### Backend Setup

```bash
cd backend
npm install
```

Create a `.env` file:
```
PORT=3000
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_service_role_key
```

Run the backend:
```bash
npm run dev
```

### Mobile App Setup

```bash
cd mobile
flutter pub get
```

Create a `.env` file:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
MAPBOX_ACCESS_TOKEN=your_mapbox_token
BACKEND_URL=http://your_backend_url:3000/api
```

Run the app:
```bash
flutter run
```

## Project Structure

```
hood/
├── mobile/                 # Flutter mobile app
│   ├── lib/
│   │   ├── config/        # App configuration
│   │   ├── models/        # Data models
│   │   ├── providers/     # State management
│   │   ├── screens/       # UI screens
│   │   ├── services/      # API services
│   │   └── widgets/       # Reusable widgets
│   └── pubspec.yaml
├── backend/                # Node.js backend
│   └── src/
│       ├── routes/        # API routes
│       └── services/      # Business logic
└── database/
    └── schema.sql         # Database schema
```

## API Endpoints

- `POST /api/complete-task` - Complete a task and award karma
- `GET /api/user/:userId` - Get user profile
- `GET /api/karma-level/:points` - Get karma level info
- `POST /api/karma/award` - Award karma points

## Karma System

| Points | Level |
|--------|-------|
| 0-49 | New Neighbor |
| 50-199 | Active Neighbor |
| 200-499 | Neighborhood Hero |
| 500+ | Neighborhood Legend |

## License

MIT
