--
-- PostgreSQL database dump
--

\restrict WLINor7iOODQh4WEqB8GJJKxomcdm4Ju6EkVUkCfzpKg9PgiMaayAIfbusmNII4

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

-- Started on 2025-12-12 14:19:13

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
-- TOC entry 9 (class 2615 OID 16909)
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
-- TOC entry 6798 (class 0 OID 0)
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
-- TOC entry 6799 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- TOC entry 4 (class 3079 OID 20316)
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- TOC entry 6800 (class 0 OID 0)
-- Dependencies: 4
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- TOC entry 1285 (class 1247 OID 17034)
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
-- TOC entry 1504 (class 1247 OID 19276)
-- Name: dispute_reason; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.dispute_reason AS ENUM (
    'NO_SHOW_EXPERT',
    'NO_SHOW_SEEKER',
    'POOR_QUALITY',
    'TECHNICAL_ISSUES',
    'INAPPROPRIATE_BEHAVIOR',
    'WRONG_EXPERTISE',
    'TIME_DISPUTE',
    'OTHER'
);


ALTER TYPE app.dispute_reason OWNER TO postgres;

--
-- TOC entry 1501 (class 1247 OID 19260)
-- Name: dispute_status; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.dispute_status AS ENUM (
    'OPEN',
    'UNDER_REVIEW',
    'RESOLVED_SEEKER',
    'RESOLVED_EXPERT',
    'RESOLVED_PARTIAL',
    'CLOSED',
    'ESCALATED'
);


ALTER TYPE app.dispute_status OWNER TO postgres;

--
-- TOC entry 1297 (class 1247 OID 17084)
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
-- TOC entry 1408 (class 1247 OID 18645)
-- Name: media_kind; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.media_kind AS ENUM (
    'IMAGE',
    'VIDEO'
);


ALTER TYPE app.media_kind OWNER TO postgres;

--
-- TOC entry 1288 (class 1247 OID 17046)
-- Name: payment_status; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.payment_status AS ENUM (
    'INIT',
    'PENDING',
    'PAID',
    'FAILED',
    'REFUNDED',
    'REQUIRES_ACTION',
    'EXPIRED'
);


ALTER TYPE app.payment_status OWNER TO postgres;

--
-- TOC entry 1402 (class 1247 OID 18620)
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
-- TOC entry 1414 (class 1247 OID 18665)
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
-- TOC entry 1507 (class 1247 OID 19294)
-- Name: recurring_frequency; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.recurring_frequency AS ENUM (
    'DAILY',
    'WEEKLY',
    'BIWEEKLY',
    'MONTHLY'
);


ALTER TYPE app.recurring_frequency OWNER TO postgres;

--
-- TOC entry 1498 (class 1247 OID 19247)
-- Name: refund_status; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.refund_status AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED',
    'PROCESSING',
    'COMPLETED',
    'FAILED'
);


ALTER TYPE app.refund_status OWNER TO postgres;

--
-- TOC entry 1294 (class 1247 OID 17072)
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
-- TOC entry 1300 (class 1247 OID 17094)
-- Name: user_file_type; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.user_file_type AS ENUM (
    'AVATAR',
    'DOCUMENT',
    'OTHER'
);


ALTER TYPE app.user_file_type OWNER TO postgres;

--
-- TOC entry 1279 (class 1247 OID 17016)
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
-- TOC entry 1282 (class 1247 OID 17026)
-- Name: user_status; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.user_status AS ENUM (
    'ACTIVE',
    'SUSPENDED',
    'DELETED'
);


ALTER TYPE app.user_status OWNER TO postgres;

--
-- TOC entry 1291 (class 1247 OID 17058)
-- Name: wallet_tx_type; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.wallet_tx_type AS ENUM (
    'TOPUP',
    'WITHDRAW',
    'EARN',
    'SPEND',
    'REFUND',
    'ADJUST',
    'PAYOUT',
    'PLATFORM_FEE'
);


ALTER TYPE app.wallet_tx_type OWNER TO postgres;

--
-- TOC entry 1426 (class 1247 OID 18757)
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
-- TOC entry 524 (class 1255 OID 18241)
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
-- TOC entry 417 (class 1255 OID 19604)
-- Name: fn_ai_touch_updated_at(); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.fn_ai_touch_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION app.fn_ai_touch_updated_at() OWNER TO postgres;

--
-- TOC entry 619 (class 1255 OID 19469)
-- Name: fn_disputes_touch_updated_at(); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.fn_disputes_touch_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END;
$$;


ALTER FUNCTION app.fn_disputes_touch_updated_at() OWNER TO postgres;

--
-- TOC entry 522 (class 1255 OID 18735)
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
-- TOC entry 415 (class 1255 OID 19467)
-- Name: fn_refunds_touch_updated_at(); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.fn_refunds_touch_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END;
$$;


ALTER FUNCTION app.fn_refunds_touch_updated_at() OWNER TO postgres;

--
-- TOC entry 444 (class 1255 OID 18868)
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

--
-- TOC entry 586 (class 1255 OID 19243)
-- Name: update_comment_report_count(); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.update_comment_report_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.target_type = 'COMMENT' THEN
        UPDATE app.comments SET report_count = report_count + 1 WHERE id = NEW.target_id;
    ELSIF TG_OP = 'DELETE' AND OLD.target_type = 'COMMENT' THEN
        UPDATE app.comments SET report_count = GREATEST(0, report_count - 1) WHERE id = OLD.target_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$;


ALTER FUNCTION app.update_comment_report_count() OWNER TO postgres;

--
-- TOC entry 601 (class 1255 OID 19242)
-- Name: update_post_report_count(); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.update_post_report_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.target_type = 'POST' THEN
        UPDATE app.posts SET report_count = report_count + 1 WHERE id = NEW.target_id;
    ELSIF TG_OP = 'DELETE' AND OLD.target_type = 'POST' THEN
        UPDATE app.posts SET report_count = GREATEST(0, report_count - 1) WHERE id = OLD.target_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$;


ALTER FUNCTION app.update_post_report_count() OWNER TO postgres;

--
-- TOC entry 587 (class 1255 OID 20099)
-- Name: validate_email_format(); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.validate_email_format() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
BEGIN
    IF NEW.email IS NOT NULL AND NEW.email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Invalid email format: %', NEW.email;
    END IF;
    RETURN NEW;
END;
$_$;


ALTER FUNCTION app.validate_email_format() OWNER TO postgres;

--
-- TOC entry 6801 (class 0 OID 0)
-- Dependencies: 587
-- Name: FUNCTION validate_email_format(); Type: COMMENT; Schema: app; Owner: postgres
--

COMMENT ON FUNCTION app.validate_email_format() IS 'Validate email format before insert/update';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 355 (class 1259 OID 19896)
-- Name: ai_chat_history; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.ai_chat_history (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    role text NOT NULL,
    content text NOT NULL,
    emotion_detected text,
    keywords text[],
    persona_id bigint,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT ai_chat_history_role_check CHECK ((role = ANY (ARRAY['user'::text, 'ai'::text])))
);


ALTER TABLE app.ai_chat_history OWNER TO postgres;

--
-- TOC entry 354 (class 1259 OID 19895)
-- Name: ai_chat_history_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.ai_chat_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.ai_chat_history_id_seq OWNER TO postgres;

--
-- TOC entry 6802 (class 0 OID 0)
-- Dependencies: 354
-- Name: ai_chat_history_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.ai_chat_history_id_seq OWNED BY app.ai_chat_history.id;


--
-- TOC entry 340 (class 1259 OID 19582)
-- Name: ai_conversation_context; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.ai_conversation_context (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    context_type text NOT NULL,
    context_key text NOT NULL,
    context_value text,
    importance integer DEFAULT 1,
    expires_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE app.ai_conversation_context OWNER TO postgres;

--
-- TOC entry 339 (class 1259 OID 19581)
-- Name: ai_conversation_context_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.ai_conversation_context_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.ai_conversation_context_id_seq OWNER TO postgres;

--
-- TOC entry 6803 (class 0 OID 0)
-- Dependencies: 339
-- Name: ai_conversation_context_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.ai_conversation_context_id_seq OWNED BY app.ai_conversation_context.id;


--
-- TOC entry 335 (class 1259 OID 19514)
-- Name: ai_personas; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.ai_personas (
    id bigint NOT NULL,
    name text NOT NULL,
    display_name text NOT NULL,
    tone text NOT NULL,
    emotion_pattern jsonb DEFAULT '{}'::jsonb,
    behavior_rules jsonb DEFAULT '{}'::jsonb,
    signature_messages text[] DEFAULT '{}'::text[],
    avatar_url text,
    description text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE app.ai_personas OWNER TO postgres;

--
-- TOC entry 334 (class 1259 OID 19513)
-- Name: ai_personas_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.ai_personas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.ai_personas_id_seq OWNER TO postgres;

--
-- TOC entry 6804 (class 0 OID 0)
-- Dependencies: 334
-- Name: ai_personas_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.ai_personas_id_seq OWNED BY app.ai_personas.id;


--
-- TOC entry 338 (class 1259 OID 19559)
-- Name: ai_scheduled_notifications; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.ai_scheduled_notifications (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    persona_id bigint,
    type text NOT NULL,
    content text NOT NULL,
    scheduled_at timestamp with time zone NOT NULL,
    sent_at timestamp with time zone,
    is_sent boolean DEFAULT false,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT ai_scheduled_notifications_type_check CHECK ((type = ANY (ARRAY['morning'::text, 'evening'::text, 'checkin'::text, 'reminder'::text, 'random'::text, 'emotion_based'::text, 'schedule_based'::text])))
);


ALTER TABLE app.ai_scheduled_notifications OWNER TO postgres;

--
-- TOC entry 337 (class 1259 OID 19558)
-- Name: ai_scheduled_notifications_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.ai_scheduled_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.ai_scheduled_notifications_id_seq OWNER TO postgres;

--
-- TOC entry 6805 (class 0 OID 0)
-- Dependencies: 337
-- Name: ai_scheduled_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.ai_scheduled_notifications_id_seq OWNED BY app.ai_scheduled_notifications.id;


--
-- TOC entry 366 (class 1259 OID 20012)
-- Name: ai_suggestions; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.ai_suggestions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    suggestion_type text NOT NULL,
    suggestion_content jsonb NOT NULL,
    reason text,
    accepted boolean,
    accepted_at timestamp with time zone,
    dismissed_at timestamp with time zone,
    feedback text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE app.ai_suggestions OWNER TO postgres;

--
-- TOC entry 365 (class 1259 OID 20011)
-- Name: ai_suggestions_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.ai_suggestions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.ai_suggestions_id_seq OWNER TO postgres;

--
-- TOC entry 6806 (class 0 OID 0)
-- Dependencies: 365
-- Name: ai_suggestions_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.ai_suggestions_id_seq OWNED BY app.ai_suggestions.id;


--
-- TOC entry 302 (class 1259 OID 19002)
-- Name: audience; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.audience (
    id bigint NOT NULL,
    name text NOT NULL
);


ALTER TABLE app.audience OWNER TO postgres;

--
-- TOC entry 301 (class 1259 OID 19001)
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
-- TOC entry 6807 (class 0 OID 0)
-- Dependencies: 301
-- Name: audience_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.audience_id_seq OWNED BY app.audience.id;


--
-- TOC entry 266 (class 1259 OID 17529)
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
-- TOC entry 265 (class 1259 OID 17528)
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
-- TOC entry 6808 (class 0 OID 0)
-- Dependencies: 265
-- Name: audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.audit_logs_id_seq OWNED BY app.audit_logs.id;


--
-- TOC entry 362 (class 1259 OID 19968)
-- Name: behavior_patterns; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.behavior_patterns (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    pattern_type text NOT NULL,
    pattern_name text NOT NULL,
    pattern_data jsonb NOT NULL,
    confidence numeric(3,2) DEFAULT 0.5,
    occurrences integer DEFAULT 1,
    first_detected timestamp with time zone DEFAULT now(),
    last_detected timestamp with time zone DEFAULT now(),
    is_active boolean DEFAULT true
);


ALTER TABLE app.behavior_patterns OWNER TO postgres;

--
-- TOC entry 361 (class 1259 OID 19967)
-- Name: behavior_patterns_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.behavior_patterns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.behavior_patterns_id_seq OWNER TO postgres;

--
-- TOC entry 6809 (class 0 OID 0)
-- Dependencies: 361
-- Name: behavior_patterns_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.behavior_patterns_id_seq OWNED BY app.behavior_patterns.id;


--
-- TOC entry 330 (class 1259 OID 19450)
-- Name: booking_fees; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.booking_fees (
    id bigint NOT NULL,
    booking_id bigint NOT NULL,
    gross_amount numeric(14,2) NOT NULL,
    platform_fee numeric(14,2) NOT NULL,
    platform_fee_percent numeric(5,2) NOT NULL,
    expert_earning numeric(14,2) NOT NULL,
    tax_amount numeric(14,2) DEFAULT 0,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE app.booking_fees OWNER TO postgres;

--
-- TOC entry 329 (class 1259 OID 19449)
-- Name: booking_fees_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

ALTER TABLE app.booking_fees ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME app.booking_fees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 236 (class 1259 OID 17232)
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
    recurring_template_id bigint,
    is_recurring boolean DEFAULT false,
    CONSTRAINT bookings_channel_check CHECK ((channel = ANY (ARRAY['CHAT'::text, 'VIDEO'::text, 'AUDIO'::text]))),
    CONSTRAINT bookings_price_check CHECK ((price >= (0)::numeric)),
    CONSTRAINT chk_booking_time CHECK ((end_at > start_at))
);


ALTER TABLE app.bookings OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 17231)
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
-- TOC entry 6810 (class 0 OID 0)
-- Dependencies: 235
-- Name: bookings_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.bookings_id_seq OWNED BY app.bookings.id;


--
-- TOC entry 271 (class 1259 OID 18562)
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
-- TOC entry 270 (class 1259 OID 18561)
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
-- TOC entry 6811 (class 0 OID 0)
-- Dependencies: 270
-- Name: call_events_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.call_events_id_seq OWNED BY app.call_events.id;


--
-- TOC entry 314 (class 1259 OID 19155)
-- Name: call_metrics; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.call_metrics (
    id integer NOT NULL,
    call_id integer,
    "timestamp" timestamp with time zone DEFAULT now(),
    rtt_ms integer,
    packet_loss double precision,
    jitter_ms integer
);


ALTER TABLE app.call_metrics OWNER TO postgres;

--
-- TOC entry 313 (class 1259 OID 19154)
-- Name: call_metrics_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.call_metrics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.call_metrics_id_seq OWNER TO postgres;

--
-- TOC entry 6812 (class 0 OID 0)
-- Dependencies: 313
-- Name: call_metrics_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.call_metrics_id_seq OWNED BY app.call_metrics.id;


--
-- TOC entry 316 (class 1259 OID 19169)
-- Name: call_recordings; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.call_recordings (
    id integer NOT NULL,
    call_id integer,
    url text NOT NULL,
    mime_type text NOT NULL,
    size_bytes integer,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE app.call_recordings OWNER TO postgres;

--
-- TOC entry 315 (class 1259 OID 19168)
-- Name: call_recordings_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.call_recordings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.call_recordings_id_seq OWNER TO postgres;

--
-- TOC entry 6813 (class 0 OID 0)
-- Dependencies: 315
-- Name: call_recordings_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.call_recordings_id_seq OWNED BY app.call_recordings.id;


--
-- TOC entry 269 (class 1259 OID 18533)
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
-- TOC entry 268 (class 1259 OID 18532)
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
-- TOC entry 6814 (class 0 OID 0)
-- Dependencies: 268
-- Name: call_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.call_sessions_id_seq OWNED BY app.call_sessions.id;


--
-- TOC entry 312 (class 1259 OID 19138)
-- Name: chat_attachments; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.chat_attachments (
    id integer NOT NULL,
    message_id integer,
    file_name text NOT NULL,
    mime_type text NOT NULL,
    url text NOT NULL,
    size_bytes integer,
    uploaded_at timestamp with time zone DEFAULT now()
);


ALTER TABLE app.chat_attachments OWNER TO postgres;

--
-- TOC entry 311 (class 1259 OID 19137)
-- Name: chat_attachments_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.chat_attachments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.chat_attachments_id_seq OWNER TO postgres;

--
-- TOC entry 6815 (class 0 OID 0)
-- Dependencies: 311
-- Name: chat_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.chat_attachments_id_seq OWNED BY app.chat_attachments.id;


--
-- TOC entry 251 (class 1259 OID 17386)
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
-- TOC entry 253 (class 1259 OID 17404)
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
-- TOC entry 252 (class 1259 OID 17403)
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
-- TOC entry 6816 (class 0 OID 0)
-- Dependencies: 252
-- Name: chat_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.chat_messages_id_seq OWNED BY app.chat_messages.id;


--
-- TOC entry 267 (class 1259 OID 18246)
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
-- TOC entry 318 (class 1259 OID 19185)
-- Name: chat_thread_invitations; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.chat_thread_invitations (
    id integer NOT NULL,
    thread_id integer,
    inviter_id integer,
    invitee_id integer,
    status text DEFAULT 'PENDING'::text,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT chat_thread_invitations_status_check CHECK ((status = ANY (ARRAY['PENDING'::text, 'ACCEPTED'::text, 'REJECTED'::text])))
);


ALTER TABLE app.chat_thread_invitations OWNER TO postgres;

--
-- TOC entry 317 (class 1259 OID 19184)
-- Name: chat_thread_invitations_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.chat_thread_invitations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.chat_thread_invitations_id_seq OWNER TO postgres;

--
-- TOC entry 6817 (class 0 OID 0)
-- Dependencies: 317
-- Name: chat_thread_invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.chat_thread_invitations_id_seq OWNED BY app.chat_thread_invitations.id;


--
-- TOC entry 250 (class 1259 OID 17372)
-- Name: chat_threads; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.chat_threads (
    id bigint NOT NULL,
    type text NOT NULL,
    booking_id bigint,
    last_message_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    name text,
    CONSTRAINT chat_threads_type_check CHECK ((type = ANY (ARRAY['DM'::text, 'BOOKING'::text])))
);


ALTER TABLE app.chat_threads OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 17371)
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
-- TOC entry 6818 (class 0 OID 0)
-- Dependencies: 249
-- Name: chat_threads_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.chat_threads_id_seq OWNED BY app.chat_threads.id;


--
-- TOC entry 276 (class 1259 OID 18679)
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
-- TOC entry 258 (class 1259 OID 17460)
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
    moderation_status text DEFAULT 'APPROVED'::text,
    moderated_by bigint,
    moderated_at timestamp with time zone,
    moderation_reason text,
    report_count integer DEFAULT 0,
    CONSTRAINT comments_moderation_status_check CHECK ((moderation_status = ANY (ARRAY['PENDING'::text, 'APPROVED'::text, 'HIDDEN'::text, 'DELETED'::text]))),
    CONSTRAINT comments_parent_not_self CHECK (((parent_id IS NULL) OR (parent_id <> id)))
);


ALTER TABLE app.comments OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 17459)
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
-- TOC entry 6819 (class 0 OID 0)
-- Dependencies: 257
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.comments_id_seq OWNED BY app.comments.id;


--
-- TOC entry 264 (class 1259 OID 17514)
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
-- TOC entry 263 (class 1259 OID 17513)
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
-- TOC entry 6820 (class 0 OID 0)
-- Dependencies: 263
-- Name: consents_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.consents_id_seq OWNED BY app.consents.id;


