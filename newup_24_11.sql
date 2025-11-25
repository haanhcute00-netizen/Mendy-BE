--
-- PostgreSQL database dump
--

\restrict 7WYB5k6oJrOZLQN4VjzlhNsESTicDLKkAMv0RXuiIBSun60TiDyzkRa6b1KbNdM

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

-- Started on 2025-11-24 13:51:06

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 8 (class 2615 OID 16909)
-- Name: app; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA app;


ALTER SCHEMA app OWNER TO postgres;

--
-- TOC entry 3 (class 3079 OID 17566)
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- TOC entry 6068 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- TOC entry 2 (class 3079 OID 16910)
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- TOC entry 6069 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- TOC entry 1182 (class 1247 OID 17034)
-- Name: booking_status; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.booking_status AS ENUM (
    'PENDING',
    'CONFIRMED',
    'CANCELLED',
    'COMPLETED',
    'NOSHOW'
);


ALTER TYPE app.booking_status OWNER TO postgres;

--
-- TOC entry 1194 (class 1247 OID 17084)
-- Name: gender; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.gender AS ENUM (
    'MALE',
    'FEMALE',
    'OTHER',
    'UNSPECIFIED'
);


ALTER TYPE app.gender OWNER TO postgres;

--
-- TOC entry 1305 (class 1247 OID 18645)
-- Name: media_kind; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.media_kind AS ENUM (
    'IMAGE',
    'VIDEO'
);


ALTER TYPE app.media_kind OWNER TO postgres;

--
-- TOC entry 1185 (class 1247 OID 17046)
-- Name: payment_status; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.payment_status AS ENUM (
    'INIT',
    'PENDING',
    'PAID',
    'FAILED',
    'REFUNDED',
    'REQUIRES_ACTION'
);


ALTER TYPE app.payment_status OWNER TO postgres;

--
-- TOC entry 1299 (class 1247 OID 18620)
-- Name: post_privacy; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.post_privacy AS ENUM (
    'PUBLIC',
    'FRIENDS',
    'ONLY_ME',
    'CUSTOM'
);


ALTER TYPE app.post_privacy OWNER TO postgres;

--
-- TOC entry 1311 (class 1247 OID 18665)
-- Name: reaction_kind; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.reaction_kind AS ENUM (
    'LIKE',
    'LOVE',
    'CARE',
    'HAHA',
    'WOW',
    'SAD',
    'ANGRY'
);


ALTER TYPE app.reaction_kind OWNER TO postgres;

--
-- TOC entry 1191 (class 1247 OID 17072)
-- Name: report_reason; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.report_reason AS ENUM (
    'ABUSE',
    'SELF_HARM',
    'SPAM',
    'ILLEGAL',
    'OTHER'
);


ALTER TYPE app.report_reason OWNER TO postgres;

--
-- TOC entry 1197 (class 1247 OID 17094)
-- Name: user_file_type; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.user_file_type AS ENUM (
    'AVATAR',
    'DOCUMENT',
    'OTHER'
);


ALTER TYPE app.user_file_type OWNER TO postgres;

--
-- TOC entry 1176 (class 1247 OID 17016)
-- Name: user_role; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.user_role AS ENUM (
    'SEEKER',
    'LISTENER',
    'EXPERT',
    'ADMIN'
);


ALTER TYPE app.user_role OWNER TO postgres;

--
-- TOC entry 1179 (class 1247 OID 17026)
-- Name: user_status; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.user_status AS ENUM (
    'ACTIVE',
    'SUSPENDED',
    'DELETED'
);


ALTER TYPE app.user_status OWNER TO postgres;

--
-- TOC entry 1188 (class 1247 OID 17058)
-- Name: wallet_tx_type; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.wallet_tx_type AS ENUM (
    'TOPUP',
    'WITHDRAW',
    'EARN',
    'SPEND',
    'REFUND',
    'ADJUST',
    'PAYOUT'
);


ALTER TYPE app.wallet_tx_type OWNER TO postgres;

--
-- TOC entry 1323 (class 1247 OID 18757)
-- Name: booking_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.booking_status AS ENUM (
    'PENDING',
    'CONFIRMED',
    'CANCELED',
    'COMPLETED'
);


ALTER TYPE public.booking_status OWNER TO postgres;

--
-- TOC entry 438 (class 1255 OID 18241)
-- Name: enforce_dm_member_limit(); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.enforce_dm_member_limit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  ttype text;
  cnt   integer;
BEGIN
  SELECT type INTO ttype FROM app.chat_threads WHERE id = NEW.thread_id;
  IF ttype = 'DM' THEN
    -- (UNIQUE đã chặn trùng user rồi)
    SELECT COUNT(*) INTO cnt FROM app.chat_members WHERE thread_id = NEW.thread_id;
    IF cnt >= 2 THEN
      RAISE EXCEPTION 'DM thread can only have 2 distinct members';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION app.enforce_dm_member_limit() OWNER TO postgres;

--
-- TOC entry 436 (class 1255 OID 18735)
-- Name: fn_posts_touch_updated_at(); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.fn_posts_touch_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      NEW.updated_at := now();
      RETURN NEW;
    END;
    $$;


ALTER FUNCTION app.fn_posts_touch_updated_at() OWNER TO postgres;

--
-- TOC entry 367 (class 1255 OID 18868)
-- Name: fn_reviews_touch_updated_at(); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.fn_reviews_touch_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END;
$$;


ALTER FUNCTION app.fn_reviews_touch_updated_at() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 301 (class 1259 OID 19002)
-- Name: audience; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.audience (
    id bigint NOT NULL,
    name text NOT NULL
);


ALTER TABLE app.audience OWNER TO postgres;

--
-- TOC entry 300 (class 1259 OID 19001)
-- Name: audience_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.audience_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.audience_id_seq OWNER TO postgres;

--
-- TOC entry 6070 (class 0 OID 0)
-- Dependencies: 300
-- Name: audience_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.audience_id_seq OWNED BY app.audience.id;


--
-- TOC entry 265 (class 1259 OID 17529)
-- Name: audit_logs; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.audit_logs (
    id bigint NOT NULL,
    user_id bigint,
    action text NOT NULL,
    resource text,
    resource_id bigint,
    ip_addr inet,
    user_agent text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    meta jsonb
);


ALTER TABLE app.audit_logs OWNER TO postgres;

--
-- TOC entry 264 (class 1259 OID 17528)
-- Name: audit_logs_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.audit_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.audit_logs_id_seq OWNER TO postgres;

--
-- TOC entry 6071 (class 0 OID 0)
-- Dependencies: 264
-- Name: audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.audit_logs_id_seq OWNED BY app.audit_logs.id;


--
-- TOC entry 235 (class 1259 OID 17232)
-- Name: bookings; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.bookings (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    expert_id bigint NOT NULL,
    start_at timestamp with time zone NOT NULL,
    end_at timestamp with time zone NOT NULL,
    channel text NOT NULL,
    price numeric(12,2) NOT NULL,
    status app.booking_status DEFAULT 'PENDING'::app.booking_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    time_slot tstzrange GENERATED ALWAYS AS (tstzrange(start_at, end_at, '[)'::text)) STORED,
    CONSTRAINT bookings_channel_check CHECK ((channel = ANY (ARRAY['CHAT'::text, 'VIDEO'::text, 'AUDIO'::text]))),
    CONSTRAINT bookings_price_check CHECK ((price >= (0)::numeric)),
    CONSTRAINT chk_booking_time CHECK ((end_at > start_at))
);


ALTER TABLE app.bookings OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 17231)
-- Name: bookings_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.bookings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.bookings_id_seq OWNER TO postgres;

--
-- TOC entry 6072 (class 0 OID 0)
-- Dependencies: 234
-- Name: bookings_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.bookings_id_seq OWNED BY app.bookings.id;


--
-- TOC entry 270 (class 1259 OID 18562)
-- Name: call_events; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.call_events (
    id bigint NOT NULL,
    call_id bigint NOT NULL,
    at timestamp with time zone DEFAULT now() NOT NULL,
    type text NOT NULL,
    by_user bigint,
    payload jsonb
);


ALTER TABLE app.call_events OWNER TO postgres;

--
-- TOC entry 269 (class 1259 OID 18561)
-- Name: call_events_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.call_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.call_events_id_seq OWNER TO postgres;

--
-- TOC entry 6073 (class 0 OID 0)
-- Dependencies: 269
-- Name: call_events_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.call_events_id_seq OWNED BY app.call_events.id;


--
-- TOC entry 268 (class 1259 OID 18533)
-- Name: call_sessions; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.call_sessions (
    id bigint NOT NULL,
    thread_id bigint NOT NULL,
    caller_id bigint NOT NULL,
    callee_id bigint NOT NULL,
    kind text NOT NULL,
    status text NOT NULL,
    started_at timestamp with time zone DEFAULT now(),
    connected_at timestamp with time zone,
    ended_at timestamp with time zone,
    end_reason text,
    metadata jsonb,
    booking_id bigint,
    CONSTRAINT call_sessions_kind_check CHECK ((kind = ANY (ARRAY['AUDIO'::text, 'VIDEO'::text]))),
    CONSTRAINT call_sessions_status_check CHECK ((status = ANY (ARRAY['INIT'::text, 'RINGING'::text, 'CONNECTED'::text, 'ENDED'::text, 'MISSED'::text, 'REJECTED'::text, 'BUSY'::text, 'FAILED'::text])))
);


ALTER TABLE app.call_sessions OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 18532)
-- Name: call_sessions_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.call_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.call_sessions_id_seq OWNER TO postgres;

--
-- TOC entry 6074 (class 0 OID 0)
-- Dependencies: 267
-- Name: call_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.call_sessions_id_seq OWNED BY app.call_sessions.id;


--
-- TOC entry 250 (class 1259 OID 17386)
-- Name: chat_members; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.chat_members (
    thread_id bigint NOT NULL,
    user_id bigint NOT NULL,
    role_in_thread text,
    joined_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE app.chat_members OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 17404)
-- Name: chat_messages; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.chat_messages (
    id bigint NOT NULL,
    thread_id bigint NOT NULL,
    sender_id bigint NOT NULL,
    content text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    edited_at timestamp with time zone,
    deleted_at timestamp with time zone
);


ALTER TABLE app.chat_messages OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 17403)
-- Name: chat_messages_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.chat_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.chat_messages_id_seq OWNER TO postgres;

--
-- TOC entry 6075 (class 0 OID 0)
-- Dependencies: 251
-- Name: chat_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.chat_messages_id_seq OWNED BY app.chat_messages.id;


--
-- TOC entry 266 (class 1259 OID 18246)
-- Name: chat_read_state; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.chat_read_state (
    thread_id bigint NOT NULL,
    user_id bigint NOT NULL,
    last_read_message_id bigint NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE app.chat_read_state OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 17372)
-- Name: chat_threads; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.chat_threads (
    id bigint NOT NULL,
    type text NOT NULL,
    booking_id bigint,
    last_message_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chat_threads_type_check CHECK ((type = ANY (ARRAY['DM'::text, 'BOOKING'::text])))
);


ALTER TABLE app.chat_threads OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 17371)
-- Name: chat_threads_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.chat_threads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.chat_threads_id_seq OWNER TO postgres;

--
-- TOC entry 6076 (class 0 OID 0)
-- Dependencies: 248
-- Name: chat_threads_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.chat_threads_id_seq OWNED BY app.chat_threads.id;


--
-- TOC entry 275 (class 1259 OID 18679)
-- Name: comment_reactions; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.comment_reactions (
    comment_id bigint NOT NULL,
    user_id bigint NOT NULL,
    kind app.reaction_kind NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE app.comment_reactions OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 17460)
-- Name: comments; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.comments (
    id bigint NOT NULL,
    post_id bigint NOT NULL,
    author_id bigint NOT NULL,
    anonymous boolean DEFAULT true NOT NULL,
    content text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    parent_id bigint,
    edited boolean DEFAULT false NOT NULL,
    updated_at timestamp with time zone,
    CONSTRAINT comments_parent_not_self CHECK (((parent_id IS NULL) OR (parent_id <> id)))
);


ALTER TABLE app.comments OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 17459)
-- Name: comments_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.comments_id_seq OWNER TO postgres;

--
-- TOC entry 6077 (class 0 OID 0)
-- Dependencies: 256
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.comments_id_seq OWNED BY app.comments.id;


--
-- TOC entry 263 (class 1259 OID 17514)
-- Name: consents; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.consents (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    version text NOT NULL,
    consented_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE app.consents OWNER TO postgres;

--
-- TOC entry 262 (class 1259 OID 17513)
-- Name: consents_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.consents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.consents_id_seq OWNER TO postgres;

--
-- TOC entry 6078 (class 0 OID 0)
-- Dependencies: 262
-- Name: consents_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.consents_id_seq OWNED BY app.consents.id;


--
-- TOC entry 304 (class 1259 OID 19028)
-- Name: domains; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.domains (
    id bigint NOT NULL,
    name text NOT NULL
);


ALTER TABLE app.domains OWNER TO postgres;

--
-- TOC entry 303 (class 1259 OID 19027)
-- Name: domains_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.domains_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.domains_id_seq OWNER TO postgres;

--
-- TOC entry 6079 (class 0 OID 0)
-- Dependencies: 303
-- Name: domains_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.domains_id_seq OWNED BY app.domains.id;


--
-- TOC entry 227 (class 1259 OID 17163)
-- Name: email_verifications; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.email_verifications (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    email public.citext NOT NULL,
    otp_code character(6) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    verified boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE app.email_verifications OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 17162)
-- Name: email_verifications_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.email_verifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.email_verifications_id_seq OWNER TO postgres;

--
-- TOC entry 6080 (class 0 OID 0)
-- Dependencies: 226
-- Name: email_verifications_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.email_verifications_id_seq OWNED BY app.email_verifications.id;


--
-- TOC entry 302 (class 1259 OID 19012)
-- Name: expert_audience; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.expert_audience (
    expert_id bigint NOT NULL,
    audience_id bigint NOT NULL
);


ALTER TABLE app.expert_audience OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 17216)
-- Name: expert_availabilities; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.expert_availabilities (
    id bigint NOT NULL,
    expert_id bigint NOT NULL,
    start_at timestamp with time zone NOT NULL,
    end_at timestamp with time zone NOT NULL,
    is_recurring boolean DEFAULT false NOT NULL,
    rrule text,
    CONSTRAINT chk_avail_time CHECK ((end_at > start_at))
);


ALTER TABLE app.expert_availabilities OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 17215)
-- Name: expert_availabilities_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.expert_availabilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.expert_availabilities_id_seq OWNER TO postgres;

--
-- TOC entry 6081 (class 0 OID 0)
-- Dependencies: 232
-- Name: expert_availabilities_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.expert_availabilities_id_seq OWNED BY app.expert_availabilities.id;


--
-- TOC entry 295 (class 1259 OID 18945)
-- Name: expert_certifications; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.expert_certifications (
    id bigint NOT NULL,
    expert_id bigint NOT NULL,
    certificate_name text NOT NULL,
    issuing_org text,
    issued_at date,
    expires_at date,
    credential_url text
);


ALTER TABLE app.expert_certifications OWNER TO postgres;

--
-- TOC entry 294 (class 1259 OID 18944)
-- Name: expert_certifications_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.expert_certifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.expert_certifications_id_seq OWNER TO postgres;

--
-- TOC entry 6082 (class 0 OID 0)
-- Dependencies: 294
-- Name: expert_certifications_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.expert_certifications_id_seq OWNED BY app.expert_certifications.id;


--
-- TOC entry 305 (class 1259 OID 19038)
-- Name: expert_domain; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.expert_domain (
    expert_id bigint NOT NULL,
    domain_id bigint NOT NULL
);


ALTER TABLE app.expert_domain OWNER TO postgres;

--
-- TOC entry 293 (class 1259 OID 18931)
-- Name: expert_education; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.expert_education (
    id bigint NOT NULL,
    expert_id bigint NOT NULL,
    degree text NOT NULL,
    institution text NOT NULL,
    year_completed integer,
    description text
);


ALTER TABLE app.expert_education OWNER TO postgres;

--
-- TOC entry 292 (class 1259 OID 18930)
-- Name: expert_education_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.expert_education_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.expert_education_id_seq OWNER TO postgres;

--
-- TOC entry 6083 (class 0 OID 0)
-- Dependencies: 292
-- Name: expert_education_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.expert_education_id_seq OWNED BY app.expert_education.id;


--
-- TOC entry 291 (class 1259 OID 18917)
-- Name: expert_experience; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.expert_experience (
    id bigint NOT NULL,
    expert_id bigint NOT NULL,
    "position" text NOT NULL,
    organization text,
    years integer,
    description text,
    start_year integer,
    end_year integer
);


ALTER TABLE app.expert_experience OWNER TO postgres;

--
-- TOC entry 290 (class 1259 OID 18916)
-- Name: expert_experience_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.expert_experience_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.expert_experience_id_seq OWNER TO postgres;

--
-- TOC entry 6084 (class 0 OID 0)
-- Dependencies: 290
-- Name: expert_experience_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.expert_experience_id_seq OWNED BY app.expert_experience.id;


--
-- TOC entry 299 (class 1259 OID 18987)
-- Name: expert_media; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.expert_media (
    id bigint NOT NULL,
    expert_id bigint NOT NULL,
    media_type text NOT NULL,
    url text NOT NULL,
    title text,
    description text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE app.expert_media OWNER TO postgres;

--
-- TOC entry 298 (class 1259 OID 18986)
-- Name: expert_media_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.expert_media_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.expert_media_id_seq OWNER TO postgres;

--
-- TOC entry 6085 (class 0 OID 0)
-- Dependencies: 298
-- Name: expert_media_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.expert_media_id_seq OWNED BY app.expert_media.id;


--
-- TOC entry 296 (class 1259 OID 18958)
-- Name: expert_performance; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.expert_performance (
    expert_id bigint NOT NULL,
    response_time_avg integer,
    acceptance_rate numeric(5,2),
    completion_rate numeric(5,2),
    cancel_rate numeric(5,2),
    avg_session_duration integer,
    total_sessions integer DEFAULT 0,
    total_reviews integer DEFAULT 0,
    ai_expertise_score numeric(5,2),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE app.expert_performance OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 17180)
-- Name: expert_profiles; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.expert_profiles (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    specialties text[] NOT NULL,
    price_per_session numeric(12,2) NOT NULL,
    rating_avg numeric(2,1),
    kyc_status text DEFAULT 'PENDING'::text NOT NULL,
    intro text,
    CONSTRAINT expert_profiles_price_per_session_check CHECK ((price_per_session >= (0)::numeric)),
    CONSTRAINT expert_profiles_rating_avg_check CHECK (((rating_avg >= (0)::numeric) AND (rating_avg <= (5)::numeric)))
);


ALTER TABLE app.expert_profiles OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 17179)
-- Name: expert_profiles_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.expert_profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.expert_profiles_id_seq OWNER TO postgres;

--
-- TOC entry 6086 (class 0 OID 0)
-- Dependencies: 228
-- Name: expert_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.expert_profiles_id_seq OWNED BY app.expert_profiles.id;


--
-- TOC entry 289 (class 1259 OID 18900)
-- Name: expert_skills; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.expert_skills (
    expert_id bigint NOT NULL,
    skill_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE app.expert_skills OWNER TO postgres;

--
-- TOC entry 297 (class 1259 OID 18971)
-- Name: expert_status; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.expert_status (
    expert_id bigint NOT NULL,
    is_online boolean DEFAULT false,
    last_active_at timestamp with time zone DEFAULT now(),
    active_score numeric(5,2) DEFAULT 0,
    status_message text
);


ALTER TABLE app.expert_status OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 17199)
-- Name: listener_profiles; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.listener_profiles (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    intro text,
    verified boolean DEFAULT false NOT NULL
);


ALTER TABLE app.listener_profiles OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 17198)
-- Name: listener_profiles_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.listener_profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.listener_profiles_id_seq OWNER TO postgres;

--
-- TOC entry 6087 (class 0 OID 0)
-- Dependencies: 230
-- Name: listener_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.listener_profiles_id_seq OWNED BY app.listener_profiles.id;


--
-- TOC entry 261 (class 1259 OID 17497)
-- Name: moderation_actions; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.moderation_actions (
    id bigint NOT NULL,
    admin_id bigint,
    target_type text NOT NULL,
    target_id bigint NOT NULL,
    action text NOT NULL,
    reason text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT moderation_actions_action_check CHECK ((action = ANY (ARRAY['HIDE'::text, 'DELETE'::text, 'BAN'::text, 'WARN'::text]))),
    CONSTRAINT moderation_actions_target_type_check CHECK ((target_type = ANY (ARRAY['POST'::text, 'COMMENT'::text, 'USER'::text, 'MESSAGE'::text])))
);


