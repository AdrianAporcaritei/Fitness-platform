-- "Add client": an invite now carries the invitee's name (label) and email (decision #32).
ALTER TABLE coach_invite ADD COLUMN email varchar(254);
ALTER TABLE coach_invite ADD CONSTRAINT ck_coach_invite_email_lower CHECK (email = lower(email));

-- Duplicate check when adding a client: a coach's pending invites by email.
CREATE INDEX ix_coach_invite_coach_email_pending ON coach_invite (coach_id, email) WHERE status = 'PENDING';
