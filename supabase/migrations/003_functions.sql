-- ============================================================
-- Jamat Timing App — Database Functions
-- ============================================================

-- ============================================================
-- FUNCTION: Approve a masjid request (transactional)
-- Creates masjid, assigns admin, updates request status
-- ============================================================

CREATE OR REPLACE FUNCTION approve_masjid_request(
    p_request_id UUID,
    p_reviewer_id UUID
)
RETURNS UUID AS $$
DECLARE
    v_request masjid_request%ROWTYPE;
    v_masjid_id UUID;
    v_admin_id UUID;
BEGIN
    -- Fetch the request
    SELECT * INTO v_request FROM masjid_request WHERE id = p_request_id;
    
    IF v_request IS NULL THEN
        RAISE EXCEPTION 'Request not found: %', p_request_id;
    END IF;
    
    IF v_request.status != 'pending' AND v_request.status != 'info_requested' THEN
        RAISE EXCEPTION 'Request is not in a reviewable state: %', v_request.status;
    END IF;
    
    -- Create the masjid
    INSERT INTO masjid (name, address, city, area, latitude, longitude, contact_phone, imam_name, status)
    VALUES (
        v_request.masjid_name,
        v_request.address,
        v_request.city,
        v_request.area,
        v_request.latitude,
        v_request.longitude,
        v_request.contact_phone,
        v_request.imam_name,
        'active'
    )
    RETURNING id INTO v_masjid_id;
    
    -- Find or create admin user for the admin_email
    SELECT id INTO v_admin_id FROM admin_user WHERE email = v_request.admin_email;
    
    IF v_admin_id IS NULL THEN
        -- Create admin user (auth_uid will be linked when they accept invite)
        INSERT INTO admin_user (email, role, is_active)
        VALUES (v_request.admin_email, 'masjid_admin', TRUE)
        RETURNING id INTO v_admin_id;
    END IF;
    
    -- Assign admin to masjid
    INSERT INTO admin_masjid (admin_id, masjid_id)
    VALUES (v_admin_id, v_masjid_id)
    ON CONFLICT (admin_id, masjid_id) DO NOTHING;
    
    -- Insert initial timings if provided
    IF v_request.initial_timings IS NOT NULL THEN
        INSERT INTO prayer_timing (masjid_id, prayer, jamat_time, label, updated_by)
        SELECT 
            v_masjid_id,
            (timing->>'prayer')::prayer_name,
            (timing->>'jamat_time')::TIME,
            timing->>'label',
            v_admin_id
        FROM jsonb_array_elements(v_request.initial_timings) AS timing;
    END IF;
    
    -- Update request status
    UPDATE masjid_request 
    SET status = 'approved', 
        reviewed_by = p_reviewer_id, 
        reviewed_at = NOW()
    WHERE id = p_request_id;
    
    RETURN v_masjid_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FUNCTION: Reject a masjid request
-- ============================================================

CREATE OR REPLACE FUNCTION reject_masjid_request(
    p_request_id UUID,
    p_reviewer_id UUID,
    p_reason TEXT
)
RETURNS VOID AS $$
BEGIN
    UPDATE masjid_request
    SET status = 'rejected',
        rejection_reason = p_reason,
        reviewed_by = p_reviewer_id,
        reviewed_at = NOW()
    WHERE id = p_request_id
      AND (status = 'pending' OR status = 'info_requested');
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Request not found or not in reviewable state: %', p_request_id;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FUNCTION: Request more info on a masjid request
-- ============================================================

CREATE OR REPLACE FUNCTION request_more_info(
    p_request_id UUID,
    p_reviewer_id UUID,
    p_message TEXT
)
RETURNS VOID AS $$
BEGIN
    UPDATE masjid_request
    SET status = 'info_requested',
        rejection_reason = p_message,  -- reusing field for info request message
        reviewed_by = p_reviewer_id,
        reviewed_at = NOW()
    WHERE id = p_request_id
      AND status = 'pending';
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Request not found or not pending: %', p_request_id;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FUNCTION: Search masjids by name/area/city
-- ============================================================

CREATE OR REPLACE FUNCTION search_masjids(
    p_query TEXT,
    p_city TEXT DEFAULT NULL,
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
    similarity_score REAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.id, m.name, m.address, m.city, m.area,
        m.latitude, m.longitude, m.contact_phone, m.imam_name,
        GREATEST(
            similarity(m.name, p_query),
            similarity(COALESCE(m.area, ''), p_query),
            similarity(m.city, p_query)
        ) AS similarity_score
    FROM masjid m
    WHERE m.status = 'active'
      AND (p_city IS NULL OR m.city ILIKE '%' || p_city || '%')
      AND (
          m.name ILIKE '%' || p_query || '%'
          OR m.area ILIKE '%' || p_query || '%'
          OR m.city ILIKE '%' || p_query || '%'
          OR similarity(m.name, p_query) > 0.2
      )
    ORDER BY similarity_score DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;

-- ============================================================
-- FUNCTION: Suspend / Unsuspend a masjid
-- ============================================================

CREATE OR REPLACE FUNCTION toggle_masjid_suspension(
    p_masjid_id UUID,
    p_suspend BOOLEAN
)
RETURNS VOID AS $$
BEGIN
    UPDATE masjid 
    SET status = CASE WHEN p_suspend THEN 'suspended' ELSE 'active' END
    WHERE id = p_masjid_id
      AND status IN ('active', 'suspended');
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Masjid not found or not in active/suspended state: %', p_masjid_id;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