ALTER TABLE app.moderation_actions OWNER TO postgres;

--
-- TOC entry 260 (class 1259 OID 17496)
-- Name: moderation_actions_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.moderation_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.moderation_actions_id_seq OWNER TO postgres;

--
-- TOC entry 6088 (class 0 OID 0)
-- Dependencies: 260
-- Name: moderation_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.moderation_actions_id_seq OWNED BY app.moderation_actions.id;


--
-- TOC entry 286 (class 1259 OID 18872)
-- Name: oauth_users; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.oauth_users (
    id bigint NOT NULL,
    app_user_id bigint NOT NULL,
    google_id text NOT NULL,
    email public.citext,
    name text,
    avatar text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE app.oauth_users OWNER TO postgres;

--
-- TOC entry 285 (class 1259 OID 18871)
-- Name: oauth_users_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.oauth_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.oauth_users_id_seq OWNER TO postgres;

--
-- TOC entry 6089 (class 0 OID 0)
-- Dependencies: 285
-- Name: oauth_users_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.oauth_users_id_seq OWNED BY app.oauth_users.id;


--
-- TOC entry 239 (class 1259 OID 17280)
-- Name: payment_intents; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.payment_intents (
    id bigint NOT NULL,
    booking_id bigint,
    user_id bigint NOT NULL,
    provider text NOT NULL,
    amount numeric(12,2) NOT NULL,
    currency text DEFAULT 'VND'::text NOT NULL,
    status app.payment_status DEFAULT 'INIT'::app.payment_status NOT NULL,
    tx_ref text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    provider_ref text,
    provider_tx text
);


ALTER TABLE app.payment_intents OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 17279)
-- Name: payment_intents_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.payment_intents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.payment_intents_id_seq OWNER TO postgres;

--
-- TOC entry 6090 (class 0 OID 0)
-- Dependencies: 238
-- Name: payment_intents_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.payment_intents_id_seq OWNED BY app.payment_intents.id;


--
-- TOC entry 241 (class 1259 OID 17304)
-- Name: payments; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.payments (
    id bigint NOT NULL,
    intent_id bigint NOT NULL,
    paid_at timestamp with time zone,
    status app.payment_status NOT NULL,
    gateway_payload jsonb
);


ALTER TABLE app.payments OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 17303)
-- Name: payments_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.payments_id_seq OWNER TO postgres;

--
-- TOC entry 6091 (class 0 OID 0)
-- Dependencies: 240
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.payments_id_seq OWNED BY app.payments.id;


--
-- TOC entry 284 (class 1259 OID 18840)
-- Name: payout_accounts; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.payout_accounts (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    bank_name text NOT NULL,
    account_number text NOT NULL,
    account_holder text,
    verified boolean DEFAULT false NOT NULL,
    verified_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE app.payout_accounts OWNER TO postgres;

--
-- TOC entry 283 (class 1259 OID 18839)
-- Name: payout_accounts_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.payout_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.payout_accounts_id_seq OWNER TO postgres;

--
-- TOC entry 6092 (class 0 OID 0)
-- Dependencies: 283
-- Name: payout_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.payout_accounts_id_seq OWNED BY app.payout_accounts.id;


--
-- TOC entry 307 (class 1259 OID 19056)
-- Name: payout_requests; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.payout_requests (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    amount numeric(14,2) NOT NULL,
    status text DEFAULT 'PENDING'::text NOT NULL,
    payout_account_id bigint NOT NULL,
    admin_note text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT payout_requests_amount_check CHECK ((amount > (0)::numeric)),
    CONSTRAINT payout_requests_status_check CHECK ((status = ANY (ARRAY['PENDING'::text, 'APPROVED'::text, 'REJECTED'::text, 'PROCESSED'::text])))
);


ALTER TABLE app.payout_requests OWNER TO postgres;

--
-- TOC entry 306 (class 1259 OID 19055)
-- Name: payout_requests_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

ALTER TABLE app.payout_requests ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME app.payout_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 272 (class 1259 OID 18629)
-- Name: post_audience; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.post_audience (
    post_id bigint NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE app.post_audience OWNER TO postgres;

--
-- TOC entry 276 (class 1259 OID 18701)
-- Name: post_files; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.post_files (
    post_id bigint NOT NULL,
    file_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE app.post_files OWNER TO postgres;

--
-- TOC entry 274 (class 1259 OID 18650)
-- Name: post_media; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.post_media (
    id bigint NOT NULL,
    post_id bigint NOT NULL,
    kind app.media_kind NOT NULL,
    url text NOT NULL,
    width integer,
    height integer,
    duration_ms integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE app.post_media OWNER TO postgres;

--
-- TOC entry 273 (class 1259 OID 18649)
-- Name: post_media_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.post_media_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.post_media_id_seq OWNER TO postgres;

--
-- TOC entry 6093 (class 0 OID 0)
-- Dependencies: 273
-- Name: post_media_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.post_media_id_seq OWNED BY app.post_media.id;


--
-- TOC entry 255 (class 1259 OID 17440)
-- Name: post_reactions; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.post_reactions (
    post_id bigint NOT NULL,
    user_id bigint NOT NULL,
    reaction app.reaction_kind NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE app.post_reactions OWNER TO postgres;

--
-- TOC entry 277 (class 1259 OID 18718)
-- Name: post_saves; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.post_saves (
    user_id bigint NOT NULL,
    post_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE app.post_saves OWNER TO postgres;

--
-- TOC entry 254 (class 1259 OID 17424)
-- Name: posts; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.posts (
    id bigint NOT NULL,
    author_id bigint NOT NULL,
    anonymous boolean DEFAULT true NOT NULL,
    title text NOT NULL,
    content text NOT NULL,
    tags text[],
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    privacy app.post_privacy DEFAULT 'PUBLIC'::app.post_privacy NOT NULL
);


ALTER TABLE app.posts OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 17423)
-- Name: posts_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.posts_id_seq OWNER TO postgres;

--
-- TOC entry 6094 (class 0 OID 0)
-- Dependencies: 253
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.posts_id_seq OWNED BY app.posts.id;


--
-- TOC entry 278 (class 1259 OID 18765)
-- Name: processed_events; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.processed_events (
    idempotency_key text NOT NULL,
    occurred_at timestamp with time zone DEFAULT now()
);


ALTER TABLE app.processed_events OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 17481)
-- Name: reports; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.reports (
    id bigint NOT NULL,
    target_type text NOT NULL,
    target_id bigint NOT NULL,
    reporter_id bigint NOT NULL,
    reason app.report_reason NOT NULL,
    details text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT reports_target_type_check CHECK ((target_type = ANY (ARRAY['POST'::text, 'COMMENT'::text, 'USER'::text, 'MESSAGE'::text])))
);


ALTER TABLE app.reports OWNER TO postgres;

--
-- TOC entry 258 (class 1259 OID 17480)
-- Name: reports_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.reports_id_seq OWNER TO postgres;

--
-- TOC entry 6095 (class 0 OID 0)
-- Dependencies: 258
-- Name: reports_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.reports_id_seq OWNED BY app.reports.id;


--
-- TOC entry 280 (class 1259 OID 18795)
-- Name: reviews; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.reviews (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    expert_id bigint NOT NULL,
    booking_id bigint,
    rating numeric(2,1) NOT NULL,
    comment text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT reviews_rating_check CHECK (((rating >= (0)::numeric) AND (rating <= (5)::numeric)))
);


ALTER TABLE app.reviews OWNER TO postgres;

--
-- TOC entry 279 (class 1259 OID 18794)
-- Name: reviews_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.reviews_id_seq OWNER TO postgres;

--
-- TOC entry 6096 (class 0 OID 0)
-- Dependencies: 279
-- Name: reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.reviews_id_seq OWNED BY app.reviews.id;


--
-- TOC entry 309 (class 1259 OID 19071)
-- Name: schema_migrations; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.schema_migrations (
    id integer NOT NULL,
    version text NOT NULL,
    name text,
    executed_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE app.schema_migrations OWNER TO postgres;

--
-- TOC entry 308 (class 1259 OID 19070)
-- Name: schema_migrations_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.schema_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.schema_migrations_id_seq OWNER TO postgres;

--
-- TOC entry 6097 (class 0 OID 0)
-- Dependencies: 308
-- Name: schema_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.schema_migrations_id_seq OWNED BY app.schema_migrations.id;


--
-- TOC entry 237 (class 1259 OID 17258)
-- Name: session_notes; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.session_notes (
    id bigint NOT NULL,
    booking_id bigint NOT NULL,
    expert_id bigint NOT NULL,
    content text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE app.session_notes OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 17257)
-- Name: session_notes_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.session_notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.session_notes_id_seq OWNER TO postgres;

--
-- TOC entry 6098 (class 0 OID 0)
-- Dependencies: 236
-- Name: session_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.session_notes_id_seq OWNED BY app.session_notes.id;


--
-- TOC entry 288 (class 1259 OID 18890)
-- Name: skills; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.skills (
    id bigint NOT NULL,
    name text NOT NULL,
    category text
);


ALTER TABLE app.skills OWNER TO postgres;

--
-- TOC entry 287 (class 1259 OID 18889)
-- Name: skills_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.skills_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.skills_id_seq OWNER TO postgres;

--
-- TOC entry 6099 (class 0 OID 0)
-- Dependencies: 287
-- Name: skills_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.skills_id_seq OWNED BY app.skills.id;


--
-- TOC entry 247 (class 1259 OID 17351)
-- Name: tips; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.tips (
    id bigint NOT NULL,
    from_user_id bigint NOT NULL,
    to_user_id bigint NOT NULL,
    amount numeric(12,2) NOT NULL,
    message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT tips_amount_check CHECK ((amount > (0)::numeric))
);


ALTER TABLE app.tips OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 17350)
-- Name: tips_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.tips_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.tips_id_seq OWNER TO postgres;

--
-- TOC entry 6100 (class 0 OID 0)
-- Dependencies: 246
-- Name: tips_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.tips_id_seq OWNED BY app.tips.id;


--
-- TOC entry 225 (class 1259 OID 17147)
-- Name: user_files; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.user_files (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    file_type app.user_file_type NOT NULL,
    file_url text NOT NULL,
    mime_type text,
    byte_size bigint,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT user_files_byte_size_check CHECK (((byte_size IS NULL) OR (byte_size >= 0)))
);


ALTER TABLE app.user_files OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 17146)
-- Name: user_files_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.user_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.user_files_id_seq OWNER TO postgres;

--
-- TOC entry 6101 (class 0 OID 0)
-- Dependencies: 224
-- Name: user_files_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.user_files_id_seq OWNED BY app.user_files.id;


--
-- TOC entry 271 (class 1259 OID 18603)
-- Name: user_follows; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.user_follows (
    follower_id bigint NOT NULL,
    followee_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE app.user_follows OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 17121)
-- Name: user_profiles; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.user_profiles (
    user_id bigint NOT NULL,
    display_name text,
    avatar_url text,
    bio text,
    gender app.gender DEFAULT 'UNSPECIFIED'::app.gender,
    year_of_birth integer,
    pii_encrypted jsonb,
    preferences jsonb,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    is_anonymous boolean DEFAULT true NOT NULL,
    CONSTRAINT user_profiles_year_of_birth_check CHECK (((year_of_birth IS NULL) OR ((year_of_birth >= 1900) AND (year_of_birth <= (EXTRACT(year FROM now()))::integer))))
);


ALTER TABLE app.user_profiles OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 17136)
-- Name: user_roles; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.user_roles (
    user_id bigint NOT NULL,
    role app.user_role NOT NULL
);


ALTER TABLE app.user_roles OWNER TO postgres;

--
-- TOC entry 282 (class 1259 OID 18822)
-- Name: user_sessions; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.user_sessions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    token text NOT NULL,
    device_info text,
    ip_address inet,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked boolean DEFAULT false NOT NULL
);


ALTER TABLE app.user_sessions OWNER TO postgres;

--
-- TOC entry 281 (class 1259 OID 18821)
-- Name: user_sessions_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.user_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.user_sessions_id_seq OWNER TO postgres;

--
-- TOC entry 6102 (class 0 OID 0)
-- Dependencies: 281
-- Name: user_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.user_sessions_id_seq OWNED BY app.user_sessions.id;


--
-- TOC entry 221 (class 1259 OID 17102)
-- Name: users; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.users (
    id bigint NOT NULL,
    handle public.citext NOT NULL,
    email public.citext,
    phone character varying(20),
    password_hash text NOT NULL,
    role_primary app.user_role DEFAULT 'SEEKER'::app.user_role NOT NULL,
    is_email_verified boolean DEFAULT false NOT NULL,
    status app.user_status DEFAULT 'ACTIVE'::app.user_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT users_email_format_check CHECK ((email OPERATOR(public.~*) '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$'::public.citext))
);


ALTER TABLE app.users OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 17101)
-- Name: users_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.users_id_seq OWNER TO postgres;

--
-- TOC entry 6103 (class 0 OID 0)
-- Dependencies: 220
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.users_id_seq OWNED BY app.users.id;


--
-- TOC entry 245 (class 1259 OID 17335)
-- Name: wallet_ledger; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.wallet_ledger (
    id bigint NOT NULL,
    wallet_id bigint NOT NULL,
    tx_type app.wallet_tx_type NOT NULL,
    amount numeric(14,2) NOT NULL,
    ref_table text,
    ref_id bigint,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT wallet_ledger_amount_check CHECK ((amount <> (0)::numeric))
);


ALTER TABLE app.wallet_ledger OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 17334)
-- Name: wallet_ledger_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.wallet_ledger_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.wallet_ledger_id_seq OWNER TO postgres;

--
-- TOC entry 6104 (class 0 OID 0)
-- Dependencies: 244
-- Name: wallet_ledger_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.wallet_ledger_id_seq OWNED BY app.wallet_ledger.id;


--
-- TOC entry 243 (class 1259 OID 17320)
-- Name: wallets; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.wallets (
    id bigint NOT NULL,
    owner_user_id bigint NOT NULL,
    balance numeric(14,2) DEFAULT 0 NOT NULL
);


ALTER TABLE app.wallets OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 17319)
-- Name: wallets_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.wallets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.wallets_id_seq OWNER TO postgres;

--
-- TOC entry 6105 (class 0 OID 0)
-- Dependencies: 242
-- Name: wallets_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.wallets_id_seq OWNED BY app.wallets.id;


--
-- TOC entry 5477 (class 2604 OID 19005)
-- Name: audience id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.audience ALTER COLUMN id SET DEFAULT nextval('app.audience_id_seq'::regclass);


--
-- TOC entry 5439 (class 2604 OID 17532)
-- Name: audit_logs id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.audit_logs ALTER COLUMN id SET DEFAULT nextval('app.audit_logs_id_seq'::regclass);


--
-- TOC entry 5401 (class 2604 OID 17235)
-- Name: bookings id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.bookings ALTER COLUMN id SET DEFAULT nextval('app.bookings_id_seq'::regclass);


--
-- TOC entry 5444 (class 2604 OID 18565)
-- Name: call_events id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.call_events ALTER COLUMN id SET DEFAULT nextval('app.call_events_id_seq'::regclass);


--
-- TOC entry 5442 (class 2604 OID 18536)
-- Name: call_sessions id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.call_sessions ALTER COLUMN id SET DEFAULT nextval('app.call_sessions_id_seq'::regclass);


--
-- TOC entry 5421 (class 2604 OID 17407)
-- Name: chat_messages id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_messages ALTER COLUMN id SET DEFAULT nextval('app.chat_messages_id_seq'::regclass);


--
-- TOC entry 5418 (class 2604 OID 17375)
-- Name: chat_threads id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_threads ALTER COLUMN id SET DEFAULT nextval('app.chat_threads_id_seq'::regclass);


--
-- TOC entry 5429 (class 2604 OID 17463)
-- Name: comments id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.comments ALTER COLUMN id SET DEFAULT nextval('app.comments_id_seq'::regclass);


--
-- TOC entry 5437 (class 2604 OID 17517)
-- Name: consents id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.consents ALTER COLUMN id SET DEFAULT nextval('app.consents_id_seq'::regclass);


--
-- TOC entry 5478 (class 2604 OID 19031)
-- Name: domains id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.domains ALTER COLUMN id SET DEFAULT nextval('app.domains_id_seq'::regclass);


--
-- TOC entry 5392 (class 2604 OID 17166)
-- Name: email_verifications id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.email_verifications ALTER COLUMN id SET DEFAULT nextval('app.email_verifications_id_seq'::regclass);


--
-- TOC entry 5399 (class 2604 OID 17219)
-- Name: expert_availabilities id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_availabilities ALTER COLUMN id SET DEFAULT nextval('app.expert_availabilities_id_seq'::regclass);


--
-- TOC entry 5468 (class 2604 OID 18948)
-- Name: expert_certifications id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_certifications ALTER COLUMN id SET DEFAULT nextval('app.expert_certifications_id_seq'::regclass);


--
-- TOC entry 5467 (class 2604 OID 18934)
-- Name: expert_education id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_education ALTER COLUMN id SET DEFAULT nextval('app.expert_education_id_seq'::regclass);


--
-- TOC entry 5466 (class 2604 OID 18920)
-- Name: expert_experience id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_experience ALTER COLUMN id SET DEFAULT nextval('app.expert_experience_id_seq'::regclass);


--
-- TOC entry 5475 (class 2604 OID 18990)
-- Name: expert_media id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_media ALTER COLUMN id SET DEFAULT nextval('app.expert_media_id_seq'::regclass);


--
-- TOC entry 5395 (class 2604 OID 17183)
-- Name: expert_profiles id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_profiles ALTER COLUMN id SET DEFAULT nextval('app.expert_profiles_id_seq'::regclass);


--
-- TOC entry 5397 (class 2604 OID 17202)
-- Name: listener_profiles id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.listener_profiles ALTER COLUMN id SET DEFAULT nextval('app.listener_profiles_id_seq'::regclass);


--
-- TOC entry 5435 (class 2604 OID 17500)
-- Name: moderation_actions id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.moderation_actions ALTER COLUMN id SET DEFAULT nextval('app.moderation_actions_id_seq'::regclass);


--
-- TOC entry 5462 (class 2604 OID 18875)
-- Name: oauth_users id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.oauth_users ALTER COLUMN id SET DEFAULT nextval('app.oauth_users_id_seq'::regclass);


--
-- TOC entry 5407 (class 2604 OID 17283)
-- Name: payment_intents id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payment_intents ALTER COLUMN id SET DEFAULT nextval('app.payment_intents_id_seq'::regclass);


--
-- TOC entry 5411 (class 2604 OID 17307)
-- Name: payments id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payments ALTER COLUMN id SET DEFAULT nextval('app.payments_id_seq'::regclass);


--
-- TOC entry 5459 (class 2604 OID 18843)
-- Name: payout_accounts id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payout_accounts ALTER COLUMN id SET DEFAULT nextval('app.payout_accounts_id_seq'::regclass);


--
-- TOC entry 5447 (class 2604 OID 18653)
-- Name: post_media id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_media ALTER COLUMN id SET DEFAULT nextval('app.post_media_id_seq'::regclass);


--
-- TOC entry 5423 (class 2604 OID 17427)
-- Name: posts id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.posts ALTER COLUMN id SET DEFAULT nextval('app.posts_id_seq'::regclass);


--
-- TOC entry 5433 (class 2604 OID 17484)
-- Name: reports id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.reports ALTER COLUMN id SET DEFAULT nextval('app.reports_id_seq'::regclass);


--
-- TOC entry 5453 (class 2604 OID 18798)
-- Name: reviews id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.reviews ALTER COLUMN id SET DEFAULT nextval('app.reviews_id_seq'::regclass);


--
-- TOC entry 5482 (class 2604 OID 19074)
-- Name: schema_migrations id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.schema_migrations ALTER COLUMN id SET DEFAULT nextval('app.schema_migrations_id_seq'::regclass);


--
-- TOC entry 5405 (class 2604 OID 17261)
-- Name: session_notes id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.session_notes ALTER COLUMN id SET DEFAULT nextval('app.session_notes_id_seq'::regclass);


--
-- TOC entry 5464 (class 2604 OID 18893)
-- Name: skills id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.skills ALTER COLUMN id SET DEFAULT nextval('app.skills_id_seq'::regclass);


