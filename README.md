# Neighbourhood Hero

Think of it as the neighbour you call when you're locked out, or the friend who helps you move. A platform where people in your area can ask for help and help others out.

## What it does

- Post requests for help with anything from picking up groceries to fixing things around the house
- Browse a map to see what people nearby need assistance with
- Build your reputation by helping others and earn karma points
- Track your activity and see how much of a community hero you are

## The Stack

- Flutter for the mobile app
- Node.js backend
- PostgreSQL with PostGIS for location data
- Supabase handles auth and database

## Getting Started

### Backend

```bash
cd backend
npm install
```

Create a `.env` file with your Supabase credentials:
```
PORT=3000
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_service_role_key
```

```bash
npm run dev
```

### Database

Set up Supabase and run the schema from `database/schema.sql`. You'll need to enable the PostGIS extension:

```sql
CREATE EXTENSION IF NOT EXISTS postgis;
```

### Mobile App

```bash
cd mobile
flutter pub get
```

Add your environment variables and run:

```bash
flutter run
```

## Karma Levels

| Points | Level |
|--------|-------|
| 0-49 | New Neighbor |
| 50-199 | Active Neighbor |
| 200-499 | Neighborhood Hero |
| 500+ | Neighborhood Legend |

## License

MIT