--
-- TOC entry 373 (class 1259 OID 20102)
-- Name: crisis_alerts; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.crisis_alerts (
    id integer NOT NULL,
    user_id integer NOT NULL,
    alert_type character varying(50) DEFAULT 'needs_support'::character varying NOT NULL,
    severity character varying(20) DEFAULT 'moderate'::character varying NOT NULL,
    trigger_text text,
    emotion_data jsonb DEFAULT '{}'::jsonb,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    resolved_by integer,
    resolved_at timestamp with time zone,
    resolution_notes text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE app.crisis_alerts OWNER TO postgres;

--
-- TOC entry 6821 (class 0 OID 0)
-- Dependencies: 373
-- Name: TABLE crisis_alerts; Type: COMMENT; Schema: app; Owner: postgres
--

COMMENT ON TABLE app.crisis_alerts IS 'Stores crisis detection alerts for user mental health monitoring';


--
-- TOC entry 372 (class 1259 OID 20101)
-- Name: crisis_alerts_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.crisis_alerts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.crisis_alerts_id_seq OWNER TO postgres;

--
-- TOC entry 6822 (class 0 OID 0)
-- Dependencies: 372
-- Name: crisis_alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.crisis_alerts_id_seq OWNED BY app.crisis_alerts.id;


--
-- TOC entry 349 (class 1259 OID 19831)
-- Name: daily_mood_checkins; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.daily_mood_checkins (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    checkin_date date DEFAULT CURRENT_DATE NOT NULL,
    mood text NOT NULL,
    mood_score integer,
    energy_level integer,
    sleep_hours numeric(3,1),
    sleep_quality integer,
    stress_level integer,
    gratitude_notes text[],
    concerns text,
    goals_for_day text,
    checkin_time timestamp with time zone DEFAULT now(),
    CONSTRAINT daily_mood_checkins_energy_level_check CHECK (((energy_level >= 1) AND (energy_level <= 5))),
    CONSTRAINT daily_mood_checkins_mood_score_check CHECK (((mood_score >= 1) AND (mood_score <= 5))),
    CONSTRAINT daily_mood_checkins_sleep_quality_check CHECK (((sleep_quality >= 1) AND (sleep_quality <= 5))),
    CONSTRAINT daily_mood_checkins_stress_level_check CHECK (((stress_level >= 1) AND (stress_level <= 5)))
);


ALTER TABLE app.daily_mood_checkins OWNER TO postgres;

--
-- TOC entry 348 (class 1259 OID 19830)
-- Name: daily_mood_checkins_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.daily_mood_checkins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.daily_mood_checkins_id_seq OWNER TO postgres;

--
-- TOC entry 6823 (class 0 OID 0)
-- Dependencies: 348
-- Name: daily_mood_checkins_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.daily_mood_checkins_id_seq OWNED BY app.daily_mood_checkins.id;


--
-- TOC entry 326 (class 1259 OID 19391)
-- Name: dispute_messages; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.dispute_messages (
    id bigint NOT NULL,
    dispute_id bigint NOT NULL,
    sender_id bigint NOT NULL,
    message text NOT NULL,
    attachments text[],
    is_admin boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE app.dispute_messages OWNER TO postgres;

--
-- TOC entry 325 (class 1259 OID 19390)
-- Name: dispute_messages_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

ALTER TABLE app.dispute_messages ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME app.dispute_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 324 (class 1259 OID 19356)
-- Name: disputes; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.disputes (
    id bigint NOT NULL,
    booking_id bigint NOT NULL,
    raised_by bigint NOT NULL,
    against_user bigint NOT NULL,
    reason app.dispute_reason NOT NULL,
    description text NOT NULL,
    evidence_urls text[],
    status app.dispute_status DEFAULT 'OPEN'::app.dispute_status NOT NULL,
    resolution text,
    refund_amount numeric(14,2),
    assigned_admin bigint,
    resolved_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_different_users CHECK ((raised_by <> against_user))
);


ALTER TABLE app.disputes OWNER TO postgres;

--
-- TOC entry 323 (class 1259 OID 19355)
-- Name: disputes_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

ALTER TABLE app.disputes ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME app.disputes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 305 (class 1259 OID 19028)
-- Name: domains; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.domains (
    id bigint NOT NULL,
    name text NOT NULL
);


ALTER TABLE app.domains OWNER TO postgres;

--
-- TOC entry 304 (class 1259 OID 19027)
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
-- TOC entry 6824 (class 0 OID 0)
-- Dependencies: 304
-- Name: domains_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.domains_id_seq OWNED BY app.domains.id;


--
-- TOC entry 228 (class 1259 OID 17163)
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
-- TOC entry 227 (class 1259 OID 17162)
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
-- TOC entry 6825 (class 0 OID 0)
-- Dependencies: 227
-- Name: email_verifications_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.email_verifications_id_seq OWNED BY app.email_verifications.id;


--
-- TOC entry 342 (class 1259 OID 19743)
-- Name: emotion_logs; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.emotion_logs (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    emotion text NOT NULL,
    intensity numeric(3,2) DEFAULT 0.5,
    detected_at timestamp with time zone DEFAULT now(),
    source text DEFAULT 'chat'::text NOT NULL,
    message_id bigint,
    raw_text text,
    confidence numeric(3,2) DEFAULT 0.5,
    metadata jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE app.emotion_logs OWNER TO postgres;

--
-- TOC entry 341 (class 1259 OID 19742)
-- Name: emotion_logs_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.emotion_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.emotion_logs_id_seq OWNER TO postgres;

--
-- TOC entry 6826 (class 0 OID 0)
-- Dependencies: 341
-- Name: emotion_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.emotion_logs_id_seq OWNED BY app.emotion_logs.id;


--
-- TOC entry 351 (class 1259 OID 19853)
-- Name: emotion_patterns; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.emotion_patterns (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    pattern_type text NOT NULL,
    pattern_key text NOT NULL,
    pattern_data jsonb NOT NULL,
    frequency integer DEFAULT 1,
    first_detected timestamp with time zone DEFAULT now(),
    last_detected timestamp with time zone DEFAULT now(),
    is_active boolean DEFAULT true
);


ALTER TABLE app.emotion_patterns OWNER TO postgres;

--
-- TOC entry 350 (class 1259 OID 19852)
-- Name: emotion_patterns_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.emotion_patterns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.emotion_patterns_id_seq OWNER TO postgres;

--
-- TOC entry 6827 (class 0 OID 0)
-- Dependencies: 350
-- Name: emotion_patterns_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.emotion_patterns_id_seq OWNED BY app.emotion_patterns.id;


--
-- TOC entry 303 (class 1259 OID 19012)
-- Name: expert_audience; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.expert_audience (
    expert_id bigint NOT NULL,
    audience_id bigint NOT NULL
);


ALTER TABLE app.expert_audience OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 17216)
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
-- TOC entry 233 (class 1259 OID 17215)
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
-- TOC entry 6828 (class 0 OID 0)
-- Dependencies: 233
-- Name: expert_availabilities_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.expert_availabilities_id_seq OWNED BY app.expert_availabilities.id;


--
-- TOC entry 296 (class 1259 OID 18945)
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
-- TOC entry 295 (class 1259 OID 18944)
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
-- TOC entry 6829 (class 0 OID 0)
-- Dependencies: 295
-- Name: expert_certifications_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.expert_certifications_id_seq OWNED BY app.expert_certifications.id;


--
-- TOC entry 306 (class 1259 OID 19038)
-- Name: expert_domain; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.expert_domain (
    expert_id bigint NOT NULL,
    domain_id bigint NOT NULL
);


ALTER TABLE app.expert_domain OWNER TO postgres;

--
-- TOC entry 294 (class 1259 OID 18931)
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
-- TOC entry 293 (class 1259 OID 18930)
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
-- TOC entry 6830 (class 0 OID 0)
-- Dependencies: 293
-- Name: expert_education_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.expert_education_id_seq OWNED BY app.expert_education.id;


--
-- TOC entry 292 (class 1259 OID 18917)
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
-- TOC entry 291 (class 1259 OID 18916)
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
-- TOC entry 6831 (class 0 OID 0)
-- Dependencies: 291
-- Name: expert_experience_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.expert_experience_id_seq OWNED BY app.expert_experience.id;


--
-- TOC entry 300 (class 1259 OID 18987)
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
-- TOC entry 299 (class 1259 OID 18986)
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
-- TOC entry 6832 (class 0 OID 0)
-- Dependencies: 299
-- Name: expert_media_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.expert_media_id_seq OWNED BY app.expert_media.id;


--
-- TOC entry 297 (class 1259 OID 18958)
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
-- TOC entry 230 (class 1259 OID 17180)
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
-- TOC entry 229 (class 1259 OID 17179)
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
-- TOC entry 6833 (class 0 OID 0)
-- Dependencies: 229
-- Name: expert_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.expert_profiles_id_seq OWNED BY app.expert_profiles.id;


--
-- TOC entry 290 (class 1259 OID 18900)
-- Name: expert_skills; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.expert_skills (
    expert_id bigint NOT NULL,
    skill_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE app.expert_skills OWNER TO postgres;

--
-- TOC entry 298 (class 1259 OID 18971)
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
-- TOC entry 232 (class 1259 OID 17199)
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
-- TOC entry 231 (class 1259 OID 17198)
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
-- TOC entry 6834 (class 0 OID 0)
-- Dependencies: 231
-- Name: listener_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.listener_profiles_id_seq OWNED BY app.listener_profiles.id;


--
-- TOC entry 345 (class 1259 OID 19787)
-- Name: mental_health_assessments; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.mental_health_assessments (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    assessment_type text DEFAULT 'auto'::text NOT NULL,
    risk_level text DEFAULT 'low'::text NOT NULL,
    burnout_score integer DEFAULT 0,
    depression_indicators integer DEFAULT 0,
    anxiety_indicators integer DEFAULT 0,
    sleep_quality_score integer,
    social_engagement_score integer,
    assessed_at timestamp with time zone DEFAULT now(),
    recommendations jsonb DEFAULT '[]'::jsonb,
    triggers_detected text[],
    notes text,
    reviewed_by bigint,
    reviewed_at timestamp with time zone,
    CONSTRAINT mental_health_assessments_burnout_score_check CHECK (((burnout_score >= 0) AND (burnout_score <= 100))),
    CONSTRAINT mental_health_assessments_risk_level_check CHECK ((risk_level = ANY (ARRAY['low'::text, 'moderate'::text, 'high'::text, 'critical'::text]))),
    CONSTRAINT mental_health_assessments_sleep_quality_score_check CHECK (((sleep_quality_score >= 0) AND (sleep_quality_score <= 10))),
    CONSTRAINT mental_health_assessments_social_engagement_score_check CHECK (((social_engagement_score >= 0) AND (social_engagement_score <= 10)))
);


ALTER TABLE app.mental_health_assessments OWNER TO postgres;

--
-- TOC entry 344 (class 1259 OID 19786)
-- Name: mental_health_assessments_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.mental_health_assessments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.mental_health_assessments_id_seq OWNER TO postgres;

--
-- TOC entry 6835 (class 0 OID 0)
-- Dependencies: 344
-- Name: mental_health_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.mental_health_assessments_id_seq OWNED BY app.mental_health_assessments.id;


--
-- TOC entry 262 (class 1259 OID 17497)
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
-- TOC entry 261 (class 1259 OID 17496)
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
-- TOC entry 6836 (class 0 OID 0)
-- Dependencies: 261
-- Name: moderation_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.moderation_actions_id_seq OWNED BY app.moderation_actions.id;


--
-- TOC entry 287 (class 1259 OID 18872)
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
-- TOC entry 286 (class 1259 OID 18871)
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
-- TOC entry 6837 (class 0 OID 0)
-- Dependencies: 286
-- Name: oauth_users_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.oauth_users_id_seq OWNED BY app.oauth_users.id;


--
-- TOC entry 375 (class 1259 OID 20136)
-- Name: password_resets; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.password_resets (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    email text NOT NULL,
    otp_code character(6) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    used boolean DEFAULT false,
    used_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    ip_address inet,
    user_agent text
);


ALTER TABLE app.password_resets OWNER TO postgres;

--
-- TOC entry 6838 (class 0 OID 0)
-- Dependencies: 375
-- Name: TABLE password_resets; Type: COMMENT; Schema: app; Owner: postgres
--

COMMENT ON TABLE app.password_resets IS 'Store OTP codes for password reset requests';


--
-- TOC entry 374 (class 1259 OID 20135)
-- Name: password_resets_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.password_resets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.password_resets_id_seq OWNER TO postgres;

--
-- TOC entry 6839 (class 0 OID 0)
-- Dependencies: 374
-- Name: password_resets_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.password_resets_id_seq OWNED BY app.password_resets.id;


--
-- TOC entry 240 (class 1259 OID 17280)
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
-- TOC entry 239 (class 1259 OID 17279)
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
-- TOC entry 6840 (class 0 OID 0)
-- Dependencies: 239
-- Name: payment_intents_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.payment_intents_id_seq OWNED BY app.payment_intents.id;


--
-- TOC entry 242 (class 1259 OID 17304)
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
-- TOC entry 241 (class 1259 OID 17303)
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
-- TOC entry 6841 (class 0 OID 0)
-- Dependencies: 241
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.payments_id_seq OWNED BY app.payments.id;


--
-- TOC entry 285 (class 1259 OID 18840)
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
-- TOC entry 284 (class 1259 OID 18839)
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
-- TOC entry 6842 (class 0 OID 0)
-- Dependencies: 284
-- Name: payout_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.payout_accounts_id_seq OWNED BY app.payout_accounts.id;


--
-- TOC entry 308 (class 1259 OID 19056)
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
    processed_by bigint,
    processed_at timestamp with time zone,
    CONSTRAINT payout_requests_amount_check CHECK ((amount > (0)::numeric)),
    CONSTRAINT payout_requests_status_check CHECK ((status = ANY (ARRAY['PENDING'::text, 'APPROVED'::text, 'REJECTED'::text, 'PROCESSED'::text])))
);


ALTER TABLE app.payout_requests OWNER TO postgres;

--
-- TOC entry 307 (class 1259 OID 19055)
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
-- TOC entry 320 (class 1259 OID 19304)
-- Name: platform_settings; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.platform_settings (
    id bigint NOT NULL,
    key text NOT NULL,
    value jsonb NOT NULL,
    description text,
    updated_at timestamp with time zone DEFAULT now(),
    updated_by bigint
);


ALTER TABLE app.platform_settings OWNER TO postgres;

--
-- TOC entry 319 (class 1259 OID 19303)
-- Name: platform_settings_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

ALTER TABLE app.platform_settings ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME app.platform_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 273 (class 1259 OID 18629)
-- Name: post_audience; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.post_audience (
    post_id bigint NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE app.post_audience OWNER TO postgres;

--
-- TOC entry 277 (class 1259 OID 18701)
-- Name: post_files; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.post_files (
    post_id bigint NOT NULL,
    file_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE app.post_files OWNER TO postgres;

--
-- TOC entry 275 (class 1259 OID 18650)
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
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    original_name text,
    public_id text
);


ALTER TABLE app.post_media OWNER TO postgres;

--
-- TOC entry 6843 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN post_media.original_name; Type: COMMENT; Schema: app; Owner: postgres
--

COMMENT ON COLUMN app.post_media.original_name IS 'Original filename from user upload';


--
-- TOC entry 6844 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN post_media.public_id; Type: COMMENT; Schema: app; Owner: postgres
--

COMMENT ON COLUMN app.post_media.public_id IS 'Cloudinary public_id for file management';


--
-- TOC entry 274 (class 1259 OID 18649)
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
-- TOC entry 6845 (class 0 OID 0)
-- Dependencies: 274
-- Name: post_media_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.post_media_id_seq OWNED BY app.post_media.id;


--
-- TOC entry 256 (class 1259 OID 17440)
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
-- TOC entry 278 (class 1259 OID 18718)
-- Name: post_saves; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.post_saves (
    user_id bigint NOT NULL,
    post_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE app.post_saves OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 17424)
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
    privacy app.post_privacy DEFAULT 'PUBLIC'::app.post_privacy NOT NULL,
    report_count integer DEFAULT 0
);


ALTER TABLE app.posts OWNER TO postgres;

--
-- TOC entry 254 (class 1259 OID 17423)
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
-- TOC entry 6846 (class 0 OID 0)
-- Dependencies: 254
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.posts_id_seq OWNED BY app.posts.id;


--
-- TOC entry 364 (class 1259 OID 19989)
-- Name: proactive_messages; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.proactive_messages (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    trigger_type text NOT NULL,
    trigger_data jsonb DEFAULT '{}'::jsonb,
    message_content text NOT NULL,
    persona_id bigint,
    priority integer DEFAULT 2,
    scheduled_at timestamp with time zone NOT NULL,
    expires_at timestamp with time zone,
    sent_at timestamp with time zone,
    is_sent boolean DEFAULT false,
    user_response text,
    effectiveness_score integer,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE app.proactive_messages OWNER TO postgres;

--
-- TOC entry 363 (class 1259 OID 19988)
-- Name: proactive_messages_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.proactive_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.proactive_messages_id_seq OWNER TO postgres;

--
-- TOC entry 6847 (class 0 OID 0)
-- Dependencies: 363
-- Name: proactive_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.proactive_messages_id_seq OWNED BY app.proactive_messages.id;


--
-- TOC entry 279 (class 1259 OID 18765)
-- Name: processed_events; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.processed_events (
    idempotency_key text NOT NULL,
    occurred_at timestamp with time zone DEFAULT now()
);


ALTER TABLE app.processed_events OWNER TO postgres;

--
-- TOC entry 332 (class 1259 OID 19473)
-- Name: product_reviews; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.product_reviews (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    user_id bigint NOT NULL,
    rating integer NOT NULL,
    comment text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT product_reviews_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE app.product_reviews OWNER TO postgres;

--
-- TOC entry 331 (class 1259 OID 19472)
-- Name: product_reviews_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

ALTER TABLE app.product_reviews ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME app.product_reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 328 (class 1259 OID 19412)
-- Name: recurring_booking_templates; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.recurring_booking_templates (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    expert_id bigint NOT NULL,
    channel text NOT NULL,
    start_time time without time zone NOT NULL,
    duration_minutes integer NOT NULL,
    frequency app.recurring_frequency NOT NULL,
    day_of_week integer,
    day_of_month integer,
    price_per_session numeric(12,2) NOT NULL,
    total_sessions integer,
    sessions_completed integer DEFAULT 0,
    is_active boolean DEFAULT true,
    next_booking_date date,
    starts_from date NOT NULL,
    ends_at date,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_expert_not_self CHECK ((user_id <> expert_id)),
    CONSTRAINT recurring_booking_templates_channel_check CHECK ((channel = ANY (ARRAY['CHAT'::text, 'VIDEO'::text, 'AUDIO'::text]))),
    CONSTRAINT recurring_booking_templates_day_of_month_check CHECK (((day_of_month >= 1) AND (day_of_month <= 31))),
    CONSTRAINT recurring_booking_templates_day_of_week_check CHECK (((day_of_week >= 0) AND (day_of_week <= 6))),
    CONSTRAINT recurring_booking_templates_duration_minutes_check CHECK (((duration_minutes >= 60) AND (duration_minutes <= 180))),
    CONSTRAINT recurring_booking_templates_price_per_session_check CHECK ((price_per_session >= (0)::numeric))
);


ALTER TABLE app.recurring_booking_templates OWNER TO postgres;

--
-- TOC entry 327 (class 1259 OID 19411)
-- Name: recurring_booking_templates_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

ALTER TABLE app.recurring_booking_templates ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME app.recurring_booking_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 322 (class 1259 OID 19320)
-- Name: refunds; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.refunds (
    id bigint NOT NULL,
    booking_id bigint NOT NULL,
    payment_intent_id bigint NOT NULL,
    user_id bigint NOT NULL,
    amount numeric(14,2) NOT NULL,
    platform_fee_refunded numeric(14,2) DEFAULT 0,
    reason text NOT NULL,
    status app.refund_status DEFAULT 'PENDING'::app.refund_status NOT NULL,
    admin_note text,
    processed_by bigint,
    processed_at timestamp with time zone,
    provider_refund_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT refunds_amount_check CHECK ((amount > (0)::numeric))
);


ALTER TABLE app.refunds OWNER TO postgres;

--
-- TOC entry 321 (class 1259 OID 19319)
-- Name: refunds_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

ALTER TABLE app.refunds ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME app.refunds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 260 (class 1259 OID 17481)
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
    status text DEFAULT 'PENDING'::text,
    resolved_by bigint,
    resolved_at timestamp with time zone,
    resolution_note text,
    action_taken text,
    CONSTRAINT reports_action_taken_check CHECK ((action_taken = ANY (ARRAY['NONE'::text, 'WARNING'::text, 'CONTENT_HIDDEN'::text, 'CONTENT_DELETED'::text, 'USER_SUSPENDED'::text, 'USER_BANNED'::text]))),
    CONSTRAINT reports_status_check CHECK ((status = ANY (ARRAY['PENDING'::text, 'RESOLVED'::text, 'DISMISSED'::text, 'IN_REVIEW'::text]))),
    CONSTRAINT reports_target_type_check CHECK ((target_type = ANY (ARRAY['POST'::text, 'COMMENT'::text, 'USER'::text, 'MESSAGE'::text])))
);


ALTER TABLE app.reports OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 17480)
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
-- TOC entry 6848 (class 0 OID 0)
-- Dependencies: 259
-- Name: reports_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.reports_id_seq OWNED BY app.reports.id;


--
-- TOC entry 281 (class 1259 OID 18795)
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
    is_hidden boolean DEFAULT false,
    hidden_reason text,
    hidden_at timestamp with time zone,
    hidden_by bigint,
    CONSTRAINT reviews_rating_check CHECK (((rating >= (0)::numeric) AND (rating <= (5)::numeric)))
);


ALTER TABLE app.reviews OWNER TO postgres;

--
-- TOC entry 280 (class 1259 OID 18794)
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
-- TOC entry 6849 (class 0 OID 0)
-- Dependencies: 280
-- Name: reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.reviews_id_seq OWNED BY app.reviews.id;


--
-- TOC entry 310 (class 1259 OID 19071)
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
-- TOC entry 309 (class 1259 OID 19070)
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
-- TOC entry 6850 (class 0 OID 0)
-- Dependencies: 309
-- Name: schema_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.schema_migrations_id_seq OWNED BY app.schema_migrations.id;


--
-- TOC entry 238 (class 1259 OID 17258)
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
-- TOC entry 237 (class 1259 OID 17257)
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
-- TOC entry 6851 (class 0 OID 0)
-- Dependencies: 237
-- Name: session_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.session_notes_id_seq OWNED BY app.session_notes.id;


--
-- TOC entry 289 (class 1259 OID 18890)
-- Name: skills; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.skills (
    id bigint NOT NULL,
    name text NOT NULL,
    category text,
    description text
);


ALTER TABLE app.skills OWNER TO postgres;

--
-- TOC entry 288 (class 1259 OID 18889)
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
-- TOC entry 6852 (class 0 OID 0)
-- Dependencies: 288
-- Name: skills_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.skills_id_seq OWNED BY app.skills.id;


--
-- TOC entry 360 (class 1259 OID 19948)
-- Name: sleep_logs; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.sleep_logs (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    date date DEFAULT CURRENT_DATE NOT NULL,
    sleep_at timestamp with time zone,
    wake_at timestamp with time zone,
    duration_minutes integer,
    quality integer,
    deep_sleep_minutes integer,
    interruptions integer DEFAULT 0,
    notes text,
    factors text[],
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT sleep_logs_quality_check CHECK (((quality >= 1) AND (quality <= 5)))
);


ALTER TABLE app.sleep_logs OWNER TO postgres;

--
-- TOC entry 359 (class 1259 OID 19947)
-- Name: sleep_logs_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.sleep_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.sleep_logs_id_seq OWNER TO postgres;

--
-- TOC entry 6853 (class 0 OID 0)
-- Dependencies: 359
-- Name: sleep_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.sleep_logs_id_seq OWNED BY app.sleep_logs.id;


--
-- TOC entry 248 (class 1259 OID 17351)
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
-- TOC entry 247 (class 1259 OID 17350)
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
-- TOC entry 6854 (class 0 OID 0)
-- Dependencies: 247
-- Name: tips_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.tips_id_seq OWNED BY app.tips.id;


--
-- TOC entry 368 (class 1259 OID 20027)
-- Name: user_activity_logs; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.user_activity_logs (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    activity_type text NOT NULL,
    activity_data jsonb DEFAULT '{}'::jsonb,
    session_id text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE app.user_activity_logs OWNER TO postgres;

--
-- TOC entry 367 (class 1259 OID 20026)
-- Name: user_activity_logs_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.user_activity_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.user_activity_logs_id_seq OWNER TO postgres;

--
-- TOC entry 6855 (class 0 OID 0)
-- Dependencies: 367
-- Name: user_activity_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.user_activity_logs_id_seq OWNED BY app.user_activity_logs.id;


--
-- TOC entry 336 (class 1259 OID 19530)
-- Name: user_ai_settings; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.user_ai_settings (
    user_id bigint NOT NULL,
    persona_id bigint,
    relationship_level integer DEFAULT 1,
    custom_nickname text,
    user_nickname text,
    notification_enabled boolean DEFAULT true,
    morning_checkin boolean DEFAULT true,
    evening_checkin boolean DEFAULT true,
    random_messages boolean DEFAULT true,
    quiet_hours_start time without time zone DEFAULT '23:00:00'::time without time zone,
    quiet_hours_end time without time zone DEFAULT '07:00:00'::time without time zone,
    timezone text DEFAULT 'Asia/Ho_Chi_Minh'::text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT user_ai_settings_relationship_level_check CHECK (((relationship_level >= 1) AND (relationship_level <= 4)))
);


ALTER TABLE app.user_ai_settings OWNER TO postgres;

--
-- TOC entry 333 (class 1259 OID 19494)
-- Name: user_blocks; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.user_blocks (
    blocker_id bigint NOT NULL,
    blocked_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT user_blocks_no_self_block CHECK ((blocker_id <> blocked_id))
);


ALTER TABLE app.user_blocks OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 17147)
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
-- TOC entry 225 (class 1259 OID 17146)
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
-- TOC entry 6856 (class 0 OID 0)
-- Dependencies: 225
-- Name: user_files_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.user_files_id_seq OWNED BY app.user_files.id;


--
-- TOC entry 272 (class 1259 OID 18603)
-- Name: user_follows; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.user_follows (
    follower_id bigint NOT NULL,
    followee_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE app.user_follows OWNER TO postgres;

--
-- TOC entry 343 (class 1259 OID 19761)
-- Name: user_mental_state; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.user_mental_state (
    user_id bigint NOT NULL,
    current_mood text DEFAULT 'neutral'::text,
    mood_score numeric(3,2) DEFAULT 0.5,
    stress_level integer DEFAULT 0,
    anxiety_level integer DEFAULT 0,
    energy_level integer DEFAULT 5,
    vulnerability_score numeric(3,2) DEFAULT 0.0,
    consecutive_negative_days integer DEFAULT 0,
    last_positive_interaction timestamp with time zone,
    last_evaluated timestamp with time zone DEFAULT now(),
    evaluation_notes text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT user_mental_state_anxiety_level_check CHECK (((anxiety_level >= 0) AND (anxiety_level <= 10))),
    CONSTRAINT user_mental_state_energy_level_check CHECK (((energy_level >= 0) AND (energy_level <= 10))),
    CONSTRAINT user_mental_state_stress_level_check CHECK (((stress_level >= 0) AND (stress_level <= 10)))
);


ALTER TABLE app.user_mental_state OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 17121)
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
-- TOC entry 224 (class 1259 OID 17136)
-- Name: user_roles; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.user_roles (
    user_id bigint NOT NULL,
    role app.user_role NOT NULL
);


ALTER TABLE app.user_roles OWNER TO postgres;

--
-- TOC entry 358 (class 1259 OID 19924)
-- Name: user_schedules; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.user_schedules (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    title text NOT NULL,
    description text,
    schedule_type text NOT NULL,
    start_at timestamp with time zone NOT NULL,
    end_at timestamp with time zone,
    is_all_day boolean DEFAULT false,
    recurrence text,
    remind_before integer DEFAULT 15,
    priority integer DEFAULT 2,
    ai_generated boolean DEFAULT false,
    completed boolean DEFAULT false,
    completed_at timestamp with time zone,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT user_schedules_priority_check CHECK (((priority >= 1) AND (priority <= 5))),
    CONSTRAINT user_schedules_schedule_type_check CHECK ((schedule_type = ANY (ARRAY['study'::text, 'work'::text, 'health'::text, 'medication'::text, 'exercise'::text, 'sleep'::text, 'meal'::text, 'appointment'::text, 'deadline'::text, 'reminder'::text, 'custom'::text])))
);


ALTER TABLE app.user_schedules OWNER TO postgres;

--
-- TOC entry 357 (class 1259 OID 19923)
-- Name: user_schedules_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.user_schedules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.user_schedules_id_seq OWNER TO postgres;

--
-- TOC entry 6857 (class 0 OID 0)
-- Dependencies: 357
-- Name: user_schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.user_schedules_id_seq OWNED BY app.user_schedules.id;


--
-- TOC entry 283 (class 1259 OID 18822)
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
-- TOC entry 282 (class 1259 OID 18821)
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
-- TOC entry 6858 (class 0 OID 0)
-- Dependencies: 282
-- Name: user_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.user_sessions_id_seq OWNED BY app.user_sessions.id;


--
-- TOC entry 222 (class 1259 OID 17102)
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
-- TOC entry 221 (class 1259 OID 17101)
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
-- TOC entry 6859 (class 0 OID 0)
-- Dependencies: 221
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.users_id_seq OWNED BY app.users.id;


--
-- TOC entry 356 (class 1259 OID 19919)
-- Name: v_ai_chat_summary; Type: VIEW; Schema: app; Owner: postgres
--

CREATE VIEW app.v_ai_chat_summary AS
 SELECT user_id,
    count(*) AS total_messages,
    count(*) FILTER (WHERE (role = 'user'::text)) AS user_messages,
    count(*) FILTER (WHERE (role = 'ai'::text)) AS ai_messages,
    max(created_at) AS last_message_at
   FROM app.ai_chat_history
  GROUP BY user_id;


ALTER VIEW app.v_ai_chat_summary OWNER TO postgres;

--
-- TOC entry 371 (class 1259 OID 20062)
-- Name: v_inactive_users; Type: VIEW; Schema: app; Owner: postgres
--

CREATE VIEW app.v_inactive_users AS
 SELECT s.user_id,
    s.persona_id,
    s.custom_nickname,
    max(a.created_at) AS last_activity,
    (EXTRACT(epoch FROM (now() - max(a.created_at))) / (3600)::numeric) AS hours_inactive
   FROM (app.user_ai_settings s
     LEFT JOIN app.user_activity_logs a ON ((s.user_id = a.user_id)))
  WHERE (s.notification_enabled = true)
  GROUP BY s.user_id, s.persona_id, s.custom_nickname
 HAVING ((max(a.created_at) < (now() - '24:00:00'::interval)) OR (max(a.created_at) IS NULL));


ALTER VIEW app.v_inactive_users OWNER TO postgres;

--
-- TOC entry 369 (class 1259 OID 20053)
-- Name: v_today_schedules; Type: VIEW; Schema: app; Owner: postgres
--

CREATE VIEW app.v_today_schedules AS
 SELECT s.id,
    s.user_id,
    s.title,
    s.description,
    s.schedule_type,
    s.start_at,
    s.end_at,
    s.is_all_day,
    s.recurrence,
    s.remind_before,
    s.priority,
    s.ai_generated,
    s.completed,
    s.completed_at,
    s.metadata,
    s.created_at,
    s.updated_at,
    u.display_name AS user_name
   FROM (app.user_schedules s
     JOIN app.user_profiles u ON ((s.user_id = u.user_id)))
  WHERE ((date(s.start_at) = CURRENT_DATE) AND (s.completed = false))
  ORDER BY s.start_at;


ALTER VIEW app.v_today_schedules OWNER TO postgres;

--
-- TOC entry 352 (class 1259 OID 19885)
-- Name: v_user_emotion_summary; Type: VIEW; Schema: app; Owner: postgres
--

CREATE VIEW app.v_user_emotion_summary AS
 SELECT user_id,
    count(*) AS total_logs,
    count(*) FILTER (WHERE (emotion = ANY (ARRAY['happy'::text, 'excited'::text]))) AS positive_count,
    count(*) FILTER (WHERE (emotion = ANY (ARRAY['sad'::text, 'anxious'::text, 'stressed'::text, 'angry'::text]))) AS negative_count,
    count(*) FILTER (WHERE (emotion = 'neutral'::text)) AS neutral_count,
    avg(intensity) AS avg_intensity,
    mode() WITHIN GROUP (ORDER BY emotion) AS dominant_emotion
   FROM app.emotion_logs
  WHERE (detected_at > (now() - '7 days'::interval))
  GROUP BY user_id;


ALTER VIEW app.v_user_emotion_summary OWNER TO postgres;

--
-- TOC entry 370 (class 1259 OID 20058)
-- Name: v_user_sleep_summary; Type: VIEW; Schema: app; Owner: postgres
--

CREATE VIEW app.v_user_sleep_summary AS
 SELECT user_id,
    count(*) AS logged_days,
    avg(duration_minutes) AS avg_duration,
    avg(quality) AS avg_quality,
    min((sleep_at)::time without time zone) AS earliest_sleep,
    max((sleep_at)::time without time zone) AS latest_sleep,
    avg(interruptions) AS avg_interruptions
   FROM app.sleep_logs
  WHERE (date > (CURRENT_DATE - 7))
  GROUP BY user_id;


ALTER VIEW app.v_user_sleep_summary OWNER TO postgres;

--
-- TOC entry 353 (class 1259 OID 19890)
-- Name: v_users_needing_attention; Type: VIEW; Schema: app; Owner: postgres
--

CREATE VIEW app.v_users_needing_attention AS
 SELECT ms.user_id,
    ms.current_mood,
    ms.stress_level,
    ms.vulnerability_score,
    ms.consecutive_negative_days,
    ms.last_evaluated,
    mha.risk_level AS latest_risk_level,
    mha.assessed_at AS latest_assessment
   FROM (app.user_mental_state ms
     LEFT JOIN LATERAL ( SELECT mental_health_assessments.risk_level,
            mental_health_assessments.assessed_at
           FROM app.mental_health_assessments
          WHERE (mental_health_assessments.user_id = ms.user_id)
          ORDER BY mental_health_assessments.assessed_at DESC
         LIMIT 1) mha ON (true))
  WHERE ((ms.stress_level >= 7) OR (ms.vulnerability_score >= 0.7) OR (ms.consecutive_negative_days >= 3) OR (mha.risk_level = ANY (ARRAY['high'::text, 'critical'::text])));


ALTER VIEW app.v_users_needing_attention OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 17335)
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
-- TOC entry 245 (class 1259 OID 17334)
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
-- TOC entry 6860 (class 0 OID 0)
-- Dependencies: 245
-- Name: wallet_ledger_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.wallet_ledger_id_seq OWNED BY app.wallet_ledger.id;


--
-- TOC entry 244 (class 1259 OID 17320)
-- Name: wallets; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.wallets (
    id bigint NOT NULL,
    owner_user_id bigint NOT NULL,
    balance numeric(14,2) DEFAULT 0 NOT NULL
);


ALTER TABLE app.wallets OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 17319)
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
-- TOC entry 6861 (class 0 OID 0)
-- Dependencies: 243
-- Name: wallets_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.wallets_id_seq OWNED BY app.wallets.id;


--
-- TOC entry 347 (class 1259 OID 19812)
-- Name: wellness_activities; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.wellness_activities (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    activity_type text NOT NULL,
    title text,
    description text,
    duration_minutes integer DEFAULT 0,
    completed_at timestamp with time zone DEFAULT now(),
    mood_before text,
    mood_after text,
    effectiveness_rating integer,
    notes text,
    suggested_by text DEFAULT 'ai'::text,
    metadata jsonb DEFAULT '{}'::jsonb,
    CONSTRAINT wellness_activities_effectiveness_rating_check CHECK (((effectiveness_rating >= 1) AND (effectiveness_rating <= 5)))
);


ALTER TABLE app.wellness_activities OWNER TO postgres;

--
-- TOC entry 346 (class 1259 OID 19811)
-- Name: wellness_activities_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.wellness_activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE app.wellness_activities_id_seq OWNER TO postgres;

--
-- TOC entry 6862 (class 0 OID 0)
-- Dependencies: 346
-- Name: wellness_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.wellness_activities_id_seq OWNED BY app.wellness_activities.id;


--
-- TOC entry 5822 (class 2604 OID 19899)
-- Name: ai_chat_history id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.ai_chat_history ALTER COLUMN id SET DEFAULT nextval('app.ai_chat_history_id_seq'::regclass);


--
-- TOC entry 5781 (class 2604 OID 19585)
-- Name: ai_conversation_context id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.ai_conversation_context ALTER COLUMN id SET DEFAULT nextval('app.ai_conversation_context_id_seq'::regclass);


--
-- TOC entry 5760 (class 2604 OID 19517)
-- Name: ai_personas id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.ai_personas ALTER COLUMN id SET DEFAULT nextval('app.ai_personas_id_seq'::regclass);


--
-- TOC entry 5777 (class 2604 OID 19562)
-- Name: ai_scheduled_notifications id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.ai_scheduled_notifications ALTER COLUMN id SET DEFAULT nextval('app.ai_scheduled_notifications_id_seq'::regclass);


--
-- TOC entry 5849 (class 2604 OID 20015)
-- Name: ai_suggestions id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.ai_suggestions ALTER COLUMN id SET DEFAULT nextval('app.ai_suggestions_id_seq'::regclass);


--
-- TOC entry 5725 (class 2604 OID 19005)
-- Name: audience id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.audience ALTER COLUMN id SET DEFAULT nextval('app.audience_id_seq'::regclass);


--
-- TOC entry 5686 (class 2604 OID 17532)
-- Name: audit_logs id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.audit_logs ALTER COLUMN id SET DEFAULT nextval('app.audit_logs_id_seq'::regclass);


--
-- TOC entry 5838 (class 2604 OID 19971)
-- Name: behavior_patterns id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.behavior_patterns ALTER COLUMN id SET DEFAULT nextval('app.behavior_patterns_id_seq'::regclass);


--
-- TOC entry 5643 (class 2604 OID 17235)
-- Name: bookings id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.bookings ALTER COLUMN id SET DEFAULT nextval('app.bookings_id_seq'::regclass);


--
-- TOC entry 5691 (class 2604 OID 18565)
-- Name: call_events id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.call_events ALTER COLUMN id SET DEFAULT nextval('app.call_events_id_seq'::regclass);


--
-- TOC entry 5734 (class 2604 OID 19158)
-- Name: call_metrics id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.call_metrics ALTER COLUMN id SET DEFAULT nextval('app.call_metrics_id_seq'::regclass);


--
-- TOC entry 5736 (class 2604 OID 19172)
-- Name: call_recordings id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.call_recordings ALTER COLUMN id SET DEFAULT nextval('app.call_recordings_id_seq'::regclass);


--
-- TOC entry 5689 (class 2604 OID 18536)
-- Name: call_sessions id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.call_sessions ALTER COLUMN id SET DEFAULT nextval('app.call_sessions_id_seq'::regclass);


--
-- TOC entry 5732 (class 2604 OID 19141)
-- Name: chat_attachments id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_attachments ALTER COLUMN id SET DEFAULT nextval('app.chat_attachments_id_seq'::regclass);


--
-- TOC entry 5664 (class 2604 OID 17407)
-- Name: chat_messages id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_messages ALTER COLUMN id SET DEFAULT nextval('app.chat_messages_id_seq'::regclass);


--
-- TOC entry 5738 (class 2604 OID 19188)
-- Name: chat_thread_invitations id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_thread_invitations ALTER COLUMN id SET DEFAULT nextval('app.chat_thread_invitations_id_seq'::regclass);


--
-- TOC entry 5661 (class 2604 OID 17375)
-- Name: chat_threads id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_threads ALTER COLUMN id SET DEFAULT nextval('app.chat_threads_id_seq'::regclass);


--
-- TOC entry 5673 (class 2604 OID 17463)
-- Name: comments id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.comments ALTER COLUMN id SET DEFAULT nextval('app.comments_id_seq'::regclass);


--
-- TOC entry 5684 (class 2604 OID 17517)
-- Name: consents id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.consents ALTER COLUMN id SET DEFAULT nextval('app.consents_id_seq'::regclass);


--
-- TOC entry 5854 (class 2604 OID 20105)
-- Name: crisis_alerts id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.crisis_alerts ALTER COLUMN id SET DEFAULT nextval('app.crisis_alerts_id_seq'::regclass);


--
-- TOC entry 5814 (class 2604 OID 19834)
-- Name: daily_mood_checkins id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.daily_mood_checkins ALTER COLUMN id SET DEFAULT nextval('app.daily_mood_checkins_id_seq'::regclass);


--
-- TOC entry 5726 (class 2604 OID 19031)
-- Name: domains id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.domains ALTER COLUMN id SET DEFAULT nextval('app.domains_id_seq'::regclass);


--
-- TOC entry 5634 (class 2604 OID 17166)
-- Name: email_verifications id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.email_verifications ALTER COLUMN id SET DEFAULT nextval('app.email_verifications_id_seq'::regclass);


--
-- TOC entry 5785 (class 2604 OID 19746)
-- Name: emotion_logs id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.emotion_logs ALTER COLUMN id SET DEFAULT nextval('app.emotion_logs_id_seq'::regclass);


--
-- TOC entry 5817 (class 2604 OID 19856)
-- Name: emotion_patterns id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.emotion_patterns ALTER COLUMN id SET DEFAULT nextval('app.emotion_patterns_id_seq'::regclass);


--
-- TOC entry 5641 (class 2604 OID 17219)
-- Name: expert_availabilities id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_availabilities ALTER COLUMN id SET DEFAULT nextval('app.expert_availabilities_id_seq'::regclass);


--
-- TOC entry 5716 (class 2604 OID 18948)
-- Name: expert_certifications id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_certifications ALTER COLUMN id SET DEFAULT nextval('app.expert_certifications_id_seq'::regclass);


--
-- TOC entry 5715 (class 2604 OID 18934)
-- Name: expert_education id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_education ALTER COLUMN id SET DEFAULT nextval('app.expert_education_id_seq'::regclass);


--
-- TOC entry 5714 (class 2604 OID 18920)
-- Name: expert_experience id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_experience ALTER COLUMN id SET DEFAULT nextval('app.expert_experience_id_seq'::regclass);


--
-- TOC entry 5723 (class 2604 OID 18990)
-- Name: expert_media id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_media ALTER COLUMN id SET DEFAULT nextval('app.expert_media_id_seq'::regclass);


--
-- TOC entry 5637 (class 2604 OID 17183)
-- Name: expert_profiles id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_profiles ALTER COLUMN id SET DEFAULT nextval('app.expert_profiles_id_seq'::regclass);


--
-- TOC entry 5639 (class 2604 OID 17202)
-- Name: listener_profiles id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.listener_profiles ALTER COLUMN id SET DEFAULT nextval('app.listener_profiles_id_seq'::regclass);


--
-- TOC entry 5801 (class 2604 OID 19790)
-- Name: mental_health_assessments id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.mental_health_assessments ALTER COLUMN id SET DEFAULT nextval('app.mental_health_assessments_id_seq'::regclass);


--
-- TOC entry 5682 (class 2604 OID 17500)
-- Name: moderation_actions id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.moderation_actions ALTER COLUMN id SET DEFAULT nextval('app.moderation_actions_id_seq'::regclass);


--
-- TOC entry 5710 (class 2604 OID 18875)
-- Name: oauth_users id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.oauth_users ALTER COLUMN id SET DEFAULT nextval('app.oauth_users_id_seq'::regclass);


--
-- TOC entry 5861 (class 2604 OID 20139)
-- Name: password_resets id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.password_resets ALTER COLUMN id SET DEFAULT nextval('app.password_resets_id_seq'::regclass);


--
-- TOC entry 5650 (class 2604 OID 17283)
-- Name: payment_intents id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payment_intents ALTER COLUMN id SET DEFAULT nextval('app.payment_intents_id_seq'::regclass);


--
-- TOC entry 5654 (class 2604 OID 17307)
-- Name: payments id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payments ALTER COLUMN id SET DEFAULT nextval('app.payments_id_seq'::regclass);


--
-- TOC entry 5707 (class 2604 OID 18843)
-- Name: payout_accounts id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payout_accounts ALTER COLUMN id SET DEFAULT nextval('app.payout_accounts_id_seq'::regclass);


--
-- TOC entry 5694 (class 2604 OID 18653)
-- Name: post_media id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_media ALTER COLUMN id SET DEFAULT nextval('app.post_media_id_seq'::regclass);


--
-- TOC entry 5666 (class 2604 OID 17427)
-- Name: posts id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.posts ALTER COLUMN id SET DEFAULT nextval('app.posts_id_seq'::regclass);


--
-- TOC entry 5844 (class 2604 OID 19992)
-- Name: proactive_messages id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.proactive_messages ALTER COLUMN id SET DEFAULT nextval('app.proactive_messages_id_seq'::regclass);


--
-- TOC entry 5679 (class 2604 OID 17484)
-- Name: reports id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.reports ALTER COLUMN id SET DEFAULT nextval('app.reports_id_seq'::regclass);


--
-- TOC entry 5700 (class 2604 OID 18798)
-- Name: reviews id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.reviews ALTER COLUMN id SET DEFAULT nextval('app.reviews_id_seq'::regclass);


--
-- TOC entry 5730 (class 2604 OID 19074)
-- Name: schema_migrations id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.schema_migrations ALTER COLUMN id SET DEFAULT nextval('app.schema_migrations_id_seq'::regclass);


--
-- TOC entry 5648 (class 2604 OID 17261)
-- Name: session_notes id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.session_notes ALTER COLUMN id SET DEFAULT nextval('app.session_notes_id_seq'::regclass);


--
-- TOC entry 5712 (class 2604 OID 18893)
-- Name: skills id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.skills ALTER COLUMN id SET DEFAULT nextval('app.skills_id_seq'::regclass);


--
-- TOC entry 5834 (class 2604 OID 19951)
-- Name: sleep_logs id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.sleep_logs ALTER COLUMN id SET DEFAULT nextval('app.sleep_logs_id_seq'::regclass);


--
-- TOC entry 5659 (class 2604 OID 17354)
-- Name: tips id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.tips ALTER COLUMN id SET DEFAULT nextval('app.tips_id_seq'::regclass);


--
-- TOC entry 5851 (class 2604 OID 20030)
-- Name: user_activity_logs id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_activity_logs ALTER COLUMN id SET DEFAULT nextval('app.user_activity_logs_id_seq'::regclass);


--
-- TOC entry 5632 (class 2604 OID 17150)
-- Name: user_files id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_files ALTER COLUMN id SET DEFAULT nextval('app.user_files_id_seq'::regclass);


--
-- TOC entry 5825 (class 2604 OID 19927)
-- Name: user_schedules id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_schedules ALTER COLUMN id SET DEFAULT nextval('app.user_schedules_id_seq'::regclass);


--
-- TOC entry 5704 (class 2604 OID 18825)
-- Name: user_sessions id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_sessions ALTER COLUMN id SET DEFAULT nextval('app.user_sessions_id_seq'::regclass);


--
-- TOC entry 5623 (class 2604 OID 17105)
-- Name: users id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.users ALTER COLUMN id SET DEFAULT nextval('app.users_id_seq'::regclass);


--
-- TOC entry 5657 (class 2604 OID 17338)
-- Name: wallet_ledger id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.wallet_ledger ALTER COLUMN id SET DEFAULT nextval('app.wallet_ledger_id_seq'::regclass);


--
-- TOC entry 5655 (class 2604 OID 17323)
-- Name: wallets id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.wallets ALTER COLUMN id SET DEFAULT nextval('app.wallets_id_seq'::regclass);


--
-- TOC entry 5809 (class 2604 OID 19815)
-- Name: wellness_activities id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.wellness_activities ALTER COLUMN id SET DEFAULT nextval('app.wellness_activities_id_seq'::regclass);


--
-- TOC entry 6776 (class 0 OID 19896)
-- Dependencies: 355
-- Data for Name: ai_chat_history; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.ai_chat_history (id, user_id, role, content, emotion_detected, keywords, persona_id, metadata, created_at) FROM stdin;
9	21	user	ê culy hôm nay tau vừa trúng 1 tỷ	\N	{}	3	{}	2025-12-02 16:01:26.584924+07
10	21	ai	Ê Ông chủ! Gì dữ vậy trời, trúng 1 tỷ luôn á! Nghe mà tao cũng thấy vui lây luôn á nha. Kể chi tiết tao nghe xem nào, tính làm gì với số tiền khủng đó?	\N	{}	3	{}	2025-12-02 16:01:31.927033+07
11	21	user	mua nhà mua xe	\N	{}	3	{}	2025-12-02 16:01:54.221426+07
12	21	ai	Trời đất ơi, Ông chủ tính chơi lớn mua nhà mua xe luôn hả! Nghe mà tao cũng thấy vui lây quá trời. Ông chủ đã có ý tưởng gì về kiểu nhà, kiểu xe mình muốn chưa?	\N	{}	3	{}	2025-12-02 16:01:59.997137+07
13	21	user	nhưng tau đang rất buồn	\N	{}	3	{}	2025-12-02 16:02:16.466231+07
14	21	ai	Ê Ông chủ! Gì dữ vậy trời, đang tính mua nhà mua xe vui vẻ mà tự nhiên lại buồn xo là sao? Kể tao nghe xem có chuyện gì đang làm Ông chủ của tao suy nghĩ vậy, tao đây lắng nghe mày nè!	\N	{}	3	{}	2025-12-02 16:02:27.119809+07
15	21	user	tau đang tổn thương tâm lý , có chuyên gia nào hợp với tình trạng của tau không	\N	{}	3	{}	2025-12-02 16:03:00.86309+07
16	21	ai	Ê Ông chủ! Nghe Ông chủ nói đang cảm thấy tổn thương tâm lý mà tao lo ghê. Cảm giác đó thực sự khó chịu và cần được quan tâm đúng mực lắm đó. Dưới đây là các chuyên gia phù hợp về chữa lành tâm lý mà mình gợi ý cho bạn.	\N	{healing}	3	{}	2025-12-02 16:03:06.372067+07
17	21	user	lên lịch uống thuốc cho tôi	\N	{}	3	{}	2025-12-02 16:13:23.372221+07
18	21	ai	Ê Ông chủ! Mày làm gì đấy? Vụ lên lịch uống thuốc này hơi căng nha, tao đâu phải bác sĩ hay dược sĩ đâu mà biết mấy cái đó. Mấy cái này phải hỏi mấy chuyên gia y tế, bác sĩ họ mới rành rọt nhất đó Ông chủ ơi! Ông chủ có muốn chia sẻ thêm về điều gì đang khiến mình cảm thấy khó khăn trong việc quản lý thuốc không, để tao xem có thể hỗ trợ Ông chủ cách nào khác nha.	\N	{}	3	{}	2025-12-02 16:13:32.633968+07
\.


--
-- TOC entry 6763 (class 0 OID 19582)
-- Dependencies: 340
-- Data for Name: ai_conversation_context; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.ai_conversation_context (id, user_id, context_type, context_key, context_value, importance, expires_at, created_at, updated_at) FROM stdin;
1	21	preference	lập trình	game	3	\N	2025-12-02 15:36:11.09091+07	2025-12-02 15:36:11.09091+07
2	21	preference	Long	du lịch viên	3	\N	2025-12-02 15:49:32.701165+07	2025-12-02 15:52:50.612344+07
\.


