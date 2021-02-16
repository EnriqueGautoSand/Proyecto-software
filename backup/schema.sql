--
-- PostgreSQL database dump
--

-- Dumped from database version 12.3
-- Dumped by pg_dump version 12.3

-- Started on 2021-02-10 23:36:26

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
-- TOC entry 3670 (class 1262 OID 20157)
-- Name: almacen; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE almacen WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'English_United States.1252' LC_CTYPE = 'English_United States.1252';


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
-- TOC entry 3 (class 3079 OID 20166)
-- Name: btree_gin; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA public;


--
-- TOC entry 3671 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION btree_gin; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION btree_gin IS 'support for indexing common datatypes in GIN';


--
-- TOC entry 2 (class 3079 OID 20602)
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- TOC entry 3672 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- TOC entry 991 (class 1247 OID 21226)
-- Name: companiatarjeta; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.companiatarjeta AS ENUM (
    'visa',
    'mastercard',
    'naranja'
);


ALTER TYPE public.companiatarjeta OWNER TO postgres;

--
-- TOC entry 994 (class 1247 OID 21234)
-- Name: metodospagos; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.metodospagos AS ENUM (
    'tarjeta',
    'contado'
);


ALTER TYPE public.metodospagos OWNER TO postgres;

--
-- TOC entry 997 (class 1247 OID 21240)
-- Name: tipoclaves; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.tipoclaves AS ENUM (
    'consumidorFinal',
    'responsableInscripto',
    'monotributista'
);


ALTER TYPE public.tipoclaves OWNER TO postgres;

--
-- TOC entry 1000 (class 1247 OID 21248)
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
-- TOC entry 564 (class 1255 OID 105211)
-- Name: actualiarstockencompranulada(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actualiarstockencompranulada() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
if new."estado" != old."estado" then
	if not new."estado" then
	update productos  set stock=stock-renglon_compras.cantidad from  
	 renglon_compras where renglon_compras.compra_id=new.id  and productos.id =renglon_compras.producto_id;

	end if;
end if;
return new;

end
$$;


ALTER FUNCTION public.actualiarstockencompranulada() OWNER TO postgres;

--
-- TOC entry 555 (class 1255 OID 21268)
-- Name: audit_table(regclass); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.audit_table(target_table regclass) RETURNS void
    LANGUAGE sql
    AS $$
SELECT audit_table(target_table, ARRAY[]::text[]);
$$;


ALTER FUNCTION public.audit_table(target_table regclass) OWNER TO postgres;

--
-- TOC entry 556 (class 1255 OID 21269)
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
-- TOC entry 557 (class 1255 OID 21270)
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
-- TOC entry 561 (class 1255 OID 105205)
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
-- TOC entry 558 (class 1255 OID 21272)
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
-- TOC entry 559 (class 1255 OID 21273)
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
-- TOC entry 560 (class 1255 OID 21274)
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
-- TOC entry 562 (class 1255 OID 105207)
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
-- TOC entry 563 (class 1255 OID 105209)
-- Name: sumarstockenventanulada(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sumarstockenventanulada() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
if new."estado" != old."estado" then
	if not new."estado" then
	update productos  set stock=stock+renglon.cantidad from  
	 renglon where renglon.venta_id=new.id  and productos.id =renglon.producto_id;
	end if;
end if;
return new;

end
$$;


ALTER FUNCTION public.sumarstockenventanulada() OWNER TO postgres;

--
-- TOC entry 1931 (class 2617 OID 21277)
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
-- TOC entry 204 (class 1259 OID 21283)
-- Name: ab_permission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_permission (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.ab_permission OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 21286)
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
-- TOC entry 206 (class 1259 OID 21288)
-- Name: ab_permission_view; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_permission_view (
    id integer NOT NULL,
    permission_id integer,
    view_menu_id integer
);


ALTER TABLE public.ab_permission_view OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 21291)
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
-- TOC entry 208 (class 1259 OID 21293)
-- Name: ab_permission_view_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_permission_view_role (
    id integer NOT NULL,
    permission_view_id integer,
    role_id integer
);


ALTER TABLE public.ab_permission_view_role OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 21296)
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
-- TOC entry 210 (class 1259 OID 21298)
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
-- TOC entry 211 (class 1259 OID 21304)
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
-- TOC entry 212 (class 1259 OID 21306)
-- Name: ab_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_role (
    id integer NOT NULL,
    name character varying(64) NOT NULL
);


ALTER TABLE public.ab_role OWNER TO postgres;

--
-- TOC entry 213 (class 1259 OID 21309)
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
-- TOC entry 214 (class 1259 OID 21311)
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
-- TOC entry 215 (class 1259 OID 21317)
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
-- TOC entry 216 (class 1259 OID 21319)
-- Name: ab_user_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_user_role (
    id integer NOT NULL,
    user_id integer,
    role_id integer
);


ALTER TABLE public.ab_user_role OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 21322)
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
-- TOC entry 218 (class 1259 OID 21324)
-- Name: ab_view_menu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_view_menu (
    id integer NOT NULL,
    name character varying(250) NOT NULL
);


ALTER TABLE public.ab_view_menu OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 21327)
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
-- TOC entry 220 (class 1259 OID 21329)
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
-- TOC entry 268 (class 1259 OID 105104)
-- Name: auditoria; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auditoria (
    id integer NOT NULL,
    message character varying(500) NOT NULL,
    username character varying(64) NOT NULL,
    anterior character varying(500) NOT NULL,
    created_on timestamp without time zone,
    operation_id integer NOT NULL,
    target character varying(150) NOT NULL
);


ALTER TABLE public.auditoria OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 21337)
-- Name: categoria; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categoria (
    id integer NOT NULL,
    categoria character varying(50) NOT NULL
);


ALTER TABLE public.categoria OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 21340)
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
-- TOC entry 3673 (class 0 OID 0)
-- Dependencies: 222
-- Name: categoria_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categoria_id_seq OWNED BY public.categoria.id;


--
-- TOC entry 223 (class 1259 OID 21342)
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
    estado boolean,
    direccion character varying(100),
    idlocalidad integer,
    telefono_celular character varying(30)
);


ALTER TABLE public.clientes OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 21345)
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
-- TOC entry 3674 (class 0 OID 0)
-- Dependencies: 224
-- Name: clientes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.clientes_id_seq OWNED BY public.clientes.id;


--
-- TOC entry 243 (class 1259 OID 22146)
-- Name: companiaTarjeta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."companiaTarjeta" (
    id integer NOT NULL,
    compania character varying(50),
    estado boolean
);