--
-- TOC entry 5416 (class 2604 OID 17354)
-- Name: tips id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.tips ALTER COLUMN id SET DEFAULT nextval('app.tips_id_seq'::regclass);


--
-- TOC entry 5390 (class 2604 OID 17150)
-- Name: user_files id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_files ALTER COLUMN id SET DEFAULT nextval('app.user_files_id_seq'::regclass);


--
-- TOC entry 5456 (class 2604 OID 18825)
-- Name: user_sessions id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_sessions ALTER COLUMN id SET DEFAULT nextval('app.user_sessions_id_seq'::regclass);


--
-- TOC entry 5381 (class 2604 OID 17105)
-- Name: users id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.users ALTER COLUMN id SET DEFAULT nextval('app.users_id_seq'::regclass);


--
-- TOC entry 5414 (class 2604 OID 17338)
-- Name: wallet_ledger id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.wallet_ledger ALTER COLUMN id SET DEFAULT nextval('app.wallet_ledger_id_seq'::regclass);


--
-- TOC entry 5412 (class 2604 OID 17323)
-- Name: wallets id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.wallets ALTER COLUMN id SET DEFAULT nextval('app.wallets_id_seq'::regclass);


--
-- TOC entry 6054 (class 0 OID 19002)
-- Dependencies: 301
-- Data for Name: audience; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.audience (id, name) FROM stdin;
\.


--
-- TOC entry 6018 (class 0 OID 17529)
-- Dependencies: 265
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.audit_logs (id, user_id, action, resource, resource_id, ip_addr, user_agent, created_at, meta) FROM stdin;
1	2	DASHBOARD_VIEWED	\N	\N	::1	PostmanRuntime/7.48.0	2025-10-16 13:21:46.308111+07	{}
2	2	USERS_LIST_VIEWED	\N	\N	::1	PostmanRuntime/7.48.0	2025-10-16 13:23:40.759365+07	{"filters": {"limit": 50, "offset": 0}}
3	2	USER_VIEWED	\N	\N	::1	PostmanRuntime/7.48.0	2025-10-16 13:24:16.080379+07	{}
\.


--
-- TOC entry 5988 (class 0 OID 17232)
-- Dependencies: 235
-- Data for Name: bookings; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.bookings (id, user_id, expert_id, start_at, end_at, channel, price, status, created_at) FROM stdin;
2	6	1	2025-09-23 14:00:00+07	2025-09-23 15:00:00+07	CHAT	0.00	PENDING	2025-09-23 19:39:05.228372+07
5	4	1	2025-10-07 21:00:00+07	2025-10-07 22:00:00+07	CHAT	0.00	PENDING	2025-10-05 18:25:03.180449+07
6	8	1	2025-10-07 23:00:00+07	2025-10-08 00:00:00+07	CHAT	0.00	PENDING	2025-10-05 18:31:38.483434+07
7	4	1	2025-10-08 00:00:00+07	2025-10-08 01:00:00+07	CHAT	0.00	PENDING	2025-10-05 18:42:12.83791+07
8	4	1	2025-10-08 02:00:00+07	2025-10-08 03:00:00+07	CHAT	0.00	PENDING	2025-10-05 18:50:44.055419+07
9	5	1	2025-10-10 02:00:00+07	2025-10-10 03:00:00+07	CHAT	0.00	PENDING	2025-10-08 21:07:46.438197+07
10	5	1	2025-10-09 19:00:00+07	2025-10-09 20:00:00+07	VIDEO	0.00	CANCELLED	2025-10-08 21:08:20.931918+07
12	5	1	2025-10-15 16:00:00+07	2025-10-15 17:30:00+07	VIDEO	0.00	PENDING	2025-10-14 12:01:06.11874+07
13	5	1	2025-10-15 18:00:00+07	2025-10-15 20:30:00+07	VIDEO	0.00	PENDING	2025-10-14 12:13:19.803264+07
14	5	1	2025-10-15 08:00:00+07	2025-10-15 10:30:00+07	VIDEO	1250000.00	PENDING	2025-10-14 12:22:43.988055+07
11	5	1	2025-10-10 04:00:00+07	2025-10-10 05:00:00+07	VIDEO	0.00	COMPLETED	2025-10-09 12:45:35.689863+07
15	5	1	2025-10-16 03:00:00+07	2025-10-16 04:30:00+07	VIDEO	750000.00	COMPLETED	2025-10-15 19:22:24.467554+07
18	5	1	2025-10-16 05:00:00+07	2025-10-16 06:30:00+07	VIDEO	750000.00	COMPLETED	2025-10-15 20:39:52.391024+07
20	21	17	2025-11-23 17:00:00+07	2025-11-23 19:00:00+07	CHAT	600000.00	PENDING	2025-11-23 16:35:21.938811+07
\.


--
-- TOC entry 6023 (class 0 OID 18562)
-- Dependencies: 270
-- Data for Name: call_events; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.call_events (id, call_id, at, type, by_user, payload) FROM stdin;
1	1	2025-09-18 15:06:39.484274+07	INVITE	1	\N
2	1	2025-09-18 15:06:55.24178+07	ACCEPT	1	\N
3	1	2025-09-18 15:06:56.575249+07	ACCEPT	1	\N
4	1	2025-09-18 15:06:57.294988+07	HANGUP	1	\N
5	1	2025-09-18 15:06:57.900229+07	HANGUP	1	\N
6	1	2025-09-18 15:06:58.048108+07	HANGUP	1	\N
7	2	2025-09-18 15:06:58.509793+07	INVITE	1	\N
8	3	2025-09-18 15:06:58.992771+07	INVITE	1	\N
9	4	2025-09-18 15:06:59.608104+07	INVITE	1	\N
10	4	2025-09-18 15:07:00.069515+07	ACCEPT	1	\N
11	4	2025-09-18 15:07:00.268979+07	ACCEPT	1	\N
12	4	2025-09-18 15:07:00.440377+07	ACCEPT	1	\N
14	5	2025-09-18 18:27:55.079679+07	INVITE	5	\N
15	5	2025-09-18 18:27:58.695826+07	HANGUP	5	\N
16	6	2025-09-18 18:28:00.442508+07	INVITE	5	\N
17	7	2025-09-18 18:28:28.763965+07	INVITE	5	\N
18	8	2025-09-18 18:28:38.135876+07	INVITE	5	\N
19	8	2025-09-18 18:28:38.147939+07	RINGING	4	\N
20	8	2025-09-18 18:28:41.479469+07	ACCEPT	4	\N
21	8	2025-09-18 18:29:18.819784+07	HANGUP	4	\N
22	9	2025-09-18 18:49:14.175839+07	INVITE	5	\N
23	9	2025-09-18 18:49:14.192168+07	RINGING	4	\N
24	10	2025-09-18 18:49:23.420545+07	INVITE	5	\N
25	10	2025-09-18 18:49:23.432502+07	RINGING	4	\N
26	10	2025-09-18 18:49:23.504623+07	RINGING	4	\N
27	10	2025-09-18 18:49:27.278927+07	ACCEPT	4	\N
28	10	2025-09-18 18:49:40.301463+07	ACCEPT	4	\N
29	10	2025-09-18 18:49:49.093241+07	ACCEPT	4	\N
30	11	2025-09-18 18:50:00.652596+07	INVITE	5	\N
31	11	2025-09-18 18:50:00.671731+07	RINGING	4	\N
32	11	2025-09-18 18:50:00.759076+07	RINGING	4	\N
33	10	2025-09-18 18:50:03.684481+07	HANGUP	4	\N
34	12	2025-09-18 18:50:06.995741+07	INVITE	5	\N
35	12	2025-09-18 18:50:07.006322+07	RINGING	4	\N
36	12	2025-09-18 18:50:07.011292+07	RINGING	4	\N
37	12	2025-09-18 18:50:09.375394+07	ACCEPT	4	\N
38	12	2025-09-18 18:50:21.505774+07	HANGUP	5	\N
39	13	2025-09-18 18:50:30.967643+07	INVITE	5	\N
40	13	2025-09-18 18:50:30.977447+07	RINGING	4	\N
41	13	2025-09-18 18:50:30.990384+07	RINGING	4	\N
42	13	2025-09-18 18:50:35.160814+07	ACCEPT	4	\N
43	13	2025-09-18 18:51:15.344949+07	HANGUP	5	\N
44	14	2025-09-18 18:51:43.699113+07	INVITE	5	\N
45	14	2025-09-18 18:51:43.71262+07	RINGING	4	\N
46	14	2025-09-18 18:51:43.723477+07	RINGING	4	\N
47	14	2025-09-18 18:51:47.349199+07	ACCEPT	4	\N
48	14	2025-09-18 18:52:00.103033+07	ACCEPT	4	\N
49	14	2025-09-18 18:52:01.738754+07	ACCEPT	4	\N
50	15	2025-09-18 18:52:01.965922+07	INVITE	5	\N
51	15	2025-09-18 18:52:01.976158+07	RINGING	4	\N
52	15	2025-09-18 18:52:01.986826+07	RINGING	4	\N
53	15	2025-09-18 18:52:02.315997+07	ACCEPT	4	\N
54	15	2025-09-18 18:52:02.485391+07	ACCEPT	4	\N
55	15	2025-09-18 18:52:02.717374+07	ACCEPT	4	\N
56	15	2025-09-18 18:52:02.869429+07	ACCEPT	4	\N
57	15	2025-09-18 18:52:02.96889+07	HANGUP	5	\N
58	16	2025-09-18 18:52:04.109326+07	INVITE	5	\N
59	16	2025-09-18 18:52:04.119717+07	RINGING	4	\N
60	16	2025-09-18 18:52:04.13807+07	RINGING	4	\N
61	16	2025-09-18 18:52:05.451297+07	ACCEPT	4	\N
62	16	2025-09-18 18:52:11.594768+07	ACCEPT	4	\N
63	16	2025-09-18 18:52:21.181949+07	HANGUP	5	\N
64	17	2025-09-18 18:52:22.456517+07	INVITE	5	\N
65	17	2025-09-18 18:52:22.468584+07	RINGING	4	\N
66	17	2025-09-18 18:52:22.476167+07	RINGING	4	\N
67	17	2025-09-18 18:52:25.444144+07	ACCEPT	4	\N
68	18	2025-09-18 18:52:27.380166+07	INVITE	5	\N
69	18	2025-09-18 18:52:27.390318+07	RINGING	4	\N
70	18	2025-09-18 18:52:27.401238+07	RINGING	4	\N
71	17	2025-09-18 18:52:29.60213+07	HANGUP	4	\N
72	19	2025-09-18 18:52:32.771565+07	INVITE	5	\N
73	19	2025-09-18 18:52:32.78265+07	RINGING	4	\N
74	19	2025-09-18 18:52:32.79031+07	RINGING	4	\N
75	19	2025-09-18 18:52:35.316658+07	ACCEPT	4	\N
76	19	2025-09-18 18:53:06.272161+07	HANGUP	4	\N
77	20	2025-09-18 18:59:47.194353+07	INVITE	5	\N
78	20	2025-09-18 18:59:47.220619+07	RINGING	4	\N
79	20	2025-09-18 18:59:49.660116+07	ACCEPT	4	\N
80	20	2025-09-18 18:59:52.757754+07	ACCEPT	4	\N
81	21	2025-09-23 20:06:36.217611+07	INVITE	4	\N
82	22	2025-09-23 20:07:03.869948+07	INVITE	4	\N
83	23	2025-09-23 20:07:05.516922+07	INVITE	4	\N
84	24	2025-09-23 20:07:07.756632+07	INVITE	4	\N
85	25	2025-09-23 20:07:08.192276+07	INVITE	4	\N
86	26	2025-09-23 20:07:08.559865+07	INVITE	4	\N
87	27	2025-09-23 20:07:08.752498+07	INVITE	4	\N
88	28	2025-09-23 20:07:08.924063+07	INVITE	4	\N
89	29	2025-09-23 20:07:09.098106+07	INVITE	4	\N
90	30	2025-09-23 20:07:09.27825+07	INVITE	4	\N
91	31	2025-09-23 20:07:09.458305+07	INVITE	4	\N
92	32	2025-09-23 20:07:09.644318+07	INVITE	4	\N
93	33	2025-09-23 20:07:09.824455+07	INVITE	4	\N
94	34	2025-09-23 20:07:09.990183+07	INVITE	4	\N
95	35	2025-09-23 20:07:10.146179+07	INVITE	4	\N
96	36	2025-09-23 20:07:10.326681+07	INVITE	4	\N
97	37	2025-09-23 20:07:10.492224+07	INVITE	4	\N
98	38	2025-09-23 20:07:10.67256+07	INVITE	4	\N
99	39	2025-09-23 20:07:10.858278+07	INVITE	4	\N
100	40	2025-09-23 20:07:11.032572+07	INVITE	4	\N
101	41	2025-09-23 20:07:11.196647+07	INVITE	4	\N
102	42	2025-09-23 20:07:11.3765+07	INVITE	4	\N
103	43	2025-09-23 20:07:11.548769+07	INVITE	4	\N
104	44	2025-09-23 20:07:11.714391+07	INVITE	4	\N
105	45	2025-09-23 20:07:11.886837+07	INVITE	4	\N
106	46	2025-09-23 20:07:18.771326+07	INVITE	4	\N
107	47	2025-09-23 20:07:25.420468+07	INVITE	4	\N
108	48	2025-09-23 20:07:58.145277+07	INVITE	4	\N
109	48	2025-09-23 20:07:58.159999+07	RINGING	5	\N
110	48	2025-09-23 20:07:58.205913+07	RINGING	5	\N
111	48	2025-09-23 20:08:00.594169+07	ACCEPT	5	\N
112	48	2025-09-23 20:08:18.32158+07	HANGUP	4	\N
113	49	2025-09-23 20:08:22.663031+07	INVITE	4	\N
114	49	2025-09-23 20:08:22.675488+07	RINGING	5	\N
115	49	2025-09-23 20:08:22.747798+07	RINGING	5	\N
116	49	2025-09-23 20:08:24.38412+07	ACCEPT	5	\N
117	49	2025-09-23 20:08:35.180219+07	HANGUP	4	\N
118	50	2025-11-23 16:38:40.184713+07	INVITE	21	\N
119	50	2025-11-23 16:38:45.800812+07	ACCEPT	5	\N
120	50	2025-11-23 16:38:57.743434+07	HANGUP	5	\N
121	51	2025-11-23 16:39:04.567431+07	INVITE	21	\N
122	51	2025-11-23 16:39:08.689863+07	ACCEPT	5	\N
\.


--
-- TOC entry 6021 (class 0 OID 18533)
-- Dependencies: 268
-- Data for Name: call_sessions; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.call_sessions (id, thread_id, caller_id, callee_id, kind, status, started_at, connected_at, ended_at, end_reason, metadata, booking_id) FROM stdin;
19	3	5	4	VIDEO	ENDED	2025-09-18 18:52:32.768768+07	2025-09-18 18:52:35.303442+07	2025-09-18 18:53:06.263907+07	callee_hangup	\N	\N
1	2	1	3	VIDEO	ENDED	2025-09-18 15:06:39.472715+07	2025-09-18 15:06:56.561987+07	2025-09-18 15:06:58.045836+07	hangup	\N	\N
2	2	1	3	VIDEO	INIT	2025-09-18 15:06:58.491052+07	\N	\N	\N	\N	\N
3	2	1	3	VIDEO	INIT	2025-09-18 15:06:58.990261+07	\N	\N	\N	\N	\N
4	2	1	3	VIDEO	CONNECTED	2025-09-18 15:06:59.606092+07	2025-09-18 15:07:00.437848+07	\N	\N	\N	\N
5	3	5	5	VIDEO	ENDED	2025-09-18 18:27:55.066776+07	\N	2025-09-18 18:27:58.657924+07	caller_hangup	\N	\N
8	3	5	4	VIDEO	ENDED	2025-09-18 18:28:38.098447+07	2025-09-18 18:28:41.44174+07	2025-09-18 18:29:18.808955+07	callee_hangup	\N	\N
10	3	5	4	VIDEO	ENDED	2025-09-18 18:49:23.41783+07	2025-09-18 18:49:49.081291+07	2025-09-18 18:50:03.671639+07	callee_hangup	\N	\N
12	3	5	4	AUDIO	ENDED	2025-09-18 18:50:06.976576+07	2025-09-18 18:50:09.362455+07	2025-09-18 18:50:21.495141+07	caller_hangup	\N	\N
13	3	5	4	AUDIO	ENDED	2025-09-18 18:50:30.947898+07	2025-09-18 18:50:35.147905+07	2025-09-18 18:51:15.327537+07	caller_hangup	\N	\N
15	3	5	4	AUDIO	ENDED	2025-09-18 18:52:01.955861+07	2025-09-18 18:52:02.866771+07	2025-09-18 18:52:02.96614+07	caller_hangup	\N	\N
16	3	5	4	AUDIO	ENDED	2025-09-18 18:52:04.106858+07	2025-09-18 18:52:11.581116+07	2025-09-18 18:52:21.17831+07	caller_hangup	\N	\N
48	3	4	5	VIDEO	ENDED	2025-09-23 20:07:58.125116+07	2025-09-23 20:08:00.584997+07	2025-09-23 20:08:18.297365+07	caller_hangup	\N	\N
17	3	5	4	VIDEO	ENDED	2025-09-18 18:52:22.442486+07	2025-09-18 18:52:25.432074+07	2025-09-18 18:52:29.589338+07	callee_hangup	\N	\N
49	3	4	5	AUDIO	ENDED	2025-09-23 20:08:22.643937+07	2025-09-23 20:08:24.371388+07	2025-09-23 20:08:35.159542+07	caller_hangup	\N	\N
50	6	21	5	VIDEO	ENDED	2025-11-23 16:38:40.178184+07	2025-11-23 16:38:45.796246+07	2025-11-23 16:38:57.730746+07	hangup	\N	\N
20	3	5	4	VIDEO	ENDED	2025-09-18 18:59:47.181697+07	2025-09-18 18:59:52.745226+07	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
21	3	4	5	VIDEO	ENDED	2025-09-23 20:06:36.195711+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
6	3	5	5	VIDEO	ENDED	2025-09-18 18:28:00.404351+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
7	3	5	5	VIDEO	ENDED	2025-09-18 18:28:28.716985+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
22	3	4	5	VIDEO	ENDED	2025-09-23 20:07:03.852068+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
23	3	4	5	VIDEO	ENDED	2025-09-23 20:07:05.504583+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
9	3	5	4	VIDEO	ENDED	2025-09-18 18:49:14.166693+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
24	3	4	5	VIDEO	ENDED	2025-09-23 20:07:07.754713+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
25	3	4	5	VIDEO	ENDED	2025-09-23 20:07:08.180109+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
26	3	4	5	VIDEO	ENDED	2025-09-23 20:07:08.548471+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
27	3	4	5	VIDEO	ENDED	2025-09-23 20:07:08.750665+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
28	3	4	5	VIDEO	ENDED	2025-09-23 20:07:08.922341+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
29	3	4	5	VIDEO	ENDED	2025-09-23 20:07:09.096454+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
11	3	5	4	AUDIO	ENDED	2025-09-18 18:50:00.642126+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
30	3	4	5	VIDEO	ENDED	2025-09-23 20:07:09.276514+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
31	3	4	5	VIDEO	ENDED	2025-09-23 20:07:09.45642+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
32	3	4	5	VIDEO	ENDED	2025-09-23 20:07:09.642318+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
33	3	4	5	VIDEO	ENDED	2025-09-23 20:07:09.82262+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
34	3	4	5	VIDEO	ENDED	2025-09-23 20:07:09.988265+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
35	3	4	5	VIDEO	ENDED	2025-09-23 20:07:10.144242+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
36	3	4	5	VIDEO	ENDED	2025-09-23 20:07:10.324777+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
37	3	4	5	VIDEO	ENDED	2025-09-23 20:07:10.490317+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
38	3	4	5	VIDEO	ENDED	2025-09-23 20:07:10.670252+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
39	3	4	5	VIDEO	ENDED	2025-09-23 20:07:10.856544+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
14	3	5	4	AUDIO	ENDED	2025-09-18 18:51:43.680671+07	2025-09-18 18:52:01.7265+07	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
40	3	4	5	VIDEO	ENDED	2025-09-23 20:07:11.030518+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
41	3	4	5	VIDEO	ENDED	2025-09-23 20:07:11.194441+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
42	3	4	5	VIDEO	ENDED	2025-09-23 20:07:11.374109+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
43	3	4	5	VIDEO	ENDED	2025-09-23 20:07:11.546731+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
44	3	4	5	VIDEO	ENDED	2025-09-23 20:07:11.712486+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
45	3	4	5	VIDEO	ENDED	2025-09-23 20:07:11.884274+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
46	3	4	5	VIDEO	ENDED	2025-09-23 20:07:18.758694+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
47	3	4	5	VIDEO	ENDED	2025-09-23 20:07:25.408512+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
18	3	5	4	VIDEO	ENDED	2025-09-18 18:52:27.367723+07	\N	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
51	6	21	5	VIDEO	ENDED	2025-11-23 16:39:04.55469+07	2025-11-23 16:39:08.687406+07	2025-11-23 16:39:39.76631+07	disconnect	\N	\N
\.