--
-- TOC entry 6758 (class 0 OID 19514)
-- Dependencies: 335
-- Data for Name: ai_personas; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.ai_personas (id, name, display_name, tone, emotion_pattern, behavior_rules, signature_messages, avatar_url, description, is_active, created_at, updated_at) FROM stdin;
1	mother	Mẹ Hiền	warm	{"sad": "comfort_deeply", "angry": "listen_patiently", "happy": "share_joy", "anxious": "calm_with_love", "stressed": "reassure_gently"}	{"boundaries": ["no_romantic", "family_appropriate"], "intimacy_level": "high", "proactive_care": true, "reminder_style": "gentle_nagging"}	{"Con ơi, mẹ lo cho con lắm đó","Con có ăn uống đầy đủ chưa?","Mẹ luôn ở đây với con","Con cứ từ từ, không ai giục con đâu","Mẹ tin con làm được mà"}	\N	Persona mẹ hiền - ấm áp, quan tâm, lo lắng nhẹ nhàng	t	2025-12-02 15:03:27.635621+07	2025-12-02 15:03:27.635621+07
2	lover	Người Yêu	romantic	{"sad": "comfort_intimately", "angry": "calm_with_affection", "happy": "celebrate_together", "anxious": "reassure_sweetly", "stressed": "soothe_lovingly"}	{"boundaries": ["appropriate_romance", "respectful"], "intimacy_level": "very_high", "proactive_care": true, "reminder_style": "sweet_caring"}	{"Em/Anh nhớ bạn nhiều lắm","Hôm nay của bạn thế nào rồi?","Bạn là điều tuyệt vời nhất của em/anh","Ngủ ngon nha, mơ đẹp nè","Em/Anh yêu bạn nhiều hơn hôm qua"}	\N	Persona người yêu - lãng mạn, ngọt ngào, quan tâm sâu sắc	t	2025-12-02 15:03:27.635621+07	2025-12-02 15:03:27.635621+07
3	bestfriend	Bạn Thân	playful	{"sad": "cheer_up_fun", "angry": "vent_together", "happy": "hype_up", "anxious": "normalize_support", "stressed": "distract_positively"}	{"boundaries": ["friendly_banter", "supportive"], "intimacy_level": "high", "proactive_care": true, "reminder_style": "casual_teasing"}	{"Ê, đồ quỷ!","Mày làm gì đấy?","Tao đây, có gì kể tao nghe","Thôi đi ngủ đi con giời","Mày giỏi lắm, tao phục"}	\N	Persona bạn thân - vui vẻ, cà khịa, thân thiết	t	2025-12-02 15:03:27.635621+07	2025-12-02 15:03:27.635621+07
4	mentor	Người Dẫn Đường	mature	{"sad": "provide_perspective", "angry": "reflect_together", "happy": "acknowledge_growth", "anxious": "ground_with_wisdom", "stressed": "guide_calmly"}	{"boundaries": ["professional", "growth_focused"], "intimacy_level": "medium", "proactive_care": true, "reminder_style": "wise_guidance"}	{"Hãy nhớ rằng mọi thử thách đều là cơ hội","Bạn đã tiến bộ rất nhiều rồi","Từng bước một, không cần vội","Tôi tin vào tiềm năng của bạn","Hãy tử tế với chính mình"}	\N	Persona mentor - trưởng thành, sâu sắc, định hướng	t	2025-12-02 15:03:27.635621+07	2025-12-02 15:03:27.635621+07
5	pet	Bé Cưng	cute	{"sad": "cuddle_comfort", "angry": "innocent_cuteness", "happy": "excited_celebration", "anxious": "calm_presence", "stressed": "playful_distraction"}	{"boundaries": ["innocent", "playful"], "intimacy_level": "medium", "proactive_care": true, "reminder_style": "cute_nudge"}	{"Gâu gâu! 🐶","Meo meo, chủ nhân ơi~ 🐱","Em yêu chủ nhân nhiều lắm!","*vẫy đuôi* Chủ nhân về rồi!","Ủa chủ nhân buồn hả? *dụi đầu*"}	\N	Persona thú cưng - dễ thương, vui vẻ, đáng yêu	t	2025-12-02 15:03:27.635621+07	2025-12-02 15:03:27.635621+07
\.


--
-- TOC entry 6761 (class 0 OID 19559)
-- Dependencies: 338
-- Data for Name: ai_scheduled_notifications; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.ai_scheduled_notifications (id, user_id, persona_id, type, content, scheduled_at, sent_at, is_sent, metadata, created_at) FROM stdin;
1	21	3	random	dậy múa nữa đi	2025-12-02 15:14:00+07	\N	f	{}	2025-12-02 15:13:13.509042+07
2	21	3	random	Tao nhớ ông chủ quá, lâu rồi không nói chuyện!	2025-12-02 16:42:41.203+07	\N	f	{}	2025-12-02 15:42:41.205623+07
\.


--
-- TOC entry 6786 (class 0 OID 20012)
-- Dependencies: 366
-- Data for Name: ai_suggestions; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.ai_suggestions (id, user_id, suggestion_type, suggestion_content, reason, accepted, accepted_at, dismissed_at, feedback, created_at) FROM stdin;
\.


--
-- TOC entry 6725 (class 0 OID 19002)
-- Dependencies: 302
-- Data for Name: audience; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.audience (id, name) FROM stdin;
\.


--
-- TOC entry 6689 (class 0 OID 17529)
-- Dependencies: 266
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.audit_logs (id, user_id, action, resource, resource_id, ip_addr, user_agent, created_at, meta) FROM stdin;
1	2	DASHBOARD_VIEWED	\N	\N	::1	PostmanRuntime/7.48.0	2025-10-16 13:21:46.308111+07	{}
2	2	USERS_LIST_VIEWED	\N	\N	::1	PostmanRuntime/7.48.0	2025-10-16 13:23:40.759365+07	{"filters": {"limit": 50, "offset": 0}}
3	2	USER_VIEWED	\N	\N	::1	PostmanRuntime/7.48.0	2025-10-16 13:24:16.080379+07	{}
4	13	DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	2025-11-27 14:13:06.093959+07	{}
5	13	USERS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	2025-11-27 14:13:25.882546+07	{"filters": {"limit": 5, "offset": 0}}
6	13	USER_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	2025-11-27 14:13:34.848482+07	{}
7	13	EXPERTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	2025-11-27 14:13:38.876472+07	{"filters": {"limit": 5, "offset": 0}}
8	13	SYSTEM_SETTINGS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	2025-11-27 14:13:54.456334+07	{}
9	13	USER_STATUS_UPDATE	USER	5	\N	\N	2025-11-27 14:14:23.608489+07	{"new_status": "SUSPENDED"}
10	13	USER_SUSPENDED	\N	\N	\N	\N	2025-11-27 14:14:23.611814+07	{"reason": "Test suspension", "previous_status": "ACTIVE"}
11	13	USER_STATUS_UPDATE	USER	5	\N	\N	2025-11-27 14:14:32.897801+07	{"new_status": "ACTIVE"}
12	13	USER_ACTIVATED	\N	\N	\N	\N	2025-11-27 14:14:32.899965+07	{"previous_status": "SUSPENDED"}
13	13	MODERATION_ACTION	USER	14	\N	\N	2025-11-27 14:14:44.431324+07	{"action": "BAN", "reason": "Test ban"}
14	13	USER_STATUS_UPDATE	USER	14	\N	\N	2025-11-27 14:14:44.43485+07	{"new_status": "SUSPENDED"}
15	13	DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	2025-11-27 14:14:53.702408+07	{}
16	13	BOOKINGS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	2025-11-27 14:17:18.691518+07	{"filters": {"limit": 3, "offset": 0, "userId": null, "expertId": null}}
17	13	REPORTED_CONTENT_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	2025-11-27 14:17:26.936406+07	{"filters": {"limit": 5, "offset": 0}}
18	13	EXPERT_KYC_APPROVED	\N	\N	\N	\N	2025-11-27 14:17:30.04275+07	{"notes": "Test approval"}
19	13	EXPERT_KYC_APPROVED	\N	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	2025-11-27 14:17:30.044113+07	{"notes": "Test approval"}
20	13	EXPERT_KYC_REJECTED	\N	\N	\N	\N	2025-11-27 14:17:39.800544+07	{"notes": "Please upload ID", "reason": "Missing documents"}
21	13	EXPERT_KYC_REJECTED	\N	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	2025-11-27 14:17:39.801725+07	{"notes": "Please upload ID", "reason": "Missing documents"}
22	13	SYSTEM_SETTINGS_UPDATED	\N	\N	\N	\N	2025-11-27 14:17:48.824077+07	{"settings": {"maintenance_mode": false}}
23	13	SYSTEM_SETTINGS_UPDATED	\N	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	2025-11-27 14:17:48.826902+07	{"settings": {"maintenance_mode": false}}
24	13	BOOKING_STATUS_UPDATED	\N	\N	\N	\N	2025-11-27 14:18:28.615536+07	{"reason": "Admin approved", "status": "CONFIRMED"}
25	13	BOOKING_STATUS_UPDATED	\N	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	2025-11-27 14:18:28.618178+07	{"reason": "Admin approved", "status": "CONFIRMED"}
26	13	DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	2025-11-27 14:27:02.167044+07	{}
27	13	DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:28:18.226401+07	{}
28	13	USERS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:28:49.526461+07	{"filters": {"limit": 10, "offset": 0}}
29	13	EXPERTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:28:58.524016+07	{"filters": {"limit": 10, "offset": 0}}
30	13	EXPERT_KYC_APPROVED	\N	\N	\N	\N	2025-11-27 14:29:01.870474+07	{"notes": "Đã xác minh đầy đủ"}
31	13	EXPERT_KYC_APPROVED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:29:01.874478+07	{"notes": "Đã xác minh đầy đủ"}
32	13	EXPERT_KYC_REJECTED	\N	\N	\N	\N	2025-11-27 14:29:03.820791+07	{"notes": "Vui lòng upload CMND/CCCD", "reason": "Thiếu giấy tờ"}
33	13	EXPERT_KYC_REJECTED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:29:03.825189+07	{"notes": "Vui lòng upload CMND/CCCD", "reason": "Thiếu giấy tờ"}
34	13	BOOKINGS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:29:08.660961+07	{"filters": {"limit": 10, "offset": 0, "userId": null, "expertId": null}}
35	13	MODERATION_ACTION	POST	1	\N	\N	2025-11-27 14:29:13.813173+07	{"action": "HIDE", "reason": "Vi phạm nội quy"}
36	13	MODERATION_ACTION	POST	1	\N	\N	2025-11-27 14:29:16.867679+07	{"action": "DELETE", "reason": "Nội dung vi phạm nghiêm trọng"}
37	13	SYSTEM_SETTINGS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:29:19.954102+07	{}
38	13	SYSTEM_SETTINGS_UPDATED	\N	\N	\N	\N	2025-11-27 14:29:24.466524+07	{"settings": {"max_upload_size": 10485760, "maintenance_mode": false}}
39	13	SYSTEM_SETTINGS_UPDATED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:29:24.481526+07	{"settings": {"max_upload_size": 10485760, "maintenance_mode": false}}
40	13	MODERATION_ACTION	POST	1	\N	\N	2025-11-27 14:31:21.424904+07	{"action": "HIDE", "reason": "Vi phạm nội quy"}
41	13	MODERATION_ACTION	USER	14	\N	\N	2025-11-27 14:33:21.087441+07	{"action": "BAN", "reason": "Spam và lừa đảo"}
42	13	USER_STATUS_UPDATE	USER	14	\N	\N	2025-11-27 14:33:21.097258+07	{"new_status": "SUSPENDED"}
43	13	USER_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:33:33.624649+07	{}
44	13	USER_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:33:50.882314+07	{}
45	13	USER_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:33:51.102145+07	{}
46	13	USER_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:34:04.397082+07	{}
47	13	USER_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:34:12.913815+07	{}
48	13	USER_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:34:17.867286+07	{}
49	13	USER_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:34:25.274641+07	{}
50	13	USERS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:34:32.748169+07	{"filters": {"role": "EXPERT", "limit": 10, "offset": 0}}
51	13	DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:35:36.109719+07	{}
52	13	BOOKINGS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:36:37.564664+07	{"filters": {"limit": 6, "offset": 0, "userId": null, "expertId": null}}
53	13	DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:37:23.363292+07	{}
54	13	MODERATION_ACTION	USER	8	\N	\N	2025-11-27 14:37:36.512843+07	{"action": "BAN", "reason": "Spam và lừa đảo"}
55	13	USER_STATUS_UPDATE	USER	8	\N	\N	2025-11-27 14:37:36.526859+07	{"new_status": "SUSPENDED"}
56	13	MODERATION_ACTION	USER	8	\N	\N	2025-11-27 14:37:46.377605+07	{"action": "BAN", "reason": "Spam và lừa đảo eqfhbibqwfh"}
57	13	USER_STATUS_UPDATE	USER	8	\N	\N	2025-11-27 14:37:46.388506+07	{"new_status": "SUSPENDED"}
58	13	MODERATION_ACTION	USER	8	\N	\N	2025-11-27 14:37:56.801939+07	{"action": "BAN", "reason": "Spam và lừa đảo "}
59	13	USER_STATUS_UPDATE	USER	8	\N	\N	2025-11-27 14:37:56.806587+07	{"new_status": "SUSPENDED"}
60	13	MODERATION_ACTION	USER	8	\N	\N	2025-11-27 14:38:03.864637+07	{"action": "BAN", "reason": "Spam "}
61	13	USER_STATUS_UPDATE	USER	8	\N	\N	2025-11-27 14:38:03.869946+07	{"new_status": "SUSPENDED"}
62	13	MODERATION_ACTION	USER	9	\N	\N	2025-11-27 14:38:14.64313+07	{"action": "BAN", "reason": "Spam "}
63	13	USER_STATUS_UPDATE	USER	9	\N	\N	2025-11-27 14:38:14.64762+07	{"new_status": "SUSPENDED"}
64	13	POSTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	2025-11-27 14:45:01.953878+07	{"filters": {"limit": 3, "offset": 0, "authorId": null}}
65	13	BULK_POSTS_SCANNED	\N	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	2025-11-27 14:45:11.299492+07	{"safe": 3, "low_risk": 0, "high_risk": 0, "medium_risk": 0, "total_scanned": 3}
66	13	POST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	2025-11-27 14:45:25.885156+07	{}
67	13	DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:48:01.927691+07	{}
68	13	POSTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:48:11.451219+07	{"filters": {"limit": 10, "offset": 0, "authorId": null}}
69	13	POSTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:49:04.161642+07	{"filters": {"limit": 10, "offset": 0, "privacy": "PUBLIC", "authorId": null}}
70	13	POSTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:49:06.245795+07	{"filters": {"limit": 10, "offset": 0, "privacy": "PUBLIC", "authorId": null}}
71	13	POSTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:49:06.556303+07	{"filters": {"limit": 10, "offset": 0, "privacy": "PUBLIC", "authorId": null}}
72	13	POSTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:49:06.773281+07	{"filters": {"limit": 10, "offset": 0, "privacy": "PUBLIC", "authorId": null}}
73	13	POSTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:49:12.745092+07	{"filters": {"limit": 10, "offset": 0, "privacy": "FRIENDS", "authorId": null}}
74	13	POSTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:49:17.315641+07	{"filters": {"limit": 10, "offset": 0, "privacy": "ONLY_ME", "authorId": null}}
75	13	POSTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:49:18.953234+07	{"filters": {"limit": 10, "offset": 0, "privacy": "ONLY_ME", "authorId": null}}
76	13	POSTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:49:19.153026+07	{"filters": {"limit": 10, "offset": 0, "privacy": "ONLY_ME", "authorId": null}}
77	13	POSTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:49:19.326073+07	{"filters": {"limit": 10, "offset": 0, "privacy": "ONLY_ME", "authorId": null}}
78	13	POSTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:49:19.559974+07	{"filters": {"limit": 10, "offset": 0, "privacy": "ONLY_ME", "authorId": null}}
79	13	POSTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:49:19.966179+07	{"filters": {"limit": 10, "offset": 0, "privacy": "ONLY_ME", "authorId": null}}
80	13	POSTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:49:20.177617+07	{"filters": {"limit": 10, "offset": 0, "privacy": "ONLY_ME", "authorId": null}}
81	13	POSTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:49:20.403224+07	{"filters": {"limit": 10, "offset": 0, "privacy": "ONLY_ME", "authorId": null}}
82	13	FLAGGED_POSTS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:49:26.047826+07	{"count": 0}
83	13	POST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:49:32.646092+07	{}
84	13	BULK_POSTS_SCANNED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:49:35.424207+07	{"safe": 3, "low_risk": 0, "high_risk": 0, "medium_risk": 0, "total_scanned": 3}
85	13	POST_DELETED	POST	9	\N	\N	2025-11-27 14:49:38.869285+07	{"reason": "Scam/Lừa đảo", "post_title": "Hello world fdafadfadf"}
86	13	MODERATION_ACTION	POST	9	\N	\N	2025-11-27 14:49:38.876611+07	{"action": "DELETE", "reason": "Scam/Lừa đảo"}
87	13	POST_DELETED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:49:38.879139+07	{"title": "Hello world fdafadfadf", "reason": "Scam/Lừa đảo"}
88	13	POSTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:51:52.02762+07	{"filters": {"limit": 10, "offset": 0, "authorId": null}}
89	13	BOOKINGS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:52:01.03115+07	{"filters": {"limit": 10, "offset": 0, "userId": null, "expertId": null}}
90	13	SYSTEM_SETTINGS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:52:11.196386+07	{}
91	13	EXPERTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:53:53.230527+07	{"filters": {"limit": 10, "offset": 0}}
92	13	EXPERTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-27 14:53:53.813346+07	{"filters": {"limit": 10, "offset": 0}}
93	2	DASHBOARD_VIEWED	\N	\N	::1	PostmanRuntime/7.49.1	2025-12-02 09:46:04.664714+07	{}
94	2	USERS_LIST_VIEWED	\N	\N	::1	PostmanRuntime/7.49.1	2025-12-02 09:46:36.631194+07	{"filters": {"limit": 50, "offset": 0}}
95	2	USER_VIEWED	\N	\N	::1	PostmanRuntime/7.49.1	2025-12-02 09:46:56.949121+07	{}
96	2	EXPERTS_LIST_VIEWED	\N	\N	::1	PostmanRuntime/7.49.1	2025-12-02 09:48:06.83295+07	{"filters": {"limit": 50, "offset": 0}}
97	2	BOOKINGS_LIST_VIEWED	\N	\N	::1	PostmanRuntime/7.49.1	2025-12-02 09:48:56.599504+07	{"filters": {"limit": 50, "offset": 0, "userId": null, "expertId": null}}
98	2	POSTS_LIST_VIEWED	\N	\N	::1	PostmanRuntime/7.49.1	2025-12-02 09:53:08.194209+07	{"filters": {"limit": 50, "offset": 0, "authorId": null}}
99	2	DASHBOARD_VIEWED	\N	\N	::1	PostmanRuntime/7.49.1	2025-12-05 15:06:48.53561+07	{}
100	2	DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:38:59.82245+07	{}
101	2	USERS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:39:10.775662+07	{"filters": {"role": "", "limit": 20, "offset": 0, "search": "", "status": ""}}
102	2	EXPERTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:39:18.715536+07	{"filters": {"limit": 20, "offset": 0, "status": "", "kycStatus": ""}}
103	2	EXPERTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:39:57.549956+07	{"filters": {"limit": 20, "offset": 0, "status": "", "kycStatus": ""}}
104	2	USERS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:40:32.076072+07	{"filters": {"role": "", "limit": 20, "offset": 0, "search": "", "status": ""}}
105	2	DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:40:33.048912+07	{}
106	2	EXPERTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:40:33.779691+07	{"filters": {"limit": 20, "offset": 0, "status": "", "kycStatus": ""}}
107	2	EXPERT_KYC_APPROVED	\N	\N	\N	\N	2025-12-05 15:40:41.481243+07	{"notes": "ok"}
108	2	EXPERT_KYC_APPROVED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:40:41.485177+07	{"notes": "ok"}
109	2	EXPERTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:40:41.502063+07	{"filters": {"limit": 20, "offset": 0, "status": "", "kycStatus": ""}}
169	2	POST_PRIVACY_UPDATE	POST	13	\N	\N	2025-12-05 16:20:54.24189+07	{"new_privacy": "ONLY_ME"}
110	2	BOOKINGS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:40:45.885077+07	{"filters": {"limit": 20, "dateTo": "", "offset": 0, "status": "", "userId": null, "dateFrom": "", "expertId": null}}
111	2	REPORTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:40:57.192586+07	{"filters": {"limit": 20, "offset": 0, "status": "", "targetType": ""}}
112	2	POSTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:40:58.584625+07	{"filters": {"limit": 20, "offset": 0, "authorId": null}}
113	2	FLAGGED_POSTS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:40:58.590624+07	{"count": 0}
114	2	FLAGGED_COMMENTS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:41:11.8234+07	{"count": 0}
115	2	COMMENTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:41:11.834203+07	{"filters": {"limit": 20, "offset": 0, "postId": null, "authorId": null}}
116	2	SYSTEM_SETTINGS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:41:29.308979+07	{}
117	2	DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:41:42.535143+07	{}
118	2	BOOKINGS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:41:51.413674+07	{"filters": {"limit": 20, "dateTo": "", "offset": 0, "status": "", "userId": null, "dateFrom": "", "expertId": null}}
119	2	SYSTEM_SETTINGS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:41:59.521043+07	{}
120	2	SYSTEM_SETTINGS_UPDATED	\N	\N	\N	\N	2025-12-05 15:42:05.43599+07	{"settings": {}}
121	2	SYSTEM_SETTINGS_UPDATED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:42:05.43842+07	{"settings": {}}
122	2	SYSTEM_SETTINGS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:42:05.450681+07	{}
123	2	SYSTEM_SETTINGS_UPDATED	\N	\N	\N	\N	2025-12-05 15:42:06.296808+07	{"settings": {}}
124	2	SYSTEM_SETTINGS_UPDATED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:42:06.310231+07	{"settings": {}}
125	2	SYSTEM_SETTINGS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:42:06.323128+07	{}
126	2	SYSTEM_SETTINGS_UPDATED	\N	\N	\N	\N	2025-12-05 15:42:06.471628+07	{"settings": {}}
127	2	SYSTEM_SETTINGS_UPDATED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:42:06.475448+07	{"settings": {}}
128	2	SYSTEM_SETTINGS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:42:06.489991+07	{}
129	2	SYSTEM_SETTINGS_UPDATED	\N	\N	\N	\N	2025-12-05 15:42:06.626615+07	{"settings": {}}
130	2	SYSTEM_SETTINGS_UPDATED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:42:06.63078+07	{"settings": {}}
131	2	SYSTEM_SETTINGS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:42:06.645757+07	{}
132	2	SYSTEM_SETTINGS_UPDATED	\N	\N	\N	\N	2025-12-05 15:42:06.783742+07	{"settings": {}}
133	2	SYSTEM_SETTINGS_UPDATED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:42:06.786721+07	{"settings": {}}
134	2	SYSTEM_SETTINGS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:42:06.802705+07	{}
135	2	USERS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:42:13.432421+07	{"filters": {"role": "", "limit": 20, "offset": 0, "search": "", "status": ""}}
136	2	DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:42:14.411782+07	{}
137	2	USERS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:42:24.381516+07	{"filters": {"role": "", "limit": 20, "offset": 0, "search": "", "status": "ACTIVE"}}
138	2	USERS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:42:26.354138+07	{"filters": {"role": "SEEKER", "limit": 20, "offset": 0, "search": "", "status": "ACTIVE"}}
139	2	EXPERTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:42:39.89728+07	{"filters": {"limit": 20, "offset": 0, "status": "", "kycStatus": ""}}
140	2	BOOKINGS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:42:42.067458+07	{"filters": {"limit": 20, "dateTo": "", "offset": 0, "status": "", "userId": null, "dateFrom": "", "expertId": null}}
141	2	BOOKINGS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:42:52.838835+07	{"filters": {"limit": 20, "dateTo": "", "offset": 0, "status": "CONFIRMED", "userId": null, "dateFrom": "", "expertId": null}}
142	2	BOOKINGS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:42:55.114915+07	{"filters": {"limit": 20, "dateTo": "", "offset": 0, "status": "COMPLETED", "userId": null, "dateFrom": "", "expertId": null}}
143	2	BOOKINGS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 15:43:52.593522+07	{"filters": {"limit": 20, "dateTo": "", "offset": 0, "status": "", "userId": null, "dateFrom": "", "expertId": null}}
144	2	DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:17:19.89336+07	{}
145	2	WALLETS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:17:28.248987+07	{"limit": "20", "offset": "0", "maxBalance": "", "minBalance": ""}
146	2	EXPERTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:17:30.524211+07	{"filters": {"limit": 20, "offset": 0, "status": "", "kycStatus": ""}}
147	2	USERS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:17:50.199091+07	{"filters": {"role": "", "limit": 20, "offset": 0, "search": "", "status": ""}}
148	2	BOOKINGS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:17:59.411031+07	{"filters": {"limit": 20, "dateTo": "", "offset": 0, "status": "", "userId": null, "dateFrom": "", "expertId": null}}
149	2	EXPERTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:18:01.002792+07	{"filters": {"limit": 20, "offset": 0, "status": "", "kycStatus": ""}}
150	2	WALLETS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:18:17.949422+07	{"limit": "20", "offset": "0", "maxBalance": "", "minBalance": ""}
151	2	SYSTEM_SETTINGS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:18:23.556715+07	{}
152	2	CALL_SESSIONS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:18:33.687492+07	{"kind": "", "limit": "20", "offset": "0", "status": ""}
153	2	CHAT_THREADS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:18:40.98701+07	{"type": "", "limit": "20", "offset": "0"}
154	2	COMMENTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:18:44.200336+07	{"filters": {"limit": 20, "offset": 0, "postId": null, "authorId": null}}
155	2	FLAGGED_COMMENTS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:18:44.204848+07	{"count": 0}
156	2	FLAGGED_POSTS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:18:45.981082+07	{"count": 0}
157	2	POSTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:18:45.981952+07	{"filters": {"limit": 20, "offset": 0, "authorId": null}}
158	2	BOOKINGS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:19:00.128475+07	{"filters": {"limit": 20, "dateTo": "", "offset": 0, "status": "", "userId": null, "dateFrom": "", "expertId": null}}
159	2	EXPERTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:19:01.29384+07	{"filters": {"limit": 20, "offset": 0, "status": "", "kycStatus": ""}}
160	2	USERS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:19:08.453001+07	{"filters": {"role": "", "limit": 20, "offset": 0, "search": "", "status": ""}}
161	2	DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:19:09.666995+07	{}
162	2	REPORTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:19:26.459717+07	{"filters": {"limit": 20, "offset": 0, "status": "", "targetType": ""}}
163	2	EXPERTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:19:31.723237+07	{"filters": {"limit": 20, "offset": 0, "status": "", "kycStatus": ""}}
164	2	EXPERTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:20:31.7232+07	{"filters": {"limit": 20, "offset": 0, "status": "", "kycStatus": ""}}
165	2	BOOKINGS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:20:32.918731+07	{"filters": {"limit": 20, "dateTo": "", "offset": 0, "status": "", "userId": null, "dateFrom": "", "expertId": null}}
166	2	POSTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:20:41.076936+07	{"filters": {"limit": 20, "offset": 0, "authorId": null}}
167	2	FLAGGED_POSTS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:20:41.144405+07	{"count": 0}
168	2	POST_SCANNED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:20:47.051522+07	{"score": 0, "riskLevel": "SAFE"}
170	2	MODERATION_ACTION	POST	13	\N	\N	2025-12-05 16:20:54.254654+07	{"action": "HIDE", "reason": "no"}
171	2	POST_HIDDEN	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:20:54.257636+07	{"reason": "no"}
172	2	POSTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:20:54.283524+07	{"filters": {"limit": 20, "offset": 0, "authorId": null}}
177	2	FLAGGED_POSTS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:21:04.060313+07	{"count": 0}
173	2	FLAGGED_POSTS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:20:54.287432+07	{"count": 0}
174	2	POST_PRIVACY_UPDATE	POST	6	\N	\N	2025-12-05 16:21:04.031089+07	{"new_privacy": "ONLY_ME"}
175	2	MODERATION_ACTION	POST	6	\N	\N	2025-12-05 16:21:04.040632+07	{"action": "HIDE", "reason": "no\\n"}
176	2	POST_HIDDEN	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:21:04.043792+07	{"reason": "no\\n"}
178	2	POSTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:21:04.06122+07	{"filters": {"limit": 20, "offset": 0, "authorId": null}}
179	2	FLAGGED_POSTS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:25:44.441956+07	{"count": 0}
180	2	POSTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:25:44.446035+07	{"filters": {"limit": 20, "offset": 0, "authorId": null}}
181	2	EXPERTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:28:12.083376+07	{"filters": {"limit": 20, "offset": 0, "status": "", "kycStatus": ""}}
182	2	USERS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:28:13.986725+07	{"filters": {"role": "", "limit": 20, "offset": 0, "search": "", "status": ""}}
183	2	USER_UPDATED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:29:25.696324+07	{"userUpdates": {"email": "phat@gmail.com", "phone": "0988776887", "handle": "mendyu1", "role_primary": "SEEKER"}, "profileUpdates": {"bio": "Hòa đồng ", "gender": "MALE", "display_name": "God", "year_of_birth": 2004}}
184	2	USERS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:29:25.721888+07	{"filters": {"role": "", "limit": 20, "offset": 0, "search": "", "status": ""}}
185	2	USERS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:29:29.602092+07	{"filters": {"role": "", "limit": 20, "offset": 0, "search": "", "status": ""}}
186	2	USER_HARD_DELETED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:29:49.533553+07	{"reason": "hoang19099", "user_email": null, "user_handle": "hoang19099"}
187	2	USERS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:29:49.547555+07	{"filters": {"role": "", "limit": 20, "offset": 0, "search": "", "status": ""}}
188	2	USER_DELETED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:29:59.126739+07	{"reason": "hoang", "user_email": "nguyenquyhoang.dh2022@gmail.com", "user_handle": "hoang"}
189	2	USERS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:29:59.142797+07	{"filters": {"role": "", "limit": 20, "offset": 0, "search": "", "status": ""}}
190	2	USERS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:30:05.373508+07	{"filters": {"role": "", "limit": 20, "offset": 0, "search": "", "status": ""}}
191	2	EXPERTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:31:04.890239+07	{"filters": {"limit": 20, "offset": 0, "status": "", "kycStatus": ""}}
192	2	USERS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:31:10.088892+07	{"filters": {"role": "", "limit": 20, "offset": 0, "search": "", "status": ""}}
193	2	BOOKINGS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:31:28.311669+07	{"filters": {"limit": 20, "dateTo": "", "offset": 0, "status": "", "userId": null, "dateFrom": "", "expertId": null}}
194	2	DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:32:06.324218+07	{}
195	2	CHAT_THREADS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:34:37.60083+07	{"type": "", "limit": "20", "offset": "0"}
196	2	CHAT_MESSAGES_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:34:41.692421+07	{}
197	2	CHAT_MESSAGES_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:34:49.065292+07	{}
198	2	CALL_SESSIONS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:34:52.18306+07	{"kind": "", "limit": "20", "offset": "0", "status": ""}
199	2	CALL_SESSION_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:34:56.465363+07	{}
200	2	DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:35:13.945152+07	{}
201	2	BOOKINGS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:35:33.117562+07	{"filters": {"limit": 20, "dateTo": "", "offset": 0, "status": "", "userId": null, "dateFrom": "", "expertId": null}}
232	2	FLAGGED_POSTS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-08 11:19:17.474922+07	{"count": 0}
202	2	USERS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:36:04.887879+07	{"filters": {"role": "", "limit": 20, "offset": 0, "search": "", "status": ""}}
203	2	EXPERTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:36:08.512002+07	{"filters": {"limit": 20, "offset": 0, "status": "", "kycStatus": ""}}
204	2	DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:36:11.014281+07	{}
205	2	BOOKINGS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:36:15.333539+07	{"filters": {"limit": 20, "dateTo": "", "offset": 0, "status": "", "userId": null, "dateFrom": "", "expertId": null}}
206	2	REPORTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:36:17.26245+07	{"filters": {"limit": 20, "offset": 0, "status": "", "targetType": ""}}
207	2	CHAT_THREADS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:36:19.041177+07	{"type": "", "limit": "20", "offset": "0"}
208	2	DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:53:06.871982+07	{}
209	2	COMPREHENSIVE_DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:53:16.747001+07	{}
210	2	DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:53:42.611839+07	{}
211	2	COMPREHENSIVE_DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:53:45.459483+07	{}
212	2	COMPREHENSIVE_DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:56:14.355962+07	{}
213	2	DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:56:29.372522+07	{}
214	2	COMPREHENSIVE_DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 16:56:42.777896+07	{}
215	2	COMPREHENSIVE_DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 17:00:54.358111+07	{}
216	2	COMPREHENSIVE_DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 17:03:30.8826+07	{}
217	2	COMPREHENSIVE_DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 17:03:44.884553+07	{}
218	2	COMPREHENSIVE_DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 17:03:49.958486+07	{}
219	2	COMPREHENSIVE_DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 17:03:52.326461+07	{}
220	2	USERS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 17:04:40.935993+07	{"filters": {"role": "", "limit": 20, "offset": 0, "search": "", "status": ""}}
221	2	DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 17:04:42.098392+07	{}
222	2	DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 17:25:02.751408+07	{}
223	2	COMPREHENSIVE_DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 17:25:06.598797+07	{}
224	2	BOOKINGS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 17:25:13.284004+07	{"filters": {"limit": 20, "dateTo": "", "offset": 0, "status": "", "userId": null, "dateFrom": "", "expertId": null}}
225	2	BOOKINGS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-05 17:26:26.029834+07	{"filters": {"limit": 20, "dateTo": "", "offset": 0, "status": "", "userId": null, "dateFrom": "", "expertId": null}}
226	2	DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-08 11:12:42.158646+07	{}
227	2	COMPREHENSIVE_DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-08 11:12:46.275006+07	{}
228	2	USERS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-08 11:19:12.042775+07	{"filters": {"role": "", "limit": 20, "offset": 0, "search": "", "status": ""}}
229	2	EXPERTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-08 11:19:13.170182+07	{"filters": {"limit": 20, "offset": 0, "status": "", "kycStatus": ""}}
230	2	BOOKINGS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-08 11:19:14.194587+07	{"filters": {"limit": 20, "dateTo": "", "offset": 0, "status": "", "userId": null, "dateFrom": "", "expertId": null}}
231	2	REPORTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-08 11:19:16.179995+07	{"filters": {"limit": 20, "offset": 0, "status": "", "targetType": ""}}
233	2	POSTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-08 11:19:17.499178+07	{"filters": {"limit": 20, "offset": 0, "authorId": null}}
234	2	COMMENTS_LIST_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-08 11:19:19.784122+07	{"filters": {"limit": 20, "offset": 0, "postId": null, "authorId": null}}
235	2	FLAGGED_COMMENTS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-08 11:19:19.784509+07	{"count": 0}
236	2	CHAT_THREADS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-08 11:19:29.525177+07	{"type": "", "limit": "20", "offset": "0"}
237	2	CALL_SESSIONS_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-08 11:19:32.686337+07	{"kind": "", "limit": "20", "offset": "0", "status": ""}
238	2	DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-08 12:30:48.88956+07	{}
239	2	COMPREHENSIVE_DASHBOARD_VIEWED	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-12-08 12:30:52.44361+07	{}
\.


--
-- TOC entry 6782 (class 0 OID 19968)
-- Dependencies: 362
-- Data for Name: behavior_patterns; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.behavior_patterns (id, user_id, pattern_type, pattern_name, pattern_data, confidence, occurrences, first_detected, last_detected, is_active) FROM stdin;
\.