ALTER TABLE public."companiaTarjeta" OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 22144)
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
-- TOC entry 3675 (class 0 OID 0)
-- Dependencies: 242
-- Name: companiaTarjeta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."companiaTarjeta_id_seq" OWNED BY public."companiaTarjeta".id;


--
-- TOC entry 274 (class 1259 OID 105157)
-- Name: compras; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras (
    id integer NOT NULL,
    estado boolean,
    total double precision NOT NULL,
    "totalNeto" double precision NOT NULL,
    totaliva double precision,
    fecha date NOT NULL,
    proveedor_id integer NOT NULL,
    formadepago_id integer NOT NULL,
    "datosFormaPagos_id" integer,
    percepcion double precision,
    comprobante integer
);


ALTER TABLE public.compras OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 105101)
-- Name: compras_comprobante_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.compras_comprobante_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.compras_comprobante_seq OWNER TO postgres;

--
-- TOC entry 273 (class 1259 OID 105155)
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
-- TOC entry 3676 (class 0 OID 0)
-- Dependencies: 273
-- Name: compras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.compras_id_seq OWNED BY public.compras.id;


--
-- TOC entry 249 (class 1259 OID 104570)
-- Name: datosEmpresa; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."datosEmpresa" (
    id integer NOT NULL,
    compania character varying(50),
    direccion character varying(255),
    cuit character varying(30),
    logo text,
    "tipoClave_id" integer NOT NULL,
    idlocalidad integer
);


ALTER TABLE public."datosEmpresa" OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 104568)
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
-- TOC entry 3677 (class 0 OID 0)
-- Dependencies: 248
-- Name: datosEmpresa_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."datosEmpresa_id_seq" OWNED BY public."datosEmpresa".id;


--
-- TOC entry 264 (class 1259 OID 105036)
-- Name: datosFormaPagos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."datosFormaPagos" (
    id integer NOT NULL,
    "numeroCupon" bigint NOT NULL,
    credito boolean,
    cuotas integer,
    "companiaTarjeta_id" integer NOT NULL,
    formadepago_id integer NOT NULL
);


ALTER TABLE public."datosFormaPagos" OWNER TO postgres;

--
-- TOC entry 270 (class 1259 OID 105119)
-- Name: datosFormaPagosCompra; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."datosFormaPagosCompra" (
    id integer NOT NULL,
    "numeroCupon" bigint NOT NULL,
    credito boolean,
    cuotas integer,
    "companiaTarjeta_id" integer NOT NULL,
    formadepago_id integer NOT NULL
);


ALTER TABLE public."datosFormaPagosCompra" OWNER TO postgres;

--
-- TOC entry 269 (class 1259 OID 105117)
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
-- TOC entry 3678 (class 0 OID 0)
-- Dependencies: 269
-- Name: datosFormaPagosCompra_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."datosFormaPagosCompra_id_seq" OWNED BY public."datosFormaPagosCompra".id;


--
-- TOC entry 263 (class 1259 OID 105034)
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
-- TOC entry 3679 (class 0 OID 0)
-- Dependencies: 263
-- Name: datosFormaPagos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."datosFormaPagos_id_seq" OWNED BY public."datosFormaPagos".id;


--
-- TOC entry 260 (class 1259 OID 104982)
-- Name: forma_pago_venta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.forma_pago_venta (
    id integer NOT NULL,
    monto double precision NOT NULL,
    venta_id integer NOT NULL,
    formadepago_id integer NOT NULL
);


ALTER TABLE public.forma_pago_venta OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 104980)
-- Name: forma_pago_venta_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.forma_pago_venta_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.forma_pago_venta_id_seq OWNER TO postgres;

--
-- TOC entry 3680 (class 0 OID 0)
-- Dependencies: 259
-- Name: forma_pago_venta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.forma_pago_venta_id_seq OWNED BY public.forma_pago_venta.id;


--
-- TOC entry 225 (class 1259 OID 21377)
-- Name: formadepago; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.formadepago (
    id integer NOT NULL,
    "Metodo" character varying(50)
);


ALTER TABLE public.formadepago OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 21380)
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
-- TOC entry 3681 (class 0 OID 0)
-- Dependencies: 226
-- Name: formadepago_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.formadepago_id_seq OWNED BY public.formadepago.id;


--
-- TOC entry 227 (class 1259 OID 21382)
-- Name: localidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.localidad (
    idlocalidad integer NOT NULL,
    localidad character varying(55) NOT NULL
);


ALTER TABLE public.localidad OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 21385)
-- Name: localidad_idLocalidad_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."localidad_idLocalidad_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."localidad_idLocalidad_seq" OWNER TO postgres;

--
-- TOC entry 3682 (class 0 OID 0)
-- Dependencies: 228
-- Name: localidad_idLocalidad_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."localidad_idLocalidad_seq" OWNED BY public.localidad.idlocalidad;


--
-- TOC entry 229 (class 1259 OID 21387)
-- Name: marcas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.marcas (
    id integer NOT NULL,
    marca character varying(50) NOT NULL
);


ALTER TABLE public.marcas OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 21390)
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
-- TOC entry 3683 (class 0 OID 0)
-- Dependencies: 230
-- Name: marcas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.marcas_id_seq OWNED BY public.marcas.id;


--
-- TOC entry 245 (class 1259 OID 38701)
-- Name: modulos_configuracion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.modulos_configuracion (
    id integer NOT NULL,
    modulo_pedido boolean,
    dias_pedido integer,
    dias_atras integer,
    porcentaje_ventas double precision,
    fecha_vencimiento integer,
    modulo_ofertas_whatsapp boolean,
    dias_oferta integer,
    fecha_vencimiento_oferta integer,
    porcentaje_subida_precio integer,
    twilio_account_sid character varying(50),
    twilio_auth_token character varying(50),
    descuento double precision
);


ALTER TABLE public.modulos_configuracion OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 38699)
-- Name: modulos_configuracion_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.modulos_configuracion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.modulos_configuracion_id_seq OWNER TO postgres;

--
-- TOC entry 3684 (class 0 OID 0)
-- Dependencies: 244
-- Name: modulos_configuracion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.modulos_configuracion_id_seq OWNED BY public.modulos_configuracion.id;


--
-- TOC entry 266 (class 1259 OID 105079)
-- Name: oferta_whatsapp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.oferta_whatsapp (
    id integer NOT NULL,
    fecha timestamp without time zone NOT NULL,
    expiracion timestamp without time zone NOT NULL,
    producto_id integer NOT NULL,
    cliente_id integer NOT NULL,
    descuento double precision NOT NULL,
    cantidad integer NOT NULL,
    "totalNeto" double precision NOT NULL,
    totaliva double precision NOT NULL,
    percepcion double precision NOT NULL,
    percepcion_porcentaje double precision NOT NULL,
    hash_activacion character varying(255) NOT NULL,
    reservado boolean NOT NULL,
    vendido boolean NOT NULL,
    renglon_compra_id integer NOT NULL,
    cancelado boolean
);


