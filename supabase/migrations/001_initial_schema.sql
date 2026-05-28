-- ============================================================
-- Jamat Timing App — Initial Database Schema
-- ============================================================

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- ENUMS
-- ============================================================

CREATE TYPE masjid_status AS ENUM ('pending', 'active', 'suspended', 'rejected');
CREATE TYPE prayer_name AS ENUM ('fajr', 'dhuhr', 'asr', 'maghrib', 'isha', 'jumuah', 'taraweeh', 'eid');
CREATE TYPE user_role AS ENUM ('masjid_admin', 'super_admin');
CREATE TYPE request_status AS ENUM ('pending', 'approved', 'rejected', 'info_requested');

-- ============================================================
-- TABLE: admin_user
-- ============================================================
-- Linked to Supabase Auth UID. Created by super admin or seed.

CREATE TABLE admin_user (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_uid    UUID UNIQUE,  -- references auth.users(id)
    email       TEXT UNIQUE NOT NULL,
    full_name   TEXT,
    role        user_role NOT NULL DEFAULT 'masjid_admin',
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_admin_user_auth_uid ON admin_user(auth_uid);
CREATE INDEX idx_admin_user_role ON admin_user(role);

-- ============================================================
-- TABLE: masjid
-- ============================================================

CREATE TABLE masjid (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            TEXT NOT NULL,
    address         TEXT NOT NULL,
    city            TEXT NOT NULL,
    area            TEXT,
    latitude        DOUBLE PRECISION NOT NULL,
    longitude       DOUBLE PRECISION NOT NULL,
    contact_phone   TEXT,
    imam_name       TEXT,
    status          masjid_status NOT NULL DEFAULT 'pending',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Spatial-like index for proximity queries (lat/lng combo)
CREATE INDEX idx_masjid_location ON masjid(latitude, longitude);
CREATE INDEX idx_masjid_status ON masjid(status);
CREATE INDEX idx_masjid_city ON masjid(city);
CREATE INDEX idx_masjid_name_trgm ON masjid USING gin (name gin_trgm_ops);

-- Enable trigram extension for fuzzy text search
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Auto-update updated_at on row changes
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_masjid_updated_at
    BEFORE UPDATE ON masjid
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- TABLE: prayer_timing
-- ============================================================

CREATE TABLE prayer_timing (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    masjid_id       UUID NOT NULL REFERENCES masjid(id) ON DELETE CASCADE,
    prayer          prayer_name NOT NULL,
    jamat_time      TIME NOT NULL,
    label           TEXT,           -- e.g. "1st Jamat", "Ramadan only"
    is_ramadan      BOOLEAN NOT NULL DEFAULT FALSE,
    valid_from      DATE,           -- seasonal schedule start
    valid_until     DATE,           -- seasonal schedule end
    updated_by      UUID REFERENCES admin_user(id),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_prayer_timing_masjid ON prayer_timing(masjid_id);
CREATE INDEX idx_prayer_timing_prayer ON prayer_timing(prayer);

-- Prevent duplicate timings for same masjid + prayer + label
CREATE UNIQUE INDEX idx_prayer_timing_unique 
    ON prayer_timing(masjid_id, prayer, COALESCE(label, ''));

CREATE TRIGGER trg_prayer_timing_updated_at
    BEFORE UPDATE ON prayer_timing
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- TABLE: masjid_request
-- ============================================================

CREATE TABLE masjid_request (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    masjid_name         TEXT NOT NULL,
    address             TEXT NOT NULL,
    city                TEXT NOT NULL,
    area                TEXT,
    latitude            DOUBLE PRECISION,
    longitude           DOUBLE PRECISION,
    contact_phone       TEXT,
    imam_name           TEXT,
    initial_timings     JSONB,          -- snapshot of submitted timings
    admin_email         TEXT NOT NULL,
    note                TEXT,           -- supporting note from submitter
    status              request_status NOT NULL DEFAULT 'pending',
    rejection_reason    TEXT,
    submitted_by        UUID REFERENCES admin_user(id),
    reviewed_by         UUID REFERENCES admin_user(id),
    submitted_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reviewed_at         TIMESTAMPTZ
);

CREATE INDEX idx_masjid_request_status ON masjid_request(status);
CREATE INDEX idx_masjid_request_submitted_by ON masjid_request(submitted_by);

-- ============================================================
-- TABLE: admin_masjid (many-to-many assignment)
-- ============================================================

CREATE TABLE admin_masjid (
    admin_id    UUID NOT NULL REFERENCES admin_user(id) ON DELETE CASCADE,
    masjid_id   UUID NOT NULL REFERENCES masjid(id) ON DELETE CASCADE,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (admin_id, masjid_id)
);

CREATE INDEX idx_admin_masjid_admin ON admin_masjid(admin_id);
CREATE INDEX idx_admin_masjid_masjid ON admin_masjid(masjid_id);

-- ============================================================
-- TABLE: audit_log
-- ============================================================

CREATE TABLE audit_log (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    masjid_id       UUID REFERENCES masjid(id) ON DELETE SET NULL,
    masjid_name     TEXT,           -- denormalized for readability
    prayer          prayer_name,
    action          TEXT NOT NULL,  -- 'INSERT', 'UPDATE', 'DELETE'
    old_time        TIME,
    new_time        TIME,
    old_label       TEXT,
    new_label       TEXT,
    changed_by      UUID REFERENCES admin_user(id),
    changed_by_email TEXT,          -- denormalized
    changed_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_log_masjid ON audit_log(masjid_id);
CREATE INDEX idx_audit_log_changed_by ON audit_log(changed_by);
CREATE INDEX idx_audit_log_changed_at ON audit_log(changed_at DESC);

-- ============================================================
-- TRIGGER: Auto-log prayer_timing changes to audit_log
-- ============================================================

CREATE OR REPLACE FUNCTION log_timing_change()
RETURNS TRIGGER AS $$
DECLARE
    v_masjid_name TEXT;
    v_admin_email TEXT;
BEGIN
    -- Get masjid name for denormalization
    IF TG_OP = 'DELETE' THEN
        SELECT name INTO v_masjid_name FROM masjid WHERE id = OLD.masjid_id;
        SELECT email INTO v_admin_email FROM admin_user WHERE id = OLD.updated_by;
        
        INSERT INTO audit_log (masjid_id, masjid_name, prayer, action, old_time, old_label, changed_by, changed_by_email)
        VALUES (OLD.masjid_id, v_masjid_name, OLD.prayer, 'DELETE', OLD.jamat_time, OLD.label, OLD.updated_by, v_admin_email);
        
        RETURN OLD;
    ELSIF TG_OP = 'INSERT' THEN
        SELECT name INTO v_masjid_name FROM masjid WHERE id = NEW.masjid_id;
        SELECT email INTO v_admin_email FROM admin_user WHERE id = NEW.updated_by;
        
        INSERT INTO audit_log (masjid_id, masjid_name, prayer, action, new_time, new_label, changed_by, changed_by_email)
        VALUES (NEW.masjid_id, v_masjid_name, NEW.prayer, 'INSERT', NEW.jamat_time, NEW.label, NEW.updated_by, v_admin_email);
        
        RETURN NEW;
    ELSE  -- UPDATE
        SELECT name INTO v_masjid_name FROM masjid WHERE id = NEW.masjid_id;
        SELECT email INTO v_admin_email FROM admin_user WHERE id = NEW.updated_by;
        
        INSERT INTO audit_log (masjid_id, masjid_name, prayer, action, old_time, new_time, old_label, new_label, changed_by, changed_by_email)
        VALUES (NEW.masjid_id, v_masjid_name, NEW.prayer, 'UPDATE', OLD.jamat_time, NEW.jamat_time, OLD.label, NEW.label, NEW.updated_by, v_admin_email);
        
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_prayer_timing_audit
    AFTER INSERT OR UPDATE OR DELETE ON prayer_timing
    FOR EACH ROW
    EXECUTE FUNCTION log_timing_change();

-- ============================================================
-- FUNCTION: Get nearby masjids using Haversine formula
-- ============================================================

CREATE OR REPLACE FUNCTION get_nearby_masjids(
    p_lat DOUBLE PRECISION,
    p_lng DOUBLE PRECISION,
    p_radius_km DOUBLE PRECISION DEFAULT 10.0,
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE (
    id UUID,
    name TEXT,
    address TEXT,
    city TEXT,
    area TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    contact_phone TEXT,
    imam_name TEXT,
    status masjid_status,
    distance_km DOUBLE PRECISION,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.id, m.name, m.address, m.city, m.area,
        m.latitude, m.longitude, m.contact_phone, m.imam_name,
        m.status,
        (6371 * acos(
            LEAST(1.0, 
                cos(radians(p_lat)) * cos(radians(m.latitude)) *
                cos(radians(m.longitude) - radians(p_lng)) +
                sin(radians(p_lat)) * sin(radians(m.latitude))
            )
        )) AS distance_km,
        m.created_at, m.updated_at
    FROM masjid m
    WHERE m.status = 'active'
      AND m.latitude BETWEEN p_lat - (p_radius_km / 111.0) AND p_lat + (p_radius_km / 111.0)
      AND m.longitude BETWEEN p_lng - (p_radius_km / (111.0 * cos(radians(p_lat)))) 
                          AND p_lng + (p_radius_km / (111.0 * cos(radians(p_lat))))
    HAVING (6371 * acos(
        LEAST(1.0, 
            cos(radians(p_lat)) * cos(radians(m.latitude)) *
            cos(radians(m.longitude) - radians(p_lng)) +
            sin(radians(p_lat)) * sin(radians(m.latitude))
        )
    )) <= p_radius_km
    ORDER BY distance_km ASC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;
