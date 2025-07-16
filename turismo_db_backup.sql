--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: actividad_punto_turistico; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.actividad_punto_turistico (
    id integer NOT NULL,
    id_punto_turistico integer,
    actividad character varying(255) NOT NULL,
    precio numeric(10,2),
    estado character varying(20) NOT NULL,
    creado_por character varying(255),
    editado_por character varying(255),
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_ultima_edicion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    trial228 character(1),
    tipo character varying(50)
);


ALTER TABLE public.actividad_punto_turistico OWNER TO tursd;

--
-- Name: actividad_punto_turistico_id_seq; Type: SEQUENCE; Schema: public; Owner: tursd
--

CREATE SEQUENCE public.actividad_punto_turistico_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.actividad_punto_turistico_id_seq OWNER TO tursd;

--
-- Name: actividad_punto_turistico_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tursd
--

ALTER SEQUENCE public.actividad_punto_turistico_id_seq OWNED BY public.actividad_punto_turistico.id;


--
-- Name: administradores; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.administradores (
    id integer NOT NULL,
    nombre character varying(255) NOT NULL,
    apellido character varying(255) NOT NULL,
    cedula character varying(20) NOT NULL,
    telefono character varying(20) NOT NULL,
    email character varying(255) NOT NULL,
    departamento character varying(255) NOT NULL,
    contrasena character varying(255) NOT NULL,
    estado character varying(20) NOT NULL,
    creado_por character varying(255),
    editado_por character varying(255),
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_ultima_edicion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    trial106 character(1)
);


ALTER TABLE public.administradores OWNER TO tursd;

--
-- Name: administradores_id_seq; Type: SEQUENCE; Schema: public; Owner: tursd
--

CREATE SEQUENCE public.administradores_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.administradores_id_seq OWNER TO tursd;

--
-- Name: administradores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tursd
--

ALTER SEQUENCE public.administradores_id_seq OWNED BY public.administradores.id;


--
-- Name: anuncios; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.anuncios (
    id integer NOT NULL,
    nombre character varying(250) NOT NULL,
    descripcion text NOT NULL,
    estado character varying(20) NOT NULL,
    creado_por character varying(255),
    editado_por character varying(255),
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_ultima_edicion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    trial106 character(1)
);


ALTER TABLE public.anuncios OWNER TO tursd;

--
-- Name: anuncios_id_seq; Type: SEQUENCE; Schema: public; Owner: tursd
--

CREATE SEQUENCE public.anuncios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.anuncios_id_seq OWNER TO tursd;

--
-- Name: anuncios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tursd
--

ALTER SEQUENCE public.anuncios_id_seq OWNED BY public.anuncios.id;


--
-- Name: asistente; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.asistente (
    id integer NOT NULL,
    nombre character varying(255) NOT NULL,
    apellido character varying(255) NOT NULL,
    cedula character varying(20) NOT NULL,
    telefono character varying(20) NOT NULL,
    email character varying(255) NOT NULL,
    contrasena character varying(255) NOT NULL,
    estado character varying(20) NOT NULL,
    creado_por character varying(255),
    editado_por character varying(255),
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_ultima_edicion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    trial110 character(1)
);


ALTER TABLE public.asistente OWNER TO tursd;

--
-- Name: asistente_id_seq; Type: SEQUENCE; Schema: public; Owner: tursd
--

CREATE SEQUENCE public.asistente_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.asistente_id_seq OWNER TO tursd;

--
-- Name: asistente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tursd
--

ALTER SEQUENCE public.asistente_id_seq OWNED BY public.asistente.id;


--
-- Name: cache; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.cache (
    key character varying(255) NOT NULL,
    value text NOT NULL,
    expiration integer NOT NULL,
    trial110 character(1)
);


ALTER TABLE public.cache OWNER TO tursd;

--
-- Name: cache_locks; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.cache_locks (
    key character varying(255) NOT NULL,
    owner character varying(255) NOT NULL,
    expiration integer NOT NULL,
    trial110 character(1)
);


ALTER TABLE public.cache_locks OWNER TO tursd;

--
-- Name: duenos_locales; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.duenos_locales (
    id integer NOT NULL,
    nombre character varying(255) NOT NULL,
    apellido character varying(255) NOT NULL,
    cedula character varying(20) NOT NULL,
    telefono character varying(20) NOT NULL,
    email character varying(255) NOT NULL,
    contrasena character varying(255) NOT NULL,
    estado character varying(20) NOT NULL,
    creado_por character varying(255),
    editado_por character varying(255),
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_ultima_edicion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    trial110 character(1)
);


ALTER TABLE public.duenos_locales OWNER TO tursd;

--
-- Name: duenos_locales_id_seq; Type: SEQUENCE; Schema: public; Owner: tursd
--

CREATE SEQUENCE public.duenos_locales_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.duenos_locales_id_seq OWNER TO tursd;

--
-- Name: duenos_locales_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tursd
--

ALTER SEQUENCE public.duenos_locales_id_seq OWNED BY public.duenos_locales.id;


--
-- Name: estado_vias; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.estado_vias (
    id integer NOT NULL,
    nombre_via character varying(255) NOT NULL,
    estado character varying(20) NOT NULL,
    comentarios text,
    eliminado character varying(10),
    creado_por character varying(255),
    editado_por character varying(255),
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_ultima_edicion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    trial110 character(1)
);


ALTER TABLE public.estado_vias OWNER TO tursd;

--
-- Name: estado_vias_id_seq; Type: SEQUENCE; Schema: public; Owner: tursd
--

CREATE SEQUENCE public.estado_vias_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.estado_vias_id_seq OWNER TO tursd;

--
-- Name: estado_vias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tursd
--

ALTER SEQUENCE public.estado_vias_id_seq OWNED BY public.estado_vias.id;


--
-- Name: etiquetas_turisticas; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.etiquetas_turisticas (
    id integer NOT NULL,
    nombre character varying(255) NOT NULL,
    descripcion text,
    estado character varying(20) NOT NULL,
    creado_por character varying(255),
    editado_por character varying(255),
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_ultima_edicion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    trial110 character(1)
);


ALTER TABLE public.etiquetas_turisticas OWNER TO tursd;

--
-- Name: etiquetas_turisticas_id_seq; Type: SEQUENCE; Schema: public; Owner: tursd
--

CREATE SEQUENCE public.etiquetas_turisticas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.etiquetas_turisticas_id_seq OWNER TO tursd;

--
-- Name: etiquetas_turisticas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tursd
--

ALTER SEQUENCE public.etiquetas_turisticas_id_seq OWNED BY public.etiquetas_turisticas.id;


--
-- Name: failed_jobs; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.failed_jobs (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    connection text NOT NULL,
    queue text NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    trial110 character(1)
);


ALTER TABLE public.failed_jobs OWNER TO tursd;

--
-- Name: failed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: tursd
--

CREATE SEQUENCE public.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.failed_jobs_id_seq OWNER TO tursd;

--
-- Name: failed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tursd
--

ALTER SEQUENCE public.failed_jobs_id_seq OWNED BY public.failed_jobs.id;


--
-- Name: horarios_atencion; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.horarios_atencion (
    id integer NOT NULL,
    id_local integer NOT NULL,
    dia_semana character varying(20) NOT NULL,
    hora_inicio time without time zone NOT NULL,
    hora_fin time without time zone NOT NULL,
    estado character varying(20) NOT NULL,
    creado_por character varying(255),
    editado_por character varying(255),
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_ultima_edicion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    trial110 character(1)
);


ALTER TABLE public.horarios_atencion OWNER TO tursd;

--
-- Name: horarios_atencion_id_seq; Type: SEQUENCE; Schema: public; Owner: tursd
--

CREATE SEQUENCE public.horarios_atencion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.horarios_atencion_id_seq OWNER TO tursd;

--
-- Name: horarios_atencion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tursd
--

ALTER SEQUENCE public.horarios_atencion_id_seq OWNED BY public.horarios_atencion.id;


--
-- Name: imagenes; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.imagenes (
    id integer NOT NULL,
    id_entidad integer NOT NULL,
    tipo character varying(50) NOT NULL,
    ruta_imagen character varying(255) NOT NULL,
    descripcion character varying(255),
    estado character varying(20) NOT NULL,
    creado_por character varying(255),
    editado_por character varying(255),
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_ultima_edicion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    trial110 character(1)
);


ALTER TABLE public.imagenes OWNER TO tursd;

--
-- Name: imagenes_id_seq; Type: SEQUENCE; Schema: public; Owner: tursd
--

CREATE SEQUENCE public.imagenes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.imagenes_id_seq OWNER TO tursd;

--
-- Name: imagenes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tursd
--

ALTER SEQUENCE public.imagenes_id_seq OWNED BY public.imagenes.id;


--
-- Name: informacion_general; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.informacion_general (
    id integer NOT NULL,
    mision text,
    vision text,
    detalles text,
    encargado character varying(255),
    version_aplicacion character varying(50),
    estado character varying(20) NOT NULL,
    creado_por character varying(255),
    editado_por character varying(255),
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_ultima_edicion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    trial110 character(1)
);


ALTER TABLE public.informacion_general OWNER TO tursd;

--
-- Name: informacion_general_id_seq; Type: SEQUENCE; Schema: public; Owner: tursd
--

CREATE SEQUENCE public.informacion_general_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.informacion_general_id_seq OWNER TO tursd;

--
-- Name: informacion_general_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tursd
--

ALTER SEQUENCE public.informacion_general_id_seq OWNED BY public.informacion_general.id;


--
-- Name: job_batches; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.job_batches (
    id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    total_jobs integer NOT NULL,
    pending_jobs integer NOT NULL,
    failed_jobs integer NOT NULL,
    failed_job_ids text NOT NULL,
    options text,
    cancelled_at integer,
    created_at integer NOT NULL,
    finished_at integer,
    trial110 character(1)
);


ALTER TABLE public.job_batches OWNER TO tursd;

--
-- Name: jobs; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.jobs (
    id bigint NOT NULL,
    queue character varying(255) NOT NULL,
    payload text NOT NULL,
    attempts smallint NOT NULL,
    reserved_at bigint,
    available_at bigint NOT NULL,
    created_at bigint NOT NULL,
    trial113 character(1)
);


ALTER TABLE public.jobs OWNER TO tursd;

--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: tursd
--

CREATE SEQUENCE public.jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.jobs_id_seq OWNER TO tursd;

--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tursd
--

ALTER SEQUENCE public.jobs_id_seq OWNED BY public.jobs.id;


--
-- Name: local_etiqueta; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.local_etiqueta (
    id_local integer NOT NULL,
    id_etiqueta integer NOT NULL,
    estado character varying(20) NOT NULL,
    creado_por character varying(255),
    editado_por character varying(255),
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_ultima_edicion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    trial113 character(1)
);


ALTER TABLE public.local_etiqueta OWNER TO tursd;

--
-- Name: locales_turisticos; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.locales_turisticos (
    id integer NOT NULL,
    nombre character varying(255) NOT NULL,
    descripcion text,
    id_dueno integer,
    direccion character varying(255),
    latitud numeric(9,6),
    longitud numeric(9,6),
    id_parroquia integer,
    estado character varying(20) NOT NULL,
    creado_por character varying(255),
    editado_por character varying(255),
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_ultima_edicion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    trial110 character(1)
);


ALTER TABLE public.locales_turisticos OWNER TO tursd;

--
-- Name: locales_turisticos_id_seq; Type: SEQUENCE; Schema: public; Owner: tursd
--

CREATE SEQUENCE public.locales_turisticos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.locales_turisticos_id_seq OWNER TO tursd;

--
-- Name: locales_turisticos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tursd
--

ALTER SEQUENCE public.locales_turisticos_id_seq OWNED BY public.locales_turisticos.id;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL,
    trial113 character(1)
);


ALTER TABLE public.migrations OWNER TO tursd;

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: tursd
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.migrations_id_seq OWNER TO tursd;

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tursd
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: parroquias; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.parroquias (
    id integer NOT NULL,
    nombre character varying(255) NOT NULL,
    fecha_fundacion character varying(255) NOT NULL,
    poblacion character varying(255) NOT NULL,
    temperatura_promedio character varying(255) NOT NULL,
    descripcion text,
    estado character varying(20) NOT NULL,
    creado_por character varying(255),
    editado_por character varying(255),
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_ultima_edicion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    trial110 character(1)
);


ALTER TABLE public.parroquias OWNER TO tursd;

--
-- Name: parroquias_id_seq; Type: SEQUENCE; Schema: public; Owner: tursd
--

CREATE SEQUENCE public.parroquias_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.parroquias_id_seq OWNER TO tursd;

--
-- Name: parroquias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tursd
--

ALTER SEQUENCE public.parroquias_id_seq OWNED BY public.parroquias.id;


--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.password_reset_tokens (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp without time zone,
    trial113 character(1)
);


ALTER TABLE public.password_reset_tokens OWNER TO tursd;

--
-- Name: personal_access_tokens; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.personal_access_tokens (
    id bigint NOT NULL,
    tokenable_type character varying(255) NOT NULL,
    tokenable_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    token character varying(64) NOT NULL,
    abilities text,
    last_used_at timestamp without time zone,
    expires_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    trial113 character(1)
);


ALTER TABLE public.personal_access_tokens OWNER TO tursd;

--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: tursd
--

CREATE SEQUENCE public.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.personal_access_tokens_id_seq OWNER TO tursd;

--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tursd
--

ALTER SEQUENCE public.personal_access_tokens_id_seq OWNED BY public.personal_access_tokens.id;


--
-- Name: puntos_turisticos; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.puntos_turisticos (
    id integer NOT NULL,
    nombre character varying(255) NOT NULL,
    descripcion text,
    latitud numeric(9,6),
    longitud numeric(9,6),
    id_parroquia integer,
    estado character varying(20) NOT NULL,
    creado_por character varying(255),
    editado_por character varying(255),
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_ultima_edicion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    trial113 character(1)
);


ALTER TABLE public.puntos_turisticos OWNER TO tursd;

--
-- Name: puntos_turisticos_etiqueta; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.puntos_turisticos_etiqueta (
    id_punto_turistico integer NOT NULL,
    id_etiqueta integer NOT NULL,
    estado character varying(20) NOT NULL,
    creado_por character varying(255),
    editado_por character varying(255),
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_ultima_edicion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    trial113 character(1)
);


ALTER TABLE public.puntos_turisticos_etiqueta OWNER TO tursd;

--
-- Name: puntos_turisticos_id_seq; Type: SEQUENCE; Schema: public; Owner: tursd
--

CREATE SEQUENCE public.puntos_turisticos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.puntos_turisticos_id_seq OWNER TO tursd;

--
-- Name: puntos_turisticos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tursd
--

ALTER SEQUENCE public.puntos_turisticos_id_seq OWNED BY public.puntos_turisticos.id;


--
-- Name: servicios_locales; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.servicios_locales (
    id integer NOT NULL,
    id_local integer,
    servicio character varying(255) NOT NULL,
    precio numeric(10,2) NOT NULL,
    tipo character varying(255) NOT NULL,
    estado character varying(20) NOT NULL,
    creado_por character varying(255),
    editado_por character varying(255),
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_ultima_edicion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    trial113 character(1)
);


ALTER TABLE public.servicios_locales OWNER TO tursd;

--
-- Name: servicios_locales_id_seq; Type: SEQUENCE; Schema: public; Owner: tursd
--

CREATE SEQUENCE public.servicios_locales_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.servicios_locales_id_seq OWNER TO tursd;

--
-- Name: servicios_locales_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tursd
--

ALTER SEQUENCE public.servicios_locales_id_seq OWNED BY public.servicios_locales.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.sessions (
    id character varying(255) NOT NULL,
    user_id bigint,
    ip_address character varying(45),
    user_agent text,
    payload text NOT NULL,
    last_activity integer NOT NULL,
    trial113 character(1)
);


ALTER TABLE public.sessions OWNER TO tursd;

--
-- Name: top_lugares; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.top_lugares (
    id integer NOT NULL,
    tipo character varying(20) NOT NULL,
    nombre character varying(255) NOT NULL,
    descripcion text,
    puntos integer DEFAULT 0 NOT NULL,
    estado character varying(20) DEFAULT 'activo'::character varying NOT NULL,
    comentarios text,
    creado_por character varying(255),
    editado_por character varying(255),
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_ultima_edicion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.top_lugares OWNER TO tursd;

--
-- Name: top_lugares_id_seq; Type: SEQUENCE; Schema: public; Owner: tursd
--

CREATE SEQUENCE public.top_lugares_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.top_lugares_id_seq OWNER TO tursd;

--
-- Name: top_lugares_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tursd
--

ALTER SEQUENCE public.top_lugares_id_seq OWNED BY public.top_lugares.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: tursd
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    email_verified_at timestamp without time zone,
    password character varying(255) NOT NULL,
    estado character varying(20) NOT NULL,
    tipo character varying(20) NOT NULL,
    remember_token character varying(100),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    trial113 character(1)
);


ALTER TABLE public.users OWNER TO tursd;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: tursd
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO tursd;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tursd
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: actividad_punto_turistico id; Type: DEFAULT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.actividad_punto_turistico ALTER COLUMN id SET DEFAULT nextval('public.actividad_punto_turistico_id_seq'::regclass);


--
-- Name: administradores id; Type: DEFAULT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.administradores ALTER COLUMN id SET DEFAULT nextval('public.administradores_id_seq'::regclass);


--
-- Name: anuncios id; Type: DEFAULT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.anuncios ALTER COLUMN id SET DEFAULT nextval('public.anuncios_id_seq'::regclass);


--
-- Name: asistente id; Type: DEFAULT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.asistente ALTER COLUMN id SET DEFAULT nextval('public.asistente_id_seq'::regclass);


--
-- Name: duenos_locales id; Type: DEFAULT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.duenos_locales ALTER COLUMN id SET DEFAULT nextval('public.duenos_locales_id_seq'::regclass);


--
-- Name: estado_vias id; Type: DEFAULT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.estado_vias ALTER COLUMN id SET DEFAULT nextval('public.estado_vias_id_seq'::regclass);


--
-- Name: etiquetas_turisticas id; Type: DEFAULT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.etiquetas_turisticas ALTER COLUMN id SET DEFAULT nextval('public.etiquetas_turisticas_id_seq'::regclass);


--
-- Name: failed_jobs id; Type: DEFAULT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.failed_jobs ALTER COLUMN id SET DEFAULT nextval('public.failed_jobs_id_seq'::regclass);


--
-- Name: horarios_atencion id; Type: DEFAULT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.horarios_atencion ALTER COLUMN id SET DEFAULT nextval('public.horarios_atencion_id_seq'::regclass);


--
-- Name: imagenes id; Type: DEFAULT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.imagenes ALTER COLUMN id SET DEFAULT nextval('public.imagenes_id_seq'::regclass);


--
-- Name: informacion_general id; Type: DEFAULT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.informacion_general ALTER COLUMN id SET DEFAULT nextval('public.informacion_general_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public.jobs_id_seq'::regclass);