ALTER TABLE public.oferta_whatsapp OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 105077)
-- Name: oferta_whatsapp_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.oferta_whatsapp_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.oferta_whatsapp_id_seq OWNER TO postgres;

--
-- TOC entry 3685 (class 0 OID 0)
-- Dependencies: 265
-- Name: oferta_whatsapp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.oferta_whatsapp_id_seq OWNED BY public.oferta_whatsapp.id;


--
-- TOC entry 231 (class 1259 OID 21397)
-- Name: operacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.operacion (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.operacion OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 104917)
-- Name: pedido_cliente; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pedido_cliente (
    id integer NOT NULL,
    fecha timestamp without time zone NOT NULL,
    expiracion timestamp without time zone NOT NULL,
    vendido boolean NOT NULL,
    hash_activacion character varying(255) NOT NULL,
    cliente_id integer NOT NULL,
    reservado boolean NOT NULL,
    venta_id integer,
    cancelado boolean
);


ALTER TABLE public.pedido_cliente OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 104915)
-- Name: pedido_cliente_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pedido_cliente_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pedido_cliente_id_seq OWNER TO postgres;

--
-- TOC entry 3686 (class 0 OID 0)
-- Dependencies: 255
-- Name: pedido_cliente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pedido_cliente_id_seq OWNED BY public.pedido_cliente.id;


--
-- TOC entry 252 (class 1259 OID 104869)
-- Name: pedido_proveedor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pedido_proveedor (
    id integer NOT NULL,
    fecha timestamp without time zone,
    proveedor_id integer NOT NULL
);


ALTER TABLE public.pedido_proveedor OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 104867)
-- Name: pedido_proveedor_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pedido_proveedor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pedido_proveedor_id_seq OWNER TO postgres;

--
-- TOC entry 3687 (class 0 OID 0)
-- Dependencies: 251
-- Name: pedido_proveedor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pedido_proveedor_id_seq OWNED BY public.pedido_proveedor.id;


--
-- TOC entry 247 (class 1259 OID 38876)
-- Name: productos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.productos (
    id integer NOT NULL,
    estado boolean,
    precio double precision,
    stock integer,
    iva double precision NOT NULL,
    unidad_id integer NOT NULL,
    marcas_id integer NOT NULL,
    categoria_id integer NOT NULL,
    medida double precision,
    detalle character varying(255)
);


ALTER TABLE public.productos OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 38874)
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
-- TOC entry 3688 (class 0 OID 0)
-- Dependencies: 246
-- Name: productos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.productos_id_seq OWNED BY public.productos.id;


--
-- TOC entry 232 (class 1259 OID 21405)
-- Name: proveedor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.proveedor (
    id integer NOT NULL,
    cuit character varying(30) NOT NULL,
    nombre character varying(30) NOT NULL,
    apellido character varying(30) NOT NULL,
    domicilio character varying(255),
    estado boolean,
    "tipoClave_id" integer NOT NULL,
    "idTipoPersona" integer NOT NULL,
    ranking integer,
    idlocalidad integer,
    direccion character varying(100),
    telefono_celular character varying(30),
    correo character varying(100)
);


ALTER TABLE public.proveedor OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 21411)
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
-- TOC entry 3689 (class 0 OID 0)
-- Dependencies: 233
-- Name: proveedor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.proveedor_id_seq OWNED BY public.proveedor.id;


--
-- TOC entry 272 (class 1259 OID 105139)
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
-- TOC entry 276 (class 1259 OID 105184)
-- Name: renglon_compras; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.renglon_compras (
    id integer NOT NULL,
    "precioCompra" double precision,
    cantidad integer,
    compra_id integer NOT NULL,
    producto_id integer NOT NULL,
    descuento double precision,
    fecha_vencimiento date,
    vendido boolean NOT NULL,
    stock_lote integer NOT NULL,
    "renglonPedidoWhatsapp_id" integer
);


ALTER TABLE public.renglon_compras OWNER TO postgres;

--
-- TOC entry 275 (class 1259 OID 105182)
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
-- TOC entry 3690 (class 0 OID 0)
-- Dependencies: 275
-- Name: renglon_compras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.renglon_compras_id_seq OWNED BY public.renglon_compras.id;


--
-- TOC entry 271 (class 1259 OID 105137)
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
-- TOC entry 3691 (class 0 OID 0)
-- Dependencies: 271
-- Name: renglon_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.renglon_id_seq OWNED BY public.renglon.id;


--
-- TOC entry 258 (class 1259 OID 104937)
-- Name: renglon_pedido; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.renglon_pedido (
    id integer NOT NULL,
    cantidad integer,
    pedido_proveedor_id integer NOT NULL,
    producto_id integer NOT NULL
);


ALTER TABLE public.renglon_pedido OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 104935)
-- Name: renglon_pedido_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.renglon_pedido_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.renglon_pedido_id_seq OWNER TO postgres;

--
-- TOC entry 3692 (class 0 OID 0)
-- Dependencies: 257
-- Name: renglon_pedido_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.renglon_pedido_id_seq OWNED BY public.renglon_pedido.id;


--
-- TOC entry 262 (class 1259 OID 105018)
-- Name: renglon_pedido_whatsapp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.renglon_pedido_whatsapp (
    id integer NOT NULL,
    "precioVenta" double precision,
    cantidad integer,
    pedidocliente_id integer NOT NULL,
    producto_id integer NOT NULL,
    descuento double precision
);


ALTER TABLE public.renglon_pedido_whatsapp OWNER TO postgres;

--
-- TOC entry 261 (class 1259 OID 105016)
-- Name: renglon_pedido_whatsapp_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.renglon_pedido_whatsapp_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.renglon_pedido_whatsapp_id_seq OWNER TO postgres;

--
-- TOC entry 3693 (class 0 OID 0)
-- Dependencies: 261
-- Name: renglon_pedido_whatsapp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.renglon_pedido_whatsapp_id_seq OWNED BY public.renglon_pedido_whatsapp.id;


--
-- TOC entry 239 (class 1259 OID 21855)
-- Name: tipoPersona; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."tipoPersona" (
    "idTipoPersona" integer NOT NULL,
    "tipoPersona" character varying(30) NOT NULL
);


