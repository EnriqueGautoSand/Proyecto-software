--
-- PostgreSQL database dump
--

-- Dumped from database version 12.2
-- Dumped by pg_dump version 12.2

-- Started on 2020-11-13 21:20:51

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

DROP DATABASE almacen;
--
-- TOC entry 3638 (class 1262 OID 73733)
-- Name: almacen; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE almacen WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Spanish_Argentina.1252' LC_CTYPE = 'Spanish_Argentina.1252';


ALTER DATABASE almacen OWNER TO postgres;

\connect almacen

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

--
-- TOC entry 3 (class 3079 OID 232899)
-- Name: btree_gin; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA public;


--
-- TOC entry 3639 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION btree_gin; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION btree_gin IS 'support for indexing common datatypes in GIN';


--
-- TOC entry 2 (class 3079 OID 233379)
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- TOC entry 3640 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- TOC entry 990 (class 1247 OID 166904)
-- Name: companiatarjeta; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.companiatarjeta AS ENUM (
    'visa',
    'mastercard',
    'naranja'
);


ALTER TYPE public.companiatarjeta OWNER TO postgres;

--
-- TOC entry 997 (class 1247 OID 166922)
-- Name: metodospagos; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.metodospagos AS ENUM (
    'tarjeta',
    'contado'
);


ALTER TYPE public.metodospagos OWNER TO postgres;

--
-- TOC entry 980 (class 1247 OID 134040)
-- Name: tipoclaves; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.tipoclaves AS ENUM (
    'consumidorFinal',
    'responsableInscripto',
    'monotributista'
);


ALTER TYPE public.tipoclaves OWNER TO postgres;

--
-- TOC entry 983 (class 1247 OID 134106)
-- Name: tiposdocumentos; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.tiposdocumentos AS ENUM (
    'DNI',
    'CUIT',
    'CDI',
    'LE',
    'LC',
    'CI_extranjera',
    'Pasaporte',
    'CI_PoliciaFederal',
    'CertificadodeMigracion'
);


ALTER TYPE public.tiposdocumentos OWNER TO postgres;

--
-- TOC entry 286 (class 1255 OID 208440)
-- Name: actualiarstockencompranulada(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actualiarstockencompranulada() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
if not new."Estado" then
update productos  set stock=stock-renglon_compras.cantidad from  
 renglon_compras where renglon_compras.compra_id=new.id  and productos.id =renglon_compras.producto_id;
else
update productos  set stock=stock+renglon_compras.cantidad from  
 renglon_compras where renglon_compras.compra_id=new.id  and productos.id =renglon_compras.producto_id;
end if;
return new;

end
$$;


ALTER FUNCTION public.actualiarstockencompranulada() OWNER TO postgres;

--
-- TOC entry 546 (class 1255 OID 234037)
-- Name: audit_table(regclass); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.audit_table(target_table regclass) RETURNS void
    LANGUAGE sql
    AS $$
SELECT audit_table(target_table, ARRAY[]::text[]);
$$;


ALTER FUNCTION public.audit_table(target_table regclass) OWNER TO postgres;

--
-- TOC entry 545 (class 1255 OID 234036)
-- Name: audit_table(regclass, text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.audit_table(target_table regclass, ignored_cols text[]) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    query text;
    excluded_columns_text text = '';
BEGIN
    EXECUTE 'DROP TRIGGER IF EXISTS audit_trigger_insert ON ' || target_table;
    EXECUTE 'DROP TRIGGER IF EXISTS audit_trigger_update ON ' || target_table;
    EXECUTE 'DROP TRIGGER IF EXISTS audit_trigger_delete ON ' || target_table;

    IF array_length(ignored_cols, 1) > 0 THEN
        excluded_columns_text = ', ' || quote_literal(ignored_cols);
    END IF;
    query = 'CREATE TRIGGER audit_trigger_insert AFTER INSERT ON ' ||
             target_table || ' REFERENCING NEW TABLE AS new_table FOR EACH STATEMENT ' ||
             E'WHEN (get_setting(\'postgresql_audit.enable_versioning\', \'true\')::bool)' ||
             ' EXECUTE PROCEDURE create_activity(' ||
             excluded_columns_text ||
             ');';
    RAISE NOTICE '%', query;
    EXECUTE query;
    query = 'CREATE TRIGGER audit_trigger_update AFTER UPDATE ON ' ||
             target_table || ' REFERENCING NEW TABLE AS new_table OLD TABLE AS old_table FOR EACH STATEMENT ' ||
             E'WHEN (get_setting(\'postgresql_audit.enable_versioning\', \'true\')::bool)' ||
             ' EXECUTE PROCEDURE create_activity(' ||
             excluded_columns_text ||
             ');';
    RAISE NOTICE '%', query;
    EXECUTE query;
    query = 'CREATE TRIGGER audit_trigger_delete AFTER DELETE ON ' ||
             target_table || ' REFERENCING OLD TABLE AS old_table FOR EACH STATEMENT ' ||
             E'WHEN (get_setting(\'postgresql_audit.enable_versioning\', \'true\')::bool)' ||
             ' EXECUTE PROCEDURE create_activity(' ||
             excluded_columns_text ||
             ');';
    RAISE NOTICE '%', query;
    EXECUTE query;
END;
$$;


ALTER FUNCTION public.audit_table(target_table regclass, ignored_cols text[]) OWNER TO postgres;

--
-- TOC entry 544 (class 1255 OID 234035)
-- Name: create_activity(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.create_activity() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public'
    AS $$
DECLARE
    audit_row activity;
    excluded_cols text[] = ARRAY[]::text[];
    _transaction_id BIGINT;
BEGIN
    _transaction_id := (
        SELECT id
        FROM transaction
        WHERE
            native_transaction_id = txid_current() AND
            issued_at >= (NOW() - INTERVAL '1 day')
        ORDER BY issued_at DESC
        LIMIT 1
    );

    IF TG_ARGV[0] IS NOT NULL THEN
        excluded_cols = TG_ARGV[0]::text[];
    END IF;

    IF (TG_OP = 'UPDATE') THEN
        INSERT INTO activity(
            id, schema_name, table_name, relid, issued_at, native_transaction_id,
            verb, old_data, changed_data, transaction_id)
        SELECT
            nextval('activity_id_seq') as id,
            TG_TABLE_SCHEMA::text AS schema_name,
            TG_TABLE_NAME::text AS table_name,
            TG_RELID AS relid,
            statement_timestamp() AT TIME ZONE 'UTC' AS issued_at,
            txid_current() AS native_transaction_id,
            LOWER(TG_OP) AS verb,
            old_data - excluded_cols AS old_data,
            new_data - old_data - excluded_cols AS changed_data,
            _transaction_id AS transaction_id
        FROM (
            SELECT *
            FROM (
                SELECT
                    row_to_json(old_table.*)::jsonb AS old_data,
                    row_number() OVER ()
                FROM old_table
            ) AS old_table
            JOIN (
                SELECT
                    row_to_json(new_table.*)::jsonb AS new_data,
                    row_number() OVER ()
                FROM new_table
            ) AS new_table
            USING(row_number)
        ) as sub
        WHERE new_data - old_data - excluded_cols != '{}'::jsonb;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO activity(
            id, schema_name, table_name, relid, issued_at, native_transaction_id,
            verb, old_data, changed_data, transaction_id)
        SELECT
            nextval('activity_id_seq') as id,
            TG_TABLE_SCHEMA::text AS schema_name,
            TG_TABLE_NAME::text AS table_name,
            TG_RELID AS relid,
            statement_timestamp() AT TIME ZONE 'UTC' AS issued_at,
            txid_current() AS native_transaction_id,
            LOWER(TG_OP) AS verb,
            '{}'::jsonb AS old_data,
            row_to_json(new_table.*)::jsonb - excluded_cols AS changed_data,
            _transaction_id AS transaction_id
        FROM new_table;
    ELSEIF TG_OP = 'DELETE' THEN
        INSERT INTO activity(
            id, schema_name, table_name, relid, issued_at, native_transaction_id,
            verb, old_data, changed_data, transaction_id)
        SELECT
            nextval('activity_id_seq') as id,
            TG_TABLE_SCHEMA::text AS schema_name,
            TG_TABLE_NAME::text AS table_name,
            TG_RELID AS relid,
            statement_timestamp() AT TIME ZONE 'UTC' AS issued_at,
            txid_current() AS native_transaction_id,
            LOWER(TG_OP) AS verb,
            row_to_json(old_table.*)::jsonb - excluded_cols AS old_data,
            '{}'::jsonb AS changed_data,
            _transaction_id AS transaction_id
        FROM old_table;
    END IF;
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.create_activity() OWNER TO postgres;

--
-- TOC entry 267 (class 1255 OID 208434)
-- Name: descontarstockenventa(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.descontarstockenventa() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin

update productos set stock=stock-new.cantidad 
	where productos.id =new.producto_id;
return new;

end
$$;


ALTER FUNCTION public.descontarstockenventa() OWNER TO postgres;

--
-- TOC entry 548 (class 1255 OID 234040)
-- Name: get_setting(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_setting(setting text, default_value text) RETURNS text
    LANGUAGE sql
    AS $$
    SELECT coalesce(
        nullif(current_setting(setting, 't'), ''),
        default_value
    );
$$;


ALTER FUNCTION public.get_setting(setting text, default_value text) OWNER TO postgres;

--
-- TOC entry 543 (class 1255 OID 234034)
-- Name: jsonb_change_key_name(jsonb, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.jsonb_change_key_name(data jsonb, old_key text, new_key text) RETURNS jsonb
    LANGUAGE sql IMMUTABLE
    AS $$
    SELECT ('{'||string_agg(to_json(CASE WHEN key = old_key THEN new_key ELSE key END)||':'||value, ',')||'}')::jsonb
    FROM (
        SELECT *
        FROM jsonb_each(data)
    ) t;
$$;


ALTER FUNCTION public.jsonb_change_key_name(data jsonb, old_key text, new_key text) OWNER TO postgres;

--
-- TOC entry 547 (class 1255 OID 234038)
-- Name: jsonb_subtract(jsonb, jsonb); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.jsonb_subtract(arg1 jsonb, arg2 jsonb) RETURNS jsonb
    LANGUAGE sql
    AS $$
SELECT
  COALESCE(json_object_agg(key, value), '{}')::jsonb
FROM
  jsonb_each(arg1)
WHERE
  (arg1 -> key) <> (arg2 -> key) OR (arg2 -> key) IS NULL
$$;


ALTER FUNCTION public.jsonb_subtract(arg1 jsonb, arg2 jsonb) OWNER TO postgres;

--
-- TOC entry 268 (class 1255 OID 208436)
-- Name: sumarstockencompra(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sumarstockencompra() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin

update productos set stock=stock+new.cantidad 
	where productos.id =new.producto_id;
return new;

end
$$;


ALTER FUNCTION public.sumarstockencompra() OWNER TO postgres;

--
-- TOC entry 285 (class 1255 OID 208438)
-- Name: sumarstockenventanulada(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sumarstockenventanulada() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
if not new."Estado" then
update productos  set stock=stock+renglon.cantidad from  
 renglon where renglon.venta_id=new.id  and productos.id =renglon.producto_id;
else
update productos  set stock=stock-renglon.cantidad from  
 renglon where renglon.venta_id=new.id  and productos.id =renglon.producto_id;
end if;
return new;

end
$$;


ALTER FUNCTION public.sumarstockenventanulada() OWNER TO postgres;

--
-- TOC entry 1884 (class 2617 OID 234039)
-- Name: -; Type: OPERATOR; Schema: public; Owner: postgres
--

CREATE OPERATOR public.- (
    FUNCTION = public.jsonb_subtract,
    LEFTARG = jsonb,
    RIGHTARG = jsonb
);


ALTER OPERATOR public.- (jsonb, jsonb) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 252 (class 1259 OID 208362)
-- Name: FormadePago_Venta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."FormadePago_Venta" (
    id integer NOT NULL,
    monto double precision NOT NULL,
    venta_id integer NOT NULL,
    formadepago_id integer NOT NULL
);


ALTER TABLE public."FormadePago_Venta" OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 208360)
-- Name: FormadePago_Venta_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."FormadePago_Venta_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."FormadePago_Venta_id_seq" OWNER TO postgres;

--
-- TOC entry 3641 (class 0 OID 0)
-- Dependencies: 251
-- Name: FormadePago_Venta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."FormadePago_Venta_id_seq" OWNED BY public."FormadePago_Venta".id;


--
-- TOC entry 222 (class 1259 OID 183299)
-- Name: ab_permission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_permission (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.ab_permission OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 100450)
-- Name: ab_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ab_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ab_permission_id_seq OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 183354)
-- Name: ab_permission_view; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_permission_view (
    id integer NOT NULL,
    permission_id integer,
    view_menu_id integer
);


ALTER TABLE public.ab_permission_view OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 100513)
-- Name: ab_permission_view_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ab_permission_view_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ab_permission_view_id_seq OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 183388)
-- Name: ab_permission_view_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_permission_view_role (
    id integer NOT NULL,
    permission_view_id integer,
    role_id integer
);


ALTER TABLE public.ab_permission_view_role OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 100551)
-- Name: ab_permission_view_role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ab_permission_view_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ab_permission_view_role_id_seq OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 183344)
-- Name: ab_register_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_register_user (
    id integer NOT NULL,
    first_name character varying(64) NOT NULL,
    last_name character varying(64) NOT NULL,
    username character varying(64) NOT NULL,
    password character varying(256),
    email character varying(64) NOT NULL,
    registration_date timestamp without time zone,
    registration_hash character varying(256)
);


ALTER TABLE public.ab_register_user OWNER TO postgres;

--
-- TOC entry 208 (class 1259 OID 100501)
-- Name: ab_register_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ab_register_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ab_register_user_id_seq OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 183313)
-- Name: ab_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_role (
    id integer NOT NULL,
    name character varying(64) NOT NULL
);


ALTER TABLE public.ab_role OWNER TO postgres;

--
-- TOC entry 206 (class 1259 OID 100468)
-- Name: ab_role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ab_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ab_role_id_seq OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 183320)
-- Name: ab_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_user (
    id integer NOT NULL,
    first_name character varying(64) NOT NULL,
    last_name character varying(64) NOT NULL,
    username character varying(64) NOT NULL,
    password character varying(256),
    active boolean,
    email character varying(64) NOT NULL,
    last_login timestamp without time zone,
    login_count integer,
    fail_login_count integer,
    created_on timestamp without time zone,
    changed_on timestamp without time zone,
    created_by_fk integer,
    changed_by_fk integer,
    cuil character varying(50)
);


ALTER TABLE public.ab_user OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 100477)
-- Name: ab_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ab_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ab_user_id_seq OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 183371)
-- Name: ab_user_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_user_role (
    id integer NOT NULL,
    user_id integer,
    role_id integer
);


ALTER TABLE public.ab_user_role OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 100532)
-- Name: ab_user_role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ab_user_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ab_user_role_id_seq OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 183306)
-- Name: ab_view_menu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_view_menu (
    id integer NOT NULL,
    name character varying(250) NOT NULL
);


