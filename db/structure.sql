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
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


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
    hidden boolean DEFAULT false NOT NULL
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
-- Name: cost_change_requests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cost_change_requests (
    id integer NOT NULL,
    new_cost integer,
    old_cost integer,
    approved boolean DEFAULT false NOT NULL,
    rejected boolean DEFAULT false NOT NULL,
    performed boolean DEFAULT false NOT NULL,
    update_existing_subscriptions boolean DEFAULT false NOT NULL,
    user_id integer,
    approved_at timestamp without time zone,
    rejected_at timestamp without time zone,
    performed_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: cost_change_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cost_change_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cost_change_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cost_change_requests_id_seq OWNED BY cost_change_requests.id;


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
    locked_by character varying(255),
    queue character varying(255),
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
    action character varying(255),
    message character varying(255),
    data text,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
    type character varying(255),
    target_id integer,
    target_type character varying(255),
    target_user_id integer,
    subscription_target_user_id integer,
    data text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
    likable_type character varying(255),
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
    contribution_id integer
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
    target_type character varying(255),
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
    target_type character varying(255),
    user_id integer,
    amount integer,
    stripe_charge_data text,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    target_user_id integer,
    cost integer,
    subscription_fees integer,
    subscription_cost integer
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
    type character varying(255),
    hidden boolean DEFAULT false NOT NULL
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
-- Name: profile_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE profile_types (
    id integer NOT NULL,
    title character varying(255),
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
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: stripe_transfers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stripe_transfers (
    id integer NOT NULL,
    user_id integer,
    stripe_response text,
    amount integer,
    description character varying(255),
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
    target_type character varying(255),
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
    charge_date timestamp without time zone
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
-- Name: uploads; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE uploads (
    id integer NOT NULL,
    uploadable_id integer,
    uploadable_type character varying(255),
    transloadit_data text,
    user_id integer,
    duration double precision,
    type character varying(255),
    mime_type character varying(255),
    width integer,
    height integer,
    preview_url character varying(255),
    url character varying(255),
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
    low_quality_playlist_url text
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
    slug character varying(255),
    email character varying(255),
    password_hash character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    full_name character varying(512),
    subscription_cost integer,
    holder_name character varying(255),
    routing_number character varying(255),
    account_number character varying(255),
    stripe_user_id character varying(255),
    stripe_card_id character varying(255),
    last_four_cc_numbers character varying(255),
    card_type character varying(255),
    profile_picture_url text,
    original_profile_picture_url text,
    cover_picture_url text,
    original_cover_picture_url text,
    is_profile_owner boolean DEFAULT false NOT NULL,
    has_complete_profile boolean DEFAULT false NOT NULL,
    profile_name character varying(512),
    is_admin boolean DEFAULT false NOT NULL,
    contacts_info text,
    auth_token character varying(255),
    cover_picture_position integer DEFAULT 0 NOT NULL,
    subscription_fees integer,
    cost integer,
    password_reset_token character varying(255),
    has_public_profile boolean DEFAULT false,
    company_name character varying(255),
    small_profile_picture_url text,
    account_picture_url text,
    small_account_picture_url text,
    original_account_picture_url text,
    cost_changed_at timestamp without time zone,
    activated boolean DEFAULT false NOT NULL,
    registration_token character varying(255),
    rss_enabled boolean DEFAULT false NOT NULL,
    downloads_enabled boolean DEFAULT true NOT NULL,
    itunes_enabled boolean DEFAULT true NOT NULL,
    profile_types_text text,
    subscribers_count integer DEFAULT 0 NOT NULL,
    billing_failed boolean DEFAULT false NOT NULL,
    stripe_recipient_id character varying(255),
    billing_failed_at timestamp without time zone,
    vacation_enabled boolean DEFAULT false NOT NULL,
    vacation_message text,
    last_visited_profile_id integer,
    vacation_enabled_at timestamp without time zone,
    billing_address_city character varying(255),
    billing_address_state character varying(255),
    billing_address_zip character varying(255),
    billing_address_line_1 text,
    billing_address_line_2 text,
    contributions_enabled boolean DEFAULT true NOT NULL,
    notifications_debug_enabled boolean DEFAULT true,
    custom_profile_page_css text,
    api_token character varying(255)
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

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contributions ALTER COLUMN id SET DEFAULT nextval('contributions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cost_change_requests ALTER COLUMN id SET DEFAULT nextval('cost_change_requests_id_seq'::regclass);


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

ALTER TABLE ONLY profile_types ALTER COLUMN id SET DEFAULT nextval('profile_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY profile_types_users ALTER COLUMN id SET DEFAULT nextval('profile_types_users_id_seq'::regclass);


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
-- Name: cost_change_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cost_change_requests
    ADD CONSTRAINT cost_change_requests_pkey PRIMARY KEY (id);


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

INSERT INTO schema_migrations (version) VALUES ('20150301060034');

INSERT INTO schema_migrations (version) VALUES ('20150305053822');

INSERT INTO schema_migrations (version) VALUES ('20150306183346');

INSERT INTO schema_migrations (version) VALUES ('20150308055851');

INSERT INTO schema_migrations (version) VALUES ('20150309035722');

