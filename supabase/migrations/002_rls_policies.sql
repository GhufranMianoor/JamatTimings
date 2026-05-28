-- ============================================================
-- Jamat Timing App — Row Level Security Policies
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE admin_user ENABLE ROW LEVEL SECURITY;
ALTER TABLE masjid ENABLE ROW LEVEL SECURITY;
ALTER TABLE prayer_timing ENABLE ROW LEVEL SECURITY;
ALTER TABLE masjid_request ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_masjid ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- Helper function: Get current user's role
-- ============================================================

CREATE OR REPLACE FUNCTION get_user_role()
RETURNS user_role AS $$
    SELECT role FROM admin_user 
    WHERE auth_uid = auth.uid() 
    AND is_active = TRUE
    LIMIT 1;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Helper: Check if user is super admin
CREATE OR REPLACE FUNCTION is_super_admin()
RETURNS BOOLEAN AS $$
    SELECT EXISTS(
        SELECT 1 FROM admin_user 
        WHERE auth_uid = auth.uid() 
        AND role = 'super_admin' 
        AND is_active = TRUE
    );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Helper: Check if user is admin of a specific masjid
CREATE OR REPLACE FUNCTION is_masjid_admin(p_masjid_id UUID)
RETURNS BOOLEAN AS $$
    SELECT EXISTS(
        SELECT 1 FROM admin_masjid am
        JOIN admin_user au ON au.id = am.admin_id
        WHERE am.masjid_id = p_masjid_id
        AND au.auth_uid = auth.uid()
        AND au.is_active = TRUE
    );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- ============================================================
-- MASJID policies
-- ============================================================

-- Anyone can read active masjids (guest users, no auth required)
CREATE POLICY "masjid_select_active" ON masjid
    FOR SELECT
    USING (status = 'active');

-- Super admins can see ALL masjids (any status)
CREATE POLICY "masjid_select_all_super_admin" ON masjid
    FOR SELECT
    USING (is_super_admin());

-- Masjid admins can see their assigned masjids
CREATE POLICY "masjid_select_assigned_admin" ON masjid
    FOR SELECT
    USING (is_masjid_admin(id));

-- Only super admin can insert/update/delete masjids
CREATE POLICY "masjid_insert_super_admin" ON masjid
    FOR INSERT
    WITH CHECK (is_super_admin());

CREATE POLICY "masjid_update_super_admin" ON masjid
    FOR UPDATE
    USING (is_super_admin())
    WITH CHECK (is_super_admin());

CREATE POLICY "masjid_delete_super_admin" ON masjid
    FOR DELETE
    USING (is_super_admin());

-- ============================================================
-- PRAYER_TIMING policies
-- ============================================================

-- Anyone can read timings for active masjids
CREATE POLICY "timing_select_all" ON prayer_timing
    FOR SELECT
    USING (
        EXISTS(SELECT 1 FROM masjid WHERE masjid.id = prayer_timing.masjid_id AND masjid.status = 'active')
    );

-- Super admin can read all timings
CREATE POLICY "timing_select_super_admin" ON prayer_timing
    FOR SELECT
    USING (is_super_admin());

-- Assigned admin can insert timings for their masjid
CREATE POLICY "timing_insert_admin" ON prayer_timing
    FOR INSERT
    WITH CHECK (is_masjid_admin(masjid_id));

-- Assigned admin can update timings for their masjid
CREATE POLICY "timing_update_admin" ON prayer_timing
    FOR UPDATE
    USING (is_masjid_admin(masjid_id))
    WITH CHECK (is_masjid_admin(masjid_id));

-- Assigned admin can delete timings for their masjid
CREATE POLICY "timing_delete_admin" ON prayer_timing
    FOR DELETE
    USING (is_masjid_admin(masjid_id));

-- Super admin can do everything with timings
CREATE POLICY "timing_all_super_admin" ON prayer_timing
    FOR ALL
    USING (is_super_admin())
    WITH CHECK (is_super_admin());

-- ============================================================
-- MASJID_REQUEST policies
-- ============================================================

-- Any authenticated user can submit a request
CREATE POLICY "request_insert_any_auth" ON masjid_request
    FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

-- Submitter can see their own requests
CREATE POLICY "request_select_own" ON masjid_request
    FOR SELECT
    USING (
        submitted_by IN (
            SELECT id FROM admin_user WHERE auth_uid = auth.uid()
        )
    );

-- Super admin can see all requests
CREATE POLICY "request_select_super_admin" ON masjid_request
    FOR SELECT
    USING (is_super_admin());

-- Only super admin can update requests (approve/reject)
CREATE POLICY "request_update_super_admin" ON masjid_request
    FOR UPDATE
    USING (is_super_admin())
    WITH CHECK (is_super_admin());

-- Only super admin can delete requests
CREATE POLICY "request_delete_super_admin" ON masjid_request
    FOR DELETE
    USING (is_super_admin());

-- ============================================================
-- ADMIN_USER policies
-- ============================================================

-- Users can read their own record
CREATE POLICY "admin_user_select_own" ON admin_user
    FOR SELECT
    USING (auth_uid = auth.uid());

-- Super admin can read all admin users
CREATE POLICY "admin_user_select_super_admin" ON admin_user
    FOR SELECT
    USING (is_super_admin());

-- Only super admin can manage admin accounts
CREATE POLICY "admin_user_insert_super_admin" ON admin_user
    FOR INSERT
    WITH CHECK (is_super_admin());

CREATE POLICY "admin_user_update_super_admin" ON admin_user
    FOR UPDATE
    USING (is_super_admin())
    WITH CHECK (is_super_admin());

CREATE POLICY "admin_user_delete_super_admin" ON admin_user
    FOR DELETE
    USING (is_super_admin());

-- ============================================================
-- ADMIN_MASJID policies
-- ============================================================

-- Admins can see their own assignments
CREATE POLICY "admin_masjid_select_own" ON admin_masjid
    FOR SELECT
    USING (
        admin_id IN (SELECT id FROM admin_user WHERE auth_uid = auth.uid())
    );

-- Super admin can manage all assignments
CREATE POLICY "admin_masjid_all_super_admin" ON admin_masjid
    FOR ALL
    USING (is_super_admin())
    WITH CHECK (is_super_admin());

-- ============================================================
-- AUDIT_LOG policies
-- ============================================================

-- Only super admin can read audit logs
CREATE POLICY "audit_log_select_super_admin" ON audit_log
    FOR SELECT
    USING (is_super_admin());

-- Masjid admins can see audit logs for their own masjids
CREATE POLICY "audit_log_select_own_masjid" ON audit_log
    FOR SELECT
    USING (is_masjid_admin(masjid_id));

-- No direct insert/update/delete — only via trigger
-- (The trigger function runs as SECURITY DEFINER)