--
-- TOC entry 6003 (class 0 OID 17386)
-- Dependencies: 250
-- Data for Name: chat_members; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.chat_members (thread_id, user_id, role_in_thread, joined_at) FROM stdin;
2	1	PARTICIPANT	2025-09-18 11:58:30.239937+07
2	3	PARTICIPANT	2025-09-18 11:58:30.239937+07
3	4	PARTICIPANT	2025-09-18 18:18:36.391024+07
3	5	PARTICIPANT	2025-09-18 18:18:36.391024+07
4	6	PARTICIPANT	2025-09-23 19:39:05.259633+07
4	1	PARTICIPANT	2025-09-23 19:39:05.259633+07
5	1	PARTICIPANT	2025-10-09 13:17:48.640163+07
5	5	PARTICIPANT	2025-10-09 13:17:48.640163+07
6	21	PARTICIPANT	2025-11-23 16:36:48.668606+07
6	5	PARTICIPANT	2025-11-23 16:36:48.668606+07
\.


--
-- TOC entry 6005 (class 0 OID 17404)
-- Dependencies: 252
-- Data for Name: chat_messages; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.chat_messages (id, thread_id, sender_id, content, created_at, edited_at, deleted_at) FROM stdin;
1	2	1	Xin chào Bob 👋	2025-09-18 11:59:59.304003+07	\N	\N
2	2	1	Xin chào Bob adbadj cjhadbvcjadbvmad vadvadsvsfvsfvfsvfvsfvsfvsfv👋	2025-09-18 14:48:33.903399+07	\N	\N
3	5	1	Xin chào Bob adbadj cjhadbvcjadbvmad vadvadsvsfvsfvfsvfvsfvsfvsfv👋	2025-10-09 13:19:57.821808+07	\N	\N
\.


--
-- TOC entry 6019 (class 0 OID 18246)
-- Dependencies: 266
-- Data for Name: chat_read_state; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.chat_read_state (thread_id, user_id, last_read_message_id, updated_at) FROM stdin;
5	5	3	2025-10-09 13:25:57.515098+07
\.


--
-- TOC entry 6002 (class 0 OID 17372)
-- Dependencies: 249
-- Data for Name: chat_threads; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.chat_threads (id, type, booking_id, last_message_at, created_at) FROM stdin;
1	DM	\N	2025-09-18 11:57:06.029006+07	2025-09-18 11:57:06.029006+07
2	DM	\N	2025-09-18 14:48:33.930167+07	2025-09-18 11:58:30.226518+07
3	DM	\N	2025-09-18 18:18:36.387743+07	2025-09-18 18:18:36.387743+07
4	BOOKING	2	2025-09-23 19:39:05.251839+07	2025-09-23 19:39:05.251839+07
5	DM	\N	2025-10-09 13:19:57.850905+07	2025-10-09 13:17:48.635687+07
6	DM	\N	2025-11-23 16:36:48.665428+07	2025-11-23 16:36:48.665428+07
\.


--
-- TOC entry 6028 (class 0 OID 18679)
-- Dependencies: 275
-- Data for Name: comment_reactions; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.comment_reactions (comment_id, user_id, kind, created_at) FROM stdin;
\.


--
-- TOC entry 6010 (class 0 OID 17460)
-- Dependencies: 257
-- Data for Name: comments; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.comments (id, post_id, author_id, anonymous, content, created_at, parent_id, edited, updated_at) FROM stdin;
2	6	7	t	Bài viết hay quá!	2025-09-26 12:08:22.516113+07	\N	f	\N
3	9	5	t	Bài viết hay quá!	2025-10-09 13:32:13.153475+07	\N	f	\N
\.


--
-- TOC entry 6016 (class 0 OID 17514)
-- Dependencies: 263
-- Data for Name: consents; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.consents (id, user_id, version, consented_at) FROM stdin;
\.


--
-- TOC entry 6057 (class 0 OID 19028)
-- Dependencies: 304
-- Data for Name: domains; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.domains (id, name) FROM stdin;
\.


--
-- TOC entry 5980 (class 0 OID 17163)
-- Dependencies: 227
-- Data for Name: email_verifications; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.email_verifications (id, user_id, email, otp_code, expires_at, verified, created_at) FROM stdin;
1	1	skinss246@gmail.com	700967	2025-09-16 21:57:04.56+07	t	2025-09-16 21:47:04.606102+07
14	5	nguyenquyhoang.dh2022@gmail.com	127802	2025-10-09 14:07:11.351+07	t	2025-10-09 13:57:11.391595+07
\.


--
-- TOC entry 6055 (class 0 OID 19012)
-- Dependencies: 302
-- Data for Name: expert_audience; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.expert_audience (expert_id, audience_id) FROM stdin;
\.


--
-- TOC entry 5986 (class 0 OID 17216)
-- Dependencies: 233
-- Data for Name: expert_availabilities; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.expert_availabilities (id, expert_id, start_at, end_at, is_recurring, rrule) FROM stdin;
\.


--
-- TOC entry 6048 (class 0 OID 18945)
-- Dependencies: 295
-- Data for Name: expert_certifications; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.expert_certifications (id, expert_id, certificate_name, issuing_org, issued_at, expires_at, credential_url) FROM stdin;
\.


--
-- TOC entry 6058 (class 0 OID 19038)
-- Dependencies: 305
-- Data for Name: expert_domain; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.expert_domain (expert_id, domain_id) FROM stdin;
\.


--
-- TOC entry 6046 (class 0 OID 18931)
-- Dependencies: 293
-- Data for Name: expert_education; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.expert_education (id, expert_id, degree, institution, year_completed, description) FROM stdin;
\.


--
-- TOC entry 6044 (class 0 OID 18917)
-- Dependencies: 291
-- Data for Name: expert_experience; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.expert_experience (id, expert_id, "position", organization, years, description, start_year, end_year) FROM stdin;
\.


--
-- TOC entry 6052 (class 0 OID 18987)
-- Dependencies: 299
-- Data for Name: expert_media; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.expert_media (id, expert_id, media_type, url, title, description, created_at) FROM stdin;
\.


--
-- TOC entry 6049 (class 0 OID 18958)
-- Dependencies: 296
-- Data for Name: expert_performance; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.expert_performance (expert_id, response_time_avg, acceptance_rate, completion_rate, cancel_rate, avg_session_duration, total_sessions, total_reviews, ai_expertise_score, updated_at) FROM stdin;
\.


--
-- TOC entry 5982 (class 0 OID 17180)
-- Dependencies: 229
-- Data for Name: expert_profiles; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.expert_profiles (id, user_id, specialties, price_per_session, rating_avg, kyc_status, intro) FROM stdin;
1	7	{}	0.00	\N	PENDING	New expert
2	9	{}	0.00	\N	PENDING	New expert
3	1	{Anxiety,Depression,Relationship}	500000.00	5.0	PENDING	I'm a licensed therapist with 5 years of experience...
4	17	{stress,anxiety,life-coaching}	300000.00	4.8	PENDING	10 năm kinh nghiệm life coaching
5	18	{marriage,family-conflict,relationship}	350000.00	4.9	PENDING	15 năm kinh nghiệm tư vấn hôn nhân gia đình
6	19	{career,productivity,interview}	250000.00	4.7	PENDING	Hỗ trợ định hướng nghề nghiệp & kỹ năng phỏng vấn
7	20	{depression,anxiety,healing}	400000.00	5.0	PENDING	10 năm kinh nghiệm trị liệu trầm cảm và sang chấn
\.


--
-- TOC entry 6042 (class 0 OID 18900)
-- Dependencies: 289
-- Data for Name: expert_skills; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.expert_skills (expert_id, skill_id, created_at) FROM stdin;
\.


--
-- TOC entry 6050 (class 0 OID 18971)
-- Dependencies: 297
-- Data for Name: expert_status; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.expert_status (expert_id, is_online, last_active_at, active_score, status_message) FROM stdin;
4	t	2025-11-18 22:49:07.333623+07	0.00	\N
5	f	2025-11-18 22:51:08.462332+07	0.00	\N
6	t	2025-11-18 22:51:16.311789+07	0.00	\N
7	t	2025-11-18 22:51:21.317694+07	0.00	\N
\.


--
-- TOC entry 5984 (class 0 OID 17199)
-- Dependencies: 231
-- Data for Name: listener_profiles; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.listener_profiles (id, user_id, intro, verified) FROM stdin;
\.


--
-- TOC entry 6014 (class 0 OID 17497)
-- Dependencies: 261
-- Data for Name: moderation_actions; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.moderation_actions (id, admin_id, target_type, target_id, action, reason, created_at) FROM stdin;
\.


--
-- TOC entry 6039 (class 0 OID 18872)
-- Dependencies: 286
-- Data for Name: oauth_users; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.oauth_users (id, app_user_id, google_id, email, name, avatar, created_at) FROM stdin;
1	15	113893440272545257057	skytua121@gmail.com	Tiến Võ Đức	https://lh3.googleusercontent.com/a/ACg8ocJc8Ma3D2iEvKA7TJgR8P29fDAs8zrCf89P9LZCga_Iv7kCs2OR=s96-c	2025-11-14 15:24:34.241407+07
2	16	107111890882708815722	2254810130@vaa.edu.vn	TIEN VO DUC	https://lh3.googleusercontent.com/a/ACg8ocK44KKLwXJDpgQSk5uQgMdtZcn_dJVSDIQsmikTFL46u1_AIQ=s96-c	2025-11-17 11:00:04.875516+07
\.


--
-- TOC entry 5992 (class 0 OID 17280)
-- Dependencies: 239
-- Data for Name: payment_intents; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.payment_intents (id, booking_id, user_id, provider, amount, currency, status, tx_ref, metadata, created_at, provider_ref, provider_tx) FROM stdin;
1	7	4	MOMO	1.00	VND	REQUIRES_ACTION	\N	{"requestType": "captureWallet"}	2025-10-05 18:48:46.164999+07	BK7_1759664926162	\N
2	8	4	MOMO	1.00	VND	REQUIRES_ACTION	\N	{"requestType": "captureWallet"}	2025-10-05 18:51:00.154789+07	BK8_1759665060153	\N
3	8	4	MOMO	1000.00	VND	REQUIRES_ACTION	\N	{"requestType": "captureWallet"}	2025-10-05 18:54:13.726285+07	BK8_1759665253724	\N
4	10	5	MOMO	1000.00	VND	REQUIRES_ACTION	\N	{"requestType": "captureWallet"}	2025-10-09 14:00:33.087209+07	BK10_1759993233085	\N
5	11	5	MOMO	1000.00	VND	REQUIRES_ACTION	\N	{"requestType": "captureWallet"}	2025-10-09 14:03:05.571509+07	BK11_1759993385570	\N
6	12	5	MOMO	1000.00	VND	REQUIRES_ACTION	\N	{"requestType": "captureWallet"}	2025-10-14 12:01:06.22644+07	BK12_1760418066224	\N
7	13	5	MOMO	1000.00	VND	REQUIRES_ACTION	\N	{"requestType": "captureWallet"}	2025-10-14 12:13:19.859374+07	BK13_1760418799857	\N
8	14	5	MOMO	1250000.00	VND	REQUIRES_ACTION	\N	{"requestType": "captureWallet"}	2025-10-14 12:22:44.016631+07	BK14_1760419364014	\N
9	15	5	MOMO	750000.00	VND	REQUIRES_ACTION	\N	{"requestType": "captureWallet"}	2025-10-15 19:22:24.493579+07	BK15_1760530944491	\N
10	18	5	MOMO	750000.00	VND	REQUIRES_ACTION	\N	{"requestType": "captureWallet"}	2025-10-15 20:39:52.391024+07	BK18_1760535592405	\N
11	20	21	MOMO	600000.00	VND	REQUIRES_ACTION	\N	{"requestType": "captureWallet"}	2025-11-23 16:35:21.938811+07	BK20_1763890521951	\N
\.


--
-- TOC entry 5994 (class 0 OID 17304)
-- Dependencies: 241
-- Data for Name: payments; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.payments (id, intent_id, paid_at, status, gateway_payload) FROM stdin;
\.


--
-- TOC entry 6037 (class 0 OID 18840)
-- Dependencies: 284
-- Data for Name: payout_accounts; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.payout_accounts (id, user_id, bank_name, account_number, account_holder, verified, verified_at, created_at) FROM stdin;
1	1	VCB	1234567890	Nguyễn Văn A	f	\N	2025-10-16 13:14:12.287422+07
\.


--
-- TOC entry 6060 (class 0 OID 19056)
-- Dependencies: 307
-- Data for Name: payout_requests; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.payout_requests (id, user_id, amount, status, payout_account_id, admin_note, created_at, updated_at) FROM stdin;
1	1	200000.00	REJECTED	1	Test Rejection	2025-11-21 17:55:11.881242+07	2025-11-21 17:55:11.931534+07
\.


--
-- TOC entry 6025 (class 0 OID 18629)
-- Dependencies: 272
-- Data for Name: post_audience; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.post_audience (post_id, user_id) FROM stdin;
\.


--
-- TOC entry 6029 (class 0 OID 18701)
-- Dependencies: 276
-- Data for Name: post_files; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.post_files (post_id, file_id, created_at) FROM stdin;
\.


--
-- TOC entry 6027 (class 0 OID 18650)
-- Dependencies: 274
-- Data for Name: post_media; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.post_media (id, post_id, kind, url, width, height, duration_ms, created_at) FROM stdin;
\.


--
-- TOC entry 6008 (class 0 OID 17440)
-- Dependencies: 255
-- Data for Name: post_reactions; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.post_reactions (post_id, user_id, reaction, created_at) FROM stdin;
\.


--
-- TOC entry 6030 (class 0 OID 18718)
-- Dependencies: 277
-- Data for Name: post_saves; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.post_saves (user_id, post_id, created_at) FROM stdin;
\.


--
-- TOC entry 6007 (class 0 OID 17424)
-- Dependencies: 254
-- Data for Name: posts; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.posts (id, author_id, anonymous, title, content, tags, created_at, updated_at, privacy) FROM stdin;
6	4	t	Hello world	Nội dung bài viết đầu tiên	\N	2025-09-26 11:35:25.999037+07	2025-09-26 11:35:25.999037+07	PUBLIC
8	9	t	Hello world fdafadfadf	Nội dung bài viết đầu tiên àdsafadfaf	\N	2025-10-08 20:56:24.861694+07	2025-10-08 20:56:24.861694+07	PUBLIC
9	5	t	Hello world fdafadfadf	Nội dung bài viết đầu tiên àdsafadfaf	\N	2025-10-09 13:31:38.529154+07	2025-10-09 13:31:38.529154+07	PUBLIC
\.


--
-- TOC entry 6031 (class 0 OID 18765)
-- Dependencies: 278
-- Data for Name: processed_events; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.processed_events (idempotency_key, occurred_at) FROM stdin;
\.


--
-- TOC entry 6012 (class 0 OID 17481)
-- Dependencies: 259
-- Data for Name: reports; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.reports (id, target_type, target_id, reporter_id, reason, details, created_at) FROM stdin;
\.


--
-- TOC entry 6033 (class 0 OID 18795)
-- Dependencies: 280
-- Data for Name: reviews; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.reviews (id, user_id, expert_id, booking_id, rating, comment, created_at, updated_at) FROM stdin;
2	5	1	18	5.0	Chuyên gia rất tận tâm và giỏi	2025-10-15 20:41:20.522902+07	2025-10-15 20:41:20.522902+07
\.


--
-- TOC entry 6062 (class 0 OID 19071)
-- Dependencies: 309
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.schema_migrations (id, version, name, executed_at) FROM stdin;
1	000_tracking	Initialize migration tracking	2025-11-21 19:20:24.816692+07
3	001_create_payout_requests	001_create_payout_requests.sql	2025-11-21 20:35:08.990008+07
4	002_add_performance_indexes	002_add_performance_indexes.sql	2025-11-21 20:35:08.997636+07
\.


--
-- TOC entry 5990 (class 0 OID 17258)
-- Dependencies: 237
-- Data for Name: session_notes; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.session_notes (id, booking_id, expert_id, content, created_at) FROM stdin;
\.


--
-- TOC entry 6041 (class 0 OID 18890)
-- Dependencies: 288
-- Data for Name: skills; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.skills (id, name, category) FROM stdin;
\.


--
-- TOC entry 6000 (class 0 OID 17351)
-- Dependencies: 247
-- Data for Name: tips; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.tips (id, from_user_id, to_user_id, amount, message, created_at) FROM stdin;
\.


--
-- TOC entry 5978 (class 0 OID 17147)
-- Dependencies: 225
-- Data for Name: user_files; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.user_files (id, user_id, file_type, file_url, mime_type, byte_size, created_at) FROM stdin;
\.


--
-- TOC entry 6024 (class 0 OID 18603)
-- Dependencies: 271
-- Data for Name: user_follows; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.user_follows (follower_id, followee_id, created_at) FROM stdin;
5	1	2025-10-09 13:44:52.687741+07
\.


--
-- TOC entry 5975 (class 0 OID 17121)
-- Dependencies: 222
-- Data for Name: user_profiles; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.user_profiles (user_id, display_name, avatar_url, bio, gender, year_of_birth, pii_encrypted, preferences, updated_at, is_anonymous) FROM stdin;
1	ThS. lê văn Vĩ	/uploads/6ae01e28-dcac-4244-b2e4-1800ce3e82be.png	\N	MALE	2000	\N	{"attachment_url": "/uploads/c3adcc40-8ce9-4ea3-b57c-aabf13bdf7ff.pdf"}	2025-09-18 13:20:18.428364+07	t
7	ThS. Đỗ Thành Đạt	/uploads/fbfdae6b-fcb7-46ef-9404-84c8dc9934d4.png	\N	MALE	1998	\N	{"attachment_url": "/uploads/7082994a-eb45-4c05-bdb2-2afb9df12f06.pdf"}	2025-09-23 19:38:29.3419+07	t
9	ThS. Đỗ Thành Đạt long	/uploads/9d09b5fd-a1de-4869-bd38-2ad29ce09854.png	\N	MALE	1998	\N	{"attachment_url": "/uploads/a78eb362-84da-40f3-923f-87071bdfea6f.pdf"}	2025-10-08 20:11:59.962319+07	t
17	John Miller	\N	Life coach chuyên về stress & anxiety	MALE	1985	\N	\N	2025-11-18 22:49:07.333623+07	t
18	Linda Parker	\N	Chuyên gia trị liệu hôn nhân gia đình	FEMALE	1980	\N	\N	2025-11-18 22:51:08.462332+07	t
19	Kevin Smith	\N	Chuyên gia định hướng nghề nghiệp	MALE	1990	\N	\N	2025-11-18 22:51:16.311789+07	t
20	Sara Johnson	\N	Trị liệu tâm lý – trầm cảm & lo âu	FEMALE	1987	\N	\N	2025-11-18 22:51:21.317694+07	t
\.


--
-- TOC entry 5976 (class 0 OID 17136)
-- Dependencies: 223
-- Data for Name: user_roles; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.user_roles (user_id, role) FROM stdin;
\.