ALTER TABLE public."tipoPersona" OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 21853)
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
-- TOC entry 3694 (class 0 OID 0)
-- Dependencies: 238
-- Name: tipoPersona_idTipoPersona_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."tipoPersona_idTipoPersona_seq" OWNED BY public."tipoPersona"."idTipoPersona";


--
-- TOC entry 241 (class 1259 OID 21865)
-- Name: tiposClave; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."tiposClave" (
    id integer NOT NULL,
    "tipoClave" character varying(30) NOT NULL
);


ALTER TABLE public."tiposClave" OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 21863)
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
-- TOC entry 3695 (class 0 OID 0)
-- Dependencies: 240
-- Name: tiposClave_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."tiposClave_id_seq" OWNED BY public."tiposClave".id;


--
-- TOC entry 234 (class 1259 OID 21436)
-- Name: tiposDocumentos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."tiposDocumentos" (
    id integer NOT NULL,
    "tipoDocumento" character varying(30) NOT NULL
);


ALTER TABLE public."tiposDocumentos" OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 21439)
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
-- TOC entry 3696 (class 0 OID 0)
-- Dependencies: 235
-- Name: tiposDocumentos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."tiposDocumentos_id_seq" OWNED BY public."tiposDocumentos".id;


--
-- TOC entry 236 (class 1259 OID 21441)
-- Name: unidad_medida; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.unidad_medida (
    id integer NOT NULL,
    unidad character varying(50) NOT NULL
);


ALTER TABLE public.unidad_medida OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 21444)
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
-- TOC entry 3697 (class 0 OID 0)
-- Dependencies: 237
-- Name: unidad_medida_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.unidad_medida_id_seq OWNED BY public.unidad_medida.id;


--
-- TOC entry 254 (class 1259 OID 104882)
-- Name: ventas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ventas (
    id integer NOT NULL,
    estado boolean,
    fecha date NOT NULL,
    "totalNeto" double precision NOT NULL,
    totaliva double precision,
    total double precision NOT NULL,
    cliente_id integer NOT NULL,
    percepcion double precision,
    comprobante integer
);


ALTER TABLE public.ventas OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 104851)
-- Name: ventas_comprobante_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ventas_comprobante_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ventas_comprobante_seq OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 104880)
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
-- TOC entry 3698 (class 0 OID 0)
-- Dependencies: 253
-- Name: ventas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ventas_id_seq OWNED BY public.ventas.id;


--
-- TOC entry 3330 (class 2604 OID 21454)
-- Name: categoria id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria ALTER COLUMN id SET DEFAULT nextval('public.categoria_id_seq'::regclass);


--
-- TOC entry 3331 (class 2604 OID 21455)
-- Name: clientes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes ALTER COLUMN id SET DEFAULT nextval('public.clientes_id_seq'::regclass);


--
-- TOC entry 3340 (class 2604 OID 22149)
-- Name: companiaTarjeta id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."companiaTarjeta" ALTER COLUMN id SET DEFAULT nextval('public."companiaTarjeta_id_seq"'::regclass);


--
-- TOC entry 3354 (class 2604 OID 105160)
-- Name: compras id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras ALTER COLUMN id SET DEFAULT nextval('public.compras_id_seq'::regclass);


--
-- TOC entry 3343 (class 2604 OID 104573)
-- Name: datosEmpresa id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa" ALTER COLUMN id SET DEFAULT nextval('public."datosEmpresa_id_seq"'::regclass);


--
-- TOC entry 3350 (class 2604 OID 105039)
-- Name: datosFormaPagos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagos" ALTER COLUMN id SET DEFAULT nextval('public."datosFormaPagos_id_seq"'::regclass);


--
-- TOC entry 3352 (class 2604 OID 105122)
-- Name: datosFormaPagosCompra id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagosCompra" ALTER COLUMN id SET DEFAULT nextval('public."datosFormaPagosCompra_id_seq"'::regclass);


--
-- TOC entry 3348 (class 2604 OID 104985)
-- Name: forma_pago_venta id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.forma_pago_venta ALTER COLUMN id SET DEFAULT nextval('public.forma_pago_venta_id_seq'::regclass);


--
-- TOC entry 3332 (class 2604 OID 21462)
-- Name: formadepago id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.formadepago ALTER COLUMN id SET DEFAULT nextval('public.formadepago_id_seq'::regclass);


--
-- TOC entry 3333 (class 2604 OID 21463)
-- Name: localidad idlocalidad; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.localidad ALTER COLUMN idlocalidad SET DEFAULT nextval('public."localidad_idLocalidad_seq"'::regclass);


--
-- TOC entry 3334 (class 2604 OID 21464)
-- Name: marcas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marcas ALTER COLUMN id SET DEFAULT nextval('public.marcas_id_seq'::regclass);


--
-- TOC entry 3341 (class 2604 OID 38704)
-- Name: modulos_configuracion id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modulos_configuracion ALTER COLUMN id SET DEFAULT nextval('public.modulos_configuracion_id_seq'::regclass);


--
-- TOC entry 3351 (class 2604 OID 105082)
-- Name: oferta_whatsapp id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oferta_whatsapp ALTER COLUMN id SET DEFAULT nextval('public.oferta_whatsapp_id_seq'::regclass);


--
-- TOC entry 3346 (class 2604 OID 104920)
-- Name: pedido_cliente id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedido_cliente ALTER COLUMN id SET DEFAULT nextval('public.pedido_cliente_id_seq'::regclass);


--
-- TOC entry 3344 (class 2604 OID 104872)
-- Name: pedido_proveedor id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedido_proveedor ALTER COLUMN id SET DEFAULT nextval('public.pedido_proveedor_id_seq'::regclass);


--
-- TOC entry 3342 (class 2604 OID 38879)
-- Name: productos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos ALTER COLUMN id SET DEFAULT nextval('public.productos_id_seq'::regclass);


--
-- TOC entry 3335 (class 2604 OID 21467)
-- Name: proveedor id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedor ALTER COLUMN id SET DEFAULT nextval('public.proveedor_id_seq'::regclass);


--
-- TOC entry 3353 (class 2604 OID 105142)
-- Name: renglon id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon ALTER COLUMN id SET DEFAULT nextval('public.renglon_id_seq'::regclass);


--
-- TOC entry 3355 (class 2604 OID 105187)
-- Name: renglon_compras id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_compras ALTER COLUMN id SET DEFAULT nextval('public.renglon_compras_id_seq'::regclass);


--
-- TOC entry 3347 (class 2604 OID 104940)
-- Name: renglon_pedido id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_pedido ALTER COLUMN id SET DEFAULT nextval('public.renglon_pedido_id_seq'::regclass);


