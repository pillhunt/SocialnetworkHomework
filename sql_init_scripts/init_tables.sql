SET search_path TO snhwdb, public;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE SEQUENCE IF NOT EXISTS public.sn_user_info_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

CREATE SEQUENCE IF NOT EXISTS public.sn_user_sessions_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

CREATE TABLE IF NOT EXISTS public.sn_user_info
(
    id bigint NOT NULL DEFAULT nextval('sn_user_info_id_seq'::regclass),
    user_id uuid NOT NULL,
    user_questionnaire_id text COLLATE pg_catalog."default",
    user_name text COLLATE pg_catalog."default",
    user_sname text COLLATE pg_catalog."default",
    user_patronimic text COLLATE pg_catalog."default",
    user_birthday date,
    user_city text COLLATE pg_catalog."default",
    user_email text COLLATE pg_catalog."default" NOT NULL,
    user_login text COLLATE pg_catalog."default" NOT NULL,
    user_password text COLLATE pg_catalog."default" NOT NULL,
    user_status smallint NOT NULL DEFAULT 1,
    user_gender smallint,
    user_personal_interest text COLLATE pg_catalog."default",
    CONSTRAINT sn_user_info_pkey PRIMARY KEY (user_id),
    CONSTRAINT sn_user_info_unique UNIQUE (user_id, user_email, user_login)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.sn_user_info
OWNER to snhwdb;

ALTER SEQUENCE public.sn_user_info_id_seq
    OWNED BY public.sn_user_info.id;

ALTER SEQUENCE public.sn_user_info_id_seq
    OWNER TO snhwdb;

-- Index: sn_userinfo_id_fname_sname_index

-- DROP INDEX IF EXISTS public.sn_userinfo_id_fname_sname_index;

CREATE INDEX IF NOT EXISTS sn_user_info_id_fname_sname_index
    ON public.sn_user_info USING btree
    (user_id ASC NULLS LAST)
    INCLUDE(user_name, user_sname, user_city)
    WITH (deduplicate_items=True)
    TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS public.sn_user_sessions
(
    id bigint NOT NULL DEFAULT nextval('sn_user_sessions_id_seq'::regclass),
    user_session_id uuid NOT NULL,
    user_id uuid NOT NULL,
    user_session_created timestamp without time zone NOT NULL,
    user_session_duration integer NOT NULL,
    user_auth_token text COLLATE pg_catalog."default" NOT NULL,
    user_session_status boolean NOT NULL DEFAULT true,
    CONSTRAINT sn_user_sessions_pkey PRIMARY KEY (user_session_id)
)


TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.sn_user_sessions
OWNER to snhwdb;

ALTER SEQUENCE public.sn_user_sessions_id_seq
    OWNED BY public.sn_user_sessions.id;

ALTER SEQUENCE public.sn_user_sessions_id_seq
    OWNER TO snhwdb;