--
-- Name: locales_turisticos id; Type: DEFAULT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.locales_turisticos ALTER COLUMN id SET DEFAULT nextval('public.locales_turisticos_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: parroquias id; Type: DEFAULT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.parroquias ALTER COLUMN id SET DEFAULT nextval('public.parroquias_id_seq'::regclass);


--
-- Name: personal_access_tokens id; Type: DEFAULT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.personal_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.personal_access_tokens_id_seq'::regclass);


--
-- Name: puntos_turisticos id; Type: DEFAULT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.puntos_turisticos ALTER COLUMN id SET DEFAULT nextval('public.puntos_turisticos_id_seq'::regclass);


--
-- Name: servicios_locales id; Type: DEFAULT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.servicios_locales ALTER COLUMN id SET DEFAULT nextval('public.servicios_locales_id_seq'::regclass);


--
-- Name: top_lugares id; Type: DEFAULT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.top_lugares ALTER COLUMN id SET DEFAULT nextval('public.top_lugares_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: actividad_punto_turistico; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.actividad_punto_turistico (id, id_punto_turistico, actividad, precio, estado, creado_por, editado_por, fecha_creacion, fecha_ultima_edicion, trial228, tipo) FROM stdin;
2	2	Natación	\N	activo	Jenniffer Gomez	\N	2025-01-03 19:04:24.805787	2025-01-03 19:04:24.805787	\N	Natación
3	2	Caminatas	\N	activo	Jenniffer Gomez	\N	2025-01-03 19:05:23.542063	2025-01-03 19:05:23.542063	\N	Caminatas
1	1	Miradores	\N	activo	Jenniffer Gomez	Jessie Contreras	2024-12-30 17:12:02.564845	2024-12-30 17:12:02.564845	\N	Miradores
5	3	Chamanes Tsáchilas	\N	activo	Jessie Contreras	\N	2025-01-08 19:16:01.96405	2025-01-08 19:16:01.96405	\N	Baños
6	3	Creencias	\N	activo	Jessie Contreras	\N	2025-01-08 19:17:36.021297	2025-01-08 19:17:36.021297	\N	Rituales de purificación
7	3	Danzas	\N	activo	Jessie Contreras	\N	2025-01-08 19:20:46.399341	2025-01-08 19:20:46.399341	\N	Homenaje
4	2	Ciclismo	\N	inactivo	Jenniffer Gomez	\N	2025-01-03 19:06:35.026743	2025-01-03 19:06:35.026743	\N	Ciclismo
8	5	Senderismo	\N	activo	Jessie Contreras	\N	2025-01-09 10:53:25.006543	2025-01-09 10:53:25.006543	\N	Atractivos Recreativos
9	5	Aves	\N	activo	Jessie Contreras	\N	2025-01-09 10:54:03.689431	2025-01-09 10:54:03.689431	\N	Atractivos Recreativos
11	5	Felino	\N	activo	Jessie Contreras	\N	2025-01-09 10:54:52.325872	2025-01-09 10:54:52.325872	\N	Atractivos Recreativos
10	5	Entrada	\N	inactivo	Jessie Contreras	\N	2025-01-09 10:54:27.403562	2025-01-09 10:54:27.403562	\N	Atractivos Recreativos
12	6	Café	\N	activo	Jessie Contreras	\N	2025-01-11 14:22:33.104937	2025-01-11 14:22:33.104937	\N	Gastronomía
13	6	Aventura	\N	activo	Jessie Contreras	\N	2025-01-11 14:23:52.836126	2025-01-11 14:23:52.836126	\N	Atractivos Recreativos
14	6	Ferias	\N	activo	Jessie Contreras	\N	2025-01-11 14:24:53.518869	2025-01-11 14:24:53.518869	\N	Atractivos Recreativos
15	7	Flora	\N	activo	Jessie Contreras	\N	2025-01-11 14:34:39.929239	2025-01-11 14:34:39.929239	\N	Atractivos Recreativos
16	8	Sacramentos	\N	activo	Jessie Contreras	\N	2025-01-11 14:43:58.446915	2025-01-11 14:43:58.446915	\N	Servicios Religiosos
17	9	Iglesia	\N	activo	Jessie Contreras	\N	2025-01-11 14:49:40.151956	2025-01-11 14:49:40.151956	\N	Atractivos Recreativos
18	9	Caminatas	\N	activo	Jessie Contreras	\N	2025-01-11 14:50:59.462907	2025-01-11 14:50:59.462907	\N	Atractivos Recreativos
19	7	Fauna	\N	activo	Jessie Contreras	\N	2025-01-12 09:34:28.981039	2025-01-12 09:34:28.981039	\N	Atractivos Recreativos
20	7	Animales de la zona	\N	activo	Jessie Contreras	\N	2025-01-12 09:35:13.393199	2025-01-12 09:35:13.393199	\N	Atractivos Recreativos
21	7	Flora exótica	\N	activo	Jessie Contreras	\N	2025-01-12 09:35:48.677891	2025-01-12 09:35:48.677891	\N	Atractivos Recreativos
22	9	Actividades recreativas	\N	activo	Jessie Contreras	\N	2025-01-12 10:09:30.795122	2025-01-12 10:09:30.795122	\N	Atractivos Recreativos
23	9	Caminata	\N	activo	Jessie Contreras	\N	2025-01-12 10:10:13.812428	2025-01-12 10:10:13.812428	\N	Atractivos Recreativos
24	9	Parqueaderos	\N	activo	Jessie Contreras	\N	2025-01-12 10:11:24.568765	2025-01-12 10:11:24.568765	\N	Atractivos Recreativos
25	6	Parque	\N	activo	Jessie Contreras	\N	2025-01-13 09:15:36.073818	2025-01-13 09:15:36.073818	\N	Atractivos Recreativos
26	6	Deportes Extremos	\N	activo	Jessie Contreras	\N	2025-01-13 09:16:48.437512	2025-01-13 09:16:48.437512	\N	Atractivos Recreativos
27	6	Áreas Verdes	\N	activo	Jessie Contreras	\N	2025-01-13 09:17:16.912504	2025-01-13 09:17:16.912504	\N	Atractivos Recreativos
28	6	Juegos recreativos	\N	activo	Jessie Contreras	\N	2025-01-13 09:17:49.85003	2025-01-13 09:17:49.85003	\N	Atractivos Recreativos
\.


--
-- Data for Name: administradores; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.administradores (id, nombre, apellido, cedula, telefono, email, departamento, contrasena, estado, creado_por, editado_por, fecha_creacion, fecha_ultima_edicion, trial106) FROM stdin;
1	Jessie	Contreras	0803413160	0981655688	jncontreras@espe.edu.ec	Administrativo	$2y$12$zAU3kBx4EDJm4mleaTr/j.2iwayJ8MOh.myEIf53dj54678n1r4Fu	activo	SuperAdmin	Jenniffer Gomez	2024-12-26 13:07:52.251916	2024-12-26 13:07:52.251916	\N
\.


--
-- Data for Name: anuncios; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.anuncios (id, nombre, descripcion, estado, creado_por, editado_por, fecha_creacion, fecha_ultima_edicion, trial106) FROM stdin;
1	Fiesta Parroquial Luz de America	Celebración anual de la parroquia con eventos culturales, música en vivo, y feria gastronómica.	activo	Jennifer Gómez	\N	2024-12-27 21:41:22	2025-01-08 22:08:33	\N
2	Fiesta de Cantonización Santo Domingo	Celebración anual de la cantonización con eventos culturales, música en vivo, y feria gastronómica.	activo	Jennifer Gómez	Jessie Contreras	2024-12-27 21:45:53	2025-01-09 14:39:42	\N
\.


--
-- Data for Name: asistente; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.asistente (id, nombre, apellido, cedula, telefono, email, contrasena, estado, creado_por, editado_por, fecha_creacion, fecha_ultima_edicion, trial110) FROM stdin;
2	Juan	Perez	0986325678	0981655600	jessiecontreras6@gmail.com	$2y$12$PVbWUDnyEMahNY5vncHYS.gt6OJB8pJPORPhpX.JKnn5DAAWqi7w6	activo	Jessie Contreras	\N	2025-01-13 15:04:56.076057	2025-01-13 15:04:56.076057	\N
1	Jenniffer	Gomez	1239876541	0912345678	jngomez@gmail.com	$2y$12$kO17ZIvrWxr6yTOR7Z.5y.andwdbJq3EymXaXM3uzXx6SP8AsD.zW	inactivo	Jenniffer Gomez	Jessie Contreras	2024-12-26 13:18:14.463239	2024-12-26 13:18:14.463239	\N
3	Luis	Solorzano	2350639650	0988411223	lasolorzano@gmail.com	$2y$12$nzlaMIPTTGcQZaMzKaMLwecEMyOHHEfRR3RV9nBzH6.HZcssaAU4e	activo	Jessie Contreras	Jessie Contreras	2025-01-15 10:41:39.89605	2025-01-15 10:41:39.89605	\N
\.


--
-- Data for Name: cache; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.cache (key, value, expiration, trial110) FROM stdin;
\.


--
-- Data for Name: cache_locks; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.cache_locks (key, owner, expiration, trial110) FROM stdin;
\.


--
-- Data for Name: duenos_locales; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.duenos_locales (id, nombre, apellido, cedula, telefono, email, contrasena, estado, creado_por, editado_por, fecha_creacion, fecha_ultima_edicion, trial110) FROM stdin;
1	Patrimonio	Natural	08887654321	0989009555	patrimonio.jc@dominio.com	$2y$12$1Z1vOS1kmQ8ByY1NhLrNru/nSYSDtuEpR.XbaLRZZshrlsa/nqCOi	activo	Jenniffer Gomez	Jenniffer Gomez	2024-12-27 11:54:11.829191	2024-12-27 11:54:11.829191	\N
2	Rosita	Cuases	0803413160	0981655003	RositaCuases@example.ec	$2y$12$v6QR3KWonOtJ7qOwqMG1FOVYcbm9dJG6gruYqjWkGUhbWDhzhLlEC	activo	Jessie Contreras	Jessie Contreras	2025-01-09 09:51:21.376819	2025-01-09 09:51:21.376819	\N
3	Pedro	Pérez	1204145443	0935456624	pedro12@gmail.com	$2y$12$CcjhyF43Tf1rTmlJQlanpetBSxGQQT125O6xzJs7RaNE6ByodMF12	activo	Jessie Contreras	\N	2025-01-27 09:12:42.648022	2025-01-27 09:12:42.648022	\N
\.


--
-- Data for Name: estado_vias; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.estado_vias (id, nombre_via, estado, comentarios, eliminado, creado_por, editado_por, fecha_creacion, fecha_ultima_edicion, trial110) FROM stdin;
\.


--
-- Data for Name: etiquetas_turisticas; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.etiquetas_turisticas (id, nombre, descripcion, estado, creado_por, editado_por, fecha_creacion, fecha_ultima_edicion, trial110) FROM stdin;
1	Étnia Tsáchila	Étnia Tsáchila	activo	Jenniffer Gomez	\N	2024-12-26 13:23:32.142479	2024-12-26 13:23:32.142479	\N
3	Alojamientos	Alojamientos	activo	Jenniffer Gomez	\N	2024-12-26 13:25:38.197151	2024-12-26 13:25:38.197151	\N
5	Parques	Parques	activo	Jenniffer Gomez	\N	2024-12-26 13:28:10.841099	2024-12-26 13:28:10.841099	\N
6	Rios	Rios	activo	Jenniffer Gomez	\N	2024-12-26 13:30:03.607477	2024-12-26 13:30:03.607477	\N
4	Atracciones Estables	Atracciones Estables	activo	Jenniffer Gomez	Jessie Contreras	2024-12-26 13:26:55.743255	2024-12-26 13:26:55.743255	\N
2	Alimentos	Alimentos	activo	Jenniffer Gomez	Jessie Contreras	2024-12-26 13:24:38.548808	2024-12-26 13:24:38.548808	\N
\.


--
-- Data for Name: failed_jobs; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.failed_jobs (id, uuid, connection, queue, payload, exception, failed_at, trial110) FROM stdin;
\.


--
-- Data for Name: horarios_atencion; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.horarios_atencion (id, id_local, dia_semana, hora_inicio, hora_fin, estado, creado_por, editado_por, fecha_creacion, fecha_ultima_edicion, trial110) FROM stdin;
1	1	Miércoles	12:00:00	21:00:00	activo	Jenniffer Gomez	\N	2024-12-27 12:07:24.866457	2024-12-27 12:07:24.866457	\N
2	1	Jueves	12:00:00	21:00:00	activo	Jenniffer Gomez	\N	2024-12-27 12:07:48.788332	2024-12-27 12:07:48.788332	\N
3	1	Viernes	12:00:00	21:00:00	activo	Jenniffer Gomez	\N	2024-12-27 12:08:01.557978	2024-12-27 12:08:01.557978	\N
4	1	Sábado	12:00:00	21:00:00	activo	Jenniffer Gomez	\N	2024-12-27 12:08:14.259315	2024-12-27 12:08:14.259315	\N
5	1	Domingo	12:00:00	21:00:00	activo	Jenniffer Gomez	\N	2024-12-27 12:08:43.594758	2024-12-27 12:08:43.594758	\N
54	10	Domingo	09:00:00	18:00:00	activo	Jessie Contreras	\N	2025-01-11 10:32:32.176944	2025-01-11 10:32:32.176944	\N
10	2	Viernes	00:00:00	23:59:00	inactivo	Jenniffer Gomez	\N	2024-12-27 12:23:39.043637	2024-12-27 12:23:39.043637	\N
9	2	Jueves	00:00:00	23:59:00	inactivo	Jenniffer Gomez	\N	2024-12-27 12:23:14.575091	2024-12-27 12:23:14.575091	\N
7	2	Martes	07:30:00	02:00:00	inactivo	Jenniffer Gomez	Jenniffer Gomez	2024-12-27 12:21:38.24369	2024-12-27 17:22:09	\N
8	2	Miércoles	07:00:00	12:00:00	inactivo	Jenniffer Gomez	\N	2024-12-27 12:22:39.107262	2024-12-27 12:22:39.107262	\N
11	2	Sábado	00:00:00	23:59:00	inactivo	Jenniffer Gomez	\N	2024-12-27 12:23:52.631134	2024-12-27 12:23:52.631134	\N
12	2	Domingo	07:00:00	02:00:00	inactivo	Jenniffer Gomez	\N	2024-12-27 12:24:27.174149	2024-12-27 12:24:27.174149	\N
6	2	Lunes	06:00:00	17:00:00	inactivo	Jenniffer Gomez	Jenniffer Gomez	2024-12-27 12:21:16.823688	2025-01-08 19:09:24	\N
13	5	Martes	09:00:00	18:00:00	activo	Jenniffer Gomez	\N	2025-01-08 15:35:10.143739	2025-01-08 15:35:10.143739	\N
15	5	Miércoles	09:00:00	18:00:00	activo	Jenniffer Gomez	\N	2025-01-08 15:35:50.845367	2025-01-08 15:35:50.845367	\N
55	11	Miércoles	09:30:00	18:00:00	activo	Jessie Contreras	\N	2025-01-11 10:56:34.822846	2025-01-11 10:56:34.822846	\N
14	5	Lunes	09:00:00	18:00:00	activo	Jenniffer Gomez	Jenniffer Gomez	2025-01-08 15:35:27.313704	2025-01-08 20:36:03	\N
16	5	Viernes	09:00:00	18:00:00	activo	Jenniffer Gomez	\N	2025-01-08 15:36:21.51052	2025-01-08 15:36:21.51052	\N
17	5	Jueves	09:00:00	18:00:00	activo	Jenniffer Gomez	\N	2025-01-08 15:36:53.625164	2025-01-08 15:36:53.625164	\N
18	5	Sábado	09:00:00	18:00:00	activo	Jenniffer Gomez	\N	2025-01-08 15:37:50.35927	2025-01-08 15:37:50.35927	\N
19	5	Domingo	09:00:00	18:00:00	activo	Jenniffer Gomez	\N	2025-01-08 15:38:34.440618	2025-01-08 15:38:34.440618	\N
20	4	Lunes	11:00:00	22:00:00	activo	Jenniffer Gomez	\N	2025-01-08 15:40:41.111906	2025-01-08 15:40:41.111906	\N
21	4	Martes	11:00:00	22:00:00	activo	Jenniffer Gomez	\N	2025-01-08 15:40:55.960769	2025-01-08 15:40:55.960769	\N
22	4	Miércoles	11:00:00	22:00:00	activo	Jenniffer Gomez	\N	2025-01-08 15:41:12.552437	2025-01-08 15:41:12.552437	\N
23	4	Jueves	11:00:00	22:00:00	activo	Jenniffer Gomez	\N	2025-01-08 15:41:39.128956	2025-01-08 15:41:39.128956	\N
24	4	Viernes	11:00:00	22:00:00	activo	Jenniffer Gomez	\N	2025-01-08 15:42:00.576736	2025-01-08 15:42:00.576736	\N
25	4	Sábado	11:00:00	22:00:00	activo	Jenniffer Gomez	\N	2025-01-08 15:42:29.240958	2025-01-08 15:42:29.240958	\N
26	4	Domingo	11:00:00	22:00:00	activo	Jenniffer Gomez	\N	2025-01-08 15:42:42.887866	2025-01-08 15:42:42.887866	\N
27	6	Lunes	08:00:00	17:00:00	activo	Jenniffer Gomez	\N	2025-01-08 15:53:56.33666	2025-01-08 15:53:56.33666	\N
28	6	Martes	08:00:00	17:00:00	activo	Jenniffer Gomez	\N	2025-01-08 15:54:08.517714	2025-01-08 15:54:08.517714	\N
29	6	Miércoles	08:00:00	17:00:00	activo	Jenniffer Gomez	\N	2025-01-08 15:54:37.903917	2025-01-08 15:54:37.903917	\N
30	6	Jueves	08:00:00	17:00:00	activo	Jenniffer Gomez	\N	2025-01-08 15:54:56.652233	2025-01-08 15:54:56.652233	\N
31	6	Viernes	08:00:00	17:00:00	activo	Jenniffer Gomez	\N	2025-01-08 15:55:31.619047	2025-01-08 15:55:31.619047	\N
32	6	Sábado	08:00:00	17:00:00	activo	Jenniffer Gomez	\N	2025-01-08 15:55:42.979651	2025-01-08 15:55:42.979651	\N
33	6	Domingo	08:00:00	17:00:00	activo	Jenniffer Gomez	\N	2025-01-08 15:55:54.970734	2025-01-08 15:55:54.970734	\N
34	7	Lunes	08:00:00	22:00:00	activo	Jenniffer Gomez	\N	2025-01-08 16:15:09.164627	2025-01-08 16:15:09.164627	\N
35	7	Martes	08:00:00	22:00:00	activo	Jenniffer Gomez	\N	2025-01-08 16:15:30.617652	2025-01-08 16:15:30.617652	\N
36	7	Miércoles	08:00:00	22:00:00	activo	Jenniffer Gomez	\N	2025-01-08 16:15:44.459824	2025-01-08 16:15:44.459824	\N
37	7	Jueves	08:00:00	22:00:00	activo	Jenniffer Gomez	\N	2025-01-08 16:15:59.105669	2025-01-08 16:15:59.105669	\N
38	7	Viernes	08:00:00	22:00:00	activo	Jenniffer Gomez	\N	2025-01-08 16:16:16.494562	2025-01-08 16:16:16.494562	\N
39	7	Sábado	08:00:00	22:00:00	activo	Jenniffer Gomez	\N	2025-01-08 16:16:28.92327	2025-01-08 16:16:28.92327	\N
40	7	Domingo	08:00:00	22:00:00	activo	Jenniffer Gomez	\N	2025-01-08 16:16:43.4931	2025-01-08 16:16:43.4931	\N
42	9	Lunes	09:00:00	18:00:00	activo	Jessie Contreras	\N	2025-01-11 10:18:03.871527	2025-01-11 10:18:03.871527	\N
41	9	Martes	09:00:00	18:00:00	activo	Jessie Contreras	Jessie Contreras	2025-01-10 09:24:13.619109	2025-01-11 15:18:24	\N
43	9	Miércoles	09:00:00	18:00:00	activo	Jessie Contreras	\N	2025-01-11 10:18:48.282584	2025-01-11 10:18:48.282584	\N
44	9	Jueves	09:00:00	18:00:00	activo	Jessie Contreras	\N	2025-01-11 10:19:08.747898	2025-01-11 10:19:08.747898	\N
46	9	Sábado	09:00:00	18:00:00	activo	Jessie Contreras	\N	2025-01-11 10:19:52.479176	2025-01-11 10:19:52.479176	\N
47	9	Domingo	09:00:00	18:00:00	activo	Jessie Contreras	\N	2025-01-11 10:20:15.775712	2025-01-11 10:20:15.775712	\N
56	11	Jueves	09:30:00	18:00:00	activo	Jessie Contreras	\N	2025-01-11 10:56:59.069172	2025-01-11 10:56:59.069172	\N
45	9	Viernes	09:00:00	18:00:00	activo	Jessie Contreras	Jessie Contreras	2025-01-11 10:19:29.829184	2025-01-11 15:20:39	\N
48	10	Lunes	09:00:00	18:00:00	activo	Jessie Contreras	\N	2025-01-11 10:30:48.691128	2025-01-11 10:30:48.691128	\N
49	10	Martes	09:00:00	18:00:00	activo	Jessie Contreras	\N	2025-01-11 10:31:02.969414	2025-01-11 10:31:02.969414	\N
50	10	Miércoles	09:00:00	18:00:00	activo	Jessie Contreras	\N	2025-01-11 10:31:15.749949	2025-01-11 10:31:15.749949	\N
51	10	Jueves	09:00:00	18:00:00	activo	Jessie Contreras	\N	2025-01-11 10:31:40.570751	2025-01-11 10:31:40.570751	\N
52	10	Viernes	09:00:00	18:00:00	activo	Jessie Contreras	\N	2025-01-11 10:31:52.812663	2025-01-11 10:31:52.812663	\N
53	10	Sábado	09:00:00	18:00:00	activo	Jessie Contreras	\N	2025-01-11 10:32:17.455152	2025-01-11 10:32:17.455152	\N
57	11	Viernes	09:30:00	18:00:00	activo	Jessie Contreras	\N	2025-01-11 10:57:33.842925	2025-01-11 10:57:33.842925	\N
58	11	Sábado	09:30:00	18:00:00	activo	Jessie Contreras	\N	2025-01-11 10:57:51.463534	2025-01-11 10:57:51.463534	\N
59	11	Domingo	09:30:00	18:00:00	activo	Jessie Contreras	\N	2025-01-11 10:58:16.754138	2025-01-11 10:58:16.754138	\N
61	12	Martes	09:00:00	17:30:00	activo	Jessie Contreras	\N	2025-01-11 13:59:06.881265	2025-01-11 13:59:06.881265	\N
63	12	Jueves	09:00:00	17:30:00	activo	Jessie Contreras	\N	2025-01-11 13:59:54.848069	2025-01-11 13:59:54.848069	\N
62	12	Miércoles	09:00:00	17:30:00	activo	Jessie Contreras	Jessie Contreras	2025-01-11 13:59:32.193115	2025-01-11 19:00:08	\N
60	12	Lunes	09:00:00	17:30:00	activo	Jessie Contreras	Jessie Contreras	2025-01-11 13:58:47.467515	2025-01-11 19:00:28	\N
64	12	Viernes	09:00:00	17:30:00	activo	Jessie Contreras	\N	2025-01-11 14:00:57.503902	2025-01-11 14:00:57.503902	\N
67	13	Lunes	08:00:00	19:00:00	activo	Jessie Contreras	\N	2025-01-12 09:09:43.78685	2025-01-12 09:09:43.78685	\N
65	12	Sábado	09:00:00	17:30:00	activo	Jessie Contreras	Jessie Contreras	2025-01-11 14:01:22.291917	2025-01-11 19:01:54	\N
66	12	Domingo	09:00:00	17:30:00	activo	Jessie Contreras	Jessie Contreras	2025-01-11 14:01:38.78107	2025-01-11 19:02:12	\N
68	13	Martes	08:00:00	19:00:00	activo	Jessie Contreras	\N	2025-01-12 09:10:02.896117	2025-01-12 09:10:02.896117	\N
69	13	Miércoles	08:00:00	19:00:00	activo	Jessie Contreras	\N	2025-01-12 09:10:18.543981	2025-01-12 09:10:18.543981	\N
70	13	Jueves	08:00:00	19:00:00	activo	Jessie Contreras	\N	2025-01-12 09:10:30.319298	2025-01-12 09:10:30.319298	\N
71	13	Viernes	08:00:00	19:00:00	activo	Jessie Contreras	\N	2025-01-12 09:10:47.439735	2025-01-12 09:10:47.439735	\N
72	13	Sábado	08:00:00	19:00:00	activo	Jessie Contreras	\N	2025-01-12 09:11:07.60339	2025-01-12 09:11:07.60339	\N
73	13	Domingo	08:00:00	19:00:00	activo	Jessie Contreras	\N	2025-01-12 09:11:23.039937	2025-01-12 09:11:23.039937	\N
74	15	Lunes	00:00:00	00:00:00	activo	Jessie Contreras	Jessie Contreras	2025-01-12 09:50:07.490178	2025-01-12 14:57:05	\N
75	15	Martes	00:00:00	00:00:00	activo	Jessie Contreras	Jessie Contreras	2025-01-12 09:50:20.89057	2025-01-12 14:57:26	\N
76	15	Miércoles	00:00:00	00:00:00	activo	Jessie Contreras	Jessie Contreras	2025-01-12 09:51:16.279161	2025-01-12 14:57:45	\N
77	15	Jueves	00:00:00	00:00:00	activo	Jessie Contreras	Jessie Contreras	2025-01-12 09:51:27.456141	2025-01-12 14:57:57	\N
78	15	Viernes	00:00:00	00:00:00	activo	Jessie Contreras	Jessie Contreras	2025-01-12 09:51:40.405026	2025-01-12 14:58:20	\N
79	15	Sábado	00:00:00	00:00:00	activo	Jessie Contreras	Jessie Contreras	2025-01-12 09:51:56.433753	2025-01-12 14:58:38	\N
80	15	Domingo	00:00:00	00:00:00	activo	Jessie Contreras	Jessie Contreras	2025-01-12 09:52:09.022714	2025-01-12 14:58:51	\N
81	16	Miércoles	09:00:00	20:00:00	activo	Jessie Contreras	\N	2025-01-13 09:42:46.553006	2025-01-13 09:42:46.553006	\N
82	16	Jueves	09:00:00	20:00:00	activo	Jessie Contreras	\N	2025-01-13 09:43:24.505783	2025-01-13 09:43:24.505783	\N
83	16	Viernes	09:00:00	20:00:00	activo	Jessie Contreras	\N	2025-01-13 09:43:43.220666	2025-01-13 09:43:43.220666	\N
84	16	Sábado	09:00:00	20:00:00	activo	Jessie Contreras	\N	2025-01-13 09:44:16.328724	2025-01-13 09:44:16.328724	\N
85	16	Domingo	09:00:00	20:00:00	activo	Jessie Contreras	\N	2025-01-13 09:44:58.563196	2025-01-13 09:44:58.563196	\N
86	2	Lunes	00:00:00	00:00:00	activo	Jessie Contreras	\N	2025-01-13 12:01:25.273548	2025-01-13 12:01:25.273548	\N
87	2	Martes	00:00:00	00:00:00	activo	Jessie Contreras	\N	2025-01-13 12:01:36.26337	2025-01-13 12:01:36.26337	\N
89	2	Miércoles	00:00:00	00:00:00	activo	Jessie Contreras	\N	2025-01-13 12:01:53.446181	2025-01-13 12:01:53.446181	\N
90	2	Jueves	00:00:00	00:00:00	activo	Jessie Contreras	\N	2025-01-13 12:02:05.409396	2025-01-13 12:02:05.409396	\N
92	2	Viernes	00:00:00	00:00:00	activo	Jessie Contreras	\N	2025-01-13 12:02:19.488288	2025-01-13 12:02:19.488288	\N
94	2	Viernes	00:00:00	00:00:00	inactivo	Jessie Contreras	\N	2025-01-13 12:02:20.840197	2025-01-13 12:02:20.840197	\N
88	2	Martes	00:00:00	00:00:00	inactivo	Jessie Contreras	\N	2025-01-13 12:01:37.71922	2025-01-13 12:01:37.71922	\N
91	2	Jueves	00:00:00	00:00:00	inactivo	Jessie Contreras	\N	2025-01-13 12:02:06.287336	2025-01-13 12:02:06.287336	\N
93	2	Sábado	00:00:00	00:00:00	activo	Jessie Contreras	Jessie Contreras	2025-01-13 12:02:20.333605	2025-01-13 17:03:37	\N
95	2	Domingo	00:00:00	00:00:00	activo	Jessie Contreras	\N	2025-01-13 12:03:55.466128	2025-01-13 12:03:55.466128	\N
96	2	Domingo	00:00:00	00:00:00	activo	Jessie Contreras	\N	2025-01-13 12:03:56.313274	2025-01-13 12:03:56.313274	\N
97	17	Lunes	10:00:00	20:00:00	activo	Jessie Contreras	\N	2025-01-13 14:56:32.582045	2025-01-13 14:56:32.582045	\N
98	17	Martes	08:00:00	17:00:00	activo	Jessie Contreras	\N	2025-01-27 09:16:11.8069	2025-01-27 09:16:11.8069	\N
99	17	Miércoles	08:00:00	17:00:00	activo	Jessie Contreras	\N	2025-01-27 09:16:12.022304	2025-01-27 09:16:12.022304	\N
100	17	Jueves	08:00:00	17:00:00	activo	Jessie Contreras	\N	2025-01-27 09:16:12.247897	2025-01-27 09:16:12.247897	\N
101	17	Viernes	08:00:00	17:00:00	activo	Jessie Contreras	\N	2025-01-27 09:16:12.459483	2025-01-27 09:16:12.459483	\N
\.


--
-- Data for Name: imagenes; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.imagenes (id, id_entidad, tipo, ruta_imagen, descripcion, estado, creado_por, editado_por, fecha_creacion, fecha_ultima_edicion, trial110) FROM stdin;
1	1	asistente	imagenes/5gShQsMABIg412lXwAllNYLkIvBP2H5KjGsqfbiS.jpg	Imagen del asistente.	activo	Jenniffer Gomez	\N	2024-12-26 13:18:19.699688	2024-12-26 13:18:19.699688	\N
2	1	etiquetas	imagenes/UU0cscaQbL7QE0btsDcPwK4ck9lW40MBxIYO97oC.jpg	Imagen de la etiqueta.	activo	Jenniffer Gomez	\N	2024-12-26 13:23:39.463617	2024-12-26 13:23:39.463617	\N
3	2	etiquetas	imagenes/x010as0Qx1XzckssOi167fpNDtCow97DNo4A72Vx.jpg	Imagen de la etiqueta.	activo	Jenniffer Gomez	\N	2024-12-26 13:24:41.117361	2024-12-26 13:24:41.117361	\N
4	3	etiquetas	imagenes/zt0HquY8MqIkLrkvfEk2VZnmPXXtwLqEOkgB2uSZ.jpg	Imagen de la etiqueta.	activo	Jenniffer Gomez	\N	2024-12-26 13:25:40.231418	2024-12-26 13:25:40.231418	\N
5	4	etiquetas	imagenes/U2SJbuqCvAQ0oHUwsuFQFRSEnWpaxozcSjsY4atQ.jpg	Imagen de la etiqueta.	activo	Jenniffer Gomez	\N	2024-12-26 13:26:58.117746	2024-12-26 13:26:58.117746	\N
6	5	etiquetas	imagenes/UpoSdZhkX9PQyedqelJA3jXNucgAOq1xBuF4smqW.jpg	Imagen de la etiqueta.	activo	Jenniffer Gomez	\N	2024-12-26 13:28:13.040954	2024-12-26 13:28:13.040954	\N
7	6	etiquetas	imagenes/m9wYP26vwimUhmIc9FEScG0mGd4WLHZNed8fNUVI.jpg	Imagen de la etiqueta.	activo	Jenniffer Gomez	\N	2024-12-26 13:30:05.940321	2024-12-26 13:30:05.940321	\N
22	5	servicioLocal	imagenes/hRLxwCEyYZwMcs0cUxBDzJHUfK0IJUeOj0ciYfjQ.jpg	Imagen del servicio.	activo	Jenniffer Gomez	\N	2024-12-27 12:25:52.052833	2024-12-27 12:25:52.052833	\N
23	6	servicioLocal	imagenes/zTvgiWK1SCa623nBqCQ2pJXKFTlOMKt68OQz518t.jpg	Imagen del servicio.	activo	Jenniffer Gomez	\N	2024-12-27 12:26:45.314309	2024-12-27 12:26:45.314309	\N
24	7	servicioLocal	imagenes/WN4gpKFmpzaBqzd4ifrUDENWjk6Md9ixKj5xrkG9.jpg	Imagen del servicio.	activo	Jenniffer Gomez	\N	2024-12-27 12:27:27.390942	2024-12-27 12:27:27.390942	\N
25	8	servicioLocal	imagenes/kz5jEyvOsoO2eyaswIGrLqGIaFGLiXGYry1aTO5F.jpg	Imagen del servicio.	activo	Jenniffer Gomez	\N	2024-12-27 12:28:26.49473	2024-12-27 12:28:26.49473	\N
26	9	servicioLocal	imagenes/wz4UDIeo9l4mmsoAK5pBj4J3WngJJfKH56DOiAlb.jpg	Imagen del servicio.	activo	Jenniffer Gomez	\N	2024-12-27 12:29:13.878615	2024-12-27 12:29:13.878615	\N
27	10	servicioLocal	imagenes/oVypxNDlQ56igEKF7wAkwPHquVdSDRph9YpHDh5y.jpg	Imagen del servicio.	activo	Jenniffer Gomez	\N	2024-12-27 12:30:19.549481	2024-12-27 12:30:19.549481	\N
28	1	anuncio	imagenes/zUeNq60eGepTgjWHICXzHLCsI0FsLAxm8ohB7fsF.jpg	imagen del anuncio	activo	Jenniffer Gomez	\N	2024-12-27 16:42:12.744742	2024-12-27 16:42:12.744742	\N
30	1	portada	imagenes/YCWdc3j2kZu0Q6hHkP2piCuNHuvEK2tayLiluHQG.jpg	imagen del portda	activo	Jenniffer Gomez	\N	2024-12-27 17:22:18.180717	2024-12-27 17:22:18.180717	\N
40	2	actividadPuntoTuristico	imagenes/8Twa0PDkV43QrqzFx0QjQkJE9Yo1ni6z6smiDTTG.jpg	Imagen de la actividad.	activo	Jenniffer Gomez	\N	2025-01-03 19:04:26.441257	2025-01-03 19:04:26.441257	\N
41	3	actividadPuntoTuristico	imagenes/dRh0plpFn6KODABMVBeXcfKFkyrGXpoldcWAfy1J.jpg	Imagen de la actividad.	activo	Jenniffer Gomez	\N	2025-01-03 19:05:25.235536	2025-01-03 19:05:25.235536	\N
42	4	actividadPuntoTuristico	imagenes/NMRQl4TRCDRZwbcLrRPjpBUKECavETlYkF9IF8Ti.jpg	Imagen de la actividad.	activo	Jenniffer Gomez	\N	2025-01-03 19:06:36.538627	2025-01-03 19:06:36.538627	\N
43	1	parroquia	imagenes/8VSFbVrXjGVKIqS54FiIPeTJaPLpo55XQA1bfiFi.jpg	Imagen de la parroquia	activo	Jenniffer Gomez	\N	2025-01-08 11:14:05.061951	2025-01-08 11:14:05.061951	\N
44	1	parroquia	imagenes/X3YcYFyuGYOCihBqY9amOtJnKkP0zcfpqKkdl38k.jpg	Imagen de la parroquia	activo	Jenniffer Gomez	\N	2025-01-08 11:14:11.300336	2025-01-08 11:14:11.300336	\N
45	1	parroquia	imagenes/xELejuTA5nrxBIjjPylkKZ1Jqk5l8DR9Yw5dunGN.jpg	Imagen de la parroquia	activo	Jenniffer Gomez	\N	2025-01-08 11:14:18.338002	2025-01-08 11:14:18.338002	\N
46	36	parroquia	imagenes/hwBsDUdZu66ztmiwcBAUpEfTvdYgQROBUpHRUvPv.jpg	Imagen de la parroquia	activo	Jenniffer Gomez	\N	2025-01-08 11:28:28.739046	2025-01-08 11:28:28.739046	\N
47	36	parroquia	imagenes/P3oQrHrMKuXhPktCnPBYpPEVcR2YQHqmQVdrH8gV.jpg	Imagen de la parroquia	activo	Jenniffer Gomez	\N	2025-01-08 11:28:34.497627	2025-01-08 11:28:34.497627	\N
48	36	parroquia	imagenes/TVHaa7MHqQNo6heSM9cteeRpj9XKNMA111fiA44v.jpg	Imagen de la parroquia	activo	Jenniffer Gomez	\N	2025-01-08 11:28:38.803413	2025-01-08 11:28:38.803413	\N
13	1	duenoLocal	imagenes/0wARM7QLeH5tQ2UfvZdU1JKRu2aPHERj1UgiRLin.jpg	Imagen del propietario.	activo	Jenniffer Gomez	\N	2024-12-27 11:54:13.458571	2024-12-27 11:54:13.458571	\N
34	1	actividadPuntoTuristico	imagenes/2z309Nymw7u4r89d7qinAQm185SYPs83WQnMtIZO.jpg	Imagen de la actividad.	activo	Jenniffer Gomez	\N	2024-12-30 17:12:04.783694	2024-12-30 17:12:04.783694	\N
17	1	servicioLocal	imagenes/0ttSbvSniq0b6cEl1TnTp5yIBnhvxO5Ih1GVhjaZ.jpg	Imagen del servicio.	activo	Jenniffer Gomez	\N	2024-12-27 12:10:44.575314	2024-12-27 12:10:44.575314	\N
18	2	servicioLocal	imagenes/kzBEwt84BAAh3RTEr9V1hYApnb0w3iwyHwJLiujV.jpg	Imagen del servicio.	activo	Jenniffer Gomez	\N	2024-12-27 12:13:04.505965	2024-12-27 12:13:04.505965	\N
19	3	servicioLocal	imagenes/gCBYP7LrqwyCcJvD6mgMIzNZvHI05nF8g76ookEL.jpg	Imagen del servicio.	activo	Jenniffer Gomez	\N	2024-12-27 12:14:44.039144	2024-12-27 12:14:44.039144	\N
20	4	servicioLocal	imagenes/vYOAIWO2KOIooFiXhTOdS5uUDOUZF7YtpyGgOi0D.jpg	Imagen del servicio.	activo	Jenniffer Gomez	\N	2024-12-27 12:15:44.085173	2024-12-27 12:15:44.085173	\N
29	2	anuncio	imagenes/9ExcblrUY0NKMXvmFjr4F9iCwb7TSr0boRjN52VK.jpg	Imagen del anuncio.	activo	Jenniffer Gomez	\N	2024-12-27 16:46:13.261302	2024-12-27 16:46:13.261302	\N
49	37	parroquia	imagenes/Qh0KAGTp0faWjvzahbkxBx5ZJQV6XvBLwPlW3uRz.jpg	Imagen de la parroquia	activo	Jenniffer Gomez	\N	2025-01-08 11:34:07.162769	2025-01-08 11:34:07.162769	\N
50	37	parroquia	imagenes/YDW6NnVyHTcOSWQ0xxBCbwXzUZ0TrdDY90s00L9i.jpg	Imagen de la parroquia	activo	Jenniffer Gomez	\N	2025-01-08 11:34:10.574428	2025-01-08 11:34:10.574428	\N
51	37	parroquia	imagenes/83tIq8CuzpbIgY2Sn3DhRdPiAcajTsqPKd47lzsP.jpg	Imagen de la parroquia	activo	Jenniffer Gomez	\N	2025-01-08 11:34:33.98898	2025-01-08 11:34:33.98898	\N
52	38	parroquia	imagenes/AcnEeNzOtKoD7Q5LqB8X9KhZsPQIi4bURWThE5aT.jpg	Imagen de la parroquia	activo	Jenniffer Gomez	\N	2025-01-08 11:46:16.431557	2025-01-08 11:46:16.431557	\N
53	38	parroquia	imagenes/2aOGX7bKEbOgWIA9vI5x3LpSFGlrIpxsDUSC15Qd.jpg	Imagen de la parroquia	activo	Jenniffer Gomez	\N	2025-01-08 11:46:23.104308	2025-01-08 11:46:23.104308	\N
54	38	parroquia	imagenes/NAhb6PnH3707SbysHjmP4Athe3qGbK9WioFQH5aF.jpg	Imagen de la parroquia	activo	Jenniffer Gomez	\N	2025-01-08 11:46:26.778272	2025-01-08 11:46:26.778272	\N
55	35	parroquia	imagenes/msGULwsY689fosKd7kUojFp49vdHR7nYIKDFcKxf.jpg	Imagen de la parroquia	activo	Jenniffer Gomez	\N	2025-01-08 11:49:45.696812	2025-01-08 11:49:45.696812	\N
56	35	parroquia	imagenes/2QAKGgatTcDXiTxjpeTMbC4D3I65Iuaii76SGoE6.jpg	Imagen de la parroquia	activo	Jenniffer Gomez	\N	2025-01-08 11:50:44.300526	2025-01-08 11:50:44.300526	\N
57	35	parroquia	imagenes/l6GkqRQpmS97TClBkkLQI1ACBiHzmTsO7JAnKkQo.jpg	Imagen de la parroquia	activo	Jenniffer Gomez	\N	2025-01-08 11:50:51.103269	2025-01-08 11:50:51.103269	\N
58	35	parroquia	imagenes/tIbeRoayJyLrV3c340tHNjO6QKI1T692wSprYSqy.jpg	Imagen de la parroquia	activo	Jenniffer Gomez	\N	2025-01-08 11:51:32.777832	2025-01-08 11:51:32.777832	\N
59	39	parroquia	imagenes/MijkgBzks4TuIa1pjRq7CJpSKhjoqBdt1vls2skG.jpg	Imagen de la parroquia	activo	Jenniffer Gomez	\N	2025-01-08 12:04:21.348401	2025-01-08 12:04:21.348401	\N
60	39	parroquia	imagenes/RgW3ClcsVlu9IIEOnRrcpYeT3eHRIuolkDYHoV8f.jpg	Imagen de la parroquia	activo	Jenniffer Gomez	\N	2025-01-08 12:04:24.839323	2025-01-08 12:04:24.839323	\N
61	39	parroquia	imagenes/Btf6PvCeXq6UN1lKnLTPLJ94h4P05930zONJmtXF.jpg	Imagen de la parroquia	activo	Jenniffer Gomez	\N	2025-01-08 12:04:27.570455	2025-01-08 12:04:27.570455	\N
62	34	parroquia	imagenes/eCLnvwRKGy6WDLYzgvplAkbf1Ky4ARAjXY5Fg58m.jpg	Imagen de la parroquia	activo	Jenniffer Gomez	\N	2025-01-08 13:55:36.864417	2025-01-08 13:55:36.864417	\N
63	34	parroquia	imagenes/JwSdGlPJsYU0KHxtKW5pVCaMAIuAuTKPDqBo9C6j.jpg	Imagen de la parroquia	activo	Jenniffer Gomez	\N	2025-01-08 13:56:03.955902	2025-01-08 13:56:03.955902	\N
65	34	parroquia	imagenes/e6HzBExjKyJtkrREGYt3TEMxBihMmn9eZsbEUfHh.jpg	Imagen de la parroquia	activo	Jenniffer Gomez	\N	2025-01-08 13:56:40.329174	2025-01-08 13:56:40.329174	\N
66	34	parroquia	imagenes/DL3fkIF52QhZKO2qXFeifFChRezPB4k8m7m0ImKL.jpg	Imagen de la parroquia	activo	Jenniffer Gomez	\N	2025-01-08 13:56:47.531472	2025-01-08 13:56:47.531472	\N
67	3	localTuristico	imagenes/iZ2k8h2gaJM2HGemEC3FVglfg1fgTmepvOH32a2A.jpg	Imagen del local turistico.	activo	Jenniffer Gomez	\N	2025-01-08 14:10:58.41356	2025-01-08 14:10:58.41356	\N
68	3	localTuristico	imagenes/mhsmAezzJ7RYOPH2AWTWKkf1SI46OMzxXywAyJDY.jpg	Imagen del local turistico.	activo	Jenniffer Gomez	\N	2025-01-08 14:11:02.745471	2025-01-08 14:11:02.745471	\N
69	3	localTuristico	imagenes/P323tx3gKrTUPF9nJ7NmkdPTGU0Tvph1nMx7eA8s.jpg	Imagen del local turistico.	activo	Jenniffer Gomez	\N	2025-01-08 14:11:06.319843	2025-01-08 14:11:06.319843	\N
70	1	localTuristico	imagenes/OAx97Af5EAtKJZNb4jNhWV6WxjKjPByiwElpYSaI.jpg	Imagen del local turistico.	activo	Jenniffer Gomez	\N	2025-01-08 14:18:04.948915	2025-01-08 14:18:04.948915	\N
73	6	localTuristico	imagenes/9HEtBF1MTGXGwC1pxcfQcEakWIE6rNohSqBC8M6H.jpg	Imagen del local turistico.	activo	Jenniffer Gomez	\N	2025-01-08 15:53:09.544842	2025-01-08 15:53:09.544842	\N
74	7	localTuristico	imagenes/GFPKgvIwFVc18KcKhSWHCXGZILvg518aL5AGnSId.jpg	Imagen del local turistico.	activo	Jenniffer Gomez	\N	2025-01-08 16:07:39.106682	2025-01-08 16:07:39.106682	\N
75	7	localTuristico	imagenes/5tJES3AhtzsfxPkpT633OKaxC3KbNg1swA00ZWIF.jpg	Imagen del local turistico.	activo	Jenniffer Gomez	\N	2025-01-08 16:07:55.745982	2025-01-08 16:07:55.745982	\N
76	7	localTuristico	imagenes/x038TcR15A4mnkODdBDlWVuDfoOynlZ7mIudvChg.jpg	Imagen del local turistico.	activo	Jenniffer Gomez	\N	2025-01-08 16:08:14.577241	2025-01-08 16:08:14.577241	\N
77	7	localTuristico	imagenes/vRzdmxFHJkkR7KmGHYQBVay9GWo7y5ddpHaqow2M.jpg	Imagen del local turistico.	activo	Jenniffer Gomez	\N	2025-01-08 16:08:25.758575	2025-01-08 16:08:25.758575	\N
78	1	puntoTuristico	imagenes/Y9MuWkeodVNtG6aDlgiC6XwFfu0S0wn8UpMtpyFv.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-08 16:28:34.445538	2025-01-08 16:28:34.445538	\N
79	2	puntoTuristico	imagenes/0NC9116xsadfiY9TSSsVlGdYewNeYxIckhvm6bCr.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-08 16:52:41.877223	2025-01-08 16:52:41.877223	\N
80	2	puntoTuristico	imagenes/PbMaer56YyKleQeUhxtTKYxTSqylme5thwIa1uPi.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-08 16:52:53.031096	2025-01-08 16:52:53.031096	\N
82	3	puntoTuristico	imagenes/oLpv1cQ0fXTevkRx9fhl4rmamL4kfrpoP0ICPSpv.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-08 17:03:38.426704	2025-01-08 17:03:38.426704	\N
83	3	puntoTuristico	imagenes/VcgT3QIm041MeSNdnqO4EzFwV9Yjkk5DB4BSaXEf.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-08 17:03:43.490344	2025-01-08 17:03:43.490344	\N
84	5	localTuristico	imagenes/RM3g7KZFc0MF8KBbvPaPqxfimKgcYgpurmsQx2LQ.jpg	Imagen del local turistico.	activo	Jessie Contreras	\N	2025-01-08 17:21:58.630672	2025-01-08 17:21:58.630672	\N
85	11	servicioLocal	imagenes/kEwjOETDVcimxIBRPHeSXnLGPsbf8VVNdMl2YQso.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-08 18:11:09.594188	2025-01-08 18:11:09.594188	\N
86	12	servicioLocal	imagenes/0Wb7Fk5Lw9Y7WkaNILxToVRXWIkNsv4Q21w1VRhy.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-08 18:14:58.557655	2025-01-08 18:14:58.557655	\N
87	13	servicioLocal	imagenes/mh1mhtb7DxbUbXhHyfdmk2AzplrjJfSvjK1oN7lk.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-08 18:28:18.22165	2025-01-08 18:28:18.22165	\N
88	14	servicioLocal	imagenes/0NISLG7r05oFaRgtVHrbF72PxFPQrUikxlIZfj1t.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-08 18:29:41.080678	2025-01-08 18:29:41.080678	\N
89	15	servicioLocal	imagenes/Gx1p0YRpCzr5oUuMbyKh6BCAuwK3Zvfr6ihsrE0C.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-08 18:30:17.454214	2025-01-08 18:30:17.454214	\N
90	16	servicioLocal	imagenes/BXi5AxDeDuwfLrQ8By5UC9jpLCXhs5HXIBh8Cxd0.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-08 18:31:06.964907	2025-01-08 18:31:06.964907	\N
91	17	servicioLocal	imagenes/4SROaZQcvPZ66neFAsEtFxgg7I0If4HBtvuQBNai.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-08 18:31:45.080691	2025-01-08 18:31:45.080691	\N
92	18	servicioLocal	imagenes/694xAp5DetJP2byDyjfuL0uK0sHfCrJiAtb7r9BJ.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-08 18:32:35.668898	2025-01-08 18:32:35.668898	\N
93	19	servicioLocal	imagenes/GYzAkw2TVUFPaTe4aVa2wS2RYsraqF7GLqUCBnkK.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-08 18:35:21.862411	2025-01-08 18:35:21.862411	\N
94	20	servicioLocal	imagenes/q5sbMGRSLuCYKTUJtS3MoqAnPqe3926lra3lGHoD.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-08 18:37:39.047509	2025-01-08 18:37:39.047509	\N
81	1	administrador	imagenes/nhWihHtejGhP6dmoGZz6reLTyIpYUduSU3Bw86ry.jpg	Imagen del administrador.	activo	Jessie Contreras	\N	2025-01-08 16:55:45.910022	2025-01-08 16:55:45.910022	\N
95	21	servicioLocal	imagenes/WQBDFIyL3NLUWrhWVXKr6LAT8UwJdPH75pjaLNB1.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-08 18:38:17.067628	2025-01-08 18:38:17.067628	\N
96	22	servicioLocal	imagenes/NDvITuf687p66dbhxlcd06pF2qTVFv47R8PisGgl.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-08 18:41:35.025847	2025-01-08 18:41:35.025847	\N
97	23	servicioLocal	imagenes/0nPzJye0cEDTnrCYSKCoDxhtfur7ysxF6uy1fwge.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-08 18:42:22.614621	2025-01-08 18:42:22.614621	\N
98	24	servicioLocal	imagenes/sKEQIxLeQi7rSAuj0WLmwgfvLIFD93yRYQxUTEKl.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-08 18:43:21.48404	2025-01-08 18:43:21.48404	\N
99	25	servicioLocal	imagenes/cQ8Efc0XNpPViqxqOQAfw3YXya5FExOlJpO4d3f8.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-08 18:44:13.557022	2025-01-08 18:44:13.557022	\N
100	26	servicioLocal	imagenes/DndgA7bLvBWWg5g8s3RU0o4I4zm5CMMYwyL8QQmd.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-08 18:45:53.883835	2025-01-08 18:45:53.883835	\N
101	27	servicioLocal	imagenes/OAlSRFzmcxNfFpOSLDl6Gi2GtRjpXGWAIw5RY0xl.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-08 18:49:49.42242	2025-01-08 18:49:49.42242	\N
102	28	servicioLocal	imagenes/iSvwUGQODIZVgCmZbCtmHsk0zXMFxsGnR1HNYcId.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-08 18:57:59.407116	2025-01-08 18:57:59.407116	\N
103	29	servicioLocal	imagenes/1pHLTpjhrkQoy7LgPlp2gjJ6p8THRPR66hiN1H5G.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-08 18:58:34.986365	2025-01-08 18:58:34.986365	\N
104	30	servicioLocal	imagenes/TGEAYiSI7oTtSgGbiQc9zBaK2vgWuVRc7Stl2qxq.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-08 19:00:33.328486	2025-01-08 19:00:33.328486	\N
105	31	servicioLocal	imagenes/S4A5xtyoBKi7qskMlnCoAvHLmL9hs25gpq0jvGO8.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-08 19:01:46.97236	2025-01-08 19:01:46.97236	\N
106	32	servicioLocal	imagenes/6xYqoERxQ9acy2P1jnbC8Urxl6wc0GKkoRJeyYrq.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-08 19:03:10.374216	2025-01-08 19:03:10.374216	\N
107	33	servicioLocal	imagenes/Ufb9l1MYk5TPUZ3D4r2xUynZsBmcb8srnbD8wHnI.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-08 19:06:15.55734	2025-01-08 19:06:15.55734	\N
108	34	servicioLocal	imagenes/8zKYjkkg05Fgryi0A4XAblAnuizSg1BsheAlz9ej.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-08 19:10:38.31318	2025-01-08 19:10:38.31318	\N
109	5	actividadPuntoTuristico	imagenes/FVM9XA3xRsbkKGnQZTe8WIirDDdgabwSuSTarJnl.jpg	Imagen de la actividad.	activo	Jessie Contreras	\N	2025-01-08 19:16:03.661783	2025-01-08 19:16:03.661783	\N
110	6	actividadPuntoTuristico	imagenes/33rCNwB2RMeQyMnvKGheXj3wTMZoFjqneRkC1z1o.jpg	Imagen de la actividad.	activo	Jessie Contreras	\N	2025-01-08 19:17:38.560971	2025-01-08 19:17:38.560971	\N
111	7	actividadPuntoTuristico	imagenes/uf3W7PratGSN0yDqh1X4BaPUzGlifz2VKGGDM881.jpg	Imagen de la actividad.	activo	Jessie Contreras	\N	2025-01-08 19:20:48.105135	2025-01-08 19:20:48.105135	\N
112	35	servicioLocal	imagenes/7RQ1TpyDCJLOzxrLvnXgmyEazhzd2MLW32S2f5sp.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-09 09:11:07.869276	2025-01-09 09:11:07.869276	\N
113	4	puntoTuristico	imagenes/ClsEQ5pq84INrU0wClbsHg4ONSwWBLizudzc4JPA.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-09 10:06:00.937708	2025-01-09 10:06:00.937708	\N
114	4	localTuristico	imagenes/5BqWN0LN57B2XTJlWEqt2z1Cquq21nLUKUeFbIRG.jpg	Imagen del local turistico.	activo	Jessie Contreras	\N	2025-01-09 10:14:35.389305	2025-01-09 10:14:35.389305	\N
115	4	localTuristico	imagenes/PK0VdTDiAeG9bjKrBY4xAWByhu4SBiAasl2ycJuB.jpg	Imagen del local turistico.	activo	Jessie Contreras	\N	2025-01-09 10:14:52.535378	2025-01-09 10:14:52.535378	\N
116	36	servicioLocal	imagenes/KsDQanBkSZeHmRXuyrgzwdaYOE02KRl9N8rhFHME.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-09 10:24:00.494364	2025-01-09 10:24:00.494364	\N
117	37	servicioLocal	imagenes/1QckMiG5AVkiyqDK290QwDxZULGdoytyIXODq6WL.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-09 10:38:31.512202	2025-01-09 10:38:31.512202	\N
118	5	puntoTuristico	imagenes/kSxORBXGsS50qsMhALtHFQD41OudXjOImCAtHyUh.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-09 10:49:28.890054	2025-01-09 10:49:28.890054	\N
119	8	actividadPuntoTuristico	imagenes/PM2tN0jN8gsEU2qYE6HTOW2Et1R8HcfVGAJQxfmt.jpg	Imagen de la actividad.	activo	Jessie Contreras	\N	2025-01-09 10:53:26.697901	2025-01-09 10:53:26.697901	\N
120	9	actividadPuntoTuristico	imagenes/KpFB4kRMwC9kwI1F9Z2rgP1q0PwhuE0DMZtmEuS2.jpg	Imagen de la actividad.	activo	Jessie Contreras	\N	2025-01-09 10:54:05.38623	2025-01-09 10:54:05.38623	\N
121	10	actividadPuntoTuristico	imagenes/uj4HtElfkgRQRp4qMQiTc07xf6GRc2zpjPjG9gOj.jpg	Imagen de la actividad.	activo	Jessie Contreras	\N	2025-01-09 10:54:29.41873	2025-01-09 10:54:29.41873	\N
122	11	actividadPuntoTuristico	imagenes/YrIB0dNH02G7CLttrjLZQFSx3ciGrKQkzW5a6wxK.jpg	Imagen de la actividad.	activo	Jessie Contreras	\N	2025-01-09 10:54:54.028715	2025-01-09 10:54:54.028715	\N
124	8	localTuristico	imagenes/PKUtPZouItEzvSIXD8KGkDNEN8AtUDVbKQK1aeQc.jpg	Imagen del local turistico.	activo	Jessie Contreras	\N	2025-01-10 09:21:16.507594	2025-01-10 09:21:16.507594	\N
125	9	localTuristico	imagenes/o9DRsmbJTXJO407ZLu4xxWz9XP08ua4Q4ERLecrG.jpg	Imagen del local turistico.	activo	Jessie Contreras	\N	2025-01-11 10:17:08.611458	2025-01-11 10:17:08.611458	\N
126	9	localTuristico	imagenes/dJfXBN9RpaZq5tZTKnPioZFahjVOfbB3VLS725Zz.jpg	Imagen del local turistico.	activo	Jessie Contreras	\N	2025-01-11 10:17:12.860769	2025-01-11 10:17:12.860769	\N
127	38	servicioLocal	imagenes/tzrpHYawA00L4yMbYU0z9AqCAkag4WoR2yhl3mzx.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 10:21:42.400198	2025-01-11 10:21:42.400198	\N
128	39	servicioLocal	imagenes/QedqFDavcNSG2vOZGMFMcAgbE3VblZzK98CWNjIN.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 10:22:20.751494	2025-01-11 10:22:20.751494	\N
129	40	servicioLocal	imagenes/tLebJWc8PsWBFEKWKrKMyVE6gkU2O57mwta32Udx.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 10:23:07.437116	2025-01-11 10:23:07.437116	\N
130	41	servicioLocal	imagenes/S43wZuwB4TEkWNpNA8TquVIuSRf7O4iPF8d3wdDv.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 10:24:04.116484	2025-01-11 10:24:04.116484	\N
131	9	localTuristico	imagenes/xwEIc0RNSQJXSuaDkkfixX6Rb0tjE9jELkVkA6yB.jpg	Imagen del local turistico.	activo	Jessie Contreras	\N	2025-01-11 10:24:29.672246	2025-01-11 10:24:29.672246	\N
132	42	servicioLocal	imagenes/nhbPmaXGHXJGTm1a0yvfLet39NeevZeCKpm5vv4J.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 10:26:24.901395	2025-01-11 10:26:24.901395	\N
133	43	servicioLocal	imagenes/OksB4AyZEkby6LTNMLJDbeV9kLvcpwfiQPMD5n9b.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 10:27:18.003664	2025-01-11 10:27:18.003664	\N
134	44	servicioLocal	imagenes/w6gD1GlDAM5INoHKIcoZWG3OUb3tQB2nL9LcpBWs.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 10:27:56.764552	2025-01-11 10:27:56.764552	\N
135	45	servicioLocal	imagenes/jLLaIVyFBqcCeMLmVZGVFZRftuqXwUFHdA8GlHVd.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 10:34:26.995824	2025-01-11 10:34:26.995824	\N
136	46	servicioLocal	imagenes/FiSEMmcOf6nVPuP3vTzw6LgbrnF5nITNvdo1TBUs.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 10:35:24.469653	2025-01-11 10:35:24.469653	\N
137	47	servicioLocal	imagenes/LXDUXS7tnLBDmHG38Wg48oAsjV0TbpoGWVsNn23i.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 10:37:03.360578	2025-01-11 10:37:03.360578	\N
138	48	servicioLocal	imagenes/JKfpvCabTPyUdONQ3sVBobx3Aijhqb6LnGVJHixj.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 10:38:08.254349	2025-01-11 10:38:08.254349	\N
139	49	servicioLocal	imagenes/PDmGgDuoSeFd0gz8iG9cfAY4CjvYkuIrn4MmDTe2.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 10:38:54.88793	2025-01-11 10:38:54.88793	\N
140	50	servicioLocal	imagenes/9cjEQ6O0hbgAgJjw9XE39ExfEXYD4Mqm3oVvzOkc.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 10:39:25.760426	2025-01-11 10:39:25.760426	\N
141	10	localTuristico	imagenes/fdnVT6pdDnmBjX4R2DxsnBakFS4ZO6M0JdQimiRR.jpg	Imagen del local turistico.	activo	Jessie Contreras	\N	2025-01-11 10:44:43.708351	2025-01-11 10:44:43.708351	\N
142	10	localTuristico	imagenes/ReOSAICJQmIWDCoF3LhjVXMfXipbQ94vKgbT3wER.jpg	Imagen del local turistico.	activo	Jessie Contreras	\N	2025-01-11 10:45:01.481082	2025-01-11 10:45:01.481082	\N
143	52	servicioLocal	imagenes/nO6Rj2quSF43bN5S7ZhjRJlWA0kBvvtwC7ZL2ESu.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 10:45:51.431641	2025-01-11 10:45:51.431641	\N
144	53	servicioLocal	imagenes/s3hUuh9wSYc0MSIN2Vg0bqpHSIElpg2OUppRpk88.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 10:46:20.670005	2025-01-11 10:46:20.670005	\N
145	54	servicioLocal	imagenes/azWOPC95YQIYgY2bdCgu7XCG9fIJpdrfzZqUipwA.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 10:47:02.391648	2025-01-11 10:47:02.391648	\N
146	11	localTuristico	imagenes/y1jEwDUT0d6773V6JlaPJ8ibC7r541crNXMcpYlB.jpg	Imagen del local turistico.	activo	Jessie Contreras	\N	2025-01-11 10:55:53.235776	2025-01-11 10:55:53.235776	\N
147	11	localTuristico	imagenes/52MTYQyf1vGwHi4teDIQShWnIu7zOwSVKoP0FoUN.jpg	Imagen del local turistico.	activo	Jessie Contreras	\N	2025-01-11 10:59:00.621437	2025-01-11 10:59:00.621437	\N
148	55	servicioLocal	imagenes/IjrbUk9xY8QPYckL1Jj6mNjEE6QFhRQq59CLjYvu.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 10:59:54.34093	2025-01-11 10:59:54.34093	\N
149	56	servicioLocal	imagenes/UK5Fd58X1v3gdjxCMT8QXZ3icNfnsJrTZBMQERPS.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 11:01:02.637154	2025-01-11 11:01:02.637154	\N
150	57	servicioLocal	imagenes/NvduCRXhRKqbn5eEaM7OLigxlCXtQCi4zxnkzD26.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 11:01:34.362262	2025-01-11 11:01:34.362262	\N
151	58	servicioLocal	imagenes/wklXfnTvgWoOvXs9tB0QeYiqIdsyNS4UkALXrR66.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 11:02:22.767835	2025-01-11 11:02:22.767835	\N
152	59	servicioLocal	imagenes/MRit1qg2PrAR0oSZnaehiUVo9FH6MgEKg4Rydi0D.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 11:03:02.971084	2025-01-11 11:03:02.971084	\N
153	60	servicioLocal	imagenes/VGQ3MTwBE7r47eaj3Q6twlZFNkYIgGlPgy8FA5c8.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 11:03:44.384079	2025-01-11 11:03:44.384079	\N
154	61	servicioLocal	imagenes/FIPbWzQrZ9N7W92ojA5svPWlWo5U233N8YgfBPAi.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 11:04:29.785215	2025-01-11 11:04:29.785215	\N
155	12	localTuristico	imagenes/7yq7ub58Pjf04sSVioPm2LC4N3pRFrKsS8qj0wlt.png	Imagen del local turistico.	activo	Jessie Contreras	\N	2025-01-11 13:57:42.010116	2025-01-11 13:57:42.010116	\N
156	12	localTuristico	imagenes/dJdBgwyEgaLyH4uWSFI4JV0WklVAlnzzrZu8fJO8.jpg	Imagen del local turistico.	activo	Jessie Contreras	\N	2025-01-11 14:02:58.113839	2025-01-11 14:02:58.113839	\N
157	63	servicioLocal	imagenes/orKUA88dpxNsIJ1v0XokiUwAkx3l6DEb773ZaSyd.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 14:04:56.276393	2025-01-11 14:04:56.276393	\N
158	64	servicioLocal	imagenes/9WjU6c27iu4h2fRRqhQAsGE8rIwaataCpLudrW2Y.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 14:05:48.828175	2025-01-11 14:05:48.828175	\N
159	65	servicioLocal	imagenes/kJ8z9SB9DFKCE02pPz7zWExkE1h5YDGfTFSgNRi7.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 14:06:42.054567	2025-01-11 14:06:42.054567	\N
160	66	servicioLocal	imagenes/l1MmmYdF9zW2cEQZ1LDGZYmYeptdmW0kYcUMAIaX.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 14:07:39.884331	2025-01-11 14:07:39.884331	\N
161	67	servicioLocal	imagenes/sZEjOP55FYbo0H6VcTIxMBMfEGMHaIasaNsisVGe.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 14:08:38.183465	2025-01-11 14:08:38.183465	\N
162	68	servicioLocal	imagenes/dekLQVlkZNvA4TvTyqgauxTGjEsp11fTy4pmNqIg.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 14:09:27.71362	2025-01-11 14:09:27.71362	\N
163	69	servicioLocal	imagenes/wZadeIGGg2DeV6WJvdHTWKYRTZuRpwWQ5L6ZNwKX.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 14:10:08.981828	2025-01-11 14:10:08.981828	\N
164	70	servicioLocal	imagenes/RKzcnxMQ5JVBmZezB4MLnVkKv9zz8XEpccsdgzJJ.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 14:11:26.736202	2025-01-11 14:11:26.736202	\N
165	71	servicioLocal	imagenes/S1v2wepNOoKwrNVnviFtZlLV0k7przFyWIKg528Y.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 14:12:31.218455	2025-01-11 14:12:31.218455	\N
166	72	servicioLocal	imagenes/V6XVoHd3RYyV5Aq62cMaUrxAw1ZOT9wKB5YmRDuO.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 14:14:10.643882	2025-01-11 14:14:10.643882	\N
167	73	servicioLocal	imagenes/fmDmFvP6ED6N49REGy2pLyLrhhF55jGcjcxzJWOa.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-11 14:15:01.143428	2025-01-11 14:15:01.143428	\N
168	6	puntoTuristico	imagenes/5MAM2wY7ZMkPdzlqQ7nXipbxRURPF4vkKxC4p0Aj.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-11 14:18:16.716535	2025-01-11 14:18:16.716535	\N
169	6	puntoTuristico	imagenes/77tt3UJ8AEhaoVKPVfcKiAat0GIBJ68cl6dapfe6.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-11 14:21:23.117604	2025-01-11 14:21:23.117604	\N
170	12	actividadPuntoTuristico	imagenes/ipXBavqzMPqvUvk7AoK0jn1qEAIMSM8BOHHERIEv.jpg	Imagen de la actividad.	activo	Jessie Contreras	\N	2025-01-11 14:22:34.8069	2025-01-11 14:22:34.8069	\N
171	6	puntoTuristico	imagenes/mg51uwNqc8ak9rFfG1ogkkp7cIzGj8TJ3js3dPIu.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-11 14:22:58.708227	2025-01-11 14:22:58.708227	\N
172	13	actividadPuntoTuristico	imagenes/7BgmHur7L573ejJF3X1TB4xNEfhNupDWTnGuRkU0.jpg	Imagen de la actividad.	activo	Jessie Contreras	\N	2025-01-11 14:23:54.744493	2025-01-11 14:23:54.744493	\N
173	14	actividadPuntoTuristico	imagenes/HG9RXrRSlSwVXOJ8wYTLRrPIAYqnx5x3hcyEWVF8.jpg	Imagen de la actividad.	activo	Jessie Contreras	\N	2025-01-11 14:24:55.335275	2025-01-11 14:24:55.335275	\N
174	7	puntoTuristico	imagenes/TzAx0QYXEXWbGIH8ZDl92sCfKJQ68fihfXxnvMAZ.png	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-11 14:30:17.541439	2025-01-11 14:30:17.541439	\N
175	7	puntoTuristico	imagenes/Z60Qp84TL07chBFLLHtRNN7ChxU9XRswD7Q1uLXA.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-11 14:30:46.473138	2025-01-11 14:30:46.473138	\N
176	15	actividadPuntoTuristico	imagenes/eKT6cg7ElfLY6ZZgSM8iIckIt5KBVKZhcGxZWYL8.png	Imagen de la actividad.	activo	Jessie Contreras	\N	2025-01-11 14:34:41.166989	2025-01-11 14:34:41.166989	\N
177	8	puntoTuristico	imagenes/C8c6s27LhKgnXEdpegBI8kPV78CB6bCNSD9PyJ0W.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-11 14:41:42.1453	2025-01-11 14:41:42.1453	\N
178	8	puntoTuristico	imagenes/EUbKGuxQRuG0RN1EkBQ41dkpkZUYykQNQZw11JsQ.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-11 14:42:59.713279	2025-01-11 14:42:59.713279	\N
179	8	puntoTuristico	imagenes/Xoz1FQNNQAvUOQD36eAZDitxLpRqXCS3bddjW39d.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-11 14:43:14.802584	2025-01-11 14:43:14.802584	\N
180	16	actividadPuntoTuristico	imagenes/wL2cokJi6CrkwkJVSVmwXwc5OOgBASdWnQjzb3hO.jpg	Imagen de la actividad.	activo	Jessie Contreras	\N	2025-01-11 14:43:59.713017	2025-01-11 14:43:59.713017	\N
181	9	puntoTuristico	imagenes/qD9bEU3hPgWqrCGaE4RDQkz1je2GDTxBPAI92FrT.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-11 14:48:46.540045	2025-01-11 14:48:46.540045	\N
182	17	actividadPuntoTuristico	imagenes/yyXfN4Pk2O0rkMcVWP3lsm1omaedPcK9v8gLc9CE.jpg	Imagen de la actividad.	activo	Jessie Contreras	\N	2025-01-11 14:49:41.40745	2025-01-11 14:49:41.40745	\N
183	18	actividadPuntoTuristico	imagenes/G8r8AdEDRH0Bb0i85gtnpUZOqvyfeSFp5fBxzyIK.png	Imagen de la actividad.	activo	Jessie Contreras	\N	2025-01-11 14:51:00.701746	2025-01-11 14:51:00.701746	\N
185	13	localTuristico	imagenes/o9VRlvK3YQoF69vqFac7LyVwUrPAXWRq61PmICeR.jpg	Imagen del local turistico.	activo	Jessie Contreras	\N	2025-01-12 09:07:00.370838	2025-01-12 09:07:00.370838	\N
186	13	localTuristico	imagenes/WOeesVjXN5n1uSNAG2sSBbfAZSTmcpDJJqsNpGuB.jpg	Imagen del local turistico.	activo	Jessie Contreras	\N	2025-01-12 09:07:11.403601	2025-01-12 09:07:11.403601	\N
187	13	localTuristico	imagenes/W6Ok5ZV5dt7mXOg4UxKdM0sGBCkTcnJAeJvfGETV.jpg	Imagen del local turistico.	activo	Jessie Contreras	\N	2025-01-12 09:07:50.173531	2025-01-12 09:07:50.173531	\N
188	74	servicioLocal	imagenes/c7VMgCx3wkpm7WuMDsNZCKIQrbvOOx041CaTET7V.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-12 09:13:10.992673	2025-01-12 09:13:10.992673	\N
189	75	servicioLocal	imagenes/I3KBv69U07M199OxarMIZ2kxtfd8VAYFpYcqhc53.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-12 09:15:14.197674	2025-01-12 09:15:14.197674	\N
190	76	servicioLocal	imagenes/vOtfETi4LzfQzfX0CZqCAnbxI53yJzdpUM8oMJ7W.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-12 09:16:49.378228	2025-01-12 09:16:49.378228	\N
191	77	servicioLocal	imagenes/HD7q3TfTdmXep0eRlVfOQT7SFs0HPXfblo7YyM9m.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-12 09:17:40.619052	2025-01-12 09:17:40.619052	\N
192	78	servicioLocal	imagenes/HWRncXLiqMLjLmQXNCBzXAp07SCihivveEShjZIt.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-12 09:19:00.348327	2025-01-12 09:19:00.348327	\N
193	14	localTuristico	imagenes/4OYLgPku7YBN4t0oyW8kkMvSviSRKw2wYKwjk4D7.png	Imagen del local turistico.	activo	Jessie Contreras	\N	2025-01-12 09:25:05.216147	2025-01-12 09:25:05.216147	\N
194	79	servicioLocal	imagenes/iTl027MXN89CofwSdeXUDoFE7tljxOqeOiAf73Sm.png	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-12 09:25:34.807521	2025-01-12 09:25:34.807521	\N
195	80	servicioLocal	imagenes/9kWJb3FUE5Wl0riYhMUlj03NAudQODZe0Zxl3Xb8.png	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-12 09:27:15.090618	2025-01-12 09:27:15.090618	\N
196	81	servicioLocal	imagenes/DZC76AuaApJqLXE8BE3VQ10MLWvjU93NA7cqLrQB.png	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-12 09:27:54.87308	2025-01-12 09:27:54.87308	\N
197	82	servicioLocal	imagenes/pEkN5wh4DlzNr5U8ruf0LgVsUGUu6J7fj0e4R3YX.png	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-12 09:28:54.230167	2025-01-12 09:28:54.230167	\N
198	7	puntoTuristico	imagenes/1aiqt8NkabeLSNLBNrYmWMROYisKqevGbzcuTlNw.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-12 09:31:38.080233	2025-01-12 09:31:38.080233	\N
199	19	actividadPuntoTuristico	imagenes/q4TPrNbW655d8rhV7bp0bdVSuPsNF54nvT78or8O.jpg	Imagen de la actividad.	activo	Jessie Contreras	\N	2025-01-12 09:34:30.361757	2025-01-12 09:34:30.361757	\N
200	20	actividadPuntoTuristico	imagenes/TJViI1XJJqfGMa5uLyVgfPDpQpJc5cz4dCSfEmIb.jpg	Imagen de la actividad.	activo	Jessie Contreras	\N	2025-01-12 09:35:14.69635	2025-01-12 09:35:14.69635	\N
201	21	actividadPuntoTuristico	imagenes/ydJBFmLceeCzZaMiA5LMoOgVfwTb6lewkSv5udf9.jpg	Imagen de la actividad.	activo	Jessie Contreras	\N	2025-01-12 09:35:50.121412	2025-01-12 09:35:50.121412	\N
202	5	puntoTuristico	imagenes/KeimZmt6xmAUzD3WDVKYsUPqedWXQCkjN7tBHETC.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-12 09:36:51.613584	2025-01-12 09:36:51.613584	\N
203	15	localTuristico	imagenes/MPIM0WkygBKbEZ5WsV6zRAeIrmYGEHeVtGxFgvfB.jpg	Imagen del local turistico.	activo	Jessie Contreras	\N	2025-01-12 09:48:02.294654	2025-01-12 09:48:02.294654	\N
204	83	servicioLocal	imagenes/iMPleAVI7aUYskgPBtnBu70YRqpkVF3AQ9DPMFDa.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-12 09:56:07.899229	2025-01-12 09:56:07.899229	\N
205	15	localTuristico	imagenes/NU5uLfQOrNnJBKwOv0mvKXv9t1qqLS43FwPDdSLZ.jpg	Imagen del local turistico.	activo	Jessie Contreras	\N	2025-01-12 09:56:41.69931	2025-01-12 09:56:41.69931	\N
206	10	puntoTuristico	imagenes/80qY48vWcdIU4KDE5D63sFukNTv0D5TTj5KaOoRY.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-12 10:04:54.756079	2025-01-12 10:04:54.756079	\N
207	10	puntoTuristico	imagenes/G1IGRShMifoi5Roairx2nVZ237q8uxayZaaq1IEb.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-12 10:05:14.561605	2025-01-12 10:05:14.561605	\N
208	22	actividadPuntoTuristico	imagenes/o0d0PwD4njdlM0S3MOjStVA4DxbM4XZR3K1Wjw8B.jpg	Imagen de la actividad.	activo	Jessie Contreras	\N	2025-01-12 10:09:32.248693	2025-01-12 10:09:32.248693	\N
209	23	actividadPuntoTuristico	imagenes/iVd09tIKGuMXbvIGenI3bXRBUn8bnzndGWdQkeK5.jpg	Imagen de la actividad.	activo	Jessie Contreras	\N	2025-01-12 10:10:15.131332	2025-01-12 10:10:15.131332	\N
210	24	actividadPuntoTuristico	imagenes/6sdrH99a3VIBXIQ5fwKQclJFK5W2lsnpATF4KzVb.jpg	Imagen de la actividad.	activo	Jessie Contreras	\N	2025-01-12 10:11:25.914467	2025-01-12 10:11:25.914467	\N
211	9	puntoTuristico	imagenes/hDgSYGudSMoZvXmk9A3rN7VKOsOBwZ8O4POqYlDm.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-12 10:12:03.926906	2025-01-12 10:12:03.926906	\N
212	9	puntoTuristico	imagenes/JXWVTkHR353fcwwBUW4Za1Dj9tCNibv928WSAHe4.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-12 10:12:22.826698	2025-01-12 10:12:22.826698	\N
213	11	puntoTuristico	imagenes/5llQL6KVTyL3MU9ymRDBCXTaPTy2lmNtNQ6Zaw0g.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-12 10:27:33.694522	2025-01-12 10:27:33.694522	\N
214	11	puntoTuristico	imagenes/vuzbqKqJXZJ7b0kS6sUvqyvayveOTQ7pCpRjxyyL.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-12 10:27:45.092957	2025-01-12 10:27:45.092957	\N
215	11	puntoTuristico	imagenes/Ssq46OqVOYmhckIJlbtXSxpQm3SfthE6yiZeqM19.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-12 10:28:01.592558	2025-01-12 10:28:01.592558	\N
216	11	puntoTuristico	imagenes/o12ldQpMaCCHJN28zV01qAHoVWjD4gTNPjMNMJOq.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-12 10:28:13.934177	2025-01-12 10:28:13.934177	\N
217	11	puntoTuristico	imagenes/gCv6sv9Nm8f7H3X3GYcO78cqzoZUtDSGTo6VJhkm.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-12 10:28:26.667762	2025-01-12 10:28:26.667762	\N
218	11	puntoTuristico	imagenes/OxAYbyymLMIZoKVLDeJGqsnzLBvxXlXouTOMR90J.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-12 10:28:41.311247	2025-01-12 10:28:41.311247	\N
219	6	puntoTuristico	imagenes/zChdKQyyX3FKVGBpwa1wlo3N5wyzaaO3yjb24BmR.jpg	Imagen del punto turistico.	activo	Jessie Contreras	\N	2025-01-13 09:15:06.449633	2025-01-13 09:15:06.449633	\N
220	25	actividadPuntoTuristico	imagenes/mEQkkrlBRxtvXcEgq57fcrmzpZCL1JVGnNtLGNx3.jpg	Imagen de la actividad.	activo	Jessie Contreras	\N	2025-01-13 09:15:37.440893	2025-01-13 09:15:37.440893	\N
221	26	actividadPuntoTuristico	imagenes/ONL6KwU4gu32rIoMCWs3fsiWRdbFrV7b3Z8F1Lmv.jpg	Imagen de la actividad.	activo	Jessie Contreras	\N	2025-01-13 09:16:49.709692	2025-01-13 09:16:49.709692	\N
222	27	actividadPuntoTuristico	imagenes/5nd8RT2DxXQNMmVWQkmj0q9CgHVCcFX8Llnqm1DL.jpg	Imagen de la actividad.	activo	Jessie Contreras	\N	2025-01-13 09:17:18.173524	2025-01-13 09:17:18.173524	\N
223	28	actividadPuntoTuristico	imagenes/Q5oc3YaasGiqc6QKAINY1bnJ0MlhVyr7Fr79SuRT.jpg	Imagen de la actividad.	activo	Jessie Contreras	\N	2025-01-13 09:17:51.073642	2025-01-13 09:17:51.073642	\N
224	16	localTuristico	imagenes/z73TrTbD89Griv0A5gtMJL0t9x78wcMZw5Q9ftEq.jpg	Imagen del local turistico.	activo	Jessie Contreras	\N	2025-01-13 09:33:14.176452	2025-01-13 09:33:14.176452	\N
225	16	localTuristico	imagenes/ZOGRLrnIlESK7mpxW3ZSQjBEIkbh1sys03K3GQzi.jpg	Imagen del local turistico.	activo	Jessie Contreras	\N	2025-01-13 09:34:05.619569	2025-01-13 09:34:05.619569	\N
226	84	servicioLocal	imagenes/MA5448C2LB1Wdo9q1P5PzRrTRXjmtSehlekPwEpc.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-13 09:46:17.444918	2025-01-13 09:46:17.444918	\N
227	85	servicioLocal	imagenes/Y0sBb7Sdlaz3JHypqOLL0D6MVxz2mbgah5eRLP96.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-13 09:47:21.209644	2025-01-13 09:47:21.209644	\N
228	86	servicioLocal	imagenes/iMUSFMWsu0g69y6d4p2QPvlghDSBw1WLCNpp7TIk.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-13 09:48:45.469453	2025-01-13 09:48:45.469453	\N
229	87	servicioLocal	imagenes/EksxQY1Sp5ZGrsKHMHIikrmdZkxIjPu7l3z4T1UW.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-13 09:49:57.783389	2025-01-13 09:49:57.783389	\N
230	88	servicioLocal	imagenes/sQFzm2eAPPLgsyTx0Rs5v2cxEQlXKWdG6AOmPRTc.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-13 09:50:27.495867	2025-01-13 09:50:27.495867	\N
231	89	servicioLocal	imagenes/301DOlDAvvyPBCTRCJigvsSu6JKsWQf53FLmMkvB.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-13 09:51:04.828428	2025-01-13 09:51:04.828428	\N
232	2	localTuristico	imagenes/L78054lRdweizEWOk2MkZhWsJ3Yaipr8nJ4AGjBf.jpg	Imagen del local turistico.	activo	Jessie Contreras	\N	2025-01-13 11:59:35.831771	2025-01-13 11:59:35.831771	\N
233	2	localTuristico	imagenes/s44ukcXbyuxUWWOsjatk2DJ2DqujKIvb5ISVe5Wg.jpg	Imagen del local turistico.	activo	Jessie Contreras	\N	2025-01-13 11:59:57.08655	2025-01-13 11:59:57.08655	\N
234	17	localTuristico	imagenes/jSZ6sqs4H4MRnvoLuExKlcZRLVmD9iDdUcwoLZLv.jpg	Imagen del local turistico.	activo	Jessie Contreras	\N	2025-01-13 14:56:09.611758	2025-01-13 14:56:09.611758	\N
235	91	servicioLocal	imagenes/EyXyDKyNHeyQK1SZZJVFufP0woHgLUWehpOboUI0.jpg	Imagen del servicio.	activo	Jessie Contreras	\N	2025-01-13 14:57:49.595546	2025-01-13 14:57:49.595546	\N
236	2	duenoLocal	imagenes/mPWNSlSC5VL8qQBl1eRWpIazcyppTjlZiHkCHrLH.jpg	Imagen del propietario.	activo	Jessie Contreras	\N	2025-01-21 17:14:54.509895	2025-01-21 17:14:54.509895	\N
\.


--
-- Data for Name: informacion_general; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.informacion_general (id, mision, vision, detalles, encargado, version_aplicacion, estado, creado_por, editado_por, fecha_creacion, fecha_ultima_edicion, trial110) FROM stdin;
\.


--
-- Data for Name: job_batches; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.job_batches (id, name, total_jobs, pending_jobs, failed_jobs, failed_job_ids, options, cancelled_at, created_at, finished_at, trial110) FROM stdin;
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.jobs (id, queue, payload, attempts, reserved_at, available_at, created_at, trial113) FROM stdin;
\.


--
-- Data for Name: local_etiqueta; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.local_etiqueta (id_local, id_etiqueta, estado, creado_por, editado_por, fecha_creacion, fecha_ultima_edicion, trial113) FROM stdin;
2	2	activo	Jenniffer Gomez	\N	2024-12-27 12:20:05.794737	2024-12-27 12:20:05.794737	\N
3	6	activo	Jenniffer Gomez	\N	2025-01-08 14:03:10.669738	2025-01-08 14:03:10.669738	\N
1	6	activo	Jenniffer Gomez	\N	2025-01-08 14:16:33.742471	2025-01-08 14:16:33.742471	\N
1	2	inactivo	Jenniffer Gomez	\N	2024-12-27 12:02:43.620112	2024-12-27 12:02:43.620112	\N
4	4	activo	Jenniffer Gomez	\N	2025-01-08 14:23:46.564901	2025-01-08 14:23:46.564901	\N
4	2	activo	Jenniffer Gomez	\N	2025-01-08 14:23:47.070127	2025-01-08 14:23:47.070127	\N
5	4	activo	Jenniffer Gomez	\N	2025-01-08 14:27:49.930645	2025-01-08 14:27:49.930645	\N
5	2	activo	Jenniffer Gomez	\N	2025-01-08 14:27:50.431091	2025-01-08 14:27:50.431091	\N
6	4	activo	Jenniffer Gomez	\N	2025-01-08 15:51:49.078957	2025-01-08 15:51:49.078957	\N
6	2	activo	Jenniffer Gomez	\N	2025-01-08 15:51:49.385697	2025-01-08 15:51:49.385697	\N
7	3	activo	Jenniffer Gomez	\N	2025-01-08 16:07:06.262521	2025-01-08 16:07:06.262521	\N
7	2	activo	Jenniffer Gomez	\N	2025-01-08 16:07:06.567685	2025-01-08 16:07:06.567685	\N
8	6	activo	Jessie Contreras	\N	2025-01-08 16:38:59.401119	2025-01-08 16:38:59.401119	\N
9	4	activo	Jessie Contreras	\N	2025-01-09 11:20:50.506151	2025-01-09 11:20:50.506151	\N
9	2	activo	Jessie Contreras	\N	2025-01-09 11:20:51.002533	2025-01-09 11:20:51.002533	\N
10	4	activo	Jessie Contreras	\N	2025-01-11 10:29:31.150925	2025-01-11 10:29:31.150925	\N
10	2	activo	Jessie Contreras	\N	2025-01-11 10:29:31.774795	2025-01-11 10:29:31.774795	\N
11	4	activo	Jessie Contreras	\N	2025-01-11 10:54:50.271806	2025-01-11 10:54:50.271806	\N
11	2	activo	Jessie Contreras	\N	2025-01-11 10:54:50.632668	2025-01-11 10:54:50.632668	\N
11	6	activo	Jessie Contreras	\N	2025-01-11 11:05:46.830779	2025-01-11 11:05:46.830779	\N
10	6	activo	Jessie Contreras	\N	2025-01-11 13:33:27.319342	2025-01-11 13:33:27.319342	\N
9	6	activo	Jessie Contreras	\N	2025-01-11 13:33:45.220584	2025-01-11 13:33:45.220584	\N
12	4	activo	Jessie Contreras	\N	2025-01-11 13:55:15.837741	2025-01-11 13:55:15.837741	\N
12	2	activo	Jessie Contreras	\N	2025-01-11 13:55:16.346483	2025-01-11 13:55:16.346483	\N
12	3	activo	Jessie Contreras	\N	2025-01-11 14:03:54.86475	2025-01-11 14:03:54.86475	\N
13	4	activo	Jessie Contreras	\N	2025-01-12 09:06:10.087319	2025-01-12 09:06:10.087319	\N
13	2	activo	Jessie Contreras	\N	2025-01-12 09:06:10.584366	2025-01-12 09:06:10.584366	\N
14	6	activo	Jessie Contreras	\N	2025-01-12 09:23:46.655782	2025-01-12 09:23:46.655782	\N
14	2	activo	Jessie Contreras	\N	2025-01-12 09:23:47.13023	2025-01-12 09:23:47.13023	\N
15	3	activo	Jessie Contreras	\N	2025-01-12 09:45:13.530243	2025-01-12 09:45:13.530243	\N
15	4	activo	Jessie Contreras	\N	2025-01-12 09:45:13.885711	2025-01-12 09:45:13.885711	\N
16	4	activo	Jessie Contreras	\N	2025-01-13 09:32:00.75848	2025-01-13 09:32:00.75848	\N
17	2	activo	Jessie Contreras	\N	2025-01-13 14:55:49.357567	2025-01-13 14:55:49.357567	\N
\.


--
-- Data for Name: locales_turisticos; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.locales_turisticos (id, nombre, descripcion, id_dueno, direccion, latitud, longitud, id_parroquia, estado, creado_por, editado_por, fecha_creacion, fecha_ultima_edicion, trial110) FROM stdin;
3	Cascadas del Diablo	Se debe escalar una montaña de senderos angostos. La ruta se inicia en el kilómetro 38 de la vía Santo Domingo - Quito.	1	Ubicado el recinto Unión del Toachi, kilometro 38 de la vía Santo Domingo - Quito.	-0.328215	-78.948441	1	activo	Jenniffer Gomez	\N	2025-01-08 14:03:08.988702	2025-01-08 14:03:08.988702	\N
1	Rancho Las Marías	Emprendimiento de productos lácteos (quesos y yogures artesanales) con expansión nacional.	1	kilómetro 12 de la vía Santo Domingo-Alóag.	-0.278970	-79.074504	1	activo	Jenniffer Gomez	Jenniffer Gomez	2024-12-27 12:02:41.953908	2025-01-08 19:16:31	\N
4	Balneario Ibiza	Lugar ideal para disfrutar de la naturaleza con piscina, jacuzzi, eventos y karaoke.	1	Parroquia Alluriquín, km 23 vía Santo Domingo - Quito	-0.310870	-79.030298	1	activo	Jenniffer Gomez	\N	2025-01-08 14:23:44.277516	2025-01-08 14:23:44.277516	\N
6	Complejo Turístico El Palmar	Ambiente familiar con variedad de actividades, áreas deportivas y senderos en la naturaleza.	1	Parroquia Luz de América, vía Puerto Limón, kilómetro 3 ½.	-0.399635	-79.305439	39	activo	Jenniffer Gomez	\N	2025-01-08 15:51:47.73512	2025-01-08 15:51:47.73512	\N
7	Hosteria las Cucardas	Hostería con servicios de alojamiento y recreación.	1	Km 23 vía Santo Domingo - Quito, sector El Paraíso	-0.322524	-78.998269	1	activo	Jenniffer Gomez	\N	2025-01-08 16:07:04.572673	2025-01-08 16:07:04.572673	\N
8	Bosque y Cascadas Las Rocas	Destino lleno de cultura y tradiciones, con cascadas y espacios para camping.	1	En la parroquia El Esfuerzo	-0.438333	-79.276314	36	activo	Jessie Contreras	\N	2025-01-08 16:38:57.981663	2025-01-08 16:38:57.981663	\N
5	Balneario Otonga Café	Balneario con ambiente natural para relajarse.	2	Km 20 vía Alóag - Santo Domingo, El Paraíso	-0.313232	-79.026665	1	activo	Jenniffer Gomez	Jessie Contreras	2025-01-08 14:27:47.937186	2025-01-09 15:02:36	\N
12	Hostería D'Carlos Aqua Park	Diseñado para brindar entretenimiento, relajación y comodidad a sus visitantes. Este destino combina la diversión de un parque acuático con el confort de una hostería, ofreciendo una experiencia inolvidable para familias, parejas y grupos de amigos. Rodeado de naturaleza y con instalaciones modernas, es ideal para desconectarse de la rutina y disfrutar de momentos únicos.	1	Las Mercedes md, vía a Km 7, Santo Domingo	-0.215005	-79.117184	34	activo	Jessie Contreras	Jessie Contreras	2025-01-11 13:55:13.895618	2025-01-11 19:03:53	\N
11	Complejo Turistico Venturas	Es un destino que combina recreación, naturaleza y confort en un solo lugar. Con amplias instalaciones y una oferta diversa de actividades, este complejo es ideal para quienes buscan disfrutar de momentos únicos en compañía de familia o amigos. Su entorno natural y servicios de calidad lo convierten en un lugar perfecto para relajarse y divertirse.	1	Julio Moreno, Santo Domingo	-0.324052	-79.161698	34	activo	Jessie Contreras	Jessie Contreras	2025-01-11 10:54:48.917347	2025-01-11 16:05:45	\N
10	Parque Acuático el Pulpo	Ofrece una experiencia única para quienes buscan salir de la rutina y liberarse del estrés. Este destino destaca por contar con el tobogán más grande del país, 11 piscinas variadas, jacuzzi, sauna, un río artificial, canchas deportivas y un restaurante. Es el lugar perfecto para disfrutar momentos inolvidables en compañía de familia o amigos, en un ambiente lleno de diversión y relajación.	1	Julio Moreno, pasando el segundo puente, siguiendo nuestra señaletica, vía Aquepi 230104 Santo Domingo, Ecuador	-0.341347	-79.146280	34	activo	Jessie Contreras	Jessie Contreras	2025-01-11 10:29:29.168372	2025-01-11 18:33:25	\N
9	Balneario Gorila Park	Un emocionante destino recreativo que combina naturaleza y diversión, ideal para familias y grupos. Ofrece piscinas, áreas verdes, juegos infantiles y servicios de comida, en un entorno acogedor y seguro. Perfecto para disfrutar de un día inolvidable al aire libre.	1	Via . Julio Moreno Espinoza (Vía Aventura), Sector Union Carchense Km.12.	-0.346689	-79.166815	34	activo	Jessie Contreras	Jessie Contreras	2025-01-09 11:20:48.422718	2025-01-11 18:33:43	\N
13	Complejo turistico La Española	Es ideal para pasar tiempo en familia, disfrutar de actividades al aire libre y explorar la gastronomía local.	1	Km 18, vía Quevedo margen izquierdo detrás de la gasolinera "La Española" 230153 Santo Domingo, Ecuador	-0.381879	-79.274940	39	activo	Jessie Contreras	\N	2025-01-12 09:06:07.970313	2025-01-12 09:06:07.970313	\N
14	Complejo Turistico Santa Rosa	Destino de recreación y descanso con áreas naturales y servicios básicos.	1	Km 16 Vía Quevedo, Recinto Santa Marianita, junto al IPEE	-0.361774	-79.258547	39	activo	Jessie Contreras	\N	2025-01-12 09:23:44.81707	2025-01-12 09:23:44.81707	\N
15	Hostería Balneario Los Españoles	La Hostería Balneario Los Españoles es un acogedor complejo turístico ideal para disfrutar de la naturaleza y el descanso. Ubicada en un entorno tranquilo, ofrece cómodas habitaciones, áreas recreativas, piscinas termales y servicios gastronómicos. Es un lugar perfecto para relajarse, disfrutar de actividades al aire libre y desconectar del ajetreo cotidiano.	1	Vía Santo Domingo - Quinindé, a 5 minuto de Valle Hermoso. 230213 Santo Domingo, Ecuador	-0.086603	-79.280519	37	activo	Jessie Contreras	Jessie Contreras	2025-01-12 09:45:11.892244	2025-01-12 14:53:26	\N
16	Aventure mini Golf	Este centro de entretenimiento, impulsado por la empresa privada, ofrece opciones como una cancha de pádel, campos de minigolf y un mirador con vistas al río Toachi, promoviendo el disfrute y el desarrollo turístico en la región.	1	Santo Domingo	-0.253312	-79.134135	34	activo	Jessie Contreras	\N	2025-01-13 09:31:59.032235	2025-01-13 09:31:59.032235	\N
2	Agachaditos	Si no as degustado la sazón de @agachaditos en santo domingo dejame decirte que no sabes de cosas buenas ,lo mejor de lo mejor en agachaditos	1	Cerca de 29 de Mayo & Esmeraldas, Santo Domingo, Ecuador, Santo Domingo de los Colorados, Ecuador	-0.253499	-79.176518	34	activo	Jenniffer Gomez	Jessie Contreras	2024-12-27 12:20:04.046456	2025-01-13 16:51:50	\N
17	La casa del hornado	"El Costeñito Luz de América" es un restaurante que ofrece comida típica de la región, con especialidades en asados, mariscos y platos tradicionales  Es conocido por su ambiente acogedor y su enfoque en la gastronomía autóctona, brindando a los comensales una experiencia culinaria auténtica de la región	2	Av. Abraham Calazacón y Río Onzole tras el Cementerio Central.	-0.239124	-79.170227	34	activo	Jessie Contreras	\N	2025-01-13 14:55:47.725006	2025-01-13 14:55:47.725006	\N
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.migrations (id, migration, batch, trial113) FROM stdin;
\.


--
-- Data for Name: parroquias; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.parroquias (id, nombre, fecha_fundacion, poblacion, temperatura_promedio, descripcion, estado, creado_por, editado_por, fecha_creacion, fecha_ultima_edicion, trial110) FROM stdin;
1	San José de Alluriquín	29 de enero de 1970	8607	20°C	Alluriquín, conocida como la "Tierra Dulce" por su tradición en la elaboración de melcochas, panela y maní, se sitúa a una altitud de 739 metros sobre el nivel del mar. La parroquia se caracteriza por su clima agradable y su paisaje fluvial, destacando la confluencia del río Damas con el río Toachi. Además, cuenta con un sistema de nueve cascadas naturales, lo que la convierte en un destino turístico ideal para actividades como el canyoning y el rápel.	activo	Jenniffer Gomez	Jenniffer Gomez	2024-12-26 13:35:40.313141	2024-12-26 13:35:40.313141	\N
36	El Esfuerzo	6 de enero de 2003	5973	25°C	La parroquia El Esfuerzo, en Santo Domingo de los Tsáchilas, fue fundada el 6 de enero de 2003. Tiene una población aproximada de 5,973 habitantes y un clima con temperaturas entre 12 °C y 28 °C. Es una zona agrícola con cultivos como yuca, limón y plátano, destacada por sus atractivos naturales como el balneario El Esfuerzo y las cascadas 'Las Rocas'. Su historia está ligada a migrantes de provincias andinas en busca de mejores condiciones.	activo	Jenniffer Gomez	\N	2025-01-08 11:20:51.28312	2025-01-08 11:20:51.28312	\N
37	Valle Hermoso	1 de agosto de 2000	9865	25°C	Valle Hermoso se caracteriza por sus paisajes naturales, incluyendo el río Blanco y selvas vírgenes, que inspiraron su nombre. La parroquia se compone de 18 recintos, entre ellos Chigüilpe, Triunfo, Sábalo y Recreo. Su economía se basa en la agricultura, con cultivos de palma africana, abacá, palmito, maracuyá y piña, además de la ganadería de carne y leche. Valle Hermoso es también un destino turístico conocido por sus paisajes y tranquilidad, ofreciendo actividades como senderismo, pesca y excursiones en bicicleta.	activo	Jenniffer Gomez	\N	2025-01-08 11:31:05.100399	2025-01-08 11:31:05.100399	\N
38	Santa María del Toachi	28 de enero del 2003	7059	25°C	Santa María del Toachi es una parroquia caracterizada por su diversidad topográfica y climática, lo que favorece una variada producción agrícola. Sus primeros habitantes provinieron de las provincias de Cotopaxi, Azuay, El Oro, Loja y Manabí, estableciéndose en la zona alrededor de 1976. La economía local se basa en la agricultura, con cultivos de plátano, café y banano, además de la ganadería y la explotación maderera. La parroquia cuenta con atractivos naturales como cascadas, ríos y paisajes agrícolas, que la convierten en un potencial destino agroturístico.	activo	Jenniffer Gomez	\N	2025-01-08 11:45:27.249867	2025-01-08 11:45:27.249867	\N
35	San Jacinto del Búa	9 de noviembre de 1998	11718	25°C	San Jacinto del Búa se caracteriza por su clima cálido y húmedo, con una vegetación exuberante propia de la selva muy húmeda. La economía local se basa principalmente en la agricultura y la ganadería, con cultivos de palma africana, cacao y banano. La parroquia cuenta con diversos atractivos naturales, incluyendo ríos y cascadas, que la convierten en un destino potencial para el ecoturismo.	activo	Jenniffer Gomez	Jenniffer Gomez	2025-01-03 18:56:40.016732	2025-01-03 18:56:40.016732	\N
39	Luz de América	2 de diciembre de 1993	11504	25°C	Luz de América se caracteriza por su clima tropical, con una estación seca corta y lluvias significativas durante la mayor parte del año. La altitud de la parroquia varía entre 150 y 650 metros sobre el nivel del mar. La economía local se basa principalmente en la agricultura, con cultivos de cacao y banano, además de la ganadería. La parroquia cuenta con una infraestructura básica que incluye servicios de educación, salud y transporte, y es conocida por su biodiversidad y paisajes naturales, lo que la convierte en un lugar atractivo para el ecoturismo.	activo	Jenniffer Gomez	Jenniffer Gomez	2025-01-08 11:58:07.721952	2025-01-08 11:58:07.721952	\N
34	Santo Domingo	29 de mayo de 1861	492969	23°C	Es una zona tropical húmeda con una temperatura promedio de 22.8 °C. La ciudad es conocida por su diversidad cultural y su importancia económica en la región.	activo	Jenniffer Gomez	Jenniffer Gomez	2024-12-27 11:47:56.407921	2024-12-27 11:47:56.407921	\N
\.


--
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.password_reset_tokens (email, token, created_at, trial113) FROM stdin;
\.


--
-- Data for Name: personal_access_tokens; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.personal_access_tokens (id, tokenable_type, tokenable_id, name, token, abilities, last_used_at, expires_at, created_at, updated_at, trial113) FROM stdin;
\.


--
-- Data for Name: puntos_turisticos; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.puntos_turisticos (id, nombre, descripcion, latitud, longitud, id_parroquia, estado, creado_por, editado_por, fecha_creacion, fecha_ultima_edicion, trial113) FROM stdin;
3	Comuna Tsáchila Congoma	Comunidad ancestral Tsáchila que conserva tradiciones culturales únicas, con actividades interactivas para los visitantes.	-0.390846	-79.351443	39	activo	Jessie Contreras	\N	2025-01-08 17:01:31.712049	2025-01-08 17:01:31.712049	\N
2	Malecón Luz de América	Río con áreas cercanas ideales para la recreación, el contacto con la naturaleza y actividades culturales.	-0.405315	-79.303262	39	activo	Jenniffer Gomez	Jessie Contreras	2025-01-03 19:01:59.320205	2025-01-03 19:01:59.320205	\N
1	Malecón El Esfuerzo	Un espacio recreativo con río, áreas verdes, juegos infantiles y miradores.	-0.419580	-79.278846	36	activo	Jenniffer Gomez	Jessie Contreras	2024-12-30 17:09:07.108849	2024-12-30 17:09:07.108849	\N
4	Balneario Rio Damas	Ofrece una experiencia única para disfrutar de la naturaleza y el clima, con piscinas, deporte, parqueadero y bar.	-0.318963	-78.998612	1	activo	Jessie Contreras	\N	2025-01-09 09:49:33.122272	2025-01-09 09:49:33.122272	\N
5	Zoológico La Isla del Tapir	Es un lugar ecológico y recreativo.\nproyectado a la conservación de la Flora y Fauna.	-0.117760	-79.258118	37	activo	Jessie Contreras	\N	2025-01-09 10:44:52.628672	2025-01-09 10:44:52.628672	\N
6	Parque Jelen Tenka	Es un destino turístico único en Santo Domingo de los Tsáchilas, que combina naturaleza, cultura y recreación en un entorno acogedor. Este parque destaca por su enfoque en la preservación ambiental y la promoción de las tradiciones locales, ofreciendo a los visitantes una experiencia enriquecedora y relajante. Es el lugar ideal para disfrutar en familia o con amigos, rodeado de paisajes espectaculares	-0.242857	-79.161880	34	activo	Jessie Contreras	\N	2025-01-11 14:17:32.621977	2025-01-11 14:17:32.621977	\N
8	Catedral Católica El Buen Pastor	La iniciativa nace de la Diócesis de Santo Domingo, liderada en aquel entonces por el Obispo Wilson Moncayo que junto al Comité Pro Catedral se encargaron de reunir los recursos provenientes de donaciones, rifas y del apoyo del municipio de la ciudad.	-0.251832	-79.184257	34	activo	Jessie Contreras	\N	2025-01-11 14:40:23.909855	2025-01-11 14:40:23.909855	\N
9	Cerro Bombolí	El cerro Bombolí es un atractivo natural destacado por su impresionante belleza escénica. Por esta razón, un grupo de santodomingueños se ha unido para conservarlo.	-0.246677	-79.191470	34	activo	Jessie Contreras	\N	2025-01-11 14:47:39.030814	2025-01-11 14:47:39.030814	\N
7	Jardín botánico Padre Julio Marrero	Este lugar está dedicado a la conservación, investigación y exhibición de una gran diversidad de especies de plantas autóctonas y exóticas. Es un destino ideal para quienes buscan conectar con la naturaleza, aprender sobre flora tropical y disfrutar de un ambiente tranquilo rodeado de paisajes espectaculares.	-0.223406	-79.185483	34	activo	Jessie Contreras	Jessie Contreras	2025-01-11 14:29:26.439391	2025-01-11 14:29:26.439391	\N
10	Parque Zaracay	El Parque Zaracay, inaugurado el 17 de octubre de 1957, es el parque central de Santo Domingo, Ecuador, y un símbolo de identidad cultural e histórica. Alberga el Monumento a Joaquín Zaracay, líder tsáchila y primer gobernador de su etnia. Construido mediante mingas comunitarias, incluye 17 bancas representando las provincias del Ecuador y árboles que embellecen el espacio. Ha sido testigo de eventos cívicos, sociales, políticos y religiosos que han marcado el desarrollo de la ciudad, consolidándose como un lugar de encuentro y tradición.	-0.254122	-79.167845	34	activo	Jessie Contreras	\N	2025-01-12 10:04:21.549083	2025-01-12 10:04:21.549083	\N
11	Monumento Del Indio Colorado	Es un emblemático homenaje a la cultura Tsáchila, comunidad indígena reconocida por su historia y tradiciones. La escultura representa a un miembro de esta etnia, caracterizado por su distintivo cabello teñido de rojo con achiote, símbolo de identidad y conexión con la naturaleza. Este monumento es un ícono cultural y turístico que celebra las raíces ancestrales de la región.	-0.254144	-79.176235	34	activo	Jessie Contreras	\N	2025-01-12 10:26:49.969086	2025-01-12 10:26:49.969086	\N
\.


--
-- Data for Name: puntos_turisticos_etiqueta; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.puntos_turisticos_etiqueta (id_punto_turistico, id_etiqueta, estado, creado_por, editado_por, fecha_creacion, fecha_ultima_edicion, trial113) FROM stdin;
1	5	activo	Jenniffer Gomez	\N	2024-12-30 17:09:09.237652	2024-12-30 17:09:09.237652	\N
2	6	activo	Jenniffer Gomez	\N	2025-01-03 19:02:01.308101	2025-01-03 19:02:01.308101	\N
1	6	activo	Jessie Contreras	\N	2025-01-08 16:25:05.013863	2025-01-08 16:25:05.013863	\N
2	5	activo	Jessie Contreras	\N	2025-01-08 16:51:05.480409	2025-01-08 16:51:05.480409	\N
3	1	activo	Jessie Contreras	\N	2025-01-08 17:01:33.282237	2025-01-08 17:01:33.282237	\N
4	6	activo	Jessie Contreras	\N	2025-01-09 09:49:34.529079	2025-01-09 09:49:34.529079	\N
5	4	activo	Jessie Contreras	\N	2025-01-09 10:44:54.289116	2025-01-09 10:44:54.289116	\N
6	5	activo	Jessie Contreras	\N	2025-01-11 14:17:34.424358	2025-01-11 14:17:34.424358	\N
7	4	activo	Jessie Contreras	\N	2025-01-11 14:29:27.946147	2025-01-11 14:29:27.946147	\N
8	4	activo	Jessie Contreras	\N	2025-01-11 14:40:25.293242	2025-01-11 14:40:25.293242	\N
9	4	activo	Jessie Contreras	\N	2025-01-11 14:47:40.53817	2025-01-11 14:47:40.53817	\N
10	4	activo	Jessie Contreras	\N	2025-01-12 10:04:22.93634	2025-01-12 10:04:22.93634	\N
11	4	activo	Jessie Contreras	\N	2025-01-12 10:26:51.439241	2025-01-12 10:26:51.439241	\N
\.


--
-- Data for Name: servicios_locales; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.servicios_locales (id, id_local, servicio, precio, tipo, estado, creado_por, editado_por, fecha_creacion, fecha_ultima_edicion, trial113) FROM stdin;
5	2	Bolon	2.50	Desayuno	activo	Jenniffer Gomez	\N	2024-12-27 12:25:50.31251	2024-12-27 12:25:50.31251	\N
6	2	Bolón con Filete de Pescado	3.00	Desayuno	activo	Jenniffer Gomez	\N	2024-12-27 12:26:43.705736	2024-12-27 12:26:43.705736	\N
7	2	Ceviche de Concha	5.00	Ceviche	activo	Jenniffer Gomez	\N	2024-12-27 12:27:25.680727	2024-12-27 12:27:25.680727	\N
8	2	Ensalada de Frutas con Yogurt & Granola	2.00	Desayuno	activo	Jenniffer Gomez	\N	2024-12-27 12:28:24.82966	2024-12-27 12:28:24.82966	\N
9	2	Encebollado Grande	2.50	Encebollado	activo	Jenniffer Gomez	\N	2024-12-27 12:29:12.283488	2024-12-27 12:29:12.283488	\N
10	2	Arroz Marinero	3.50	Almuerzo	activo	Jenniffer Gomez	\N	2024-12-27 12:30:17.561427	2024-12-27 12:30:17.561427	\N
24	4	Piscinas	3.00	Atractivos Recreativos	activo	Jessie Contreras	Jessie Contreras	2025-01-08 18:43:19.771333	2025-01-08 18:43:19.771333	\N
12	5	Frappe	4.00	Postres y Bebidas	activo	Jessie Contreras	Jessie Contreras	2025-01-08 18:14:57.169148	2025-01-08 18:14:57.169148	\N
11	5	Pastel	15.00	Postres y Bebidas	activo	Jessie Contreras	Jessie Contreras	2025-01-08 18:11:08.176599	2025-01-08 18:11:08.176599	\N
13	5	Batidos	2.50	Postres y Bebidas	activo	Jessie Contreras	\N	2025-01-08 18:28:16.500318	2025-01-08 18:28:16.500318	\N
15	5	Cafe bebible	1.00	Postres y Bebidas	activo	Jessie Contreras	\N	2025-01-08 18:30:15.675184	2025-01-08 18:30:15.675184	\N
27	1	Queso Mozzarela	3.50	Alimentos	activo	Jessie Contreras	\N	2025-01-08 18:49:47.734956	2025-01-08 18:49:47.734956	\N
25	4	Eventos	20.00	Atractivos Recreativos	activo	Jessie Contreras	Jessie Contreras	2025-01-08 18:44:11.848917	2025-01-08 18:44:11.848917	\N
2	1	Yogurt	4.00	Alimentos	activo	Jenniffer Gomez	Jessie Contreras	2024-12-27 12:13:02.79774	2024-12-27 12:13:02.79774	\N
3	1	Queso Mozzarela Trenza	2.15	Alimentos	activo	Jenniffer Gomez	Jessie Contreras	2024-12-27 12:14:42.4657	2024-12-27 12:14:42.4657	\N
4	1	Alimentos varios	0.00	Alimentos	activo	Jenniffer Gomez	Jessie Contreras	2024-12-27 12:15:42.444777	2024-12-27 12:15:42.444777	\N
28	3	Cascada libre	0.00	Atractivos Naturales	activo	Jessie Contreras	\N	2025-01-08 18:57:57.698271	2025-01-08 18:57:57.698271	\N
29	3	Cascada	0.00	Atractivos Naturales	activo	Jessie Contreras	\N	2025-01-08 18:58:33.28535	2025-01-08 18:58:33.28535	\N
14	5	Cafe Gourmet	3.00	Productos	activo	Jessie Contreras	Jessie Contreras	2025-01-08 18:29:39.354929	2025-01-08 18:29:39.354929	\N
16	5	Café molido	5.00	Productos	activo	Jessie Contreras	Jessie Contreras	2025-01-08 18:31:05.158027	2025-01-08 18:31:05.158027	\N
18	5	Café Molido	3.50	Productos	activo	Jessie Contreras	Jessie Contreras	2025-01-08 18:32:34.003474	2025-01-08 18:32:34.003474	\N
17	5	Café Granulado	5.00	Productos	activo	Jessie Contreras	Jessie Contreras	2025-01-08 18:31:43.391203	2025-01-08 18:31:43.391203	\N
30	7	Eventos Personalizados	0.00	Atractivos Recreativos	activo	Jessie Contreras	Jessie Contreras	2025-01-08 19:00:31.597251	2025-01-08 19:00:31.597251	\N
46	10	Tobogán extremo	0.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-11 10:35:22.765058	2025-01-11 10:35:22.765058	\N
33	7	Rio	0.00	Atractivos Recreativos	activo	Jessie Contreras	Jessie Contreras	2025-01-08 19:06:13.858666	2025-01-08 19:06:13.858666	\N
34	7	Canchas	0.00	Atractivos Recreativos	activo	Jessie Contreras	Jessie Contreras	2025-01-08 19:10:36.590837	2025-01-08 19:10:36.590837	\N
47	10	Áreas Verdes	0.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-11 10:37:01.472143	2025-01-11 10:37:01.472143	\N
22	4	Arroz Marinero	8.00	Gastronomía	activo	Jessie Contreras	Jessie Contreras	2025-01-08 18:41:33.222018	2025-01-08 18:41:33.222018	\N
20	4	Arroz con concha	8.00	Gastronomía	activo	Jessie Contreras	Jessie Contreras	2025-01-08 18:37:33.216763	2025-01-08 18:37:33.216763	\N
19	4	Parque	0.00	Atractivos Recreativos	activo	Jessie Contreras	Jessie Contreras	2025-01-08 18:35:20.145586	2025-01-08 18:35:20.145586	\N
26	4	Platos al día	0.00	Almuerzo y piqueos	inactivo	Jessie Contreras	\N	2025-01-08 18:45:52.069088	2025-01-08 18:45:52.069088	\N
21	4	Micheladas	3.50	Bebidas	activo	Jessie Contreras	Jessie Contreras	2025-01-08 18:38:15.260908	2025-01-08 18:38:15.260908	\N
23	4	Piña Colada	3.50	Bebidas	activo	Jessie Contreras	Jessie Contreras	2025-01-08 18:42:20.123303	2025-01-08 18:42:20.123303	\N
32	7	Piscinas	0.00	Atractivos Recreativos	activo	Jessie Contreras	Jessie Contreras	2025-01-08 19:03:08.637425	2025-01-08 19:03:08.637425	\N
48	10	Emborrajado Conteño	1.50	Gastronomía	activo	Jessie Contreras	\N	2025-01-11 10:38:06.531215	2025-01-11 10:38:06.531215	\N
31	7	Habitación matrimonial	25.00	Habitaciones	activo	Jessie Contreras	Jessie Contreras	2025-01-08 19:01:45.230943	2025-01-08 19:01:45.230943	\N
36	7	Habitación individual	18.00	Habitaciones	activo	Jessie Contreras	\N	2025-01-09 10:23:58.818769	2025-01-09 10:23:58.818769	\N
37	6	Piscinas	3.00	Balneario Ibiza	activo	Jessie Contreras	\N	2025-01-09 10:38:29.202301	2025-01-09 10:38:29.202301	\N
49	10	Tilapia Frita	4.50	Gastronomía	activo	Jessie Contreras	\N	2025-01-11 10:38:53.188816	2025-01-11 10:38:53.188816	\N
1	1	Mozzarela con dulce de Guayaba	3.50	Alimentos	activo	Jenniffer Gomez	Jessie Contreras	2024-12-27 12:10:42.946	2024-12-27 12:10:42.946	\N
38	9	Rio	3.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-11 10:21:40.680301	2025-01-11 10:21:40.680301	\N
39	9	Toboganes	0.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-11 10:22:19.066125	2025-01-11 10:22:19.066125	\N
40	9	Piscinas	0.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-11 10:23:05.74269	2025-01-11 10:23:05.74269	\N
41	9	Áreas verdes	0.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-11 10:24:02.463868	2025-01-11 10:24:02.463868	\N
42	9	Salones para eventos	0.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-11 10:26:23.190991	2025-01-11 10:26:23.190991	\N
43	9	Restaurante y snack bar	0.00	Gastronomía	activo	Jessie Contreras	\N	2025-01-11 10:27:16.292082	2025-01-11 10:27:16.292082	\N
44	9	Estacionamiento	0.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-11 10:27:55.080405	2025-01-11 10:27:55.080405	\N
45	10	Tobogán  niños	0.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-11 10:34:25.320663	2025-01-11 10:34:25.320663	\N
50	10	Chuleta	5.00	Gastronomía	activo	Jessie Contreras	\N	2025-01-11 10:39:24.059752	2025-01-11 10:39:24.059752	\N
51	10	Frutas tropicales	1.00	Snacks naturales	activo	Jessie Contreras	\N	2025-01-11 10:42:15.822276	2025-01-11 10:42:15.822276	\N
52	10	Piscinas	0.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-11 10:45:49.736782	2025-01-11 10:45:49.736782	\N
53	10	Rio	0.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-11 10:46:18.324231	2025-01-11 10:46:18.324231	\N
54	10	Sauna y Jacuzzi	2.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-11 10:47:00.690561	2025-01-11 10:47:00.690561	\N
55	11	Piscinas	3.50	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-11 10:59:52.99875	2025-01-11 10:59:52.99875	\N
56	11	Canchas deportivas	0.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-11 11:01:01.378714	2025-01-11 11:01:01.378714	\N
57	11	Sauna	0.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-11 11:01:33.136478	2025-01-11 11:01:33.136478	\N
58	11	Restaurante y cafetería	0.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-11 11:02:21.429864	2025-01-11 11:02:21.429864	\N
59	11	Áreas Verdes	0.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-11 11:03:01.708729	2025-01-11 11:03:01.708729	\N
60	11	Camarones reventados	5.00	Gastronomía	activo	Jessie Contreras	\N	2025-01-11 11:03:43.106066	2025-01-11 11:03:43.106066	\N
61	11	Rio	0.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-11 11:04:28.523749	2025-01-11 11:04:28.523749	\N
62	11	Tilapia Frita	5.00	Gastronomía	activo	Jessie Contreras	\N	2025-01-11 11:05:01.632835	2025-01-11 11:05:01.632835	\N
63	12	Habitación doble	25.00	Hospedaje	activo	Jessie Contreras	\N	2025-01-11 14:04:54.572173	2025-01-11 14:04:54.572173	\N
64	12	Habitación familiar	30.00	Hospedaje	activo	Jessie Contreras	\N	2025-01-11 14:05:47.142461	2025-01-11 14:05:47.142461	\N
65	12	Habitación Tripe	28.00	Hospedaje	activo	Jessie Contreras	\N	2025-01-11 14:06:40.240789	2025-01-11 14:06:40.240789	\N
66	12	Habitación matrimonial	25.00	Hospedaje	activo	Jessie Contreras	\N	2025-01-11 14:07:38.194492	2025-01-11 14:07:38.194492	\N
67	12	Piscinas	5.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-11 14:08:36.494816	2025-01-11 14:08:36.494816	\N
68	12	Parque acuático para niños	5.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-11 14:09:26.016623	2025-01-11 14:09:26.016623	\N
69	12	Rio lento (artificial)	0.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-11 14:10:07.100257	2025-01-11 14:10:07.100257	\N
70	12	Hamburguesa	3.50	Gastronomía	activo	Jessie Contreras	\N	2025-01-11 14:11:24.908237	2025-01-11 14:11:24.908237	\N
71	12	platos a la carta	7.00	Gastronomía	activo	Jessie Contreras	\N	2025-01-11 14:12:29.527241	2025-01-11 14:12:29.527241	\N
72	12	Eventos	0.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-11 14:14:08.9283	2025-01-11 14:14:08.9283	\N
73	12	Tobogán	0.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-11 14:14:59.446798	2025-01-11 14:14:59.446798	\N
74	13	Locros	4.00	Gastronomía	activo	Jessie Contreras	\N	2025-01-12 09:13:09.237097	2025-01-12 09:13:09.237097	\N
75	13	Piscinas	3.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-12 09:15:12.476965	2025-01-12 09:15:12.476965	\N
76	13	Espacios recreativos	0.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-12 09:16:47.7105	2025-01-12 09:16:47.7105	\N
77	13	Áreas verdes	0.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-12 09:17:38.875751	2025-01-12 09:17:38.875751	\N
78	13	Salón de eventos	50.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-12 09:18:58.646597	2025-01-12 09:18:58.646597	\N
79	14	Rio	0.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-12 09:25:33.363501	2025-01-12 09:25:33.363501	\N
80	14	Almuerzo	0.00	Gastronomía	activo	Jessie Contreras	\N	2025-01-12 09:27:13.538345	2025-01-12 09:27:13.538345	\N
81	14	Pescado frito	4.00	Gastronomía	activo	Jessie Contreras	\N	2025-01-12 09:27:53.408413	2025-01-12 09:27:53.408413	\N
82	14	Plato típico	4.00	Gastronomía	activo	Jessie Contreras	\N	2025-01-12 09:28:52.885529	2025-01-12 09:28:52.885529	\N
83	15	Servicios ofrecidos	2.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-12 09:56:04.728603	2025-01-12 09:56:04.728603	\N
35	8	Rio	0.00	Atractivos Recreativos	activo	Jessie Contreras	Jessie Contreras	2025-01-09 09:11:05.074283	2025-01-09 09:11:05.074283	\N
84	16	Caminata	5.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-13 09:46:15.746004	2025-01-13 09:46:15.746004	\N
85	16	Casa del Arbol	0.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-13 09:47:17.473917	2025-01-13 09:47:17.473917	\N
86	16	Fotografías	0.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-13 09:48:43.763046	2025-01-13 09:48:43.763046	\N
87	16	Mini Golf	2.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-13 09:49:56.067695	2025-01-13 09:49:56.067695	\N
88	16	Paisajes	0.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-13 09:50:25.777695	2025-01-13 09:50:25.777695	\N
89	16	Áreas Verdes	0.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-13 09:51:02.987192	2025-01-13 09:51:02.987192	\N
92	17	comida	5.00	Gastronomía	activo	Jessie Contreras	\N	2025-01-13 14:58:06.643431	2025-01-13 14:58:06.643431	\N
90	17	c	5.00	Gastronomía	inactivo	Jessie Contreras	\N	2025-01-13 14:57:35.577839	2025-01-13 14:57:35.577839	\N
93	17	Piscinas	33.00	Atractivos Recreativos	activo	Jessie Contreras	\N	2025-01-14 16:47:15.022458	2025-01-14 16:47:15.022458	\N
91	17	Comida	6.00	Gastronomía	inactivo	Jessie Contreras	Jessie Contreras	2025-01-13 14:57:47.894409	2025-01-13 14:57:47.894409	\N
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.sessions (id, user_id, ip_address, user_agent, payload, last_activity, trial113) FROM stdin;
uwK1GelxhfQm8OHvgpuRQMWCvFc0903QhCURw1Fj	\N	192.168.18.245	PostmanRuntime/7.43.0	YTozOntzOjY6Il90b2tlbiI7czo0MDoiclphdUdma1ZLb3JJaVNMcXdzZmFMREdhMm9zdTdkbnJjSW51cTBtVCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MjY6Imh0dHA6Ly8xOTIuMTY4LjE4LjI0NTo4MDAwIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==	1735587995	\N
\.


--
-- Data for Name: top_lugares; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.top_lugares (id, tipo, nombre, descripcion, puntos, estado, comentarios, creado_por, editado_por, fecha_creacion, fecha_ultima_edicion) FROM stdin;
2	localTuristico	Agachaditos	contador para el localTuristico	4	activo	Agregado automáticamente	APP	APP	2024-12-30 20:05:45	2025-01-03 19:38:34
3	puntoTuristico	Parque de la Juventud y la Familia	contador para el puntoTuristico	7	activo	Agregado automáticamente	APP	APP	2024-12-30 22:12:52	2025-01-04 16:37:21
4	puntoTuristico	Ríos San Gabriel del Baba	contador para el puntoTuristico	9	activo	Agregado automáticamente	APP	APP	2025-01-04 00:07:08	2025-01-04 17:59:24
1	localTuristico	Parrilladas Oh Qué Rico	contador para el localTuristico	13	activo	Agregado automáticamente	APP	APP	2024-12-30 20:05:22	2025-01-04 18:16:23
11	puntoTuristico	Catedral Católica El Buen Pastor	contador para el puntoTuristico	1	activo	Agregado automáticamente	APP	APP	2025-01-13 19:36:41	2025-01-13 19:36:41
7	puntoTuristico	Comuna Tsáchila Congoma	contador para el puntoTuristico	17	activo	Agregado automáticamente	APP	APP	2025-01-09 14:58:02	2025-01-30 12:24:56
6	puntoTuristico	Malecón El Esfuerzo	contador para el puntoTuristico	6	activo	Agregado automáticamente	APP	APP	2025-01-09 14:56:59	2025-01-09 14:57:17
9	puntoTuristico	Zoológico La Isla del Tapir	contador para el puntoTuristico	1	activo	Agregado automáticamente	APP	APP	2025-01-09 15:57:03	2025-01-09 15:57:03
5	puntoTuristico	Malecón Luz de América	contador para el puntoTuristico	13	activo	Agregado automáticamente	APP	APP	2025-01-09 14:32:29	2025-01-13 17:12:36
8	puntoTuristico	Balneario Rio Damas	contador para el puntoTuristico	4	activo	Agregado automáticamente	APP	APP	2025-01-09 15:05:26	2025-01-13 19:22:21
10	puntoTuristico	Monumento Del Indio Colorado	contador para el puntoTuristico	1	activo	Agregado automáticamente	APP	APP	2025-01-13 19:36:19	2025-01-13 19:36:19
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: tursd
--

COPY public.users (id, name, email, email_verified_at, password, estado, tipo, remember_token, created_at, updated_at, trial113) FROM stdin;
1	Jessie Contreras	jncontreras@espe.edu.ec	\N	$2y$12$GHbYceRf8o9/jCxM0fcDEunPsCA.yh5hQLZNhGYJNHgAQD8RFYCeG	activo	Admin	\N	2024-12-26 18:07:55	2025-01-08 21:20:38	\N
35	Juan Perez	jessiecontreras6@gmail.com	\N	$2y$12$JyEhk/a7VOjG.EyA9vC2vu32W7hYJPjQ/tZnhdo7gmd9Gg.9xfcEO	activo	asistente	\N	2025-01-13 20:04:56	2025-01-13 20:04:56	\N
34	Jenniffer Gomez	jngomez@gmail.com	\N	$2y$12$75g9Qew/unnPKY5AU56yLe7B9xG4t0rsbiRw9/1uo3JrdJDanHK6q	inactivo	asistente	\N	2024-12-26 18:18:14	2025-01-15 15:39:49	\N
36	Luis Solorzano	lasolorzano@gmail.com	\N	$2y$12$KvKgp8vcjcC55DhhmKfoP.diG2PzzhDZZt9V/IKUmcYYllzcIHyIG	activo	asistente	\N	2025-01-15 15:41:40	2025-01-15 15:41:40	\N
\.


--
-- Name: actividad_punto_turistico_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tursd
--

SELECT pg_catalog.setval('public.actividad_punto_turistico_id_seq', 28, true);


--
-- Name: administradores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tursd
--

SELECT pg_catalog.setval('public.administradores_id_seq', 33, true);


--
-- Name: anuncios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tursd
--

SELECT pg_catalog.setval('public.anuncios_id_seq', 2, true);


--
-- Name: asistente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tursd
--

SELECT pg_catalog.setval('public.asistente_id_seq', 3, true);


--
-- Name: duenos_locales_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tursd
--

SELECT pg_catalog.setval('public.duenos_locales_id_seq', 3, true);


--
-- Name: estado_vias_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tursd
--

SELECT pg_catalog.setval('public.estado_vias_id_seq', 1, false);


--
-- Name: etiquetas_turisticas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tursd
--

SELECT pg_catalog.setval('public.etiquetas_turisticas_id_seq', 6, true);


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tursd
--

SELECT pg_catalog.setval('public.failed_jobs_id_seq', 1, false);


--
-- Name: horarios_atencion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tursd
--

SELECT pg_catalog.setval('public.horarios_atencion_id_seq', 101, true);


--
-- Name: imagenes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tursd
--

SELECT pg_catalog.setval('public.imagenes_id_seq', 236, true);


--
-- Name: informacion_general_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tursd
--

SELECT pg_catalog.setval('public.informacion_general_id_seq', 1, false);


--
-- Name: jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tursd
--

SELECT pg_catalog.setval('public.jobs_id_seq', 1, false);


--
-- Name: locales_turisticos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tursd
--

SELECT pg_catalog.setval('public.locales_turisticos_id_seq', 17, true);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tursd
--

SELECT pg_catalog.setval('public.migrations_id_seq', 1, false);


--
-- Name: parroquias_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tursd
--

SELECT pg_catalog.setval('public.parroquias_id_seq', 39, true);


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tursd
--

SELECT pg_catalog.setval('public.personal_access_tokens_id_seq', 1, false);


--
-- Name: puntos_turisticos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tursd
--

SELECT pg_catalog.setval('public.puntos_turisticos_id_seq', 11, true);


--
-- Name: servicios_locales_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tursd
--

SELECT pg_catalog.setval('public.servicios_locales_id_seq', 93, true);


--
-- Name: top_lugares_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tursd
--

SELECT pg_catalog.setval('public.top_lugares_id_seq', 11, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tursd
--

SELECT pg_catalog.setval('public.users_id_seq', 36, true);


--
-- Name: actividad_punto_turistico pk_actividad_punto_turistico; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.actividad_punto_turistico
    ADD CONSTRAINT pk_actividad_punto_turistico PRIMARY KEY (id);


--
-- Name: administradores pk_administradores; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.administradores
    ADD CONSTRAINT pk_administradores PRIMARY KEY (id);


--
-- Name: anuncios pk_anuncios; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.anuncios
    ADD CONSTRAINT pk_anuncios PRIMARY KEY (id);


--
-- Name: asistente pk_asistente; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.asistente
    ADD CONSTRAINT pk_asistente PRIMARY KEY (id);


--
-- Name: cache pk_cache; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.cache
    ADD CONSTRAINT pk_cache PRIMARY KEY (key);


--
-- Name: cache_locks pk_cache_locks; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.cache_locks
    ADD CONSTRAINT pk_cache_locks PRIMARY KEY (key);


--
-- Name: duenos_locales pk_duenos_locales; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.duenos_locales
    ADD CONSTRAINT pk_duenos_locales PRIMARY KEY (id);


--
-- Name: estado_vias pk_estado_vias; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.estado_vias
    ADD CONSTRAINT pk_estado_vias PRIMARY KEY (id);


--
-- Name: etiquetas_turisticas pk_etiquetas_turisticas; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.etiquetas_turisticas
    ADD CONSTRAINT pk_etiquetas_turisticas PRIMARY KEY (id);


--
-- Name: failed_jobs pk_failed_jobs; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT pk_failed_jobs PRIMARY KEY (id);


--
-- Name: horarios_atencion pk_horarios_atencion; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.horarios_atencion
    ADD CONSTRAINT pk_horarios_atencion PRIMARY KEY (id);


--
-- Name: imagenes pk_imagenes; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.imagenes
    ADD CONSTRAINT pk_imagenes PRIMARY KEY (id);


--
-- Name: informacion_general pk_informacion_general; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.informacion_general
    ADD CONSTRAINT pk_informacion_general PRIMARY KEY (id);


--
-- Name: job_batches pk_job_batches; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.job_batches
    ADD CONSTRAINT pk_job_batches PRIMARY KEY (id);


--
-- Name: jobs pk_jobs; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT pk_jobs PRIMARY KEY (id);


--
-- Name: local_etiqueta pk_local_etiqueta; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.local_etiqueta
    ADD CONSTRAINT pk_local_etiqueta PRIMARY KEY (id_local, id_etiqueta);


--
-- Name: locales_turisticos pk_locales_turisticos; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.locales_turisticos
    ADD CONSTRAINT pk_locales_turisticos PRIMARY KEY (id);


--
-- Name: migrations pk_migrations; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT pk_migrations PRIMARY KEY (id);


--
-- Name: parroquias pk_parroquias; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.parroquias
    ADD CONSTRAINT pk_parroquias PRIMARY KEY (id);


--
-- Name: password_reset_tokens pk_password_reset_tokens; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT pk_password_reset_tokens PRIMARY KEY (email);


--
-- Name: personal_access_tokens pk_personal_access_tokens; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT pk_personal_access_tokens PRIMARY KEY (id);


--
-- Name: puntos_turisticos pk_puntos_turisticos; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.puntos_turisticos
    ADD CONSTRAINT pk_puntos_turisticos PRIMARY KEY (id);


--
-- Name: puntos_turisticos_etiqueta pk_puntos_turisticos_etiqueta; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.puntos_turisticos_etiqueta
    ADD CONSTRAINT pk_puntos_turisticos_etiqueta PRIMARY KEY (id_punto_turistico, id_etiqueta);


--
-- Name: servicios_locales pk_servicios_locales; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.servicios_locales
    ADD CONSTRAINT pk_servicios_locales PRIMARY KEY (id);


--
-- Name: sessions pk_sessions; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT pk_sessions PRIMARY KEY (id);


--
-- Name: users pk_users; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT pk_users PRIMARY KEY (id);


--
-- Name: top_lugares top_lugares_pkey; Type: CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.top_lugares
    ADD CONSTRAINT top_lugares_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs_uuid_unique; Type: INDEX; Schema: public; Owner: tursd
--

CREATE UNIQUE INDEX failed_jobs_uuid_unique ON public.failed_jobs USING btree (uuid);


--
-- Name: idx_cedula; Type: INDEX; Schema: public; Owner: tursd
--

CREATE UNIQUE INDEX idx_cedula ON public.administradores USING btree (cedula);


--
-- Name: idx_email; Type: INDEX; Schema: public; Owner: tursd
--

CREATE UNIQUE INDEX idx_email ON public.administradores USING btree (email);


--
-- Name: idx_id_dueno; Type: INDEX; Schema: public; Owner: tursd
--

CREATE INDEX idx_id_dueno ON public.locales_turisticos USING btree (id_dueno);


--
-- Name: idx_id_etiqueta; Type: INDEX; Schema: public; Owner: tursd
--

CREATE INDEX idx_id_etiqueta ON public.local_etiqueta USING btree (id_etiqueta);


--
-- Name: idx_id_local; Type: INDEX; Schema: public; Owner: tursd
--

CREATE INDEX idx_id_local ON public.horarios_atencion USING btree (id_local);


--
-- Name: idx_id_parroquia; Type: INDEX; Schema: public; Owner: tursd
--

CREATE INDEX idx_id_parroquia ON public.locales_turisticos USING btree (id_parroquia);


--
-- Name: idx_id_punto_turistico; Type: INDEX; Schema: public; Owner: tursd
--

CREATE INDEX idx_id_punto_turistico ON public.actividad_punto_turistico USING btree (id_punto_turistico);


--
-- Name: idx_top_lugares_tipo_nombre; Type: INDEX; Schema: public; Owner: tursd
--

CREATE UNIQUE INDEX idx_top_lugares_tipo_nombre ON public.top_lugares USING btree (tipo, nombre);


--
-- Name: jobs_queue_index; Type: INDEX; Schema: public; Owner: tursd
--

CREATE INDEX jobs_queue_index ON public.jobs USING btree (queue);


--
-- Name: personal_access_tokens_token_unique; Type: INDEX; Schema: public; Owner: tursd
--

CREATE UNIQUE INDEX personal_access_tokens_token_unique ON public.personal_access_tokens USING btree (token);


--
-- Name: personal_access_tokens_tokenable_type_tokenable_id_index; Type: INDEX; Schema: public; Owner: tursd
--

CREATE INDEX personal_access_tokens_tokenable_type_tokenable_id_index ON public.personal_access_tokens USING btree (tokenable_type, tokenable_id);


--
-- Name: sessions_last_activity_index; Type: INDEX; Schema: public; Owner: tursd
--

CREATE INDEX sessions_last_activity_index ON public.sessions USING btree (last_activity);


--
-- Name: sessions_user_id_index; Type: INDEX; Schema: public; Owner: tursd
--

CREATE INDEX sessions_user_id_index ON public.sessions USING btree (user_id);


--
-- Name: users_email_unique; Type: INDEX; Schema: public; Owner: tursd
--

CREATE UNIQUE INDEX users_email_unique ON public.users USING btree (email);


--
-- Name: actividad_punto_turistico actividad_punto_turistico_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.actividad_punto_turistico
    ADD CONSTRAINT actividad_punto_turistico_ibfk_1 FOREIGN KEY (id_punto_turistico) REFERENCES public.puntos_turisticos(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: horarios_atencion horarios_atencion_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.horarios_atencion
    ADD CONSTRAINT horarios_atencion_ibfk_1 FOREIGN KEY (id_local) REFERENCES public.locales_turisticos(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: local_etiqueta local_etiqueta_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.local_etiqueta
    ADD CONSTRAINT local_etiqueta_ibfk_1 FOREIGN KEY (id_local) REFERENCES public.locales_turisticos(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: local_etiqueta local_etiqueta_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.local_etiqueta
    ADD CONSTRAINT local_etiqueta_ibfk_2 FOREIGN KEY (id_etiqueta) REFERENCES public.etiquetas_turisticas(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: locales_turisticos locales_turisticos_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.locales_turisticos
    ADD CONSTRAINT locales_turisticos_ibfk_1 FOREIGN KEY (id_dueno) REFERENCES public.duenos_locales(id) ON UPDATE RESTRICT ON DELETE SET NULL;


--
-- Name: locales_turisticos locales_turisticos_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.locales_turisticos
    ADD CONSTRAINT locales_turisticos_ibfk_2 FOREIGN KEY (id_parroquia) REFERENCES public.parroquias(id) ON UPDATE RESTRICT ON DELETE SET NULL;


--
-- Name: puntos_turisticos_etiqueta puntos_turisticos_etiqueta_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.puntos_turisticos_etiqueta
    ADD CONSTRAINT puntos_turisticos_etiqueta_ibfk_1 FOREIGN KEY (id_punto_turistico) REFERENCES public.puntos_turisticos(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: puntos_turisticos_etiqueta puntos_turisticos_etiqueta_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.puntos_turisticos_etiqueta
    ADD CONSTRAINT puntos_turisticos_etiqueta_ibfk_2 FOREIGN KEY (id_etiqueta) REFERENCES public.etiquetas_turisticas(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: puntos_turisticos puntos_turisticos_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.puntos_turisticos
    ADD CONSTRAINT puntos_turisticos_ibfk_1 FOREIGN KEY (id_parroquia) REFERENCES public.parroquias(id) ON UPDATE RESTRICT ON DELETE SET NULL;


--
-- Name: servicios_locales servicios_locales_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: tursd
--

ALTER TABLE ONLY public.servicios_locales
    ADD CONSTRAINT servicios_locales_ibfk_1 FOREIGN KEY (id_local) REFERENCES public.locales_turisticos(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