--
-- TOC entry 3349 (class 2604 OID 105021)
-- Name: renglon_pedido_whatsapp id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_pedido_whatsapp ALTER COLUMN id SET DEFAULT nextval('public.renglon_pedido_whatsapp_id_seq'::regclass);


--
-- TOC entry 3338 (class 2604 OID 21858)
-- Name: tipoPersona idTipoPersona; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tipoPersona" ALTER COLUMN "idTipoPersona" SET DEFAULT nextval('public."tipoPersona_idTipoPersona_seq"'::regclass);


--
-- TOC entry 3339 (class 2604 OID 21868)
-- Name: tiposClave id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tiposClave" ALTER COLUMN id SET DEFAULT nextval('public."tiposClave_id_seq"'::regclass);


--
-- TOC entry 3336 (class 2604 OID 21472)
-- Name: tiposDocumentos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tiposDocumentos" ALTER COLUMN id SET DEFAULT nextval('public."tiposDocumentos_id_seq"'::regclass);


--
-- TOC entry 3337 (class 2604 OID 21473)
-- Name: unidad_medida id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unidad_medida ALTER COLUMN id SET DEFAULT nextval('public.unidad_medida_id_seq'::regclass);


--
-- TOC entry 3345 (class 2604 OID 104885)
-- Name: ventas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas ALTER COLUMN id SET DEFAULT nextval('public.ventas_id_seq'::regclass);


--
-- TOC entry 3357 (class 2606 OID 21479)
-- Name: ab_permission ab_permission_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission
    ADD CONSTRAINT ab_permission_name_key UNIQUE (name);


--
-- TOC entry 3359 (class 2606 OID 21481)
-- Name: ab_permission ab_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission
    ADD CONSTRAINT ab_permission_pkey PRIMARY KEY (id);


--
-- TOC entry 3361 (class 2606 OID 21483)
-- Name: ab_permission_view ab_permission_view_permission_id_view_menu_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_permission_id_view_menu_id_key UNIQUE (permission_id, view_menu_id);


--
-- TOC entry 3363 (class 2606 OID 21485)
-- Name: ab_permission_view ab_permission_view_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_pkey PRIMARY KEY (id);


--
-- TOC entry 3365 (class 2606 OID 21487)
-- Name: ab_permission_view_role ab_permission_view_role_permission_view_id_role_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_permission_view_id_role_id_key UNIQUE (permission_view_id, role_id);


--
-- TOC entry 3367 (class 2606 OID 21489)
-- Name: ab_permission_view_role ab_permission_view_role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_pkey PRIMARY KEY (id);


--
-- TOC entry 3369 (class 2606 OID 21491)
-- Name: ab_register_user ab_register_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_register_user
    ADD CONSTRAINT ab_register_user_pkey PRIMARY KEY (id);


--
-- TOC entry 3371 (class 2606 OID 21493)
-- Name: ab_register_user ab_register_user_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_register_user
    ADD CONSTRAINT ab_register_user_username_key UNIQUE (username);


--
-- TOC entry 3373 (class 2606 OID 21495)
-- Name: ab_role ab_role_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_role
    ADD CONSTRAINT ab_role_name_key UNIQUE (name);


--
-- TOC entry 3375 (class 2606 OID 21497)
-- Name: ab_role ab_role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_role
    ADD CONSTRAINT ab_role_pkey PRIMARY KEY (id);


--
-- TOC entry 3377 (class 2606 OID 21499)
-- Name: ab_user ab_user_cuil_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_cuil_key UNIQUE (cuil);


--
-- TOC entry 3379 (class 2606 OID 21501)
-- Name: ab_user ab_user_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_email_key UNIQUE (email);


--
-- TOC entry 3381 (class 2606 OID 21503)
-- Name: ab_user ab_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_pkey PRIMARY KEY (id);


--
-- TOC entry 3385 (class 2606 OID 21505)
-- Name: ab_user_role ab_user_role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_pkey PRIMARY KEY (id);


--
-- TOC entry 3387 (class 2606 OID 21507)
-- Name: ab_user_role ab_user_role_user_id_role_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_user_id_role_id_key UNIQUE (user_id, role_id);


--
-- TOC entry 3383 (class 2606 OID 21509)
-- Name: ab_user ab_user_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_username_key UNIQUE (username);


--
-- TOC entry 3389 (class 2606 OID 21511)
-- Name: ab_view_menu ab_view_menu_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_view_menu
    ADD CONSTRAINT ab_view_menu_name_key UNIQUE (name);


--
-- TOC entry 3391 (class 2606 OID 21513)
-- Name: ab_view_menu ab_view_menu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_view_menu
    ADD CONSTRAINT ab_view_menu_pkey PRIMARY KEY (id);


--
-- TOC entry 3479 (class 2606 OID 105111)
-- Name: auditoria auditoria_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria
    ADD CONSTRAINT auditoria_pkey PRIMARY KEY (id);


--
-- TOC entry 3393 (class 2606 OID 21517)
-- Name: categoria categoria_categoria_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_categoria_key UNIQUE (categoria);


--
-- TOC entry 3395 (class 2606 OID 21519)
-- Name: categoria categoria_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_pkey PRIMARY KEY (id);


--
-- TOC entry 3397 (class 2606 OID 21521)
-- Name: clientes clientes_documento_tipoDocumento_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT "clientes_documento_tipoDocumento_id_key" UNIQUE (documento, "tipoDocumento_id");


--
-- TOC entry 3399 (class 2606 OID 21523)
-- Name: clientes clientes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (id);


--
-- TOC entry 3437 (class 2606 OID 22153)
-- Name: companiaTarjeta companiaTarjeta_compania_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."companiaTarjeta"
    ADD CONSTRAINT "companiaTarjeta_compania_key" UNIQUE (compania);


--
-- TOC entry 3439 (class 2606 OID 22151)
-- Name: companiaTarjeta companiaTarjeta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."companiaTarjeta"
    ADD CONSTRAINT "companiaTarjeta_pkey" PRIMARY KEY (id);


--
-- TOC entry 3487 (class 2606 OID 105166)
-- Name: compras compras_comprobante_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_comprobante_key UNIQUE (comprobante);


--
-- TOC entry 3489 (class 2606 OID 105164)
-- Name: compras compras_comprobante_proveedor_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_comprobante_proveedor_id_key UNIQUE (comprobante, proveedor_id);


--
-- TOC entry 3491 (class 2606 OID 105162)
-- Name: compras compras_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_pkey PRIMARY KEY (id);


