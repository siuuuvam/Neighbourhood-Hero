-- Enable PostGIS extension for location math
CREATE EXTENSION IF NOT EXISTS postgis;

-- 1. PROFILES TABLE (Extends Auth)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users NOT NULL PRIMARY KEY,
  username TEXT UNIQUE,
  avatar_url TEXT,
  karma_points INT DEFAULT 0,
  role TEXT DEFAULT 'neighbor',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 2. HELP REQUESTS TABLE (Geospatial)
CREATE TABLE IF NOT EXISTS help_requests (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) NOT NULL,
  helper_id UUID REFERENCES profiles(id),
  title TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'open' CHECK (status IN ('open', 'accepted', 'completed')),
  location GEOGRAPHY(POINT, 4326) NOT NULL,
  category TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
  accepted_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE
);

-- 3. KARMA TRANSACTIONS TABLE (for tracking)
CREATE TABLE IF NOT EXISTS karma_transactions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) NOT NULL,
  amount INT NOT NULL,
  reason TEXT,
  related_request_id UUID REFERENCES help_requests(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 4. RATINGS TABLE
CREATE TABLE IF NOT EXISTS ratings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  request_id UUID REFERENCES help_requests(id) NOT NULL,
  from_user_id UUID REFERENCES profiles(id) NOT NULL,
  to_user_id UUID REFERENCES profiles(id) NOT NULL,
  rating INT CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- SPATIAL INDEX for fast location queries
CREATE INDEX IF NOT EXISTS idx_requests_location ON help_requests USING GIST (location);
CREATE INDEX IF NOT EXISTS idx_requests_status ON help_requests (status);
CREATE INDEX IF NOT EXISTS idx_requests_user ON help_requests (user_id);
CREATE INDEX IF NOT EXISTS idx_requests_helper ON help_requests (helper_id);
CREATE INDEX IF NOT EXISTS idx_karma_user ON karma_transactions (user_id);
CREATE INDEX IF NOT EXISTS idx_ratings_request ON ratings (request_id);

-- ROW LEVEL SECURITY (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE help_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE karma_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE ratings ENABLE ROW LEVEL SECURITY;

-- Profiles Policies
CREATE POLICY "Profiles are viewable by everyone"
  ON profiles FOR SELECT USING (true);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Help Requests Policies
CREATE POLICY "Requests are viewable by everyone"
  ON help_requests FOR SELECT USING (true);

CREATE POLICY "Users can create requests"
  ON help_requests FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own requests"
  ON help_requests FOR UPDATE USING (auth.uid() = user_id OR auth.uid() = helper_id);

-- Karma Transactions Policies
CREATE POLICY "Karma transactions viewable by owner"
  ON karma_transactions FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Karma transactions insertable by service"
  ON karma_transactions FOR INSERT WITH CHECK (true);

-- Ratings Policies
CREATE POLICY "Ratings viewable by involved users"
  ON ratings FOR SELECT USING (auth.uid() = from_user_id OR auth.uid() = to_user_id);

CREATE POLICY "Users can create ratings"
  ON ratings FOR INSERT WITH CHECK (auth.uid() = from_user_id);

-- FUNCTION: Add Karma Securely
CREATE OR REPLACE FUNCTION add_karma(target_user_id UUID, amount INT)
RETURNS VOID AS $$
BEGIN
  UPDATE profiles 
  SET karma_points = karma_points + amount,
      updated_at = now()
  WHERE id = target_user_id;
  
  INSERT INTO karma_transactions (user_id, amount, reason)
  VALUES (target_user_id, amount, 'Task completion reward');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- FUNCTION: Get nearby requests using PostGIS
CREATE OR REPLACE FUNCTION get_nearby_requests(
  user_location GEOGRAPHY(POINT, 4326),
  radius_km DOUBLE PRECISION DEFAULT 5.0
)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  title TEXT,
  description TEXT,
  status TEXT,
  location GEOGRAPHY,
  distance_meters DOUBLE PRECISION,
  created_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    hr.id,
    hr.user_id,
    hr.title,
    hr.description,
    hr.status,
    hr.location,
    ST_Distance(hr.location, user_location) as distance_meters,
    hr.created_at
  FROM help_requests hr
  WHERE hr.status = 'open'
    AND ST_DWithin(hr.location, user_location, radius_km * 1000)
  ORDER BY ST_Distance(hr.location, user_location);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- FUNCTION: Handle new user signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, username, karma_points, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', 'Neighbor'),
    0,
    'neighbor'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- TRIGGER: Auto-create profile on signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- FUNCTION: Update timestamps
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER: Auto-update updated_at
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
