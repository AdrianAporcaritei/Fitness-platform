CREATE TABLE coach_invite (
    id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    coach_id          uuid         NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
    code_hash         varchar(64)  NOT NULL,
    label             varchar(100),
    status            varchar(20)  NOT NULL,
    expires_at        timestamptz  NOT NULL,
    used_at           timestamptz,
    used_by_client_id uuid REFERENCES app_user (id) ON DELETE SET NULL,
    created_at        timestamptz  NOT NULL DEFAULT now(),
    updated_at        timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT uq_coach_invite_code_hash UNIQUE (code_hash),
    CONSTRAINT ck_coach_invite_status CHECK (status IN ('PENDING', 'USED', 'REVOKED'))
);
CREATE INDEX ix_coach_invite_coach ON coach_invite (coach_id);

CREATE TABLE refresh_token (
    id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id        uuid        NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
    token_hash     varchar(64) NOT NULL,
    family_id      uuid        NOT NULL,
    expires_at     timestamptz NOT NULL,
    revoked_at     timestamptz,
    replaced_by_id uuid REFERENCES refresh_token (id) ON DELETE SET NULL,
    created_at     timestamptz NOT NULL DEFAULT now(),
    updated_at     timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_refresh_token_hash UNIQUE (token_hash)
);
CREATE INDEX ix_refresh_token_family ON refresh_token (family_id);
CREATE INDEX ix_refresh_token_user ON refresh_token (user_id);

CREATE TABLE user_action_token (
    id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    uuid        NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
    purpose    varchar(30) NOT NULL,
    token_hash varchar(64) NOT NULL,
    expires_at timestamptz NOT NULL,
    used_at    timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_user_action_token_hash UNIQUE (token_hash),
    CONSTRAINT ck_user_action_token_purpose CHECK (purpose IN ('EMAIL_VERIFICATION', 'PASSWORD_RESET'))
);
CREATE INDEX ix_user_action_token_user_purpose ON user_action_token (user_id, purpose);