--
-- TOC entry 3415 (class 2606 OID 39375)
-- Name: proveedor correo_proveedor_unico; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT correo_proveedor_unico UNIQUE (correo);


--
-- TOC entry 3447 (class 2606 OID 104580)
-- Name: datosEmpresa datosEmpresa_compania_direccion_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_compania_direccion_key" UNIQUE (compania, direccion);


--
-- TOC entry 3449 (class 2606 OID 104582)
-- Name: datosEmpresa datosEmpresa_compania_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_compania_key" UNIQUE (compania);


--
-- TOC entry 3451 (class 2606 OID 104586)
-- Name: datosEmpresa datosEmpresa_cuit_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_cuit_key" UNIQUE (cuit);


--
-- TOC entry 3453 (class 2606 OID 104584)
-- Name: datosEmpresa datosEmpresa_direccion_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_direccion_key" UNIQUE (direccion);


--
-- TOC entry 3455 (class 2606 OID 104578)
-- Name: datosEmpresa datosEmpresa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_pkey" PRIMARY KEY (id);


--
-- TOC entry 3481 (class 2606 OID 105126)
-- Name: datosFormaPagosCompra datosFormaPagosCompra_numeroCupon_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagosCompra"
    ADD CONSTRAINT "datosFormaPagosCompra_numeroCupon_key" UNIQUE ("numeroCupon");


--
-- TOC entry 3483 (class 2606 OID 105124)
-- Name: datosFormaPagosCompra datosFormaPagosCompra_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagosCompra"
    ADD CONSTRAINT "datosFormaPagosCompra_pkey" PRIMARY KEY (id);


--
-- TOC entry 3473 (class 2606 OID 105043)
-- Name: datosFormaPagos datosFormaPagos_numeroCupon_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagos"
    ADD CONSTRAINT "datosFormaPagos_numeroCupon_key" UNIQUE ("numeroCupon");


--
-- TOC entry 3475 (class 2606 OID 105041)
-- Name: datosFormaPagos datosFormaPagos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagos"
    ADD CONSTRAINT "datosFormaPagos_pkey" PRIMARY KEY (id);


--
-- TOC entry 3469 (class 2606 OID 104987)
-- Name: forma_pago_venta forma_pago_venta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.forma_pago_venta
    ADD CONSTRAINT forma_pago_venta_pkey PRIMARY KEY (id);


--
-- TOC entry 3401 (class 2606 OID 21551)
-- Name: formadepago formadepago_Metodo_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.formadepago
    ADD CONSTRAINT "formadepago_Metodo_key" UNIQUE ("Metodo");


--
-- TOC entry 3403 (class 2606 OID 21553)
-- Name: formadepago formadepago_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.formadepago
    ADD CONSTRAINT formadepago_pkey PRIMARY KEY (id);


--
-- TOC entry 3405 (class 2606 OID 21555)
-- Name: localidad localidad_localidad_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.localidad
    ADD CONSTRAINT localidad_localidad_key UNIQUE (localidad);


--
-- TOC entry 3407 (class 2606 OID 21557)
-- Name: localidad localidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.localidad
    ADD CONSTRAINT localidad_pkey PRIMARY KEY (idlocalidad);


--
-- TOC entry 3409 (class 2606 OID 21559)
-- Name: marcas marcas_marca_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marcas
    ADD CONSTRAINT marcas_marca_key UNIQUE (marca);


--
-- TOC entry 3411 (class 2606 OID 21561)
-- Name: marcas marcas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marcas
    ADD CONSTRAINT marcas_pkey PRIMARY KEY (id);


--
-- TOC entry 3441 (class 2606 OID 38706)
-- Name: modulos_configuracion modulos_configuracion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modulos_configuracion
    ADD CONSTRAINT modulos_configuracion_pkey PRIMARY KEY (id);


--
-- TOC entry 3477 (class 2606 OID 105084)
-- Name: oferta_whatsapp oferta_whatsapp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oferta_whatsapp
    ADD CONSTRAINT oferta_whatsapp_pkey PRIMARY KEY (id);


--
-- TOC entry 3413 (class 2606 OID 21565)
-- Name: operacion operacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.operacion
    ADD CONSTRAINT operacion_pkey PRIMARY KEY (id);


--
-- TOC entry 3463 (class 2606 OID 104924)
-- Name: pedido_cliente pedido_cliente_hash_activacion_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedido_cliente
    ADD CONSTRAINT pedido_cliente_hash_activacion_key UNIQUE (hash_activacion);


--
-- TOC entry 3465 (class 2606 OID 104922)
-- Name: pedido_cliente pedido_cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedido_cliente
    ADD CONSTRAINT pedido_cliente_pkey PRIMARY KEY (id);


--
-- TOC entry 3457 (class 2606 OID 104874)
-- Name: pedido_proveedor pedido_proveedor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedido_proveedor
    ADD CONSTRAINT pedido_proveedor_pkey PRIMARY KEY (id);


--
-- TOC entry 3443 (class 2606 OID 38883)
-- Name: productos productos_categoria_id_marcas_id_unidad_id_medida_detalle_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_categoria_id_marcas_id_unidad_id_medida_detalle_key UNIQUE (categoria_id, marcas_id, unidad_id, medida, detalle);


--
-- TOC entry 3445 (class 2606 OID 38881)
-- Name: productos productos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_pkey PRIMARY KEY (id);


--
-- TOC entry 3417 (class 2606 OID 21571)
-- Name: proveedor proveedor_cuit_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT proveedor_cuit_key UNIQUE (cuit);


--
-- TOC entry 3419 (class 2606 OID 21573)
-- Name: proveedor proveedor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT proveedor_pkey PRIMARY KEY (id);


--
-- TOC entry 3493 (class 2606 OID 105189)
-- Name: renglon_compras renglon_compras_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_compras
    ADD CONSTRAINT renglon_compras_pkey PRIMARY KEY (id);


--
-- TOC entry 3467 (class 2606 OID 104942)
-- Name: renglon_pedido renglon_pedido_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_pedido
    ADD CONSTRAINT renglon_pedido_pkey PRIMARY KEY (id);


--
-- TOC entry 3471 (class 2606 OID 105023)
-- Name: renglon_pedido_whatsapp renglon_pedido_whatsapp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_pedido_whatsapp
    ADD CONSTRAINT renglon_pedido_whatsapp_pkey PRIMARY KEY (id);


--
-- TOC entry 3485 (class 2606 OID 105144)
-- Name: renglon renglon_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon
    ADD CONSTRAINT renglon_pkey PRIMARY KEY (id);