ALTER TABLE public.ab_view_menu OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 100459)
-- Name: ab_view_menu_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ab_view_menu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ab_view_menu_id_seq OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 191683)
-- Name: audit_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.audit_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.audit_log_id_seq OWNER TO postgres;

--
-- TOC entry 260 (class 1259 OID 232886)
-- Name: auditoria; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auditoria (
    id integer NOT NULL,
    message character varying(300) NOT NULL,
    username character varying(64) NOT NULL,
    created_on timestamp without time zone,
    operation_id integer NOT NULL,
    target character varying(150) NOT NULL
);


ALTER TABLE public.auditoria OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 166824)
-- Name: categoria; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categoria (
    id integer NOT NULL,
    categoria character varying(50) NOT NULL
);


ALTER TABLE public.categoria OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 166822)
-- Name: categoria_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categoria_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.categoria_id_seq OWNER TO postgres;

--
-- TOC entry 3642 (class 0 OID 0)
-- Dependencies: 216
-- Name: categoria_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categoria_id_seq OWNED BY public.categoria.id;


--
-- TOC entry 242 (class 1259 OID 199566)
-- Name: clientes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clientes (
    id integer NOT NULL,
    documento character varying(30) NOT NULL,
    nombre character varying(30),
    apellido character varying(30),
    "tipoDocumento_id" integer NOT NULL,
    "tipoClave_id" integer NOT NULL,
    "idTipoPersona" integer NOT NULL,
    estado boolean
);


ALTER TABLE public.clientes OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 199564)
-- Name: clientes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.clientes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.clientes_id_seq OWNER TO postgres;

--
-- TOC entry 3643 (class 0 OID 0)
-- Dependencies: 241
-- Name: clientes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.clientes_id_seq OWNED BY public.clientes.id;


--
-- TOC entry 219 (class 1259 OID 174960)
-- Name: companiaTarjeta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."companiaTarjeta" (
    id integer NOT NULL,
    compania character varying(50)
);


ALTER TABLE public."companiaTarjeta" OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 174958)
-- Name: companiaTarjeta_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."companiaTarjeta_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."companiaTarjeta_id_seq" OWNER TO postgres;

--
-- TOC entry 3644 (class 0 OID 0)
-- Dependencies: 218
-- Name: companiaTarjeta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."companiaTarjeta_id_seq" OWNED BY public."companiaTarjeta".id;


--
-- TOC entry 250 (class 1259 OID 208339)
-- Name: compras; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras (
    id integer NOT NULL,
    "Estado" boolean,
    total double precision NOT NULL,
    "totalNeto" double precision NOT NULL,
    totaliva double precision,
    fecha date NOT NULL,
    proveedor_id integer NOT NULL,
    formadepago_id integer NOT NULL,
    "datosFormaPagos_id" integer,
    percepcion double precision
);


ALTER TABLE public.compras OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 208337)
-- Name: compras_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.compras_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.compras_id_seq OWNER TO postgres;

--
-- TOC entry 3645 (class 0 OID 0)
-- Dependencies: 249
-- Name: compras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.compras_id_seq OWNED BY public.compras.id;


--
-- TOC entry 244 (class 1259 OID 200114)
-- Name: datosEmpresa; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."datosEmpresa" (
    id integer NOT NULL,
    compania character varying(50),
    direccion character varying(255),
    cuit character varying(30),
    logo text,
    "tipoClave_id" integer NOT NULL
);


ALTER TABLE public."datosEmpresa" OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 200112)
-- Name: datosEmpresa_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."datosEmpresa_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."datosEmpresa_id_seq" OWNER TO postgres;

--
-- TOC entry 3646 (class 0 OID 0)
-- Dependencies: 243
-- Name: datosEmpresa_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."datosEmpresa_id_seq" OWNED BY public."datosEmpresa".id;


--
-- TOC entry 256 (class 1259 OID 208398)
-- Name: datosFormaPagos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."datosFormaPagos" (
    id integer NOT NULL,
    "numeroCupon" character varying(50),
    credito boolean,
    cuotas integer,
    "companiaTarjeta_id" integer NOT NULL,
    formadepago_id integer NOT NULL
);


ALTER TABLE public."datosFormaPagos" OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 208319)
-- Name: datosFormaPagosCompra; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."datosFormaPagosCompra" (
    id integer NOT NULL,
    "numeroCupon" character varying(50) NOT NULL,
    credito boolean,
    cuotas integer,
    "companiaTarjeta_id" integer NOT NULL,
    formadepago_id integer NOT NULL
);


ALTER TABLE public."datosFormaPagosCompra" OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 208317)
-- Name: datosFormaPagosCompra_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."datosFormaPagosCompra_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."datosFormaPagosCompra_id_seq" OWNER TO postgres;

--
-- TOC entry 3647 (class 0 OID 0)
-- Dependencies: 247
-- Name: datosFormaPagosCompra_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."datosFormaPagosCompra_id_seq" OWNED BY public."datosFormaPagosCompra".id;


--
-- TOC entry 255 (class 1259 OID 208396)
-- Name: datosFormaPagos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."datosFormaPagos_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."datosFormaPagos_id_seq" OWNER TO postgres;

--
-- TOC entry 3648 (class 0 OID 0)
-- Dependencies: 255
-- Name: datosFormaPagos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."datosFormaPagos_id_seq" OWNED BY public."datosFormaPagos".id;


--
-- TOC entry 221 (class 1259 OID 183168)
-- Name: formadepago; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.formadepago (
    id integer NOT NULL,
    "Metodo" character varying(50)
);


ALTER TABLE public.formadepago OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 183166)
-- Name: formadepago_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.formadepago_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.formadepago_id_seq OWNER TO postgres;

--
-- TOC entry 3649 (class 0 OID 0)
-- Dependencies: 220
-- Name: formadepago_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.formadepago_id_seq OWNED BY public.formadepago.id;


--
-- TOC entry 215 (class 1259 OID 101175)
-- Name: marcas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.marcas (
    id integer NOT NULL,
    marca character varying(50) NOT NULL
);


ALTER TABLE public.marcas OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 101173)
-- Name: marcas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.marcas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.marcas_id_seq OWNER TO postgres;

--
-- TOC entry 3650 (class 0 OID 0)
-- Dependencies: 214
-- Name: marcas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.marcas_id_seq OWNED BY public.marcas.id;


--
-- TOC entry 259 (class 1259 OID 232881)
-- Name: operacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.operacion (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.operacion OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 191841)
-- Name: productos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.productos (
    id integer NOT NULL,
    "Estado" boolean,
    precio double precision,
    stock integer,
    iva integer NOT NULL,
    unidad_id integer NOT NULL,
    marcas_id integer NOT NULL,
    categoria_id integer NOT NULL,
    medida double precision,
    detalle character varying(255)
);


ALTER TABLE public.productos OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 191839)
-- Name: productos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.productos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.productos_id_seq OWNER TO postgres;

--
-- TOC entry 3651 (class 0 OID 0)
-- Dependencies: 235
-- Name: productos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.productos_id_seq OWNED BY public.productos.id;


--
-- TOC entry 240 (class 1259 OID 199546)
-- Name: proveedor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.proveedor (
    id integer NOT NULL,
    cuit character varying(30) NOT NULL,
    nombre character varying(30) NOT NULL,
    apellido character varying(30) NOT NULL,
    domicilio character varying(255),
    correo character varying(100),
    estado boolean,
    "tipoClave_id" integer NOT NULL,
    "idTipoPersona" integer NOT NULL,
    ranking integer
);


ALTER TABLE public.proveedor OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 199544)
-- Name: proveedor_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.proveedor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.proveedor_id_seq OWNER TO postgres;

--
-- TOC entry 3652 (class 0 OID 0)
-- Dependencies: 239
-- Name: proveedor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.proveedor_id_seq OWNED BY public.proveedor.id;


--
-- TOC entry 254 (class 1259 OID 208380)
-- Name: renglon; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.renglon (
    id integer NOT NULL,
    "precioVenta" double precision,
    cantidad integer,
    venta_id integer NOT NULL,
    producto_id integer NOT NULL,
    descuento double precision
);


ALTER TABLE public.renglon OWNER TO postgres;

--
-- TOC entry 258 (class 1259 OID 208418)
-- Name: renglon_compras; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.renglon_compras (
    id integer NOT NULL,
    "precioCompra" double precision,
    cantidad integer,
    compra_id integer NOT NULL,
    producto_id integer NOT NULL,
    descuento double precision
);


ALTER TABLE public.renglon_compras OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 208416)
-- Name: renglon_compras_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.renglon_compras_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.renglon_compras_id_seq OWNER TO postgres;

--
-- TOC entry 3653 (class 0 OID 0)
-- Dependencies: 257
-- Name: renglon_compras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.renglon_compras_id_seq OWNED BY public.renglon_compras.id;


--
-- TOC entry 253 (class 1259 OID 208378)
-- Name: renglon_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.renglon_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.renglon_id_seq OWNER TO postgres;

--
-- TOC entry 3654 (class 0 OID 0)
-- Dependencies: 253
-- Name: renglon_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.renglon_id_seq OWNED BY public.renglon.id;


--
-- TOC entry 238 (class 1259 OID 199536)
-- Name: tipoPersona; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."tipoPersona" (
    "idTipoPersona" integer NOT NULL,
    "tipoPersona" character varying(30) NOT NULL
);


ALTER TABLE public."tipoPersona" OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 199534)
-- Name: tipoPersona_idTipoPersona_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."tipoPersona_idTipoPersona_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."tipoPersona_idTipoPersona_seq" OWNER TO postgres;

--
-- TOC entry 3655 (class 0 OID 0)
-- Dependencies: 237
-- Name: tipoPersona_idTipoPersona_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."tipoPersona_idTipoPersona_seq" OWNED BY public."tipoPersona"."idTipoPersona";


--
-- TOC entry 231 (class 1259 OID 191344)
-- Name: tiposClave; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."tiposClave" (
    id integer NOT NULL,
    "tipoClave" character varying(30) NOT NULL
);


ALTER TABLE public."tiposClave" OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 191342)
-- Name: tiposClave_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."tiposClave_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."tiposClave_id_seq" OWNER TO postgres;

--
-- TOC entry 3656 (class 0 OID 0)
-- Dependencies: 230
-- Name: tiposClave_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."tiposClave_id_seq" OWNED BY public."tiposClave".id;


--
-- TOC entry 233 (class 1259 OID 191354)
-- Name: tiposDocumentos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."tiposDocumentos" (
    id integer NOT NULL,
    "tipoDocumento" character varying(30) NOT NULL
);


ALTER TABLE public."tiposDocumentos" OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 191352)
-- Name: tiposDocumentos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."tiposDocumentos_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."tiposDocumentos_id_seq" OWNER TO postgres;

--
-- TOC entry 3657 (class 0 OID 0)
-- Dependencies: 232
-- Name: tiposDocumentos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."tiposDocumentos_id_seq" OWNED BY public."tiposDocumentos".id;


--
-- TOC entry 213 (class 1259 OID 101165)
-- Name: unidad_medida; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.unidad_medida (
    id integer NOT NULL,
    unidad character varying(50) NOT NULL
);


ALTER TABLE public.unidad_medida OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 101163)
-- Name: unidad_medida_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.unidad_medida_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.unidad_medida_id_seq OWNER TO postgres;

--
-- TOC entry 3658 (class 0 OID 0)
-- Dependencies: 212
-- Name: unidad_medida_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.unidad_medida_id_seq OWNED BY public.unidad_medida.id;


--
-- TOC entry 246 (class 1259 OID 208306)
-- Name: ventas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ventas (
    id integer NOT NULL,
    "Estado" boolean,
    fecha date NOT NULL,
    "totalNeto" double precision NOT NULL,
    totaliva double precision,
    total double precision NOT NULL,
    cliente_id integer NOT NULL,
    percepcion double precision
);


ALTER TABLE public.ventas OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 208304)
-- Name: ventas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ventas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ventas_id_seq OWNER TO postgres;

--
-- TOC entry 3659 (class 0 OID 0)
-- Dependencies: 245
-- Name: ventas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ventas_id_seq OWNED BY public.ventas.id;


--
-- TOC entry 3298 (class 2604 OID 208365)
-- Name: FormadePago_Venta id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FormadePago_Venta" ALTER COLUMN id SET DEFAULT nextval('public."FormadePago_Venta_id_seq"'::regclass);


--
-- TOC entry 3285 (class 2604 OID 166827)
-- Name: categoria id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria ALTER COLUMN id SET DEFAULT nextval('public.categoria_id_seq'::regclass);


--
-- TOC entry 3293 (class 2604 OID 199569)
-- Name: clientes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes ALTER COLUMN id SET DEFAULT nextval('public.clientes_id_seq'::regclass);


--
-- TOC entry 3286 (class 2604 OID 174963)
-- Name: companiaTarjeta id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."companiaTarjeta" ALTER COLUMN id SET DEFAULT nextval('public."companiaTarjeta_id_seq"'::regclass);


--
-- TOC entry 3297 (class 2604 OID 208342)
-- Name: compras id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras ALTER COLUMN id SET DEFAULT nextval('public.compras_id_seq'::regclass);


--
-- TOC entry 3294 (class 2604 OID 200117)
-- Name: datosEmpresa id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa" ALTER COLUMN id SET DEFAULT nextval('public."datosEmpresa_id_seq"'::regclass);


--
-- TOC entry 3300 (class 2604 OID 208401)
-- Name: datosFormaPagos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagos" ALTER COLUMN id SET DEFAULT nextval('public."datosFormaPagos_id_seq"'::regclass);


--
-- TOC entry 3296 (class 2604 OID 208322)
-- Name: datosFormaPagosCompra id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagosCompra" ALTER COLUMN id SET DEFAULT nextval('public."datosFormaPagosCompra_id_seq"'::regclass);


--
-- TOC entry 3287 (class 2604 OID 183171)
-- Name: formadepago id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.formadepago ALTER COLUMN id SET DEFAULT nextval('public.formadepago_id_seq'::regclass);


--
-- TOC entry 3284 (class 2604 OID 101178)
-- Name: marcas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marcas ALTER COLUMN id SET DEFAULT nextval('public.marcas_id_seq'::regclass);


--
-- TOC entry 3290 (class 2604 OID 191844)
-- Name: productos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos ALTER COLUMN id SET DEFAULT nextval('public.productos_id_seq'::regclass);


--
-- TOC entry 3292 (class 2604 OID 199549)
-- Name: proveedor id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedor ALTER COLUMN id SET DEFAULT nextval('public.proveedor_id_seq'::regclass);


--
-- TOC entry 3299 (class 2604 OID 208383)
-- Name: renglon id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon ALTER COLUMN id SET DEFAULT nextval('public.renglon_id_seq'::regclass);


--
-- TOC entry 3301 (class 2604 OID 208421)
-- Name: renglon_compras id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_compras ALTER COLUMN id SET DEFAULT nextval('public.renglon_compras_id_seq'::regclass);