--
-- TOC entry 6035 (class 0 OID 18822)
-- Dependencies: 282
-- Data for Name: user_sessions; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.user_sessions (id, user_id, token, device_info, ip_address, expires_at, created_at, revoked) FROM stdin;
1	9	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTkyNjI3MCwiZXhwIjoxNzYyNTE4MjcwLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.kDWDalTAsS4QGdDB8_rX-K2VgKnmTJRVusblYI0AiHc	PostmanRuntime/7.48.0	::1	2025-10-08 20:24:30.835+07	2025-10-08 19:24:30.836841+07	f
2	9	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTkyNzQxOSwiZXhwIjoxNzYyNTE5NDE5LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.hJ0TTg-RyOpBj1s_TdfQTs6gK3MgfzIO_irWsAy6nVo	PostmanRuntime/7.48.0	::1	2025-10-08 20:43:39.291+07	2025-10-08 19:43:39.292884+07	f
3	9	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTkyNzQyMiwiZXhwIjoxNzYyNTE5NDIyLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.MHXFG1bSvF3JyfPvsOS_EvIh3G9DHP4P_mA-9h9D1ko	PostmanRuntime/7.48.0	::1	2025-10-08 20:43:42.424+07	2025-10-08 19:43:42.42619+07	f
4	9	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTkyOTEwNSwiZXhwIjoxNzYyNTIxMTA1LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.5TU2-ci_JyDVWh7IdsJ0wMZ7jew6VErGaYH7cumQjxY	PostmanRuntime/7.48.0	::1	2025-10-08 21:11:45.91+07	2025-10-08 20:11:45.911466+07	f
5	9	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTkyOTg3NywiZXhwIjoxNzYyNTIxODc3LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.HP-_B8Yr-eSWkK5A3AIg6pCKMW8l-jL5nA5E9Iol0DQ	PostmanRuntime/7.48.0	::1	2025-10-08 21:24:37.814+07	2025-10-08 20:24:37.815335+07	f
6	9	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTkzMDc5NiwiZXhwIjoxNzYyNTIyNzk2LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.ZU4Ipz_lIlufdCY53MgLWeMBLoMXMWXkAkjWY5Zw3XA	PostmanRuntime/7.48.0	::1	2025-10-08 21:39:56.405+07	2025-10-08 20:39:56.406838+07	f
7	9	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTkzMTEzNiwiZXhwIjoxNzYyNTIzMTM2LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.XpFJfqkX3mqajaFp51X6Gmt3xVnRnodtjvgsB4PkO6Y	PostmanRuntime/7.48.0	::1	2025-10-08 21:45:36.706+07	2025-10-08 20:45:36.707824+07	f
8	9	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTkzMTkxOSwiZXhwIjoxNzYyNTIzOTE5LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.S7DhmIAPFz5eQ_4D460GiJ28LHEEbqQblcc4_ApOwn8	PostmanRuntime/7.48.0	::1	2025-10-08 21:58:39.83+07	2025-10-08 20:58:39.832011+07	f
9	9	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTkzMTkzOCwiZXhwIjoxNzYyNTIzOTM4LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.5kU_9FtE4sAKdo7xlXYsRdAwLjeV0aQKW6x6MiZDppk	PostmanRuntime/7.48.0	::1	2025-10-08 21:58:58.165+07	2025-10-08 20:58:58.16645+07	f
10	9	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTkzMjE4MCwiZXhwIjoxNzYyNTI0MTgwLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.drvAUANwpiAYyb2OxwLEAaDgUCWAZA4o4uH-ONw_aI4	PostmanRuntime/7.48.0	::1	2025-10-08 22:03:00.22+07	2025-10-08 21:03:00.221123+07	f
11	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTkzMjMyOCwiZXhwIjoxNzYyNTI0MzI4LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.BQd7e7AhR1CwpG5T-Rrojx6h1A3B8ljAWoCab9gyUAk	PostmanRuntime/7.48.0	::1	2025-10-08 22:05:28.373+07	2025-10-08 21:05:28.373862+07	f
12	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTkzMjU2NSwiZXhwIjoxNzYyNTI0NTY1LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.hB5SQ-kFZXqnvzDoNTp_TiJugnNV8gp151nsx86bBc0	PostmanRuntime/7.48.0	::1	2025-10-08 22:09:25.86+07	2025-10-08 21:09:25.860999+07	f
13	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTkzMjYxNCwiZXhwIjoxNzYyNTI0NjE0LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.gqztv7zQUPRp9rSLXJbnWIrwQoV3pMr78NPs8xBVncI	PostmanRuntime/7.48.0	::1	2025-10-08 22:10:14.028+07	2025-10-08 21:10:14.028723+07	f
14	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTk4NzAxNiwiZXhwIjoxNzYyNTc5MDE2LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.FdcpZKOxCfwffu8oT3sZMCJ1r2yfq_tKHgjIm8C00gU	PostmanRuntime/7.48.0	::1	2025-10-09 13:16:56.085+07	2025-10-09 12:16:56.087183+07	f
15	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTk4NzM2MiwiZXhwIjoxNzYyNTc5MzYyLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.0JNK2a--ATb03PWMyUmSiVKuIIbaLajOLzXKIEfNOOc	PostmanRuntime/7.48.0	::1	2025-10-09 13:22:42.234+07	2025-10-09 12:22:42.2355+07	f
16	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTk4ODIyNCwiZXhwIjoxNzYyNTgwMjI0LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.D00_OVYLBcDwzqbCtTeDK14gQDFtOcq2YXVSREQgsBQ	PostmanRuntime/7.48.0	::1	2025-10-09 13:37:04.157+07	2025-10-09 12:37:04.158366+07	f
17	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTk4ODI5NSwiZXhwIjoxNzYyNTgwMjk1LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.z4AdApXJxMOdLU6z0XGBZ2GHbMe-_eCFCi-iwjdJIzQ	PostmanRuntime/7.48.0	::1	2025-10-09 13:38:15.203+07	2025-10-09 12:38:15.204119+07	f
18	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTk5MDI3MywiZXhwIjoxNzYyNTgyMjczLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.v3UEaak04oBpcGQI5D2RBpgT-80pibmA5gLWm315ZCI	PostmanRuntime/7.48.0	::1	2025-10-09 14:11:13.787+07	2025-10-09 13:11:13.788307+07	f
19	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTk5MDM5MSwiZXhwIjoxNzYyNTgyMzkxLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.NYUBBBdGqaKAYZ6V5TpVBZRQykUxsV-eg2wLezCbhpI	PostmanRuntime/7.48.0	::1	2025-10-09 14:13:11.978+07	2025-10-09 13:13:11.979729+07	f
20	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDEwMjM1MiwiZXhwIjoxNzYyNjk0MzUyLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.Xv83UVWlVYuOzpNu7lGTbxauf36ryDx9AaK_86X0u-8	PostmanRuntime/7.48.0	::1	2025-10-10 21:19:12.385+07	2025-10-10 20:19:12.386733+07	f
21	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDEwMjM4OSwiZXhwIjoxNzYyNjk0Mzg5LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.OftYyRD_8R_3JYWq9-sxNbGVIJGX7VSDqOSm5AhIjuk	PostmanRuntime/7.48.0	::1	2025-10-10 21:19:49.46+07	2025-10-10 20:19:49.462185+07	f
22	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDEwNzIyMSwiZXhwIjoxNzYyNjk5MjIxLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.ZWxbE3lAP71jOEG6thTEVzW78LQ22MNQ4UtB4ZCGF0c	PostmanRuntime/7.48.0	::1	2025-10-10 22:40:21.822+07	2025-10-10 21:40:21.824461+07	f
23	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDEwNzI0MywiZXhwIjoxNzYyNjk5MjQzLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.JKPY8I8nla49MIdtXppqAm7g-diwgCt8HO3_57SQ_Hw	PostmanRuntime/7.48.0	::1	2025-10-10 22:40:43.634+07	2025-10-10 21:40:43.63662+07	f
24	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDQxNzYzNywiZXhwIjoxNzYzMDA5NjM3LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.7ohWBBCWuDyiSqwSwTIHQAIe5CBYbWu7rZSWJXwIb5A	PostmanRuntime/7.48.0	::1	2025-10-14 12:53:57.851+07	2025-10-14 11:53:57.854381+07	f
25	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDQxNzY1MCwiZXhwIjoxNzYzMDA5NjUwLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.MUbEh8iuw_lvnsMlL1a9fEjAAtlkP0WFAusb3VPuTFU	PostmanRuntime/7.48.0	::1	2025-10-14 12:54:10.947+07	2025-10-14 11:54:10.9493+07	f
26	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDQxOTA4OCwiZXhwIjoxNzYzMDExMDg4LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.YWlGBEVQjRN9xF2LbgOdUSY1XPixgzgtHdyCZSy-vV4	PostmanRuntime/7.48.0	::1	2025-10-14 13:18:08.278+07	2025-10-14 12:18:08.281166+07	f
27	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDQxOTE1MywiZXhwIjoxNzYzMDExMTUzLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.Y3Ooy_C21jvkeKwvtnWUYn_PUJz8SNJc3k6lu5viVUw	PostmanRuntime/7.48.0	::1	2025-10-14 13:19:13.112+07	2025-10-14 12:19:13.115035+07	f
28	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDQxOTMyOSwiZXhwIjoxNzYzMDExMzI5LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.V-e_0aRucGNMW_h0I2RZTnBr9IO5xPJGOiamtltz8AU	PostmanRuntime/7.48.0	::1	2025-10-14 13:22:09.123+07	2025-10-14 12:22:09.125115+07	f
29	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDQzNDIyNCwiZXhwIjoxNzYzMDI2MjI0LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.6cJN40CHZ9rBcBmClgfqiV95VRf-DXtIvoNqJ-kgcH8	PostmanRuntime/7.48.0	::1	2025-10-14 17:30:24.748+07	2025-10-14 16:30:24.751384+07	f
30	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDQzNDg0MCwiZXhwIjoxNzYzMDI2ODQwLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.msMVgIemOz74O_LBez8XzTYxVqGyvaV1U2Je82kq1tI	PostmanRuntime/7.48.0	::1	2025-10-14 17:40:40.051+07	2025-10-14 16:40:40.052566+07	f
31	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDQzODQ4MSwiZXhwIjoxNzYzMDMwNDgxLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.I5Ze7GexOpOjS2sH9RwLDvGbxGz1MBKfX2uC1j1U6Gw	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::1	2025-10-14 18:41:21.145+07	2025-10-14 17:41:21.147362+07	f
32	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDUzMDg5NywiZXhwIjoxNzYzMTIyODk3LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.Xqb49FC30mjwM_o_V3DkZTldj1NV1sCbuWp8iKz0WT8	PostmanRuntime/7.48.0	::1	2025-10-15 20:21:37.872+07	2025-10-15 19:21:37.873542+07	f
33	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDUzMzEwNywiZXhwIjoxNzYzMTI1MTA3LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.mSeutgZx9_fjIfravoE7N5-jPidfJIwsgyv0puD6vcs	PostmanRuntime/7.48.0	::1	2025-10-15 20:58:27.361+07	2025-10-15 19:58:27.362828+07	f
34	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDUzMzE1NywiZXhwIjoxNzYzMTI1MTU3LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.-OrxY1THVTJekTBvLYbRq6zEAO89UQ2aBQhKCynXTMI	PostmanRuntime/7.48.0	::1	2025-10-15 20:59:17.129+07	2025-10-15 19:59:17.129996+07	f
35	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDUzNDAyNCwiZXhwIjoxNzYzMTI2MDI0LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.AfTizNSfAVaURJ6tFrj8572UQQ1BlsGLVlljtJCSPuY	PostmanRuntime/7.48.0	::1	2025-10-15 21:13:44.029+07	2025-10-15 20:13:44.030225+07	f
36	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDUzNTYzMSwiZXhwIjoxNzYzMTI3NjMxLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.IKYaTx50n5oSFkfeNp4KlmXbeR17fLZ-J7S1fnRmOR4	PostmanRuntime/7.48.0	::1	2025-10-15 21:40:31.44+07	2025-10-15 20:40:31.440866+07	f
37	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDUzNTY2NiwiZXhwIjoxNzYzMTI3NjY2LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.OhzAbXhzevh5cUnldkoyXJMtF7LDqCJGjBuOWivyKdY	PostmanRuntime/7.48.0	::1	2025-10-15 21:41:06.145+07	2025-10-15 20:41:06.146918+07	f
38	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDUzNTY2OCwiZXhwIjoxNzYzMTI3NjY4LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.D0TxymZebdrERST0m5tvJYipkIkPvmfp6Gz1bTUXEq0	PostmanRuntime/7.48.0	::1	2025-10-15 21:41:08.019+07	2025-10-15 20:41:08.020559+07	f
39	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDU5MzgyOCwiZXhwIjoxNzYzMTg1ODI4LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.IXrdvcXW41H7zlm-Mt8sgSbcKxAmb6-Wn6OwDsr_VfE	PostmanRuntime/7.48.0	::1	2025-10-16 13:50:28.37+07	2025-10-16 12:50:28.372913+07	f
40	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDU5MzgzMywiZXhwIjoxNzYzMTg1ODMzLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.LGCctukQ25OtQD-5mXJO5yjo3sF97E1WUhBCKi3Dp68	PostmanRuntime/7.48.0	::1	2025-10-16 13:50:33.812+07	2025-10-16 12:50:33.814492+07	f
41	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDU5NTMzNywiZXhwIjoxNzYzMTg3MzM3LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0._a-yMb8AOf-c9njVVJTXhMLFOCq4SvS_OvHMy_l2B4Y	PostmanRuntime/7.48.0	::1	2025-10-16 14:15:37.882+07	2025-10-16 13:15:37.883161+07	f
42	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDU5NTQxMCwiZXhwIjoxNzYzMTg3NDEwLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.DvjOnoPVrtAXUWnzWa9oGV-iBUEtfGBc9oYdwoQ_qDo	PostmanRuntime/7.48.0	::1	2025-10-16 14:16:50.894+07	2025-10-16 13:16:50.894679+07	f
43	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDU5OTc1NSwiZXhwIjoxNzYzMTkxNzU1LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.6biRldXEp9l3gm18hLD5Ra24PpT4IeeaYdZgXj63f2k	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::1	2025-10-16 15:29:15.771+07	2025-10-16 14:29:15.772261+07	f
44	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDU5OTc3MCwiZXhwIjoxNzYzMTkxNzcwLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.fpQdCaPxVxj77sIB7ayGClVV0ybtUelhwWhS4syPv6o	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::1	2025-10-16 15:29:30.138+07	2025-10-16 14:29:30.139572+07	f
45	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDU5OTc3MiwiZXhwIjoxNzYzMTkxNzcyLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.43GwV22LKkVzlYuvZty5soV3NdVTJNPr9lrAcmFGKPY	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::1	2025-10-16 15:29:32.749+07	2025-10-16 14:29:32.750299+07	f
46	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDYwMDgwMiwiZXhwIjoxNzYzMTkyODAyLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.BLl8J4jgpN367THp2BE0j6l4k6r_HTx_J1MMDvQP5Ac	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::1	2025-10-16 15:46:42.257+07	2025-10-16 14:46:42.258372+07	f
47	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDYwMDgwNCwiZXhwIjoxNzYzMTkyODA0LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.eK7Fym1yE-8z7_TC5heR-s2PA8cdmqmLXD-KWUwfYFQ	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::1	2025-10-16 15:46:44.445+07	2025-10-16 14:46:44.446434+07	f
48	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDYwMDgwNSwiZXhwIjoxNzYzMTkyODA1LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.9_M0dl3JahjXPnn3MQ9ezhUco5Chfp2Ku6L8tGF8Ofg	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::1	2025-10-16 15:46:45.222+07	2025-10-16 14:46:45.22317+07	f
49	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDYwMDgwNSwiZXhwIjoxNzYzMTkyODA1LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.9_M0dl3JahjXPnn3MQ9ezhUco5Chfp2Ku6L8tGF8Ofg	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::1	2025-10-16 15:46:45.496+07	2025-10-16 14:46:45.49714+07	f
50	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDYwMDgwNSwiZXhwIjoxNzYzMTkyODA1LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.9_M0dl3JahjXPnn3MQ9ezhUco5Chfp2Ku6L8tGF8Ofg	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::1	2025-10-16 15:46:45.691+07	2025-10-16 14:46:45.69255+07	f
51	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDYwMDgwNSwiZXhwIjoxNzYzMTkyODA1LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.9_M0dl3JahjXPnn3MQ9ezhUco5Chfp2Ku6L8tGF8Ofg	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::1	2025-10-16 15:46:45.878+07	2025-10-16 14:46:45.879849+07	f
52	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDYwMDgxOSwiZXhwIjoxNzYzMTkyODE5LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.ULRSUi1KTPqYdBtSICaGgqLa6I3NYZBE6HmYU3et-dk	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::1	2025-10-16 15:46:59.344+07	2025-10-16 14:46:59.345566+07	f
53	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDYwMDgzMywiZXhwIjoxNzYzMTkyODMzLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.qZFSuWAKOoL3262tSwGRXjdlXgNV0Qs3DbcAaaJsFIc	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::1	2025-10-16 15:47:13.224+07	2025-10-16 14:47:13.225258+07	f
54	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MzQ3ODA1NywiZXhwIjoxNzY2MDcwMDU3LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.eW_QjQnZUmHexWpExZq-UvwY5fXko3nMoB1-GSb8vcg	PostmanRuntime/7.49.1	::1	2025-11-18 23:00:57.427+07	2025-11-18 22:00:57.429154+07	f
55	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MzQ3ODQ4OCwiZXhwIjoxNzY2MDcwNDg4LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.1dUGGFraXULo6f7D4RbjcjbLBdhZ6WZ9cRVqRTjGbCc	PostmanRuntime/7.49.1	::1	2025-11-18 23:08:08.166+07	2025-11-18 22:08:08.167825+07	f
56	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MzQ3OTIxNSwiZXhwIjoxNzY2MDcxMjE1LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.klVfq_cZSJjIOJDZ2cqqOdccml1RSnHb2JPI3Nlknu0	PostmanRuntime/7.49.1	::1	2025-11-18 23:20:15.148+07	2025-11-18 22:20:15.150161+07	f
57	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MzU0NTIyNywiZXhwIjoxNzY2MTM3MjI3LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.Kx08oWSyL_MMZe5_Z-cFBSB0xGEtgqnpdepdWETpAJM	PostmanRuntime/7.49.1	::1	2025-11-19 17:40:27.986+07	2025-11-19 16:40:27.989292+07	f
58	9	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MzU0NTI3OSwiZXhwIjoxNzY2MTM3Mjc5LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.l-6QZg7PS9YqPKUW-FCAzJ2hn5aIpQbEaoobPqof3fo	PostmanRuntime/7.49.1	::1	2025-11-19 17:41:19.863+07	2025-11-19 16:41:19.865291+07	f
59	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MzU0NTYyNSwiZXhwIjoxNzY2MTM3NjI1LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.rNFdkII5K7zqF29Rto287RCrFo1YPYa47tEj7FpiT3Q	PostmanRuntime/7.49.1	::1	2025-11-19 17:47:05.218+07	2025-11-19 16:47:05.219321+07	f
60	9	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MzcyODM1NywiZXhwIjoxNzY2MzIwMzU3LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.tCfxDIScUducHLdK82WHJQNymoxMyjuwJGzNDwYXccQ	PostmanRuntime/7.49.1	::1	2025-11-21 20:32:37.112+07	2025-11-21 19:32:37.113955+07	f
61	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMSIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjM3MjgzOTMsImV4cCI6MTc2NjMyMDM5MywiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.C6dspBAv_x97YdKIkhympt8fQxz-9nQ0XChJAPBlbwo	PostmanRuntime/7.49.1	::1	2025-11-21 20:33:13.704+07	2025-11-21 19:33:13.706035+07	f
62	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMSIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjM3MzY3MzgsImV4cCI6MTc2NjMyODczOCwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.FerxLxLzHXxpx2S9IXohAJ_dh2NWLQHGcx3Mipspx6c	PostmanRuntime/7.49.1	::1	2025-11-21 22:52:18.898+07	2025-11-21 21:52:18.899375+07	f
63	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMSIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjM3MzY4OTMsImV4cCI6MTc2NjMyODg5MywiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.EtbzFyDkRwi4iT5HUD-RuREd_sQmwkx6R0jwAsMdVrk	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-11-21 22:54:53.48+07	2025-11-21 21:54:53.481523+07	f
64	9	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MzczNzE5NCwiZXhwIjoxNzY2MzI5MTk0LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.ipvwUg7ztCYLlEu9WMKuBsT9kSXZiMBKZCfFikQQljw	PostmanRuntime/7.49.1	::1	2025-11-21 22:59:54.194+07	2025-11-21 21:59:54.195292+07	f
65	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMSIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjM3MzcyMDUsImV4cCI6MTc2NjMyOTIwNSwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.pVIDszNIpWvEZPlEw7pgZILqQ0dDLqbkKHFTvgioSYY	PostmanRuntime/7.49.1	::1	2025-11-21 23:00:05.957+07	2025-11-21 22:00:05.958859+07	f
66	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMSIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjM4OTAwMjcsImV4cCI6MTc2NjQ4MjAyNywiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.ELHoF_H4rfYVGi_dH7A0Qt7QrRBMsItSgyPxQ7jowgs	PostmanRuntime/7.49.1	::1	2025-11-23 17:27:07.322+07	2025-11-23 16:27:07.323924+07	f
67	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2Mzg5MDY4MSwiZXhwIjoxNzY2NDgyNjgxLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.gp7-9S0QRTaEvvyXRHTAeDLyaf0V7WMtK3VP2euHLsg	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	::1	2025-11-23 17:38:01.319+07	2025-11-23 16:38:01.320382+07	f
68	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMSIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjM4OTA2OTQsImV4cCI6MTc2NjQ4MjY5NCwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.lQRFuW8kjfdcTPuVBw0k2LomTjoel1hZGu4dybf-N5A	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	::1	2025-11-23 17:38:14.951+07	2025-11-23 16:38:14.951957+07	f
\.