--
-- TOC entry 3429 (class 2606 OID 21860)
-- Name: tipoPersona tipoPersona_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tipoPersona"
    ADD CONSTRAINT "tipoPersona_pkey" PRIMARY KEY ("idTipoPersona");


--
-- TOC entry 3431 (class 2606 OID 21862)
-- Name: tipoPersona tipoPersona_tipoPersona_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tipoPersona"
    ADD CONSTRAINT "tipoPersona_tipoPersona_key" UNIQUE ("tipoPersona");


--
-- TOC entry 3433 (class 2606 OID 21870)
-- Name: tiposClave tiposClave_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tiposClave"
    ADD CONSTRAINT "tiposClave_pkey" PRIMARY KEY (id);


--
-- TOC entry 3435 (class 2606 OID 21872)
-- Name: tiposClave tiposClave_tipoClave_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tiposClave"
    ADD CONSTRAINT "tiposClave_tipoClave_key" UNIQUE ("tipoClave");


--
-- TOC entry 3421 (class 2606 OID 21587)
-- Name: tiposDocumentos tiposDocumentos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tiposDocumentos"
    ADD CONSTRAINT "tiposDocumentos_pkey" PRIMARY KEY (id);


--
-- TOC entry 3423 (class 2606 OID 21589)
-- Name: tiposDocumentos tiposDocumentos_tipoDocumento_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tiposDocumentos"
    ADD CONSTRAINT "tiposDocumentos_tipoDocumento_key" UNIQUE ("tipoDocumento");


--
-- TOC entry 3425 (class 2606 OID 21591)
-- Name: unidad_medida unidad_medida_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unidad_medida
    ADD CONSTRAINT unidad_medida_pkey PRIMARY KEY (id);


--
-- TOC entry 3427 (class 2606 OID 21593)
-- Name: unidad_medida unidad_medida_unidad_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unidad_medida
    ADD CONSTRAINT unidad_medida_unidad_key UNIQUE (unidad);


--
-- TOC entry 3459 (class 2606 OID 104889)
-- Name: ventas ventas_comprobante_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_comprobante_key UNIQUE (comprobante);


--
-- TOC entry 3461 (class 2606 OID 104887)
-- Name: ventas ventas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_pkey PRIMARY KEY (id);


--
-- TOC entry 3538 (class 2620 OID 105208)
-- Name: renglon_compras updateproductoscompra; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER updateproductoscompra AFTER INSERT ON public.renglon_compras FOR EACH ROW EXECUTE FUNCTION public.sumarstockencompra();


--
-- TOC entry 3537 (class 2620 OID 105212)
-- Name: compras updateproductoscompranulada; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER updateproductoscompranulada AFTER UPDATE ON public.compras FOR EACH ROW EXECUTE FUNCTION public.actualiarstockencompranulada();


--
-- TOC entry 3536 (class 2620 OID 105206)
-- Name: renglon updateproductosventa; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER updateproductosventa AFTER INSERT ON public.renglon FOR EACH ROW EXECUTE FUNCTION public.descontarstockenventa();


--
-- TOC entry 3535 (class 2620 OID 105210)
-- Name: ventas updateproductosventanulada; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER updateproductosventanulada AFTER UPDATE ON public.ventas FOR EACH ROW EXECUTE FUNCTION public.sumarstockenventanulada();


--
-- TOC entry 3494 (class 2606 OID 21612)
-- Name: ab_permission_view ab_permission_view_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.ab_permission(id);


--
-- TOC entry 3496 (class 2606 OID 21617)
-- Name: ab_permission_view_role ab_permission_view_role_permission_view_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_permission_view_id_fkey FOREIGN KEY (permission_view_id) REFERENCES public.ab_permission_view(id);


--
-- TOC entry 3497 (class 2606 OID 21622)
-- Name: ab_permission_view_role ab_permission_view_role_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.ab_role(id);


--
-- TOC entry 3495 (class 2606 OID 21627)
-- Name: ab_permission_view ab_permission_view_view_menu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_view_menu_id_fkey FOREIGN KEY (view_menu_id) REFERENCES public.ab_view_menu(id);


--
-- TOC entry 3498 (class 2606 OID 21632)
-- Name: ab_user ab_user_changed_by_fk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_changed_by_fk_fkey FOREIGN KEY (changed_by_fk) REFERENCES public.ab_user(id);


--
-- TOC entry 3499 (class 2606 OID 21637)
-- Name: ab_user ab_user_created_by_fk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_created_by_fk_fkey FOREIGN KEY (created_by_fk) REFERENCES public.ab_user(id);


--
-- TOC entry 3500 (class 2606 OID 21642)
-- Name: ab_user_role ab_user_role_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.ab_role(id);


--
-- TOC entry 3501 (class 2606 OID 21647)
-- Name: ab_user_role ab_user_role_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.ab_user(id);


--
-- TOC entry 3524 (class 2606 OID 105112)
-- Name: auditoria auditoria_operation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria
    ADD CONSTRAINT auditoria_operation_id_fkey FOREIGN KEY (operation_id) REFERENCES public.operacion(id);


--
-- TOC entry 3502 (class 2606 OID 21667)
-- Name: clientes clientes_tipoDocumento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT "clientes_tipoDocumento_id_fkey" FOREIGN KEY ("tipoDocumento_id") REFERENCES public."tiposDocumentos"(id);


--
-- TOC entry 3529 (class 2606 OID 105177)
-- Name: compras compras_datosFormaPagos_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT "compras_datosFormaPagos_id_fkey" FOREIGN KEY ("datosFormaPagos_id") REFERENCES public."datosFormaPagosCompra"(id);


--
-- TOC entry 3530 (class 2606 OID 105172)
-- Name: compras compras_formadepago_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_formadepago_id_fkey FOREIGN KEY (formadepago_id) REFERENCES public.formadepago(id);


--
-- TOC entry 3531 (class 2606 OID 105167)
-- Name: compras compras_proveedor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_proveedor_id_fkey FOREIGN KEY (proveedor_id) REFERENCES public.proveedor(id);


--
-- TOC entry 3509 (class 2606 OID 104592)
-- Name: datosEmpresa datosEmpresa_idlocalidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_idlocalidad_fkey" FOREIGN KEY (idlocalidad) REFERENCES public.localidad(idlocalidad);


--
-- TOC entry 3508 (class 2606 OID 104587)
-- Name: datosEmpresa datosEmpresa_tipoClave_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_tipoClave_id_fkey" FOREIGN KEY ("tipoClave_id") REFERENCES public."tiposClave"(id);


