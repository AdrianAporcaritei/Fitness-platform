CREATE TABLE app_user (
    id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    email             varchar(320) NOT NULL,
    password_hash     varchar(255) NOT NULL,
    role              varchar(20)  NOT NULL,
    first_name        varchar(100) NOT NULL,
    last_name         varchar(100) NOT NULL,
    locale            varchar(2)   NOT NULL,
    timezone          varchar(64)  NOT NULL,
    status            varchar(20)  NOT NULL,
    email_verified_at timestamptz,
    last_login_at     timestamptz,
    created_at        timestamptz  NOT NULL DEFAULT now(),
    updated_at        timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT uq_app_user_email UNIQUE (email),
    CONSTRAINT ck_app_user_email_lower CHECK (email = lower(email)),
    CONSTRAINT ck_app_user_role CHECK (role IN ('COACH', 'CLIENT', 'ADMIN')),
    CONSTRAINT ck_app_user_status CHECK (status IN ('PENDING', 'ACTIVE', 'SUSPENDED')),
    CONSTRAINT ck_app_user_locale CHECK (locale IN ('ro', 'en'))
);

CREATE TABLE coach_profile (
    user_id         uuid PRIMARY KEY REFERENCES app_user (id) ON DELETE CASCADE,
    bio             text,
    specializations text[] NOT NULL DEFAULT '{}',
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE coach_client (
    id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    coach_id   uuid        NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
    client_id  uuid        NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
    status     varchar(20) NOT NULL,
    invited_at timestamptz,
    started_at timestamptz,
    ended_at   timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT ck_coach_client_status CHECK (status IN ('ACTIVE', 'PAUSED', 'ENDED'))
);

CREATE UNIQUE INDEX ux_coach_client_current ON coach_client (client_id) WHERE status IN ('ACTIVE', 'PAUSED');
CREATE INDEX ix_coach_client_coach ON coach_client (coach_id);
