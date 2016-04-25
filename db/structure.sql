--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


SET search_path = public, pg_catalog;

--
-- Name: pg_search_dmetaphone(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pg_search_dmetaphone(text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
  SELECT array_to_string(ARRAY(SELECT dmetaphone(unnest(regexp_split_to_array($1, E'\\s+')))), ' ')
$_$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: benefits; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE benefits (
    id integer NOT NULL,
    message text,
    user_id integer,
    ordering integer DEFAULT 0 NOT NULL
);


--
-- Name: benefits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE benefits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: benefits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE benefits_id_seq OWNED BY benefits.id;


--
-- Name: comment_ignores; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comment_ignores (
    id integer NOT NULL,
    user_id integer,
    commenter_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comment_ignores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comment_ignores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comment_ignores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comment_ignores_id_seq OWNED BY comment_ignores.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    post_id integer,
    user_id integer,
    message text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    post_user_id integer,
    parent_id integer,
    mentions text,
    hidden boolean DEFAULT false NOT NULL,
    likes_count integer DEFAULT 0 NOT NULL,
    replies_count integer DEFAULT 0 NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: contributions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contributions (
    id integer NOT NULL,
    amount integer,
    recurring boolean DEFAULT false NOT NULL,
    user_id integer,
    target_user_id integer,
    parent_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: contributions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contributions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contributions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contributions_id_seq OWNED BY contributions.id;


--
-- Name: credit_card_declines; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE credit_card_declines (
    id integer NOT NULL,
    user_id integer,
    stripe_fingerprint character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: credit_card_declines_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE credit_card_declines_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: credit_card_declines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE credit_card_declines_id_seq OWNED BY credit_card_declines.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    handler text NOT NULL,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying,
    queue character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: dialogues; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE dialogues (
    id integer NOT NULL,
    recent_message_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    recent_message_at timestamp without time zone,
    unread boolean DEFAULT true NOT NULL,
    read_at timestamp without time zone
);


--
-- Name: dialogues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE dialogues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dialogues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE dialogues_id_seq OWNED BY dialogues.id;


--
-- Name: dialogues_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE dialogues_users (
    id integer NOT NULL,
    dialogue_id integer,
    user_id integer,
    removed boolean DEFAULT false NOT NULL
);


--
-- Name: dialogues_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE dialogues_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dialogues_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE dialogues_users_id_seq OWNED BY dialogues_users.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    action character varying,
    message character varying,
    data text,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    subject_id integer,
    subject_type character varying
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: feed_events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE feed_events (
    id integer NOT NULL,
    type character varying,
    target_id integer,
    target_type character varying,
    target_user_id integer,
    subscription_target_user_id integer,
    data text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    hidden boolean DEFAULT false NOT NULL
);


--
-- Name: feed_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE feed_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feed_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE feed_events_id_seq OWNED BY feed_events.id;


--
-- Name: likes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE likes (
    id integer NOT NULL,
    user_id integer,
    likable_id integer,
    likable_type character varying,
    post_id integer,
    target_user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    comment_id integer
);


--
-- Name: likes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: likes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE likes_id_seq OWNED BY likes.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE messages (
    id integer NOT NULL,
    user_id integer,
    target_user_id integer,
    message text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    dialogue_id integer,
    contribution_id integer,
    read boolean DEFAULT false NOT NULL,
    read_at timestamp without time zone
);


--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE messages_id_seq OWNED BY messages.id;


--
-- Name: payment_failures; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE payment_failures (
    id integer NOT NULL,
    user_id integer,
    target_id integer,
    target_type character varying,
    exception_data text,
    stripe_charge_data text,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    target_user_id integer
);


--
-- Name: payment_failures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE payment_failures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_failures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE payment_failures_id_seq OWNED BY payment_failures.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE payments (
    id integer NOT NULL,
    target_id integer,
    target_type character varying,
    user_id integer,
    amount integer,
    stripe_charge_data text,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    target_user_id integer,
    cost integer,
    subscription_fees integer,
    subscription_cost integer,
    source_country character varying
);


--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE payments_id_seq OWNED BY payments.id;


--
-- Name: pending_posts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pending_posts (
    id integer NOT NULL,
    user_id integer,
    title character varying(512),
    message text,
    keywords text
);


--
-- Name: pending_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pending_posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pending_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pending_posts_id_seq OWNED BY pending_posts.id;


--
-- Name: posts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE posts (
    id integer NOT NULL,
    user_id integer,
    message text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    title character varying(512),
    keywords_text character varying(512),
    type character varying,
    hidden boolean DEFAULT false NOT NULL,
    comments_count integer DEFAULT 0 NOT NULL,
    likes_count integer DEFAULT 0 NOT NULL
);


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE posts_id_seq OWNED BY posts.id;


--
-- Name: profile_pages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE profile_pages (
    id integer NOT NULL,
    user_id integer,
    welcome_box text,
    css text,
    special_offer text
);


--
-- Name: profile_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE profile_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profile_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE profile_pages_id_seq OWNED BY profile_pages.id;


--
-- Name: profile_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE profile_types (
    id integer NOT NULL,
    title character varying,
    ordering integer DEFAULT 0 NOT NULL,
    user_id integer
);


--
-- Name: profile_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE profile_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profile_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE profile_types_id_seq OWNED BY profile_types.id;


--
-- Name: profile_types_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE profile_types_users (
    id integer NOT NULL,
    user_id integer,
    profile_type_id integer,
    ordering integer DEFAULT 0 NOT NULL
);


--
-- Name: profile_types_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE profile_types_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profile_types_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE profile_types_users_id_seq OWNED BY profile_types_users.id;


--
-- Name: requests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE requests (
    id integer NOT NULL,
    new_cost integer,
    old_cost integer,
    approved boolean DEFAULT false NOT NULL,
    rejected boolean DEFAULT false NOT NULL,
    performed boolean DEFAULT false NOT NULL,
    update_existing_subscriptions boolean DEFAULT false NOT NULL,
    user_id integer,
    type character varying,
    approved_at timestamp without time zone,
    rejected_at timestamp without time zone,
    performed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    amount integer,
    recurring boolean DEFAULT false NOT NULL,
    target_user_id integer,
    message text
);


--
-- Name: requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE requests_id_seq OWNED BY requests.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: stripe_transfers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stripe_transfers (
    id integer NOT NULL,
    user_id integer,
    stripe_response text,
    amount integer,
    description character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: stripe_transfers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stripe_transfers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stripe_transfers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stripe_transfers_id_seq OWNED BY stripe_transfers.id;


--
-- Name: subscription_daily_count_change_events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE subscription_daily_count_change_events (
    id integer NOT NULL,
    subscriptions_count integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    created_on date,
    user_id integer,
    unsubscribers_count integer DEFAULT 0,
    failed_payments_count integer DEFAULT 0
);


--
-- Name: subscription_daily_count_change_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subscription_daily_count_change_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscription_daily_count_change_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subscription_daily_count_change_events_id_seq OWNED BY subscription_daily_count_change_events.id;


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE subscriptions (
    id integer NOT NULL,
    user_id integer,
    target_id integer,
    target_type character varying,
    target_user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    notifications_enabled boolean DEFAULT true NOT NULL,
    charged_at timestamp without time zone,
    removed boolean DEFAULT false NOT NULL,
    removed_at timestamp without time zone,
    rejected boolean DEFAULT false NOT NULL,
    rejected_at timestamp without time zone,
    cost integer,
    fees integer,
    total_cost integer,
    fake boolean DEFAULT false NOT NULL,
    processing_payment boolean DEFAULT false NOT NULL,
    processing_started_at timestamp without time zone
);


--
-- Name: subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subscriptions_id_seq OWNED BY subscriptions.id;


--
-- Name: top_profiles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE top_profiles (
    id integer NOT NULL,
    user_id integer,
    "position" integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    profile_name character varying,
    profile_types_text text
);


--
-- Name: top_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE top_profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: top_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE top_profiles_id_seq OWNED BY top_profiles.id;


--
-- Name: uploads; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE uploads (
    id integer NOT NULL,
    uploadable_id integer,
    uploadable_type character varying,
    transloadit_data text,
    user_id integer,
    duration double precision,
    type character varying,
    mime_type character varying,
    width integer,
    height integer,
    preview_url text,
    url text,
    filename text,
    basename text,
    filesize integer,
    ordering integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    removed boolean DEFAULT false,
    removed_at timestamp without time zone,
    s3_paths text,
    hd_url text,
    playlist_url text,
    high_quality_playlist_url text,
    low_quality_playlist_url text,
    retina_preview_url text
);


--
-- Name: uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE uploads_id_seq OWNED BY uploads.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    slug character varying,
    email character varying,
    password_hash character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    full_name character varying(512),
    subscription_cost integer,
    holder_name character varying,
    routing_number character varying,
    account_number character varying,
    stripe_user_id character varying,
    stripe_card_id character varying,
    last_four_cc_numbers character varying,
    card_type character varying,
    profile_picture_url text,
    original_profile_picture_url text,
    cover_picture_url text,
    original_cover_picture_url text,
    is_profile_owner boolean DEFAULT false NOT NULL,
    has_complete_profile boolean DEFAULT false NOT NULL,
    profile_name character varying(512),
    is_admin boolean DEFAULT false NOT NULL,
    contacts_info text,
    auth_token character varying,
    cover_picture_position integer DEFAULT 0 NOT NULL,
    subscription_fees integer,
    cost integer,
    has_public_profile boolean DEFAULT false,
    password_reset_token character varying,
    company_name character varying,
    small_profile_picture_url text,
    account_picture_url text,
    small_account_picture_url text,
    original_account_picture_url text,
    cost_changed_at timestamp without time zone,
    activated boolean DEFAULT false NOT NULL,
    registration_token character varying,
    rss_enabled boolean DEFAULT true NOT NULL,
    downloads_enabled boolean DEFAULT true NOT NULL,
    itunes_enabled boolean DEFAULT true NOT NULL,
    subscribers_count integer DEFAULT 0 NOT NULL,
    billing_failed boolean DEFAULT false NOT NULL,
    stripe_recipient_id character varying,
    billing_failed_at timestamp without time zone,
    vacation_enabled boolean DEFAULT false NOT NULL,
    vacation_message text,
    last_visited_profile_id integer,
    vacation_enabled_at timestamp without time zone,
    billing_address_city character varying,
    billing_address_state character varying,
    billing_address_zip character varying,
    billing_address_line_1 text,
    billing_address_line_2 text,
    contributions_enabled boolean DEFAULT true NOT NULL,
    notifications_debug_enabled boolean DEFAULT true,
    api_token character varying,
    custom_profile_page_css text,
    hidden boolean DEFAULT true NOT NULL,
    prefers_paypal boolean DEFAULT false NOT NULL,
    paypal_email character varying,
    stripe_card_fingerprint character varying,
    has_mature_content boolean DEFAULT false NOT NULL,
    custom_head_js text,
    cover_picture_width integer,
    cover_picture_height integer,
    cover_picture_position_perc double precision DEFAULT 0.0,
    has_custom_welcome_message boolean DEFAULT false NOT NULL,
    has_custom_profile_page_css boolean DEFAULT false NOT NULL,
    has_special_offer boolean DEFAULT false NOT NULL,
    subscriptions_chart_visible boolean DEFAULT false NOT NULL,
    partner_id integer,
    partner_fees integer DEFAULT 0 NOT NULL,
    locked boolean DEFAULT false NOT NULL,
    daily_contributions_limit integer DEFAULT 3000 NOT NULL,
    last_post_created_at timestamp without time zone,
    last_time_locked_at timestamp without time zone,
    accepts_large_contributions boolean DEFAULT false NOT NULL,
    message_notifications_enabled boolean DEFAULT true NOT NULL,
    recent_subscriptions_count integer DEFAULT 0 NOT NULL,
    recent_subscription_at timestamp without time zone,
    is_sales boolean DEFAULT false NOT NULL,
    lock_type character varying,
    lock_reason character varying,
    gross_sales integer DEFAULT 0 NOT NULL,
    gross_contributions integer DEFAULT 0 NOT NULL,
    adult_subscriptions_limit integer DEFAULT 6 NOT NULL,
    tos_accepted boolean DEFAULT true NOT NULL,
    payout_updated_at timestamp without time zone,
    subscriptions_count integer DEFAULT 0 NOT NULL,
    adult_subscriptions_limit_changed_at timestamp without time zone,
    old_email character varying,
    email_updated_at timestamp without time zone,
    posts_count integer DEFAULT 0 NOT NULL,
    contribution_limit_reached_at timestamp without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY benefits ALTER COLUMN id SET DEFAULT nextval('benefits_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY comment_ignores ALTER COLUMN id SET DEFAULT nextval('comment_ignores_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contributions ALTER COLUMN id SET DEFAULT nextval('contributions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY credit_card_declines ALTER COLUMN id SET DEFAULT nextval('credit_card_declines_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY dialogues ALTER COLUMN id SET DEFAULT nextval('dialogues_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY dialogues_users ALTER COLUMN id SET DEFAULT nextval('dialogues_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY feed_events ALTER COLUMN id SET DEFAULT nextval('feed_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY likes ALTER COLUMN id SET DEFAULT nextval('likes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY messages ALTER COLUMN id SET DEFAULT nextval('messages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_failures ALTER COLUMN id SET DEFAULT nextval('payment_failures_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY payments ALTER COLUMN id SET DEFAULT nextval('payments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pending_posts ALTER COLUMN id SET DEFAULT nextval('pending_posts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY posts ALTER COLUMN id SET DEFAULT nextval('posts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY profile_pages ALTER COLUMN id SET DEFAULT nextval('profile_pages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY profile_types ALTER COLUMN id SET DEFAULT nextval('profile_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY profile_types_users ALTER COLUMN id SET DEFAULT nextval('profile_types_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY requests ALTER COLUMN id SET DEFAULT nextval('requests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_transfers ALTER COLUMN id SET DEFAULT nextval('stripe_transfers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY subscription_daily_count_change_events ALTER COLUMN id SET DEFAULT nextval('subscription_daily_count_change_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY subscriptions ALTER COLUMN id SET DEFAULT nextval('subscriptions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY top_profiles ALTER COLUMN id SET DEFAULT nextval('top_profiles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY uploads ALTER COLUMN id SET DEFAULT nextval('uploads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: benefits_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY benefits
    ADD CONSTRAINT benefits_pkey PRIMARY KEY (id);


--
-- Name: comment_ignores_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comment_ignores
    ADD CONSTRAINT comment_ignores_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: contributions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contributions
    ADD CONSTRAINT contributions_pkey PRIMARY KEY (id);


--
-- Name: credit_card_declines_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY credit_card_declines
    ADD CONSTRAINT credit_card_declines_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: dialogues_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY dialogues
    ADD CONSTRAINT dialogues_pkey PRIMARY KEY (id);


--
-- Name: dialogues_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY dialogues_users
    ADD CONSTRAINT dialogues_users_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: feed_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY feed_events
    ADD CONSTRAINT feed_events_pkey PRIMARY KEY (id);


--
-- Name: likes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


--
-- Name: messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: payment_failures_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY payment_failures
    ADD CONSTRAINT payment_failures_pkey PRIMARY KEY (id);


--
-- Name: payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: pending_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pending_posts
    ADD CONSTRAINT pending_posts_pkey PRIMARY KEY (id);


--
-- Name: posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: profile_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY profile_pages
    ADD CONSTRAINT profile_pages_pkey PRIMARY KEY (id);


--
-- Name: profile_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY profile_types
    ADD CONSTRAINT profile_types_pkey PRIMARY KEY (id);


--
-- Name: profile_types_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY profile_types_users
    ADD CONSTRAINT profile_types_users_pkey PRIMARY KEY (id);


--
-- Name: requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY requests
    ADD CONSTRAINT requests_pkey PRIMARY KEY (id);


--
-- Name: stripe_transfers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stripe_transfers
    ADD CONSTRAINT stripe_transfers_pkey PRIMARY KEY (id);


--
-- Name: subscription_daily_count_change_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY subscription_daily_count_change_events
    ADD CONSTRAINT subscription_daily_count_change_events_pkey PRIMARY KEY (id);


--
-- Name: subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: top_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY top_profiles
    ADD CONSTRAINT top_profiles_pkey PRIMARY KEY (id);


--
-- Name: uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX delayed_jobs_priority ON delayed_jobs USING btree (priority, run_at);


--
-- Name: index_comments_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_parent_id ON comments USING btree (parent_id);


--
-- Name: index_comments_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_post_id ON comments USING btree (post_id);


--
-- Name: index_events_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_user_id ON events USING btree (user_id);


--
-- Name: index_likes_on_comment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_likes_on_comment_id ON likes USING btree (comment_id);


--
-- Name: index_likes_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_likes_on_post_id ON likes USING btree (post_id);


--
-- Name: index_payments_on_target_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_payments_on_target_user_id ON payments USING btree (target_user_id);


--
-- Name: index_payments_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_payments_on_user_id ON payments USING btree (user_id);


--
-- Name: index_subscriptions_on_target_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_subscriptions_on_target_user_id ON subscriptions USING btree (target_user_id);


--
-- Name: index_uploads_on_uploadable_id_and_uploadable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_uploads_on_uploadable_id_and_uploadable_type ON uploads USING btree (uploadable_id, uploadable_type);


--
-- Name: index_users_on_api_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_api_token ON users USING btree (api_token);


--
-- Name: index_users_on_auth_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_auth_token ON users USING btree (auth_token);


--
-- Name: index_users_on_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_slug ON users USING btree (slug);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20140202103843');

INSERT INTO schema_migrations (version) VALUES ('20140202153903');

INSERT INTO schema_migrations (version) VALUES ('20140228110435');

INSERT INTO schema_migrations (version) VALUES ('20140228182743');

INSERT INTO schema_migrations (version) VALUES ('20140301073218');

INSERT INTO schema_migrations (version) VALUES ('20140302143540');

INSERT INTO schema_migrations (version) VALUES ('20140303133258');

INSERT INTO schema_migrations (version) VALUES ('20140303135718');

INSERT INTO schema_migrations (version) VALUES ('20140304115014');

INSERT INTO schema_migrations (version) VALUES ('20140306143300');

INSERT INTO schema_migrations (version) VALUES ('20140306143557');

INSERT INTO schema_migrations (version) VALUES ('20140308203447');

INSERT INTO schema_migrations (version) VALUES ('20140309101758');

INSERT INTO schema_migrations (version) VALUES ('20140309102803');

INSERT INTO schema_migrations (version) VALUES ('20140312080511');

INSERT INTO schema_migrations (version) VALUES ('20140312082212');

INSERT INTO schema_migrations (version) VALUES ('20140312113727');

INSERT INTO schema_migrations (version) VALUES ('20140312135728');

INSERT INTO schema_migrations (version) VALUES ('20140321091326');

INSERT INTO schema_migrations (version) VALUES ('20140321111847');

INSERT INTO schema_migrations (version) VALUES ('20140326104922');

INSERT INTO schema_migrations (version) VALUES ('20140403112436');

INSERT INTO schema_migrations (version) VALUES ('20140403141129');

INSERT INTO schema_migrations (version) VALUES ('20140404115255');

INSERT INTO schema_migrations (version) VALUES ('20140404115337');

INSERT INTO schema_migrations (version) VALUES ('20140407054251');

INSERT INTO schema_migrations (version) VALUES ('20140408072458');

INSERT INTO schema_migrations (version) VALUES ('20140408163449');

INSERT INTO schema_migrations (version) VALUES ('20140408163607');

INSERT INTO schema_migrations (version) VALUES ('20140410071915');

INSERT INTO schema_migrations (version) VALUES ('20140412094101');

INSERT INTO schema_migrations (version) VALUES ('20140413122522');

INSERT INTO schema_migrations (version) VALUES ('20140415050828');

INSERT INTO schema_migrations (version) VALUES ('20140415061847');

INSERT INTO schema_migrations (version) VALUES ('20140415125049');

INSERT INTO schema_migrations (version) VALUES ('20140417115754');

INSERT INTO schema_migrations (version) VALUES ('20140417184746');

INSERT INTO schema_migrations (version) VALUES ('20140417193428');

INSERT INTO schema_migrations (version) VALUES ('20140418112251');

INSERT INTO schema_migrations (version) VALUES ('20140418134507');

INSERT INTO schema_migrations (version) VALUES ('20140419085232');

INSERT INTO schema_migrations (version) VALUES ('20140420102145');

INSERT INTO schema_migrations (version) VALUES ('20140421093001');

INSERT INTO schema_migrations (version) VALUES ('20140421152627');

INSERT INTO schema_migrations (version) VALUES ('20140421153513');

INSERT INTO schema_migrations (version) VALUES ('20140423124726');

INSERT INTO schema_migrations (version) VALUES ('20140423174402');

INSERT INTO schema_migrations (version) VALUES ('20140425163510');

INSERT INTO schema_migrations (version) VALUES ('20140429091410');

INSERT INTO schema_migrations (version) VALUES ('20140430181853');

INSERT INTO schema_migrations (version) VALUES ('20140501143033');

INSERT INTO schema_migrations (version) VALUES ('20140503111532');

INSERT INTO schema_migrations (version) VALUES ('20140503111650');

INSERT INTO schema_migrations (version) VALUES ('20140503111909');

INSERT INTO schema_migrations (version) VALUES ('20140503161433');

INSERT INTO schema_migrations (version) VALUES ('20140503161952');

INSERT INTO schema_migrations (version) VALUES ('20140504180126');

INSERT INTO schema_migrations (version) VALUES ('20140505163806');

INSERT INTO schema_migrations (version) VALUES ('20140508084847');

INSERT INTO schema_migrations (version) VALUES ('20140508115848');

INSERT INTO schema_migrations (version) VALUES ('20140508115947');

INSERT INTO schema_migrations (version) VALUES ('20140509182958');

INSERT INTO schema_migrations (version) VALUES ('20140511101640');

INSERT INTO schema_migrations (version) VALUES ('20140511120444');

INSERT INTO schema_migrations (version) VALUES ('20140511121316');

INSERT INTO schema_migrations (version) VALUES ('20140513204040');

INSERT INTO schema_migrations (version) VALUES ('20140513212757');

INSERT INTO schema_migrations (version) VALUES ('20140516193258');

INSERT INTO schema_migrations (version) VALUES ('20140526173934');

INSERT INTO schema_migrations (version) VALUES ('20140526202726');

INSERT INTO schema_migrations (version) VALUES ('20140527070103');

INSERT INTO schema_migrations (version) VALUES ('20140528162312');

INSERT INTO schema_migrations (version) VALUES ('20140530170944');

INSERT INTO schema_migrations (version) VALUES ('20140604041646');

INSERT INTO schema_migrations (version) VALUES ('20140604125434');

INSERT INTO schema_migrations (version) VALUES ('20140623040355');

INSERT INTO schema_migrations (version) VALUES ('20140623041205');

INSERT INTO schema_migrations (version) VALUES ('20140624125826');

INSERT INTO schema_migrations (version) VALUES ('20140624130009');

INSERT INTO schema_migrations (version) VALUES ('20140624130659');

INSERT INTO schema_migrations (version) VALUES ('20140724070838');

INSERT INTO schema_migrations (version) VALUES ('20140725163435');

INSERT INTO schema_migrations (version) VALUES ('20140801083349');

INSERT INTO schema_migrations (version) VALUES ('20140806113538');

INSERT INTO schema_migrations (version) VALUES ('20140806234854');

INSERT INTO schema_migrations (version) VALUES ('20140818144156');

INSERT INTO schema_migrations (version) VALUES ('20140818144636');

INSERT INTO schema_migrations (version) VALUES ('20140903094406');

INSERT INTO schema_migrations (version) VALUES ('20140904174036');

INSERT INTO schema_migrations (version) VALUES ('20140904174216');

INSERT INTO schema_migrations (version) VALUES ('20140908174517');

INSERT INTO schema_migrations (version) VALUES ('20140925094412');

INSERT INTO schema_migrations (version) VALUES ('20141007164537');

INSERT INTO schema_migrations (version) VALUES ('20141007164627');

INSERT INTO schema_migrations (version) VALUES ('20141007164832');

INSERT INTO schema_migrations (version) VALUES ('20141009063051');

INSERT INTO schema_migrations (version) VALUES ('20141021155421');

INSERT INTO schema_migrations (version) VALUES ('20141029032547');

INSERT INTO schema_migrations (version) VALUES ('20141031093054');

INSERT INTO schema_migrations (version) VALUES ('20141120115958');

INSERT INTO schema_migrations (version) VALUES ('20141128040705');

INSERT INTO schema_migrations (version) VALUES ('20141128075349');

INSERT INTO schema_migrations (version) VALUES ('20141211175513');

INSERT INTO schema_migrations (version) VALUES ('20141218170138');

INSERT INTO schema_migrations (version) VALUES ('20141219110607');

INSERT INTO schema_migrations (version) VALUES ('20141219110658');

INSERT INTO schema_migrations (version) VALUES ('20141219160721');

INSERT INTO schema_migrations (version) VALUES ('20141224143422');

INSERT INTO schema_migrations (version) VALUES ('20150108153710');

INSERT INTO schema_migrations (version) VALUES ('20150108160914');

INSERT INTO schema_migrations (version) VALUES ('20150114171839');

INSERT INTO schema_migrations (version) VALUES ('20150201145937');

INSERT INTO schema_migrations (version) VALUES ('20150216164150');

INSERT INTO schema_migrations (version) VALUES ('20150216190226');

INSERT INTO schema_migrations (version) VALUES ('20150217120737');

INSERT INTO schema_migrations (version) VALUES ('20150228065448');

INSERT INTO schema_migrations (version) VALUES ('20150228082413');

INSERT INTO schema_migrations (version) VALUES ('20150301060034');

INSERT INTO schema_migrations (version) VALUES ('20150305053822');

INSERT INTO schema_migrations (version) VALUES ('20150306183346');

INSERT INTO schema_migrations (version) VALUES ('20150308055851');

INSERT INTO schema_migrations (version) VALUES ('20150313072158');

INSERT INTO schema_migrations (version) VALUES ('20150406094929');

INSERT INTO schema_migrations (version) VALUES ('20150409102628');

INSERT INTO schema_migrations (version) VALUES ('20150412040011');

INSERT INTO schema_migrations (version) VALUES ('20150421092204');

INSERT INTO schema_migrations (version) VALUES ('20150427135922');

INSERT INTO schema_migrations (version) VALUES ('20150427143207');

INSERT INTO schema_migrations (version) VALUES ('20150612142345');

INSERT INTO schema_migrations (version) VALUES ('20150624082959');

INSERT INTO schema_migrations (version) VALUES ('20150715154323');

INSERT INTO schema_migrations (version) VALUES ('20150722090032');

INSERT INTO schema_migrations (version) VALUES ('20150723081420');

INSERT INTO schema_migrations (version) VALUES ('20150728052541');

INSERT INTO schema_migrations (version) VALUES ('20150728052954');

INSERT INTO schema_migrations (version) VALUES ('20150728053441');

INSERT INTO schema_migrations (version) VALUES ('20150808171641');

INSERT INTO schema_migrations (version) VALUES ('20150821051110');

INSERT INTO schema_migrations (version) VALUES ('20150821051358');

INSERT INTO schema_migrations (version) VALUES ('20150826065253');

INSERT INTO schema_migrations (version) VALUES ('20150831165850');

INSERT INTO schema_migrations (version) VALUES ('20150901083301');

INSERT INTO schema_migrations (version) VALUES ('20150907084252');

INSERT INTO schema_migrations (version) VALUES ('20150909104949');

INSERT INTO schema_migrations (version) VALUES ('20150914102909');

INSERT INTO schema_migrations (version) VALUES ('20150914103009');

INSERT INTO schema_migrations (version) VALUES ('20150914103109');

INSERT INTO schema_migrations (version) VALUES ('20150915085427');

INSERT INTO schema_migrations (version) VALUES ('20150915095324');

INSERT INTO schema_migrations (version) VALUES ('20150921091114');

INSERT INTO schema_migrations (version) VALUES ('20150921091404');

INSERT INTO schema_migrations (version) VALUES ('20150923161105');

INSERT INTO schema_migrations (version) VALUES ('20150928154431');

INSERT INTO schema_migrations (version) VALUES ('20150930095546');

INSERT INTO schema_migrations (version) VALUES ('20151002060324');

INSERT INTO schema_migrations (version) VALUES ('20151009100851');

INSERT INTO schema_migrations (version) VALUES ('20151013084651');

INSERT INTO schema_migrations (version) VALUES ('20151016085049');

INSERT INTO schema_migrations (version) VALUES ('20151021161724');

INSERT INTO schema_migrations (version) VALUES ('20151021161818');

INSERT INTO schema_migrations (version) VALUES ('20151021163506');

INSERT INTO schema_migrations (version) VALUES ('20151023111243');

INSERT INTO schema_migrations (version) VALUES ('20151023111720');

INSERT INTO schema_migrations (version) VALUES ('20151023111938');

INSERT INTO schema_migrations (version) VALUES ('20151030103407');

INSERT INTO schema_migrations (version) VALUES ('20151101223552');

INSERT INTO schema_migrations (version) VALUES ('20151102154643');

INSERT INTO schema_migrations (version) VALUES ('20151112105603');

INSERT INTO schema_migrations (version) VALUES ('20151209101344');

INSERT INTO schema_migrations (version) VALUES ('20160107065147');

INSERT INTO schema_migrations (version) VALUES ('20160107093009');

INSERT INTO schema_migrations (version) VALUES ('20160111104245');

INSERT INTO schema_migrations (version) VALUES ('20160111105423');

INSERT INTO schema_migrations (version) VALUES ('20160112081924');

INSERT INTO schema_migrations (version) VALUES ('20160112083017');

INSERT INTO schema_migrations (version) VALUES ('20160127072439');

INSERT INTO schema_migrations (version) VALUES ('20160222074243');

INSERT INTO schema_migrations (version) VALUES ('20160222074636');

INSERT INTO schema_migrations (version) VALUES ('20160308064956');

INSERT INTO schema_migrations (version) VALUES ('20160309105538');

INSERT INTO schema_migrations (version) VALUES ('20160322123833');

INSERT INTO schema_migrations (version) VALUES ('20160323064600');

INSERT INTO schema_migrations (version) VALUES ('20160323074945');

INSERT INTO schema_migrations (version) VALUES ('20160323075112');

INSERT INTO schema_migrations (version) VALUES ('20160330033850');

INSERT INTO schema_migrations (version) VALUES ('20160330034103');

INSERT INTO schema_migrations (version) VALUES ('20160330042049');

INSERT INTO schema_migrations (version) VALUES ('20160330131651');

INSERT INTO schema_migrations (version) VALUES ('20160331042433');

INSERT INTO schema_migrations (version) VALUES ('20160331042455');

INSERT INTO schema_migrations (version) VALUES ('20160331050339');

INSERT INTO schema_migrations (version) VALUES ('20160331053200');

INSERT INTO schema_migrations (version) VALUES ('20160405054048');

INSERT INTO schema_migrations (version) VALUES ('20160405054255');

INSERT INTO schema_migrations (version) VALUES ('20160405103729');

INSERT INTO schema_migrations (version) VALUES ('20160405114000');

INSERT INTO schema_migrations (version) VALUES ('20160408071021');

INSERT INTO schema_migrations (version) VALUES ('20160408071053');

INSERT INTO schema_migrations (version) VALUES ('20160422102107');