--
-- TOC entry 3525 (class 2606 OID 105127)
-- Name: datosFormaPagosCompra datosFormaPagosCompra_companiaTarjeta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagosCompra"
    ADD CONSTRAINT "datosFormaPagosCompra_companiaTarjeta_id_fkey" FOREIGN KEY ("companiaTarjeta_id") REFERENCES public."companiaTarjeta"(id);


--
-- TOC entry 3526 (class 2606 OID 105132)
-- Name: datosFormaPagosCompra datosFormaPagosCompra_formadepago_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagosCompra"
    ADD CONSTRAINT "datosFormaPagosCompra_formadepago_id_fkey" FOREIGN KEY (formadepago_id) REFERENCES public.formadepago(id);


--
-- TOC entry 3520 (class 2606 OID 105044)
-- Name: datosFormaPagos datosFormaPagos_companiaTarjeta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagos"
    ADD CONSTRAINT "datosFormaPagos_companiaTarjeta_id_fkey" FOREIGN KEY ("companiaTarjeta_id") REFERENCES public."companiaTarjeta"(id);


--
-- TOC entry 3521 (class 2606 OID 105049)
-- Name: datosFormaPagos datosFormaPagos_formadepago_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagos"
    ADD CONSTRAINT "datosFormaPagos_formadepago_id_fkey" FOREIGN KEY (formadepago_id) REFERENCES public.forma_pago_venta(id);


--
-- TOC entry 3517 (class 2606 OID 104993)
-- Name: forma_pago_venta forma_pago_venta_formadepago_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.forma_pago_venta
    ADD CONSTRAINT forma_pago_venta_formadepago_id_fkey FOREIGN KEY (formadepago_id) REFERENCES public.formadepago(id);


--
-- TOC entry 3516 (class 2606 OID 104988)
-- Name: forma_pago_venta forma_pago_venta_venta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.forma_pago_venta
    ADD CONSTRAINT forma_pago_venta_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES public.ventas(id);


--
-- TOC entry 3503 (class 2606 OID 21717)
-- Name: clientes localidad_pkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT localidad_pkey FOREIGN KEY (idlocalidad) REFERENCES public.localidad(idlocalidad);


--
-- TOC entry 3504 (class 2606 OID 21722)
-- Name: proveedor localidad_pkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT localidad_pkey FOREIGN KEY (idlocalidad) REFERENCES public.localidad(idlocalidad);


--
-- TOC entry 3523 (class 2606 OID 105090)
-- Name: oferta_whatsapp oferta_whatsapp_cliente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oferta_whatsapp
    ADD CONSTRAINT oferta_whatsapp_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id);


--
-- TOC entry 3522 (class 2606 OID 105085)
-- Name: oferta_whatsapp oferta_whatsapp_producto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oferta_whatsapp
    ADD CONSTRAINT oferta_whatsapp_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES public.productos(id);


--
-- TOC entry 3512 (class 2606 OID 104925)
-- Name: pedido_cliente pedido_cliente_cliente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedido_cliente
    ADD CONSTRAINT pedido_cliente_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id);


--
-- TOC entry 3513 (class 2606 OID 104930)
-- Name: pedido_cliente pedido_cliente_venta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedido_cliente
    ADD CONSTRAINT pedido_cliente_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES public.ventas(id);


--
-- TOC entry 3510 (class 2606 OID 104875)
-- Name: pedido_proveedor pedido_proveedor_proveedor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedido_proveedor
    ADD CONSTRAINT pedido_proveedor_proveedor_id_fkey FOREIGN KEY (proveedor_id) REFERENCES public.proveedor(id);


--
-- TOC entry 3507 (class 2606 OID 38894)
-- Name: productos productos_categoria_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_categoria_id_fkey FOREIGN KEY (categoria_id) REFERENCES public.categoria(id);


--
-- TOC entry 3506 (class 2606 OID 38889)
-- Name: productos productos_marcas_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_marcas_id_fkey FOREIGN KEY (marcas_id) REFERENCES public.marcas(id);


--
-- TOC entry 3505 (class 2606 OID 38884)
-- Name: productos productos_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad_medida(id);


--
-- TOC entry 3532 (class 2606 OID 105190)
-- Name: renglon_compras renglon_compras_compra_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_compras
    ADD CONSTRAINT renglon_compras_compra_id_fkey FOREIGN KEY (compra_id) REFERENCES public.compras(id);


--
-- TOC entry 3533 (class 2606 OID 105195)
-- Name: renglon_compras renglon_compras_producto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_compras
    ADD CONSTRAINT renglon_compras_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES public.productos(id);


--
-- TOC entry 3534 (class 2606 OID 105200)
-- Name: renglon_compras renglon_compras_renglonPedidoWhatsapp_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_compras
    ADD CONSTRAINT "renglon_compras_renglonPedidoWhatsapp_id_fkey" FOREIGN KEY ("renglonPedidoWhatsapp_id") REFERENCES public.renglon_pedido_whatsapp(id);


--
-- TOC entry 3514 (class 2606 OID 104943)
-- Name: renglon_pedido renglon_pedido_pedido_proveedor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_pedido
    ADD CONSTRAINT renglon_pedido_pedido_proveedor_id_fkey FOREIGN KEY (pedido_proveedor_id) REFERENCES public.pedido_proveedor(id);


--
-- TOC entry 3515 (class 2606 OID 104948)
-- Name: renglon_pedido renglon_pedido_producto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_pedido
    ADD CONSTRAINT renglon_pedido_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES public.productos(id);


--
-- TOC entry 3518 (class 2606 OID 105024)
-- Name: renglon_pedido_whatsapp renglon_pedido_whatsapp_pedidocliente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_pedido_whatsapp
    ADD CONSTRAINT renglon_pedido_whatsapp_pedidocliente_id_fkey FOREIGN KEY (pedidocliente_id) REFERENCES public.pedido_cliente(id);


--
-- TOC entry 3519 (class 2606 OID 105029)
-- Name: renglon_pedido_whatsapp renglon_pedido_whatsapp_producto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_pedido_whatsapp
    ADD CONSTRAINT renglon_pedido_whatsapp_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES public.productos(id);


--
-- TOC entry 3527 (class 2606 OID 105150)
-- Name: renglon renglon_producto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon
    ADD CONSTRAINT renglon_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES public.productos(id);


--
-- TOC entry 3528 (class 2606 OID 105145)
-- Name: renglon renglon_venta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon
    ADD CONSTRAINT renglon_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES public.ventas(id);


--
-- TOC entry 3511 (class 2606 OID 104890)
-- Name: ventas ventas_cliente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id);


-- Completed on 2021-02-10 23:36:27

--
-- PostgreSQL database dump complete
--