--
-- TOC entry 5974 (class 0 OID 17102)
-- Dependencies: 221
-- Data for Name: users; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.users (id, handle, email, phone, password_hash, role_primary, is_email_verified, status, created_at, updated_at) FROM stdin;
3	user3	\N	\N	$2b$10$cPtrL8rWsBNKM7ArQ3ZOUe760WcpeE/x0hgDPvfP3QbSyE0S3m1Ee	SEEKER	f	ACTIVE	2025-09-17 10:46:43.716438+07	2025-09-17 10:46:43.716438+07
1	user1	skinss246@gmail.com	\N	$2b$10$5.CJdEP/QZq2IrWiS452PumX5UUbDg8fozTCmQn1JPNdUsHfV4llG	EXPERT	t	ACTIVE	2025-09-16 20:52:35.997355+07	2025-09-18 13:20:18.431143+07
4	phat	\N	\N	$2b$10$J6mNcwWi.CsAdqdQ/cNrk.ivl1AhaCJl40X.TKOM1TrQR1wwOcPve	SEEKER	f	ACTIVE	2025-09-18 18:17:06.316332+07	2025-09-18 18:17:06.316332+07
6	datbike	\N	\N	$2b$10$jB1N/SKHgIz7j/4Vc1FkDuR0IQAohBB0rFIrVEUU2B3/DDk39o0WK	SEEKER	f	ACTIVE	2025-09-23 19:17:05.339169+07	2025-09-23 19:17:05.339169+07
7	long999	\N	\N	$2b$10$qGL9t0CsXnOXLrEx08190.8OG6mlj0uSWeo5ZmuP.YQEi.gV/0IJi	EXPERT	f	ACTIVE	2025-09-23 19:17:15.781882+07	2025-09-23 19:38:29.346052+07
8	hoang19	\N	\N	$2b$10$EX3NTgodP.af1ou1CLaBYuxvZ0MIsCaFrp18Qc/T6JS9ELCNB5cI.	SEEKER	f	ACTIVE	2025-10-05 18:30:59.863278+07	2025-10-05 18:30:59.863278+07
9	hoang1999	\N	\N	$2b$10$owItQg6qIUYiJf0TKTTLMOiL0fHbwfGIYHgZOEPOfE1BNb/pcok1S	EXPERT	f	ACTIVE	2025-10-08 19:21:54.937956+07	2025-10-08 20:11:59.983794+07
5	hoang	nguyenquyhoang.dh2022@gmail.com	\N	$2b$10$Gk/6MSlNiw7AAyKKvHeaiuELuGXf6TWx.GMgvqKayqdl2aNCES3OW	SEEKER	t	ACTIVE	2025-09-18 18:17:12.551167+07	2025-10-09 13:57:57.400312+07
11	admin	admin@healing.com	\N	$2b$10$rOzJqQjQjQjQjQjQjQjQuOzJqQjQjQjQjQjQjQjQjQuOzJqQjQjQjQjQjQjQ	ADMIN	f	ACTIVE	2025-10-09 15:21:16.12008+07	2025-10-09 15:21:16.12008+07
13	admin1	admi3n@healing.com	\N	$2b$10$zUUXfxb0tNMV4dT4q6SE7exZox3lv15m3b42U2BIBW0f874iVc3Vu	ADMIN	f	ACTIVE	2025-10-09 15:29:57.954001+07	2025-10-09 15:29:57.954001+07
14	hoang19099	\N	\N	$2b$10$Bhw7M/gfjBfCmdI2r/k2Y.xBeQ73p.dWzlFpZBTVppIyF7hhBpZ9y	SEEKER	f	ACTIVE	2025-10-10 21:41:06.94826+07	2025-10-10 21:41:06.94826+07
2	user2	\N	\N	$2b$10$QdcLOX0A18ESIb/cCgaEg.S07H8cWXlOMf0cvPPzkhuBfUaqPxopm	ADMIN	f	ACTIVE	2025-09-17 10:46:34.854443+07	2025-09-17 10:46:34.854443+07
15	skytua121_mhyldrq9	skytua121@gmail.com	\N	GOOGLE_OAUTH_ONLY	SEEKER	f	ACTIVE	2025-11-14 15:24:34.210636+07	2025-11-14 15:24:34.210636+07
16	2254810130_mi2m96uy	2254810130@vaa.edu.vn	\N	GOOGLE_OAUTH_ONLY	SEEKER	f	ACTIVE	2025-11-17 11:00:04.85883+07	2025-11-17 11:00:04.85883+07
17	expert_john	john@example.com	0901000001	hash123	EXPERT	f	ACTIVE	2025-11-18 22:49:07.333623+07	2025-11-18 22:49:07.333623+07
18	expert_linda	linda@example.com	0901000002	hash123	EXPERT	f	ACTIVE	2025-11-18 22:51:08.462332+07	2025-11-18 22:51:08.462332+07
19	expert_kevin	kevin@example.com	0901000003	hash123	EXPERT	f	ACTIVE	2025-11-18 22:51:16.311789+07	2025-11-18 22:51:16.311789+07
20	expert_sara	sara@example.com	0901000004	hash123	EXPERT	f	ACTIVE	2025-11-18 22:51:21.317694+07	2025-11-18 22:51:21.317694+07
21	mendyu1	\N	\N	$2b$10$r5cPlO4wukdZHssAhLFm7.uthUJ8zOQpi2hyEeZz6SfxW47wWk/e6	SEEKER	f	ACTIVE	2025-11-21 19:32:55.645794+07	2025-11-21 19:32:55.645794+07
\.


--
-- TOC entry 5998 (class 0 OID 17335)
-- Dependencies: 245
-- Data for Name: wallet_ledger; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.wallet_ledger (id, wallet_id, tx_type, amount, ref_table, ref_id, created_at) FROM stdin;
1	1	EARN	500000.00	TEST_CREDIT	1763722442782	2025-11-21 17:54:02.789396+07
3	1	EARN	500000.00	TEST_CREDIT	1763722511868	2025-11-21 17:55:11.876628+07
4	1	WITHDRAW	-200000.00	PAYOUT_REQUEST	1	2025-11-21 17:55:11.881242+07
5	1	EARN	200000.00	PAYOUT_REFUND	1	2025-11-21 17:55:11.931534+07
\.


--
-- TOC entry 5996 (class 0 OID 17320)
-- Dependencies: 243
-- Data for Name: wallets; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.wallets (id, owner_user_id, balance) FROM stdin;
1	1	1000000.00
\.


--
-- TOC entry 6106 (class 0 OID 0)
-- Dependencies: 300
-- Name: audience_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.audience_id_seq', 1, false);


--
-- TOC entry 6107 (class 0 OID 0)
-- Dependencies: 264
-- Name: audit_logs_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.audit_logs_id_seq', 3, true);


--
-- TOC entry 6108 (class 0 OID 0)
-- Dependencies: 234
-- Name: bookings_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.bookings_id_seq', 20, true);


--
-- TOC entry 6109 (class 0 OID 0)
-- Dependencies: 269
-- Name: call_events_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.call_events_id_seq', 122, true);


--
-- TOC entry 6110 (class 0 OID 0)
-- Dependencies: 267
-- Name: call_sessions_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.call_sessions_id_seq', 51, true);


--
-- TOC entry 6111 (class 0 OID 0)
-- Dependencies: 251
-- Name: chat_messages_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.chat_messages_id_seq', 3, true);


--
-- TOC entry 6112 (class 0 OID 0)
-- Dependencies: 248
-- Name: chat_threads_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.chat_threads_id_seq', 6, true);


--
-- TOC entry 6113 (class 0 OID 0)
-- Dependencies: 256
-- Name: comments_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.comments_id_seq', 4, true);


--
-- TOC entry 6114 (class 0 OID 0)
-- Dependencies: 262
-- Name: consents_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.consents_id_seq', 1, false);


--
-- TOC entry 6115 (class 0 OID 0)
-- Dependencies: 303
-- Name: domains_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.domains_id_seq', 1, false);


--
-- TOC entry 6116 (class 0 OID 0)
-- Dependencies: 226
-- Name: email_verifications_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.email_verifications_id_seq', 14, true);


--
-- TOC entry 6117 (class 0 OID 0)
-- Dependencies: 232
-- Name: expert_availabilities_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.expert_availabilities_id_seq', 1, false);


--
-- TOC entry 6118 (class 0 OID 0)
-- Dependencies: 294
-- Name: expert_certifications_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.expert_certifications_id_seq', 1, false);


--
-- TOC entry 6119 (class 0 OID 0)
-- Dependencies: 292
-- Name: expert_education_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.expert_education_id_seq', 1, false);


--
-- TOC entry 6120 (class 0 OID 0)
-- Dependencies: 290
-- Name: expert_experience_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.expert_experience_id_seq', 1, false);


--
-- TOC entry 6121 (class 0 OID 0)
-- Dependencies: 298
-- Name: expert_media_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.expert_media_id_seq', 1, false);


--
-- TOC entry 6122 (class 0 OID 0)
-- Dependencies: 228
-- Name: expert_profiles_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.expert_profiles_id_seq', 7, true);


--
-- TOC entry 6123 (class 0 OID 0)
-- Dependencies: 230
-- Name: listener_profiles_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.listener_profiles_id_seq', 1, false);


--
-- TOC entry 6124 (class 0 OID 0)
-- Dependencies: 260
-- Name: moderation_actions_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.moderation_actions_id_seq', 1, false);


--
-- TOC entry 6125 (class 0 OID 0)
-- Dependencies: 285
-- Name: oauth_users_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.oauth_users_id_seq', 2, true);


--
-- TOC entry 6126 (class 0 OID 0)
-- Dependencies: 238
-- Name: payment_intents_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.payment_intents_id_seq', 11, true);


--
-- TOC entry 6127 (class 0 OID 0)
-- Dependencies: 240
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.payments_id_seq', 1, false);


--
-- TOC entry 6128 (class 0 OID 0)
-- Dependencies: 283
-- Name: payout_accounts_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.payout_accounts_id_seq', 2, true);


--
-- TOC entry 6129 (class 0 OID 0)
-- Dependencies: 306
-- Name: payout_requests_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.payout_requests_id_seq', 1, true);


--
-- TOC entry 6130 (class 0 OID 0)
-- Dependencies: 273
-- Name: post_media_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.post_media_id_seq', 1, false);


--
-- TOC entry 6131 (class 0 OID 0)
-- Dependencies: 253
-- Name: posts_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.posts_id_seq', 9, true);


--
-- TOC entry 6132 (class 0 OID 0)
-- Dependencies: 258
-- Name: reports_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.reports_id_seq', 1, false);


--
-- TOC entry 6133 (class 0 OID 0)
-- Dependencies: 279
-- Name: reviews_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.reviews_id_seq', 2, true);


--
-- TOC entry 6134 (class 0 OID 0)
-- Dependencies: 308
-- Name: schema_migrations_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.schema_migrations_id_seq', 5, true);


--
-- TOC entry 6135 (class 0 OID 0)
-- Dependencies: 236
-- Name: session_notes_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.session_notes_id_seq', 1, false);


--
-- TOC entry 6136 (class 0 OID 0)
-- Dependencies: 287
-- Name: skills_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.skills_id_seq', 1, false);


--
-- TOC entry 6137 (class 0 OID 0)
-- Dependencies: 246
-- Name: tips_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.tips_id_seq', 1, false);


--
-- TOC entry 6138 (class 0 OID 0)
-- Dependencies: 224
-- Name: user_files_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.user_files_id_seq', 1, false);


--
-- TOC entry 6139 (class 0 OID 0)
-- Dependencies: 281
-- Name: user_sessions_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.user_sessions_id_seq', 68, true);


--
-- TOC entry 6140 (class 0 OID 0)
-- Dependencies: 220
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.users_id_seq', 21, true);


--
-- TOC entry 6141 (class 0 OID 0)
-- Dependencies: 244
-- Name: wallet_ledger_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.wallet_ledger_id_seq', 5, true);


--
-- TOC entry 6142 (class 0 OID 0)
-- Dependencies: 242
-- Name: wallets_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.wallets_id_seq', 2, true);


--
-- TOC entry 5734 (class 2606 OID 19011)
-- Name: audience audience_name_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.audience
    ADD CONSTRAINT audience_name_key UNIQUE (name);


--
-- TOC entry 5736 (class 2606 OID 19009)
-- Name: audience audience_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.audience
    ADD CONSTRAINT audience_pkey PRIMARY KEY (id);


--
-- TOC entry 5649 (class 2606 OID 17537)
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 5551 (class 2606 OID 17244)
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (id);


--
-- TOC entry 5668 (class 2606 OID 18570)
-- Name: call_events call_events_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.call_events
    ADD CONSTRAINT call_events_pkey PRIMARY KEY (id);


--
-- TOC entry 5660 (class 2606 OID 18543)
-- Name: call_sessions call_sessions_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.call_sessions
    ADD CONSTRAINT call_sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 5604 (class 2606 OID 17392)
-- Name: chat_members chat_members_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_members
    ADD CONSTRAINT chat_members_pkey PRIMARY KEY (thread_id, user_id);


--
-- TOC entry 5611 (class 2606 OID 17412)
-- Name: chat_messages chat_messages_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_messages
    ADD CONSTRAINT chat_messages_pkey PRIMARY KEY (id);


--
-- TOC entry 5657 (class 2606 OID 18251)
-- Name: chat_read_state chat_read_state_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_read_state
    ADD CONSTRAINT chat_read_state_pkey PRIMARY KEY (thread_id, user_id);


--
-- TOC entry 5599 (class 2606 OID 17380)
-- Name: chat_threads chat_threads_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_threads
    ADD CONSTRAINT chat_threads_pkey PRIMARY KEY (id);


--
-- TOC entry 5680 (class 2606 OID 18684)
-- Name: comment_reactions comment_reactions_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.comment_reactions
    ADD CONSTRAINT comment_reactions_pkey PRIMARY KEY (comment_id, user_id);


--
-- TOC entry 5630 (class 2606 OID 17469)
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- TOC entry 5647 (class 2606 OID 17522)
-- Name: consents consents_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.consents
    ADD CONSTRAINT consents_pkey PRIMARY KEY (id);


--
-- TOC entry 5740 (class 2606 OID 19037)
-- Name: domains domains_name_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.domains
    ADD CONSTRAINT domains_name_key UNIQUE (name);


--
-- TOC entry 5742 (class 2606 OID 19035)
-- Name: domains domains_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.domains
    ADD CONSTRAINT domains_pkey PRIMARY KEY (id);


--
-- TOC entry 5528 (class 2606 OID 17172)
-- Name: email_verifications email_verifications_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.email_verifications
    ADD CONSTRAINT email_verifications_pkey PRIMARY KEY (id);


--
-- TOC entry 5738 (class 2606 OID 19016)
-- Name: expert_audience expert_audience_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_audience
    ADD CONSTRAINT expert_audience_pkey PRIMARY KEY (expert_id, audience_id);


--
-- TOC entry 5546 (class 2606 OID 17225)
-- Name: expert_availabilities expert_availabilities_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_availabilities
    ADD CONSTRAINT expert_availabilities_pkey PRIMARY KEY (id);


--
-- TOC entry 5726 (class 2606 OID 18952)
-- Name: expert_certifications expert_certifications_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_certifications
    ADD CONSTRAINT expert_certifications_pkey PRIMARY KEY (id);


--
-- TOC entry 5744 (class 2606 OID 19042)
-- Name: expert_domain expert_domain_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_domain
    ADD CONSTRAINT expert_domain_pkey PRIMARY KEY (expert_id, domain_id);


--
-- TOC entry 5724 (class 2606 OID 18938)
-- Name: expert_education expert_education_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_education
    ADD CONSTRAINT expert_education_pkey PRIMARY KEY (id);


--
-- TOC entry 5722 (class 2606 OID 18924)
-- Name: expert_experience expert_experience_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_experience
    ADD CONSTRAINT expert_experience_pkey PRIMARY KEY (id);


--
-- TOC entry 5732 (class 2606 OID 18995)
-- Name: expert_media expert_media_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_media
    ADD CONSTRAINT expert_media_pkey PRIMARY KEY (id);


--
-- TOC entry 5728 (class 2606 OID 18965)
-- Name: expert_performance expert_performance_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_performance
    ADD CONSTRAINT expert_performance_pkey PRIMARY KEY (expert_id);


--
-- TOC entry 5534 (class 2606 OID 17190)
-- Name: expert_profiles expert_profiles_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_profiles
    ADD CONSTRAINT expert_profiles_pkey PRIMARY KEY (id);


--
-- TOC entry 5536 (class 2606 OID 17192)
-- Name: expert_profiles expert_profiles_user_id_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_profiles
    ADD CONSTRAINT expert_profiles_user_id_key UNIQUE (user_id);


--
-- TOC entry 5720 (class 2606 OID 18905)
-- Name: expert_skills expert_skills_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_skills
    ADD CONSTRAINT expert_skills_pkey PRIMARY KEY (expert_id, skill_id);


--
-- TOC entry 5730 (class 2606 OID 18980)
-- Name: expert_status expert_status_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_status
    ADD CONSTRAINT expert_status_pkey PRIMARY KEY (expert_id);


--
-- TOC entry 5542 (class 2606 OID 17207)
-- Name: listener_profiles listener_profiles_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.listener_profiles
    ADD CONSTRAINT listener_profiles_pkey PRIMARY KEY (id);


--
-- TOC entry 5544 (class 2606 OID 17209)
-- Name: listener_profiles listener_profiles_user_id_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.listener_profiles
    ADD CONSTRAINT listener_profiles_user_id_key UNIQUE (user_id);


--
-- TOC entry 5645 (class 2606 OID 17507)
-- Name: moderation_actions moderation_actions_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.moderation_actions
    ADD CONSTRAINT moderation_actions_pkey PRIMARY KEY (id);


--
-- TOC entry 5561 (class 2606 OID 18217)
-- Name: bookings no_overlap_per_expert; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.bookings
    ADD CONSTRAINT no_overlap_per_expert EXCLUDE USING gist (expert_id WITH =, time_slot WITH &&);


--
-- TOC entry 5712 (class 2606 OID 18882)
-- Name: oauth_users oauth_users_google_id_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.oauth_users
    ADD CONSTRAINT oauth_users_google_id_key UNIQUE (google_id);


--
-- TOC entry 5714 (class 2606 OID 18880)
-- Name: oauth_users oauth_users_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.oauth_users
    ADD CONSTRAINT oauth_users_pkey PRIMARY KEY (id);


--
-- TOC entry 5572 (class 2606 OID 17290)
-- Name: payment_intents payment_intents_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payment_intents
    ADD CONSTRAINT payment_intents_pkey PRIMARY KEY (id);


--
-- TOC entry 5574 (class 2606 OID 17292)
-- Name: payment_intents payment_intents_tx_ref_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payment_intents
    ADD CONSTRAINT payment_intents_tx_ref_key UNIQUE (tx_ref);


--
-- TOC entry 5579 (class 2606 OID 17313)
-- Name: payments payments_intent_id_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payments
    ADD CONSTRAINT payments_intent_id_key UNIQUE (intent_id);


--
-- TOC entry 5581 (class 2606 OID 17311)
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- TOC entry 5708 (class 2606 OID 18849)
-- Name: payout_accounts payout_accounts_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payout_accounts
    ADD CONSTRAINT payout_accounts_pkey PRIMARY KEY (id);