--
-- TOC entry 3291 (class 2604 OID 199539)
-- Name: tipoPersona idTipoPersona; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tipoPersona" ALTER COLUMN "idTipoPersona" SET DEFAULT nextval('public."tipoPersona_idTipoPersona_seq"'::regclass);


--
-- TOC entry 3288 (class 2604 OID 191347)
-- Name: tiposClave id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tiposClave" ALTER COLUMN id SET DEFAULT nextval('public."tiposClave_id_seq"'::regclass);


--
-- TOC entry 3289 (class 2604 OID 191357)
-- Name: tiposDocumentos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tiposDocumentos" ALTER COLUMN id SET DEFAULT nextval('public."tiposDocumentos_id_seq"'::regclass);


--
-- TOC entry 3283 (class 2604 OID 101168)
-- Name: unidad_medida id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unidad_medida ALTER COLUMN id SET DEFAULT nextval('public.unidad_medida_id_seq'::regclass);


--
-- TOC entry 3295 (class 2604 OID 208309)
-- Name: ventas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas ALTER COLUMN id SET DEFAULT nextval('public.ventas_id_seq'::regclass);


--
-- TOC entry 3624 (class 0 OID 208362)
-- Dependencies: 252
-- Data for Name: FormadePago_Venta; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (1, 443, 1, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (2, 254, 2, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (3, 300, 3, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (4, 32, 3, 2);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (5, 247.5, 4, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (6, 99, 5, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (7, 219.77999999999997, 5, 2);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (8, 90, 6, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (9, 217, 7, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (10, 2201.5, 8, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (11, 284.6, 9, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (12, 100, 10, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (13, 99, 11, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (14, 99, 12, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (15, 117.6, 13, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (16, 100, 14, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (17, 100, 15, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (18, 120, 16, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (19, 120, 17, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (20, 100, 18, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (21, 100, 19, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (22, 100, 20, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (23, 72, 21, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (24, 99.82499999999999, 22, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (25, 99.82499999999999, 23, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (26, 99.82499999999999, 24, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (27, 61, 25, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (28, 61, 26, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (29, 61, 27, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (30, 61, 28, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (31, 61, 29, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (32, 61, 30, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (33, 61, 31, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (34, 55.50000000000001, 32, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (35, 146.4, 33, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (36, 55.50000000000001, 34, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (37, 55.50000000000001, 35, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (38, 55.50000000000001, 36, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (39, 333.00000000000006, 37, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (40, 146.4, 38, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (41, 55.50000000000001, 39, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (42, 333.00000000000006, 40, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (43, 146.4, 41, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (44, 55.50000000000001, 42, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (45, 333.00000000000006, 43, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (46, 166.50000000000003, 44, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (47, 146.4, 45, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (48, 138.75000000000003, 46, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (49, 333.00000000000006, 47, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (50, 333.00000000000006, 48, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (51, 333.00000000000006, 49, 1);
INSERT INTO public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) VALUES (52, 333.00000000000006, 50, 1);


--
-- TOC entry 3594 (class 0 OID 183299)
-- Dependencies: 222
-- Data for Name: ab_permission; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ab_permission (id, name) VALUES (30, 'can_this_form_get');
INSERT INTO public.ab_permission (id, name) VALUES (31, 'can_this_form_post');
INSERT INTO public.ab_permission (id, name) VALUES (32, 'can_download');
INSERT INTO public.ab_permission (id, name) VALUES (33, 'can_list');
INSERT INTO public.ab_permission (id, name) VALUES (34, 'can_add');
INSERT INTO public.ab_permission (id, name) VALUES (35, 'can_delete');
INSERT INTO public.ab_permission (id, name) VALUES (36, 'can_userinfo');
INSERT INTO public.ab_permission (id, name) VALUES (37, 'can_edit');
INSERT INTO public.ab_permission (id, name) VALUES (38, 'can_show');
INSERT INTO public.ab_permission (id, name) VALUES (39, 'resetmypassword');
INSERT INTO public.ab_permission (id, name) VALUES (40, 'resetpasswords');
INSERT INTO public.ab_permission (id, name) VALUES (41, 'userinfoedit');
INSERT INTO public.ab_permission (id, name) VALUES (42, 'menu_access');
INSERT INTO public.ab_permission (id, name) VALUES (43, 'copyrole');
INSERT INTO public.ab_permission (id, name) VALUES (44, 'can_chart');
INSERT INTO public.ab_permission (id, name) VALUES (45, 'can_get');
INSERT INTO public.ab_permission (id, name) VALUES (46, 'can_put');
INSERT INTO public.ab_permission (id, name) VALUES (47, 'can_info');
INSERT INTO public.ab_permission (id, name) VALUES (48, 'can_post');
INSERT INTO public.ab_permission (id, name) VALUES (53, 'can_venta');
INSERT INTO public.ab_permission (id, name) VALUES (54, 'can_access');
INSERT INTO public.ab_permission (id, name) VALUES (56, 'can_show_static_pdf');
INSERT INTO public.ab_permission (id, name) VALUES (57, 'can_download_pdf');


--
-- TOC entry 3599 (class 0 OID 183354)
-- Dependencies: 227
-- Data for Name: ab_permission_view; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (257, 30, 113);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (258, 31, 113);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (259, 30, 114);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (260, 31, 114);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (261, 30, 115);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (262, 31, 115);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (263, 32, 117);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (264, 33, 117);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (265, 34, 117);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (266, 35, 117);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (267, 36, 117);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (268, 37, 117);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (269, 38, 117);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (270, 39, 117);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (271, 40, 117);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (272, 41, 117);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (273, 42, 118);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (274, 42, 119);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (275, 32, 120);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (276, 33, 120);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (277, 34, 120);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (278, 35, 120);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (279, 37, 120);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (280, 38, 120);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (281, 43, 120);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (282, 42, 121);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (283, 44, 122);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (284, 42, 123);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (285, 33, 124);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (286, 42, 125);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (287, 33, 126);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (288, 42, 127);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (289, 33, 128);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (290, 42, 129);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (291, 45, 130);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (292, 46, 131);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (293, 35, 131);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (294, 45, 131);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (295, 47, 131);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (296, 48, 131);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (366, 53, 161);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (367, 42, 162);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (368, 42, 163);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (369, 54, 164);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (370, 42, 165);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (372, 42, 167);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (373, 42, 168);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (374, 33, 169);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (375, 34, 169);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (376, 37, 169);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (377, 35, 169);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (378, 42, 170);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (379, 33, 171);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (380, 34, 171);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (381, 37, 171);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (382, 35, 171);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (383, 42, 172);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (384, 38, 173);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (385, 32, 173);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (386, 37, 173);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (387, 35, 173);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (388, 34, 173);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (389, 33, 173);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (390, 38, 174);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (391, 32, 174);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (392, 37, 174);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (393, 35, 174);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (394, 34, 174);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (395, 33, 174);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (396, 38, 175);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (397, 32, 175);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (398, 37, 175);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (399, 35, 175);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (400, 34, 175);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (401, 33, 175);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (402, 38, 176);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (403, 32, 176);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (404, 37, 176);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (405, 35, 176);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (406, 34, 176);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (407, 33, 176);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (408, 56, 177);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (412, 42, 179);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (416, 42, 181);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (417, 33, 182);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (418, 42, 183);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (419, 38, 184);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (420, 33, 184);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (421, 37, 184);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (422, 38, 185);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (423, 32, 185);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (424, 37, 185);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (425, 35, 185);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (426, 34, 185);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (427, 33, 185);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (428, 38, 186);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (429, 32, 186);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (430, 37, 186);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (431, 35, 186);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (432, 34, 186);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (433, 33, 186);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (434, 54, 187);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (435, 38, 188);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (436, 33, 188);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (437, 37, 188);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (438, 38, 189);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (439, 33, 189);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (440, 37, 189);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (441, 35, 188);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (442, 57, 188);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (443, 54, 188);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (444, 32, 188);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (445, 34, 188);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (446, 38, 190);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (447, 33, 190);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (448, 37, 190);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (449, 38, 191);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (450, 33, 191);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (451, 37, 191);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (452, 38, 192);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (453, 33, 192);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (454, 37, 192);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (455, 54, 192);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (456, 54, 193);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (457, 54, 194);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (458, 32, 195);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (459, 37, 195);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (460, 33, 195);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (461, 35, 195);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (462, 38, 195);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (463, 34, 195);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (464, 42, 196);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (465, 42, 197);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (466, 34, 198);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (467, 33, 198);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (468, 37, 198);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (469, 38, 198);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (470, 32, 198);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (471, 35, 198);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (472, 42, 199);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (473, 34, 200);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (474, 33, 200);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (475, 37, 200);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (476, 38, 200);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (477, 32, 200);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (478, 35, 200);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (479, 42, 201);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (480, 33, 202);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (481, 38, 202);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (482, 42, 203);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (483, 44, 204);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (484, 42, 205);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (485, 37, 206);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (486, 34, 206);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (487, 32, 206);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (488, 38, 206);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (489, 33, 206);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (490, 35, 206);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (491, 33, 208);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (492, 38, 208);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (493, 35, 208);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (494, 38, 209);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (495, 35, 209);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (496, 32, 209);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (497, 34, 209);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (498, 37, 209);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (499, 33, 209);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (500, 42, 210);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (501, 33, 161);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (502, 37, 161);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (503, 34, 161);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (504, 32, 161);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (505, 38, 161);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (506, 35, 161);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (507, 34, 191);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (508, 32, 132);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (509, 38, 132);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (510, 33, 132);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (511, 35, 132);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (512, 34, 132);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (513, 37, 132);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (514, 42, 212);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (515, 42, 213);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (516, 33, 133);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (517, 32, 133);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (518, 37, 133);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (519, 34, 133);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (520, 38, 133);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (521, 35, 133);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (522, 35, 191);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (523, 35, 190);


--
-- TOC entry 3601 (class 0 OID 183388)
-- Dependencies: 229
-- Data for Name: ab_permission_view_role; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (298, 257, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (299, 258, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (300, 259, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (301, 260, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (302, 261, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (303, 262, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (304, 263, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (305, 264, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (306, 265, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (307, 266, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (308, 267, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (309, 268, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (310, 269, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (311, 270, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (312, 271, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (313, 272, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (314, 273, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (315, 274, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (316, 275, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (317, 276, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (318, 277, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (319, 278, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (320, 279, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (321, 280, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (322, 281, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (323, 282, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (324, 283, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (325, 284, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (326, 285, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (327, 286, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (328, 287, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (329, 288, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (330, 289, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (331, 290, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (332, 291, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (333, 292, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (334, 293, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (335, 294, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (336, 295, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (337, 296, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (410, 366, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (411, 367, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (412, 368, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (413, 369, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (414, 370, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (416, 372, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (417, 373, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (418, 374, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (419, 375, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (420, 376, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (421, 377, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (422, 378, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (423, 379, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (424, 380, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (425, 381, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (426, 382, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (427, 383, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (428, 384, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (429, 385, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (430, 386, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (431, 387, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (432, 388, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (433, 389, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (434, 390, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (435, 391, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (436, 392, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (437, 393, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (438, 394, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (439, 395, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (440, 396, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (441, 397, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (442, 398, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (443, 399, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (444, 400, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (445, 401, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (446, 402, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (447, 403, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (448, 404, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (449, 405, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (450, 406, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (451, 407, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (452, 408, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (456, 412, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (460, 416, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (461, 417, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (462, 418, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (463, 419, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (464, 420, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (465, 421, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (466, 422, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (467, 423, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (468, 424, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (469, 425, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (470, 426, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (471, 427, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (472, 428, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (473, 429, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (474, 430, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (475, 431, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (476, 432, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (477, 433, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (479, 434, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (480, 435, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (481, 436, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (482, 437, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (483, 438, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (484, 439, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (485, 440, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (486, 441, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (487, 442, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (488, 443, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (489, 444, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (490, 445, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (491, 446, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (492, 447, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (493, 448, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (494, 449, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (495, 450, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (496, 451, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (497, 366, 8);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (498, 367, 8);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (499, 368, 8);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (500, 374, 8);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (501, 375, 8);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (502, 378, 8);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (503, 412, 8);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (504, 449, 8);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (505, 450, 8);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (506, 452, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (507, 453, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (508, 454, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (509, 455, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (510, 456, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (511, 457, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (512, 458, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (513, 459, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (514, 460, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (515, 461, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (516, 462, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (517, 463, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (518, 464, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (519, 465, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (520, 466, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (521, 467, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (522, 468, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (523, 469, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (524, 470, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (525, 471, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (526, 472, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (527, 473, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (528, 474, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (529, 475, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (530, 476, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (531, 477, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (532, 478, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (533, 479, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (534, 480, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (535, 481, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (536, 482, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (537, 483, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (538, 484, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (539, 485, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (540, 486, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (541, 487, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (542, 488, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (543, 489, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (544, 490, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (545, 491, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (546, 492, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (547, 493, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (548, 494, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (549, 495, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (550, 496, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (551, 497, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (552, 498, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (553, 499, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (554, 500, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (555, 501, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (556, 502, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (557, 503, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (558, 504, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (559, 505, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (560, 506, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (561, 507, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (562, 259, 8);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (563, 261, 8);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (564, 262, 8);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (565, 264, 8);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (566, 265, 8);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (567, 267, 8);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (568, 268, 8);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (569, 269, 8);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (570, 270, 8);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (571, 271, 8);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (572, 272, 8);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (573, 508, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (574, 509, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (575, 510, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (576, 511, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (577, 512, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (578, 513, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (579, 514, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (580, 515, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (581, 516, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (582, 517, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (583, 518, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (584, 519, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (585, 520, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (586, 521, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (587, 522, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (588, 523, 5);


--
-- TOC entry 3598 (class 0 OID 183344)
-- Dependencies: 226
-- Data for Name: ab_register_user; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3596 (class 0 OID 183313)
-- Dependencies: 224
-- Data for Name: ab_role; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ab_role (id, name) VALUES (5, 'Admin');
INSERT INTO public.ab_role (id, name) VALUES (6, 'Public');
INSERT INTO public.ab_role (id, name) VALUES (7, 'Gerente');
INSERT INTO public.ab_role (id, name) VALUES (8, 'vendedor');


--
-- TOC entry 3597 (class 0 OID 183320)
-- Dependencies: 225
-- Data for Name: ab_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ab_user (id, first_name, last_name, username, password, active, email, last_login, login_count, fail_login_count, created_on, changed_on, created_by_fk, changed_by_fk, cuil) VALUES (8, 'enrique', 'sand', 'egsand', 'pbkdf2:sha256:50000$M2KUtiFD$2bbe3354fdf08e42d3a2b9cfb6e08ba7e693dbe72a933f530184e52c9353f827', true, 'xovibe4870@x1post.com', '2020-11-06 10:01:50.553639', 1, 0, '2020-11-06 09:50:56.941954', '2020-11-06 10:11:03.964096', NULL, 6, '27-05883446-2');
INSERT INTO public.ab_user (id, first_name, last_name, username, password, active, email, last_login, login_count, fail_login_count, created_on, changed_on, created_by_fk, changed_by_fk, cuil) VALUES (17, 'vendedor', '1', 'vendedor', 'pbkdf2:sha256:50000$suwSLpY6$e59f815bc57ab0d88b389602b91d68744bcc684f30d7b6acf37eed744143b983', true, 'dayim53320@idcbill.com', '2020-11-11 09:42:34.833647', 2, 0, '2020-11-10 21:56:07.058721', '2020-11-10 21:57:45.652447', NULL, 6, '27-10604821-0');
INSERT INTO public.ab_user (id, first_name, last_name, username, password, active, email, last_login, login_count, fail_login_count, created_on, changed_on, created_by_fk, changed_by_fk, cuil) VALUES (6, 'gerente', 'gerente', 'gerente1', 'pbkdf2:sha256:50000$Q5m5vE72$9a595328c91717556dc8d8e9a89b781f26a05c50016dc84e195797eb8bdcaac4', true, 'gerente@gmail.com', '2020-11-11 13:52:16.415815', 16, 0, '2020-10-15 18:33:32.22051', '2020-10-26 12:54:36.693305', 5, 5, '27-39441118-9');
INSERT INTO public.ab_user (id, first_name, last_name, username, password, active, email, last_login, login_count, fail_login_count, created_on, changed_on, created_by_fk, changed_by_fk, cuil) VALUES (16, 'jack', 'nickolson', 'jack', 'pbkdf2:sha256:50000$gPa5yVlC$ef4dea0120344212163d25b946edcba8ca9f5eafd782fe1f6d07cba7b4b61372', true, 'sirepo4423@x1post.com', '2020-11-09 14:54:54.205387', 1, 0, '2020-11-09 14:54:38.867965', '2020-11-09 14:54:38.867965', NULL, NULL, NULL);
INSERT INTO public.ab_user (id, first_name, last_name, username, password, active, email, last_login, login_count, fail_login_count, created_on, changed_on, created_by_fk, changed_by_fk, cuil) VALUES (5, 'admin', 'super', 'superadmin', 'pbkdf2:sha256:50000$DIByLH7T$9421fe78a224369623f4e330177bcbebf9f22d6384b72366d8f8f4ec3511d55e', true, 'admin@fab.org', '2020-11-12 22:01:58.901947', 44, 0, '2020-10-15 18:13:49.879222', '2020-10-15 18:13:49.879222', NULL, NULL, NULL);


--
-- TOC entry 3600 (class 0 OID 183371)
-- Dependencies: 228
-- Data for Name: ab_user_role; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ab_user_role (id, user_id, role_id) VALUES (6, 5, 5);
INSERT INTO public.ab_user_role (id, user_id, role_id) VALUES (9, 6, 7);
INSERT INTO public.ab_user_role (id, user_id, role_id) VALUES (11, 8, 6);
INSERT INTO public.ab_user_role (id, user_id, role_id) VALUES (12, 8, 8);
INSERT INTO public.ab_user_role (id, user_id, role_id) VALUES (24, 16, 6);
INSERT INTO public.ab_user_role (id, user_id, role_id) VALUES (25, 17, 6);
INSERT INTO public.ab_user_role (id, user_id, role_id) VALUES (26, 17, 8);


--
-- TOC entry 3595 (class 0 OID 183306)
-- Dependencies: 223
-- Data for Name: ab_view_menu; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ab_view_menu (id, name) VALUES (109, 'IndexView');
INSERT INTO public.ab_view_menu (id, name) VALUES (110, 'UtilView');
INSERT INTO public.ab_view_menu (id, name) VALUES (111, 'LocaleView');
INSERT INTO public.ab_view_menu (id, name) VALUES (112, 'SecurityApi');
INSERT INTO public.ab_view_menu (id, name) VALUES (113, 'ResetPasswordView');
INSERT INTO public.ab_view_menu (id, name) VALUES (114, 'ResetMyPasswordView');
INSERT INTO public.ab_view_menu (id, name) VALUES (115, 'UserInfoEditView');
INSERT INTO public.ab_view_menu (id, name) VALUES (116, 'AuthDBView');
INSERT INTO public.ab_view_menu (id, name) VALUES (117, 'MyUserDBModelView');
INSERT INTO public.ab_view_menu (id, name) VALUES (118, 'List Users');
INSERT INTO public.ab_view_menu (id, name) VALUES (119, 'Security');
INSERT INTO public.ab_view_menu (id, name) VALUES (120, 'RoleModelView');
INSERT INTO public.ab_view_menu (id, name) VALUES (121, 'List Roles');
INSERT INTO public.ab_view_menu (id, name) VALUES (122, 'UserStatsChartView');
INSERT INTO public.ab_view_menu (id, name) VALUES (123, 'User''s Statistics');
INSERT INTO public.ab_view_menu (id, name) VALUES (124, 'PermissionModelView');
INSERT INTO public.ab_view_menu (id, name) VALUES (125, 'Base Permissions');
INSERT INTO public.ab_view_menu (id, name) VALUES (126, 'ViewMenuModelView');
INSERT INTO public.ab_view_menu (id, name) VALUES (127, 'Views/Menus');
INSERT INTO public.ab_view_menu (id, name) VALUES (128, 'PermissionViewModelView');
INSERT INTO public.ab_view_menu (id, name) VALUES (129, 'Permission on Views/Menus');
INSERT INTO public.ab_view_menu (id, name) VALUES (130, 'MenuApi');
INSERT INTO public.ab_view_menu (id, name) VALUES (131, 'ProductoApi');
INSERT INTO public.ab_view_menu (id, name) VALUES (132, 'VentasApi');
INSERT INTO public.ab_view_menu (id, name) VALUES (133, 'ComprasApi');
INSERT INTO public.ab_view_menu (id, name) VALUES (161, 'VentaView');
INSERT INTO public.ab_view_menu (id, name) VALUES (162, 'Realizar Ventas');
INSERT INTO public.ab_view_menu (id, name) VALUES (163, 'Ventas');
INSERT INTO public.ab_view_menu (id, name) VALUES (164, 'productocrud');
INSERT INTO public.ab_view_menu (id, name) VALUES (165, 'Productos');
INSERT INTO public.ab_view_menu (id, name) VALUES (167, 'Compra');
INSERT INTO public.ab_view_menu (id, name) VALUES (168, 'Compras');
INSERT INTO public.ab_view_menu (id, name) VALUES (169, 'ClientesView');
INSERT INTO public.ab_view_menu (id, name) VALUES (170, 'Clientes');
INSERT INTO public.ab_view_menu (id, name) VALUES (171, 'ProveedorView');
INSERT INTO public.ab_view_menu (id, name) VALUES (172, 'Proveedor');
INSERT INTO public.ab_view_menu (id, name) VALUES (173, 'ProductoModelview');
INSERT INTO public.ab_view_menu (id, name) VALUES (174, 'MarcasModelview');
INSERT INTO public.ab_view_menu (id, name) VALUES (175, 'unidadesModelView');
INSERT INTO public.ab_view_menu (id, name) VALUES (176, 'CategoriaModelview');
INSERT INTO public.ab_view_menu (id, name) VALUES (177, 'ReportesView');
INSERT INTO public.ab_view_menu (id, name) VALUES (179, 'Reporte Ventas');
INSERT INTO public.ab_view_menu (id, name) VALUES (181, 'Reporte Compras');
INSERT INTO public.ab_view_menu (id, name) VALUES (182, 'Sistemaview');
INSERT INTO public.ab_view_menu (id, name) VALUES (183, 'Datos Empresa');
INSERT INTO public.ab_view_menu (id, name) VALUES (184, 'Empresaview');
INSERT INTO public.ab_view_menu (id, name) VALUES (185, 'CompaniaTarjetaview');
INSERT INTO public.ab_view_menu (id, name) VALUES (186, 'RenglonVentas');
INSERT INTO public.ab_view_menu (id, name) VALUES (187, 'compraclass');
INSERT INTO public.ab_view_menu (id, name) VALUES (188, 'comprarepo');
INSERT INTO public.ab_view_menu (id, name) VALUES (189, 'ventarepo');
INSERT INTO public.ab_view_menu (id, name) VALUES (190, 'CompraReportes');
INSERT INTO public.ab_view_menu (id, name) VALUES (191, 'VentaReportes');
INSERT INTO public.ab_view_menu (id, name) VALUES (192, 'empresa');
INSERT INTO public.ab_view_menu (id, name) VALUES (193, 'crudempresa');
INSERT INTO public.ab_view_menu (id, name) VALUES (194, 'tarjeta');
INSERT INTO public.ab_view_menu (id, name) VALUES (195, 'compraauditoriaView');
INSERT INTO public.ab_view_menu (id, name) VALUES (196, 'compra');
INSERT INTO public.ab_view_menu (id, name) VALUES (197, 'compraaud');
INSERT INTO public.ab_view_menu (id, name) VALUES (198, 'ventaauditoriaView');
INSERT INTO public.ab_view_menu (id, name) VALUES (199, 'Ventaau');
INSERT INTO public.ab_view_menu (id, name) VALUES (200, 'clientesauditoriaView');
INSERT INTO public.ab_view_menu (id, name) VALUES (201, 'Clientesaud');
INSERT INTO public.ab_view_menu (id, name) VALUES (202, 'AuditLogView');
INSERT INTO public.ab_view_menu (id, name) VALUES (203, 'Audit Events');
INSERT INTO public.ab_view_menu (id, name) VALUES (204, 'AuditLogChartView');
INSERT INTO public.ab_view_menu (id, name) VALUES (205, 'Chart Events');
INSERT INTO public.ab_view_menu (id, name) VALUES (206, 'MetododepagoVentas');
INSERT INTO public.ab_view_menu (id, name) VALUES (207, 'RegisterUserDBView');
INSERT INTO public.ab_view_menu (id, name) VALUES (208, 'RegisterUserModelView');
INSERT INTO public.ab_view_menu (id, name) VALUES (209, 'PrecioMdelview');
INSERT INTO public.ab_view_menu (id, name) VALUES (210, 'Control de Precios');
INSERT INTO public.ab_view_menu (id, name) VALUES (211, 'MyRegisterUserDBView');
INSERT INTO public.ab_view_menu (id, name) VALUES (212, 'Auditoria');
INSERT INTO public.ab_view_menu (id, name) VALUES (213, 'Graficos de Auditoria');


--
-- TOC entry 3632 (class 0 OID 232886)
-- Dependencies: 260
-- Data for Name: auditoria; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (16, 'Consumidor Final 100.0 True 2020-11-11', 'superadmin', '2020-11-11 10:56:58.69499', 13, 'VentasApi');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (17, 'Consumidor Final 72.0 True 2020-11-11', 'superadmin', '2020-11-11 11:10:25.178567', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (18, 'Consumidor Final 72.0 False 2020-11-11', 'superadmin', '2020-11-11 11:11:03.085512', 14, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (19, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-11 11:33:43.948525', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (20, 'galletita rex 250.0 gramos', 'superadmin', '2020-11-11 11:55:00.535191', 15, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (21, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-11 11:55:00.818183', 15, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (22, 'reinharina', 'superadmin', '2020-11-11 11:57:10.330832', 15, 'Marcas');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (23, '  DNI 253648741 ', 'superadmin', '2020-11-11 12:01:04.513283', 14, 'Clientes');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (24, 'virginia  DNI 253648741 ', 'superadmin', '2020-11-11 12:02:17.814743', 14, 'Clientes');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (25, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-11 12:03:23.669795', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (26, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-11 12:04:34.073567', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (27, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-11 12:12:28.364965', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (28, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-11 12:13:38.745551', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (29, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-11 12:16:46.697979', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (30, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-11 12:19:02.964268', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (31, 'cotto', 'superadmin', '2020-11-11 12:20:27.557761', 13, 'Marcas');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (32, 'galletita rex 250.0 gramos', 'superadmin', '2020-11-11 12:21:03.286426', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (33, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-11 12:24:13.362413', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (34, 'galletita rex 250.0 gramos', 'superadmin', '2020-11-11 12:29:18.188456', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (35, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-11 12:32:13.641424', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (36, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-11 12:35:24.648615', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (37, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-11 12:40:31.952125', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (38, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-11 12:41:10.485509', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (39, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-11 12:43:39.433488', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (40, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-11 12:47:10.181076', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (41, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-11 12:50:16.477893', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (42, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-11 12:51:29.353544', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (43, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-11 12:53:36.04027', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (44, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-11 13:00:25.461854', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (45, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-11 13:15:11.772297', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (46, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-11 13:16:42.784706', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (47, 'yerba guarani 400.0 gramos', 'superadmin', '2020-11-11 13:22:18.310552', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (48, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-11 13:28:06.966194', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (49, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-11 13:30:28.635488', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (50, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-11 13:33:23.848822', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (51, 'Marcelo Lobardys CUIT 27-10255123-6 ', 'superadmin', '2020-11-11 13:45:15.540311', 14, 'Clientes');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (52, 'Cuit 30-99924708-9 ricargdino barselo 990.0 True 2020-11-11', 'gerente1', '2020-11-11 13:53:22.254867', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (53, 'Cuit 20-41091788-3 sand enrique 25000.0 True 2020-11-11', 'gerente1', '2020-11-11 13:57:28.802332', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (54, '{''unidad'': ''gramos'', ''marca'': ''rex'', ''categoria'': ''galletita'', ''estado'': True, ''precio'': 50.0, ''stock'': 72, ''iva'': 11.0, ''medida'': 251.0, ''detalle'': ''''}', 'superadmin', '2020-11-11 13:59:09.911312', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (55, 'Consumidor Final 61.0 True 2020-11-11', 'superadmin', '2020-11-11 14:09:32.616416', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (56, 'Cuit 20-41091788-3 sand enrique 0.0 True 2020-11-11', 'superadmin', '2020-11-11 14:22:54.206579', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (57, 'Cuit 30-13453456-3 Retondo Cortencio', 'superadmin', '2020-11-11 15:58:03.661547', 14, 'Proveedor');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (58, 'Cuit 30-13453456-3 Retondo Cortencio', 'superadmin', '2020-11-11 16:13:42.444902', 14, 'Proveedor');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (59, 'virginia rosas DNI 253648741 ', 'superadmin', '2020-11-11 16:35:52.426121', 14, 'Clientes');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (60, 'Cuit 27-11077410-4 Cortencio Odulio', 'superadmin', '2020-11-11 16:40:13.424268', 13, 'Proveedor');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (61, 'Cuit 27-11077410-4 Cortencio Odulio', 'superadmin', '2020-11-11 16:46:46.939323', 14, 'Proveedor');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (62, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-12 22:59:20.634191', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (63, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-12 22:59:20.682186', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (64, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 22:59:20.723188', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (65, 'yerba guarani 400.0 gramos', 'superadmin', '2020-11-12 22:59:20.760187', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (66, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-12 22:59:43.043276', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (67, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-12 22:59:43.117274', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (68, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 22:59:43.183273', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (69, 'yerba guarani 400.0 gramos', 'superadmin', '2020-11-12 22:59:43.273271', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (70, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-12 23:03:04.077272', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (71, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-12 23:03:04.188277', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (72, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 23:03:04.27828', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (73, 'yerba guarani 400.0 gramos', 'superadmin', '2020-11-12 23:03:04.324272', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (74, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-12 23:03:37.475336', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (75, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-12 23:03:37.523334', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (76, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 23:03:37.566331', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (77, 'yerba guarani 400.0 gramos', 'superadmin', '2020-11-12 23:03:37.614338', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (78, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-12 23:03:46.747133', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (79, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-12 23:03:46.823142', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (80, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 23:03:46.889135', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (81, 'yerba guarani 400.0 gramos', 'superadmin', '2020-11-12 23:03:46.956139', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (82, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-12 23:05:55.759962', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (83, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-12 23:05:55.860967', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (84, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 23:05:55.923961', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (85, 'yerba guarani 400.0 gramos', 'superadmin', '2020-11-12 23:05:56.047965', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (86, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-12 23:08:29.877807', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (87, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-12 23:08:30.025812', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (88, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 23:08:30.083802', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (89, 'yerba guarani 400.0 gramos', 'superadmin', '2020-11-12 23:08:30.136805', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (90, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-12 23:11:43.493429', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (91, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-12 23:11:43.602438', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (92, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 23:11:43.695428', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (93, 'yerba guarani 400.0 gramos', 'superadmin', '2020-11-12 23:11:43.797434', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (94, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-12 23:14:23.732235', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (95, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-12 23:14:23.782239', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (96, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 23:14:23.830432', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (97, 'yerba guarani 400.0 gramos', 'superadmin', '2020-11-12 23:14:23.877037', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (98, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-12 23:14:30.321868', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (99, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-12 23:14:30.428876', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (100, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 23:14:30.472874', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (101, 'yerba guarani 400.0 gramos', 'superadmin', '2020-11-12 23:14:30.510874', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (102, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-12 23:14:35.877248', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (103, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-12 23:14:35.921255', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (104, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 23:14:35.967257', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (105, 'yerba guarani 400.0 gramos', 'superadmin', '2020-11-12 23:14:36.006253', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (106, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-12 23:33:47.903825', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (107, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-12 23:33:47.947836', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (108, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 23:33:48.000836', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (109, 'yerba guarani 400.0 gramos', 'superadmin', '2020-11-12 23:33:48.129825', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (110, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-12 23:34:10.820955', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (111, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-12 23:34:10.85495', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (112, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 23:34:10.882958', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (113, 'yerba guarani 400.0 gramos', 'superadmin', '2020-11-12 23:34:10.918956', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (114, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-12 23:34:17.673763', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (115, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-12 23:34:17.715772', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (116, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 23:34:17.752771', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (117, 'yerba guarani 400.0 gramos', 'superadmin', '2020-11-12 23:34:17.78477', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (118, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-12 23:34:28.378079', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (119, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 23:34:38.264145', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (120, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-12 23:34:47.657628', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (121, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-12 23:34:55.601052', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (122, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-12 23:38:21.554192', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (123, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 23:38:21.631192', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (124, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-12 23:38:21.702192', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (125, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-12 23:38:21.777564', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (126, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-12 23:40:44.645964', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (127, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 23:40:44.693977', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (128, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-12 23:40:44.739966', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (129, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-12 23:40:44.782961', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (130, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 23:45:31.510818', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (131, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-12 23:46:20.284498', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (132, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-12 23:46:20.327497', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (133, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-12 23:46:20.36949', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (134, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 23:46:20.413496', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (135, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-12 23:48:40.014597', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (136, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-12 23:48:40.074589', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (137, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-12 23:48:40.13359', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (138, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 23:48:40.181586', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (139, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-12 23:54:31.298242', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (140, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-12 23:54:31.379246', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (141, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-12 23:54:31.426246', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (142, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 23:54:31.478246', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (143, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-12 23:57:34.183028', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (144, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-12 23:57:34.229046', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (145, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-12 23:57:34.269034', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (146, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 23:57:34.306046', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (147, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-12 23:57:52.173743', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (148, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-12 23:57:52.216745', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (149, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-12 23:57:52.254744', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (150, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 23:57:52.342749', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (151, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-12 23:58:37.148904', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (152, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-12 23:58:37.191909', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (153, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-12 23:58:37.233908', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (154, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 23:58:37.271921', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (155, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-12 23:58:52.149601', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (156, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-12 23:58:52.194606', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (157, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-12 23:58:52.231616', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (158, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 23:58:52.268608', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (159, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-12 23:58:58.113822', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (160, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-12 23:58:58.158827', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (161, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-12 23:58:58.195823', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (162, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 23:58:58.231837', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (163, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-12 23:59:25.936793', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (164, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-12 23:59:25.982789', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (165, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-12 23:59:26.028792', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (166, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-12 23:59:26.073793', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (167, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-13 00:03:28.12233', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (168, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-13 00:03:28.165347', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (169, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-13 00:03:28.202334', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (170, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-13 00:03:28.239333', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (171, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-13 00:04:18.830624', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (172, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-13 00:04:18.88463', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (173, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-13 00:04:18.927633', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (174, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-13 00:04:18.965625', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (175, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-13 00:10:29.670114', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (176, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-13 00:10:29.712113', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (177, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-13 00:10:29.78212', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (178, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-13 00:10:29.835123', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (179, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-13 00:14:38.746316', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (180, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-13 00:14:38.829316', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (181, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-13 00:14:38.921322', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (182, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-13 00:14:38.971322', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (183, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-13 00:17:55.268565', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (184, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-13 00:17:55.320568', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (185, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-13 00:17:55.36157', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (186, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-13 00:17:55.404565', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (187, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-13 00:19:30.066409', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (188, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-13 00:19:30.114407', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (189, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-13 00:19:30.162411', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (190, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-13 00:19:30.204403', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (191, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-13 00:40:15.234128', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (192, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-13 00:40:15.282122', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (193, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-13 00:40:15.321139', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (194, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-13 00:40:15.356122', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (195, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-13 00:40:28.315014', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (196, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-13 00:40:28.402032', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (197, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-13 00:40:28.438014', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (198, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-13 00:40:28.478023', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (199, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-13 00:40:49.892104', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (200, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-13 00:40:49.927558', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (201, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-13 00:40:49.965575', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (202, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-13 00:40:50.002554', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (203, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-13 00:41:29.046545', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (204, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-13 00:41:46.398658', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (205, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-13 00:42:29.51646', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (206, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-13 00:42:29.567456', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (207, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-13 00:42:29.615457', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (208, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-13 00:42:29.663452', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (224, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-13 08:58:42.315243', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (225, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-13 08:58:42.412865', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (226, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-13 08:58:42.458188', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (227, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-13 08:58:42.495201', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (228, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-13 08:59:14.74983', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (229, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-13 08:59:14.791833', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (230, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-13 08:59:14.844833', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (231, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-13 08:59:14.910832', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (232, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-13 09:01:47.260204', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (233, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-13 09:05:03.148543', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (234, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-13 09:05:03.242529', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (235, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-13 09:05:42.887224', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (236, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-13 09:05:42.925226', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (237, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-13 09:09:05.194788', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (238, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-13 09:09:05.28979', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (239, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-13 09:09:05.335787', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (240, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-13 09:09:05.379789', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (241, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-13 09:12:19.265054', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (242, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-13 09:12:19.425054', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (243, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-13 09:12:19.508055', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (244, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-13 09:12:19.593051', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (245, 'galletita rex 251.0 gramos', 'superadmin', '2020-11-13 09:12:36.059603', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (246, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-13 09:12:46.549555', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (247, 'gaseosa coca cola 1.5 litro', 'superadmin', '2020-11-13 09:13:15.373423', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (248, 'yerba guarani 500.0 gramos', 'superadmin', '2020-11-13 09:13:33.023935', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (249, 'galletita saladix 250.0 gramos', 'superadmin', '2020-11-13 09:17:56.201626', 15, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (250, 'Consumidor Final 55.5 True 2020-11-13', 'superadmin', '2020-11-13 09:40:21.362235', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (251, '', 'superadmin', '2020-11-13 11:45:15.648282', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (252, 'cliente Consumidor Final totaliva 0.0 percepcion 0.0 ', 'superadmin', '2020-11-13 12:11:51.851124', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (253, 'cliente Consumidor Final totaliva 0.0 percepcion 0.0 estadorender <b> Venta Realizada </b> ', 'superadmin', '2020-11-13 12:14:36.995348', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (254, 'cliente Consumidor Final totaliva 0.0 percepcion 0.0 ', 'superadmin', '2020-11-13 12:19:07.892446', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (255, 'cliente Consumidor Final totaliva 0.0 percepcion 0.0 ESTADO  Venta Realizada </b> ', 'superadmin', '2020-11-13 12:20:42.01684', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (256, 'cliente Consumidor Final totaliva 0.0 percepcion 0.0 ESTADO  Venta Realizada  ', 'superadmin', '2020-11-13 12:22:18.835517', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (257, 'proveedor Cuit 20-41091788-3 sand enrique totaliva 0.0 total 20000.0 ESTADO  Compra Realizada  formadepago Contado percepcion 0.0 ', 'superadmin', '2020-11-13 12:23:43.314356', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (258, 'unidad litro marca guarani categoria yerba estado True precio 50.0 stock 0 iva 351351.0 medida 250.0 detalle - ', 'superadmin', '2020-11-13 12:37:13.990832', 13, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (259, 'marca salfate ', 'superadmin', '2020-11-13 12:39:28.455695', 13, 'Marcas');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (260, 'marca salfate ', 'superadmin', '2020-11-13 12:40:38.874065', 15, 'Marcas');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (261, 'marca salfate ', 'superadmin', '2020-11-13 12:44:48.547747', 13, 'Marcas');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (262, 'marca AFAFAGS ', 'superadmin', '2020-11-13 12:47:45.783703', 13, 'Marcas');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (263, 'marca AFAFAGS ', 'superadmin', '2020-11-13 12:47:58.72536', 15, 'Marcas');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (264, 'marca salfate ', 'superadmin', '2020-11-13 12:48:03.697674', 15, 'Marcas');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (265, 'marca SALFATE ', 'superadmin', '2020-11-13 12:48:11.647457', 13, 'Marcas');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (266, 'marca SALFATE ', 'superadmin', '2020-11-13 12:48:16.34041', 15, 'Marcas');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (267, 'UNIDAD gramos MARCA rex CATEGORIA galletita ESTADO True PRECIO 25.0 STOCK 55 IVA 11.0 MEDIDA 251.0 DETALLE  ', 'superadmin', '2020-11-13 14:00:19.235959', 15, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (268, 'UNIDAD gramos MARCA rex CATEGORIA galletita ESTADO True PRECIO 25.0 STOCK 55 IVA 11.0 MEDIDA 251.0 DETALLE  ', 'superadmin', '2020-11-13 14:00:26.549453', 15, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (269, 'UNIDAD gramos MARCA rex CATEGORIA galletita ESTADO False PRECIO 25.0 STOCK 55 IVA 11.0 MEDIDA 251.0 DETALLE  ', 'superadmin', '2020-11-13 14:01:22.672038', 15, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (270, 'UNIDAD gramos MARCA rex CATEGORIA galletita ESTADO False PRECIO 25.0 STOCK 55 IVA 11.0 MEDIDA 251.0 DETALLE  ', 'superadmin', '2020-11-13 14:01:30.09597', 15, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (271, 'UNIDAD gramos MARCA rex CATEGORIA galletita ESTADO True PRECIO 25.0 STOCK 55 IVA 11.0 MEDIDA 251.0 DETALLE  ', 'superadmin', '2020-11-13 14:02:26.829048', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (272, 'UNIDAD gramos MARCA saladix CATEGORIA galletita ESTADO True PRECIO 35.0 STOCK 180 IVA 21.0 MEDIDA 250.0 DETALLE  ', 'superadmin', '2020-11-13 14:02:33.139684', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (273, 'CLIENTE Marcelo Lobardys CUIT 27-10255123-6  TOTALIVA 34.0 PERCEPCION 0.0 ESTADO  Venta Anulada  ', 'superadmin', '2020-11-13 14:03:38.701798', 14, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (274, 'CLIENTE Consumidor Final TOTALIVA 0.0 PERCEPCION 0.0 ESTADO  Venta Anulada  ', 'superadmin', '2020-11-13 14:05:05.701658', 14, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (275, 'CLIENTE Consumidor Final TOTALIVA 0.0 PERCEPCION 0.0 ESTADO  Venta Anulada  ', 'superadmin', '2020-11-13 14:05:35.234459', 14, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (276, 'CLIENTE Consumidor Final TOTALIVA 0.0 PERCEPCION 0.0 ESTADO  Venta Anulada  ', 'superadmin', '2020-11-13 14:05:45.078537', 14, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (277, 'CLIENTE Consumidor Final TOTALIVA 0.0 PERCEPCION 0.0 ESTADO  Venta Realizada  ', 'superadmin', '2020-11-13 14:10:58.551167', 14, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (278, 'CLIENTE Consumidor Final TOTALIVA 0.0 PERCEPCION 0.0 ESTADO  Venta Realizada  ', 'superadmin', '2020-11-13 14:11:10.161385', 14, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (279, 'CLIENTE Consumidor Final TOTALIVA 0.0 PERCEPCION 0.0 ESTADO  Venta Anulada  ', 'superadmin', '2020-11-13 14:11:16.297177', 14, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (280, 'CLIENTE Consumidor Final TOTALIVA 0.0 PERCEPCION 0.0 ESTADO  Venta Anulada  ', 'superadmin', '2020-11-13 14:13:09.419152', 14, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (281, 'CLIENTE Consumidor Final TOTALIVA 0.0 PERCEPCION 0.0 ESTADO  Venta Realizada  ', 'superadmin', '2020-11-13 14:13:30.372731', 14, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (282, 'CLIENTE Consumidor Final TOTALIVA 0.0 PERCEPCION 0.0 ESTADO  Venta Realizada  ', 'superadmin', '2020-11-13 14:13:47.034299', 14, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (283, 'CLIENTE Consumidor Final TOTALIVA 0.0 PERCEPCION 0.0 ESTADO  Venta Realizada  ', 'superadmin', '2020-11-13 14:13:52.844944', 14, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (284, 'PROVEEDOR Cuit 30-13453456-3 Retondo Cortencio TOTALIVA 19.8 TOTAL 217.8 ESTADO  Compra Anulada  FORMADEPAGO Contado PERCEPCION 0.0 ', 'superadmin', '2020-11-13 14:14:53.222127', 14, 'Compra');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (285, 'PROVEEDOR Cuit 30-13453456-3 Retondo Cortencio TOTALIVA 19.8 TOTAL 217.8 ESTADO  Compra Realizada  FORMADEPAGO Contado PERCEPCION 0.0 ', 'superadmin', '2020-11-13 14:15:51.869909', 14, 'Compra');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (286, 'CLIENTE Consumidor Final TOTALIVA 0.0 PERCEPCION 0.0 TOTALRENDER <b> $333.0</b> ESTADO  Venta Realizada  ', 'superadmin', '2020-11-13 14:17:18.174312', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (287, 'PROVEEDOR Cuit 20-41091788-3 sand enrique TOTALIVA 0.0 TOTAL 20000.0 ESTADO  Compra Anulada  FORMADEPAGO Contado PERCEPCION 0.0 ', 'superadmin', '2020-11-13 14:36:22.194294', 14, 'Compra');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (288, 'CLIENTE Consumidor Final TOTALIVA 0.0 PERCEPCION 0.0 ESTADO  Venta Anulada  ', 'superadmin', '2020-11-13 14:36:38.055678', 14, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (289, 'CLIENTE Consumidor Final TOTALIVA 0.0 PERCEPCION 0.0 ESTADO  Venta Anulada  ', 'superadmin', '2020-11-13 14:36:46.659688', 14, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (290, 'CLIENTE Consumidor Final TOTALIVA 0.0 PERCEPCION 0.0 ESTADO  Venta Anulada  ', 'superadmin', '2020-11-13 14:36:58.497731', 14, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (291, 'CLIENTE Consumidor Final TOTALIVA 0.0 PERCEPCION 0.0 ESTADO  Venta Realizada  ', 'superadmin', '2020-11-13 14:37:06.28117', 14, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (292, 'CLIENTE Consumidor Final TOTALIVA 0.0 PERCEPCION 0.0 ESTADO  Venta Realizada  ', 'superadmin', '2020-11-13 14:37:13.593532', 14, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (293, 'CLIENTE Consumidor Final TOTALIVA 0.0 PERCEPCION 0.0 ESTADO  Venta Realizada  ', 'superadmin', '2020-11-13 14:41:21.222897', 14, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (294, 'CLIENTE Consumidor Final TOTALIVA 0.0 PERCEPCION 0.0 TOTALRENDER  $333.00 ESTADO  Venta Anulada  ', 'superadmin', '2020-11-13 14:45:09.181131', 14, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (295, 'CLIENTE Consumidor Final TOTALIVA 0.0 PERCEPCION 0.0 TOTALRENDER  $333.00 ESTADO  Venta Realizada  ', 'superadmin', '2020-11-13 14:45:27.06885', 14, 'Venta');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (296, 'CATEGORIA galletita MARCA rex MEDIDA 251.0 UNIDAD gramos PRECIO 25.0 STOCK 57 IVA 11.0 ESTADO  Desactivado DETALLE  ', 'superadmin', '2020-11-13 14:47:07.012722', 14, 'Productos');
INSERT INTO public.auditoria (id, message, username, created_on, operation_id, target) VALUES (297, 'CATEGORIA galletita MARCA rex MEDIDA 251.0 UNIDAD gramos PRECIO 25.0 STOCK 57 IVA 10.0 ESTADO  Desactivado DETALLE  ', 'superadmin', '2020-11-13 14:47:21.155648', 14, 'Productos');


--
-- TOC entry 3589 (class 0 OID 166824)
-- Dependencies: 217
-- Data for Name: categoria; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.categoria (id, categoria) VALUES (1, 'YERBA');
INSERT INTO public.categoria (id, categoria) VALUES (2, 'GASEOSA');
INSERT INTO public.categoria (id, categoria) VALUES (3, 'GALLETITA');
INSERT INTO public.categoria (id, categoria) VALUES (4, 'VINO');
INSERT INTO public.categoria (id, categoria) VALUES (5, 'CERVEZA');
INSERT INTO public.categoria (id, categoria) VALUES (6, 'CIGARRILLOS');
INSERT INTO public.categoria (id, categoria) VALUES (7, 'DULCES');
INSERT INTO public.categoria (id, categoria) VALUES (11, 'HARINA');


--
-- TOC entry 3614 (class 0 OID 199566)
-- Dependencies: 242
-- Data for Name: clientes; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado) VALUES (1, 'Consumidor Final', NULL, NULL, 1, 1, 1, true);
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado) VALUES (637, '27-10255123-6', 'Marcelo', 'Lobardys', 2, 2, 1, true);
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado) VALUES (2357, '253648741', 'virginia', 'rosas', 1, 1, 1, true);
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado) VALUES (2356, '3905508741', 'jorge', 'sdfgasdfg', 1, 1, 1, true);
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado) VALUES (4, '131618746', 'juan', 'perez', 1, 3, 1, true);


--
-- TOC entry 3591 (class 0 OID 174960)
-- Dependencies: 219
-- Data for Name: companiaTarjeta; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."companiaTarjeta" (id, compania) VALUES (1, 'Visa');
INSERT INTO public."companiaTarjeta" (id, compania) VALUES (2, 'Mastercard');
INSERT INTO public."companiaTarjeta" (id, compania) VALUES (135, 'Naranja');
INSERT INTO public."companiaTarjeta" (id, compania) VALUES (730, 'Maestro');


--
-- TOC entry 3622 (class 0 OID 208339)
-- Dependencies: 250
-- Data for Name: compras; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.compras (id, "Estado", total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion) VALUES (2, true, 104.5, 95, 9.5, '2020-11-05', 5, 1, NULL, 0);
INSERT INTO public.compras (id, "Estado", total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion) VALUES (3, true, 309, 300, 0, '2020-11-06', 5, 1, NULL, 3);
INSERT INTO public.compras (id, "Estado", total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion) VALUES (4, true, 198, 198, 0, '2020-11-08', 4, 1, NULL, 0);
INSERT INTO public.compras (id, "Estado", total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion) VALUES (5, true, 4950, 4950, 0, '2020-11-09', 4, 1, NULL, 0);
INSERT INTO public.compras (id, "Estado", total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion) VALUES (6, true, 198, 198, 0, '2020-11-09', 4, 1, NULL, 0);
INSERT INTO public.compras (id, "Estado", total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion) VALUES (7, true, 990, 990, 0, '2020-11-11', 6, 1, NULL, 0);
INSERT INTO public.compras (id, "Estado", total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion) VALUES (8, true, 25000, 25000, 0, '2020-11-11', 4, 1, NULL, 0);
INSERT INTO public.compras (id, "Estado", total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion) VALUES (9, true, 0, 0, 0, '2020-11-11', 4, 1, NULL, 0);
INSERT INTO public.compras (id, "Estado", total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion) VALUES (10, true, 0, 0, 0, '2020-11-11', 4, 1, NULL, 0);
INSERT INTO public.compras (id, "Estado", total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion) VALUES (11, true, 0, 0, 0, '2020-11-11', 4, 1, NULL, 0);
INSERT INTO public.compras (id, "Estado", total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion) VALUES (12, true, 0, 0, 0, '2020-11-11', 4, 1, NULL, 0);
INSERT INTO public.compras (id, "Estado", total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion) VALUES (13, true, 0, 0, 0, '2020-11-11', 4, 1, NULL, 0);
INSERT INTO public.compras (id, "Estado", total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion) VALUES (1, true, 217.8, 198, 19.8, '2020-11-04', 5, 1, NULL, 0);
INSERT INTO public.compras (id, "Estado", total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion) VALUES (14, false, 20000, 20000, 0, '2020-11-13', 4, 1, NULL, 0);


--
-- TOC entry 3616 (class 0 OID 200114)
-- Dependencies: 244
-- Data for Name: datosEmpresa; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."datosEmpresa" (id, compania, direccion, cuit, logo, "tipoClave_id") VALUES (1, 'Kiogestion', 'Avenida Roque Perez, 1522', '', '24a99ed4-1e9c-11eb-8bac-10c37b9bc0ef_sep_logo.jpg', 2);


--
-- TOC entry 3628 (class 0 OID 208398)
-- Dependencies: 256
-- Data for Name: datosFormaPagos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."datosFormaPagos" (id, "numeroCupon", credito, cuotas, "companiaTarjeta_id", formadepago_id) VALUES (1, '3243', false, 0, 730, 4);
INSERT INTO public."datosFormaPagos" (id, "numeroCupon", credito, cuotas, "companiaTarjeta_id", formadepago_id) VALUES (2, '4654654656', false, 0, 1, 7);


--
-- TOC entry 3620 (class 0 OID 208319)
-- Dependencies: 248
-- Data for Name: datosFormaPagosCompra; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3593 (class 0 OID 183168)
-- Dependencies: 221
-- Data for Name: formadepago; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.formadepago (id, "Metodo") VALUES (1, 'Contado');
INSERT INTO public.formadepago (id, "Metodo") VALUES (2, 'Tarjeta');


--
-- TOC entry 3587 (class 0 OID 101175)
-- Dependencies: 215
-- Data for Name: marcas; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.marcas (id, marca) VALUES (1, 'GUARANI');
INSERT INTO public.marcas (id, marca) VALUES (2, 'FANTA');
INSERT INTO public.marcas (id, marca) VALUES (3, 'ROMANCE');
INSERT INTO public.marcas (id, marca) VALUES (4, 'CAÑUELAS');
INSERT INTO public.marcas (id, marca) VALUES (5, 'COCA COLA');
INSERT INTO public.marcas (id, marca) VALUES (6, 'REX');
INSERT INTO public.marcas (id, marca) VALUES (7, 'SALADIX');
INSERT INTO public.marcas (id, marca) VALUES (8, 'SPRITE');
INSERT INTO public.marcas (id, marca) VALUES (9, 'HEIGTH');
INSERT INTO public.marcas (id, marca) VALUES (10, 'IMPERIAL');
INSERT INTO public.marcas (id, marca) VALUES (11, 'CORONA');
INSERT INTO public.marcas (id, marca) VALUES (12, 'MILLER');
INSERT INTO public.marcas (id, marca) VALUES (13, 'FAVORITAS');
INSERT INTO public.marcas (id, marca) VALUES (15, 'MALBORO');
INSERT INTO public.marcas (id, marca) VALUES (17, 'MALBEC');
INSERT INTO public.marcas (id, marca) VALUES (18, 'TERMIDOR');
INSERT INTO public.marcas (id, marca) VALUES (19, 'UVITA');
INSERT INTO public.marcas (id, marca) VALUES (20, 'COTTO');


--
-- TOC entry 3631 (class 0 OID 232881)
-- Dependencies: 259
-- Data for Name: operacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.operacion (id, name) VALUES (13, 'INSERT');
INSERT INTO public.operacion (id, name) VALUES (14, 'UPDATE');
INSERT INTO public.operacion (id, name) VALUES (15, 'DELETE');


--
-- TOC entry 3608 (class 0 OID 191841)
-- Dependencies: 236
-- Data for Name: productos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.productos (id, "Estado", precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (3, true, 60, 341, 22, 1, 5, 2, 1.5, '');
INSERT INTO public.productos (id, "Estado", precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (1, true, 150, 784, 11, 2, 1, 1, 500, '');
INSERT INTO public.productos (id, "Estado", precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (4, false, 25, 57, 10, 2, 6, 3, 251, '');
INSERT INTO public.productos (id, "Estado", precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (6, true, 50, 0, 351351, 1, 1, 1, 250, '-');
INSERT INTO public.productos (id, "Estado", precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (5, true, 35, 180, 21, 2, 7, 3, 250, '');


--
-- TOC entry 3612 (class 0 OID 199546)
-- Dependencies: 240
-- Data for Name: proveedor; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.proveedor (id, cuit, nombre, apellido, domicilio, correo, estado, "tipoClave_id", "idTipoPersona", ranking) VALUES (4, '20-41091788-3', 'enrique', 'sand', NULL, '', true, 3, 1, 0);
INSERT INTO public.proveedor (id, cuit, nombre, apellido, domicilio, correo, estado, "tipoClave_id", "idTipoPersona", ranking) VALUES (6, '30-99924708-9', 'barselo', 'ricargdino', NULL, '', true, 3, 1, 0);
INSERT INTO public.proveedor (id, cuit, nombre, apellido, domicilio, correo, estado, "tipoClave_id", "idTipoPersona", ranking) VALUES (5, '30-13453456-3', 'Cortencio', 'Retondo', NULL, 'flask@gmail.com', true, 2, 1, 0);
INSERT INTO public.proveedor (id, cuit, nombre, apellido, domicilio, correo, estado, "tipoClave_id", "idTipoPersona", ranking) VALUES (7, '27-11077410-4', 'Odulio', 'Cortencio', NULL, 'sagasgsadgsad@sad', true, 2, 1, 0);


--
-- TOC entry 3626 (class 0 OID 208380)
-- Dependencies: 254
-- Data for Name: renglon; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (1, 50, 2, 1, 4, 50);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (2, 50, 6, 1, 3, 50);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (3, 50, 2, 2, 4, 50);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (4, 60, 2, 2, 1, 60);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (5, 50, 2, 3, 4, 50);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (6, 50, 4, 3, 3, 50);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (7, 50, 2, 4, 4, 1);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (8, 50, 3, 4, 3, 1);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (9, 50, 2, 5, 4, 10);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (10, 50, 4, 5, 3, 1);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (11, 100, 5, 1, 1, NULL);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (12, 50, 2, 6, 5, 10);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (13, 60, 2, 7, 1, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (14, 50, 2, 7, 4, 3);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (15, 50, 10, 8, 5, 3);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (16, 50, 15, 8, 3, 3);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (17, 50, 20, 8, 4, 1.1);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (18, 50, 2, 9, 5, 2);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (19, 60, 2, 9, 1, 2);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (20, 50, 2, 10, 5, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (21, 50, 2, 11, 3, 1);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (22, 50, 2, 12, 5, 1);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (23, 60, 2, 13, 1, 2);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (24, 50, 2, 14, 3, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (25, 50, 2, 15, 4, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (26, 60, 2, 16, 1, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (27, 60, 2, 17, 1, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (28, 50, 2, 18, 3, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (29, 50, 2, 19, 3, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (30, 50, 2, 20, 3, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (31, 60, 1, 21, 1, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (32, 55, 2, 22, 5, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (33, 55, 2, 23, 5, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (34, 55, 2, 24, 5, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (35, 50, 1, 25, 3, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (36, 50, 1, 26, 3, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (37, 50, 1, 27, 3, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (38, 50, 1, 28, 3, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (39, 50, 1, 29, 3, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (40, 50, 1, 30, 3, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (41, 50, 1, 31, 3, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (42, 25, 2, 32, 4, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (43, 60, 2, 33, 3, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (44, 25, 2, 34, 4, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (45, 25, 2, 35, 4, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (46, 25, 2, 36, 4, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (47, 150, 2, 37, 1, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (48, 60, 2, 38, 3, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (49, 25, 2, 39, 4, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (50, 150, 2, 40, 1, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (51, 60, 2, 41, 3, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (52, 25, 2, 42, 4, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (53, 150, 2, 43, 1, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (54, 150, 1, 44, 1, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (55, 60, 2, 45, 3, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (56, 25, 5, 46, 4, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (57, 150, 2, 47, 1, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (58, 150, 2, 48, 1, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (59, 150, 2, 49, 1, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (60, 150, 2, 50, 1, 0);


--
-- TOC entry 3630 (class 0 OID 208418)
-- Dependencies: 258
-- Data for Name: renglon_compras; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento) VALUES (1, 100, 2, 1, 4, 1);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento) VALUES (2, 50, 2, 2, 4, 5);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento) VALUES (3, 150, 2, 3, 1, 0);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento) VALUES (4, 100, 2, 4, 1, 1);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento) VALUES (5, 50, 100, 5, 1, 1);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento) VALUES (6, 100, 2, 6, 4, 1);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento) VALUES (7, 10, 100, 7, 3, 1);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento) VALUES (8, 500, 50, 8, 1, 0);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento) VALUES (9, 0, 15, 9, 1, 0);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento) VALUES (10, 0, 15, 10, 1, 0);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento) VALUES (11, 0, 15, 11, 1, 0);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento) VALUES (12, 0, 15, 12, 1, 0);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento) VALUES (13, 0, 15, 13, 1, 0);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento) VALUES (14, 100, 200, 14, 3, 0);


--
-- TOC entry 3610 (class 0 OID 199536)
-- Dependencies: 238
-- Data for Name: tipoPersona; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."tipoPersona" ("idTipoPersona", "tipoPersona") VALUES (1, 'Fisica');
INSERT INTO public."tipoPersona" ("idTipoPersona", "tipoPersona") VALUES (2, 'Juridica');


--
-- TOC entry 3603 (class 0 OID 191344)
-- Dependencies: 231
-- Data for Name: tiposClave; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."tiposClave" (id, "tipoClave") VALUES (1, 'Consumidor Final');
INSERT INTO public."tiposClave" (id, "tipoClave") VALUES (2, 'Responsable Inscripto');
INSERT INTO public."tiposClave" (id, "tipoClave") VALUES (3, 'Monotributista');
INSERT INTO public."tiposClave" (id, "tipoClave") VALUES (4, 'Exento');


--
-- TOC entry 3605 (class 0 OID 191354)
-- Dependencies: 233
-- Data for Name: tiposDocumentos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."tiposDocumentos" (id, "tipoDocumento") VALUES (1, 'DNI');
INSERT INTO public."tiposDocumentos" (id, "tipoDocumento") VALUES (2, 'CUIT');


--
-- TOC entry 3585 (class 0 OID 101165)
-- Dependencies: 213
-- Data for Name: unidad_medida; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.unidad_medida (id, unidad) VALUES (1, 'LITRO');
INSERT INTO public.unidad_medida (id, unidad) VALUES (2, 'GRAMOS');
INSERT INTO public.unidad_medida (id, unidad) VALUES (3, 'KILO');
INSERT INTO public.unidad_medida (id, unidad) VALUES (4, 'MILILITRO');


--
-- TOC entry 3618 (class 0 OID 208306)
-- Dependencies: 246
-- Data for Name: ventas; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (3, true, '2020-11-04', 300, 32, 332, 637, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (4, true, '2020-11-04', 247.5, 0, 247.5, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (5, true, '2020-11-04', 288, 30.78, 318.78, 637, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (6, true, '2020-11-04', 90, 0, 90, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (7, true, '2020-11-06', 217, 0, 217, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (8, true, '2020-11-06', 2201.5, 0, 2201.5, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (9, true, '2020-11-08', 236.18, 48.42, 284.6, 637, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (1, false, '2020-11-04', 400, 400, 443, 637, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (10, true, '2020-11-09', 100, 0, 100, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (11, true, '2020-11-09', 99, 0, 99, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (12, false, '2020-11-11', 99, 0, 99, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (13, true, '2020-11-11', 117.6, 0, 117.6, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (14, false, '2020-11-11', 100, 0, 100, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (15, false, '2020-11-11', 100, 0, 100, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (16, true, '2020-11-11', 120, 0, 120, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (17, true, '2020-11-11', 120, 0, 120, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (18, true, '2020-11-11', 100, 0, 100, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (19, true, '2020-11-11', 100, 0, 100, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (20, true, '2020-11-11', 100, 0, 100, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (21, false, '2020-11-11', 72, 0, 72, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (22, true, '2020-11-11', 99.82, 0, 99.82, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (23, true, '2020-11-11', 99.82, 0, 99.82, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (24, true, '2020-11-11', 99.82, 0, 99.82, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (25, true, '2020-11-11', 61, 0, 61, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (26, true, '2020-11-11', 61, 0, 61, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (27, true, '2020-11-11', 61, 0, 61, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (28, true, '2020-11-11', 61, 0, 61, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (29, true, '2020-11-11', 61, 0, 61, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (30, true, '2020-11-11', 61, 0, 61, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (31, true, '2020-11-11', 61, 0, 61, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (32, true, '2020-11-13', 55.5, 0, 55.5, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (33, true, '2020-11-13', 146.4, 0, 146.4, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (34, true, '2020-11-13', 55.5, 0, 55.5, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (35, true, '2020-11-13', 55.5, 0, 55.5, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (36, true, '2020-11-13', 55.5, 0, 55.5, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (37, true, '2020-11-13', 333, 0, 333, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (38, true, '2020-11-13', 146.4, 0, 146.4, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (39, true, '2020-11-13', 55.5, 0, 55.5, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (40, true, '2020-11-13', 333, 0, 333, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (41, true, '2020-11-13', 146.4, 0, 146.4, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (42, true, '2020-11-13', 55.5, 0, 55.5, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (43, true, '2020-11-13', 333, 0, 333, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (44, true, '2020-11-13', 166.5, 0, 166.5, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (45, true, '2020-11-13', 146.4, 0, 146.4, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (46, true, '2020-11-13', 138.75, 0, 138.75, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (2, false, '2020-11-04', 220, 34, 254, 637, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (49, true, '2020-11-13', 333, 0, 333, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (48, true, '2020-11-13', 333, 0, 333, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (50, false, '2020-11-13', 333, 0, 333, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (47, true, '2020-11-13', 333, 0, 333, 1, 0);


--
-- TOC entry 3660 (class 0 OID 0)
-- Dependencies: 251
-- Name: FormadePago_Venta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."FormadePago_Venta_id_seq"', 52, true);


--
-- TOC entry 3661 (class 0 OID 0)
-- Dependencies: 204
-- Name: ab_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_permission_id_seq', 57, true);


--
-- TOC entry 3662 (class 0 OID 0)
-- Dependencies: 209
-- Name: ab_permission_view_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_permission_view_id_seq', 523, true);


--
-- TOC entry 3663 (class 0 OID 0)
-- Dependencies: 211
-- Name: ab_permission_view_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_permission_view_role_id_seq', 588, true);


--
-- TOC entry 3664 (class 0 OID 0)
-- Dependencies: 208
-- Name: ab_register_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_register_user_id_seq', 33, true);


--
-- TOC entry 3665 (class 0 OID 0)
-- Dependencies: 206
-- Name: ab_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_role_id_seq', 8, true);


--
-- TOC entry 3666 (class 0 OID 0)
-- Dependencies: 207
-- Name: ab_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_user_id_seq', 17, true);


--
-- TOC entry 3667 (class 0 OID 0)
-- Dependencies: 210
-- Name: ab_user_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_user_role_id_seq', 26, true);


--
-- TOC entry 3668 (class 0 OID 0)
-- Dependencies: 205
-- Name: ab_view_menu_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_view_menu_id_seq', 213, true);


--
-- TOC entry 3669 (class 0 OID 0)
-- Dependencies: 234
-- Name: audit_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.audit_log_id_seq', 297, true);


--
-- TOC entry 3670 (class 0 OID 0)
-- Dependencies: 216
-- Name: categoria_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categoria_id_seq', 11, true);


--
-- TOC entry 3671 (class 0 OID 0)
-- Dependencies: 241
-- Name: clientes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.clientes_id_seq', 3747, true);


--
-- TOC entry 3672 (class 0 OID 0)
-- Dependencies: 218
-- Name: companiaTarjeta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."companiaTarjeta_id_seq"', 3409, true);


--
-- TOC entry 3673 (class 0 OID 0)
-- Dependencies: 249
-- Name: compras_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.compras_id_seq', 14, true);


--
-- TOC entry 3674 (class 0 OID 0)
-- Dependencies: 243
-- Name: datosEmpresa_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."datosEmpresa_id_seq"', 817, true);


--
-- TOC entry 3675 (class 0 OID 0)
-- Dependencies: 247
-- Name: datosFormaPagosCompra_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."datosFormaPagosCompra_id_seq"', 1, false);


--
-- TOC entry 3676 (class 0 OID 0)
-- Dependencies: 255
-- Name: datosFormaPagos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."datosFormaPagos_id_seq"', 2, true);


--
-- TOC entry 3677 (class 0 OID 0)
-- Dependencies: 220
-- Name: formadepago_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.formadepago_id_seq', 3186, true);


--
-- TOC entry 3678 (class 0 OID 0)
-- Dependencies: 214
-- Name: marcas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.marcas_id_seq', 24, true);


--
-- TOC entry 3679 (class 0 OID 0)
-- Dependencies: 235
-- Name: productos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.productos_id_seq', 6, true);


--
-- TOC entry 3680 (class 0 OID 0)
-- Dependencies: 239
-- Name: proveedor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.proveedor_id_seq', 7, true);


--
-- TOC entry 3681 (class 0 OID 0)
-- Dependencies: 257
-- Name: renglon_compras_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.renglon_compras_id_seq', 14, true);


--
-- TOC entry 3682 (class 0 OID 0)
-- Dependencies: 253
-- Name: renglon_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.renglon_id_seq', 60, true);


--
-- TOC entry 3683 (class 0 OID 0)
-- Dependencies: 237
-- Name: tipoPersona_idTipoPersona_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."tipoPersona_idTipoPersona_seq"', 1906, true);


--
-- TOC entry 3684 (class 0 OID 0)
-- Dependencies: 230
-- Name: tiposClave_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."tiposClave_id_seq"', 5290, true);


--
-- TOC entry 3685 (class 0 OID 0)
-- Dependencies: 232
-- Name: tiposDocumentos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."tiposDocumentos_id_seq"', 2678, true);


--
-- TOC entry 3686 (class 0 OID 0)
-- Dependencies: 212
-- Name: unidad_medida_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.unidad_medida_id_seq', 4, true);


--
-- TOC entry 3687 (class 0 OID 0)
-- Dependencies: 245
-- Name: ventas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ventas_id_seq', 50, true);


--
-- TOC entry 3401 (class 2606 OID 208367)
-- Name: FormadePago_Venta FormadePago_Venta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FormadePago_Venta"
    ADD CONSTRAINT "FormadePago_Venta_pkey" PRIMARY KEY (id);


--
-- TOC entry 3323 (class 2606 OID 183305)
-- Name: ab_permission ab_permission_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission
    ADD CONSTRAINT ab_permission_name_key UNIQUE (name);


--
-- TOC entry 3325 (class 2606 OID 183303)
-- Name: ab_permission ab_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission
    ADD CONSTRAINT ab_permission_pkey PRIMARY KEY (id);


--
-- TOC entry 3347 (class 2606 OID 183360)
-- Name: ab_permission_view ab_permission_view_permission_id_view_menu_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_permission_id_view_menu_id_key UNIQUE (permission_id, view_menu_id);


--
-- TOC entry 3349 (class 2606 OID 183358)
-- Name: ab_permission_view ab_permission_view_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_pkey PRIMARY KEY (id);


--
-- TOC entry 3355 (class 2606 OID 183394)
-- Name: ab_permission_view_role ab_permission_view_role_permission_view_id_role_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_permission_view_id_role_id_key UNIQUE (permission_view_id, role_id);


--
-- TOC entry 3357 (class 2606 OID 183392)
-- Name: ab_permission_view_role ab_permission_view_role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_pkey PRIMARY KEY (id);


--
-- TOC entry 3343 (class 2606 OID 183351)
-- Name: ab_register_user ab_register_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_register_user
    ADD CONSTRAINT ab_register_user_pkey PRIMARY KEY (id);


--
-- TOC entry 3345 (class 2606 OID 183353)
-- Name: ab_register_user ab_register_user_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_register_user
    ADD CONSTRAINT ab_register_user_username_key UNIQUE (username);


--
-- TOC entry 3331 (class 2606 OID 183319)
-- Name: ab_role ab_role_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_role
    ADD CONSTRAINT ab_role_name_key UNIQUE (name);


--
-- TOC entry 3333 (class 2606 OID 183317)
-- Name: ab_role ab_role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_role
    ADD CONSTRAINT ab_role_pkey PRIMARY KEY (id);


--
-- TOC entry 3335 (class 2606 OID 183333)
-- Name: ab_user ab_user_cuil_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_cuil_key UNIQUE (cuil);


--
-- TOC entry 3337 (class 2606 OID 183331)
-- Name: ab_user ab_user_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_email_key UNIQUE (email);


--
-- TOC entry 3339 (class 2606 OID 183327)
-- Name: ab_user ab_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_pkey PRIMARY KEY (id);


--
-- TOC entry 3351 (class 2606 OID 183375)
-- Name: ab_user_role ab_user_role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_pkey PRIMARY KEY (id);


--
-- TOC entry 3353 (class 2606 OID 183377)
-- Name: ab_user_role ab_user_role_user_id_role_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_user_id_role_id_key UNIQUE (user_id, role_id);


--
-- TOC entry 3341 (class 2606 OID 183329)
-- Name: ab_user ab_user_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_username_key UNIQUE (username);


--
-- TOC entry 3327 (class 2606 OID 183312)
-- Name: ab_view_menu ab_view_menu_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_view_menu
    ADD CONSTRAINT ab_view_menu_name_key UNIQUE (name);


--
-- TOC entry 3329 (class 2606 OID 183310)
-- Name: ab_view_menu ab_view_menu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_view_menu
    ADD CONSTRAINT ab_view_menu_pkey PRIMARY KEY (id);


--
-- TOC entry 3413 (class 2606 OID 232893)
-- Name: auditoria auditoria_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria
    ADD CONSTRAINT auditoria_pkey PRIMARY KEY (id);


--
-- TOC entry 3311 (class 2606 OID 166831)
-- Name: categoria categoria_categoria_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_categoria_key UNIQUE (categoria);


--
-- TOC entry 3313 (class 2606 OID 166829)
-- Name: categoria categoria_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_pkey PRIMARY KEY (id);


--
-- TOC entry 3379 (class 2606 OID 199573)
-- Name: clientes clientes_documento_tipoDocumento_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT "clientes_documento_tipoDocumento_id_key" UNIQUE (documento, "tipoDocumento_id");


--
-- TOC entry 3381 (class 2606 OID 199571)
-- Name: clientes clientes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (id);


--
-- TOC entry 3315 (class 2606 OID 174967)
-- Name: companiaTarjeta companiaTarjeta_compania_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."companiaTarjeta"
    ADD CONSTRAINT "companiaTarjeta_compania_key" UNIQUE (compania);


--
-- TOC entry 3317 (class 2606 OID 174965)
-- Name: companiaTarjeta companiaTarjeta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."companiaTarjeta"
    ADD CONSTRAINT "companiaTarjeta_pkey" PRIMARY KEY (id);


--
-- TOC entry 3399 (class 2606 OID 208344)
-- Name: compras compras_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_pkey PRIMARY KEY (id);


--
-- TOC entry 3383 (class 2606 OID 200124)
-- Name: datosEmpresa datosEmpresa_compania_direccion_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_compania_direccion_key" UNIQUE (compania, direccion);


--
-- TOC entry 3385 (class 2606 OID 200126)
-- Name: datosEmpresa datosEmpresa_compania_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_compania_key" UNIQUE (compania);


--
-- TOC entry 3387 (class 2606 OID 200130)
-- Name: datosEmpresa datosEmpresa_cuit_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_cuit_key" UNIQUE (cuit);


--
-- TOC entry 3389 (class 2606 OID 200128)
-- Name: datosEmpresa datosEmpresa_direccion_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_direccion_key" UNIQUE (direccion);


--
-- TOC entry 3391 (class 2606 OID 200122)
-- Name: datosEmpresa datosEmpresa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_pkey" PRIMARY KEY (id);


--
-- TOC entry 3395 (class 2606 OID 208326)
-- Name: datosFormaPagosCompra datosFormaPagosCompra_numeroCupon_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagosCompra"
    ADD CONSTRAINT "datosFormaPagosCompra_numeroCupon_key" UNIQUE ("numeroCupon");


--
-- TOC entry 3397 (class 2606 OID 208324)
-- Name: datosFormaPagosCompra datosFormaPagosCompra_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagosCompra"
    ADD CONSTRAINT "datosFormaPagosCompra_pkey" PRIMARY KEY (id);


--
-- TOC entry 3405 (class 2606 OID 208405)
-- Name: datosFormaPagos datosFormaPagos_numeroCupon_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagos"
    ADD CONSTRAINT "datosFormaPagos_numeroCupon_key" UNIQUE ("numeroCupon");


--
-- TOC entry 3407 (class 2606 OID 208403)
-- Name: datosFormaPagos datosFormaPagos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagos"
    ADD CONSTRAINT "datosFormaPagos_pkey" PRIMARY KEY (id);


--
-- TOC entry 3319 (class 2606 OID 183175)
-- Name: formadepago formadepago_Metodo_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.formadepago
    ADD CONSTRAINT "formadepago_Metodo_key" UNIQUE ("Metodo");


--
-- TOC entry 3321 (class 2606 OID 183173)
-- Name: formadepago formadepago_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.formadepago
    ADD CONSTRAINT formadepago_pkey PRIMARY KEY (id);


--
-- TOC entry 3307 (class 2606 OID 101182)
-- Name: marcas marcas_marca_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marcas
    ADD CONSTRAINT marcas_marca_key UNIQUE (marca);


--
-- TOC entry 3309 (class 2606 OID 101180)
-- Name: marcas marcas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marcas
    ADD CONSTRAINT marcas_pkey PRIMARY KEY (id);


--
-- TOC entry 3411 (class 2606 OID 232885)
-- Name: operacion operacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.operacion
    ADD CONSTRAINT operacion_pkey PRIMARY KEY (id);


--
-- TOC entry 3367 (class 2606 OID 191848)
-- Name: productos productos_categoria_id_marcas_id_unidad_id_medida_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_categoria_id_marcas_id_unidad_id_medida_key UNIQUE (categoria_id, marcas_id, unidad_id, medida);


--
-- TOC entry 3369 (class 2606 OID 191846)
-- Name: productos productos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_pkey PRIMARY KEY (id);


--
-- TOC entry 3375 (class 2606 OID 199553)
-- Name: proveedor proveedor_cuit_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT proveedor_cuit_key UNIQUE (cuit);


--
-- TOC entry 3377 (class 2606 OID 199551)
-- Name: proveedor proveedor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT proveedor_pkey PRIMARY KEY (id);


--
-- TOC entry 3409 (class 2606 OID 208423)
-- Name: renglon_compras renglon_compras_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_compras
    ADD CONSTRAINT renglon_compras_pkey PRIMARY KEY (id);


--
-- TOC entry 3403 (class 2606 OID 208385)
-- Name: renglon renglon_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon
    ADD CONSTRAINT renglon_pkey PRIMARY KEY (id);


--
-- TOC entry 3371 (class 2606 OID 199541)
-- Name: tipoPersona tipoPersona_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tipoPersona"
    ADD CONSTRAINT "tipoPersona_pkey" PRIMARY KEY ("idTipoPersona");


--
-- TOC entry 3373 (class 2606 OID 199543)
-- Name: tipoPersona tipoPersona_tipoPersona_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tipoPersona"
    ADD CONSTRAINT "tipoPersona_tipoPersona_key" UNIQUE ("tipoPersona");


--
-- TOC entry 3359 (class 2606 OID 191349)
-- Name: tiposClave tiposClave_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tiposClave"
    ADD CONSTRAINT "tiposClave_pkey" PRIMARY KEY (id);


--
-- TOC entry 3361 (class 2606 OID 191351)
-- Name: tiposClave tiposClave_tipoClave_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tiposClave"
    ADD CONSTRAINT "tiposClave_tipoClave_key" UNIQUE ("tipoClave");


--
-- TOC entry 3363 (class 2606 OID 191359)
-- Name: tiposDocumentos tiposDocumentos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tiposDocumentos"
    ADD CONSTRAINT "tiposDocumentos_pkey" PRIMARY KEY (id);


--
-- TOC entry 3365 (class 2606 OID 191361)
-- Name: tiposDocumentos tiposDocumentos_tipoDocumento_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tiposDocumentos"
    ADD CONSTRAINT "tiposDocumentos_tipoDocumento_key" UNIQUE ("tipoDocumento");


--
-- TOC entry 3303 (class 2606 OID 101170)
-- Name: unidad_medida unidad_medida_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unidad_medida
    ADD CONSTRAINT unidad_medida_pkey PRIMARY KEY (id);


--
-- TOC entry 3305 (class 2606 OID 101172)
-- Name: unidad_medida unidad_medida_unidad_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unidad_medida
    ADD CONSTRAINT unidad_medida_unidad_key UNIQUE (unidad);


--
-- TOC entry 3393 (class 2606 OID 208311)
-- Name: ventas ventas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_pkey PRIMARY KEY (id);


--
-- TOC entry 3449 (class 2620 OID 208437)
-- Name: renglon_compras updateproductoscompra; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER updateproductoscompra AFTER INSERT ON public.renglon_compras FOR EACH ROW EXECUTE FUNCTION public.sumarstockencompra();


--
-- TOC entry 3447 (class 2620 OID 208441)
-- Name: compras updateproductoscompranulada; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER updateproductoscompranulada AFTER UPDATE ON public.compras FOR EACH ROW EXECUTE FUNCTION public.actualiarstockencompranulada();


--
-- TOC entry 3448 (class 2620 OID 208435)
-- Name: renglon updateproductosventa; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER updateproductosventa AFTER INSERT ON public.renglon FOR EACH ROW EXECUTE FUNCTION public.descontarstockenventa();


--
-- TOC entry 3446 (class 2620 OID 208439)
-- Name: ventas updateproductosventanulada; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER updateproductosventanulada AFTER UPDATE ON public.ventas FOR EACH ROW EXECUTE FUNCTION public.sumarstockenventanulada();


--
-- TOC entry 3438 (class 2606 OID 208373)
-- Name: FormadePago_Venta FormadePago_Venta_formadepago_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FormadePago_Venta"
    ADD CONSTRAINT "FormadePago_Venta_formadepago_id_fkey" FOREIGN KEY (formadepago_id) REFERENCES public.formadepago(id);


--
-- TOC entry 3437 (class 2606 OID 208368)
-- Name: FormadePago_Venta FormadePago_Venta_venta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FormadePago_Venta"
    ADD CONSTRAINT "FormadePago_Venta_venta_id_fkey" FOREIGN KEY (venta_id) REFERENCES public.ventas(id);


--
-- TOC entry 3416 (class 2606 OID 183361)
-- Name: ab_permission_view ab_permission_view_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.ab_permission(id);


--
-- TOC entry 3420 (class 2606 OID 183395)
-- Name: ab_permission_view_role ab_permission_view_role_permission_view_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_permission_view_id_fkey FOREIGN KEY (permission_view_id) REFERENCES public.ab_permission_view(id);


--
-- TOC entry 3421 (class 2606 OID 183400)
-- Name: ab_permission_view_role ab_permission_view_role_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.ab_role(id);


--
-- TOC entry 3417 (class 2606 OID 183366)
-- Name: ab_permission_view ab_permission_view_view_menu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_view_menu_id_fkey FOREIGN KEY (view_menu_id) REFERENCES public.ab_view_menu(id);


--
-- TOC entry 3415 (class 2606 OID 183339)
-- Name: ab_user ab_user_changed_by_fk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_changed_by_fk_fkey FOREIGN KEY (changed_by_fk) REFERENCES public.ab_user(id);


--
-- TOC entry 3414 (class 2606 OID 183334)
-- Name: ab_user ab_user_created_by_fk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_created_by_fk_fkey FOREIGN KEY (created_by_fk) REFERENCES public.ab_user(id);


--
-- TOC entry 3419 (class 2606 OID 183383)
-- Name: ab_user_role ab_user_role_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.ab_role(id);


--
-- TOC entry 3418 (class 2606 OID 183378)
-- Name: ab_user_role ab_user_role_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.ab_user(id);


--
-- TOC entry 3445 (class 2606 OID 232894)
-- Name: auditoria auditoria_operation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria
    ADD CONSTRAINT auditoria_operation_id_fkey FOREIGN KEY (operation_id) REFERENCES public.operacion(id);


--
-- TOC entry 3429 (class 2606 OID 199584)
-- Name: clientes clientes_idTipoPersona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT "clientes_idTipoPersona_fkey" FOREIGN KEY ("idTipoPersona") REFERENCES public."tipoPersona"("idTipoPersona");


--
-- TOC entry 3428 (class 2606 OID 199579)
-- Name: clientes clientes_tipoClave_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT "clientes_tipoClave_id_fkey" FOREIGN KEY ("tipoClave_id") REFERENCES public."tiposClave"(id);


--
-- TOC entry 3427 (class 2606 OID 199574)
-- Name: clientes clientes_tipoDocumento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT "clientes_tipoDocumento_id_fkey" FOREIGN KEY ("tipoDocumento_id") REFERENCES public."tiposDocumentos"(id);


--
-- TOC entry 3436 (class 2606 OID 208355)
-- Name: compras compras_datosFormaPagos_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT "compras_datosFormaPagos_id_fkey" FOREIGN KEY ("datosFormaPagos_id") REFERENCES public."datosFormaPagosCompra"(id);


--
-- TOC entry 3435 (class 2606 OID 208350)
-- Name: compras compras_formadepago_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_formadepago_id_fkey FOREIGN KEY (formadepago_id) REFERENCES public.formadepago(id);


--
-- TOC entry 3434 (class 2606 OID 208345)
-- Name: compras compras_proveedor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_proveedor_id_fkey FOREIGN KEY (proveedor_id) REFERENCES public.proveedor(id);


--
-- TOC entry 3430 (class 2606 OID 200131)
-- Name: datosEmpresa datosEmpresa_tipoClave_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_tipoClave_id_fkey" FOREIGN KEY ("tipoClave_id") REFERENCES public."tiposClave"(id);


--
-- TOC entry 3432 (class 2606 OID 208327)
-- Name: datosFormaPagosCompra datosFormaPagosCompra_companiaTarjeta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagosCompra"
    ADD CONSTRAINT "datosFormaPagosCompra_companiaTarjeta_id_fkey" FOREIGN KEY ("companiaTarjeta_id") REFERENCES public."companiaTarjeta"(id);


--
-- TOC entry 3433 (class 2606 OID 208332)
-- Name: datosFormaPagosCompra datosFormaPagosCompra_formadepago_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagosCompra"
    ADD CONSTRAINT "datosFormaPagosCompra_formadepago_id_fkey" FOREIGN KEY (formadepago_id) REFERENCES public.formadepago(id);


--
-- TOC entry 3441 (class 2606 OID 208406)
-- Name: datosFormaPagos datosFormaPagos_companiaTarjeta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagos"
    ADD CONSTRAINT "datosFormaPagos_companiaTarjeta_id_fkey" FOREIGN KEY ("companiaTarjeta_id") REFERENCES public."companiaTarjeta"(id);


--
-- TOC entry 3442 (class 2606 OID 208411)
-- Name: datosFormaPagos datosFormaPagos_formadepago_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagos"
    ADD CONSTRAINT "datosFormaPagos_formadepago_id_fkey" FOREIGN KEY (formadepago_id) REFERENCES public."FormadePago_Venta"(id);


--
-- TOC entry 3424 (class 2606 OID 191859)
-- Name: productos productos_categoria_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_categoria_id_fkey FOREIGN KEY (categoria_id) REFERENCES public.categoria(id);


--
-- TOC entry 3423 (class 2606 OID 191854)
-- Name: productos productos_marcas_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_marcas_id_fkey FOREIGN KEY (marcas_id) REFERENCES public.marcas(id);


--
-- TOC entry 3422 (class 2606 OID 191849)
-- Name: productos productos_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad_medida(id);


--
-- TOC entry 3426 (class 2606 OID 199559)
-- Name: proveedor proveedor_idTipoPersona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT "proveedor_idTipoPersona_fkey" FOREIGN KEY ("idTipoPersona") REFERENCES public."tipoPersona"("idTipoPersona");


--
-- TOC entry 3425 (class 2606 OID 199554)
-- Name: proveedor proveedor_tipoClave_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT "proveedor_tipoClave_id_fkey" FOREIGN KEY ("tipoClave_id") REFERENCES public."tiposClave"(id);


--
-- TOC entry 3443 (class 2606 OID 208424)
-- Name: renglon_compras renglon_compras_compra_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_compras
    ADD CONSTRAINT renglon_compras_compra_id_fkey FOREIGN KEY (compra_id) REFERENCES public.compras(id);


--
-- TOC entry 3444 (class 2606 OID 208429)
-- Name: renglon_compras renglon_compras_producto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_compras
    ADD CONSTRAINT renglon_compras_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES public.productos(id);


--
-- TOC entry 3440 (class 2606 OID 208391)
-- Name: renglon renglon_producto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon
    ADD CONSTRAINT renglon_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES public.productos(id);


--
-- TOC entry 3439 (class 2606 OID 208386)
-- Name: renglon renglon_venta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon
    ADD CONSTRAINT renglon_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES public.ventas(id);


--
-- TOC entry 3431 (class 2606 OID 208312)
-- Name: ventas ventas_cliente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id);


-- Completed on 2020-11-13 21:20:53

--
-- PostgreSQL database dump complete
--