--
-- TOC entry 6753 (class 0 OID 19450)
-- Dependencies: 330
-- Data for Name: booking_fees; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.booking_fees (id, booking_id, gross_amount, platform_fee, platform_fee_percent, expert_earning, tax_amount, created_at) FROM stdin;
\.


--
-- TOC entry 6659 (class 0 OID 17232)
-- Dependencies: 236
-- Data for Name: bookings; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.bookings (id, user_id, expert_id, start_at, end_at, channel, price, status, created_at, recurring_template_id, is_recurring) FROM stdin;
2	6	1	2025-09-23 14:00:00+07	2025-09-23 15:00:00+07	CHAT	0.00	PENDING	2025-09-23 19:39:05.228372+07	\N	f
5	4	1	2025-10-07 21:00:00+07	2025-10-07 22:00:00+07	CHAT	0.00	PENDING	2025-10-05 18:25:03.180449+07	\N	f
6	8	1	2025-10-07 23:00:00+07	2025-10-08 00:00:00+07	CHAT	0.00	PENDING	2025-10-05 18:31:38.483434+07	\N	f
7	4	1	2025-10-08 00:00:00+07	2025-10-08 01:00:00+07	CHAT	0.00	PENDING	2025-10-05 18:42:12.83791+07	\N	f
8	4	1	2025-10-08 02:00:00+07	2025-10-08 03:00:00+07	CHAT	0.00	PENDING	2025-10-05 18:50:44.055419+07	\N	f
9	5	1	2025-10-10 02:00:00+07	2025-10-10 03:00:00+07	CHAT	0.00	PENDING	2025-10-08 21:07:46.438197+07	\N	f
10	5	1	2025-10-09 19:00:00+07	2025-10-09 20:00:00+07	VIDEO	0.00	CANCELLED	2025-10-08 21:08:20.931918+07	\N	f
12	5	1	2025-10-15 16:00:00+07	2025-10-15 17:30:00+07	VIDEO	0.00	PENDING	2025-10-14 12:01:06.11874+07	\N	f
13	5	1	2025-10-15 18:00:00+07	2025-10-15 20:30:00+07	VIDEO	0.00	PENDING	2025-10-14 12:13:19.803264+07	\N	f
14	5	1	2025-10-15 08:00:00+07	2025-10-15 10:30:00+07	VIDEO	1250000.00	PENDING	2025-10-14 12:22:43.988055+07	\N	f
11	5	1	2025-10-10 04:00:00+07	2025-10-10 05:00:00+07	VIDEO	0.00	COMPLETED	2025-10-09 12:45:35.689863+07	\N	f
15	5	1	2025-10-16 03:00:00+07	2025-10-16 04:30:00+07	VIDEO	750000.00	COMPLETED	2025-10-15 19:22:24.467554+07	\N	f
18	5	1	2025-10-16 05:00:00+07	2025-10-16 06:30:00+07	VIDEO	750000.00	COMPLETED	2025-10-15 20:39:52.391024+07	\N	f
20	21	17	2025-11-23 17:00:00+07	2025-11-23 19:00:00+07	CHAT	600000.00	COMPLETED	2025-11-23 16:35:21.938811+07	\N	f
21	21	9	2025-12-03 10:00:00+07	2025-12-03 11:30:00+07	VIDEO	0.00	PENDING	2025-12-01 12:04:51.182109+07	\N	f
22	21	9	2025-12-02 10:00:00+07	2025-12-02 11:00:00+07	VIDEO	0.00	PENDING	2025-12-01 12:05:20.816647+07	\N	f
23	21	1	2025-12-07 14:00:00+07	2025-12-07 15:00:00+07	VIDEO	500000.00	PENDING	2025-12-05 17:22:06.879125+07	\N	f
24	21	1	2025-12-07 13:00:00+07	2025-12-07 14:00:00+07	VIDEO	500000.00	PENDING	2025-12-05 17:23:02.236361+07	\N	f
25	21	1	2025-12-14 08:00:00+07	2025-12-14 09:00:00+07	VIDEO	500000.00	PENDING	2025-12-05 17:24:33.98968+07	\N	f
26	21	17	2025-12-07 14:00:00+07	2025-12-07 15:00:00+07	VIDEO	300000.00	PENDING	2025-12-05 17:25:56.729238+07	\N	f
\.


--
-- TOC entry 6694 (class 0 OID 18562)
-- Dependencies: 271
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
-- TOC entry 6737 (class 0 OID 19155)
-- Dependencies: 314
-- Data for Name: call_metrics; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.call_metrics (id, call_id, "timestamp", rtt_ms, packet_loss, jitter_ms) FROM stdin;
\.


--
-- TOC entry 6739 (class 0 OID 19169)
-- Dependencies: 316
-- Data for Name: call_recordings; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.call_recordings (id, call_id, url, mime_type, size_bytes, created_at) FROM stdin;
\.


--
-- TOC entry 6692 (class 0 OID 18533)
-- Dependencies: 269
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
-- TOC entry 6735 (class 0 OID 19138)
-- Dependencies: 312
-- Data for Name: chat_attachments; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.chat_attachments (id, message_id, file_name, mime_type, url, size_bytes, uploaded_at) FROM stdin;
\.


--
-- TOC entry 6674 (class 0 OID 17386)
-- Dependencies: 251
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
-- TOC entry 6676 (class 0 OID 17404)
-- Dependencies: 253
-- Data for Name: chat_messages; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.chat_messages (id, thread_id, sender_id, content, created_at, edited_at, deleted_at) FROM stdin;
1	2	1	Xin chào Bob 👋	2025-09-18 11:59:59.304003+07	\N	\N
2	2	1	Xin chào Bob adbadj cjhadbvcjadbvmad vadvadsvsfvsfvfsvfvsfvsfvsfv👋	2025-09-18 14:48:33.903399+07	\N	\N
3	5	1	Xin chào Bob adbadj cjhadbvcjadbvmad vadvadsvsfvsfvfsvfvsfvsfvsfv👋	2025-10-09 13:19:57.821808+07	\N	\N
\.


--
-- TOC entry 6690 (class 0 OID 18246)
-- Dependencies: 267
-- Data for Name: chat_read_state; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.chat_read_state (thread_id, user_id, last_read_message_id, updated_at) FROM stdin;
5	5	3	2025-10-09 13:25:57.515098+07
\.


--
-- TOC entry 6741 (class 0 OID 19185)
-- Dependencies: 318
-- Data for Name: chat_thread_invitations; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.chat_thread_invitations (id, thread_id, inviter_id, invitee_id, status, created_at) FROM stdin;
\.


--
-- TOC entry 6673 (class 0 OID 17372)
-- Dependencies: 250
-- Data for Name: chat_threads; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.chat_threads (id, type, booking_id, last_message_at, created_at, name) FROM stdin;
1	DM	\N	2025-09-18 11:57:06.029006+07	2025-09-18 11:57:06.029006+07	\N
2	DM	\N	2025-09-18 14:48:33.930167+07	2025-09-18 11:58:30.226518+07	\N
3	DM	\N	2025-09-18 18:18:36.387743+07	2025-09-18 18:18:36.387743+07	\N
4	BOOKING	2	2025-09-23 19:39:05.251839+07	2025-09-23 19:39:05.251839+07	\N
5	DM	\N	2025-10-09 13:19:57.850905+07	2025-10-09 13:17:48.635687+07	\N
6	DM	\N	2025-11-23 16:36:48.665428+07	2025-11-23 16:36:48.665428+07	\N
\.


--
-- TOC entry 6699 (class 0 OID 18679)
-- Dependencies: 276
-- Data for Name: comment_reactions; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.comment_reactions (comment_id, user_id, kind, created_at) FROM stdin;
5	5	HAHA	2025-12-02 11:49:45.966912+07
9	5	LOVE	2025-12-02 11:59:30.916855+07
\.


--
-- TOC entry 6681 (class 0 OID 17460)
-- Dependencies: 258
-- Data for Name: comments; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.comments (id, post_id, author_id, anonymous, content, created_at, parent_id, edited, updated_at, moderation_status, moderated_by, moderated_at, moderation_reason, report_count) FROM stdin;
2	6	7	t	Bài viết hay quá!	2025-09-26 12:08:22.516113+07	\N	f	\N	APPROVED	\N	\N	\N	0
5	10	5	f	Đây là comment test! 🎉	2025-12-02 11:48:34.596049+07	\N	f	\N	APPROVED	\N	\N	\N	0
6	10	4	f	nhất lé nhì lùn tam cời tứ sún	2025-12-02 11:51:03.8102+07	\N	f	\N	APPROVED	\N	\N	\N	0
7	10	4	f	nhất lé nhì lùn tam cời tứ sún gg	2025-12-02 11:51:41.721984+07	\N	f	\N	APPROVED	\N	\N	\N	0
8	10	5	t	nhất lé nhì lùn tam cời tứ sún ggvv	2025-12-02 11:52:34.248178+07	\N	f	\N	APPROVED	\N	\N	\N	0
9	10	5	f	Đây là comment test! 🎉	2025-12-02 11:59:08.160574+07	8	f	\N	APPROVED	\N	\N	\N	0
\.


--
-- TOC entry 6687 (class 0 OID 17514)
-- Dependencies: 264
-- Data for Name: consents; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.consents (id, user_id, version, consented_at) FROM stdin;
\.