--
-- TOC entry 5748 (class 2606 OID 19067)
-- Name: payout_requests payout_requests_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payout_requests
    ADD CONSTRAINT payout_requests_pkey PRIMARY KEY (id);


--
-- TOC entry 5676 (class 2606 OID 18633)
-- Name: post_audience post_audience_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_audience
    ADD CONSTRAINT post_audience_pkey PRIMARY KEY (post_id, user_id);


--
-- TOC entry 5683 (class 2606 OID 18706)
-- Name: post_files post_files_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_files
    ADD CONSTRAINT post_files_pkey PRIMARY KEY (post_id, file_id);


--
-- TOC entry 5678 (class 2606 OID 18658)
-- Name: post_media post_media_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_media
    ADD CONSTRAINT post_media_pkey PRIMARY KEY (id);


--
-- TOC entry 5628 (class 2606 OID 17448)
-- Name: post_reactions post_reactions_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_reactions
    ADD CONSTRAINT post_reactions_pkey PRIMARY KEY (post_id, user_id);


--
-- TOC entry 5686 (class 2606 OID 18723)
-- Name: post_saves post_saves_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_saves
    ADD CONSTRAINT post_saves_pkey PRIMARY KEY (user_id, post_id);


--
-- TOC entry 5623 (class 2606 OID 17434)
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- TOC entry 5688 (class 2606 OID 18772)
-- Name: processed_events processed_events_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.processed_events
    ADD CONSTRAINT processed_events_pkey PRIMARY KEY (idempotency_key);


--
-- TOC entry 5643 (class 2606 OID 17490)
-- Name: reports reports_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.reports
    ADD CONSTRAINT reports_pkey PRIMARY KEY (id);


--
-- TOC entry 5697 (class 2606 OID 18804)
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- TOC entry 5699 (class 2606 OID 18864)
-- Name: reviews reviews_user_booking_unique; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.reviews
    ADD CONSTRAINT reviews_user_booking_unique UNIQUE (user_id, booking_id);


--
-- TOC entry 5751 (class 2606 OID 19079)
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (id);


--
-- TOC entry 5753 (class 2606 OID 19081)
-- Name: schema_migrations schema_migrations_version_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.schema_migrations
    ADD CONSTRAINT schema_migrations_version_key UNIQUE (version);


--
-- TOC entry 5563 (class 2606 OID 17268)
-- Name: session_notes session_notes_booking_id_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.session_notes
    ADD CONSTRAINT session_notes_booking_id_key UNIQUE (booking_id);


--
-- TOC entry 5565 (class 2606 OID 17266)
-- Name: session_notes session_notes_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.session_notes
    ADD CONSTRAINT session_notes_pkey PRIMARY KEY (id);


--
-- TOC entry 5716 (class 2606 OID 18899)
-- Name: skills skills_name_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.skills
    ADD CONSTRAINT skills_name_key UNIQUE (name);


--
-- TOC entry 5718 (class 2606 OID 18897)
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (id);


--
-- TOC entry 5597 (class 2606 OID 17360)
-- Name: tips tips_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.tips
    ADD CONSTRAINT tips_pkey PRIMARY KEY (id);


--
-- TOC entry 5532 (class 2606 OID 17555)
-- Name: email_verifications uq_email_verif_user_all; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.email_verifications
    ADD CONSTRAINT uq_email_verif_user_all UNIQUE (user_id, email);


--
-- TOC entry 5526 (class 2606 OID 17156)
-- Name: user_files user_files_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_files
    ADD CONSTRAINT user_files_pkey PRIMARY KEY (id);


--
-- TOC entry 5674 (class 2606 OID 18608)
-- Name: user_follows user_follows_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_follows
    ADD CONSTRAINT user_follows_pkey PRIMARY KEY (follower_id, followee_id);


--
-- TOC entry 5522 (class 2606 OID 17130)
-- Name: user_profiles user_profiles_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_profiles
    ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (user_id);


--
-- TOC entry 5524 (class 2606 OID 17140)
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role);


--
-- TOC entry 5706 (class 2606 OID 18831)
-- Name: user_sessions user_sessions_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_sessions
    ADD CONSTRAINT user_sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 5514 (class 2606 OID 17118)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 5516 (class 2606 OID 17116)
-- Name: users users_handle_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.users
    ADD CONSTRAINT users_handle_key UNIQUE (handle);


--
-- TOC entry 5518 (class 2606 OID 18776)
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- TOC entry 5520 (class 2606 OID 17114)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 5595 (class 2606 OID 17344)
-- Name: wallet_ledger wallet_ledger_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.wallet_ledger
    ADD CONSTRAINT wallet_ledger_pkey PRIMARY KEY (id);


--
-- TOC entry 5587 (class 2606 OID 17328)
-- Name: wallets wallets_owner_user_id_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.wallets
    ADD CONSTRAINT wallets_owner_user_id_key UNIQUE (owner_user_id);


--
-- TOC entry 5589 (class 2606 OID 17326)
-- Name: wallets wallets_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.wallets
    ADD CONSTRAINT wallets_pkey PRIMARY KEY (id);


--
-- TOC entry 5650 (class 1259 OID 18593)
-- Name: idx_audit_action_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_audit_action_time ON app.audit_logs USING btree (action, created_at DESC);


--
-- TOC entry 5651 (class 1259 OID 19129)
-- Name: idx_audit_logs_created_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_audit_logs_created_at ON app.audit_logs USING btree (created_at DESC);


--
-- TOC entry 5652 (class 1259 OID 19128)
-- Name: idx_audit_logs_resource; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_audit_logs_resource ON app.audit_logs USING btree (resource, resource_id);


--
-- TOC entry 5653 (class 1259 OID 19127)
-- Name: idx_audit_logs_user_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_audit_logs_user_id ON app.audit_logs USING btree (user_id);


--
-- TOC entry 5654 (class 1259 OID 18591)
-- Name: idx_audit_time_desc; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_audit_time_desc ON app.audit_logs USING btree (created_at DESC);


--
-- TOC entry 5655 (class 1259 OID 18592)
-- Name: idx_audit_user_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_audit_user_time ON app.audit_logs USING btree (user_id, created_at DESC);


--
-- TOC entry 5547 (class 1259 OID 17542)
-- Name: idx_avail_expert; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_avail_expert ON app.expert_availabilities USING btree (expert_id, start_at);


--
-- TOC entry 5552 (class 1259 OID 17543)
-- Name: idx_booking_expert; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_booking_expert ON app.bookings USING btree (expert_id, start_at);


--
-- TOC entry 5553 (class 1259 OID 17544)
-- Name: idx_booking_user; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_booking_user ON app.bookings USING btree (user_id, start_at);


--
-- TOC entry 5554 (class 1259 OID 19098)
-- Name: idx_bookings_created_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_bookings_created_at ON app.bookings USING btree (created_at DESC);


--
-- TOC entry 5555 (class 1259 OID 19096)
-- Name: idx_bookings_expert_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_bookings_expert_id ON app.bookings USING btree (expert_id);


--
-- TOC entry 5556 (class 1259 OID 19099)
-- Name: idx_bookings_start_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_bookings_start_at ON app.bookings USING btree (start_at);


--
-- TOC entry 5557 (class 1259 OID 19097)
-- Name: idx_bookings_status; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_bookings_status ON app.bookings USING btree (status);


--
-- TOC entry 5558 (class 1259 OID 19095)
-- Name: idx_bookings_user_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_bookings_user_id ON app.bookings USING btree (user_id);


--
-- TOC entry 5559 (class 1259 OID 18793)
-- Name: idx_bookings_user_status; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_bookings_user_status ON app.bookings USING btree (user_id, status, start_at DESC);


--
-- TOC entry 5661 (class 1259 OID 18586)
-- Name: idx_call_callee_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_call_callee_time ON app.call_sessions USING btree (callee_id, started_at DESC);


--
-- TOC entry 5662 (class 1259 OID 18585)
-- Name: idx_call_caller_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_call_caller_time ON app.call_sessions USING btree (caller_id, started_at DESC);


--
-- TOC entry 5669 (class 1259 OID 18601)
-- Name: idx_call_events_call_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_call_events_call_at ON app.call_events USING btree (call_id, at);


--
-- TOC entry 5670 (class 1259 OID 18597)
-- Name: idx_call_events_call_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_call_events_call_time ON app.call_events USING btree (call_id, at DESC);


--
-- TOC entry 5663 (class 1259 OID 18602)
-- Name: idx_call_sessions_thread_start; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_call_sessions_thread_start ON app.call_sessions USING btree (thread_id, started_at);


--
-- TOC entry 5664 (class 1259 OID 18596)
-- Name: idx_call_thread_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_call_thread_time ON app.call_sessions USING btree (thread_id, started_at DESC);


--
-- TOC entry 5665 (class 1259 OID 18559)
-- Name: idx_call_user_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_call_user_time ON app.call_sessions USING btree (caller_id, started_at DESC);


--
-- TOC entry 5666 (class 1259 OID 18560)
-- Name: idx_call_user_time2; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_call_user_time2 ON app.call_sessions USING btree (callee_id, started_at DESC);


--
-- TOC entry 5605 (class 1259 OID 19118)
-- Name: idx_chat_members_thread_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_members_thread_id ON app.chat_members USING btree (thread_id);


--
-- TOC entry 5606 (class 1259 OID 18243)
-- Name: idx_chat_members_thread_user; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_members_thread_user ON app.chat_members USING btree (thread_id, user_id);


--
-- TOC entry 5607 (class 1259 OID 19119)
-- Name: idx_chat_members_user_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_members_user_id ON app.chat_members USING btree (user_id);


--
-- TOC entry 5612 (class 1259 OID 19122)
-- Name: idx_chat_messages_created_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_messages_created_at ON app.chat_messages USING btree (created_at DESC);


--
-- TOC entry 5613 (class 1259 OID 19121)
-- Name: idx_chat_messages_sender_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_messages_sender_id ON app.chat_messages USING btree (sender_id);


--
-- TOC entry 5614 (class 1259 OID 18244)
-- Name: idx_chat_messages_thread_created; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_messages_thread_created ON app.chat_messages USING btree (thread_id, created_at DESC);


--
-- TOC entry 5615 (class 1259 OID 19120)
-- Name: idx_chat_messages_thread_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_messages_thread_id ON app.chat_messages USING btree (thread_id);


--
-- TOC entry 5616 (class 1259 OID 18598)
-- Name: idx_chat_messages_thread_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_messages_thread_time ON app.chat_messages USING btree (thread_id, created_at DESC);


--
-- TOC entry 5658 (class 1259 OID 18600)
-- Name: idx_chat_read_state_thread_user; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_read_state_thread_user ON app.chat_read_state USING btree (thread_id, user_id);


--
-- TOC entry 5600 (class 1259 OID 19116)
-- Name: idx_chat_threads_booking_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_threads_booking_id ON app.chat_threads USING btree (booking_id) WHERE (booking_id IS NOT NULL);


--
-- TOC entry 5601 (class 1259 OID 19117)
-- Name: idx_chat_threads_last_message_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_threads_last_message_at ON app.chat_threads USING btree (last_message_at DESC);


--
-- TOC entry 5602 (class 1259 OID 18245)
-- Name: idx_chat_threads_last_msg; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_threads_last_msg ON app.chat_threads USING btree (last_message_at DESC);


--
-- TOC entry 5631 (class 1259 OID 19111)
-- Name: idx_comments_author_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_comments_author_id ON app.comments USING btree (author_id);


--
-- TOC entry 5632 (class 1259 OID 19113)
-- Name: idx_comments_created_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_comments_created_at ON app.comments USING btree (created_at DESC);


--
-- TOC entry 5633 (class 1259 OID 18792)
-- Name: idx_comments_parent_created_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_comments_parent_created_at ON app.comments USING btree (post_id, parent_id, created_at DESC);


--
-- TOC entry 5634 (class 1259 OID 19112)
-- Name: idx_comments_parent_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_comments_parent_id ON app.comments USING btree (parent_id) WHERE (parent_id IS NOT NULL);


--
-- TOC entry 5635 (class 1259 OID 17549)
-- Name: idx_comments_post; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_comments_post ON app.comments USING btree (post_id, created_at);


--
-- TOC entry 5636 (class 1259 OID 18754)
-- Name: idx_comments_post_created_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_comments_post_created_at ON app.comments USING btree (post_id, created_at DESC);


--
-- TOC entry 5637 (class 1259 OID 19110)
-- Name: idx_comments_post_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_comments_post_id ON app.comments USING btree (post_id);


--
-- TOC entry 5638 (class 1259 OID 18755)
-- Name: idx_comments_post_parent_created_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_comments_post_parent_created_at ON app.comments USING btree (post_id, parent_id, created_at DESC);


--
-- TOC entry 5639 (class 1259 OID 18594)
-- Name: idx_comments_post_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_comments_post_time ON app.comments USING btree (post_id, created_at DESC);


--
-- TOC entry 5529 (class 1259 OID 18219)
-- Name: idx_email_verif_user_created; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_email_verif_user_created ON app.email_verifications USING btree (user_id, email, created_at DESC);


--
-- TOC entry 5548 (class 1259 OID 19093)
-- Name: idx_expert_availabilities_expert_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_availabilities_expert_id ON app.expert_availabilities USING btree (expert_id);


--
-- TOC entry 5549 (class 1259 OID 19094)
-- Name: idx_expert_availabilities_start_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_availabilities_start_at ON app.expert_availabilities USING btree (start_at);


--
-- TOC entry 5537 (class 1259 OID 19091)
-- Name: idx_expert_profiles_kyc_status; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_profiles_kyc_status ON app.expert_profiles USING btree (kyc_status);


--
-- TOC entry 5538 (class 1259 OID 19092)
-- Name: idx_expert_profiles_rating_avg; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_profiles_rating_avg ON app.expert_profiles USING btree (rating_avg DESC);


--
-- TOC entry 5539 (class 1259 OID 19090)
-- Name: idx_expert_profiles_user_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_profiles_user_id ON app.expert_profiles USING btree (user_id);


--
-- TOC entry 5540 (class 1259 OID 17541)
-- Name: idx_expert_specs; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_specs ON app.expert_profiles USING gin (specialties);


--
-- TOC entry 5710 (class 1259 OID 18888)
-- Name: idx_oauth_users_email; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_oauth_users_email ON app.oauth_users USING btree (email);


--
-- TOC entry 5576 (class 1259 OID 17546)
-- Name: idx_pay_status; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_pay_status ON app.payments USING btree (status);


--
-- TOC entry 5566 (class 1259 OID 19101)
-- Name: idx_payment_intents_booking_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_payment_intents_booking_id ON app.payment_intents USING btree (booking_id);


--
-- TOC entry 5567 (class 1259 OID 19102)
-- Name: idx_payment_intents_status; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_payment_intents_status ON app.payment_intents USING btree (status);


--
-- TOC entry 5568 (class 1259 OID 19103)
-- Name: idx_payment_intents_tx_ref; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_payment_intents_tx_ref ON app.payment_intents USING btree (tx_ref);


--
-- TOC entry 5569 (class 1259 OID 19100)
-- Name: idx_payment_intents_user_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_payment_intents_user_id ON app.payment_intents USING btree (user_id);


--
-- TOC entry 5577 (class 1259 OID 19104)
-- Name: idx_payments_intent_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_payments_intent_id ON app.payments USING btree (intent_id);


--
-- TOC entry 5745 (class 1259 OID 19069)
-- Name: idx_payout_requests_status; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_payout_requests_status ON app.payout_requests USING btree (status);


--
-- TOC entry 5746 (class 1259 OID 19068)
-- Name: idx_payout_requests_user_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_payout_requests_user_id ON app.payout_requests USING btree (user_id);


--
-- TOC entry 5570 (class 1259 OID 17545)
-- Name: idx_pi_status; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_pi_status ON app.payment_intents USING btree (status);


--
-- TOC entry 5681 (class 1259 OID 18717)
-- Name: idx_post_files_post; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_post_files_post ON app.post_files USING btree (post_id, created_at DESC);


--
-- TOC entry 5624 (class 1259 OID 19114)
-- Name: idx_post_reactions_post_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_post_reactions_post_id ON app.post_reactions USING btree (post_id);


--
-- TOC entry 5625 (class 1259 OID 19115)
-- Name: idx_post_reactions_user_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_post_reactions_user_id ON app.post_reactions USING btree (user_id);


--
-- TOC entry 5684 (class 1259 OID 18734)
-- Name: idx_post_saves_post; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_post_saves_post ON app.post_saves USING btree (post_id, created_at DESC);


--
-- TOC entry 5617 (class 1259 OID 18697)
-- Name: idx_posts_author; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_posts_author ON app.posts USING btree (author_id, created_at DESC);


--
-- TOC entry 5618 (class 1259 OID 19109)
-- Name: idx_posts_author_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_posts_author_id ON app.posts USING btree (author_id);


--
-- TOC entry 5619 (class 1259 OID 17548)
-- Name: idx_posts_created; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_posts_created ON app.posts USING btree (created_at DESC);


--
-- TOC entry 5620 (class 1259 OID 18696)
-- Name: idx_posts_created_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_posts_created_at ON app.posts USING btree (created_at DESC);


--
-- TOC entry 5621 (class 1259 OID 18698)
-- Name: idx_posts_privacy; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_posts_privacy ON app.posts USING btree (privacy);


--
-- TOC entry 5626 (class 1259 OID 18595)
-- Name: idx_react_post; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_react_post ON app.post_reactions USING btree (post_id);


--
-- TOC entry 5640 (class 1259 OID 19130)
-- Name: idx_reports_reporter_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_reports_reporter_id ON app.reports USING btree (reporter_id);


--
-- TOC entry 5641 (class 1259 OID 17550)
-- Name: idx_reports_target; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_reports_target ON app.reports USING btree (target_type, target_id);


--
-- TOC entry 5689 (class 1259 OID 19125)
-- Name: idx_reviews_booking_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_reviews_booking_id ON app.reviews USING btree (booking_id);


--
-- TOC entry 5690 (class 1259 OID 19126)
-- Name: idx_reviews_created_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_reviews_created_at ON app.reviews USING btree (created_at DESC);


--
-- TOC entry 5691 (class 1259 OID 19123)
-- Name: idx_reviews_expert_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_reviews_expert_id ON app.reviews USING btree (expert_id);


--
-- TOC entry 5692 (class 1259 OID 18867)
-- Name: idx_reviews_expert_rating; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_reviews_expert_rating ON app.reviews USING btree (expert_id, rating);


--
-- TOC entry 5693 (class 1259 OID 18820)
-- Name: idx_reviews_expert_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_reviews_expert_time ON app.reviews USING btree (expert_id, created_at DESC);


--
-- TOC entry 5694 (class 1259 OID 18866)
-- Name: idx_reviews_user_booking; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_reviews_user_booking ON app.reviews USING btree (user_id, booking_id);


--
-- TOC entry 5695 (class 1259 OID 19124)
-- Name: idx_reviews_user_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_reviews_user_id ON app.reviews USING btree (user_id);


--
-- TOC entry 5749 (class 1259 OID 19082)
-- Name: idx_schema_migrations_version; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_schema_migrations_version ON app.schema_migrations USING btree (version);


--
-- TOC entry 5700 (class 1259 OID 18838)
-- Name: idx_sessions_token; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_sessions_token ON app.user_sessions USING btree (token);


--
-- TOC entry 5701 (class 1259 OID 18837)
-- Name: idx_sessions_user_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_sessions_user_time ON app.user_sessions USING btree (user_id, created_at DESC);


--
-- TOC entry 5671 (class 1259 OID 18699)
-- Name: idx_user_follows_followee; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_user_follows_followee ON app.user_follows USING btree (followee_id, created_at DESC);


--
-- TOC entry 5672 (class 1259 OID 18700)
-- Name: idx_user_follows_follower; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_user_follows_follower ON app.user_follows USING btree (follower_id, created_at DESC);


--
-- TOC entry 5702 (class 1259 OID 19089)
-- Name: idx_user_sessions_expires_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_user_sessions_expires_at ON app.user_sessions USING btree (expires_at);


--
-- TOC entry 5703 (class 1259 OID 19088)
-- Name: idx_user_sessions_token; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_user_sessions_token ON app.user_sessions USING btree (token);


--
-- TOC entry 5704 (class 1259 OID 19087)
-- Name: idx_user_sessions_user_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_user_sessions_user_id ON app.user_sessions USING btree (user_id);


--
-- TOC entry 5505 (class 1259 OID 19084)
-- Name: idx_users_email; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_users_email ON app.users USING btree (email);


