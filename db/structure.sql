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
-- Name: comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    post_id integer,
    user_id integer,
    message text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    post_user_id integer
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
    updated_at timestamp without time zone
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
-- Name: payment_failures; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE payment_failures (
    id integer NOT NULL,
    user_id integer,
    target_id integer,
    target_type character varying(255),
    exception_data text,
    stripe_charge_data text,
    description text
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
    description text
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
    type character varying(255)
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
    ordering integer DEFAULT 0 NOT NULL
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
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE subscriptions (
    id integer NOT NULL,
    user_id integer,
    target_id integer,
    target_type character varying(255),
    target_user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
    basename text
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
    password_salt character varying(255),
    password_hash character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    full_name character varying(512),
    subscription_cost double precision,
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
    subscription_fees double precision,
    cost integer,
    password_reset_token character varying(255),
    has_public_profile boolean DEFAULT false
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

ALTER TABLE ONLY likes ALTER COLUMN id SET DEFAULT nextval('likes_id_seq'::regclass);


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
-- Name: likes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


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