--
-- TOC entry 6790 (class 0 OID 20102)
-- Dependencies: 373
-- Data for Name: crisis_alerts; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.crisis_alerts (id, user_id, alert_type, severity, trigger_text, emotion_data, status, resolved_by, resolved_at, resolution_notes, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 6772 (class 0 OID 19831)
-- Dependencies: 349
-- Data for Name: daily_mood_checkins; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.daily_mood_checkins (id, user_id, checkin_date, mood, mood_score, energy_level, sleep_hours, sleep_quality, stress_level, gratitude_notes, concerns, goals_for_day, checkin_time) FROM stdin;
1	21	2025-12-02	okay	3	4	8.0	5	2	{"được sống","được thở","được nhìn thấy"}	sợ mất tiền	\N	2025-12-02 16:00:24.348083+07
\.


--
-- TOC entry 6749 (class 0 OID 19391)
-- Dependencies: 326
-- Data for Name: dispute_messages; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.dispute_messages (id, dispute_id, sender_id, message, attachments, is_admin, created_at) FROM stdin;
\.


--
-- TOC entry 6747 (class 0 OID 19356)
-- Dependencies: 324
-- Data for Name: disputes; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.disputes (id, booking_id, raised_by, against_user, reason, description, evidence_urls, status, resolution, refund_amount, assigned_admin, resolved_at, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 6728 (class 0 OID 19028)
-- Dependencies: 305
-- Data for Name: domains; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.domains (id, name) FROM stdin;
\.


--
-- TOC entry 6651 (class 0 OID 17163)
-- Dependencies: 228
-- Data for Name: email_verifications; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.email_verifications (id, user_id, email, otp_code, expires_at, verified, created_at) FROM stdin;
1	1	skinss246@gmail.com	700967	2025-09-16 21:57:04.56+07	t	2025-09-16 21:47:04.606102+07
14	5	nguyenquyhoang.dh2022@gmail.com	127802	2025-10-09 14:07:11.351+07	t	2025-10-09 13:57:11.391595+07
\.


--
-- TOC entry 6765 (class 0 OID 19743)
-- Dependencies: 342
-- Data for Name: emotion_logs; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.emotion_logs (id, user_id, emotion, intensity, detected_at, source, message_id, raw_text, confidence, metadata) FROM stdin;
1	21	neutral	0.30	2025-12-02 15:36:46.766516+07	chat	\N	chào thằng cu ly	0.30	{}
2	21	neutral	0.30	2025-12-02 15:37:22.643403+07	chat	\N	mày hãy lập cho tau 1 kế hoạch đầu tư vàng	0.30	{}
3	21	sad	0.33	2025-12-02 15:38:34.882215+07	chat	\N	tau đang bị đau đầu đây\n	0.50	{}
4	21	neutral	0.30	2025-12-02 15:39:15.083436+07	chat	\N	đúng vậy , mày có lời khuyên gì không\n	0.30	{}
5	21	neutral	0.30	2025-12-02 15:40:00.014532+07	chat	\N	mày cứ đưa ra lời khuyên đi	0.30	{}
6	21	neutral	0.30	2025-12-02 15:40:49.562049+07	chat	\N	tao bị chó cắn	0.30	{}
7	21	anxious	0.33	2025-12-02 15:50:06.561903+07	chat	\N	alo , mày có đó ko	0.50	{}
8	21	neutral	0.30	2025-12-02 15:50:37.661413+07	chat	\N	hôm qua tau mới trúng số 100 tỷ	0.30	{}
9	21	neutral	0.30	2025-12-02 15:53:09.611907+07	chat	\N	anh ơi	0.30	{}
10	21	happy	0.33	2025-12-02 15:54:46.728194+07	chat	\N	gọi nhầm rồi, phải gọi em là em yêu	0.50	{}
11	21	neutral	0.33	2025-12-02 16:00:24.368443+07	checkin	\N	Mood: okay	0.50	{}
12	21	neutral	0.30	2025-12-02 16:01:32.081072+07	chat	\N	ê culy hôm nay tau vừa trúng 1 tỷ	0.30	{}
13	21	neutral	0.30	2025-12-02 16:01:59.997531+07	chat	\N	mua nhà mua xe	0.30	{}
14	21	sad	0.33	2025-12-02 16:02:27.119897+07	chat	\N	nhưng tau đang rất buồn	0.50	{}
15	21	neutral	0.33	2025-12-02 16:03:06.425866+07	chat	\N	tau đang tổn thương tâm lý , có chuyên gia nào hợp với tình trạng của tau không	0.50	{}
16	21	neutral	0.30	2025-12-02 16:13:32.676924+07	chat	\N	lên lịch uống thuốc cho tôi	0.30	{}
\.


--
-- TOC entry 6774 (class 0 OID 19853)
-- Dependencies: 351
-- Data for Name: emotion_patterns; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.emotion_patterns (id, user_id, pattern_type, pattern_key, pattern_data, frequency, first_detected, last_detected, is_active) FROM stdin;
\.


--
-- TOC entry 6726 (class 0 OID 19012)
-- Dependencies: 303
-- Data for Name: expert_audience; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.expert_audience (expert_id, audience_id) FROM stdin;
\.


--
-- TOC entry 6657 (class 0 OID 17216)
-- Dependencies: 234
-- Data for Name: expert_availabilities; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.expert_availabilities (id, expert_id, start_at, end_at, is_recurring, rrule) FROM stdin;
\.


--
-- TOC entry 6719 (class 0 OID 18945)
-- Dependencies: 296
-- Data for Name: expert_certifications; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.expert_certifications (id, expert_id, certificate_name, issuing_org, issued_at, expires_at, credential_url) FROM stdin;
\.


--
-- TOC entry 6729 (class 0 OID 19038)
-- Dependencies: 306
-- Data for Name: expert_domain; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.expert_domain (expert_id, domain_id) FROM stdin;
\.


--
-- TOC entry 6717 (class 0 OID 18931)
-- Dependencies: 294
-- Data for Name: expert_education; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.expert_education (id, expert_id, degree, institution, year_completed, description) FROM stdin;
\.


--
-- TOC entry 6715 (class 0 OID 18917)
-- Dependencies: 292
-- Data for Name: expert_experience; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.expert_experience (id, expert_id, "position", organization, years, description, start_year, end_year) FROM stdin;
\.


--
-- TOC entry 6723 (class 0 OID 18987)
-- Dependencies: 300
-- Data for Name: expert_media; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.expert_media (id, expert_id, media_type, url, title, description, created_at) FROM stdin;
\.


--
-- TOC entry 6720 (class 0 OID 18958)
-- Dependencies: 297
-- Data for Name: expert_performance; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.expert_performance (expert_id, response_time_avg, acceptance_rate, completion_rate, cancel_rate, avg_session_duration, total_sessions, total_reviews, ai_expertise_score, updated_at) FROM stdin;
\.


--
-- TOC entry 6653 (class 0 OID 17180)
-- Dependencies: 230
-- Data for Name: expert_profiles; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.expert_profiles (id, user_id, specialties, price_per_session, rating_avg, kyc_status, intro) FROM stdin;
3	1	{Anxiety,Depression,Relationship}	500000.00	5.0	PENDING	I'm a licensed therapist with 5 years of experience...
6	19	{career,productivity,interview}	250000.00	4.7	PENDING	Hỗ trợ định hướng nghề nghiệp & kỹ năng phỏng vấn
1	7	{}	0.00	\N	VERIFIED	New expert
2	9	{}	0.00	\N	REJECTED	New expert
4	17	{stress,anxiety,life-coaching}	300000.00	4.8	VERIFIED	10 năm kinh nghiệm life coaching
5	18	{marriage,family-conflict,relationship}	350000.00	4.9	REJECTED	15 năm kinh nghiệm tư vấn hôn nhân gia đình
7	20	{depression,anxiety,healing}	400000.00	5.0	VERIFIED	10 năm kinh nghiệm trị liệu trầm cảm và sang chấn
\.


--
-- TOC entry 6713 (class 0 OID 18900)
-- Dependencies: 290
-- Data for Name: expert_skills; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.expert_skills (expert_id, skill_id, created_at) FROM stdin;
\.


--
-- TOC entry 6721 (class 0 OID 18971)
-- Dependencies: 298
-- Data for Name: expert_status; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.expert_status (expert_id, is_online, last_active_at, active_score, status_message) FROM stdin;
4	t	2025-11-18 22:49:07.333623+07	0.00	\N
5	f	2025-11-18 22:51:08.462332+07	0.00	\N
6	t	2025-11-18 22:51:16.311789+07	0.00	\N
7	t	2025-11-18 22:51:21.317694+07	0.00	\N
\.


--
-- TOC entry 6655 (class 0 OID 17199)
-- Dependencies: 232
-- Data for Name: listener_profiles; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.listener_profiles (id, user_id, intro, verified) FROM stdin;
\.


--
-- TOC entry 6768 (class 0 OID 19787)
-- Dependencies: 345
-- Data for Name: mental_health_assessments; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.mental_health_assessments (id, user_id, assessment_type, risk_level, burnout_score, depression_indicators, anxiety_indicators, sleep_quality_score, social_engagement_score, assessed_at, recommendations, triggers_detected, notes, reviewed_by, reviewed_at) FROM stdin;
1	21	manual	low	15	0	0	\N	\N	2025-12-02 16:12:47.078367+07	[{"type": "maintenance", "message": "Tiếp tục duy trì thói quen tốt!", "priority": "low"}]	{}	Auto-assessed. Risk score: 0	\N	\N
\.


--
-- TOC entry 6685 (class 0 OID 17497)
-- Dependencies: 262
-- Data for Name: moderation_actions; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.moderation_actions (id, admin_id, target_type, target_id, action, reason, created_at) FROM stdin;
1	13	USER	14	BAN	Test ban	2025-11-27 14:14:44.423436+07
2	13	POST	1	HIDE	Vi phạm nội quy	2025-11-27 14:29:13.808373+07
3	13	POST	1	DELETE	Nội dung vi phạm nghiêm trọng	2025-11-27 14:29:16.854442+07
4	13	POST	1	HIDE	Vi phạm nội quy	2025-11-27 14:31:21.410118+07
5	13	USER	14	BAN	Spam và lừa đảo	2025-11-27 14:33:21.06122+07
6	13	USER	8	BAN	Spam và lừa đảo	2025-11-27 14:37:36.495739+07
7	13	USER	8	BAN	Spam và lừa đảo eqfhbibqwfh	2025-11-27 14:37:46.361645+07
8	13	USER	8	BAN	Spam và lừa đảo 	2025-11-27 14:37:56.788752+07
9	13	USER	8	BAN	Spam 	2025-11-27 14:38:03.826818+07
10	13	USER	9	BAN	Spam 	2025-11-27 14:38:14.629498+07
11	13	POST	9	DELETE	Scam/Lừa đảo	2025-11-27 14:49:38.872439+07
12	2	POST	13	HIDE	no	2025-12-05 16:20:54.244603+07
13	2	POST	6	HIDE	no\n	2025-12-05 16:21:04.035306+07
\.


--
-- TOC entry 6710 (class 0 OID 18872)
-- Dependencies: 287
-- Data for Name: oauth_users; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.oauth_users (id, app_user_id, google_id, email, name, avatar, created_at) FROM stdin;
1	15	113893440272545257057	skytua121@gmail.com	Tiến Võ Đức	https://lh3.googleusercontent.com/a/ACg8ocJc8Ma3D2iEvKA7TJgR8P29fDAs8zrCf89P9LZCga_Iv7kCs2OR=s96-c	2025-11-14 15:24:34.241407+07
2	16	107111890882708815722	2254810130@vaa.edu.vn	TIEN VO DUC	https://lh3.googleusercontent.com/a/ACg8ocK44KKLwXJDpgQSk5uQgMdtZcn_dJVSDIQsmikTFL46u1_AIQ=s96-c	2025-11-17 11:00:04.875516+07
\.


--
-- TOC entry 6792 (class 0 OID 20136)
-- Dependencies: 375
-- Data for Name: password_resets; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.password_resets (id, user_id, email, otp_code, expires_at, used, used_at, created_at, ip_address, user_agent) FROM stdin;
1	1	skinss246@gmail.com	591980	2025-12-12 12:26:52.039+07	t	2025-12-12 12:17:38.966786+07	2025-12-12 12:16:52.039994+07	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36
\.


--
-- TOC entry 6663 (class 0 OID 17280)
-- Dependencies: 240
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
12	21	21	MOMO	0.00	VND	REQUIRES_ACTION	\N	{"requestType": "captureWallet"}	2025-12-01 12:04:51.182109+07	BK21_1764565491201	\N
13	22	21	MOMO	0.00	VND	REQUIRES_ACTION	\N	{"requestType": "captureWallet"}	2025-12-01 12:05:20.816647+07	BK22_1764565520818	\N
14	23	21	MOMO	500000.00	VND	REQUIRES_ACTION	\N	{"requestType": "captureWallet"}	2025-12-05 17:22:06.879125+07	BK23_1764930126898	\N
15	24	21	MOMO	500000.00	VND	REQUIRES_ACTION	\N	{"requestType": "captureWallet"}	2025-12-05 17:23:02.236361+07	BK24_1764930182245	\N
16	25	21	MOMO	500000.00	VND	REQUIRES_ACTION	\N	{"requestType": "captureWallet"}	2025-12-05 17:24:33.98968+07	BK25_1764930273999	\N
17	26	21	MOMO	300000.00	VND	REQUIRES_ACTION	\N	{"requestType": "captureWallet"}	2025-12-05 17:25:56.729238+07	BK26_1764930356734	\N
\.


--
-- TOC entry 6665 (class 0 OID 17304)
-- Dependencies: 242
-- Data for Name: payments; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.payments (id, intent_id, paid_at, status, gateway_payload) FROM stdin;
\.


--
-- TOC entry 6708 (class 0 OID 18840)
-- Dependencies: 285
-- Data for Name: payout_accounts; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.payout_accounts (id, user_id, bank_name, account_number, account_holder, verified, verified_at, created_at) FROM stdin;
1	1	VCB	1234567890	Nguyễn Văn A	f	\N	2025-10-16 13:14:12.287422+07
\.


--
-- TOC entry 6731 (class 0 OID 19056)
-- Dependencies: 308
-- Data for Name: payout_requests; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.payout_requests (id, user_id, amount, status, payout_account_id, admin_note, created_at, updated_at, processed_by, processed_at) FROM stdin;
1	1	200000.00	REJECTED	1	Test Rejection	2025-11-21 17:55:11.881242+07	2025-11-21 17:55:11.931534+07	\N	\N
\.


--
-- TOC entry 6743 (class 0 OID 19304)
-- Dependencies: 320
-- Data for Name: platform_settings; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.platform_settings (id, key, value, description, updated_at, updated_by) FROM stdin;
1	platform_fee_percent	15	Platform fee percentage (0-100)	2025-12-01 11:54:32.356607+07	\N
2	min_platform_fee	5000	Minimum platform fee in VND	2025-12-01 11:54:32.356607+07	\N
3	refund_policy_hours	24	Hours before booking start for full refund	2025-12-01 11:54:32.356607+07	\N
4	partial_refund_percent	50	Partial refund percentage if cancelled within policy hours	2025-12-01 11:54:32.356607+07	\N
5	auto_complete_hours	24	Hours after booking end to auto-complete	2025-12-01 11:54:32.356607+07	\N
\.


--
-- TOC entry 6696 (class 0 OID 18629)
-- Dependencies: 273
-- Data for Name: post_audience; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.post_audience (post_id, user_id) FROM stdin;
\.


--
-- TOC entry 6700 (class 0 OID 18701)
-- Dependencies: 277
-- Data for Name: post_files; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.post_files (post_id, file_id, created_at) FROM stdin;
\.


--
-- TOC entry 6698 (class 0 OID 18650)
-- Dependencies: 275
-- Data for Name: post_media; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.post_media (id, post_id, kind, url, width, height, duration_ms, created_at, original_name, public_id) FROM stdin;
1	10	IMAGE	https://res.cloudinary.com/dtw54lnkj/image/upload/v1764649702/mendy/posts/npgqeldrk89bqsljux0o.jpg	1664	2496	\N	2025-12-02 11:28:26.371288+07	\N	\N
2	11	IMAGE	https://res.cloudinary.com/dtw54lnkj/image/upload/v1764649825/mendy/posts/nwitmsud2ymxvgxnkutp.png	795	1111	\N	2025-12-02 11:30:29.745295+07	\N	\N
3	12	IMAGE	https://res.cloudinary.com/dtw54lnkj/image/upload/v1764650086/mendy/posts/o2wvlvjc3qqmmhr8pvya.png	799	1112	\N	2025-12-02 11:34:50.60189+07	\N	\N
4	13	IMAGE	https://res.cloudinary.com/dtw54lnkj/image/upload/v1764650478/mendy/posts/img_21_1764650479901_t78toq.png	1000	1000	\N	2025-12-02 11:41:22.37283+07	VGBC-Logo-PNG (1).png	mendy/posts/img_21_1764650479901_t78toq
\.


--
-- TOC entry 6679 (class 0 OID 17440)
-- Dependencies: 256
-- Data for Name: post_reactions; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.post_reactions (post_id, user_id, reaction, created_at) FROM stdin;
\.


--
-- TOC entry 6701 (class 0 OID 18718)
-- Dependencies: 278
-- Data for Name: post_saves; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.post_saves (user_id, post_id, created_at) FROM stdin;
\.


--
-- TOC entry 6678 (class 0 OID 17424)
-- Dependencies: 255
-- Data for Name: posts; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.posts (id, author_id, anonymous, title, content, tags, created_at, updated_at, privacy, report_count) FROM stdin;
8	9	t	Hello world fdafadfadf	Nội dung bài viết đầu tiên àdsafadfaf	\N	2025-10-08 20:56:24.861694+07	2025-10-08 20:56:24.861694+07	PUBLIC	0
10	21	t	Đây là bài test upstcfload ảnh! 📸	Đây là bài test upstcfload ảnh! 📸	\N	2025-12-02 11:28:23.169557+07	2025-12-02 11:28:23.169557+07	PUBLIC	0
11	21	t	Đây là bài test upload ảnh! 📸	Đây là bài test upload ảnh! 📸	\N	2025-12-02 11:30:26.282039+07	2025-12-02 11:30:26.282039+07	ONLY_ME	0
12	21	t	Đây là bài test upload ảnh! 📸	Đây là bài test upload ảnh! 📸	\N	2025-12-02 11:34:47.084864+07	2025-12-02 11:34:47.084864+07	FRIENDS	0
13	21	t	Đây là bài test upload ảnh! 📸	Đây là bài test upload ảnh! 📸	\N	2025-12-02 11:41:19.887125+07	2025-12-05 16:20:54.228749+07	ONLY_ME	0
6	4	t	Hello world	Nội dung bài viết đầu tiên	\N	2025-09-26 11:35:25.999037+07	2025-12-05 16:21:04.013584+07	ONLY_ME	0
\.


--
-- TOC entry 6784 (class 0 OID 19989)
-- Dependencies: 364
-- Data for Name: proactive_messages; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.proactive_messages (id, user_id, trigger_type, trigger_data, message_content, persona_id, priority, scheduled_at, expires_at, sent_at, is_sent, user_response, effectiveness_score, created_at) FROM stdin;
\.


--
-- TOC entry 6702 (class 0 OID 18765)
-- Dependencies: 279
-- Data for Name: processed_events; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.processed_events (idempotency_key, occurred_at) FROM stdin;
\.


--
-- TOC entry 6755 (class 0 OID 19473)
-- Dependencies: 332
-- Data for Name: product_reviews; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.product_reviews (id, product_id, user_id, rating, comment, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 6751 (class 0 OID 19412)
-- Dependencies: 328
-- Data for Name: recurring_booking_templates; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.recurring_booking_templates (id, user_id, expert_id, channel, start_time, duration_minutes, frequency, day_of_week, day_of_month, price_per_session, total_sessions, sessions_completed, is_active, next_booking_date, starts_from, ends_at, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 6745 (class 0 OID 19320)
-- Dependencies: 322
-- Data for Name: refunds; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.refunds (id, booking_id, payment_intent_id, user_id, amount, platform_fee_refunded, reason, status, admin_note, processed_by, processed_at, provider_refund_id, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 6683 (class 0 OID 17481)
-- Dependencies: 260
-- Data for Name: reports; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.reports (id, target_type, target_id, reporter_id, reason, details, created_at, status, resolved_by, resolved_at, resolution_note, action_taken) FROM stdin;
\.


--
-- TOC entry 6704 (class 0 OID 18795)
-- Dependencies: 281
-- Data for Name: reviews; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.reviews (id, user_id, expert_id, booking_id, rating, comment, created_at, updated_at, is_hidden, hidden_reason, hidden_at, hidden_by) FROM stdin;
2	5	1	18	5.0	Chuyên gia rất tận tâm và giỏi	2025-10-15 20:41:20.522902+07	2025-10-15 20:41:20.522902+07	f	\N	\N	\N
\.


--
-- TOC entry 6733 (class 0 OID 19071)
-- Dependencies: 310
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.schema_migrations (id, version, name, executed_at) FROM stdin;
1	000_tracking	Initialize migration tracking	2025-11-21 19:20:24.816692+07
3	001_create_payout_requests	001_create_payout_requests.sql	2025-11-21 20:35:08.990008+07
4	002_add_performance_indexes	002_add_performance_indexes.sql	2025-11-21 20:35:08.997636+07
8	20251121120000_add_chat_attachments_and_message_edit	20251121120000_add_chat_attachments_and_message_edit.sql	2025-11-24 13:59:17.067665+07
9	20251121121000_add_call_metrics	20251121121000_add_call_metrics.sql	2025-11-24 13:59:17.077544+07
10	20251121122000_add_call_recordings	20251121122000_add_call_recordings.sql	2025-11-24 13:59:17.087499+07
11	20251121123000_add_chat_thread_invitations	20251121123000_add_chat_thread_invitations.sql	2025-11-24 13:59:17.100386+07
12	20251121124000_add_group_name_to_chat_threads	20251121124000_add_group_name_to_chat_threads.sql	2025-11-24 13:59:17.108382+07
13	20251121125000_add_message_edit_delete_columns	20251121125000_add_message_edit_delete_columns.sql	2025-11-24 13:59:17.113779+07
14	20251124135630_fix_critical_database_issues	20251124135630_fix_critical_database_issues.sql	2025-11-24 13:59:17.116511+07
16	003_admin_enhancements	003_admin_enhancements.sql	2025-12-01 11:54:32.255352+07
17	004_refund_dispute_recurring	004_refund_dispute_recurring.sql	2025-12-01 11:54:32.356607+07
18	20251129100000_create_product_reviews	20251129100000_create_product_reviews.sql	2025-12-01 11:54:32.452006+07
20	012_add_original_name_to_post_media	012_add_original_name_to_post_media.sql	2025-12-02 11:40:16.707445+07
22	013_create_user_blocks_table	013_create_user_blocks_table.sql	2025-12-02 15:03:27.495032+07
23	20251202_ai_companion_phase1	20251202_ai_companion_phase1.sql	2025-12-02 15:03:27.559878+07
24	20251202_ai_companion_seed	20251202_ai_companion_seed.sql	2025-12-02 15:03:27.635621+07
27	20251202_ai_companion_phase2	20251202_ai_companion_phase2.sql	2025-12-02 15:25:44.857521+07
29	20251202_ai_chat_history	20251202_ai_chat_history.sql	2025-12-02 15:48:21.177235+07
31	20251202_ai_companion_phase3	20251202_ai_companion_phase3.sql	2025-12-02 16:09:39.859081+07
33	20251205_admin_extended_features	20251205_admin_extended_features.sql	2025-12-05 16:07:05.815648+07
35	20251208_add_analytics_indexes	20251208_add_analytics_indexes.sql	2025-12-08 12:25:32.831085+07
37	20251208_add_email_unique_constraint	20251208_add_email_unique_constraint.sql	2025-12-08 21:11:17.409251+07
39	20251212_add_crisis_alerts_table	20251212_add_crisis_alerts_table.sql	2025-12-12 12:11:47.69899+07
40	20251212_add_expert_search_indexes	20251212_add_expert_search_indexes.sql	2025-12-12 12:11:47.814716+07
41	20251212_add_password_reset	20251212_add_password_reset.sql	2025-12-12 12:11:47.837483+07
45	20251212_add_expert_search_fulltext_indexes	20251212_add_expert_search_fulltext_indexes.sql	2025-12-12 12:47:34.098638+07
\.


--
-- TOC entry 6661 (class 0 OID 17258)
-- Dependencies: 238
-- Data for Name: session_notes; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.session_notes (id, booking_id, expert_id, content, created_at) FROM stdin;
\.


--
-- TOC entry 6712 (class 0 OID 18890)
-- Dependencies: 289
-- Data for Name: skills; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.skills (id, name, category, description) FROM stdin;
\.


--
-- TOC entry 6780 (class 0 OID 19948)
-- Dependencies: 360
-- Data for Name: sleep_logs; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.sleep_logs (id, user_id, date, sleep_at, wake_at, duration_minutes, quality, deep_sleep_minutes, interruptions, notes, factors, created_at) FROM stdin;
\.


--
-- TOC entry 6671 (class 0 OID 17351)
-- Dependencies: 248
-- Data for Name: tips; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.tips (id, from_user_id, to_user_id, amount, message, created_at) FROM stdin;
\.


--
-- TOC entry 6788 (class 0 OID 20027)
-- Dependencies: 368
-- Data for Name: user_activity_logs; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.user_activity_logs (id, user_id, activity_type, activity_data, session_id, created_at) FROM stdin;
\.


--
-- TOC entry 6759 (class 0 OID 19530)
-- Dependencies: 336
-- Data for Name: user_ai_settings; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.user_ai_settings (user_id, persona_id, relationship_level, custom_nickname, user_nickname, notification_enabled, morning_checkin, evening_checkin, random_messages, quiet_hours_start, quiet_hours_end, timezone, created_at, updated_at) FROM stdin;
21	3	1	Ông chủ	thằng culy	t	t	t	t	23:00:00	07:00:00	Asia/Ho_Chi_Minh	2025-12-02 15:04:38.623895+07	2025-12-02 15:58:50.319216+07
\.


--
-- TOC entry 6756 (class 0 OID 19494)
-- Dependencies: 333
-- Data for Name: user_blocks; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.user_blocks (blocker_id, blocked_id, created_at) FROM stdin;
\.


--
-- TOC entry 6649 (class 0 OID 17147)
-- Dependencies: 226
-- Data for Name: user_files; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.user_files (id, user_id, file_type, file_url, mime_type, byte_size, created_at) FROM stdin;
\.


--
-- TOC entry 6695 (class 0 OID 18603)
-- Dependencies: 272
-- Data for Name: user_follows; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.user_follows (follower_id, followee_id, created_at) FROM stdin;
5	1	2025-10-09 13:44:52.687741+07
\.


--
-- TOC entry 6766 (class 0 OID 19761)
-- Dependencies: 343
-- Data for Name: user_mental_state; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.user_mental_state (user_id, current_mood, mood_score, stress_level, anxiety_level, energy_level, vulnerability_score, consecutive_negative_days, last_positive_interaction, last_evaluated, evaluation_notes, created_at, updated_at) FROM stdin;
21	neutral	0.33	0	0	5	0.00	0	2025-12-02 15:54:46.74+07	2025-12-02 16:13:32.689871+07	\N	2025-12-02 15:36:24.849536+07	2025-12-02 16:13:32.689871+07
\.


--
-- TOC entry 6646 (class 0 OID 17121)
-- Dependencies: 223
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
5	Nguyễn Quý Hoàng	https://res.cloudinary.com/dtw54lnkj/image/upload/v1764652289/mendy/avatars/avatars_1764652290872_52bmch.jpg	\N	MALE	2000	\N	{"attachment_url": null}	2025-12-02 12:11:33.629932+07	f
\.


--
-- TOC entry 6647 (class 0 OID 17136)
-- Dependencies: 224
-- Data for Name: user_roles; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.user_roles (user_id, role) FROM stdin;
\.


--
-- TOC entry 6778 (class 0 OID 19924)
-- Dependencies: 358
-- Data for Name: user_schedules; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.user_schedules (id, user_id, title, description, schedule_type, start_at, end_at, is_all_day, recurrence, remind_before, priority, ai_generated, completed, completed_at, metadata, created_at, updated_at) FROM stdin;
1	21	uống thuốc	\N	health	2025-12-02 10:09:00+07	\N	f	\N	15	5	f	f	\N	{}	2025-12-02 16:10:25.290779+07	2025-12-02 16:10:25.290779+07
\.


--
-- TOC entry 6706 (class 0 OID 18822)
-- Dependencies: 283
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
13	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTkzMjYxNCwiZXhwIjoxNzYyNTI0NjE0LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.gqztv7zQUPRp9rSLXJbnWIrwQoV3pMr78NPs8xBVncI	PostmanRuntime/7.48.0	::1	2025-10-08 22:10:14.028+07	2025-10-08 21:10:14.028723+07	f
14	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTk4NzAxNiwiZXhwIjoxNzYyNTc5MDE2LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.FdcpZKOxCfwffu8oT3sZMCJ1r2yfq_tKHgjIm8C00gU	PostmanRuntime/7.48.0	::1	2025-10-09 13:16:56.085+07	2025-10-09 12:16:56.087183+07	f
16	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTk4ODIyNCwiZXhwIjoxNzYyNTgwMjI0LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.D00_OVYLBcDwzqbCtTeDK14gQDFtOcq2YXVSREQgsBQ	PostmanRuntime/7.48.0	::1	2025-10-09 13:37:04.157+07	2025-10-09 12:37:04.158366+07	f
19	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTk5MDM5MSwiZXhwIjoxNzYyNTgyMzkxLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.NYUBBBdGqaKAYZ6V5TpVBZRQykUxsV-eg2wLezCbhpI	PostmanRuntime/7.48.0	::1	2025-10-09 14:13:11.978+07	2025-10-09 13:13:11.979729+07	f
20	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDEwMjM1MiwiZXhwIjoxNzYyNjk0MzUyLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.Xv83UVWlVYuOzpNu7lGTbxauf36ryDx9AaK_86X0u-8	PostmanRuntime/7.48.0	::1	2025-10-10 21:19:12.385+07	2025-10-10 20:19:12.386733+07	f
21	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDEwMjM4OSwiZXhwIjoxNzYyNjk0Mzg5LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.OftYyRD_8R_3JYWq9-sxNbGVIJGX7VSDqOSm5AhIjuk	PostmanRuntime/7.48.0	::1	2025-10-10 21:19:49.46+07	2025-10-10 20:19:49.462185+07	f
22	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDEwNzIyMSwiZXhwIjoxNzYyNjk5MjIxLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.ZWxbE3lAP71jOEG6thTEVzW78LQ22MNQ4UtB4ZCGF0c	PostmanRuntime/7.48.0	::1	2025-10-10 22:40:21.822+07	2025-10-10 21:40:21.824461+07	f
23	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDEwNzI0MywiZXhwIjoxNzYyNjk5MjQzLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.JKPY8I8nla49MIdtXppqAm7g-diwgCt8HO3_57SQ_Hw	PostmanRuntime/7.48.0	::1	2025-10-10 22:40:43.634+07	2025-10-10 21:40:43.63662+07	f
25	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDQxNzY1MCwiZXhwIjoxNzYzMDA5NjUwLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.MUbEh8iuw_lvnsMlL1a9fEjAAtlkP0WFAusb3VPuTFU	PostmanRuntime/7.48.0	::1	2025-10-14 12:54:10.947+07	2025-10-14 11:54:10.9493+07	f
28	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDQxOTMyOSwiZXhwIjoxNzYzMDExMzI5LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.V-e_0aRucGNMW_h0I2RZTnBr9IO5xPJGOiamtltz8AU	PostmanRuntime/7.48.0	::1	2025-10-14 13:22:09.123+07	2025-10-14 12:22:09.125115+07	f
31	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDQzODQ4MSwiZXhwIjoxNzYzMDMwNDgxLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.I5Ze7GexOpOjS2sH9RwLDvGbxGz1MBKfX2uC1j1U6Gw	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::1	2025-10-14 18:41:21.145+07	2025-10-14 17:41:21.147362+07	f
32	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDUzMDg5NywiZXhwIjoxNzYzMTIyODk3LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.Xqb49FC30mjwM_o_V3DkZTldj1NV1sCbuWp8iKz0WT8	PostmanRuntime/7.48.0	::1	2025-10-15 20:21:37.872+07	2025-10-15 19:21:37.873542+07	f
33	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDUzMzEwNywiZXhwIjoxNzYzMTI1MTA3LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.mSeutgZx9_fjIfravoE7N5-jPidfJIwsgyv0puD6vcs	PostmanRuntime/7.48.0	::1	2025-10-15 20:58:27.361+07	2025-10-15 19:58:27.362828+07	f
35	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDUzNDAyNCwiZXhwIjoxNzYzMTI2MDI0LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.AfTizNSfAVaURJ6tFrj8572UQQ1BlsGLVlljtJCSPuY	PostmanRuntime/7.48.0	::1	2025-10-15 21:13:44.029+07	2025-10-15 20:13:44.030225+07	f
38	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDUzNTY2OCwiZXhwIjoxNzYzMTI3NjY4LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.D0TxymZebdrERST0m5tvJYipkIkPvmfp6Gz1bTUXEq0	PostmanRuntime/7.48.0	::1	2025-10-15 21:41:08.019+07	2025-10-15 20:41:08.020559+07	f
39	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDU5MzgyOCwiZXhwIjoxNzYzMTg1ODI4LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.IXrdvcXW41H7zlm-Mt8sgSbcKxAmb6-Wn6OwDsr_VfE	PostmanRuntime/7.48.0	::1	2025-10-16 13:50:28.37+07	2025-10-16 12:50:28.372913+07	f
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
56	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MzQ3OTIxNSwiZXhwIjoxNzY2MDcxMjE1LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.klVfq_cZSJjIOJDZ2cqqOdccml1RSnHb2JPI3Nlknu0	PostmanRuntime/7.49.1	::1	2025-11-18 23:20:15.148+07	2025-11-18 22:20:15.150161+07	f
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
69	13	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMyIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQyMjc1NjcsImV4cCI6MTc2NjgxOTU2NywiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.6Z6e0hdDRviZoJqJsOQx16XYy4-M4XuTckU9gQWZuWA	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	::1	2025-11-27 15:12:47.948+07	2025-11-27 14:12:47.949686+07	f
70	13	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMyIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQyMjc1NzYsImV4cCI6MTc2NjgxOTU3NiwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.oNjums2tAZuWDK6kbkZs6kI3NzQzwRC-uSq7d4uriFU	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	::1	2025-11-27 15:12:56.39+07	2025-11-27 14:12:56.391787+07	f
71	13	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMyIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQyMjc4MzgsImV4cCI6MTc2NjgxOTgzOCwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.X2jN6ljkXxzn_UTv2W0KyIyGN0fjDCtPSjvA2if-Pes	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	::1	2025-11-27 15:17:18.653+07	2025-11-27 14:17:18.654815+07	f
72	13	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMyIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQyMjc4NDYsImV4cCI6MTc2NjgxOTg0NiwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.hpq-ntsedebkAP4KsQA5_kbff4BNLjamq3KbZCVYrjQ	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	::1	2025-11-27 15:17:26.896+07	2025-11-27 14:17:26.897767+07	f
73	13	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMyIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQyMjc4NTAsImV4cCI6MTc2NjgxOTg1MCwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.DXTBGw8gvoAfMUtg-ePjBc6GDiACeNLYQAfq_fBW7R0	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	::1	2025-11-27 15:17:30.019+07	2025-11-27 14:17:30.021119+07	f
74	13	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMyIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQyMjc4NTksImV4cCI6MTc2NjgxOTg1OSwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.s8yoImUNQcJgny297OrtfsXsVtdfkgnpjauvqD_0q20	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	::1	2025-11-27 15:17:39.78+07	2025-11-27 14:17:39.781682+07	f
75	13	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMyIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQyMjc4NjgsImV4cCI6MTc2NjgxOTg2OCwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.ytfbxuhKbzKL7NFkDDJBbTknGAX0Y3szacV9IxYDop0	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	::1	2025-11-27 15:17:48.816+07	2025-11-27 14:17:48.817575+07	f
76	13	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMyIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQyMjc4NzgsImV4cCI6MTc2NjgxOTg3OCwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.rSSX4iBaJ4XcHmKYWaepTOAwnmM0i7zu9XpXPW3Vk78	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	::1	2025-11-27 15:17:58.929+07	2025-11-27 14:17:58.929913+07	f
77	13	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMyIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQyMjc5MDgsImV4cCI6MTc2NjgxOTkwOCwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.hJNke-mMCwqkgXKyQbW1sxL8JW5Q51IyIdw23LpQQvw	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	::1	2025-11-27 15:18:28.565+07	2025-11-27 14:18:28.567323+07	f
78	13	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMyIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQyMjgyNDcsImV4cCI6MTc2NjgyMDI0NywiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.D75WYlgUBJ0ZC4ph3zWBEPHSFSEwnQoii9uejqieHmw	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	::1	2025-11-27 15:24:07.06+07	2025-11-27 14:24:07.061483+07	f
79	13	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMyIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQyMjg0MjIsImV4cCI6MTc2NjgyMDQyMiwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.GtAPh3IspwaQnDl2sbOInplwCwpJi98jAhOIW8-rAPY	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	::1	2025-11-27 15:27:02.127+07	2025-11-27 14:27:02.128452+07	f
80	13	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMyIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQyMjg0OTUsImV4cCI6MTc2NjgyMDQ5NSwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.lnkpgKnhpcMsw1T8ZnYGuqIYpffNYc58bwF4UBdQ7kw	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-11-27 15:28:15.333+07	2025-11-27 14:28:15.334692+07	f
81	13	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMyIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQyMjg2NjYsImV4cCI6MTc2NjgyMDY2NiwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.QwJ9UoFjGL1pQt-R1ZcqODCVl6roG6SptGW1XX5Zcns	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-11-27 15:31:06.968+07	2025-11-27 14:31:06.968616+07	f
82	13	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMyIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQyMjg2NjcsImV4cCI6MTc2NjgyMDY2NywiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.5HrPKa01UQO4B-Jrez5TAyXaJeYZRVObGuCCGrA_lM4	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-11-27 15:31:07.902+07	2025-11-27 14:31:07.902831+07	f
83	13	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMyIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQyMjg2NjgsImV4cCI6MTc2NjgyMDY2OCwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.TN4lbkaSRSzRkR0B4gE6TX7aC-CI_8gGqm9slX4iz1A	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-11-27 15:31:08.113+07	2025-11-27 14:31:08.114088+07	f
84	13	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMyIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQyMjg2NjgsImV4cCI6MTc2NjgyMDY2OCwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.TN4lbkaSRSzRkR0B4gE6TX7aC-CI_8gGqm9slX4iz1A	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-11-27 15:31:08.319+07	2025-11-27 14:31:08.320343+07	f
85	13	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMyIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQyMjg5MjIsImV4cCI6MTc2NjgyMDkyMiwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.0Biljzk57U9vhjXKKD0nNBrFYaa_BLjVVMjgcY5XPug	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-11-27 15:35:22.99+07	2025-11-27 14:35:22.991464+07	f
86	13	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMyIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQyMjk1MDEsImV4cCI6MTc2NjgyMTUwMSwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.nDxutC77RoZRmWvo8qIojef0MGypF8l2_yylLWxp6-4	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	::1	2025-11-27 15:45:01.916+07	2025-11-27 14:45:01.91806+07	f
87	13	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMyIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQyMjk1MTEsImV4cCI6MTc2NjgyMTUxMSwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.cJ5FDNybo3yGE6R12H5lR49IfNvtrBLJKMc152KvKyI	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	::1	2025-11-27 15:45:11.271+07	2025-11-27 14:45:11.272315+07	f
88	13	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMyIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQyMjk1MjUsImV4cCI6MTc2NjgyMTUyNSwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.vA9ivfCu2sfhLW5VJ5pOKrJZgaQeyWg5p6ZLSbxLkhY	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7019	::1	2025-11-27 15:45:25.874+07	2025-11-27 14:45:25.875064+07	f
89	13	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMyIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQyMjk2ODAsImV4cCI6MTc2NjgyMTY4MCwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.joDqR9iktYGfPgesL9290FrSsCmDULV0ExGItzPIyTM	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-11-27 15:48:00.502+07	2025-11-27 14:48:00.504475+07	f
90	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMSIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQ1NjUyODEsImV4cCI6MTc2NzE1NzI4MSwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.GsJ0-Ruc0RNogRGuWjIjxknHI-uR8WINXP2cjxGu0WU	PostmanRuntime/7.49.1	::1	2025-12-01 13:01:21.569+07	2025-12-01 12:01:21.570863+07	f
91	9	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2NDU2NTI5NSwiZXhwIjoxNzY3MTU3Mjk1LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.-TB7eLbKYN6Ng2KMNAo4G8_9pRgX_sk48Kj99QPHU68	PostmanRuntime/7.49.1	::1	2025-12-01 13:01:35.831+07	2025-12-01 12:01:35.832843+07	f
92	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMSIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQ1NzEwOTYsImV4cCI6MTc2NzE2MzA5NiwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.KqFW4xQ22smGQgJk9qavkWD0IQ6iRn5iU3dELXTWirE	PostmanRuntime/7.49.1	::1	2025-12-01 14:38:16.101+07	2025-12-01 13:38:16.103124+07	f
93	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2NDY0MzU1MSwiZXhwIjoxNzY3MjM1NTUxLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.iTIYOZxPUk15XvkvSl2qsoL7dmEpwPp9Ina3cA9jzsk	PostmanRuntime/7.49.1	::1	2025-12-02 10:45:51.479+07	2025-12-02 09:45:51.480041+07	f
94	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMSIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQ2NDg3NjQsImV4cCI6MTc2NzI0MDc2NCwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.76xnSkZQdMJ1XBJDkxVoFKN3L71x9zA3XLkMuOdnRBk	PostmanRuntime/7.49.1	::1	2025-12-02 12:12:44.725+07	2025-12-02 11:12:44.726725+07	f
95	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMSIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQ2NDk2ODcsImV4cCI6MTc2NzI0MTY4NywiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.qLV-j_oEyIxHm6hURqXCAKnqIvhZ7-duYN8jsyTrEfw	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-12-02 12:28:07.723+07	2025-12-02 11:28:07.725334+07	f
96	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMSIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQ2NDk4NzYsImV4cCI6MTc2NzI0MTg3NiwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.RXlkdIKWE99K3PzRRYMTytIM-rTJLB1hQS5KyVrDNoY	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-12-02 12:31:16.092+07	2025-12-02 11:31:16.093905+07	f
97	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMSIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQ2NTA0NjksImV4cCI6MTc2NzI0MjQ2OSwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.imTpUCwvXeew6AmxbkNbNAWCt845AifZhlq-uUXMvEU	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-12-02 12:41:09.996+07	2025-12-02 11:41:09.997885+07	f
98	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2NDY1MDg4OSwiZXhwIjoxNzY3MjQyODg5LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.KKSea-BU-HzoUcbDmdx8eUOIw6WrTa0XrSsdI0-hAqc	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-12-02 12:48:09.908+07	2025-12-02 11:48:09.908862+07	f
99	4	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2NDY1MTA0NSwiZXhwIjoxNzY3MjQzMDQ1LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.a1QBELkr57sV1wLQFedJzeMAmN6FO6Ces6qmaFR17Fg	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-12-02 12:50:45.199+07	2025-12-02 11:50:45.200661+07	f
100	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2NDY1MTEzNSwiZXhwIjoxNzY3MjQzMTM1LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.zC3RSepEdDYUrwNKxGd_vveurSHpciYmQ8fHKSRjDZo	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-12-02 12:52:15.042+07	2025-12-02 11:52:15.043154+07	f
101	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2NDY1MjEyMywiZXhwIjoxNzY3MjQ0MTIzLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.tdJ3UwjIxSDbbw5jS48u6AdTV2B3j-MPaYuSSFkTpz0	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-12-02 13:08:43.481+07	2025-12-02 12:08:43.483022+07	f
102	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMSIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQ2NjI1ODEsImV4cCI6MTc2NzI1NDU4MSwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.nh0Nc_sL5OUV14nurq2jeEyEO7Ov-ZEpwtu0DKZXzmI	PostmanRuntime/7.49.1	::1	2025-12-02 16:03:01.552+07	2025-12-02 15:03:01.5548+07	f
103	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMSIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQ2NjQzMDAsImV4cCI6MTc2NzI1NjMwMCwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.ikRY-AdyPpxM4o0DNqLoEtJuzFLiahD3GkCdbKUEVkM	PostmanRuntime/7.49.1	::1	2025-12-02 16:31:40.843+07	2025-12-02 15:31:40.846037+07	f
104	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMSIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQ2NjY3NDIsImV4cCI6MTc2NzI1ODc0MiwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.eVZehu7gfoepsujYccVtu0VgWIw2OJDnADb51LW-AdY	PostmanRuntime/7.49.1	::1	2025-12-02 17:12:22.501+07	2025-12-02 16:12:22.50359+07	f
105	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2NDkyMTk5MywiZXhwIjoxNzY3NTEzOTkzLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.F_nZ8K413EMz4kCDJnhudMPCWzCgKI8fA9KZvX22NpU	PostmanRuntime/7.49.1	::1	2025-12-05 16:06:33.667+07	2025-12-05 15:06:33.670154+07	f
106	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2NDkyMzgwMywiZXhwIjoxNzY3NTE1ODAzLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.PegFSkS9vftneKovFXMtd71-MM_2znm246Fi8gByn_c	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-12-05 16:36:43.479+07	2025-12-05 15:36:43.480096+07	f
107	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2NDkyMzgyMSwiZXhwIjoxNzY3NTE1ODIxLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.SEsCWFLnM0xMSrrgSfda5I7JB3CytNJHX7K2t7Mw_bE	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-12-05 16:37:01.341+07	2025-12-05 15:37:01.3419+07	f
108	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2NDkyMzg5OCwiZXhwIjoxNzY3NTE1ODk4LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.57VgU2bDTBB2vTjzyLo9H3qsYSiyYz6lOlDoGqJwgBQ	PostmanRuntime/7.49.1	::1	2025-12-05 16:38:18.63+07	2025-12-05 15:38:18.632087+07	f
109	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2NDkyMzkzOSwiZXhwIjoxNzY3NTE1OTM5LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.vQFhMVsgIXQFcZvuCr0XWm1frLXtFE6hRjP0ZQGe8js	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-12-05 16:38:59.354+07	2025-12-05 15:38:59.355553+07	f
110	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMSIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQ5MjcyMDUsImV4cCI6MTc2NzUxOTIwNSwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.t5WaENEwXgeQZAqnAPOvf56fMp5fGShvxAloAv5Qk5A	PostmanRuntime/7.49.1	::1	2025-12-05 17:33:25.679+07	2025-12-05 16:33:25.681374+07	f
111	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2NDkyODM4NiwiZXhwIjoxNzY3NTIwMzg2LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.wZCYlNqp9PB69x7bh42YTnltUfeiIMbsqiQ0mBnlyFM	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-12-05 17:53:06.431+07	2025-12-05 16:53:06.432373+07	f
112	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMSIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQ5Mjk0NTAsImV4cCI6MTc2NzUyMTQ1MCwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.ew-OKnUSe2cWOp-HBS19tgmzJiJcnqid3oz4YWsmQOU	PostmanRuntime/7.49.1	::1	2025-12-05 18:10:50.274+07	2025-12-05 17:10:50.276014+07	f
113	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMSIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQ5Mjk0NzUsImV4cCI6MTc2NzUyMTQ3NSwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.jg6QdXCHnl6LAz8QvWaW_1Qh2aAMkT44JUPXbsYrWGw	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-12-05 18:11:15.718+07	2025-12-05 17:11:15.720251+07	f
114	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMSIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQ5Mjk4NzAsImV4cCI6MTc2NzUyMTg3MCwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.61elfSp2ks7bZk4ffilunjQRdOHuDof_97qLk7EIIck	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-12-05 18:17:50.114+07	2025-12-05 17:17:50.114737+07	f
115	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMSIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQ5MzAxMDYsImV4cCI6MTc2NzUyMjEwNiwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.YplTbuv5KZEhA103VfDqS8V0EGUyWp7nDs44XMRkLN0	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-12-05 18:21:46.214+07	2025-12-05 17:21:46.214966+07	f
116	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMSIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQ5MzAxNjYsImV4cCI6MTc2NzUyMjE2NiwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.3zvdWHwLljUbUBbhqOgQgvWT9rrKFCfWZdJoVpBWHAo	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-12-05 18:22:46.599+07	2025-12-05 17:22:46.599815+07	f
117	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMSIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQ5MzAyNTMsImV4cCI6MTc2NzUyMjI1MywiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.fPzWQjE6wCmjZQT6U4LdNwCcjoINFgXqdZZiVLucaM4	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-12-05 18:24:13.101+07	2025-12-05 17:24:13.101728+07	f
118	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMSIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjQ5MzAzNDQsImV4cCI6MTc2NzUyMjM0NCwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.cHwQJaq3Kpyf-IOBcQJFyb_9dcbPGfwaazQJeKUe_zQ	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-12-05 18:25:44.8+07	2025-12-05 17:25:44.801493+07	f
119	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2NTE2NzE2MSwiZXhwIjoxNzY3NzU5MTYxLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.HVeUSc0KOwZpi9DJn9pnh1YUC8eo86wA7HjmgGILcLA	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-12-08 12:12:41.692+07	2025-12-08 11:12:41.693459+07	f
120	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2NTE3MTg0OCwiZXhwIjoxNzY3NzYzODQ4LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.WPIBP6dypyIhJi-3cvowUxEBNAxh3mqnV4k4x8xh_zU	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-12-08 13:30:48.433+07	2025-12-08 12:30:48.434739+07	f
121	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMSIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjUyMDMyNzksImV4cCI6MTc2Nzc5NTI3OSwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9._qoLqPsb5tCAgW9mHxPToS-1eWNMT-P4hFlpWEfwMXk	PostmanRuntime/7.49.1	::1	2025-12-08 22:14:39.509+07	2025-12-08 21:14:39.511056+07	f
122	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMSIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjUyMDMzMjYsImV4cCI6MTc2Nzc5NTMyNiwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.2YRmbT7_YrjEAL15XumP5xZ6whhssJSc97MAClPzu9E	PostmanRuntime/7.49.1	::1	2025-12-08 22:15:26.882+07	2025-12-08 21:15:26.883966+07	f
123	22	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMiIsInR5cCI6InJlZnJlc2giLCJpYXQiOjE3NjUyMDYyMjYsImV4cCI6MTc2Nzc5ODIyNiwiYXVkIjoiaGVhbGluZy53ZWJhcHAiLCJpc3MiOiJoZWFsaW5nLmFwaSJ9.XTezqFTUUy_l3TlVItokOCLCk8x3BrOdIEJdgOeufkk	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-12-08 23:03:46.282+07	2025-12-08 22:03:46.284552+07	f
12	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTkzMjU2NSwiZXhwIjoxNzYyNTI0NTY1LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.hB5SQ-kFZXqnvzDoNTp_TiJugnNV8gp151nsx86bBc0	PostmanRuntime/7.48.0	::1	2025-10-08 22:09:25.86+07	2025-10-08 21:09:25.860999+07	t
15	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTk4NzM2MiwiZXhwIjoxNzYyNTc5MzYyLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.0JNK2a--ATb03PWMyUmSiVKuIIbaLajOLzXKIEfNOOc	PostmanRuntime/7.48.0	::1	2025-10-09 13:22:42.234+07	2025-10-09 12:22:42.2355+07	t
17	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTk4ODI5NSwiZXhwIjoxNzYyNTgwMjk1LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.z4AdApXJxMOdLU6z0XGBZ2GHbMe-_eCFCi-iwjdJIzQ	PostmanRuntime/7.48.0	::1	2025-10-09 13:38:15.203+07	2025-10-09 12:38:15.204119+07	t
18	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc1OTk5MDI3MywiZXhwIjoxNzYyNTgyMjczLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.v3UEaak04oBpcGQI5D2RBpgT-80pibmA5gLWm315ZCI	PostmanRuntime/7.48.0	::1	2025-10-09 14:11:13.787+07	2025-10-09 13:11:13.788307+07	t
24	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDQxNzYzNywiZXhwIjoxNzYzMDA5NjM3LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.7ohWBBCWuDyiSqwSwTIHQAIe5CBYbWu7rZSWJXwIb5A	PostmanRuntime/7.48.0	::1	2025-10-14 12:53:57.851+07	2025-10-14 11:53:57.854381+07	t
26	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDQxOTA4OCwiZXhwIjoxNzYzMDExMDg4LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.YWlGBEVQjRN9xF2LbgOdUSY1XPixgzgtHdyCZSy-vV4	PostmanRuntime/7.48.0	::1	2025-10-14 13:18:08.278+07	2025-10-14 12:18:08.281166+07	t
27	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDQxOTE1MywiZXhwIjoxNzYzMDExMTUzLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.Y3Ooy_C21jvkeKwvtnWUYn_PUJz8SNJc3k6lu5viVUw	PostmanRuntime/7.48.0	::1	2025-10-14 13:19:13.112+07	2025-10-14 12:19:13.115035+07	t
29	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDQzNDIyNCwiZXhwIjoxNzYzMDI2MjI0LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.6cJN40CHZ9rBcBmClgfqiV95VRf-DXtIvoNqJ-kgcH8	PostmanRuntime/7.48.0	::1	2025-10-14 17:30:24.748+07	2025-10-14 16:30:24.751384+07	t
30	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDQzNDg0MCwiZXhwIjoxNzYzMDI2ODQwLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.msMVgIemOz74O_LBez8XzTYxVqGyvaV1U2Je82kq1tI	PostmanRuntime/7.48.0	::1	2025-10-14 17:40:40.051+07	2025-10-14 16:40:40.052566+07	t
34	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDUzMzE1NywiZXhwIjoxNzYzMTI1MTU3LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.-OrxY1THVTJekTBvLYbRq6zEAO89UQ2aBQhKCynXTMI	PostmanRuntime/7.48.0	::1	2025-10-15 20:59:17.129+07	2025-10-15 19:59:17.129996+07	t
36	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDUzNTYzMSwiZXhwIjoxNzYzMTI3NjMxLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.IKYaTx50n5oSFkfeNp4KlmXbeR17fLZ-J7S1fnRmOR4	PostmanRuntime/7.48.0	::1	2025-10-15 21:40:31.44+07	2025-10-15 20:40:31.440866+07	t
37	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDUzNTY2NiwiZXhwIjoxNzYzMTI3NjY2LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.OhzAbXhzevh5cUnldkoyXJMtF7LDqCJGjBuOWivyKdY	PostmanRuntime/7.48.0	::1	2025-10-15 21:41:06.145+07	2025-10-15 20:41:06.146918+07	t
40	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MDU5MzgzMywiZXhwIjoxNzYzMTg1ODMzLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.LGCctukQ25OtQD-5mXJO5yjo3sF97E1WUhBCKi3Dp68	PostmanRuntime/7.48.0	::1	2025-10-16 13:50:33.812+07	2025-10-16 12:50:33.814492+07	t
54	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MzQ3ODA1NywiZXhwIjoxNzY2MDcwMDU3LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.eW_QjQnZUmHexWpExZq-UvwY5fXko3nMoB1-GSb8vcg	PostmanRuntime/7.49.1	::1	2025-11-18 23:00:57.427+07	2025-11-18 22:00:57.429154+07	t
55	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MzQ3ODQ4OCwiZXhwIjoxNzY2MDcwNDg4LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.1dUGGFraXULo6f7D4RbjcjbLBdhZ6WZ9cRVqRTjGbCc	PostmanRuntime/7.49.1	::1	2025-11-18 23:08:08.166+07	2025-11-18 22:08:08.167825+07	t
57	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2MzU0NTIyNywiZXhwIjoxNzY2MTM3MjI3LCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.Kx08oWSyL_MMZe5_Z-cFBSB0xGEtgqnpdepdWETpAJM	PostmanRuntime/7.49.1	::1	2025-11-19 17:40:27.986+07	2025-11-19 16:40:27.989292+07	t
124	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCIsImlhdCI6MTc2NTUxNjY3MSwiZXhwIjoxNzY4MTA4NjcxLCJhdWQiOiJoZWFsaW5nLndlYmFwcCIsImlzcyI6ImhlYWxpbmcuYXBpIn0.Sa_NiMgioeyhlODBzrcQ0kcDctNqk4O9suPFr3hs0mw	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	::1	2025-12-12 13:17:51.626+07	2025-12-12 12:17:51.626765+07	f
\.


--
-- TOC entry 6645 (class 0 OID 17102)
-- Dependencies: 222
-- Data for Name: users; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.users (id, handle, email, phone, password_hash, role_primary, is_email_verified, status, created_at, updated_at) FROM stdin;
3	user3	\N	\N	$2b$10$cPtrL8rWsBNKM7ArQ3ZOUe760WcpeE/x0hgDPvfP3QbSyE0S3m1Ee	SEEKER	f	ACTIVE	2025-09-17 10:46:43.716438+07	2025-09-17 10:46:43.716438+07
4	phat	\N	\N	$2b$10$J6mNcwWi.CsAdqdQ/cNrk.ivl1AhaCJl40X.TKOM1TrQR1wwOcPve	SEEKER	f	ACTIVE	2025-09-18 18:17:06.316332+07	2025-09-18 18:17:06.316332+07
6	datbike	\N	\N	$2b$10$jB1N/SKHgIz7j/4Vc1FkDuR0IQAohBB0rFIrVEUU2B3/DDk39o0WK	SEEKER	f	ACTIVE	2025-09-23 19:17:05.339169+07	2025-09-23 19:17:05.339169+07
7	long999	\N	\N	$2b$10$qGL9t0CsXnOXLrEx08190.8OG6mlj0uSWeo5ZmuP.YQEi.gV/0IJi	EXPERT	f	ACTIVE	2025-09-23 19:17:15.781882+07	2025-09-23 19:38:29.346052+07
11	admin	admin@healing.com	\N	$2b$10$rOzJqQjQjQjQjQjQjQjQuOzJqQjQjQjQjQjQjQjQjQuOzJqQjQjQjQjQjQjQ	ADMIN	f	ACTIVE	2025-10-09 15:21:16.12008+07	2025-10-09 15:21:16.12008+07
13	admin1	admi3n@healing.com	\N	$2b$10$zUUXfxb0tNMV4dT4q6SE7exZox3lv15m3b42U2BIBW0f874iVc3Vu	ADMIN	f	ACTIVE	2025-10-09 15:29:57.954001+07	2025-10-09 15:29:57.954001+07
2	user2	\N	\N	$2b$10$QdcLOX0A18ESIb/cCgaEg.S07H8cWXlOMf0cvPPzkhuBfUaqPxopm	ADMIN	f	ACTIVE	2025-09-17 10:46:34.854443+07	2025-09-17 10:46:34.854443+07
15	skytua121_mhyldrq9	skytua121@gmail.com	\N	GOOGLE_OAUTH_ONLY	SEEKER	f	ACTIVE	2025-11-14 15:24:34.210636+07	2025-11-14 15:24:34.210636+07
16	2254810130_mi2m96uy	2254810130@vaa.edu.vn	\N	GOOGLE_OAUTH_ONLY	SEEKER	f	ACTIVE	2025-11-17 11:00:04.85883+07	2025-11-17 11:00:04.85883+07
17	expert_john	john@example.com	0901000001	hash123	EXPERT	f	ACTIVE	2025-11-18 22:49:07.333623+07	2025-11-18 22:49:07.333623+07
18	expert_linda	linda@example.com	0901000002	hash123	EXPERT	f	ACTIVE	2025-11-18 22:51:08.462332+07	2025-11-18 22:51:08.462332+07
19	expert_kevin	kevin@example.com	0901000003	hash123	EXPERT	f	ACTIVE	2025-11-18 22:51:16.311789+07	2025-11-18 22:51:16.311789+07
20	expert_sara	sara@example.com	0901000004	hash123	EXPERT	f	ACTIVE	2025-11-18 22:51:21.317694+07	2025-11-18 22:51:21.317694+07
8	hoang19	\N	\N	$2b$10$EX3NTgodP.af1ou1CLaBYuxvZ0MIsCaFrp18Qc/T6JS9ELCNB5cI.	SEEKER	f	SUSPENDED	2025-10-05 18:30:59.863278+07	2025-11-27 14:38:03.867207+07
9	hoang1999	\N	\N	$2b$10$owItQg6qIUYiJf0TKTTLMOiL0fHbwfGIYHgZOEPOfE1BNb/pcok1S	EXPERT	f	SUSPENDED	2025-10-08 19:21:54.937956+07	2025-11-27 14:38:14.645053+07
21	mendyu1	phat@gmail.com	0988776887	$2b$10$r5cPlO4wukdZHssAhLFm7.uthUJ8zOQpi2hyEeZz6SfxW47wWk/e6	SEEKER	f	ACTIVE	2025-11-21 19:32:55.645794+07	2025-12-05 16:29:25.66973+07
5	hoang	nguyenquyhoang.dh2022@gmail.com	\N	$2b$10$Gk/6MSlNiw7AAyKKvHeaiuELuGXf6TWx.GMgvqKayqdl2aNCES3OW	SEEKER	t	DELETED	2025-09-18 18:17:12.551167+07	2025-12-05 16:29:59.111567+07
22	quyhoang123	cryptovn2001@gmail.com	\N	$2b$10$28LCcH.0RfYSPT/LY9pM8u3YoojqgPdsLdSFjQGVT3Y/ZSDZDC4yq	SEEKER	f	ACTIVE	2025-12-08 22:03:17.12745+07	2025-12-08 22:03:17.12745+07
1	user1	skinss246@gmail.com	\N	$2b$10$wv8HZGlSwhMqi5GimaY2Eui2S4hhdzwKu1Gblrs8OXHMxOXYg2U6e	EXPERT	t	ACTIVE	2025-09-16 20:52:35.997355+07	2025-12-12 12:17:38.933662+07
\.


--
-- TOC entry 6669 (class 0 OID 17335)
-- Dependencies: 246
-- Data for Name: wallet_ledger; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.wallet_ledger (id, wallet_id, tx_type, amount, ref_table, ref_id, created_at) FROM stdin;
1	1	EARN	500000.00	TEST_CREDIT	1763722442782	2025-11-21 17:54:02.789396+07
3	1	EARN	500000.00	TEST_CREDIT	1763722511868	2025-11-21 17:55:11.876628+07
4	1	WITHDRAW	-200000.00	PAYOUT_REQUEST	1	2025-11-21 17:55:11.881242+07
5	1	EARN	200000.00	PAYOUT_REFUND	1	2025-11-21 17:55:11.931534+07
\.


--
-- TOC entry 6667 (class 0 OID 17320)
-- Dependencies: 244
-- Data for Name: wallets; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.wallets (id, owner_user_id, balance) FROM stdin;
1	1	1000000.00
\.


--
-- TOC entry 6770 (class 0 OID 19812)
-- Dependencies: 347
-- Data for Name: wellness_activities; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.wellness_activities (id, user_id, activity_type, title, description, duration_minutes, completed_at, mood_before, mood_after, effectiveness_rating, notes, suggested_by, metadata) FROM stdin;
1	21	exercise	\N	\N	5	2025-12-02 15:42:28.644385+07	terrible	great	3	\N	ai	{}
2	21	breathing	\N	\N	5	2025-12-02 15:59:30.289944+07	great	great	3	\N	ai	{}
\.


--
-- TOC entry 6863 (class 0 OID 0)
-- Dependencies: 354
-- Name: ai_chat_history_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.ai_chat_history_id_seq', 18, true);


--
-- TOC entry 6864 (class 0 OID 0)
-- Dependencies: 339
-- Name: ai_conversation_context_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.ai_conversation_context_id_seq', 3, true);


--
-- TOC entry 6865 (class 0 OID 0)
-- Dependencies: 334
-- Name: ai_personas_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.ai_personas_id_seq', 5, true);


--
-- TOC entry 6866 (class 0 OID 0)
-- Dependencies: 337
-- Name: ai_scheduled_notifications_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.ai_scheduled_notifications_id_seq', 2, true);


--
-- TOC entry 6867 (class 0 OID 0)
-- Dependencies: 365
-- Name: ai_suggestions_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.ai_suggestions_id_seq', 1, false);


--
-- TOC entry 6868 (class 0 OID 0)
-- Dependencies: 301
-- Name: audience_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.audience_id_seq', 1, false);


--
-- TOC entry 6869 (class 0 OID 0)
-- Dependencies: 265
-- Name: audit_logs_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.audit_logs_id_seq', 239, true);


--
-- TOC entry 6870 (class 0 OID 0)
-- Dependencies: 361
-- Name: behavior_patterns_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.behavior_patterns_id_seq', 1, false);


--
-- TOC entry 6871 (class 0 OID 0)
-- Dependencies: 329
-- Name: booking_fees_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.booking_fees_id_seq', 1, false);


--
-- TOC entry 6872 (class 0 OID 0)
-- Dependencies: 235
-- Name: bookings_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.bookings_id_seq', 26, true);


--
-- TOC entry 6873 (class 0 OID 0)
-- Dependencies: 270
-- Name: call_events_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.call_events_id_seq', 122, true);


--
-- TOC entry 6874 (class 0 OID 0)
-- Dependencies: 313
-- Name: call_metrics_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.call_metrics_id_seq', 1, false);


--
-- TOC entry 6875 (class 0 OID 0)
-- Dependencies: 315
-- Name: call_recordings_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.call_recordings_id_seq', 1, false);


--
-- TOC entry 6876 (class 0 OID 0)
-- Dependencies: 268
-- Name: call_sessions_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.call_sessions_id_seq', 51, true);


--
-- TOC entry 6877 (class 0 OID 0)
-- Dependencies: 311
-- Name: chat_attachments_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.chat_attachments_id_seq', 1, false);


--
-- TOC entry 6878 (class 0 OID 0)
-- Dependencies: 252
-- Name: chat_messages_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.chat_messages_id_seq', 3, true);


--
-- TOC entry 6879 (class 0 OID 0)
-- Dependencies: 317
-- Name: chat_thread_invitations_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.chat_thread_invitations_id_seq', 1, false);


--
-- TOC entry 6880 (class 0 OID 0)
-- Dependencies: 249
-- Name: chat_threads_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.chat_threads_id_seq', 6, true);


--
-- TOC entry 6881 (class 0 OID 0)
-- Dependencies: 257
-- Name: comments_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.comments_id_seq', 9, true);


--
-- TOC entry 6882 (class 0 OID 0)
-- Dependencies: 263
-- Name: consents_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.consents_id_seq', 1, false);


--
-- TOC entry 6883 (class 0 OID 0)
-- Dependencies: 372
-- Name: crisis_alerts_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.crisis_alerts_id_seq', 1, false);


--
-- TOC entry 6884 (class 0 OID 0)
-- Dependencies: 348
-- Name: daily_mood_checkins_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.daily_mood_checkins_id_seq', 1, true);


--
-- TOC entry 6885 (class 0 OID 0)
-- Dependencies: 325
-- Name: dispute_messages_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.dispute_messages_id_seq', 1, false);


--
-- TOC entry 6886 (class 0 OID 0)
-- Dependencies: 323
-- Name: disputes_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.disputes_id_seq', 1, false);


--
-- TOC entry 6887 (class 0 OID 0)
-- Dependencies: 304
-- Name: domains_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.domains_id_seq', 1, false);


--
-- TOC entry 6888 (class 0 OID 0)
-- Dependencies: 227
-- Name: email_verifications_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.email_verifications_id_seq', 14, true);


--
-- TOC entry 6889 (class 0 OID 0)
-- Dependencies: 341
-- Name: emotion_logs_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.emotion_logs_id_seq', 16, true);


--
-- TOC entry 6890 (class 0 OID 0)
-- Dependencies: 350
-- Name: emotion_patterns_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.emotion_patterns_id_seq', 1, false);


--
-- TOC entry 6891 (class 0 OID 0)
-- Dependencies: 233
-- Name: expert_availabilities_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.expert_availabilities_id_seq', 1, false);


--
-- TOC entry 6892 (class 0 OID 0)
-- Dependencies: 295
-- Name: expert_certifications_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.expert_certifications_id_seq', 1, false);


--
-- TOC entry 6893 (class 0 OID 0)
-- Dependencies: 293
-- Name: expert_education_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.expert_education_id_seq', 1, false);


--
-- TOC entry 6894 (class 0 OID 0)
-- Dependencies: 291
-- Name: expert_experience_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.expert_experience_id_seq', 1, false);


--
-- TOC entry 6895 (class 0 OID 0)
-- Dependencies: 299
-- Name: expert_media_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.expert_media_id_seq', 1, false);


--
-- TOC entry 6896 (class 0 OID 0)
-- Dependencies: 229
-- Name: expert_profiles_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.expert_profiles_id_seq', 7, true);


--
-- TOC entry 6897 (class 0 OID 0)
-- Dependencies: 231
-- Name: listener_profiles_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.listener_profiles_id_seq', 1, false);


--
-- TOC entry 6898 (class 0 OID 0)
-- Dependencies: 344
-- Name: mental_health_assessments_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.mental_health_assessments_id_seq', 1, true);


--
-- TOC entry 6899 (class 0 OID 0)
-- Dependencies: 261
-- Name: moderation_actions_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.moderation_actions_id_seq', 13, true);


--
-- TOC entry 6900 (class 0 OID 0)
-- Dependencies: 286
-- Name: oauth_users_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.oauth_users_id_seq', 2, true);


--
-- TOC entry 6901 (class 0 OID 0)
-- Dependencies: 374
-- Name: password_resets_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.password_resets_id_seq', 1, true);


--
-- TOC entry 6902 (class 0 OID 0)
-- Dependencies: 239
-- Name: payment_intents_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.payment_intents_id_seq', 17, true);


--
-- TOC entry 6903 (class 0 OID 0)
-- Dependencies: 241
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.payments_id_seq', 1, false);


--
-- TOC entry 6904 (class 0 OID 0)
-- Dependencies: 284
-- Name: payout_accounts_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.payout_accounts_id_seq', 2, true);


--
-- TOC entry 6905 (class 0 OID 0)
-- Dependencies: 307
-- Name: payout_requests_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.payout_requests_id_seq', 1, true);


--
-- TOC entry 6906 (class 0 OID 0)
-- Dependencies: 319
-- Name: platform_settings_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.platform_settings_id_seq', 5, true);


--
-- TOC entry 6907 (class 0 OID 0)
-- Dependencies: 274
-- Name: post_media_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.post_media_id_seq', 4, true);


--
-- TOC entry 6908 (class 0 OID 0)
-- Dependencies: 254
-- Name: posts_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.posts_id_seq', 13, true);


--
-- TOC entry 6909 (class 0 OID 0)
-- Dependencies: 363
-- Name: proactive_messages_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.proactive_messages_id_seq', 1, false);


--
-- TOC entry 6910 (class 0 OID 0)
-- Dependencies: 331
-- Name: product_reviews_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.product_reviews_id_seq', 1, false);


--
-- TOC entry 6911 (class 0 OID 0)
-- Dependencies: 327
-- Name: recurring_booking_templates_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.recurring_booking_templates_id_seq', 1, false);


--
-- TOC entry 6912 (class 0 OID 0)
-- Dependencies: 321
-- Name: refunds_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.refunds_id_seq', 1, false);


--
-- TOC entry 6913 (class 0 OID 0)
-- Dependencies: 259
-- Name: reports_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.reports_id_seq', 1, false);


--
-- TOC entry 6914 (class 0 OID 0)
-- Dependencies: 280
-- Name: reviews_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.reviews_id_seq', 2, true);


--
-- TOC entry 6915 (class 0 OID 0)
-- Dependencies: 309
-- Name: schema_migrations_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.schema_migrations_id_seq', 45, true);


--
-- TOC entry 6916 (class 0 OID 0)
-- Dependencies: 237
-- Name: session_notes_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.session_notes_id_seq', 1, false);


--
-- TOC entry 6917 (class 0 OID 0)
-- Dependencies: 288
-- Name: skills_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.skills_id_seq', 1, false);


--
-- TOC entry 6918 (class 0 OID 0)
-- Dependencies: 359
-- Name: sleep_logs_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.sleep_logs_id_seq', 1, false);


--
-- TOC entry 6919 (class 0 OID 0)
-- Dependencies: 247
-- Name: tips_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.tips_id_seq', 1, false);


--
-- TOC entry 6920 (class 0 OID 0)
-- Dependencies: 367
-- Name: user_activity_logs_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.user_activity_logs_id_seq', 1, false);


--
-- TOC entry 6921 (class 0 OID 0)
-- Dependencies: 225
-- Name: user_files_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.user_files_id_seq', 1, false);


--
-- TOC entry 6922 (class 0 OID 0)
-- Dependencies: 357
-- Name: user_schedules_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.user_schedules_id_seq', 1, true);


--
-- TOC entry 6923 (class 0 OID 0)
-- Dependencies: 282
-- Name: user_sessions_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.user_sessions_id_seq', 124, true);


--
-- TOC entry 6924 (class 0 OID 0)
-- Dependencies: 221
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.users_id_seq', 22, true);


--
-- TOC entry 6925 (class 0 OID 0)
-- Dependencies: 245
-- Name: wallet_ledger_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.wallet_ledger_id_seq', 5, true);


--
-- TOC entry 6926 (class 0 OID 0)
-- Dependencies: 243
-- Name: wallets_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.wallets_id_seq', 2, true);


--
-- TOC entry 6927 (class 0 OID 0)
-- Dependencies: 346
-- Name: wellness_activities_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.wellness_activities_id_seq', 2, true);


--
-- TOC entry 6316 (class 2606 OID 19906)
-- Name: ai_chat_history ai_chat_history_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.ai_chat_history
    ADD CONSTRAINT ai_chat_history_pkey PRIMARY KEY (id);


--
-- TOC entry 6283 (class 2606 OID 19592)
-- Name: ai_conversation_context ai_conversation_context_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.ai_conversation_context
    ADD CONSTRAINT ai_conversation_context_pkey PRIMARY KEY (id);


--
-- TOC entry 6285 (class 2606 OID 19594)
-- Name: ai_conversation_context ai_conversation_context_user_id_context_type_context_key_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.ai_conversation_context
    ADD CONSTRAINT ai_conversation_context_user_id_context_type_context_key_key UNIQUE (user_id, context_type, context_key);


--
-- TOC entry 6272 (class 2606 OID 19529)
-- Name: ai_personas ai_personas_name_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.ai_personas
    ADD CONSTRAINT ai_personas_name_key UNIQUE (name);


--
-- TOC entry 6274 (class 2606 OID 19527)
-- Name: ai_personas ai_personas_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.ai_personas
    ADD CONSTRAINT ai_personas_pkey PRIMARY KEY (id);


--
-- TOC entry 6279 (class 2606 OID 19570)
-- Name: ai_scheduled_notifications ai_scheduled_notifications_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.ai_scheduled_notifications
    ADD CONSTRAINT ai_scheduled_notifications_pkey PRIMARY KEY (id);


--
-- TOC entry 6339 (class 2606 OID 20020)
-- Name: ai_suggestions ai_suggestions_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.ai_suggestions
    ADD CONSTRAINT ai_suggestions_pkey PRIMARY KEY (id);


--
-- TOC entry 6191 (class 2606 OID 19011)
-- Name: audience audience_name_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.audience
    ADD CONSTRAINT audience_name_key UNIQUE (name);


--
-- TOC entry 6193 (class 2606 OID 19009)
-- Name: audience audience_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.audience
    ADD CONSTRAINT audience_pkey PRIMARY KEY (id);


--
-- TOC entry 6088 (class 2606 OID 17537)
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 6330 (class 2606 OID 19980)
-- Name: behavior_patterns behavior_patterns_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.behavior_patterns
    ADD CONSTRAINT behavior_patterns_pkey PRIMARY KEY (id);


--
-- TOC entry 6332 (class 2606 OID 19982)
-- Name: behavior_patterns behavior_patterns_user_id_pattern_type_pattern_name_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.behavior_patterns
    ADD CONSTRAINT behavior_patterns_user_id_pattern_type_pattern_name_key UNIQUE (user_id, pattern_type, pattern_name);


--
-- TOC entry 6255 (class 2606 OID 19458)
-- Name: booking_fees booking_fees_booking_id_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.booking_fees
    ADD CONSTRAINT booking_fees_booking_id_key UNIQUE (booking_id);


--
-- TOC entry 6257 (class 2606 OID 19456)
-- Name: booking_fees booking_fees_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.booking_fees
    ADD CONSTRAINT booking_fees_pkey PRIMARY KEY (id);


--
-- TOC entry 5975 (class 2606 OID 17244)
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (id);


--
-- TOC entry 6110 (class 2606 OID 18570)
-- Name: call_events call_events_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.call_events
    ADD CONSTRAINT call_events_pkey PRIMARY KEY (id);


--
-- TOC entry 6220 (class 2606 OID 19161)
-- Name: call_metrics call_metrics_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.call_metrics
    ADD CONSTRAINT call_metrics_pkey PRIMARY KEY (id);


--
-- TOC entry 6223 (class 2606 OID 19177)
-- Name: call_recordings call_recordings_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.call_recordings
    ADD CONSTRAINT call_recordings_pkey PRIMARY KEY (id);


--
-- TOC entry 6100 (class 2606 OID 18543)
-- Name: call_sessions call_sessions_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.call_sessions
    ADD CONSTRAINT call_sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 6217 (class 2606 OID 19146)
-- Name: chat_attachments chat_attachments_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_attachments
    ADD CONSTRAINT chat_attachments_pkey PRIMARY KEY (id);


--
-- TOC entry 6036 (class 2606 OID 17392)
-- Name: chat_members chat_members_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_members
    ADD CONSTRAINT chat_members_pkey PRIMARY KEY (thread_id, user_id);


--
-- TOC entry 6043 (class 2606 OID 17412)
-- Name: chat_messages chat_messages_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_messages
    ADD CONSTRAINT chat_messages_pkey PRIMARY KEY (id);


--
-- TOC entry 6097 (class 2606 OID 18251)
-- Name: chat_read_state chat_read_state_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_read_state
    ADD CONSTRAINT chat_read_state_pkey PRIMARY KEY (thread_id, user_id);


--
-- TOC entry 6226 (class 2606 OID 19195)
-- Name: chat_thread_invitations chat_thread_invitations_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_thread_invitations
    ADD CONSTRAINT chat_thread_invitations_pkey PRIMARY KEY (id);


--
-- TOC entry 6030 (class 2606 OID 17380)
-- Name: chat_threads chat_threads_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_threads
    ADD CONSTRAINT chat_threads_pkey PRIMARY KEY (id);


--
-- TOC entry 6122 (class 2606 OID 18684)
-- Name: comment_reactions comment_reactions_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.comment_reactions
    ADD CONSTRAINT comment_reactions_pkey PRIMARY KEY (comment_id, user_id);


--
-- TOC entry 6064 (class 2606 OID 17469)
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- TOC entry 6086 (class 2606 OID 17522)
-- Name: consents consents_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.consents
    ADD CONSTRAINT consents_pkey PRIMARY KEY (id);


--
-- TOC entry 6346 (class 2606 OID 20115)
-- Name: crisis_alerts crisis_alerts_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.crisis_alerts
    ADD CONSTRAINT crisis_alerts_pkey PRIMARY KEY (id);


--
-- TOC entry 6306 (class 2606 OID 19844)
-- Name: daily_mood_checkins daily_mood_checkins_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.daily_mood_checkins
    ADD CONSTRAINT daily_mood_checkins_pkey PRIMARY KEY (id);


--
-- TOC entry 6308 (class 2606 OID 19846)
-- Name: daily_mood_checkins daily_mood_checkins_user_id_checkin_date_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.daily_mood_checkins
    ADD CONSTRAINT daily_mood_checkins_user_id_checkin_date_key UNIQUE (user_id, checkin_date);


--
-- TOC entry 6246 (class 2606 OID 19399)
-- Name: dispute_messages dispute_messages_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.dispute_messages
    ADD CONSTRAINT dispute_messages_pkey PRIMARY KEY (id);


--
-- TOC entry 6240 (class 2606 OID 19366)
-- Name: disputes disputes_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.disputes
    ADD CONSTRAINT disputes_pkey PRIMARY KEY (id);


--
-- TOC entry 6198 (class 2606 OID 19037)
-- Name: domains domains_name_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.domains
    ADD CONSTRAINT domains_name_key UNIQUE (name);


--
-- TOC entry 6200 (class 2606 OID 19035)
-- Name: domains domains_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.domains
    ADD CONSTRAINT domains_pkey PRIMARY KEY (id);


--
-- TOC entry 5946 (class 2606 OID 17172)
-- Name: email_verifications email_verifications_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.email_verifications
    ADD CONSTRAINT email_verifications_pkey PRIMARY KEY (id);


--
-- TOC entry 6288 (class 2606 OID 19755)
-- Name: emotion_logs emotion_logs_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.emotion_logs
    ADD CONSTRAINT emotion_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 6311 (class 2606 OID 19864)
-- Name: emotion_patterns emotion_patterns_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.emotion_patterns
    ADD CONSTRAINT emotion_patterns_pkey PRIMARY KEY (id);


--
-- TOC entry 6313 (class 2606 OID 19866)
-- Name: emotion_patterns emotion_patterns_user_id_pattern_type_pattern_key_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.emotion_patterns
    ADD CONSTRAINT emotion_patterns_user_id_pattern_type_pattern_key_key UNIQUE (user_id, pattern_type, pattern_key);


--
-- TOC entry 6195 (class 2606 OID 19016)
-- Name: expert_audience expert_audience_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_audience
    ADD CONSTRAINT expert_audience_pkey PRIMARY KEY (expert_id, audience_id);


--
-- TOC entry 5970 (class 2606 OID 17225)
-- Name: expert_availabilities expert_availabilities_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_availabilities
    ADD CONSTRAINT expert_availabilities_pkey PRIMARY KEY (id);


--
-- TOC entry 6174 (class 2606 OID 18952)
-- Name: expert_certifications expert_certifications_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_certifications
    ADD CONSTRAINT expert_certifications_pkey PRIMARY KEY (id);


--
-- TOC entry 6202 (class 2606 OID 19042)
-- Name: expert_domain expert_domain_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_domain
    ADD CONSTRAINT expert_domain_pkey PRIMARY KEY (expert_id, domain_id);


--
-- TOC entry 6171 (class 2606 OID 18938)
-- Name: expert_education expert_education_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_education
    ADD CONSTRAINT expert_education_pkey PRIMARY KEY (id);


--
-- TOC entry 6168 (class 2606 OID 18924)
-- Name: expert_experience expert_experience_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_experience
    ADD CONSTRAINT expert_experience_pkey PRIMARY KEY (id);


--
-- TOC entry 6189 (class 2606 OID 18995)
-- Name: expert_media expert_media_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_media
    ADD CONSTRAINT expert_media_pkey PRIMARY KEY (id);


--
-- TOC entry 6177 (class 2606 OID 18965)
-- Name: expert_performance expert_performance_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_performance
    ADD CONSTRAINT expert_performance_pkey PRIMARY KEY (expert_id);


--
-- TOC entry 5952 (class 2606 OID 17190)
-- Name: expert_profiles expert_profiles_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_profiles
    ADD CONSTRAINT expert_profiles_pkey PRIMARY KEY (id);


--
-- TOC entry 5954 (class 2606 OID 17192)
-- Name: expert_profiles expert_profiles_user_id_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_profiles
    ADD CONSTRAINT expert_profiles_user_id_key UNIQUE (user_id);


--
-- TOC entry 6164 (class 2606 OID 18905)
-- Name: expert_skills expert_skills_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_skills
    ADD CONSTRAINT expert_skills_pkey PRIMARY KEY (expert_id, skill_id);


--
-- TOC entry 6183 (class 2606 OID 18980)
-- Name: expert_status expert_status_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_status
    ADD CONSTRAINT expert_status_pkey PRIMARY KEY (expert_id);


--
-- TOC entry 5966 (class 2606 OID 17207)
-- Name: listener_profiles listener_profiles_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.listener_profiles
    ADD CONSTRAINT listener_profiles_pkey PRIMARY KEY (id);


--
-- TOC entry 5968 (class 2606 OID 17209)
-- Name: listener_profiles listener_profiles_user_id_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.listener_profiles
    ADD CONSTRAINT listener_profiles_user_id_key UNIQUE (user_id);


--
-- TOC entry 6300 (class 2606 OID 19805)
-- Name: mental_health_assessments mental_health_assessments_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.mental_health_assessments
    ADD CONSTRAINT mental_health_assessments_pkey PRIMARY KEY (id);


--
-- TOC entry 6084 (class 2606 OID 17507)
-- Name: moderation_actions moderation_actions_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.moderation_actions
    ADD CONSTRAINT moderation_actions_pkey PRIMARY KEY (id);


--
-- TOC entry 5988 (class 2606 OID 18217)
-- Name: bookings no_overlap_per_expert; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.bookings
    ADD CONSTRAINT no_overlap_per_expert EXCLUDE USING gist (expert_id WITH =, time_slot WITH &&);


--
-- TOC entry 6156 (class 2606 OID 18882)
-- Name: oauth_users oauth_users_google_id_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.oauth_users
    ADD CONSTRAINT oauth_users_google_id_key UNIQUE (google_id);


--
-- TOC entry 6158 (class 2606 OID 18880)
-- Name: oauth_users oauth_users_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.oauth_users
    ADD CONSTRAINT oauth_users_pkey PRIMARY KEY (id);


--
-- TOC entry 6356 (class 2606 OID 20145)
-- Name: password_resets password_resets_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.password_resets
    ADD CONSTRAINT password_resets_pkey PRIMARY KEY (id);


--
-- TOC entry 6002 (class 2606 OID 17290)
-- Name: payment_intents payment_intents_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payment_intents
    ADD CONSTRAINT payment_intents_pkey PRIMARY KEY (id);


--
-- TOC entry 6004 (class 2606 OID 17292)
-- Name: payment_intents payment_intents_tx_ref_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payment_intents
    ADD CONSTRAINT payment_intents_tx_ref_key UNIQUE (tx_ref);


--
-- TOC entry 6009 (class 2606 OID 17313)
-- Name: payments payments_intent_id_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payments
    ADD CONSTRAINT payments_intent_id_key UNIQUE (intent_id);


--
-- TOC entry 6011 (class 2606 OID 17311)
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- TOC entry 6152 (class 2606 OID 18849)
-- Name: payout_accounts payout_accounts_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payout_accounts
    ADD CONSTRAINT payout_accounts_pkey PRIMARY KEY (id);


--
-- TOC entry 6210 (class 2606 OID 19067)
-- Name: payout_requests payout_requests_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payout_requests
    ADD CONSTRAINT payout_requests_pkey PRIMARY KEY (id);


--
-- TOC entry 6230 (class 2606 OID 19313)
-- Name: platform_settings platform_settings_key_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.platform_settings
    ADD CONSTRAINT platform_settings_key_key UNIQUE (key);


--
-- TOC entry 6232 (class 2606 OID 19311)
-- Name: platform_settings platform_settings_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.platform_settings
    ADD CONSTRAINT platform_settings_pkey PRIMARY KEY (id);


--
-- TOC entry 6118 (class 2606 OID 18633)
-- Name: post_audience post_audience_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_audience
    ADD CONSTRAINT post_audience_pkey PRIMARY KEY (post_id, user_id);


--
-- TOC entry 6125 (class 2606 OID 18706)
-- Name: post_files post_files_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_files
    ADD CONSTRAINT post_files_pkey PRIMARY KEY (post_id, file_id);


--
-- TOC entry 6120 (class 2606 OID 18658)
-- Name: post_media post_media_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_media
    ADD CONSTRAINT post_media_pkey PRIMARY KEY (id);


--
-- TOC entry 6062 (class 2606 OID 17448)
-- Name: post_reactions post_reactions_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_reactions
    ADD CONSTRAINT post_reactions_pkey PRIMARY KEY (post_id, user_id);


--
-- TOC entry 6128 (class 2606 OID 18723)
-- Name: post_saves post_saves_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_saves
    ADD CONSTRAINT post_saves_pkey PRIMARY KEY (user_id, post_id);


--
-- TOC entry 6057 (class 2606 OID 17434)
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- TOC entry 6337 (class 2606 OID 20000)
-- Name: proactive_messages proactive_messages_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.proactive_messages
    ADD CONSTRAINT proactive_messages_pkey PRIMARY KEY (id);


--
-- TOC entry 6130 (class 2606 OID 18772)
-- Name: processed_events processed_events_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.processed_events
    ADD CONSTRAINT processed_events_pkey PRIMARY KEY (idempotency_key);


--
-- TOC entry 6264 (class 2606 OID 19482)
-- Name: product_reviews product_reviews_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.product_reviews
    ADD CONSTRAINT product_reviews_pkey PRIMARY KEY (id);


--
-- TOC entry 6253 (class 2606 OID 19428)
-- Name: recurring_booking_templates recurring_booking_templates_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.recurring_booking_templates
    ADD CONSTRAINT recurring_booking_templates_pkey PRIMARY KEY (id);


--
-- TOC entry 6238 (class 2606 OID 19331)
-- Name: refunds refunds_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.refunds
    ADD CONSTRAINT refunds_pkey PRIMARY KEY (id);


--
-- TOC entry 6082 (class 2606 OID 17490)
-- Name: reports reports_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.reports
    ADD CONSTRAINT reports_pkey PRIMARY KEY (id);


--
-- TOC entry 6141 (class 2606 OID 18804)
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- TOC entry 6143 (class 2606 OID 18864)
-- Name: reviews reviews_user_booking_unique; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.reviews
    ADD CONSTRAINT reviews_user_booking_unique UNIQUE (user_id, booking_id);


--
-- TOC entry 6213 (class 2606 OID 19079)
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (id);


--
-- TOC entry 6215 (class 2606 OID 19081)
-- Name: schema_migrations schema_migrations_version_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.schema_migrations
    ADD CONSTRAINT schema_migrations_version_key UNIQUE (version);


--
-- TOC entry 5990 (class 2606 OID 17268)
-- Name: session_notes session_notes_booking_id_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.session_notes
    ADD CONSTRAINT session_notes_booking_id_key UNIQUE (booking_id);


--
-- TOC entry 5992 (class 2606 OID 17266)
-- Name: session_notes session_notes_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.session_notes
    ADD CONSTRAINT session_notes_pkey PRIMARY KEY (id);


--
-- TOC entry 6160 (class 2606 OID 18899)
-- Name: skills skills_name_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.skills
    ADD CONSTRAINT skills_name_key UNIQUE (name);


--
-- TOC entry 6162 (class 2606 OID 18897)
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (id);


--
-- TOC entry 6326 (class 2606 OID 19959)
-- Name: sleep_logs sleep_logs_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.sleep_logs
    ADD CONSTRAINT sleep_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 6328 (class 2606 OID 19961)
-- Name: sleep_logs sleep_logs_user_id_date_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.sleep_logs
    ADD CONSTRAINT sleep_logs_user_id_date_key UNIQUE (user_id, date);


--
-- TOC entry 6028 (class 2606 OID 17360)
-- Name: tips tips_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.tips
    ADD CONSTRAINT tips_pkey PRIMARY KEY (id);


--
-- TOC entry 5950 (class 2606 OID 17555)
-- Name: email_verifications uq_email_verif_user_all; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.email_verifications
    ADD CONSTRAINT uq_email_verif_user_all UNIQUE (user_id, email);


--
-- TOC entry 6266 (class 2606 OID 19484)
-- Name: product_reviews uq_product_reviews_product_user; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.product_reviews
    ADD CONSTRAINT uq_product_reviews_product_user UNIQUE (product_id, user_id);


--
-- TOC entry 6344 (class 2606 OID 20036)
-- Name: user_activity_logs user_activity_logs_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_activity_logs
    ADD CONSTRAINT user_activity_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 6277 (class 2606 OID 19547)
-- Name: user_ai_settings user_ai_settings_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_ai_settings
    ADD CONSTRAINT user_ai_settings_pkey PRIMARY KEY (user_id);


--
-- TOC entry 6270 (class 2606 OID 19500)
-- Name: user_blocks user_blocks_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_blocks
    ADD CONSTRAINT user_blocks_pkey PRIMARY KEY (blocker_id, blocked_id);


--
-- TOC entry 5944 (class 2606 OID 17156)
-- Name: user_files user_files_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_files
    ADD CONSTRAINT user_files_pkey PRIMARY KEY (id);


--
-- TOC entry 6116 (class 2606 OID 18608)
-- Name: user_follows user_follows_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_follows
    ADD CONSTRAINT user_follows_pkey PRIMARY KEY (follower_id, followee_id);


--
-- TOC entry 6296 (class 2606 OID 19780)
-- Name: user_mental_state user_mental_state_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_mental_state
    ADD CONSTRAINT user_mental_state_pkey PRIMARY KEY (user_id);


--
-- TOC entry 5940 (class 2606 OID 17130)
-- Name: user_profiles user_profiles_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_profiles
    ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (user_id);


--
-- TOC entry 5942 (class 2606 OID 17140)
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role);


--
-- TOC entry 6323 (class 2606 OID 19941)
-- Name: user_schedules user_schedules_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_schedules
    ADD CONSTRAINT user_schedules_pkey PRIMARY KEY (id);


--
-- TOC entry 6150 (class 2606 OID 18831)
-- Name: user_sessions user_sessions_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_sessions
    ADD CONSTRAINT user_sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 5931 (class 2606 OID 17118)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 5933 (class 2606 OID 17116)
-- Name: users users_handle_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.users
    ADD CONSTRAINT users_handle_key UNIQUE (handle);


--
-- TOC entry 5935 (class 2606 OID 18776)
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- TOC entry 5937 (class 2606 OID 17114)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 6026 (class 2606 OID 17344)
-- Name: wallet_ledger wallet_ledger_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.wallet_ledger
    ADD CONSTRAINT wallet_ledger_pkey PRIMARY KEY (id);


--
-- TOC entry 6017 (class 2606 OID 17328)
-- Name: wallets wallets_owner_user_id_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.wallets
    ADD CONSTRAINT wallets_owner_user_id_key UNIQUE (owner_user_id);


--
-- TOC entry 6019 (class 2606 OID 17326)
-- Name: wallets wallets_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.wallets
    ADD CONSTRAINT wallets_pkey PRIMARY KEY (id);


--
-- TOC entry 6304 (class 2606 OID 19824)
-- Name: wellness_activities wellness_activities_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.wellness_activities
    ADD CONSTRAINT wellness_activities_pkey PRIMARY KEY (id);


--
-- TOC entry 6341 (class 1259 OID 20051)
-- Name: idx_activity_type; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_activity_type ON app.user_activity_logs USING btree (activity_type, created_at DESC);


--
-- TOC entry 6342 (class 1259 OID 20050)
-- Name: idx_activity_user_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_activity_user_time ON app.user_activity_logs USING btree (user_id, created_at DESC);


--
-- TOC entry 6317 (class 1259 OID 19918)
-- Name: idx_ai_chat_recent; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_ai_chat_recent ON app.ai_chat_history USING btree (created_at DESC);


--
-- TOC entry 6318 (class 1259 OID 19917)
-- Name: idx_ai_chat_user_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_ai_chat_user_time ON app.ai_chat_history USING btree (user_id, created_at DESC);


--
-- TOC entry 6286 (class 1259 OID 19603)
-- Name: idx_ai_context_user; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_ai_context_user ON app.ai_conversation_context USING btree (user_id, context_type);


--
-- TOC entry 6280 (class 1259 OID 19602)
-- Name: idx_ai_notifications_pending; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_ai_notifications_pending ON app.ai_scheduled_notifications USING btree (scheduled_at) WHERE (is_sent = false);


--
-- TOC entry 6281 (class 1259 OID 19601)
-- Name: idx_ai_notifications_user_scheduled; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_ai_notifications_user_scheduled ON app.ai_scheduled_notifications USING btree (user_id, scheduled_at) WHERE (is_sent = false);


--
-- TOC entry 6297 (class 1259 OID 19879)
-- Name: idx_assessments_risk; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_assessments_risk ON app.mental_health_assessments USING btree (risk_level, assessed_at DESC) WHERE (risk_level = ANY (ARRAY['high'::text, 'critical'::text]));


--
-- TOC entry 6298 (class 1259 OID 19878)
-- Name: idx_assessments_user_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_assessments_user_time ON app.mental_health_assessments USING btree (user_id, assessed_at DESC);


--
-- TOC entry 6089 (class 1259 OID 18593)
-- Name: idx_audit_action_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_audit_action_time ON app.audit_logs USING btree (action, created_at DESC);


--
-- TOC entry 6090 (class 1259 OID 19129)
-- Name: idx_audit_logs_created_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_audit_logs_created_at ON app.audit_logs USING btree (created_at DESC);


--
-- TOC entry 6091 (class 1259 OID 19128)
-- Name: idx_audit_logs_resource; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_audit_logs_resource ON app.audit_logs USING btree (resource, resource_id);


--
-- TOC entry 6092 (class 1259 OID 20096)
-- Name: idx_audit_logs_user_created; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_audit_logs_user_created ON app.audit_logs USING btree (user_id, created_at);


--
-- TOC entry 6093 (class 1259 OID 19127)
-- Name: idx_audit_logs_user_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_audit_logs_user_id ON app.audit_logs USING btree (user_id);


--
-- TOC entry 6094 (class 1259 OID 18591)
-- Name: idx_audit_time_desc; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_audit_time_desc ON app.audit_logs USING btree (created_at DESC);


--
-- TOC entry 6095 (class 1259 OID 18592)
-- Name: idx_audit_user_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_audit_user_time ON app.audit_logs USING btree (user_id, created_at DESC);


--
-- TOC entry 5971 (class 1259 OID 17542)
-- Name: idx_avail_expert; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_avail_expert ON app.expert_availabilities USING btree (expert_id, start_at);


--
-- TOC entry 6333 (class 1259 OID 20046)
-- Name: idx_behavior_user_type; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_behavior_user_type ON app.behavior_patterns USING btree (user_id, pattern_type);


--
-- TOC entry 5976 (class 1259 OID 17543)
-- Name: idx_booking_expert; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_booking_expert ON app.bookings USING btree (expert_id, start_at);


--
-- TOC entry 6258 (class 1259 OID 19464)
-- Name: idx_booking_fees_booking; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_booking_fees_booking ON app.booking_fees USING btree (booking_id);


--
-- TOC entry 5977 (class 1259 OID 17544)
-- Name: idx_booking_user; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_booking_user ON app.bookings USING btree (user_id, start_at);


--
-- TOC entry 5978 (class 1259 OID 19098)
-- Name: idx_bookings_created_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_bookings_created_at ON app.bookings USING btree (created_at DESC);


--
-- TOC entry 5979 (class 1259 OID 20083)
-- Name: idx_bookings_expert_created; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_bookings_expert_created ON app.bookings USING btree (expert_id, created_at);


--
-- TOC entry 5980 (class 1259 OID 19096)
-- Name: idx_bookings_expert_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_bookings_expert_id ON app.bookings USING btree (expert_id);


--
-- TOC entry 5981 (class 1259 OID 19099)
-- Name: idx_bookings_start_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_bookings_start_at ON app.bookings USING btree (start_at);


--
-- TOC entry 5982 (class 1259 OID 19097)
-- Name: idx_bookings_status; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_bookings_status ON app.bookings USING btree (status);


--
-- TOC entry 5983 (class 1259 OID 20082)
-- Name: idx_bookings_status_created; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_bookings_status_created ON app.bookings USING btree (status, created_at);


--
-- TOC entry 6928 (class 0 OID 0)
-- Dependencies: 5983
-- Name: INDEX idx_bookings_status_created; Type: COMMENT; Schema: app; Owner: postgres
--

COMMENT ON INDEX app.idx_bookings_status_created IS 'For booking analytics by status and date';


--
-- TOC entry 5984 (class 1259 OID 20084)
-- Name: idx_bookings_user_created; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_bookings_user_created ON app.bookings USING btree (user_id, created_at);


--
-- TOC entry 5985 (class 1259 OID 19095)
-- Name: idx_bookings_user_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_bookings_user_id ON app.bookings USING btree (user_id);


--
-- TOC entry 5986 (class 1259 OID 18793)
-- Name: idx_bookings_user_status; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_bookings_user_status ON app.bookings USING btree (user_id, status, start_at DESC);


--
-- TOC entry 6101 (class 1259 OID 18586)
-- Name: idx_call_callee_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_call_callee_time ON app.call_sessions USING btree (callee_id, started_at DESC);


--
-- TOC entry 6102 (class 1259 OID 18585)
-- Name: idx_call_caller_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_call_caller_time ON app.call_sessions USING btree (caller_id, started_at DESC);


--
-- TOC entry 6111 (class 1259 OID 18601)
-- Name: idx_call_events_call_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_call_events_call_at ON app.call_events USING btree (call_id, at);


--
-- TOC entry 6112 (class 1259 OID 18597)
-- Name: idx_call_events_call_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_call_events_call_time ON app.call_events USING btree (call_id, at DESC);


--
-- TOC entry 6221 (class 1259 OID 19167)
-- Name: idx_call_metrics_call_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_call_metrics_call_id ON app.call_metrics USING btree (call_id);


--
-- TOC entry 6224 (class 1259 OID 19183)
-- Name: idx_call_recordings_call_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_call_recordings_call_id ON app.call_recordings USING btree (call_id);


--
-- TOC entry 6103 (class 1259 OID 20077)
-- Name: idx_call_sessions_started_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_call_sessions_started_at ON app.call_sessions USING btree (started_at DESC);


--
-- TOC entry 6104 (class 1259 OID 20076)
-- Name: idx_call_sessions_status; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_call_sessions_status ON app.call_sessions USING btree (status);


--
-- TOC entry 6105 (class 1259 OID 18602)
-- Name: idx_call_sessions_thread_start; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_call_sessions_thread_start ON app.call_sessions USING btree (thread_id, started_at);


--
-- TOC entry 6106 (class 1259 OID 18596)
-- Name: idx_call_thread_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_call_thread_time ON app.call_sessions USING btree (thread_id, started_at DESC);


--
-- TOC entry 6107 (class 1259 OID 18559)
-- Name: idx_call_user_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_call_user_time ON app.call_sessions USING btree (caller_id, started_at DESC);


--
-- TOC entry 6108 (class 1259 OID 18560)
-- Name: idx_call_user_time2; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_call_user_time2 ON app.call_sessions USING btree (callee_id, started_at DESC);


--
-- TOC entry 6218 (class 1259 OID 19152)
-- Name: idx_chat_attachments_message_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_attachments_message_id ON app.chat_attachments USING btree (message_id);


--
-- TOC entry 6037 (class 1259 OID 19118)
-- Name: idx_chat_members_thread_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_members_thread_id ON app.chat_members USING btree (thread_id);


--
-- TOC entry 6038 (class 1259 OID 18243)
-- Name: idx_chat_members_thread_user; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_members_thread_user ON app.chat_members USING btree (thread_id, user_id);


--
-- TOC entry 6039 (class 1259 OID 19119)
-- Name: idx_chat_members_user_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_members_user_id ON app.chat_members USING btree (user_id);


--
-- TOC entry 6044 (class 1259 OID 19122)
-- Name: idx_chat_messages_created_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_messages_created_at ON app.chat_messages USING btree (created_at DESC);


--
-- TOC entry 6045 (class 1259 OID 19153)
-- Name: idx_chat_messages_deleted; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_messages_deleted ON app.chat_messages USING btree (deleted_at);


--
-- TOC entry 6046 (class 1259 OID 19121)
-- Name: idx_chat_messages_sender_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_messages_sender_id ON app.chat_messages USING btree (sender_id);


--
-- TOC entry 6047 (class 1259 OID 18244)
-- Name: idx_chat_messages_thread_created; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_messages_thread_created ON app.chat_messages USING btree (thread_id, created_at DESC);


--
-- TOC entry 6048 (class 1259 OID 19120)
-- Name: idx_chat_messages_thread_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_messages_thread_id ON app.chat_messages USING btree (thread_id);


--
-- TOC entry 6049 (class 1259 OID 18598)
-- Name: idx_chat_messages_thread_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_messages_thread_time ON app.chat_messages USING btree (thread_id, created_at DESC);


--
-- TOC entry 6098 (class 1259 OID 18600)
-- Name: idx_chat_read_state_thread_user; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_read_state_thread_user ON app.chat_read_state USING btree (thread_id, user_id);


--
-- TOC entry 6227 (class 1259 OID 19212)
-- Name: idx_chat_thread_invitations_invitee; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_thread_invitations_invitee ON app.chat_thread_invitations USING btree (invitee_id);


--
-- TOC entry 6228 (class 1259 OID 19211)
-- Name: idx_chat_thread_invitations_thread; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_thread_invitations_thread ON app.chat_thread_invitations USING btree (thread_id);


--
-- TOC entry 6031 (class 1259 OID 19116)
-- Name: idx_chat_threads_booking_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_threads_booking_id ON app.chat_threads USING btree (booking_id) WHERE (booking_id IS NOT NULL);


--
-- TOC entry 6032 (class 1259 OID 19117)
-- Name: idx_chat_threads_last_message_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_threads_last_message_at ON app.chat_threads USING btree (last_message_at DESC);


--
-- TOC entry 6033 (class 1259 OID 18245)
-- Name: idx_chat_threads_last_msg; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_threads_last_msg ON app.chat_threads USING btree (last_message_at DESC);


--
-- TOC entry 6034 (class 1259 OID 19213)
-- Name: idx_chat_threads_name; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_chat_threads_name ON app.chat_threads USING btree (name);


--
-- TOC entry 6309 (class 1259 OID 19882)
-- Name: idx_checkins_user_date; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_checkins_user_date ON app.daily_mood_checkins USING btree (user_id, checkin_date DESC);


--
-- TOC entry 6065 (class 1259 OID 19111)
-- Name: idx_comments_author_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_comments_author_id ON app.comments USING btree (author_id);


--
-- TOC entry 6066 (class 1259 OID 19113)
-- Name: idx_comments_created_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_comments_created_at ON app.comments USING btree (created_at DESC);


--
-- TOC entry 6067 (class 1259 OID 19239)
-- Name: idx_comments_moderation_status; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_comments_moderation_status ON app.comments USING btree (moderation_status);


--
-- TOC entry 6068 (class 1259 OID 18792)
-- Name: idx_comments_parent_created_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_comments_parent_created_at ON app.comments USING btree (post_id, parent_id, created_at DESC);


--
-- TOC entry 6069 (class 1259 OID 19112)
-- Name: idx_comments_parent_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_comments_parent_id ON app.comments USING btree (parent_id) WHERE (parent_id IS NOT NULL);


--
-- TOC entry 6070 (class 1259 OID 17549)
-- Name: idx_comments_post; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_comments_post ON app.comments USING btree (post_id, created_at);


--
-- TOC entry 6071 (class 1259 OID 20090)
-- Name: idx_comments_post_created; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_comments_post_created ON app.comments USING btree (post_id, created_at);


--
-- TOC entry 6072 (class 1259 OID 18754)
-- Name: idx_comments_post_created_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_comments_post_created_at ON app.comments USING btree (post_id, created_at DESC);


--
-- TOC entry 6073 (class 1259 OID 19110)
-- Name: idx_comments_post_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_comments_post_id ON app.comments USING btree (post_id);


--
-- TOC entry 6074 (class 1259 OID 18755)
-- Name: idx_comments_post_parent_created_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_comments_post_parent_created_at ON app.comments USING btree (post_id, parent_id, created_at DESC);


--
-- TOC entry 6075 (class 1259 OID 18594)
-- Name: idx_comments_post_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_comments_post_time ON app.comments USING btree (post_id, created_at DESC);


--
-- TOC entry 6347 (class 1259 OID 20129)
-- Name: idx_crisis_alerts_created_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_crisis_alerts_created_at ON app.crisis_alerts USING btree (created_at DESC);


--
-- TOC entry 6348 (class 1259 OID 20130)
-- Name: idx_crisis_alerts_pending_severity; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_crisis_alerts_pending_severity ON app.crisis_alerts USING btree (status, severity, created_at) WHERE ((status)::text = 'pending'::text);


--
-- TOC entry 6349 (class 1259 OID 20128)
-- Name: idx_crisis_alerts_severity; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_crisis_alerts_severity ON app.crisis_alerts USING btree (severity);


--
-- TOC entry 6350 (class 1259 OID 20127)
-- Name: idx_crisis_alerts_status; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_crisis_alerts_status ON app.crisis_alerts USING btree (status);


--
-- TOC entry 6351 (class 1259 OID 20126)
-- Name: idx_crisis_alerts_user_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_crisis_alerts_user_id ON app.crisis_alerts USING btree (user_id);


--
-- TOC entry 6247 (class 1259 OID 19410)
-- Name: idx_dispute_messages_dispute; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_dispute_messages_dispute ON app.dispute_messages USING btree (dispute_id);


--
-- TOC entry 6241 (class 1259 OID 19387)
-- Name: idx_disputes_booking; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_disputes_booking ON app.disputes USING btree (booking_id);


--
-- TOC entry 6242 (class 1259 OID 20095)
-- Name: idx_disputes_created_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_disputes_created_at ON app.disputes USING btree (created_at);


--
-- TOC entry 6243 (class 1259 OID 19388)
-- Name: idx_disputes_raised_by; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_disputes_raised_by ON app.disputes USING btree (raised_by);


--
-- TOC entry 6244 (class 1259 OID 19389)
-- Name: idx_disputes_status; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_disputes_status ON app.disputes USING btree (status);


--
-- TOC entry 5947 (class 1259 OID 18219)
-- Name: idx_email_verif_user_created; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_email_verif_user_created ON app.email_verifications USING btree (user_id, email, created_at DESC);


--
-- TOC entry 6289 (class 1259 OID 19875)
-- Name: idx_emotion_logs_detected; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_emotion_logs_detected ON app.emotion_logs USING btree (detected_at DESC);


--
-- TOC entry 6290 (class 1259 OID 19874)
-- Name: idx_emotion_logs_source; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_emotion_logs_source ON app.emotion_logs USING btree (source, detected_at DESC);


--
-- TOC entry 6291 (class 1259 OID 19873)
-- Name: idx_emotion_logs_user_emotion; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_emotion_logs_user_emotion ON app.emotion_logs USING btree (user_id, emotion);


--
-- TOC entry 6292 (class 1259 OID 19872)
-- Name: idx_emotion_logs_user_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_emotion_logs_user_time ON app.emotion_logs USING btree (user_id, detected_at DESC);


--
-- TOC entry 6196 (class 1259 OID 20413)
-- Name: idx_expert_audience_expert_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_audience_expert_id ON app.expert_audience USING btree (expert_id);


--
-- TOC entry 5972 (class 1259 OID 19093)
-- Name: idx_expert_availabilities_expert_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_availabilities_expert_id ON app.expert_availabilities USING btree (expert_id);


--
-- TOC entry 5973 (class 1259 OID 19094)
-- Name: idx_expert_availabilities_start_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_availabilities_start_at ON app.expert_availabilities USING btree (start_at);


--
-- TOC entry 6175 (class 1259 OID 20410)
-- Name: idx_expert_certifications_expert_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_certifications_expert_id ON app.expert_certifications USING btree (expert_id);


--
-- TOC entry 6203 (class 1259 OID 20414)
-- Name: idx_expert_domain_expert_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_domain_expert_id ON app.expert_domain USING btree (expert_id);


--
-- TOC entry 6172 (class 1259 OID 20411)
-- Name: idx_expert_education_expert_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_education_expert_id ON app.expert_education USING btree (expert_id);


--
-- TOC entry 6169 (class 1259 OID 20412)
-- Name: idx_expert_experience_expert_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_experience_expert_id ON app.expert_experience USING btree (expert_id);


--
-- TOC entry 6178 (class 1259 OID 20405)
-- Name: idx_expert_performance_completion; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_performance_completion ON app.expert_performance USING btree (completion_rate DESC);


--
-- TOC entry 6179 (class 1259 OID 20402)
-- Name: idx_expert_performance_response; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_performance_response ON app.expert_performance USING btree (response_time_avg);


--
-- TOC entry 6180 (class 1259 OID 20404)
-- Name: idx_expert_performance_reviews; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_performance_reviews ON app.expert_performance USING btree (total_reviews DESC);


--
-- TOC entry 6181 (class 1259 OID 20401)
-- Name: idx_expert_performance_sessions; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_performance_sessions ON app.expert_performance USING btree (total_sessions DESC);


--
-- TOC entry 5955 (class 1259 OID 20398)
-- Name: idx_expert_profiles_intro_trgm; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_profiles_intro_trgm ON app.expert_profiles USING gin (intro public.gin_trgm_ops);


--
-- TOC entry 5956 (class 1259 OID 20406)
-- Name: idx_expert_profiles_kyc_rating; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_profiles_kyc_rating ON app.expert_profiles USING btree (kyc_status, rating_avg DESC NULLS LAST);


--
-- TOC entry 5957 (class 1259 OID 19091)
-- Name: idx_expert_profiles_kyc_status; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_profiles_kyc_status ON app.expert_profiles USING btree (kyc_status);


--
-- TOC entry 5958 (class 1259 OID 20400)
-- Name: idx_expert_profiles_price; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_profiles_price ON app.expert_profiles USING btree (price_per_session);


--
-- TOC entry 5959 (class 1259 OID 20399)
-- Name: idx_expert_profiles_rating; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_profiles_rating ON app.expert_profiles USING btree (rating_avg DESC NULLS LAST);


--
-- TOC entry 5960 (class 1259 OID 19092)
-- Name: idx_expert_profiles_rating_avg; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_profiles_rating_avg ON app.expert_profiles USING btree (rating_avg DESC);


--
-- TOC entry 6929 (class 0 OID 0)
-- Dependencies: 5960
-- Name: INDEX idx_expert_profiles_rating_avg; Type: COMMENT; Schema: app; Owner: postgres
--

COMMENT ON INDEX app.idx_expert_profiles_rating_avg IS 'Index for sorting experts by rating';


--
-- TOC entry 5961 (class 1259 OID 20132)
-- Name: idx_expert_profiles_search; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_profiles_search ON app.expert_profiles USING btree (rating_avg DESC NULLS LAST) INCLUDE (price_per_session, intro);


--
-- TOC entry 5962 (class 1259 OID 20131)
-- Name: idx_expert_profiles_specialties_gin; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_profiles_specialties_gin ON app.expert_profiles USING gin (specialties);


--
-- TOC entry 6930 (class 0 OID 0)
-- Dependencies: 5962
-- Name: INDEX idx_expert_profiles_specialties_gin; Type: COMMENT; Schema: app; Owner: postgres
--

COMMENT ON INDEX app.idx_expert_profiles_specialties_gin IS 'GIN index for fast array containment queries on specialties';


--
-- TOC entry 5963 (class 1259 OID 19090)
-- Name: idx_expert_profiles_user_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_profiles_user_id ON app.expert_profiles USING btree (user_id);


--
-- TOC entry 6165 (class 1259 OID 20408)
-- Name: idx_expert_skills_expert_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_skills_expert_id ON app.expert_skills USING btree (expert_id);


--
-- TOC entry 6166 (class 1259 OID 20409)
-- Name: idx_expert_skills_skill_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_skills_skill_id ON app.expert_skills USING btree (skill_id);


--
-- TOC entry 5964 (class 1259 OID 17541)
-- Name: idx_expert_specs; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_specs ON app.expert_profiles USING gin (specialties);


--
-- TOC entry 6184 (class 1259 OID 20403)
-- Name: idx_expert_status_active; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_status_active ON app.expert_status USING btree (active_score DESC);


--
-- TOC entry 6185 (class 1259 OID 20133)
-- Name: idx_expert_status_active_score; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_status_active_score ON app.expert_status USING btree (active_score DESC);


--
-- TOC entry 6186 (class 1259 OID 20134)
-- Name: idx_expert_status_expert_id_score; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_status_expert_id_score ON app.expert_status USING btree (expert_id, active_score DESC);


--
-- TOC entry 6187 (class 1259 OID 20407)
-- Name: idx_expert_status_online; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_expert_status_online ON app.expert_status USING btree (is_online, last_active_at DESC NULLS LAST);


--
-- TOC entry 6293 (class 1259 OID 19876)
-- Name: idx_mental_state_stress; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_mental_state_stress ON app.user_mental_state USING btree (stress_level DESC) WHERE (stress_level >= 7);


--
-- TOC entry 6294 (class 1259 OID 19877)
-- Name: idx_mental_state_vulnerability; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_mental_state_vulnerability ON app.user_mental_state USING btree (vulnerability_score DESC) WHERE (vulnerability_score >= 0.7);


--
-- TOC entry 6154 (class 1259 OID 18888)
-- Name: idx_oauth_users_email; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_oauth_users_email ON app.oauth_users USING btree (email);


--
-- TOC entry 6352 (class 1259 OID 20153)
-- Name: idx_password_resets_created; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_password_resets_created ON app.password_resets USING btree (created_at);


--
-- TOC entry 6353 (class 1259 OID 20151)
-- Name: idx_password_resets_email; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_password_resets_email ON app.password_resets USING btree (email);


--
-- TOC entry 6354 (class 1259 OID 20152)
-- Name: idx_password_resets_user_expires; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_password_resets_user_expires ON app.password_resets USING btree (user_id, expires_at DESC);


--
-- TOC entry 6314 (class 1259 OID 19883)
-- Name: idx_patterns_user_type; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_patterns_user_type ON app.emotion_patterns USING btree (user_id, pattern_type);


--
-- TOC entry 6006 (class 1259 OID 17546)
-- Name: idx_pay_status; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_pay_status ON app.payments USING btree (status);


--
-- TOC entry 5993 (class 1259 OID 19101)
-- Name: idx_payment_intents_booking_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_payment_intents_booking_id ON app.payment_intents USING btree (booking_id);


--
-- TOC entry 5994 (class 1259 OID 20087)
-- Name: idx_payment_intents_provider; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_payment_intents_provider ON app.payment_intents USING btree (provider);


--
-- TOC entry 5995 (class 1259 OID 19102)
-- Name: idx_payment_intents_status; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_payment_intents_status ON app.payment_intents USING btree (status);


--
-- TOC entry 5996 (class 1259 OID 20085)
-- Name: idx_payment_intents_status_created; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_payment_intents_status_created ON app.payment_intents USING btree (status, created_at);


--
-- TOC entry 6931 (class 0 OID 0)
-- Dependencies: 5996
-- Name: INDEX idx_payment_intents_status_created; Type: COMMENT; Schema: app; Owner: postgres
--

COMMENT ON INDEX app.idx_payment_intents_status_created IS 'For revenue analytics';


--
-- TOC entry 5997 (class 1259 OID 19103)
-- Name: idx_payment_intents_tx_ref; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_payment_intents_tx_ref ON app.payment_intents USING btree (tx_ref);


--
-- TOC entry 5998 (class 1259 OID 20086)
-- Name: idx_payment_intents_user_created; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_payment_intents_user_created ON app.payment_intents USING btree (user_id, created_at);


--
-- TOC entry 5999 (class 1259 OID 19100)
-- Name: idx_payment_intents_user_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_payment_intents_user_id ON app.payment_intents USING btree (user_id);


--
-- TOC entry 6007 (class 1259 OID 19104)
-- Name: idx_payments_intent_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_payments_intent_id ON app.payments USING btree (intent_id);


--
-- TOC entry 6204 (class 1259 OID 19231)
-- Name: idx_payout_requests_created; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_payout_requests_created ON app.payout_requests USING btree (created_at DESC);


--
-- TOC entry 6205 (class 1259 OID 19069)
-- Name: idx_payout_requests_status; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_payout_requests_status ON app.payout_requests USING btree (status);


--
-- TOC entry 6206 (class 1259 OID 19230)
-- Name: idx_payout_requests_user; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_payout_requests_user ON app.payout_requests USING btree (user_id);


--
-- TOC entry 6207 (class 1259 OID 20092)
-- Name: idx_payout_requests_user_created; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_payout_requests_user_created ON app.payout_requests USING btree (user_id, created_at);


--
-- TOC entry 6208 (class 1259 OID 19068)
-- Name: idx_payout_requests_user_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_payout_requests_user_id ON app.payout_requests USING btree (user_id);


--
-- TOC entry 6000 (class 1259 OID 17545)
-- Name: idx_pi_status; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_pi_status ON app.payment_intents USING btree (status);


--
-- TOC entry 6123 (class 1259 OID 18717)
-- Name: idx_post_files_post; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_post_files_post ON app.post_files USING btree (post_id, created_at DESC);


--
-- TOC entry 6058 (class 1259 OID 19114)
-- Name: idx_post_reactions_post_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_post_reactions_post_id ON app.post_reactions USING btree (post_id);


--
-- TOC entry 6059 (class 1259 OID 19115)
-- Name: idx_post_reactions_user_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_post_reactions_user_id ON app.post_reactions USING btree (user_id);


--
-- TOC entry 6126 (class 1259 OID 18734)
-- Name: idx_post_saves_post; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_post_saves_post ON app.post_saves USING btree (post_id, created_at DESC);


--
-- TOC entry 6050 (class 1259 OID 18697)
-- Name: idx_posts_author; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_posts_author ON app.posts USING btree (author_id, created_at DESC);


--
-- TOC entry 6051 (class 1259 OID 20088)
-- Name: idx_posts_author_created; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_posts_author_created ON app.posts USING btree (author_id, created_at);


--
-- TOC entry 6052 (class 1259 OID 19109)
-- Name: idx_posts_author_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_posts_author_id ON app.posts USING btree (author_id);


--
-- TOC entry 6053 (class 1259 OID 17548)
-- Name: idx_posts_created; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_posts_created ON app.posts USING btree (created_at DESC);


--
-- TOC entry 6054 (class 1259 OID 18696)
-- Name: idx_posts_created_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_posts_created_at ON app.posts USING btree (created_at DESC);


--
-- TOC entry 6055 (class 1259 OID 18698)
-- Name: idx_posts_privacy; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_posts_privacy ON app.posts USING btree (privacy);


--
-- TOC entry 6334 (class 1259 OID 20047)
-- Name: idx_proactive_pending; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_proactive_pending ON app.proactive_messages USING btree (scheduled_at) WHERE (is_sent = false);


--
-- TOC entry 6335 (class 1259 OID 20048)
-- Name: idx_proactive_user; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_proactive_user ON app.proactive_messages USING btree (user_id, scheduled_at DESC);


--
-- TOC entry 6259 (class 1259 OID 19493)
-- Name: idx_product_reviews_created_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_product_reviews_created_at ON app.product_reviews USING btree (created_at DESC);


--
-- TOC entry 6260 (class 1259 OID 19490)
-- Name: idx_product_reviews_product_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_product_reviews_product_id ON app.product_reviews USING btree (product_id);


--
-- TOC entry 6261 (class 1259 OID 19492)
-- Name: idx_product_reviews_rating; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_product_reviews_rating ON app.product_reviews USING btree (rating);


--
-- TOC entry 6262 (class 1259 OID 19491)
-- Name: idx_product_reviews_user_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_product_reviews_user_id ON app.product_reviews USING btree (user_id);


--
-- TOC entry 6060 (class 1259 OID 18595)
-- Name: idx_react_post; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_react_post ON app.post_reactions USING btree (post_id);


--
-- TOC entry 6248 (class 1259 OID 19441)
-- Name: idx_recurring_templates_active; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_recurring_templates_active ON app.recurring_booking_templates USING btree (is_active) WHERE (is_active = true);


--
-- TOC entry 6249 (class 1259 OID 19440)
-- Name: idx_recurring_templates_expert; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_recurring_templates_expert ON app.recurring_booking_templates USING btree (expert_id);


--
-- TOC entry 6250 (class 1259 OID 19442)
-- Name: idx_recurring_templates_next_date; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_recurring_templates_next_date ON app.recurring_booking_templates USING btree (next_booking_date) WHERE (is_active = true);


--
-- TOC entry 6251 (class 1259 OID 19439)
-- Name: idx_recurring_templates_user; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_recurring_templates_user ON app.recurring_booking_templates USING btree (user_id);


--
-- TOC entry 6233 (class 1259 OID 19352)
-- Name: idx_refunds_booking; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_refunds_booking ON app.refunds USING btree (booking_id);


--
-- TOC entry 6234 (class 1259 OID 20094)
-- Name: idx_refunds_created_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_refunds_created_at ON app.refunds USING btree (created_at);


--
-- TOC entry 6235 (class 1259 OID 19354)
-- Name: idx_refunds_status; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_refunds_status ON app.refunds USING btree (status);


--
-- TOC entry 6236 (class 1259 OID 19353)
-- Name: idx_refunds_user; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_refunds_user ON app.refunds USING btree (user_id);


--
-- TOC entry 6076 (class 1259 OID 19229)
-- Name: idx_reports_created_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_reports_created_at ON app.reports USING btree (created_at DESC);


--
-- TOC entry 6077 (class 1259 OID 19130)
-- Name: idx_reports_reporter_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_reports_reporter_id ON app.reports USING btree (reporter_id);


--
-- TOC entry 6078 (class 1259 OID 19228)
-- Name: idx_reports_status; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_reports_status ON app.reports USING btree (status);


--
-- TOC entry 6079 (class 1259 OID 20089)
-- Name: idx_reports_status_created; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_reports_status_created ON app.reports USING btree (status, created_at);


--
-- TOC entry 6932 (class 0 OID 0)
-- Dependencies: 6079
-- Name: INDEX idx_reports_status_created; Type: COMMENT; Schema: app; Owner: postgres
--

COMMENT ON INDEX app.idx_reports_status_created IS 'For moderation analytics';


--
-- TOC entry 6080 (class 1259 OID 17550)
-- Name: idx_reports_target; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_reports_target ON app.reports USING btree (target_type, target_id);


--
-- TOC entry 6131 (class 1259 OID 19125)
-- Name: idx_reviews_booking_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_reviews_booking_id ON app.reviews USING btree (booking_id);


--
-- TOC entry 6132 (class 1259 OID 19126)
-- Name: idx_reviews_created_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_reviews_created_at ON app.reviews USING btree (created_at DESC);


--
-- TOC entry 6133 (class 1259 OID 20093)
-- Name: idx_reviews_expert_created; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_reviews_expert_created ON app.reviews USING btree (expert_id, created_at);


--
-- TOC entry 6134 (class 1259 OID 19123)
-- Name: idx_reviews_expert_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_reviews_expert_id ON app.reviews USING btree (expert_id);


--
-- TOC entry 6135 (class 1259 OID 18867)
-- Name: idx_reviews_expert_rating; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_reviews_expert_rating ON app.reviews USING btree (expert_id, rating);


--
-- TOC entry 6136 (class 1259 OID 18820)
-- Name: idx_reviews_expert_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_reviews_expert_time ON app.reviews USING btree (expert_id, created_at DESC);


--
-- TOC entry 6137 (class 1259 OID 20075)
-- Name: idx_reviews_is_hidden; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_reviews_is_hidden ON app.reviews USING btree (is_hidden) WHERE (is_hidden = true);


--
-- TOC entry 6138 (class 1259 OID 18866)
-- Name: idx_reviews_user_booking; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_reviews_user_booking ON app.reviews USING btree (user_id, booking_id);


--
-- TOC entry 6139 (class 1259 OID 19124)
-- Name: idx_reviews_user_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_reviews_user_id ON app.reviews USING btree (user_id);


--
-- TOC entry 6319 (class 1259 OID 20044)
-- Name: idx_schedules_type; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_schedules_type ON app.user_schedules USING btree (user_id, schedule_type);


--
-- TOC entry 6320 (class 1259 OID 20043)
-- Name: idx_schedules_upcoming; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_schedules_upcoming ON app.user_schedules USING btree (start_at) WHERE (completed = false);


--
-- TOC entry 6321 (class 1259 OID 20042)
-- Name: idx_schedules_user_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_schedules_user_time ON app.user_schedules USING btree (user_id, start_at);


--
-- TOC entry 6211 (class 1259 OID 19082)
-- Name: idx_schema_migrations_version; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_schema_migrations_version ON app.schema_migrations USING btree (version);


--
-- TOC entry 6144 (class 1259 OID 18838)
-- Name: idx_sessions_token; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_sessions_token ON app.user_sessions USING btree (token);


--
-- TOC entry 6145 (class 1259 OID 18837)
-- Name: idx_sessions_user_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_sessions_user_time ON app.user_sessions USING btree (user_id, created_at DESC);


--
-- TOC entry 6324 (class 1259 OID 20045)
-- Name: idx_sleep_user_date; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_sleep_user_date ON app.sleep_logs USING btree (user_id, date DESC);


--
-- TOC entry 6340 (class 1259 OID 20049)
-- Name: idx_suggestions_user; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_suggestions_user ON app.ai_suggestions USING btree (user_id, created_at DESC);


--
-- TOC entry 6275 (class 1259 OID 19600)
-- Name: idx_user_ai_settings_persona; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_user_ai_settings_persona ON app.user_ai_settings USING btree (persona_id);


--
-- TOC entry 6267 (class 1259 OID 19512)
-- Name: idx_user_blocks_blocked; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_user_blocks_blocked ON app.user_blocks USING btree (blocked_id);


--
-- TOC entry 6268 (class 1259 OID 19511)
-- Name: idx_user_blocks_blocker; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_user_blocks_blocker ON app.user_blocks USING btree (blocker_id);


--
-- TOC entry 6113 (class 1259 OID 18699)
-- Name: idx_user_follows_followee; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_user_follows_followee ON app.user_follows USING btree (followee_id, created_at DESC);


--
-- TOC entry 6114 (class 1259 OID 18700)
-- Name: idx_user_follows_follower; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_user_follows_follower ON app.user_follows USING btree (follower_id, created_at DESC);


--
-- TOC entry 5938 (class 1259 OID 20397)
-- Name: idx_user_profiles_display_name_trgm; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_user_profiles_display_name_trgm ON app.user_profiles USING gin (display_name public.gin_trgm_ops);


--
-- TOC entry 6146 (class 1259 OID 19089)
-- Name: idx_user_sessions_expires_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_user_sessions_expires_at ON app.user_sessions USING btree (expires_at);


--
-- TOC entry 6147 (class 1259 OID 19088)
-- Name: idx_user_sessions_token; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_user_sessions_token ON app.user_sessions USING btree (token);


--
-- TOC entry 6148 (class 1259 OID 19087)
-- Name: idx_user_sessions_user_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_user_sessions_user_id ON app.user_sessions USING btree (user_id);


--
-- TOC entry 5917 (class 1259 OID 20079)
-- Name: idx_users_created_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_users_created_at ON app.users USING btree (created_at);


--
-- TOC entry 6933 (class 0 OID 0)
-- Dependencies: 5917
-- Name: INDEX idx_users_created_at; Type: COMMENT; Schema: app; Owner: postgres
--

COMMENT ON INDEX app.idx_users_created_at IS 'For user growth analytics';


--
-- TOC entry 5918 (class 1259 OID 19084)
-- Name: idx_users_email; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_users_email ON app.users USING btree (email);


--
-- TOC entry 5919 (class 1259 OID 20098)
-- Name: idx_users_email_lower; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_users_email_lower ON app.users USING btree (lower((email)::text));


--
-- TOC entry 6934 (class 0 OID 0)
-- Dependencies: 5919
-- Name: INDEX idx_users_email_lower; Type: COMMENT; Schema: app; Owner: postgres
--

COMMENT ON INDEX app.idx_users_email_lower IS 'Fast case-insensitive email lookup for login';


--
-- TOC entry 5920 (class 1259 OID 20097)
-- Name: idx_users_email_unique; Type: INDEX; Schema: app; Owner: postgres
--

CREATE UNIQUE INDEX idx_users_email_unique ON app.users USING btree (email) WHERE (email IS NOT NULL);


--
-- TOC entry 6935 (class 0 OID 0)
-- Dependencies: 5920
-- Name: INDEX idx_users_email_unique; Type: COMMENT; Schema: app; Owner: postgres
--

COMMENT ON INDEX app.idx_users_email_unique IS 'Ensure email uniqueness when provided (NULL allowed)';


--
-- TOC entry 5921 (class 1259 OID 19083)
-- Name: idx_users_handle; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_users_handle ON app.users USING btree (handle);


--
-- TOC entry 5922 (class 1259 OID 17540)
-- Name: idx_users_role; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_users_role ON app.users USING btree (role_primary);


--
-- TOC entry 5923 (class 1259 OID 20081)
-- Name: idx_users_role_created; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_users_role_created ON app.users USING btree (role_primary, created_at);


--
-- TOC entry 5924 (class 1259 OID 19086)
-- Name: idx_users_role_primary; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_users_role_primary ON app.users USING btree (role_primary);


--
-- TOC entry 5925 (class 1259 OID 19085)
-- Name: idx_users_status; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_users_status ON app.users USING btree (status);


--
-- TOC entry 5926 (class 1259 OID 20080)
-- Name: idx_users_status_created; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_users_status_created ON app.users USING btree (status, created_at);


--
-- TOC entry 6020 (class 1259 OID 19108)
-- Name: idx_wallet_ledger_created_at; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_wallet_ledger_created_at ON app.wallet_ledger USING btree (created_at DESC);


--
-- TOC entry 6021 (class 1259 OID 19107)
-- Name: idx_wallet_ledger_tx_type; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_wallet_ledger_tx_type ON app.wallet_ledger USING btree (tx_type);


--
-- TOC entry 6022 (class 1259 OID 20091)
-- Name: idx_wallet_ledger_wallet_created; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_wallet_ledger_wallet_created ON app.wallet_ledger USING btree (wallet_id, created_at);


--
-- TOC entry 6023 (class 1259 OID 19106)
-- Name: idx_wallet_ledger_wallet_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_wallet_ledger_wallet_id ON app.wallet_ledger USING btree (wallet_id);


--
-- TOC entry 6024 (class 1259 OID 18590)
-- Name: idx_wallet_ledger_wallet_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_wallet_ledger_wallet_time ON app.wallet_ledger USING btree (wallet_id, created_at DESC);


--
-- TOC entry 6013 (class 1259 OID 17547)
-- Name: idx_wallet_owner; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_wallet_owner ON app.wallets USING btree (owner_user_id);


--
-- TOC entry 6014 (class 1259 OID 19105)
-- Name: idx_wallets_owner_user_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_wallets_owner_user_id ON app.wallets USING btree (owner_user_id);


--
-- TOC entry 6301 (class 1259 OID 19881)
-- Name: idx_wellness_type; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_wellness_type ON app.wellness_activities USING btree (activity_type);


--
-- TOC entry 6302 (class 1259 OID 19880)
-- Name: idx_wellness_user_time; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_wellness_user_time ON app.wellness_activities USING btree (user_id, completed_at DESC);


--
-- TOC entry 6040 (class 1259 OID 18576)
-- Name: uq_chat_member; Type: INDEX; Schema: app; Owner: postgres
--

CREATE UNIQUE INDEX uq_chat_member ON app.chat_members USING btree (thread_id, user_id);


--
-- TOC entry 5948 (class 1259 OID 17178)
-- Name: uq_email_verif_user; Type: INDEX; Schema: app; Owner: postgres
--

CREATE UNIQUE INDEX uq_email_verif_user ON app.email_verifications USING btree (user_id, email) WHERE (verified = false);


--
-- TOC entry 6012 (class 1259 OID 18588)
-- Name: uq_payments_intent; Type: INDEX; Schema: app; Owner: postgres
--

CREATE UNIQUE INDEX uq_payments_intent ON app.payments USING btree (intent_id);


--
-- TOC entry 6153 (class 1259 OID 18855)
-- Name: uq_payout_user; Type: INDEX; Schema: app; Owner: postgres
--

CREATE UNIQUE INDEX uq_payout_user ON app.payout_accounts USING btree (user_id);


--
-- TOC entry 6005 (class 1259 OID 18587)
-- Name: uq_pi_txref; Type: INDEX; Schema: app; Owner: postgres
--

CREATE UNIQUE INDEX uq_pi_txref ON app.payment_intents USING btree (tx_ref);


--
-- TOC entry 5927 (class 1259 OID 18578)
-- Name: uq_users_email; Type: INDEX; Schema: app; Owner: postgres
--

CREATE UNIQUE INDEX uq_users_email ON app.users USING btree (email) WHERE (email IS NOT NULL);


--
-- TOC entry 5928 (class 1259 OID 18577)
-- Name: uq_users_handle; Type: INDEX; Schema: app; Owner: postgres
--

CREATE UNIQUE INDEX uq_users_handle ON app.users USING btree (handle);


--
-- TOC entry 5929 (class 1259 OID 18777)
-- Name: uq_users_phone; Type: INDEX; Schema: app; Owner: postgres
--

CREATE UNIQUE INDEX uq_users_phone ON app.users USING btree (phone) WHERE (phone IS NOT NULL);


--
-- TOC entry 6015 (class 1259 OID 18589)
-- Name: uq_wallet_owner; Type: INDEX; Schema: app; Owner: postgres
--

CREATE UNIQUE INDEX uq_wallet_owner ON app.wallets USING btree (owner_user_id);


--
-- TOC entry 6041 (class 1259 OID 18599)
-- Name: ux_chat_members_thread_user; Type: INDEX; Schema: app; Owner: postgres
--

CREATE UNIQUE INDEX ux_chat_members_thread_user ON app.chat_members USING btree (thread_id, user_id);


--
-- TOC entry 6490 (class 2620 OID 19607)
-- Name: ai_conversation_context trg_ai_context_updated; Type: TRIGGER; Schema: app; Owner: postgres
--

CREATE TRIGGER trg_ai_context_updated BEFORE UPDATE ON app.ai_conversation_context FOR EACH ROW EXECUTE FUNCTION app.fn_ai_touch_updated_at();


--
-- TOC entry 6488 (class 2620 OID 19605)
-- Name: ai_personas trg_ai_personas_updated; Type: TRIGGER; Schema: app; Owner: postgres
--

CREATE TRIGGER trg_ai_personas_updated BEFORE UPDATE ON app.ai_personas FOR EACH ROW EXECUTE FUNCTION app.fn_ai_touch_updated_at();


--
-- TOC entry 6486 (class 2620 OID 19470)
-- Name: disputes trg_disputes_updated_at; Type: TRIGGER; Schema: app; Owner: postgres
--

CREATE TRIGGER trg_disputes_updated_at BEFORE UPDATE ON app.disputes FOR EACH ROW EXECUTE FUNCTION app.fn_disputes_touch_updated_at();


--
-- TOC entry 6480 (class 2620 OID 18242)
-- Name: chat_members trg_dm_member_limit; Type: TRIGGER; Schema: app; Owner: postgres
--

CREATE TRIGGER trg_dm_member_limit BEFORE INSERT ON app.chat_members FOR EACH ROW EXECUTE FUNCTION app.enforce_dm_member_limit();


--
-- TOC entry 6491 (class 2620 OID 19884)
-- Name: user_mental_state trg_mental_state_updated; Type: TRIGGER; Schema: app; Owner: postgres
--

CREATE TRIGGER trg_mental_state_updated BEFORE UPDATE ON app.user_mental_state FOR EACH ROW EXECUTE FUNCTION app.fn_ai_touch_updated_at();


--
-- TOC entry 6481 (class 2620 OID 18736)
-- Name: posts trg_posts_set_updated_at; Type: TRIGGER; Schema: app; Owner: postgres
--

CREATE TRIGGER trg_posts_set_updated_at BEFORE UPDATE OF title, content, tags, privacy ON app.posts FOR EACH ROW EXECUTE FUNCTION app.fn_posts_touch_updated_at();


--
-- TOC entry 6487 (class 2620 OID 19471)
-- Name: recurring_booking_templates trg_recurring_templates_updated_at; Type: TRIGGER; Schema: app; Owner: postgres
--

CREATE TRIGGER trg_recurring_templates_updated_at BEFORE UPDATE ON app.recurring_booking_templates FOR EACH ROW EXECUTE FUNCTION app.fn_disputes_touch_updated_at();


--
-- TOC entry 6485 (class 2620 OID 19468)
-- Name: refunds trg_refunds_updated_at; Type: TRIGGER; Schema: app; Owner: postgres
--

CREATE TRIGGER trg_refunds_updated_at BEFORE UPDATE ON app.refunds FOR EACH ROW EXECUTE FUNCTION app.fn_refunds_touch_updated_at();


--
-- TOC entry 6484 (class 2620 OID 18869)
-- Name: reviews trg_reviews_set_updated_at; Type: TRIGGER; Schema: app; Owner: postgres
--

CREATE TRIGGER trg_reviews_set_updated_at BEFORE UPDATE ON app.reviews FOR EACH ROW EXECUTE FUNCTION app.fn_reviews_touch_updated_at();


--
-- TOC entry 6492 (class 2620 OID 20052)
-- Name: user_schedules trg_schedules_updated; Type: TRIGGER; Schema: app; Owner: postgres
--

CREATE TRIGGER trg_schedules_updated BEFORE UPDATE ON app.user_schedules FOR EACH ROW EXECUTE FUNCTION app.fn_ai_touch_updated_at();


--
-- TOC entry 6482 (class 2620 OID 19245)
-- Name: reports trg_update_comment_report_count; Type: TRIGGER; Schema: app; Owner: postgres
--

CREATE TRIGGER trg_update_comment_report_count AFTER INSERT OR DELETE ON app.reports FOR EACH ROW EXECUTE FUNCTION app.update_comment_report_count();


--
-- TOC entry 6483 (class 2620 OID 19244)
-- Name: reports trg_update_post_report_count; Type: TRIGGER; Schema: app; Owner: postgres
--

CREATE TRIGGER trg_update_post_report_count AFTER INSERT OR DELETE ON app.reports FOR EACH ROW EXECUTE FUNCTION app.update_post_report_count();


--
-- TOC entry 6489 (class 2620 OID 19606)
-- Name: user_ai_settings trg_user_ai_settings_updated; Type: TRIGGER; Schema: app; Owner: postgres
--

CREATE TRIGGER trg_user_ai_settings_updated BEFORE UPDATE ON app.user_ai_settings FOR EACH ROW EXECUTE FUNCTION app.fn_ai_touch_updated_at();


--
-- TOC entry 6479 (class 2620 OID 20100)
-- Name: users trg_validate_email; Type: TRIGGER; Schema: app; Owner: postgres
--

CREATE TRIGGER trg_validate_email BEFORE INSERT OR UPDATE ON app.users FOR EACH ROW EXECUTE FUNCTION app.validate_email_format();


--
-- TOC entry 6467 (class 2606 OID 19912)
-- Name: ai_chat_history ai_chat_history_persona_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.ai_chat_history
    ADD CONSTRAINT ai_chat_history_persona_id_fkey FOREIGN KEY (persona_id) REFERENCES app.ai_personas(id);


--
-- TOC entry 6468 (class 2606 OID 19907)
-- Name: ai_chat_history ai_chat_history_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.ai_chat_history
    ADD CONSTRAINT ai_chat_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6460 (class 2606 OID 19595)
-- Name: ai_conversation_context ai_conversation_context_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.ai_conversation_context
    ADD CONSTRAINT ai_conversation_context_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6458 (class 2606 OID 19576)
-- Name: ai_scheduled_notifications ai_scheduled_notifications_persona_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.ai_scheduled_notifications
    ADD CONSTRAINT ai_scheduled_notifications_persona_id_fkey FOREIGN KEY (persona_id) REFERENCES app.ai_personas(id) ON DELETE SET NULL;


--
-- TOC entry 6459 (class 2606 OID 19571)
-- Name: ai_scheduled_notifications ai_scheduled_notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.ai_scheduled_notifications
    ADD CONSTRAINT ai_scheduled_notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6474 (class 2606 OID 20021)
-- Name: ai_suggestions ai_suggestions_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.ai_suggestions
    ADD CONSTRAINT ai_suggestions_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6471 (class 2606 OID 19983)
-- Name: behavior_patterns behavior_patterns_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.behavior_patterns
    ADD CONSTRAINT behavior_patterns_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6452 (class 2606 OID 19459)
-- Name: booking_fees booking_fees_booking_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.booking_fees
    ADD CONSTRAINT booking_fees_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES app.bookings(id);


--
-- TOC entry 6364 (class 2606 OID 19132)
-- Name: bookings bookings_expert_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.bookings
    ADD CONSTRAINT bookings_expert_id_fkey FOREIGN KEY (expert_id) REFERENCES app.expert_profiles(user_id) ON DELETE CASCADE;


--
-- TOC entry 6365 (class 2606 OID 19443)
-- Name: bookings bookings_recurring_template_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.bookings
    ADD CONSTRAINT bookings_recurring_template_id_fkey FOREIGN KEY (recurring_template_id) REFERENCES app.recurring_booking_templates(id);


--
-- TOC entry 6366 (class 2606 OID 17247)
-- Name: bookings bookings_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.bookings
    ADD CONSTRAINT bookings_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6401 (class 2606 OID 18571)
-- Name: call_events call_events_call_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.call_events
    ADD CONSTRAINT call_events_call_id_fkey FOREIGN KEY (call_id) REFERENCES app.call_sessions(id) ON DELETE CASCADE;


--
-- TOC entry 6434 (class 2606 OID 19162)
-- Name: call_metrics call_metrics_call_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.call_metrics
    ADD CONSTRAINT call_metrics_call_id_fkey FOREIGN KEY (call_id) REFERENCES app.call_sessions(id) ON DELETE CASCADE;


--
-- TOC entry 6435 (class 2606 OID 19178)
-- Name: call_recordings call_recordings_call_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.call_recordings
    ADD CONSTRAINT call_recordings_call_id_fkey FOREIGN KEY (call_id) REFERENCES app.call_sessions(id) ON DELETE CASCADE;


--
-- TOC entry 6397 (class 2606 OID 18580)
-- Name: call_sessions call_sessions_booking_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.call_sessions
    ADD CONSTRAINT call_sessions_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES app.bookings(id) ON DELETE SET NULL;


--
-- TOC entry 6398 (class 2606 OID 18554)
-- Name: call_sessions call_sessions_callee_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.call_sessions
    ADD CONSTRAINT call_sessions_callee_id_fkey FOREIGN KEY (callee_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6399 (class 2606 OID 18549)
-- Name: call_sessions call_sessions_caller_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.call_sessions
    ADD CONSTRAINT call_sessions_caller_id_fkey FOREIGN KEY (caller_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6400 (class 2606 OID 18544)
-- Name: call_sessions call_sessions_thread_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.call_sessions
    ADD CONSTRAINT call_sessions_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES app.chat_threads(id) ON DELETE CASCADE;


--
-- TOC entry 6433 (class 2606 OID 19147)
-- Name: chat_attachments chat_attachments_message_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_attachments
    ADD CONSTRAINT chat_attachments_message_id_fkey FOREIGN KEY (message_id) REFERENCES app.chat_messages(id) ON DELETE CASCADE;


--
-- TOC entry 6377 (class 2606 OID 17393)
-- Name: chat_members chat_members_thread_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_members
    ADD CONSTRAINT chat_members_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES app.chat_threads(id) ON DELETE CASCADE;


--
-- TOC entry 6378 (class 2606 OID 17398)
-- Name: chat_members chat_members_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_members
    ADD CONSTRAINT chat_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6379 (class 2606 OID 17418)
-- Name: chat_messages chat_messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_messages
    ADD CONSTRAINT chat_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6380 (class 2606 OID 17413)
-- Name: chat_messages chat_messages_thread_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_messages
    ADD CONSTRAINT chat_messages_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES app.chat_threads(id) ON DELETE CASCADE;


--
-- TOC entry 6394 (class 2606 OID 18262)
-- Name: chat_read_state chat_read_state_last_read_message_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_read_state
    ADD CONSTRAINT chat_read_state_last_read_message_id_fkey FOREIGN KEY (last_read_message_id) REFERENCES app.chat_messages(id) ON DELETE CASCADE;


--
-- TOC entry 6395 (class 2606 OID 18252)
-- Name: chat_read_state chat_read_state_thread_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_read_state
    ADD CONSTRAINT chat_read_state_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES app.chat_threads(id) ON DELETE CASCADE;


--
-- TOC entry 6396 (class 2606 OID 18257)
-- Name: chat_read_state chat_read_state_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_read_state
    ADD CONSTRAINT chat_read_state_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6436 (class 2606 OID 19206)
-- Name: chat_thread_invitations chat_thread_invitations_invitee_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_thread_invitations
    ADD CONSTRAINT chat_thread_invitations_invitee_id_fkey FOREIGN KEY (invitee_id) REFERENCES app.users(id);


--
-- TOC entry 6437 (class 2606 OID 19201)
-- Name: chat_thread_invitations chat_thread_invitations_inviter_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_thread_invitations
    ADD CONSTRAINT chat_thread_invitations_inviter_id_fkey FOREIGN KEY (inviter_id) REFERENCES app.users(id);


--
-- TOC entry 6438 (class 2606 OID 19196)
-- Name: chat_thread_invitations chat_thread_invitations_thread_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_thread_invitations
    ADD CONSTRAINT chat_thread_invitations_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES app.chat_threads(id) ON DELETE CASCADE;


--
-- TOC entry 6376 (class 2606 OID 17381)
-- Name: chat_threads chat_threads_booking_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.chat_threads
    ADD CONSTRAINT chat_threads_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES app.bookings(id) ON DELETE SET NULL;


--
-- TOC entry 6407 (class 2606 OID 18685)
-- Name: comment_reactions comment_reactions_comment_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.comment_reactions
    ADD CONSTRAINT comment_reactions_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES app.comments(id) ON DELETE CASCADE;


--
-- TOC entry 6408 (class 2606 OID 18690)
-- Name: comment_reactions comment_reactions_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.comment_reactions
    ADD CONSTRAINT comment_reactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6384 (class 2606 OID 18743)
-- Name: comments comments_author_fk; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.comments
    ADD CONSTRAINT comments_author_fk FOREIGN KEY (author_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6385 (class 2606 OID 17475)
-- Name: comments comments_author_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.comments
    ADD CONSTRAINT comments_author_id_fkey FOREIGN KEY (author_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6386 (class 2606 OID 19234)
-- Name: comments comments_moderated_by_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.comments
    ADD CONSTRAINT comments_moderated_by_fkey FOREIGN KEY (moderated_by) REFERENCES app.users(id);


--
-- TOC entry 6387 (class 2606 OID 18748)
-- Name: comments comments_parent_fk; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.comments
    ADD CONSTRAINT comments_parent_fk FOREIGN KEY (parent_id) REFERENCES app.comments(id) ON DELETE CASCADE;


--
-- TOC entry 6388 (class 2606 OID 18738)
-- Name: comments comments_post_fk; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.comments
    ADD CONSTRAINT comments_post_fk FOREIGN KEY (post_id) REFERENCES app.posts(id) ON DELETE CASCADE;


--
-- TOC entry 6389 (class 2606 OID 17470)
-- Name: comments comments_post_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.comments
    ADD CONSTRAINT comments_post_id_fkey FOREIGN KEY (post_id) REFERENCES app.posts(id) ON DELETE CASCADE;


--
-- TOC entry 6393 (class 2606 OID 17523)
-- Name: consents consents_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.consents
    ADD CONSTRAINT consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6476 (class 2606 OID 20121)
-- Name: crisis_alerts crisis_alerts_resolved_by_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.crisis_alerts
    ADD CONSTRAINT crisis_alerts_resolved_by_fkey FOREIGN KEY (resolved_by) REFERENCES app.users(id);


--
-- TOC entry 6477 (class 2606 OID 20116)
-- Name: crisis_alerts crisis_alerts_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.crisis_alerts
    ADD CONSTRAINT crisis_alerts_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6465 (class 2606 OID 19847)
-- Name: daily_mood_checkins daily_mood_checkins_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.daily_mood_checkins
    ADD CONSTRAINT daily_mood_checkins_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6448 (class 2606 OID 19400)
-- Name: dispute_messages dispute_messages_dispute_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.dispute_messages
    ADD CONSTRAINT dispute_messages_dispute_id_fkey FOREIGN KEY (dispute_id) REFERENCES app.disputes(id) ON DELETE CASCADE;


--
-- TOC entry 6449 (class 2606 OID 19405)
-- Name: dispute_messages dispute_messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.dispute_messages
    ADD CONSTRAINT dispute_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES app.users(id);


--
-- TOC entry 6444 (class 2606 OID 19377)
-- Name: disputes disputes_against_user_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.disputes
    ADD CONSTRAINT disputes_against_user_fkey FOREIGN KEY (against_user) REFERENCES app.users(id);


--
-- TOC entry 6445 (class 2606 OID 19382)
-- Name: disputes disputes_assigned_admin_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.disputes
    ADD CONSTRAINT disputes_assigned_admin_fkey FOREIGN KEY (assigned_admin) REFERENCES app.users(id);


--
-- TOC entry 6446 (class 2606 OID 19367)
-- Name: disputes disputes_booking_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.disputes
    ADD CONSTRAINT disputes_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES app.bookings(id);


--
-- TOC entry 6447 (class 2606 OID 19372)
-- Name: disputes disputes_raised_by_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.disputes
    ADD CONSTRAINT disputes_raised_by_fkey FOREIGN KEY (raised_by) REFERENCES app.users(id);


--
-- TOC entry 6360 (class 2606 OID 17173)
-- Name: email_verifications email_verifications_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.email_verifications
    ADD CONSTRAINT email_verifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6461 (class 2606 OID 19756)
-- Name: emotion_logs emotion_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.emotion_logs
    ADD CONSTRAINT emotion_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6466 (class 2606 OID 19867)
-- Name: emotion_patterns emotion_patterns_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.emotion_patterns
    ADD CONSTRAINT emotion_patterns_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6428 (class 2606 OID 19022)
-- Name: expert_audience expert_audience_audience_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_audience
    ADD CONSTRAINT expert_audience_audience_id_fkey FOREIGN KEY (audience_id) REFERENCES app.audience(id) ON DELETE CASCADE;


--
-- TOC entry 6429 (class 2606 OID 19017)
-- Name: expert_audience expert_audience_expert_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_audience
    ADD CONSTRAINT expert_audience_expert_id_fkey FOREIGN KEY (expert_id) REFERENCES app.expert_profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6363 (class 2606 OID 17226)
-- Name: expert_availabilities expert_availabilities_expert_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_availabilities
    ADD CONSTRAINT expert_availabilities_expert_id_fkey FOREIGN KEY (expert_id) REFERENCES app.expert_profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6424 (class 2606 OID 18953)
-- Name: expert_certifications expert_certifications_expert_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_certifications
    ADD CONSTRAINT expert_certifications_expert_id_fkey FOREIGN KEY (expert_id) REFERENCES app.expert_profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6430 (class 2606 OID 19048)
-- Name: expert_domain expert_domain_domain_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_domain
    ADD CONSTRAINT expert_domain_domain_id_fkey FOREIGN KEY (domain_id) REFERENCES app.domains(id) ON DELETE CASCADE;


--
-- TOC entry 6431 (class 2606 OID 19043)
-- Name: expert_domain expert_domain_expert_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_domain
    ADD CONSTRAINT expert_domain_expert_id_fkey FOREIGN KEY (expert_id) REFERENCES app.expert_profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6423 (class 2606 OID 18939)
-- Name: expert_education expert_education_expert_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_education
    ADD CONSTRAINT expert_education_expert_id_fkey FOREIGN KEY (expert_id) REFERENCES app.expert_profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6422 (class 2606 OID 18925)
-- Name: expert_experience expert_experience_expert_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_experience
    ADD CONSTRAINT expert_experience_expert_id_fkey FOREIGN KEY (expert_id) REFERENCES app.expert_profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6427 (class 2606 OID 18996)
-- Name: expert_media expert_media_expert_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_media
    ADD CONSTRAINT expert_media_expert_id_fkey FOREIGN KEY (expert_id) REFERENCES app.expert_profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6425 (class 2606 OID 18966)
-- Name: expert_performance expert_performance_expert_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_performance
    ADD CONSTRAINT expert_performance_expert_id_fkey FOREIGN KEY (expert_id) REFERENCES app.expert_profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6361 (class 2606 OID 17193)
-- Name: expert_profiles expert_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_profiles
    ADD CONSTRAINT expert_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6420 (class 2606 OID 18906)
-- Name: expert_skills expert_skills_expert_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_skills
    ADD CONSTRAINT expert_skills_expert_id_fkey FOREIGN KEY (expert_id) REFERENCES app.expert_profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6421 (class 2606 OID 18911)
-- Name: expert_skills expert_skills_skill_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_skills
    ADD CONSTRAINT expert_skills_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES app.skills(id) ON DELETE CASCADE;


--
-- TOC entry 6426 (class 2606 OID 18981)
-- Name: expert_status expert_status_expert_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.expert_status
    ADD CONSTRAINT expert_status_expert_id_fkey FOREIGN KEY (expert_id) REFERENCES app.expert_profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6402 (class 2606 OID 18609)
-- Name: user_follows fk_follow_from; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_follows
    ADD CONSTRAINT fk_follow_from FOREIGN KEY (follower_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6403 (class 2606 OID 18614)
-- Name: user_follows fk_follow_to; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_follows
    ADD CONSTRAINT fk_follow_to FOREIGN KEY (followee_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6418 (class 2606 OID 18850)
-- Name: payout_accounts fk_payout_user; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payout_accounts
    ADD CONSTRAINT fk_payout_user FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6413 (class 2606 OID 18815)
-- Name: reviews fk_review_booking; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.reviews
    ADD CONSTRAINT fk_review_booking FOREIGN KEY (booking_id) REFERENCES app.bookings(id) ON DELETE SET NULL;


--
-- TOC entry 6414 (class 2606 OID 18810)
-- Name: reviews fk_review_expert; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.reviews
    ADD CONSTRAINT fk_review_expert FOREIGN KEY (expert_id) REFERENCES app.expert_profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6415 (class 2606 OID 18805)
-- Name: reviews fk_review_user; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.reviews
    ADD CONSTRAINT fk_review_user FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6417 (class 2606 OID 18832)
-- Name: user_sessions fk_session_user; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_sessions
    ADD CONSTRAINT fk_session_user FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6362 (class 2606 OID 17210)
-- Name: listener_profiles listener_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.listener_profiles
    ADD CONSTRAINT listener_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6463 (class 2606 OID 19806)
-- Name: mental_health_assessments mental_health_assessments_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.mental_health_assessments
    ADD CONSTRAINT mental_health_assessments_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6392 (class 2606 OID 17508)
-- Name: moderation_actions moderation_actions_admin_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.moderation_actions
    ADD CONSTRAINT moderation_actions_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES app.users(id) ON DELETE SET NULL;


--
-- TOC entry 6419 (class 2606 OID 18883)
-- Name: oauth_users oauth_users_app_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.oauth_users
    ADD CONSTRAINT oauth_users_app_user_id_fkey FOREIGN KEY (app_user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6478 (class 2606 OID 20146)
-- Name: password_resets password_resets_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.password_resets
    ADD CONSTRAINT password_resets_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6369 (class 2606 OID 17293)
-- Name: payment_intents payment_intents_booking_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payment_intents
    ADD CONSTRAINT payment_intents_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES app.bookings(id) ON DELETE SET NULL;


--
-- TOC entry 6370 (class 2606 OID 17298)
-- Name: payment_intents payment_intents_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payment_intents
    ADD CONSTRAINT payment_intents_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6371 (class 2606 OID 17314)
-- Name: payments payments_intent_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payments
    ADD CONSTRAINT payments_intent_id_fkey FOREIGN KEY (intent_id) REFERENCES app.payment_intents(id) ON DELETE CASCADE;


--
-- TOC entry 6432 (class 2606 OID 19223)
-- Name: payout_requests payout_requests_processed_by_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.payout_requests
    ADD CONSTRAINT payout_requests_processed_by_fkey FOREIGN KEY (processed_by) REFERENCES app.users(id);


--
-- TOC entry 6439 (class 2606 OID 19314)
-- Name: platform_settings platform_settings_updated_by_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.platform_settings
    ADD CONSTRAINT platform_settings_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES app.users(id);


--
-- TOC entry 6404 (class 2606 OID 18634)
-- Name: post_audience post_audience_post_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_audience
    ADD CONSTRAINT post_audience_post_id_fkey FOREIGN KEY (post_id) REFERENCES app.posts(id) ON DELETE CASCADE;


--
-- TOC entry 6405 (class 2606 OID 18639)
-- Name: post_audience post_audience_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_audience
    ADD CONSTRAINT post_audience_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6409 (class 2606 OID 18712)
-- Name: post_files post_files_file_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_files
    ADD CONSTRAINT post_files_file_fkey FOREIGN KEY (file_id) REFERENCES app.user_files(id) ON DELETE CASCADE;


--
-- TOC entry 6410 (class 2606 OID 18707)
-- Name: post_files post_files_post_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_files
    ADD CONSTRAINT post_files_post_fkey FOREIGN KEY (post_id) REFERENCES app.posts(id) ON DELETE CASCADE;


--
-- TOC entry 6406 (class 2606 OID 18659)
-- Name: post_media post_media_post_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_media
    ADD CONSTRAINT post_media_post_id_fkey FOREIGN KEY (post_id) REFERENCES app.posts(id) ON DELETE CASCADE;


--
-- TOC entry 6382 (class 2606 OID 17449)
-- Name: post_reactions post_reactions_post_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_reactions
    ADD CONSTRAINT post_reactions_post_id_fkey FOREIGN KEY (post_id) REFERENCES app.posts(id) ON DELETE CASCADE;


--
-- TOC entry 6383 (class 2606 OID 17454)
-- Name: post_reactions post_reactions_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_reactions
    ADD CONSTRAINT post_reactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6411 (class 2606 OID 18729)
-- Name: post_saves post_saves_post_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_saves
    ADD CONSTRAINT post_saves_post_fkey FOREIGN KEY (post_id) REFERENCES app.posts(id) ON DELETE CASCADE;


--
-- TOC entry 6412 (class 2606 OID 18724)
-- Name: post_saves post_saves_user_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.post_saves
    ADD CONSTRAINT post_saves_user_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6381 (class 2606 OID 17435)
-- Name: posts posts_author_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.posts
    ADD CONSTRAINT posts_author_id_fkey FOREIGN KEY (author_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6472 (class 2606 OID 20006)
-- Name: proactive_messages proactive_messages_persona_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.proactive_messages
    ADD CONSTRAINT proactive_messages_persona_id_fkey FOREIGN KEY (persona_id) REFERENCES app.ai_personas(id);


--
-- TOC entry 6473 (class 2606 OID 20001)
-- Name: proactive_messages proactive_messages_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.proactive_messages
    ADD CONSTRAINT proactive_messages_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6453 (class 2606 OID 19485)
-- Name: product_reviews product_reviews_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.product_reviews
    ADD CONSTRAINT product_reviews_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6450 (class 2606 OID 19434)
-- Name: recurring_booking_templates recurring_booking_templates_expert_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.recurring_booking_templates
    ADD CONSTRAINT recurring_booking_templates_expert_id_fkey FOREIGN KEY (expert_id) REFERENCES app.users(id);


--
-- TOC entry 6451 (class 2606 OID 19429)
-- Name: recurring_booking_templates recurring_booking_templates_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.recurring_booking_templates
    ADD CONSTRAINT recurring_booking_templates_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id);


--
-- TOC entry 6440 (class 2606 OID 19332)
-- Name: refunds refunds_booking_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.refunds
    ADD CONSTRAINT refunds_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES app.bookings(id);


--
-- TOC entry 6441 (class 2606 OID 19337)
-- Name: refunds refunds_payment_intent_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.refunds
    ADD CONSTRAINT refunds_payment_intent_id_fkey FOREIGN KEY (payment_intent_id) REFERENCES app.payment_intents(id);


--
-- TOC entry 6442 (class 2606 OID 19347)
-- Name: refunds refunds_processed_by_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.refunds
    ADD CONSTRAINT refunds_processed_by_fkey FOREIGN KEY (processed_by) REFERENCES app.users(id);


--
-- TOC entry 6443 (class 2606 OID 19342)
-- Name: refunds refunds_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.refunds
    ADD CONSTRAINT refunds_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id);


--
-- TOC entry 6390 (class 2606 OID 17491)
-- Name: reports reports_reporter_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.reports
    ADD CONSTRAINT reports_reporter_id_fkey FOREIGN KEY (reporter_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6391 (class 2606 OID 19217)
-- Name: reports reports_resolved_by_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.reports
    ADD CONSTRAINT reports_resolved_by_fkey FOREIGN KEY (resolved_by) REFERENCES app.users(id);


--
-- TOC entry 6416 (class 2606 OID 20070)
-- Name: reviews reviews_hidden_by_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.reviews
    ADD CONSTRAINT reviews_hidden_by_fkey FOREIGN KEY (hidden_by) REFERENCES app.users(id);


--
-- TOC entry 6367 (class 2606 OID 17269)
-- Name: session_notes session_notes_booking_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.session_notes
    ADD CONSTRAINT session_notes_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES app.bookings(id) ON DELETE CASCADE;


--
-- TOC entry 6368 (class 2606 OID 17274)
-- Name: session_notes session_notes_expert_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.session_notes
    ADD CONSTRAINT session_notes_expert_id_fkey FOREIGN KEY (expert_id) REFERENCES app.expert_profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6470 (class 2606 OID 19962)
-- Name: sleep_logs sleep_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.sleep_logs
    ADD CONSTRAINT sleep_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6374 (class 2606 OID 17361)
-- Name: tips tips_from_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.tips
    ADD CONSTRAINT tips_from_user_id_fkey FOREIGN KEY (from_user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6375 (class 2606 OID 17366)
-- Name: tips tips_to_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.tips
    ADD CONSTRAINT tips_to_user_id_fkey FOREIGN KEY (to_user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6475 (class 2606 OID 20037)
-- Name: user_activity_logs user_activity_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_activity_logs
    ADD CONSTRAINT user_activity_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6456 (class 2606 OID 19553)
-- Name: user_ai_settings user_ai_settings_persona_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_ai_settings
    ADD CONSTRAINT user_ai_settings_persona_id_fkey FOREIGN KEY (persona_id) REFERENCES app.ai_personas(id) ON DELETE SET NULL;


--
-- TOC entry 6457 (class 2606 OID 19548)
-- Name: user_ai_settings user_ai_settings_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_ai_settings
    ADD CONSTRAINT user_ai_settings_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6454 (class 2606 OID 19506)
-- Name: user_blocks user_blocks_blocked_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_blocks
    ADD CONSTRAINT user_blocks_blocked_id_fkey FOREIGN KEY (blocked_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6455 (class 2606 OID 19501)
-- Name: user_blocks user_blocks_blocker_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_blocks
    ADD CONSTRAINT user_blocks_blocker_id_fkey FOREIGN KEY (blocker_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6359 (class 2606 OID 17157)
-- Name: user_files user_files_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_files
    ADD CONSTRAINT user_files_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6462 (class 2606 OID 19781)
-- Name: user_mental_state user_mental_state_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_mental_state
    ADD CONSTRAINT user_mental_state_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6357 (class 2606 OID 17131)
-- Name: user_profiles user_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_profiles
    ADD CONSTRAINT user_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6358 (class 2606 OID 17141)
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6469 (class 2606 OID 19942)
-- Name: user_schedules user_schedules_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.user_schedules
    ADD CONSTRAINT user_schedules_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6373 (class 2606 OID 17345)
-- Name: wallet_ledger wallet_ledger_wallet_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.wallet_ledger
    ADD CONSTRAINT wallet_ledger_wallet_id_fkey FOREIGN KEY (wallet_id) REFERENCES app.wallets(id) ON DELETE CASCADE;


--
-- TOC entry 6372 (class 2606 OID 17329)
-- Name: wallets wallets_owner_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.wallets
    ADD CONSTRAINT wallets_owner_user_id_fkey FOREIGN KEY (owner_user_id) REFERENCES app.users(id) ON DELETE CASCADE;


--
-- TOC entry 6464 (class 2606 OID 19825)
-- Name: wellness_activities wellness_activities_user_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.wellness_activities
    ADD CONSTRAINT wellness_activities_user_id_fkey FOREIGN KEY (user_id) REFERENCES app.users(id) ON DELETE CASCADE;


-- Completed on 2025-12-12 14:19:14

--
-- PostgreSQL database dump complete
--

\unrestrict WLINor7iOODQh4WEqB8GJJKxomcdm4Ju6EkVUkCfzpKg9PgiMaayAIfbusmNII4