--
-- TOC entry 5506 (class 1259 OID 19083)
-- Name: idx_users_handle; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_users_handle ON app.users USING btree (handle);


--
-- TOC entry 5507 (class 1259 OID 17540)
-- Name: idx_users_role; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_users_role ON app.users USING btree (role_primary);


--
-- TOC entry 5508 (class 1259 OID 19086)
-- Name: idx_users_role_primary; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_users_role_primary ON app.users USING btree (role_primary);


--
-- TOC entry 5509 (class 1259 OID 19085)
-- Name: idx_users_status; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_users_status ON app.users USING btree (status);


--
-- TOC entry 5590 (class 1259 OID 19108)
-- Name: idx_wallet_ledger_created_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_wallet_ledger_created_at ON app.wallet_ledger USING btree (created_at DESC);


--
-- TOC entry 5591 (class 1259 OID 19107)
-- Name: idx_wallet_ledger_tx_type; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_wallet_ledger_tx_type ON app.wallet_ledger USING btree (tx_type);


--
-- TOC entry 5592 (class 1259 OID 19106)
-- Name: idx_wallet_ledger_wallet_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_wallet_ledger_wallet_id ON app.wallet_ledger USING btree (wallet_id);


--
-- TOC entry 5593 (class 1259 OID 18590)
-- Name: idx_wallet_ledger_wallet_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_wallet_ledger_wallet_time ON app.wallet_ledger USING btree (wallet_id, created_at DESC);


--
-- TOC entry 5583 (class 1259 OID 17547)
-- Name: idx_wallet_owner; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_wallet_owner ON app.wallets USING btree (owner_user_id);


--
-- TOC entry 5584 (class 1259 OID 19105)
-- Name: idx_wallets_owner_user_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_wallets_owner_user_id ON app.wallets USING btree (owner_user_id);


--
-- TOC entry 5608 (class 1259 OID 18576)
-- Name: uq_chat_member; Type: INDEX; Schema: app; Owner: postgres
--

CREATE UNIQUE INDEX uq_chat_member ON app.chat_members USING btree (thread_id, user_id);


--
-- TOC entry 5530 (class 1259 OID 17178)
-- Name: uq_email_verif_user; Type: INDEX; Schema: app; Owner: postgres
--

CREATE UNIQUE INDEX uq_email_verif_user ON app.email_verifications USING btree (user_id, email) WHERE (verified = false);


--
-- TOC entry 5582 (class 1259 OID 18588)
-- Name: uq_payments_intent; Type: INDEX; Schema: app; Owner: postgres
--

CREATE UNIQUE INDEX uq_payments_intent ON app.payments USING btree (intent_id);


--
-- TOC entry 5709 (class 1259 OID 18855)
-- Name: uq_payout_user; Type: INDEX; Schema: app; Owner: postgres
--

CREATE UNIQUE INDEX uq_payout_user ON app.payout_accounts USING btree (user_id);


--
-- TOC entry 5575 (class 1259 OID 18587)
-- Name: uq_pi_txref; Type: INDEX; Schema: app; Owner: postgres
--

CREATE UNIQUE INDEX uq_pi_txref ON app.payment_intents USING btree (tx_ref);


--
-- TOC entry 5510 (class 1259 OID 18578)
-- Name: uq_users_email; Type: INDEX; Schema: app; Owner: postgres
--

CREATE UNIQUE INDEX uq_users_email ON app.users USING btree (email) WHERE (email IS NOT NULL);


--
-- TOC entry 5511 (class 1259 OID 18577)
-- Name: uq_users_handle; Type: INDEX; Schema: app; Owner: postgres
--

CREATE UNIQUE INDEX uq_users_handle ON app.users USING btree (handle);


--
-- TOC entry 5512 (class 1259 OID 18777)
-- Name: uq_users_phone; Type: INDEX; Schema: app; Owner: postgres
--

CREATE UNIQUE INDEX uq_users_phone ON app.users USING btree (phone) WHERE (phone IS NOT NULL);


--
-- TOC entry 5585 (class 1259 OID 18589)
-- Name: uq_wallet_owner; Type: INDEX; Schema: app; Owner: postgres
--

CREATE UNIQUE INDEX uq_wallet_owner ON app.wallets USING btree (owner_user_id);


--
-- TOC entry 5609 (class 1259 OID 18599)
-- Name: ux_chat_members_thread_user; Type: INDEX; Schema: app; Owner: postgres
--

CREATE UNIQUE INDEX ux_chat_members_thread_user ON app.chat_members USING btree (thread_id, user_id);


--
-- TOC entry 5825 (class 2620 OID 18242)
-- Name: chat_members trg_dm_member_limit; Type: TRIGGER; Schema: app; Owner: postgres
--

CREATE TRIGGER trg_dm_member_limit BEFORE INSERT ON app.chat_members FOR EACH ROW EXECUTE FUNCTION app.enforce_dm_member_limit();


--
-- TOC entry 5826 (class 2620 OID 18736)
-- Name: posts trg_posts_set_updated_at; Type: TRIGGER; Schema: app; Owner: postgres
--

CREATE TRIGGER trg_posts_set_updated_at BEFORE UPDATE OF title, content, tags, privacy ON app.posts FOR EACH ROW EXECUTE FUNCTION app.fn_posts_touch_updated_at();


--
-- TOC entry 5827 (class 2620 OID 18869)
-- Name: reviews trg_reviews_set_updated_at; Type: TRIGGER; Schema: app; Owner: postgres
--

CREATE TRIGGER trg_reviews_set_updated_at BEFORE UPDATE ON app.reviews FOR EACH ROW EXECUTE FUNCTION app.fn_reviews_touch_updated_at();


--
-- TOC entry 5761 (class 2606 OID 19132)
-- Name: bookings bookings_expert_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.bookings
    ADD CONSTRAINT bookings_expert_id_fkey FOREIGN KEY (expert_id) REFERENCES app.expert_profiles(user_id) ON DELETE CASCADE;


--
-- TOC entry 5762 (class 2606 OID 17247)
-- Name: bookings bookings_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.bookings
    ADD CONSTRAINT bookings_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5795 (class 2606 OID 18571)
-- Name: call_events call_events_call_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.call_events
    ADD CONSTRAINT call_events_call_id_fkey FOREIGN KEY (call_id) REFERENCES app.call_sessions(id) ON DELETE CASCADE;


--
-- TOC entry 5791 (class 2606 OID 18580)
-- Name: call_sessions call_sessions_booking_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.call_sessions
    ADD CONSTRAINT call_sessions_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES app.bookings(id) ON DELETE SET NULL;


--
-- TOC entry 5792 (class 2606 OID 18554)
-- Name: call_sessions call_sessions_callee_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.call_sessions
    ADD CONSTRAINT call_sessions_callee_id_fkey FOREIGN KEY (callee_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5793 (class 2606 OID 18549)
-- Name: call_sessions call_sessions_caller_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.call_sessions
    ADD CONSTRAINT call_sessions_caller_id_fkey FOREIGN KEY (caller_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5794 (class 2606 OID 18544)
-- Name: call_sessions call_sessions_thread_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.call_sessions
    ADD CONSTRAINT call_sessions_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES app.chat_threads(id) ON DELETE CASCADE;


--
-- TOC entry 5773 (class 2606 OID 17393)
-- Name: chat_members chat_members_thread_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_members
    ADD CONSTRAINT chat_members_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES app.chat_threads(id) ON DELETE CASCADE;


--
-- TOC entry 5774 (class 2606 OID 17398)
-- Name: chat_members chat_members_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_members
    ADD CONSTRAINT chat_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5775 (class 2606 OID 17418)
-- Name: chat_messages chat_messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_messages
    ADD CONSTRAINT chat_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5776 (class 2606 OID 17413)
-- Name: chat_messages chat_messages_thread_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_messages
    ADD CONSTRAINT chat_messages_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES app.chat_threads(id) ON DELETE CASCADE;


--
-- TOC entry 5788 (class 2606 OID 18262)
-- Name: chat_read_state chat_read_state_last_read_message_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_read_state
    ADD CONSTRAINT chat_read_state_last_read_message_id_fkey FOREIGN KEY (last_read_message_id) REFERENCES app.chat_messages(id) ON DELETE CASCADE;


--
-- TOC entry 5789 (class 2606 OID 18252)
-- Name: chat_read_state chat_read_state_thread_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_read_state
    ADD CONSTRAINT chat_read_state_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES app.chat_threads(id) ON DELETE CASCADE;


--
-- TOC entry 5790 (class 2606 OID 18257)
-- Name: chat_read_state chat_read_state_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_read_state
    ADD CONSTRAINT chat_read_state_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5772 (class 2606 OID 17381)
-- Name: chat_threads chat_threads_booking_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_threads
    ADD CONSTRAINT chat_threads_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES app.bookings(id) ON DELETE SET NULL;


--
-- TOC entry 5801 (class 2606 OID 18685)
-- Name: comment_reactions comment_reactions_comment_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.comment_reactions
    ADD CONSTRAINT comment_reactions_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES app.comments(id) ON DELETE CASCADE;


--
-- TOC entry 5802 (class 2606 OID 18690)
-- Name: comment_reactions comment_reactions_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.comment_reactions
    ADD CONSTRAINT comment_reactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5780 (class 2606 OID 18743)
-- Name: comments comments_author_fk; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.comments
    ADD CONSTRAINT comments_author_fk FOREIGN KEY (author_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5781 (class 2606 OID 17475)
-- Name: comments comments_author_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.comments
    ADD CONSTRAINT comments_author_id_fkey FOREIGN KEY (author_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5782 (class 2606 OID 18748)
-- Name: comments comments_parent_fk; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.comments
    ADD CONSTRAINT comments_parent_fk FOREIGN KEY (parent_id) REFERENCES app.comments(id) ON DELETE CASCADE;


--
-- TOC entry 5783 (class 2606 OID 18738)
-- Name: comments comments_post_fk; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.comments
    ADD CONSTRAINT comments_post_fk FOREIGN KEY (post_id) REFERENCES app.posts(id) ON DELETE CASCADE;


--
-- TOC entry 5784 (class 2606 OID 17470)
-- Name: comments comments_post_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.comments
    ADD CONSTRAINT comments_post_id_fkey FOREIGN KEY (post_id) REFERENCES app.posts(id) ON DELETE CASCADE;


--
-- TOC entry 5787 (class 2606 OID 17523)
-- Name: consents consents_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.consents
    ADD CONSTRAINT consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5757 (class 2606 OID 17173)
-- Name: email_verifications email_verifications_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.email_verifications
    ADD CONSTRAINT email_verifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5821 (class 2606 OID 19022)
-- Name: expert_audience expert_audience_audience_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_audience
    ADD CONSTRAINT expert_audience_audience_id_fkey FOREIGN KEY (audience_id) REFERENCES app.audience(id) ON DELETE CASCADE;


--
-- TOC entry 5822 (class 2606 OID 19017)
-- Name: expert_audience expert_audience_expert_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_audience
    ADD CONSTRAINT expert_audience_expert_id_fkey FOREIGN KEY (expert_id) REFERENCES app.expert_profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5760 (class 2606 OID 17226)
-- Name: expert_availabilities expert_availabilities_expert_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_availabilities
    ADD CONSTRAINT expert_availabilities_expert_id_fkey FOREIGN KEY (expert_id) REFERENCES app.expert_profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5817 (class 2606 OID 18953)
-- Name: expert_certifications expert_certifications_expert_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_certifications
    ADD CONSTRAINT expert_certifications_expert_id_fkey FOREIGN KEY (expert_id) REFERENCES app.expert_profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5823 (class 2606 OID 19048)
-- Name: expert_domain expert_domain_domain_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_domain
    ADD CONSTRAINT expert_domain_domain_id_fkey FOREIGN KEY (domain_id) REFERENCES app.domains(id) ON DELETE CASCADE;


--
-- TOC entry 5824 (class 2606 OID 19043)
-- Name: expert_domain expert_domain_expert_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_domain
    ADD CONSTRAINT expert_domain_expert_id_fkey FOREIGN KEY (expert_id) REFERENCES app.expert_profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5816 (class 2606 OID 18939)
-- Name: expert_education expert_education_expert_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_education
    ADD CONSTRAINT expert_education_expert_id_fkey FOREIGN KEY (expert_id) REFERENCES app.expert_profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5815 (class 2606 OID 18925)
-- Name: expert_experience expert_experience_expert_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_experience
    ADD CONSTRAINT expert_experience_expert_id_fkey FOREIGN KEY (expert_id) REFERENCES app.expert_profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5820 (class 2606 OID 18996)
-- Name: expert_media expert_media_expert_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_media
    ADD CONSTRAINT expert_media_expert_id_fkey FOREIGN KEY (expert_id) REFERENCES app.expert_profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5818 (class 2606 OID 18966)
-- Name: expert_performance expert_performance_expert_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_performance
    ADD CONSTRAINT expert_performance_expert_id_fkey FOREIGN KEY (expert_id) REFERENCES app.expert_profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5758 (class 2606 OID 17193)
-- Name: expert_profiles expert_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_profiles
    ADD CONSTRAINT expert_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5813 (class 2606 OID 18906)
-- Name: expert_skills expert_skills_expert_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_skills
    ADD CONSTRAINT expert_skills_expert_id_fkey FOREIGN KEY (expert_id) REFERENCES app.expert_profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5814 (class 2606 OID 18911)
-- Name: expert_skills expert_skills_skill_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_skills
    ADD CONSTRAINT expert_skills_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES app.skills(id) ON DELETE CASCADE;


--
-- TOC entry 5819 (class 2606 OID 18981)
-- Name: expert_status expert_status_expert_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_status
    ADD CONSTRAINT expert_status_expert_id_fkey FOREIGN KEY (expert_id) REFERENCES app.expert_profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5796 (class 2606 OID 18609)
-- Name: user_follows fk_follow_from; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_follows
    ADD CONSTRAINT fk_follow_from FOREIGN KEY (follower_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5797 (class 2606 OID 18614)
-- Name: user_follows fk_follow_to; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_follows
    ADD CONSTRAINT fk_follow_to FOREIGN KEY (followee_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5811 (class 2606 OID 18850)
-- Name: payout_accounts fk_payout_user; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payout_accounts
    ADD CONSTRAINT fk_payout_user FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5807 (class 2606 OID 18815)
-- Name: reviews fk_review_booking; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.reviews
    ADD CONSTRAINT fk_review_booking FOREIGN KEY (booking_id) REFERENCES app.bookings(id) ON DELETE SET NULL;


--
-- TOC entry 5808 (class 2606 OID 18810)
-- Name: reviews fk_review_expert; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.reviews
    ADD CONSTRAINT fk_review_expert FOREIGN KEY (expert_id) REFERENCES app.expert_profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5809 (class 2606 OID 18805)
-- Name: reviews fk_review_user; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.reviews
    ADD CONSTRAINT fk_review_user FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5810 (class 2606 OID 18832)
-- Name: user_sessions fk_session_user; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_sessions
    ADD CONSTRAINT fk_session_user FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5759 (class 2606 OID 17210)
-- Name: listener_profiles listener_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.listener_profiles
    ADD CONSTRAINT listener_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5786 (class 2606 OID 17508)
-- Name: moderation_actions moderation_actions_admin_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.moderation_actions
    ADD CONSTRAINT moderation_actions_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES app.users(id) ON DELETE SET NULL;


--
-- TOC entry 5812 (class 2606 OID 18883)
-- Name: oauth_users oauth_users_app_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.oauth_users
    ADD CONSTRAINT oauth_users_app_user_id_fkey FOREIGN KEY (app_user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5765 (class 2606 OID 17293)
-- Name: payment_intents payment_intents_booking_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payment_intents
    ADD CONSTRAINT payment_intents_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES app.bookings(id) ON DELETE SET NULL;


--
-- TOC entry 5766 (class 2606 OID 17298)
-- Name: payment_intents payment_intents_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payment_intents
    ADD CONSTRAINT payment_intents_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5767 (class 2606 OID 17314)
-- Name: payments payments_intent_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payments
    ADD CONSTRAINT payments_intent_id_fkey FOREIGN KEY (intent_id) REFERENCES app.payment_intents(id) ON DELETE CASCADE;


--
-- TOC entry 5798 (class 2606 OID 18634)
-- Name: post_audience post_audience_post_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_audience
    ADD CONSTRAINT post_audience_post_id_fkey FOREIGN KEY (post_id) REFERENCES app.posts(id) ON DELETE CASCADE;


--
-- TOC entry 5799 (class 2606 OID 18639)
-- Name: post_audience post_audience_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_audience
    ADD CONSTRAINT post_audience_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5803 (class 2606 OID 18712)
-- Name: post_files post_files_file_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_files
    ADD CONSTRAINT post_files_file_fkey FOREIGN KEY (file_id) REFERENCES app.user_files(id) ON DELETE CASCADE;


--
-- TOC entry 5804 (class 2606 OID 18707)
-- Name: post_files post_files_post_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_files
    ADD CONSTRAINT post_files_post_fkey FOREIGN KEY (post_id) REFERENCES app.posts(id) ON DELETE CASCADE;


--
-- TOC entry 5800 (class 2606 OID 18659)
-- Name: post_media post_media_post_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_media
    ADD CONSTRAINT post_media_post_id_fkey FOREIGN KEY (post_id) REFERENCES app.posts(id) ON DELETE CASCADE;


--
-- TOC entry 5778 (class 2606 OID 17449)
-- Name: post_reactions post_reactions_post_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_reactions
    ADD CONSTRAINT post_reactions_post_id_fkey FOREIGN KEY (post_id) REFERENCES app.posts(id) ON DELETE CASCADE;


--
-- TOC entry 5779 (class 2606 OID 17454)
-- Name: post_reactions post_reactions_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_reactions
    ADD CONSTRAINT post_reactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5805 (class 2606 OID 18729)
-- Name: post_saves post_saves_post_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_saves
    ADD CONSTRAINT post_saves_post_fkey FOREIGN KEY (post_id) REFERENCES app.posts(id) ON DELETE CASCADE;


--
-- TOC entry 5806 (class 2606 OID 18724)
-- Name: post_saves post_saves_user_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_saves
    ADD CONSTRAINT post_saves_user_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5777 (class 2606 OID 17435)
-- Name: posts posts_author_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.posts
    ADD CONSTRAINT posts_author_id_fkey FOREIGN KEY (author_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5785 (class 2606 OID 17491)
-- Name: reports reports_reporter_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.reports
    ADD CONSTRAINT reports_reporter_id_fkey FOREIGN KEY (reporter_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5763 (class 2606 OID 17269)
-- Name: session_notes session_notes_booking_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.session_notes
    ADD CONSTRAINT session_notes_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES app.bookings(id) ON DELETE CASCADE;


--
-- TOC entry 5764 (class 2606 OID 17274)
-- Name: session_notes session_notes_expert_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.session_notes
    ADD CONSTRAINT session_notes_expert_id_fkey FOREIGN KEY (expert_id) REFERENCES app.expert_profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5770 (class 2606 OID 17361)
-- Name: tips tips_from_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.tips
    ADD CONSTRAINT tips_from_user_id_fkey FOREIGN KEY (from_user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5771 (class 2606 OID 17366)
-- Name: tips tips_to_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.tips
    ADD CONSTRAINT tips_to_user_id_fkey FOREIGN KEY (to_user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5756 (class 2606 OID 17157)
-- Name: user_files user_files_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_files
    ADD CONSTRAINT user_files_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5754 (class 2606 OID 17131)
-- Name: user_profiles user_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_profiles
    ADD CONSTRAINT user_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5755 (class 2606 OID 17141)
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 5769 (class 2606 OID 17345)
-- Name: wallet_ledger wallet_ledger_wallet_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.wallet_ledger
    ADD CONSTRAINT wallet_ledger_wallet_id_fkey FOREIGN KEY (wallet_id) REFERENCES app.wallets(id) ON DELETE CASCADE;


--
-- TOC entry 5768 (class 2606 OID 17329)
-- Name: wallets wallets_owner_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.wallets
    ADD CONSTRAINT wallets_owner_user_id_fkey FOREIGN KEY (owner_user_id) REFERENCES app.users(id) ON DELETE CASCADE;


-- Completed on 2025-11-24 13:51:06

--
-- PostgreSQL database dump complete
--

\unrestrict 7WYB5k6oJrOZLQN4VjzlhNsESTicDLKkAMv0RXuiIBSun60TiDyzkRa6b1KbNdM

