-- =============================================================================
-- Supabase Schema: Moderator Applications
--
-- Tables:
--   1. moderator_applications — stores all moderator access requests
--   2. Updates to existing 'users' table — adds 'role' column if missing
--
-- Designed to mirror the Firebase Firestore schema exactly.
-- =============================================================================

-- ─── 1. Ensure users table has a 'role' column ─────────────────────────────

-- If your Supabase 'users' table already exists, add the role column:
ALTER TABLE users ADD COLUMN IF NOT EXISTS role TEXT DEFAULT NULL;

-- Create an index on role for efficient lookups
CREATE INDEX IF NOT EXISTS idx_users_role ON users (role);

-- ─── 2. Moderator Applications Table ────────────────────────────────────────

CREATE TABLE IF NOT EXISTS moderator_applications (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  applicant_uid   TEXT NOT NULL UNIQUE,  -- Firebase Auth UID (one application per user)
  applicant_email TEXT NOT NULL,
  applicant_name  TEXT NOT NULL,
  applicant_photo_url TEXT,
  reason          TEXT NOT NULL,
  experience      TEXT DEFAULT '',
  status          TEXT NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending', 'approved', 'rejected')),
  reviewed_by     TEXT,                  -- Admin UID who reviewed
  reviewed_at     TIMESTAMPTZ,
  review_note     TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_mod_apps_status ON moderator_applications (status);
CREATE INDEX IF NOT EXISTS idx_mod_apps_applicant ON moderator_applications (applicant_uid);
CREATE INDEX IF NOT EXISTS idx_mod_apps_created ON moderator_applications (created_at DESC);

-- ─── 3. Row Level Security (RLS) ────────────────────────────────────────────

ALTER TABLE moderator_applications ENABLE ROW LEVEL SECURITY;

-- Policy: Applicants can read their own application
CREATE POLICY "Users can read own application"
  ON moderator_applications
  FOR SELECT
  USING (auth.uid()::TEXT = applicant_uid);

-- Policy: Admins can read all applications
CREATE POLICY "Admins can read all applications"
  ON moderator_applications
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id::TEXT = auth.uid()::TEXT
        AND users.role = 'admin'
    )
  );

-- Policy: Authenticated users can insert their own application
CREATE POLICY "Users can create own application"
  ON moderator_applications
  FOR INSERT
  WITH CHECK (
    auth.uid()::TEXT = applicant_uid
    AND status = 'pending'
  );

-- Policy: Only admins can update applications (approve/reject)
CREATE POLICY "Admins can update applications"
  ON moderator_applications
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id::TEXT = auth.uid()::TEXT
        AND users.role = 'admin'
    )
  );

-- Policy: Only admins can delete applications
CREATE POLICY "Admins can delete applications"
  ON moderator_applications
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id::TEXT = auth.uid()::TEXT
        AND users.role = 'admin'
    )
  );

-- ─── 4. Auto-update trigger for updated_at ──────────────────────────────────

CREATE OR REPLACE FUNCTION update_moderator_applications_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_moderator_applications_updated_at
  BEFORE UPDATE ON moderator_applications
  FOR EACH ROW
  EXECUTE FUNCTION update_moderator_applications_updated_at();

-- ─── 5. Seed Data ───────────────────────────────────────────────────────────

INSERT INTO moderator_applications
  (applicant_uid, applicant_email, applicant_name, reason, experience, status, created_at)
VALUES
  (
    'sample-user-uid-001',
    'priya.sharma@example.com',
    'Priya Sharma',
    'I am a child rights advocate and social worker with 5 years of experience.',
    'Worked with UNICEF India as a field volunteer.',
    'pending',
    '2026-02-15T10:30:00Z'
  ),
  (
    'sample-user-uid-002',
    'rahul.gupta@example.com',
    'Rahul Gupta',
    'As a teacher in a government school, I frequently educate children about safety.',
    'Primary school teacher for 8 years. Conducted over 100 child safety workshops.',
    'approved',
    '2026-02-14T08:00:00Z'
  ),
  (
    'sample-user-uid-003',
    'anita.desai@example.com',
    'Anita Desai',
    'I am passionate about children welfare and want to contribute.',
    'NGO volunteer for 3 years. Social media content moderator at a child helpline.',
    'rejected',
    '2026-02-13T16:45:00Z'
  )
ON CONFLICT (applicant_uid) DO NOTHING;

-- Done!
-- ═══════════════════════════════════════════════════════════════════════════
