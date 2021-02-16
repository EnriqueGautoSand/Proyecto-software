--
-- PostgreSQL database dump
--

-- Dumped from database version 12.3
-- Dumped by pg_dump version 12.3

-- Started on 2021-02-10 23:35:31

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
-- TOC entry 3743 (class 1262 OID 20157)
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
-- TOC entry 3744 (class 0 OID 0)
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
-- TOC entry 3745 (class 0 OID 0)
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
-- TOC entry 3746 (class 0 OID 0)
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
-- TOC entry 3747 (class 0 OID 0)
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
-- TOC entry 3748 (class 0 OID 0)
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
-- TOC entry 3749 (class 0 OID 0)
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
-- TOC entry 3750 (class 0 OID 0)
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
-- TOC entry 3751 (class 0 OID 0)
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
-- TOC entry 3752 (class 0 OID 0)
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
-- TOC entry 3753 (class 0 OID 0)
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
-- TOC entry 3754 (class 0 OID 0)
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
-- TOC entry 3755 (class 0 OID 0)
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
-- TOC entry 3756 (class 0 OID 0)
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
-- TOC entry 3757 (class 0 OID 0)
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
-- TOC entry 3758 (class 0 OID 0)
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
-- TOC entry 3759 (class 0 OID 0)
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
-- TOC entry 3760 (class 0 OID 0)
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
-- TOC entry 3761 (class 0 OID 0)
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
-- TOC entry 3762 (class 0 OID 0)
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
-- TOC entry 3763 (class 0 OID 0)
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
-- TOC entry 3764 (class 0 OID 0)
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
-- TOC entry 3765 (class 0 OID 0)
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
-- TOC entry 3766 (class 0 OID 0)
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
-- TOC entry 3767 (class 0 OID 0)
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
-- TOC entry 3768 (class 0 OID 0)
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
-- TOC entry 3769 (class 0 OID 0)
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
-- TOC entry 3770 (class 0 OID 0)
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
-- TOC entry 3771 (class 0 OID 0)
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
-- TOC entry 3665 (class 0 OID 21283)
-- Dependencies: 204
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
INSERT INTO public.ab_permission (id, name) VALUES (58, 'anular_vencido');
INSERT INTO public.ab_permission (id, name) VALUES (59, 'Confirmar_Venta');
INSERT INTO public.ab_permission (id, name) VALUES (60, 'show_template');


--
-- TOC entry 3667 (class 0 OID 21288)
-- Dependencies: 206
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
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (524, 37, 214);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (525, 33, 214);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (526, 35, 214);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (527, 32, 214);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (528, 38, 214);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (529, 34, 214);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (530, 38, 169);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (531, 33, 215);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (532, 34, 215);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (533, 37, 215);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (534, 35, 215);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (535, 38, 171);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (536, 32, 190);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (537, 54, 216);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (538, 57, 190);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (539, 54, 217);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (540, 34, 218);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (541, 38, 218);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (542, 33, 218);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (543, 37, 218);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (544, 32, 218);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (545, 35, 218);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (546, 42, 219);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (547, 35, 220);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (548, 32, 220);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (549, 33, 220);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (550, 34, 220);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (551, 38, 220);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (552, 37, 220);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (553, 33, 224);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (554, 35, 224);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (555, 38, 224);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (556, 34, 224);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (557, 37, 224);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (558, 32, 224);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (559, 42, 225);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (560, 33, 226);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (561, 35, 226);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (562, 38, 226);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (563, 34, 226);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (564, 37, 226);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (565, 32, 226);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (566, 42, 227);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (567, 33, 228);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (568, 58, 228);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (569, 35, 228);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (570, 33, 229);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (571, 35, 229);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (572, 42, 230);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (573, 38, 229);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (574, 33, 231);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (575, 38, 231);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (576, 37, 216);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (577, 33, 216);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (578, 42, 232);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (579, 42, 233);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (580, 42, 235);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (581, 33, 236);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (582, 42, 237);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (583, 59, 236);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (584, 35, 236);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (585, 60, 236);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (586, 38, 236);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (587, 37, 236);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (588, 35, 239);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (589, 38, 239);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (590, 32, 239);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (591, 34, 239);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (592, 37, 239);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (593, 33, 239);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (594, 42, 240);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (595, 33, 241);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (596, 38, 241);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (597, 32, 241);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (598, 37, 241);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (599, 35, 241);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (600, 34, 241);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (601, 44, 242);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (602, 42, 243);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (603, 42, 244);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (604, 33, 245);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (605, 38, 245);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (606, 37, 245);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (607, 34, 245);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (608, 32, 245);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (609, 35, 245);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (610, 42, 246);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (611, 33, 247);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (612, 35, 247);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (613, 59, 247);
INSERT INTO public.ab_permission_view (id, permission_id, view_menu_id) VALUES (614, 38, 247);


--
-- TOC entry 3669 (class 0 OID 21293)
-- Dependencies: 208
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
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (589, 524, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (590, 525, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (591, 526, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (592, 527, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (593, 528, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (594, 529, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (595, 530, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (596, 531, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (597, 532, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (598, 533, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (599, 534, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (600, 535, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (601, 536, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (602, 537, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (603, 538, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (604, 539, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (605, 540, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (606, 541, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (607, 542, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (608, 543, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (609, 544, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (610, 545, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (611, 546, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (612, 547, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (613, 548, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (614, 549, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (615, 550, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (616, 551, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (617, 552, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (618, 553, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (619, 554, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (620, 555, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (621, 556, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (622, 557, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (623, 558, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (624, 559, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (625, 560, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (626, 561, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (627, 562, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (628, 563, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (629, 564, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (630, 565, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (631, 566, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (632, 567, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (633, 568, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (634, 569, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (635, 570, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (636, 571, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (637, 572, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (638, 573, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (639, 574, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (640, 575, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (641, 576, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (642, 577, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (643, 578, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (644, 579, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (645, 580, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (646, 581, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (647, 582, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (648, 583, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (649, 584, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (650, 585, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (651, 586, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (652, 587, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (653, 588, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (654, 589, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (655, 590, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (656, 591, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (657, 592, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (658, 593, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (659, 594, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (660, 595, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (661, 596, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (662, 597, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (663, 598, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (664, 599, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (665, 600, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (666, 601, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (667, 602, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (668, 603, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (669, 604, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (670, 605, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (671, 606, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (672, 607, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (673, 608, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (674, 609, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (675, 610, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (676, 611, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (677, 612, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (678, 613, 5);
INSERT INTO public.ab_permission_view_role (id, permission_view_id, role_id) VALUES (679, 614, 5);


--
-- TOC entry 3671 (class 0 OID 21298)
-- Dependencies: 210
-- Data for Name: ab_register_user; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3673 (class 0 OID 21306)
-- Dependencies: 212
-- Data for Name: ab_role; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ab_role (id, name) VALUES (5, 'Admin');
INSERT INTO public.ab_role (id, name) VALUES (6, 'Public');
INSERT INTO public.ab_role (id, name) VALUES (7, 'Gerente');
INSERT INTO public.ab_role (id, name) VALUES (9, 'Vendedor');


--
-- TOC entry 3675 (class 0 OID 21311)
-- Dependencies: 214
-- Data for Name: ab_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ab_user (id, first_name, last_name, username, password, active, email, last_login, login_count, fail_login_count, created_on, changed_on, created_by_fk, changed_by_fk, cuil) VALUES (8, 'enrique', 'sand', 'egsand', 'pbkdf2:sha256:50000$M2KUtiFD$2bbe3354fdf08e42d3a2b9cfb6e08ba7e693dbe72a933f530184e52c9353f827', true, 'xovibe4870@x1post.com', '2020-11-06 10:01:50.553639', 1, 0, '2020-11-06 09:50:56.941954', '2020-11-06 10:11:03.964096', NULL, 6, '27-05883446-2');
INSERT INTO public.ab_user (id, first_name, last_name, username, password, active, email, last_login, login_count, fail_login_count, created_on, changed_on, created_by_fk, changed_by_fk, cuil) VALUES (16, 'jack', 'nickolson', 'jack', 'pbkdf2:sha256:50000$gPa5yVlC$ef4dea0120344212163d25b946edcba8ca9f5eafd782fe1f6d07cba7b4b61372', true, 'sirepo4423@x1post.com', '2020-11-09 14:54:54.205387', 1, 0, '2020-11-09 14:54:38.867965', '2020-11-09 14:54:38.867965', NULL, NULL, NULL);
INSERT INTO public.ab_user (id, first_name, last_name, username, password, active, email, last_login, login_count, fail_login_count, created_on, changed_on, created_by_fk, changed_by_fk, cuil) VALUES (17, 'vendedor', '1', 'vendedor', 'pbkdf2:sha256:50000$suwSLpY6$e59f815bc57ab0d88b389602b91d68744bcc684f30d7b6acf37eed744143b983', true, 'dayim53320@idcbill.com', '2020-11-22 16:14:30.331351', 5, 0, '2020-11-10 21:56:07.058721', '2020-11-22 15:44:56.254073', NULL, 5, '27-10604821-0');
INSERT INTO public.ab_user (id, first_name, last_name, username, password, active, email, last_login, login_count, fail_login_count, created_on, changed_on, created_by_fk, changed_by_fk, cuil) VALUES (6, 'gerente', 'gerente', 'gerente1', 'pbkdf2:sha256:50000$Q5m5vE72$9a595328c91717556dc8d8e9a89b781f26a05c50016dc84e195797eb8bdcaac4', true, 'gerente@gmail.com', '2020-12-01 20:25:08.4678', 20, 0, '2020-10-15 18:33:32.22051', '2020-10-26 12:54:36.693305', 5, 5, '27-39441118-9');
INSERT INTO public.ab_user (id, first_name, last_name, username, password, active, email, last_login, login_count, fail_login_count, created_on, changed_on, created_by_fk, changed_by_fk, cuil) VALUES (5, 'admin', 'super', 'superadmin', 'pbkdf2:sha256:50000$DIByLH7T$9421fe78a224369623f4e330177bcbebf9f22d6384b72366d8f8f4ec3511d55e', true, 'admin@fab.org', '2021-02-16 08:55:47.132645', 87, 0, '2020-10-15 18:13:49.879222', '2020-10-15 18:13:49.879222', NULL, NULL, NULL);


--
-- TOC entry 3677 (class 0 OID 21319)
-- Dependencies: 216
-- Data for Name: ab_user_role; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ab_user_role (id, user_id, role_id) VALUES (6, 5, 5);
INSERT INTO public.ab_user_role (id, user_id, role_id) VALUES (9, 6, 7);
INSERT INTO public.ab_user_role (id, user_id, role_id) VALUES (11, 8, 6);
INSERT INTO public.ab_user_role (id, user_id, role_id) VALUES (24, 16, 6);
INSERT INTO public.ab_user_role (id, user_id, role_id) VALUES (25, 17, 6);
INSERT INTO public.ab_user_role (id, user_id, role_id) VALUES (27, 17, 9);


--
-- TOC entry 3679 (class 0 OID 21324)
-- Dependencies: 218
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
INSERT INTO public.ab_view_menu (id, name) VALUES (214, 'Clienteapi');
INSERT INTO public.ab_view_menu (id, name) VALUES (215, 'proveedoraccess');
INSERT INTO public.ab_view_menu (id, name) VALUES (216, 'PrecioMdelviewip');
INSERT INTO public.ab_view_menu (id, name) VALUES (217, 'ventaclass');
INSERT INTO public.ab_view_menu (id, name) VALUES (218, 'ModulosInteligentesView');
INSERT INTO public.ab_view_menu (id, name) VALUES (219, 'Modulos Inteligentes');
INSERT INTO public.ab_view_menu (id, name) VALUES (220, 'RenglonComprasView');
INSERT INTO public.ab_view_menu (id, name) VALUES (221, 'smsreply');
INSERT INTO public.ab_view_menu (id, name) VALUES (222, 'MyIndexView');
INSERT INTO public.ab_view_menu (id, name) VALUES (223, 'Myauthdbview');
INSERT INTO public.ab_view_menu (id, name) VALUES (224, 'PedidoView');
INSERT INTO public.ab_view_menu (id, name) VALUES (225, 'Pedidos de Presupesto');
INSERT INTO public.ab_view_menu (id, name) VALUES (226, 'RenglonPedidoView');
INSERT INTO public.ab_view_menu (id, name) VALUES (227, 'Vencidos');
INSERT INTO public.ab_view_menu (id, name) VALUES (228, 'RenglonComprasVencidos');
INSERT INTO public.ab_view_menu (id, name) VALUES (229, 'RenglonComprasxVencer');
INSERT INTO public.ab_view_menu (id, name) VALUES (230, 'Por Vencer');
INSERT INTO public.ab_view_menu (id, name) VALUES (231, 'ProductoxVencer');
INSERT INTO public.ab_view_menu (id, name) VALUES (232, 'Categoria Marca Unidad');
INSERT INTO public.ab_view_menu (id, name) VALUES (233, 'Producto');
INSERT INTO public.ab_view_menu (id, name) VALUES (234, 'ModeloWhatsapp');
INSERT INTO public.ab_view_menu (id, name) VALUES (235, 'Auditoría');
INSERT INTO public.ab_view_menu (id, name) VALUES (236, 'PedidosWhatsappView');
INSERT INTO public.ab_view_menu (id, name) VALUES (237, 'Ofertas de Ventas Whtasapp');
INSERT INTO public.ab_view_menu (id, name) VALUES (238, 'ModeloWhatsappPedido');
INSERT INTO public.ab_view_menu (id, name) VALUES (239, 'PediddosClientesView');
INSERT INTO public.ab_view_menu (id, name) VALUES (240, 'Pedidos de Ventas Whtasapp');
INSERT INTO public.ab_view_menu (id, name) VALUES (241, 'ConvertirVenta');
INSERT INTO public.ab_view_menu (id, name) VALUES (242, 'VentaTimeChartView');
INSERT INTO public.ab_view_menu (id, name) VALUES (243, 'Grafico de ventas');
INSERT INTO public.ab_view_menu (id, name) VALUES (244, 'Estadistica');
INSERT INTO public.ab_view_menu (id, name) VALUES (245, 'Pedidoapi');
INSERT INTO public.ab_view_menu (id, name) VALUES (246, 'Lotes');
INSERT INTO public.ab_view_menu (id, name) VALUES (247, 'OfertaWhatsappView');


--
-- TOC entry 3729 (class 0 OID 105104)
-- Dependencies: 268
-- Data for Name: auditoria; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (746, 'ID 10 ESTADO True TOTAL 10000.0 TOTALNETO 10000.0 TOTALIVA 0.0 FECHA 2020-11-01 PROVEEDOR_ID 5 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 1 ', 'superadmin', '', '2020-11-01 15:59:36.878917', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (747, 'ID 11 ESTADO True TOTAL 3850.0 TOTALNETO 3850.0 TOTALIVA 0.0 FECHA 2020-11-01 PROVEEDOR_ID 7 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 2 ', 'superadmin', '', '2020-11-01 16:01:13.413033', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (748, 'ID 12 ESTADO True TOTAL 4500.0 TOTALNETO 4500.0 TOTALIVA 0.0 FECHA 2020-11-01 PROVEEDOR_ID 4 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 3 ', 'superadmin', '', '2020-11-01 16:02:41.344453', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (749, 'ID 13 ESTADO True TOTAL 11800.0 TOTALNETO 11800.0 TOTALIVA 0.0 FECHA 2020-11-01 PROVEEDOR_ID 5 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 4 ', 'superadmin', '', '2020-11-01 16:04:17.26652', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (750, 'ID 14 ESTADO True TOTAL 5320.0 TOTALNETO 5320.0 TOTALIVA 0.0 FECHA 2020-11-01 PROVEEDOR_ID 11 FORMADEPAGO_ID 2 DATOSFORMAPAGOS_ID 1 PERCEPCION 0.0 COMPROBANTE 7 ', 'superadmin', '', '2020-11-01 16:06:07.886601', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (751, 'ID 72 ESTADO True FECHA 2020-11-05 TOTALNETO 3146.0 TOTALIVA 0.0 TOTAL 3146.0 CLIENTE_ID 4491 PERCEPCION 0.0 COMPROBANTE 1 ', 'superadmin', '', '2020-11-05 16:30:42.052533', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (752, 'ID 74 ESTADO True FECHA 2020-11-05 TOTALNETO 3747.9 TOTALIVA 0.0 TOTAL 3747.9 CLIENTE_ID 7735 PERCEPCION 0.0 COMPROBANTE 2 ', 'superadmin', '', '2020-11-05 16:31:51.610455', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (753, 'ID 75 ESTADO True FECHA 2020-11-10 TOTALNETO 7810.4 TOTALIVA 0.0 TOTAL 7810.4 CLIENTE_ID 4428 PERCEPCION 0.0 COMPROBANTE 3 ', 'superadmin', '', '2020-11-10 16:32:31.312853', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (754, 'ID 76 ESTADO True FECHA 2020-11-10 TOTALNETO 4374.24 TOTALIVA 0.0 TOTAL 4374.24 CLIENTE_ID 4274 PERCEPCION 0.0 COMPROBANTE 4 ', 'superadmin', '', '2020-11-10 16:33:04.80463', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (755, 'ID 77 ESTADO True FECHA 2020-11-10 TOTALNETO 251.68 TOTALIVA 0.0 TOTAL 251.68 CLIENTE_ID 2356 PERCEPCION 0.0 COMPROBANTE 5 ', 'superadmin', '', '2020-11-10 16:33:39.051937', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (756, 'ID 78 ESTADO True FECHA 2020-11-10 TOTALNETO 2831.4 TOTALIVA 0.0 TOTAL 2831.4 CLIENTE_ID 4490 PERCEPCION 0.0 COMPROBANTE 6 ', 'superadmin', '', '2020-11-10 16:34:11.645412', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (757, 'ID 79 ESTADO True FECHA 2020-11-15 TOTALNETO 5309.2 TOTALIVA 0.0 TOTAL 5309.2 CLIENTE_ID 4491 PERCEPCION 0.0 COMPROBANTE 7 ', 'superadmin', '', '2020-11-15 16:35:11.439989', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (758, 'ID 80 ESTADO True FECHA 2020-11-15 TOTALNETO 1085.37 TOTALIVA 0.0 TOTAL 1085.37 CLIENTE_ID 4221 PERCEPCION 0.0 COMPROBANTE 8 ', 'superadmin', '', '2020-11-15 16:37:03.41501', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (759, 'ID 81 ESTADO True FECHA 2020-11-15 TOTALNETO 1267.89 TOTALIVA 0.0 TOTAL 1267.89 CLIENTE_ID 4 PERCEPCION 0.0 COMPROBANTE 9 ', 'superadmin', '', '2020-11-15 16:43:13.863397', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (760, 'ID 82 ESTADO True FECHA 2020-11-15 TOTALNETO 1469.52 TOTALIVA 0.0 TOTAL 1469.52 CLIENTE_ID 4205 PERCEPCION 0.0 COMPROBANTE 10 ', 'superadmin', '', '2020-11-15 16:43:30.32346', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (761, 'ID 83 ESTADO True FECHA 2020-11-15 TOTALNETO 4797.65 TOTALIVA 0.0 TOTAL 4797.65 CLIENTE_ID 4221 PERCEPCION 0.0 COMPROBANTE 11 ', 'superadmin', '', '2020-11-15 16:43:51.514077', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (762, 'ID 84 ESTADO True FECHA 2020-11-25 TOTALNETO 1755.52 TOTALIVA 0.0 TOTAL 1755.52 CLIENTE_ID 637 PERCEPCION 0.0 COMPROBANTE 12 ', 'superadmin', '', '2020-11-25 16:44:11.552515', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (763, 'ID 87 ESTADO True FECHA 2020-11-25 TOTALNETO 1573.0 TOTALIVA 0.0 TOTAL 1573.0 CLIENTE_ID 4490 PERCEPCION 0.0 COMPROBANTE 13 ', 'superadmin', '', '2020-11-25 16:45:50.720562', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (764, 'ID 15 ESTADO True TOTAL 23500.0 TOTALNETO 23500.0 TOTALIVA 0.0 FECHA 2020-12-01 PROVEEDOR_ID 5 FORMADEPAGO_ID 2 DATOSFORMAPAGOS_ID 2 PERCEPCION 0.0 COMPROBANTE 8 ', 'superadmin', '', '2020-12-01 16:47:40.382281', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (765, 'ID 16 ESTADO True TOTAL 24100.0 TOTALNETO 24100.0 TOTALIVA 0.0 FECHA 2020-12-01 PROVEEDOR_ID 7 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 9 ', 'superadmin', '', '2020-12-01 16:49:27.962332', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (766, 'ID 18 ESTADO True TOTAL 14400.0 TOTALNETO 14400.0 TOTALIVA 0.0 FECHA 2020-12-01 PROVEEDOR_ID 11 FORMADEPAGO_ID 2 DATOSFORMAPAGOS_ID 4 PERCEPCION 0.0 COMPROBANTE 10 ', 'superadmin', '', '2020-12-01 16:50:21.897834', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (767, 'ID 19 ESTADO True TOTAL 13800.0 TOTALNETO 13800.0 TOTALIVA 882.0 FECHA 2020-12-01 PROVEEDOR_ID 9 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 11 ', 'superadmin', '', '2020-12-01 16:55:18.829306', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (768, 'ID 20 ESTADO True TOTAL 28000.0 TOTALNETO 28000.0 TOTALIVA 0.0 FECHA 2020-12-01 PROVEEDOR_ID 4 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 12 ', 'superadmin', '', '2020-12-01 16:56:11.432219', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (769, 'ID 21 ESTADO True TOTAL 4500.0 TOTALNETO 4500.0 TOTALIVA 0.0 FECHA 2020-12-01 PROVEEDOR_ID 6 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 13 ', 'superadmin', '', '2020-12-01 16:57:03.638202', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (770, 'ID 88 ESTADO True FECHA 2020-12-10 TOTALNETO 125.84 TOTALIVA 0.0 TOTAL 125.84 CLIENTE_ID 7735 PERCEPCION 0.0 COMPROBANTE 14 ', 'superadmin', '', '2020-12-10 17:05:14.668835', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (771, 'ID 90 ESTADO True FECHA 2020-12-10 TOTALNETO 880.88 TOTALIVA 0.0 TOTAL 880.88 CLIENTE_ID 4428 PERCEPCION 0.0 COMPROBANTE 15 ', 'superadmin', '', '2020-12-10 17:09:34.91451', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (772, 'ID 91 ESTADO True FECHA 2020-12-10 TOTALNETO 3211.0 TOTALIVA 674.31 TOTAL 3917.42 CLIENTE_ID 4490 PERCEPCION 1.0 COMPROBANTE 16 ', 'superadmin', '', '2020-12-10 17:14:40.752819', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (773, 'ID 92 ESTADO True FECHA 2020-12-10 TOTALNETO 6864.0 TOTALIVA 0.0 TOTAL 6864.0 CLIENTE_ID 7735 PERCEPCION 0.0 COMPROBANTE 17 ', 'superadmin', '', '2020-12-10 17:16:22.449358', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (774, 'ID 93 ESTADO True FECHA 2020-12-10 TOTALNETO 5391.1 TOTALIVA 0.0 TOTAL 5391.1 CLIENTE_ID 2356 PERCEPCION 0.0 COMPROBANTE 18 ', 'superadmin', '', '2020-12-10 17:17:41.946187', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (775, 'ID 94 ESTADO True FECHA 2020-12-10 TOTALNETO 2167.88 TOTALIVA 0.0 TOTAL 2167.88 CLIENTE_ID 4 PERCEPCION 0.0 COMPROBANTE 19 ', 'superadmin', '', '2020-12-10 17:18:07.764135', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (776, 'ID 98 ESTADO True FECHA 2020-12-10 TOTALNETO 2345.2 TOTALIVA 0.0 TOTAL 2345.2 CLIENTE_ID 1 PERCEPCION 0.0 COMPROBANTE 20 ', 'superadmin', '', '2020-12-10 17:19:29.541136', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (777, 'ID 100 ESTADO True FECHA 2020-12-20 TOTALNETO 1624.48 TOTALIVA 0.0 TOTAL 1624.48 CLIENTE_ID 4491 PERCEPCION 0.0 COMPROBANTE 21 ', 'superadmin', '', '2020-12-20 17:20:40.261098', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (778, 'ID 101 ESTADO True FECHA 2020-12-20 TOTALNETO 2831.4 TOTALIVA 0.0 TOTAL 2831.4 CLIENTE_ID 4781 PERCEPCION 0.0 COMPROBANTE 22 ', 'superadmin', '', '2020-12-20 17:21:42.735921', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (779, 'ID 102 ESTADO True FECHA 2020-12-20 TOTALNETO 3317.6 TOTALIVA 0.0 TOTAL 3317.6 CLIENTE_ID 4491 PERCEPCION 0.0 COMPROBANTE 23 ', 'superadmin', '', '2020-12-20 17:21:58.008236', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (780, 'ID 103 ESTADO True FECHA 2020-12-20 TOTALNETO 862.29 TOTALIVA 0.0 TOTAL 862.29 CLIENTE_ID 4428 PERCEPCION 0.0 COMPROBANTE 24 ', 'superadmin', '', '2020-12-20 17:22:18.523484', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (781, 'ID 104 ESTADO True FECHA 2020-12-20 TOTALNETO 709.28 TOTALIVA 0.0 TOTAL 709.28 CLIENTE_ID 4215 PERCEPCION 0.0 COMPROBANTE 25 ', 'superadmin', '', '2020-12-20 17:22:38.315636', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (782, 'ID 107 ESTADO True FECHA 2020-12-20 TOTALNETO 1560.41 TOTALIVA 0.0 TOTAL 1560.41 CLIENTE_ID 4616 PERCEPCION 0.0 COMPROBANTE 26 ', 'superadmin', '', '2020-12-20 17:23:37.584578', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (783, 'ID 108 ESTADO True FECHA 2020-12-27 TOTALNETO 1596.58 TOTALIVA 0.0 TOTAL 1596.58 CLIENTE_ID 3888 PERCEPCION 0.0 COMPROBANTE 27 ', 'superadmin', '', '2020-12-27 17:24:22.80423', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (784, 'ID 109 ESTADO True FECHA 2020-12-27 TOTALNETO 547.69 TOTALIVA 0.0 TOTAL 547.69 CLIENTE_ID 4205 PERCEPCION 0.0 COMPROBANTE 28 ', 'superadmin', '', '2020-12-27 17:24:59.433069', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (785, 'ID 110 ESTADO True FECHA 2020-12-27 TOTALNETO 1430.0 TOTALIVA 0.0 TOTAL 1430.0 CLIENTE_ID 1 PERCEPCION 0.0 COMPROBANTE 29 ', 'superadmin', '', '2020-12-27 17:25:21.884029', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (786, 'ID 111 ESTADO True FECHA 2020-12-27 TOTALNETO 228.8 TOTALIVA 0.0 TOTAL 228.8 CLIENTE_ID 1 PERCEPCION 0.0 COMPROBANTE 30 ', 'superadmin', '', '2020-12-27 17:25:36.886306', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (787, 'ID 25 ESTADO True TOTAL 900.0 TOTALNETO 900.0 TOTALIVA 0.0 FECHA 2021-01-01 PROVEEDOR_ID 5 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 14 ', 'superadmin', '', '2021-01-01 18:14:18.03363', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (788, 'ID 26 ESTADO True TOTAL 9700.0 TOTALNETO 9700.0 TOTALIVA 0.0 FECHA 2021-01-01 PROVEEDOR_ID 9 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 15 ', 'superadmin', '', '2021-01-01 18:15:47.576696', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (789, 'ID 27 ESTADO True TOTAL 4200.0 TOTALNETO 4200.0 TOTALIVA 0.0 FECHA 2021-01-01 PROVEEDOR_ID 11 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 16 ', 'superadmin', '', '2021-01-01 18:17:06.605817', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (790, 'ID 28 ESTADO True TOTAL 14400.0 TOTALNETO 14400.0 TOTALIVA 0.0 FECHA 2021-01-01 PROVEEDOR_ID 7 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 17 ', 'superadmin', '', '2021-01-01 18:18:08.54342', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (791, 'ID 29 ESTADO True TOTAL 20000.0 TOTALNETO 20000.0 TOTALIVA 0.0 FECHA 2021-01-01 PROVEEDOR_ID 4 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 18 ', 'superadmin', '', '2021-01-01 18:19:14.957672', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (792, 'ID 33 ESTADO True TOTAL 11400.0 TOTALNETO 11400.0 TOTALIVA 0.0 FECHA 2021-01-01 PROVEEDOR_ID 6 FORMADEPAGO_ID 2 DATOSFORMAPAGOS_ID 11 PERCEPCION 0.0 COMPROBANTE None ', 'superadmin', '', '2021-01-01 18:22:22.594462', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (793, 'ID 34 ESTADO True TOTAL 1600.0 TOTALNETO 1600.0 TOTALIVA 0.0 FECHA 2021-01-01 PROVEEDOR_ID 7 FORMADEPAGO_ID 2 DATOSFORMAPAGOS_ID 12 PERCEPCION 0.0 COMPROBANTE 20 ', 'superadmin', '', '2021-01-01 18:29:19.253195', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (794, 'ID 113 ESTADO True FECHA 2021-01-11 TOTALNETO 1415.7 TOTALIVA 0.0 TOTAL 1415.7 CLIENTE_ID 4491 PERCEPCION 0.0 COMPROBANTE 31 ', 'superadmin', '', '2021-01-11 18:30:44.29341', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (795, 'ID 114 ESTADO True FECHA 2021-01-11 TOTALNETO 5582.72 TOTALIVA 0.0 TOTAL 5582.72 CLIENTE_ID 7735 PERCEPCION 0.0 COMPROBANTE 32 ', 'superadmin', '', '2021-01-11 18:31:46.94301', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (796, 'ID 115 ESTADO True FECHA 2021-01-11 TOTALNETO 909.74 TOTALIVA 0.0 TOTAL 909.74 CLIENTE_ID 2356 PERCEPCION 0.0 COMPROBANTE 33 ', 'superadmin', '', '2021-01-11 18:32:22.258154', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (797, 'ID 116 ESTADO True FECHA 2021-01-11 TOTALNETO 1541.54 TOTALIVA 0.0 TOTAL 1541.54 CLIENTE_ID 1 PERCEPCION 0.0 COMPROBANTE 34 ', 'superadmin', '', '2021-01-11 18:36:19.949171', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (798, 'ID 117 ESTADO True FECHA 2021-01-11 TOTALNETO 6921.2 TOTALIVA 0.0 TOTAL 6921.2 CLIENTE_ID 4428 PERCEPCION 0.0 COMPROBANTE 35 ', 'superadmin', '', '2021-01-11 18:36:43.019894', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (799, 'ID 118 ESTADO True FECHA 2021-01-11 TOTALNETO 707.85 TOTALIVA 0.0 TOTAL 707.85 CLIENTE_ID 4221 PERCEPCION 0.0 COMPROBANTE 36 ', 'superadmin', '', '2021-01-11 18:36:59.887922', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (800, 'ID 119 ESTADO True FECHA 2021-01-11 TOTALNETO 5831.02 TOTALIVA 0.0 TOTAL 5831.02 CLIENTE_ID 4274 PERCEPCION 0.0 COMPROBANTE 37 ', 'superadmin', '', '2021-01-11 18:37:28.342932', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (801, 'ID 120 ESTADO True FECHA 2021-01-11 TOTALNETO 1315.6 TOTALIVA 0.0 TOTAL 1315.6 CLIENTE_ID 7735 PERCEPCION 0.0 COMPROBANTE 38 ', 'superadmin', '', '2021-01-11 18:37:50.428294', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (802, 'ID 121 ESTADO True FECHA 2021-01-11 TOTALNETO 2981.55 TOTALIVA 0.0 TOTAL 2981.55 CLIENTE_ID 1 PERCEPCION 0.0 COMPROBANTE 39 ', 'superadmin', '', '2021-01-11 18:38:16.300855', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (803, 'ID 122 ESTADO True FECHA 2021-01-11 TOTALNETO 865.15 TOTALIVA 0.0 TOTAL 865.15 CLIENTE_ID 4210 PERCEPCION 0.0 COMPROBANTE 40 ', 'superadmin', '', '2021-01-11 18:38:45.520918', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (804, 'ID 123 ESTADO True FECHA 2021-01-20 TOTALNETO 2911.48 TOTALIVA 0.0 TOTAL 2911.48 CLIENTE_ID 4490 PERCEPCION 0.0 COMPROBANTE 41 ', 'superadmin', '', '2021-01-20 18:40:14.396157', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (805, 'ID 124 ESTADO True FECHA 2021-01-20 TOTALNETO 1454.44 TOTALIVA 0.0 TOTAL 1454.44 CLIENTE_ID 4491 PERCEPCION 0.0 COMPROBANTE 42 ', 'superadmin', '', '2021-01-20 18:40:42.988427', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (806, 'ID 125 ESTADO True FECHA 2021-01-20 TOTALNETO 1093.95 TOTALIVA 0.0 TOTAL 1093.95 CLIENTE_ID 4205 PERCEPCION 0.0 COMPROBANTE 43 ', 'superadmin', '', '2021-01-20 18:41:40.054937', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (807, 'ID 126 ESTADO True FECHA 2021-01-20 TOTALNETO 4015.44 TOTALIVA 0.0 TOTAL 4015.44 CLIENTE_ID 4491 PERCEPCION 0.0 COMPROBANTE 44 ', 'superadmin', '', '2021-01-20 18:42:37.830511', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (808, 'ID 127 ESTADO True FECHA 2021-01-20 TOTALNETO 4994.34 TOTALIVA 0.0 TOTAL 4994.34 CLIENTE_ID 1 PERCEPCION 0.0 COMPROBANTE 45 ', 'superadmin', '', '2021-01-20 18:43:13.472866', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (809, 'ID 128 ESTADO True FECHA 2021-01-27 TOTALNETO 3381.95 TOTALIVA 0.0 TOTAL 3381.95 CLIENTE_ID 4428 PERCEPCION 0.0 COMPROBANTE 46 ', 'superadmin', '', '2021-01-27 18:43:50.191817', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (810, 'ID 129 ESTADO True FECHA 2021-01-27 TOTALNETO 1372.8 TOTALIVA 0.0 TOTAL 1372.8 CLIENTE_ID 4274 PERCEPCION 0.0 COMPROBANTE 47 ', 'superadmin', '', '2021-01-27 18:44:22.010289', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (811, 'ID 35 ESTADO True TOTAL 3900.0 TOTALNETO 3900.0 TOTALIVA 504.0 FECHA 2021-02-01 PROVEEDOR_ID 5 FORMADEPAGO_ID 2 DATOSFORMAPAGOS_ID 13 PERCEPCION 0.0 COMPROBANTE 21 ', 'superadmin', '', '2021-02-01 18:53:23.3793', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (812, 'ID 131 ESTADO True FECHA 2021-02-01 TOTALNETO 18444.14 TOTALIVA 0.0 TOTAL 18444.14 CLIENTE_ID 4491 PERCEPCION 0.0 COMPROBANTE 48 ', 'superadmin', '', '2021-02-01 18:58:37.830291', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (813, 'ID 11 CUIT 20-17662132-0 NOMBRE MARTIN APELLIDO ARJONA RANKING 0 DOMICILIO None CORREO  ESTADO True TIPOCLAVE_ID 3 IDTIPOPERSONA 1 DIRECCION drrtjdrtfh@ahhtee.com IDLOCALIDAD None TELEFONO_CELULAR None ', 'superadmin', 'ID 11 CUIT 20-17662132-0 NOMBRE MARTIN APELLIDO ARJONA RANKING 0 DOMICILIO None CORREO None ESTADO True TIPOCLAVE_ID 3 IDTIPOPERSONA 1 DIRECCION  IDLOCALIDAD None TELEFONO_CELULAR None ', '2021-02-01 19:02:04.719028', 14, 'Proveedor');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (814, 'ID 11 CUIT 20-17662132-0 NOMBRE MARTIN APELLIDO ARJONA RANKING 0 DOMICILIO None CORREO  ESTADO True TIPOCLAVE_ID 3 IDTIPOPERSONA 1 DIRECCION drrtjdrtfh@ahhtee.com IDLOCALIDAD 1 TELEFONO_CELULAR None ', 'superadmin', 'ID 11 CUIT 20-17662132-0 NOMBRE MARTIN APELLIDO ARJONA RANKING 0 DOMICILIO None CORREO  ESTADO True TIPOCLAVE_ID 3 IDTIPOPERSONA 1 DIRECCION drrtjdrtfh@ahhtee.com IDLOCALIDAD None TELEFONO_CELULAR None ', '2021-02-01 19:02:17.482233', 14, 'Proveedor');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (815, 'ID 11 CUIT 20-17662132-0 NOMBRE MARTIN APELLIDO ARJONA RANKING 0 DOMICILIO None CORREO drrtjdrtfh@ahhtee.com ESTADO True TIPOCLAVE_ID 3 IDTIPOPERSONA 1 DIRECCION  IDLOCALIDAD 1 TELEFONO_CELULAR None ', 'superadmin', 'ID 11 CUIT 20-17662132-0 NOMBRE MARTIN APELLIDO ARJONA RANKING 0 DOMICILIO None CORREO  ESTADO True TIPOCLAVE_ID 3 IDTIPOPERSONA 1 DIRECCION drrtjdrtfh@ahhtee.com IDLOCALIDAD 1 TELEFONO_CELULAR None ', '2021-02-01 19:02:30.514894', 14, 'Proveedor');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (816, 'ID 6 CUIT 30-99924708-9 NOMBRE barselo APELLIDO ricargdino RANKING 0 DOMICILIO None CORREO fdbdn14354315@ahhtee.com ESTADO True TIPOCLAVE_ID 3 IDTIPOPERSONA 1 DIRECCION junin 1649 IDLOCALIDAD None TELEFONO_CELULAR None ', 'superadmin', 'ID 6 CUIT 30-99924708-9 NOMBRE barselo APELLIDO ricargdino RANKING 0 DOMICILIO None CORREO None ESTADO True TIPOCLAVE_ID 3 IDTIPOPERSONA 1 DIRECCION junin 1649 IDLOCALIDAD None TELEFONO_CELULAR None ', '2021-02-01 19:02:46.721226', 14, 'Proveedor');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (817, 'ID 8 CUIT 27-14515511-3 NOMBRE odulio APELLIDO cortez RANKING 0 DOMICILIO None CORREO odulio@ahhtee.com ESTADO False TIPOCLAVE_ID 2 IDTIPOPERSONA 2 DIRECCION  IDLOCALIDAD None TELEFONO_CELULAR None ', 'superadmin', 'ID 8 CUIT 27-14515511-3 NOMBRE odulio APELLIDO cortez RANKING 0 DOMICILIO None CORREO None ESTADO False TIPOCLAVE_ID 2 IDTIPOPERSONA 2 DIRECCION  IDLOCALIDAD None TELEFONO_CELULAR None ', '2021-02-01 19:03:10.394136', 14, 'Proveedor');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (818, 'ID 4 CUIT 20-41091788-3 NOMBRE enrique APELLIDO sand RANKING 0 DOMICILIO None CORREO enrique@ahhtee.com ESTADO True TIPOCLAVE_ID 4 IDTIPOPERSONA 1 DIRECCION casa 55 barrio san justo IDLOCALIDAD 2 TELEFONO_CELULAR None ', 'superadmin', 'ID 4 CUIT 20-41091788-3 NOMBRE enrique APELLIDO sand RANKING 0 DOMICILIO None CORREO None ESTADO True TIPOCLAVE_ID 4 IDTIPOPERSONA 1 DIRECCION casa 55 barrio san justo IDLOCALIDAD 2 TELEFONO_CELULAR None ', '2021-02-01 19:03:22.694503', 14, 'Proveedor');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (819, 'ID 10 CUIT 20-95279133-9 NOMBRE ALSIDIO APELLIDO BENITEZ RANKING 0 DOMICILIO None CORREO ALSIDIO@ahhtee.com ESTADO False TIPOCLAVE_ID 2 IDTIPOPERSONA 1 DIRECCION  IDLOCALIDAD None TELEFONO_CELULAR None ', 'superadmin', 'ID 10 CUIT 20-95279133-9 NOMBRE ALSIDIO APELLIDO BENITEZ RANKING 0 DOMICILIO None CORREO None ESTADO False TIPOCLAVE_ID 2 IDTIPOPERSONA 1 DIRECCION None IDLOCALIDAD None TELEFONO_CELULAR None ', '2021-02-01 19:03:36.106671', 14, 'Proveedor');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (820, 'ID 7 CUIT 27-11077410-4 NOMBRE Uriel APELLIDO Dosantos RANKING 0 DOMICILIO None CORREO Uriel@ahhtee.com ESTADO True TIPOCLAVE_ID 2 IDTIPOPERSONA 1 DIRECCION  IDLOCALIDAD None TELEFONO_CELULAR None ', 'superadmin', 'ID 7 CUIT 27-11077410-4 NOMBRE Uriel APELLIDO Dosantos RANKING 0 DOMICILIO None CORREO None ESTADO True TIPOCLAVE_ID 2 IDTIPOPERSONA 1 DIRECCION  IDLOCALIDAD None TELEFONO_CELULAR None ', '2021-02-01 19:03:54.832707', 14, 'Proveedor');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (821, 'ID 5 CUIT 30-13453456-3 NOMBRE Cortencio APELLIDO Retondo RANKING 0 DOMICILIO None CORREO cortencio@ahhtee.com ESTADO True TIPOCLAVE_ID 2 IDTIPOPERSONA 1 DIRECCION  IDLOCALIDAD None TELEFONO_CELULAR None ', 'superadmin', 'ID 5 CUIT 30-13453456-3 NOMBRE Cortencio APELLIDO Retondo RANKING 0 DOMICILIO None CORREO None ESTADO True TIPOCLAVE_ID 2 IDTIPOPERSONA 1 DIRECCION  IDLOCALIDAD None TELEFONO_CELULAR None ', '2021-02-01 19:04:15.940813', 14, 'Proveedor');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (822, 'ID 36 ESTADO True TOTAL 52000.0 TOTALNETO 52000.0 TOTALIVA 10920.0 FECHA 2021-02-01 PROVEEDOR_ID 9 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 22 ', 'superadmin', '', '2021-02-01 19:25:01.725266', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (823, 'ID 37 ESTADO True TOTAL 28000.0 TOTALNETO 28000.0 TOTALIVA 0.0 FECHA 2021-02-01 PROVEEDOR_ID 5 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 23 ', 'superadmin', '', '2021-02-01 19:26:47.911812', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (824, 'ID 38 ESTADO True TOTAL 14400.0 TOTALNETO 14400.0 TOTALIVA 0.0 FECHA 2021-02-01 PROVEEDOR_ID 11 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 24 ', 'superadmin', '', '2021-02-01 19:27:25.947', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (825, 'ID 39 ESTADO True TOTAL 22700.0 TOTALNETO 22700.0 TOTALIVA 0.0 FECHA 2021-02-01 PROVEEDOR_ID 6 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 25 ', 'superadmin', '', '2021-02-01 19:29:06.861575', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (826, 'ID 40 ESTADO True TOTAL 4800.0 TOTALNETO 4800.0 TOTALIVA 720.0 FECHA 2021-02-01 PROVEEDOR_ID 7 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 26 ', 'superadmin', '', '2021-02-01 19:41:05.093844', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (827, 'ID 41 ESTADO True TOTAL 11600.0 TOTALNETO 11600.0 TOTALIVA 880.0 FECHA 2021-02-01 PROVEEDOR_ID 11 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 27 ', 'superadmin', '', '2021-02-01 19:44:54.261749', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (828, 'ID 42 ESTADO True TOTAL 25000.0 TOTALNETO 25000.0 TOTALIVA 3600.0 FECHA 2021-02-05 PROVEEDOR_ID 9 FORMADEPAGO_ID 2 DATOSFORMAPAGOS_ID 14 PERCEPCION 0.0 COMPROBANTE 28 ', 'superadmin', '', '2021-02-05 19:47:21.51938', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (829, 'ID 43 ESTADO True TOTAL 13050.0 TOTALNETO 13050.0 TOTALIVA 945.0 FECHA 2021-02-05 PROVEEDOR_ID 4 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 29 ', 'superadmin', '', '2021-02-05 19:54:34.076012', 13, 'Compra');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (830, 'ID 49 ESTADO True PRECIO 20.0 STOCK 0 IVA 21.0 UNIDAD_ID 2 MARCAS_ID 53 CATEGORIA_ID 25 MEDIDA 20.0 DETALLE PERA ', 'superadmin', '', '2021-02-10 21:58:15.319198', 13, 'Productos');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (831, 'ID 132 ESTADO True FECHA 2021-02-10 TOTALNETO 2988.7 TOTALIVA 0.0 TOTAL 2988.7 CLIENTE_ID 4490 PERCEPCION 0.0 COMPROBANTE 49 ', 'superadmin', '', '2021-02-10 22:09:01.801163', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (832, 'ID 133 ESTADO True FECHA 2021-02-10 TOTALNETO 563.13 TOTALIVA 0.0 TOTAL 563.13 CLIENTE_ID 4490 PERCEPCION 0.0 COMPROBANTE 50 ', 'superadmin', '', '2021-02-10 22:19:52.408008', 13, 'Venta');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (833, 'ID 12068 DOCUMENTO 20-34937344-4 NOMBRE EITNER  APELLIDO EMILIANO TIPODOCUMENTO_ID 1 TIPOCLAVE_ID 3 IDTIPOPERSONA 1 ESTADO True TELEFONO_CELULAR  DIRECCION  IDLOCALIDAD None ', 'superadmin', '', '2021-02-10 22:30:53.739918', 13, 'Clientes');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (834, 'ID 12069 DOCUMENTO 20-34937344-1 NOMBRE EITNER  APELLIDO EMILIANO TIPODOCUMENTO_ID 2 TIPOCLAVE_ID 3 IDTIPOPERSONA 1 ESTADO True TELEFONO_CELULAR  DIRECCION  IDLOCALIDAD None ', 'superadmin', '', '2021-02-10 22:34:07.321949', 13, 'Clientes');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (835, 'ID 12068 DOCUMENTO 20-34937344-4 NOMBRE EITNER  APELLIDO EMILIANO TIPODOCUMENTO_ID 1 TIPOCLAVE_ID 3 IDTIPOPERSONA 1 ESTADO False TELEFONO_CELULAR  DIRECCION  IDLOCALIDAD None ', 'superadmin', 'ID 12068 DOCUMENTO 20-34937344-4 NOMBRE EITNER  APELLIDO EMILIANO TIPODOCUMENTO_ID 1 TIPOCLAVE_ID 3 IDTIPOPERSONA 1 ESTADO True TELEFONO_CELULAR  DIRECCION  IDLOCALIDAD None ', '2021-02-10 22:34:47.35849', 14, 'Clientes');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (836, 'ID 12069 DOCUMENTO 20-34937344-1 NOMBRE EITNER  APELLIDO EMILIANO TIPODOCUMENTO_ID 2 TIPOCLAVE_ID 3 IDTIPOPERSONA 1 ESTADO True TELEFONO_CELULAR  DIRECCION  IDLOCALIDAD None ', 'superadmin', 'ID 12069 DOCUMENTO 20-34937344-1 NOMBRE EITNER  APELLIDO EMILIANO TIPODOCUMENTO_ID 2 TIPOCLAVE_ID 3 IDTIPOPERSONA 1 ESTADO True TELEFONO_CELULAR  DIRECCION  IDLOCALIDAD None ', '2021-02-10 22:35:38.765966', 14, 'Clientes');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (837, 'ID 12069 DOCUMENTO 20-34937344-1 NOMBRE EITNER  APELLIDO EMILIANO TIPODOCUMENTO_ID 2 TIPOCLAVE_ID 3 IDTIPOPERSONA 1 ESTADO True TELEFONO_CELULAR  DIRECCION  IDLOCALIDAD None ', 'superadmin', 'ID 12069 DOCUMENTO 20-34937344-1 NOMBRE EITNER  APELLIDO EMILIANO TIPODOCUMENTO_ID 2 TIPOCLAVE_ID 3 IDTIPOPERSONA 1 ESTADO True TELEFONO_CELULAR  DIRECCION  IDLOCALIDAD None ', '2021-02-10 22:36:33.123399', 14, 'Clientes');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (838, 'ID 12 CUIT 30-70728547-4 NOMBRE MAVENIC APELLIDO S.R.L RANKING 0 DOMICILIO None CORREO  ESTADO True TIPOCLAVE_ID 2 IDTIPOPERSONA 2 DIRECCION  IDLOCALIDAD 1 TELEFONO_CELULAR None ', 'superadmin', '', '2021-02-10 23:01:20.386097', 13, 'Proveedor');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (839, 'ID 12 CUIT 30-70728547-4 NOMBRE MAVENIC APELLIDO S.R.L RANKING 0 DOMICILIO None CORREO  ESTADO False TIPOCLAVE_ID 2 IDTIPOPERSONA 2 DIRECCION  IDLOCALIDAD 1 TELEFONO_CELULAR None ', 'superadmin', 'ID 12 CUIT 30-70728547-4 NOMBRE MAVENIC APELLIDO S.R.L RANKING 0 DOMICILIO None CORREO  ESTADO True TIPOCLAVE_ID 2 IDTIPOPERSONA 2 DIRECCION  IDLOCALIDAD 1 TELEFONO_CELULAR None ', '2021-02-10 23:02:55.861074', 14, 'Proveedor');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (840, 'ID 12 CUIT 30-70728547-4 NOMBRE MAVENIC APELLIDO S.R.L RANKING 0 DOMICILIO None CORREO  ESTADO True TIPOCLAVE_ID 2 IDTIPOPERSONA 2 DIRECCION  IDLOCALIDAD 1 TELEFONO_CELULAR None ', 'superadmin', 'ID 12 CUIT 30-70728547-4 NOMBRE MAVENIC APELLIDO S.R.L RANKING 0 DOMICILIO None CORREO  ESTADO False TIPOCLAVE_ID 2 IDTIPOPERSONA 2 DIRECCION  IDLOCALIDAD 1 TELEFONO_CELULAR None ', '2021-02-10 23:03:27.928409', 14, 'Proveedor');
INSERT INTO public.auditoria (id, message, username, anterior, created_on, operation_id, target) VALUES (841, 'ID 72 ESTADO False FECHA 2020-11-05 TOTALNETO 3146.0 TOTALIVA 0.0 TOTAL 3146.0 CLIENTE_ID 4491 PERCEPCION 0.0 COMPROBANTE 1 ', 'superadmin', 'ID 72 ESTADO True FECHA 2020-11-05 TOTALNETO 3146.0 TOTALIVA 0.0 TOTAL 3146.0 CLIENTE_ID 4491 PERCEPCION 0.0 COMPROBANTE 1 ', '2021-02-10 23:12:09.240492', 14, 'Venta');


--
-- TOC entry 3682 (class 0 OID 21337)
-- Dependencies: 221
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
INSERT INTO public.categoria (id, categoria) VALUES (13, 'FIDEO');
INSERT INTO public.categoria (id, categoria) VALUES (14, 'ARROZ');
INSERT INTO public.categoria (id, categoria) VALUES (15, 'SAL');
INSERT INTO public.categoria (id, categoria) VALUES (16, 'LECHE');
INSERT INTO public.categoria (id, categoria) VALUES (17, 'ACEITE');
INSERT INTO public.categoria (id, categoria) VALUES (19, 'LAVANDINA');
INSERT INTO public.categoria (id, categoria) VALUES (20, 'AZUCAR');
INSERT INTO public.categoria (id, categoria) VALUES (21, 'MERMELADA');
INSERT INTO public.categoria (id, categoria) VALUES (22, 'TOMATE PERITA');
INSERT INTO public.categoria (id, categoria) VALUES (23, 'CABALLA EN ACEITE');
INSERT INTO public.categoria (id, categoria) VALUES (24, 'CABALLA AL NATURAL');
INSERT INTO public.categoria (id, categoria) VALUES (25, 'JUGO EN POLVO');
INSERT INTO public.categoria (id, categoria) VALUES (26, 'DETERGENTE');
INSERT INTO public.categoria (id, categoria) VALUES (27, 'JAVON EN POLVO');
INSERT INTO public.categoria (id, categoria) VALUES (28, 'JAVON LIQUIDO');
INSERT INTO public.categoria (id, categoria) VALUES (29, 'LENTEJAS');
INSERT INTO public.categoria (id, categoria) VALUES (30, 'MAÍS PISINGALLO');
INSERT INTO public.categoria (id, categoria) VALUES (31, 'POROTOALUBIA');
INSERT INTO public.categoria (id, categoria) VALUES (32, 'ADOBO');
INSERT INTO public.categoria (id, categoria) VALUES (33, 'AZUCAR NEGRA');
INSERT INTO public.categoria (id, categoria) VALUES (34, 'BICARBONATO DE SODIO');
INSERT INTO public.categoria (id, categoria) VALUES (35, 'PIMIENTA NEGRA');
INSERT INTO public.categoria (id, categoria) VALUES (36, 'AJI MOLIDO');
INSERT INTO public.categoria (id, categoria) VALUES (37, 'PESTO');
INSERT INTO public.categoria (id, categoria) VALUES (38, 'CONDIMENTO PARA ARROZ');
INSERT INTO public.categoria (id, categoria) VALUES (39, 'COMINO MOLIDO');
INSERT INTO public.categoria (id, categoria) VALUES (40, 'PIMIENTA BLANCA MOLIDA');
INSERT INTO public.categoria (id, categoria) VALUES (41, 'KETCHUP');
INSERT INTO public.categoria (id, categoria) VALUES (42, 'MOZTAZA');
INSERT INTO public.categoria (id, categoria) VALUES (43, 'POROTOS');
INSERT INTO public.categoria (id, categoria) VALUES (44, 'CHOCLO AMARILLO');
INSERT INTO public.categoria (id, categoria) VALUES (45, 'GARBANZOS');
INSERT INTO public.categoria (id, categoria) VALUES (46, 'CHAMPIÑONES EN TROZO');
INSERT INTO public.categoria (id, categoria) VALUES (47, 'SALSA TIPO PORTUGUESA');
INSERT INTO public.categoria (id, categoria) VALUES (48, 'SALSA DE PIZA');
INSERT INTO public.categoria (id, categoria) VALUES (49, 'FILETO');
INSERT INTO public.categoria (id, categoria) VALUES (50, 'FERNET');
INSERT INTO public.categoria (id, categoria) VALUES (52, 'POROTO ALUBIA');
INSERT INTO public.categoria (id, categoria) VALUES (55, 'DAMASCO');


--
-- TOC entry 3684 (class 0 OID 21342)
-- Dependencies: 223
-- Data for Name: clientes; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado, direccion, idlocalidad, telefono_celular) VALUES (4491, '12153453213', 'german', 'Goicochea', 1, 1, 1, true, '', NULL, '');
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado, direccion, idlocalidad, telefono_celular) VALUES (7735, '25626338', 'MARTIN ', 'SCORCESENs', 1, 3, 1, true, '', 3, '3764247399');
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado, direccion, idlocalidad, telefono_celular) VALUES (2356, '3905508741', 'jorge', 'Delpiano', 1, 1, 1, true, '', NULL, '');
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado, direccion, idlocalidad, telefono_celular) VALUES (4490, '20-94173793-6', 'macro', 'SRL', 2, 2, 2, true, '', NULL, NULL);
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado, direccion, idlocalidad, telefono_celular) VALUES (1, 'Consumidor Final', '', '', 1, 1, 1, true, '', NULL, NULL);
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado, direccion, idlocalidad, telefono_celular) VALUES (4781, '27-04209000-5', 'IPLICSE', 'srl', 2, 2, 2, true, '', NULL, NULL);
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado, direccion, idlocalidad, telefono_celular) VALUES (4227, '65435165', 'arguesto', 'arguellos', 1, 1, 1, true, NULL, NULL, NULL);
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado, direccion, idlocalidad, telefono_celular) VALUES (4210, '355316543', 'Ricardo Ernesto', 'godoy', 1, 1, 1, true, NULL, NULL, NULL);
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado, direccion, idlocalidad, telefono_celular) VALUES (4616, '20-06294674-2', 'Minimercado', 'srl', 2, 2, 2, true, NULL, NULL, NULL);
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado, direccion, idlocalidad, telefono_celular) VALUES (4205, '6546516', 'julia', 'sanchez', 1, 1, 1, true, NULL, NULL, NULL);
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado, direccion, idlocalidad, telefono_celular) VALUES (4, '131618746', 'juan', 'perez', 1, 3, 1, true, NULL, NULL, NULL);
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado, direccion, idlocalidad, telefono_celular) VALUES (4241, '6551656', 'marcelo', 'ramos', 1, 1, 1, false, '', NULL, NULL);
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado, direccion, idlocalidad, telefono_celular) VALUES (4215, '13698478', 'ricardo', 'godoy', 1, 1, 1, true, NULL, NULL, NULL);
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado, direccion, idlocalidad, telefono_celular) VALUES (4274, '5456165457', 'Gerardo', 'Mantizen', 1, 1, 1, true, NULL, NULL, NULL);
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado, direccion, idlocalidad, telefono_celular) VALUES (2357, '253648741', 'virginia', 'rosas', 1, 1, 1, false, NULL, NULL, NULL);
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado, direccion, idlocalidad, telefono_celular) VALUES (4232, '136849875', 'Gerundio', 'ortiz', 1, 1, 1, false, NULL, NULL, NULL);
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado, direccion, idlocalidad, telefono_celular) VALUES (4221, '26521648', 'arguesto', 'aruga', 1, 1, 1, true, NULL, NULL, NULL);
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado, direccion, idlocalidad, telefono_celular) VALUES (637, '27-10255123-6', 'Marcelo', 'Lobardys', 2, 2, 1, true, 'junin 1643', 1, NULL);
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado, direccion, idlocalidad, telefono_celular) VALUES (4428, '30-67242739-4', 'mertin', 'salmone', 2, 4, 1, true, '', 2, NULL);
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado, direccion, idlocalidad, telefono_celular) VALUES (3888, '41091788', 'enrique', 'sand', 1, 1, 1, true, '', NULL, '');
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado, direccion, idlocalidad, telefono_celular) VALUES (12069, '20-34937344-1', 'EITNER ', 'EMILIANO', 2, 3, 1, true, '', NULL, '');
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado, direccion, idlocalidad, telefono_celular) VALUES (12068, '20-34937344-4', 'EITNER ', 'EMILIANO', 1, 3, 1, false, '', NULL, '');


--
-- TOC entry 3704 (class 0 OID 22146)
-- Dependencies: 243
-- Data for Name: companiaTarjeta; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."companiaTarjeta" (id, compania, estado) VALUES (1, 'Visa', true);
INSERT INTO public."companiaTarjeta" (id, compania, estado) VALUES (2, 'Mastercard', true);


--
-- TOC entry 3735 (class 0 OID 105157)
-- Dependencies: 274
-- Data for Name: compras; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (10, true, 10000, 10000, 0, '2020-11-01', 5, 1, NULL, 0, 1);
INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (11, true, 3850, 3850, 0, '2020-11-01', 7, 1, NULL, 0, 2);
INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (12, true, 4500, 4500, 0, '2020-11-01', 4, 1, NULL, 0, 3);
INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (13, true, 11800, 11800, 0, '2020-11-01', 5, 1, NULL, 0, 4);
INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (14, true, 5320, 5320, 0, '2020-11-01', 11, 2, 1, 0, 7);
INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (15, true, 23500, 23500, 0, '2020-12-01', 5, 2, 2, 0, 8);
INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (16, true, 24100, 24100, 0, '2020-12-01', 7, 1, NULL, 0, 9);
INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (18, true, 14400, 14400, 0, '2020-12-01', 11, 2, 4, 0, 10);
INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (19, true, 13800, 13800, 882, '2020-12-01', 9, 1, NULL, 0, 11);
INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (20, true, 28000, 28000, 0, '2020-12-01', 4, 1, NULL, 0, 12);
INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (21, true, 4500, 4500, 0, '2020-12-01', 6, 1, NULL, 0, 13);
INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (25, true, 900, 900, 0, '2021-01-01', 5, 1, NULL, 0, 14);
INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (26, true, 9700, 9700, 0, '2021-01-01', 9, 1, NULL, 0, 15);
INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (27, true, 4200, 4200, 0, '2021-01-01', 11, 1, NULL, 0, 16);
INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (28, true, 14400, 14400, 0, '2021-01-01', 7, 1, NULL, 0, 17);
INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (29, true, 20000, 20000, 0, '2021-01-01', 4, 1, NULL, 0, 18);
INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (33, true, 11400, 11400, 0, '2021-01-01', 6, 2, 11, 0, 19);
INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (34, true, 1600, 1600, 0, '2021-01-01', 7, 2, 12, 0, 20);
INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (35, true, 3900, 3900, 504, '2021-02-01', 5, 2, 13, 0, 21);
INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (36, true, 52000, 52000, 10920, '2021-02-01', 9, 1, NULL, 0, 22);
INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (37, true, 28000, 28000, 0, '2021-02-01', 5, 1, NULL, 0, 23);
INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (38, true, 14400, 14400, 0, '2021-02-01', 11, 1, NULL, 0, 24);
INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (39, true, 22700, 22700, 0, '2021-02-01', 6, 1, NULL, 0, 25);
INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (40, true, 4800, 4800, 720, '2021-02-01', 7, 1, NULL, 0, 26);
INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (41, true, 11600, 11600, 880, '2021-02-01', 11, 1, NULL, 0, 27);
INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (42, true, 25000, 25000, 3600, '2021-02-05', 9, 2, 14, 0, 28);
INSERT INTO public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) VALUES (43, true, 13050, 13050, 945, '2021-02-05', 4, 1, NULL, 0, 29);


--
-- TOC entry 3710 (class 0 OID 104570)
-- Dependencies: 249
-- Data for Name: datosEmpresa; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."datosEmpresa" (id, compania, direccion, cuit, logo, "tipoClave_id", idlocalidad) VALUES (1, 'Kiogestion', 'Avenida Roque Perez, 1522', '20-41091788-3', '0725d5dc-7086-11eb-bbb0-186024bcb2d5_sep_logo_thumb.jpg', 3, NULL);


--
-- TOC entry 3725 (class 0 OID 105036)
-- Dependencies: 264
-- Data for Name: datosFormaPagos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."datosFormaPagos" (id, "numeroCupon", credito, cuotas, "companiaTarjeta_id", formadepago_id) VALUES (8, 448863453, false, 0, 1, 84);
INSERT INTO public."datosFormaPagos" (id, "numeroCupon", credito, cuotas, "companiaTarjeta_id", formadepago_id) VALUES (9, 4453153, false, 0, 2, 94);
INSERT INTO public."datosFormaPagos" (id, "numeroCupon", credito, cuotas, "companiaTarjeta_id", formadepago_id) VALUES (10, 5345368, true, 12, 1, 95);
INSERT INTO public."datosFormaPagos" (id, "numeroCupon", credito, cuotas, "companiaTarjeta_id", formadepago_id) VALUES (11, 3453434, true, 12, 1, 99);
INSERT INTO public."datosFormaPagos" (id, "numeroCupon", credito, cuotas, "companiaTarjeta_id", formadepago_id) VALUES (12, 345134, false, 0, 1, 122);
INSERT INTO public."datosFormaPagos" (id, "numeroCupon", credito, cuotas, "companiaTarjeta_id", formadepago_id) VALUES (13, 434546, true, 24, 2, 134);
INSERT INTO public."datosFormaPagos" (id, "numeroCupon", credito, cuotas, "companiaTarjeta_id", formadepago_id) VALUES (14, 34454, false, 0, 1, 136);
INSERT INTO public."datosFormaPagos" (id, "numeroCupon", credito, cuotas, "companiaTarjeta_id", formadepago_id) VALUES (15, 435343, true, 4, 1, 137);
INSERT INTO public."datosFormaPagos" (id, "numeroCupon", credito, cuotas, "companiaTarjeta_id", formadepago_id) VALUES (16, 4385, false, 0, 2, 141);
INSERT INTO public."datosFormaPagos" (id, "numeroCupon", credito, cuotas, "companiaTarjeta_id", formadepago_id) VALUES (17, 35165654, true, 6, 1, 146);


--
-- TOC entry 3731 (class 0 OID 105119)
-- Dependencies: 270
-- Data for Name: datosFormaPagosCompra; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."datosFormaPagosCompra" (id, "numeroCupon", credito, cuotas, "companiaTarjeta_id", formadepago_id) VALUES (1, 4043315, false, 0, 1, 2);
INSERT INTO public."datosFormaPagosCompra" (id, "numeroCupon", credito, cuotas, "companiaTarjeta_id", formadepago_id) VALUES (2, 428434345, true, 4, 2, 2);
INSERT INTO public."datosFormaPagosCompra" (id, "numeroCupon", credito, cuotas, "companiaTarjeta_id", formadepago_id) VALUES (4, 15346435, false, 0, 1, 2);
INSERT INTO public."datosFormaPagosCompra" (id, "numeroCupon", credito, cuotas, "companiaTarjeta_id", formadepago_id) VALUES (11, 345315, false, 0, 1, 2);
INSERT INTO public."datosFormaPagosCompra" (id, "numeroCupon", credito, cuotas, "companiaTarjeta_id", formadepago_id) VALUES (12, 44345345, false, 0, 1, 2);
INSERT INTO public."datosFormaPagosCompra" (id, "numeroCupon", credito, cuotas, "companiaTarjeta_id", formadepago_id) VALUES (13, 4315, false, 0, 2, 2);
INSERT INTO public."datosFormaPagosCompra" (id, "numeroCupon", credito, cuotas, "companiaTarjeta_id", formadepago_id) VALUES (14, 3448415, false, 0, 2, 2);


--
-- TOC entry 3721 (class 0 OID 104982)
-- Dependencies: 260
-- Data for Name: forma_pago_venta; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (77, 3146, 72, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (79, 3747.9, 74, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (80, 7810.4, 75, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (81, 4374.24, 76, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (82, 251.68, 77, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (83, 2831.4, 78, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (84, 5309.2, 79, 2);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (85, 1085.37, 80, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (86, 1267.89, 81, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (87, 1469.52, 82, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (88, 4797.65, 83, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (89, 1755.52, 84, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (92, 1573, 87, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (93, 25, 88, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (94, 50, 88, 2);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (95, 50.84, 88, 2);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (97, 880.88, 90, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (98, 1000, 91, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (99, 2917.42, 91, 2);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (100, 6864, 92, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (101, 5391.1, 93, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (102, 2167.88, 94, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (106, 2345.2, 98, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (108, 1624.48, 100, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (109, 2831.4, 101, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (110, 3317.6, 102, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (111, 862.29, 103, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (112, 709.28, 104, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (115, 1560.41, 107, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (116, 1596.58, 108, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (117, 547.69, 109, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (118, 1430, 110, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (119, 228.8, 111, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (121, 1415.7, 113, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (122, 5582.72, 114, 2);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (123, 909.74, 115, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (124, 1541.54, 116, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (125, 6921.2, 117, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (126, 707.85, 118, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (127, 5831.02, 119, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (128, 1315.6, 120, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (129, 2981.55, 121, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (130, 865.15, 122, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (131, 2911.48, 123, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (132, 1454.44, 124, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (133, 500, 125, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (134, 593.95, 125, 2);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (135, 1000, 126, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (136, 2000, 126, 2);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (137, 1015.44, 126, 2);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (138, 4994.34, 127, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (139, 3381.95, 128, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (140, 300, 129, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (141, 1072.8, 129, 2);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (143, 18444.14, 131, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (144, 2988.7, 132, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (145, 100, 133, 1);
INSERT INTO public.forma_pago_venta (id, monto, venta_id, formadepago_id) VALUES (146, 463.13, 133, 2);


--
-- TOC entry 3686 (class 0 OID 21377)
-- Dependencies: 225
-- Data for Name: formadepago; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.formadepago (id, "Metodo") VALUES (1, 'Contado');
INSERT INTO public.formadepago (id, "Metodo") VALUES (2, 'Tarjeta');


--
-- TOC entry 3688 (class 0 OID 21382)
-- Dependencies: 227
-- Data for Name: localidad; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.localidad (idlocalidad, localidad) VALUES (1, 'Apostoles');
INSERT INTO public.localidad (idlocalidad, localidad) VALUES (2, 'Posadas');
INSERT INTO public.localidad (idlocalidad, localidad) VALUES (3, 'Obera');


--
-- TOC entry 3690 (class 0 OID 21387)
-- Dependencies: 229
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
INSERT INTO public.marcas (id, marca) VALUES (25, 'AS DE BASTOS');
INSERT INTO public.marcas (id, marca) VALUES (28, 'MANTULAK');
INSERT INTO public.marcas (id, marca) VALUES (29, 'COLOSAL');
INSERT INTO public.marcas (id, marca) VALUES (30, 'ILOLAY');
INSERT INTO public.marcas (id, marca) VALUES (31, 'NATURA');
INSERT INTO public.marcas (id, marca) VALUES (32, 'NATIVO');
INSERT INTO public.marcas (id, marca) VALUES (33, 'AYUDIN');
INSERT INTO public.marcas (id, marca) VALUES (34, 'LEDESMA');
INSERT INTO public.marcas (id, marca) VALUES (35, 'PEPSI');
INSERT INTO public.marcas (id, marca) VALUES (36, 'CRUSH');
INSERT INTO public.marcas (id, marca) VALUES (37, 'KESITAS');
INSERT INTO public.marcas (id, marca) VALUES (38, 'MEDIATARDE');
INSERT INTO public.marcas (id, marca) VALUES (39, 'INDIAS');
INSERT INTO public.marcas (id, marca) VALUES (40, 'DOS ANCLAS');
INSERT INTO public.marcas (id, marca) VALUES (41, 'DANICA');
INSERT INTO public.marcas (id, marca) VALUES (42, 'OKEY');
INSERT INTO public.marcas (id, marca) VALUES (43, 'COINCO');
INSERT INTO public.marcas (id, marca) VALUES (44, 'NOEL');
INSERT INTO public.marcas (id, marca) VALUES (45, 'BRANCA');
INSERT INTO public.marcas (id, marca) VALUES (46, 'CAPRI');
INSERT INTO public.marcas (id, marca) VALUES (47, 'VTTONE');
INSERT INTO public.marcas (id, marca) VALUES (48, 'EMETH');
INSERT INTO public.marcas (id, marca) VALUES (50, 'ONETA');
INSERT INTO public.marcas (id, marca) VALUES (51, 'MARBELLA');
INSERT INTO public.marcas (id, marca) VALUES (53, 'TANG');
INSERT INTO public.marcas (id, marca) VALUES (54, 'ALA');
INSERT INTO public.marcas (id, marca) VALUES (55, 'MAGISTRAL');
INSERT INTO public.marcas (id, marca) VALUES (56, 'ZORRO');
INSERT INTO public.marcas (id, marca) VALUES (57, 'GRAMBLE');
INSERT INTO public.marcas (id, marca) VALUES (58, 'SUSTENTO');


--
-- TOC entry 3706 (class 0 OID 38701)
-- Dependencies: 245
-- Data for Name: modulos_configuracion; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.modulos_configuracion (id, modulo_pedido, dias_pedido, dias_atras, porcentaje_ventas, fecha_vencimiento, modulo_ofertas_whatsapp, dias_oferta, fecha_vencimiento_oferta, porcentaje_subida_precio, twilio_account_sid, twilio_auth_token, descuento) VALUES (1, true, 7, 30, 80, 7, true, 7, 14, 30, 'ACf1f795288eef0800ecd20d4b8baf966f', 'bc1eae95cabc327d5175311b4d1594fb', 15);


--
-- TOC entry 3727 (class 0 OID 105079)
-- Dependencies: 266
-- Data for Name: oferta_whatsapp; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (98, '2021-02-01 19:00:26.600898', '2021-02-01 20:00:26.600898', 24, 4491, 15, 0, 0, 0, 0, 0, 'frzwuyxb', false, false, 68, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (99, '2021-02-01 19:00:29.72308', '2021-02-01 20:00:29.72308', 13, 4491, 15, 0, 0, 0, 0, 0, 'sirzwvfi', false, false, 69, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (100, '2021-02-01 19:00:30.065053', '2021-02-01 20:00:30.065053', 24, 4491, 15, 0, 0, 0, 0, 0, 'vlbqtisa', false, false, 68, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (101, '2021-02-01 19:00:30.670914', '2021-02-01 20:00:30.670914', 13, 2356, 15, 0, 0, 0, 0, 0, 'aeqadwpf', false, false, 69, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (102, '2021-02-01 19:00:31.172835', '2021-02-01 20:00:31.172835', 13, 4491, 15, 0, 0, 0, 0, 0, 'etnvavji', false, false, 69, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (103, '2021-02-01 19:00:31.624248', '2021-02-01 20:00:31.624248', 13, 7735, 15, 0, 0, 0, 0, 0, 'tjoxiikb', false, false, 69, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (104, '2021-02-01 19:00:32.130784', '2021-02-01 20:00:32.130784', 13, 2356, 15, 0, 0, 0, 0, 0, 'fpllxlnx', false, false, 69, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (105, '2021-02-01 19:00:33.080021', '2021-02-01 20:00:33.080021', 13, 7735, 15, 0, 0, 0, 0, 0, 'whkrepdd', false, false, 69, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (106, '2021-02-01 19:00:33.60046', '2021-02-01 20:00:33.60046', 24, 4491, 15, 0, 0, 0, 0, 0, 'qlfioqap', false, false, 68, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (107, '2021-02-01 19:00:34.583426', '2021-02-01 20:00:34.583426', 13, 4491, 15, 0, 0, 0, 0, 0, 'etyiifqr', false, false, 69, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (108, '2021-02-01 19:00:35.531165', '2021-02-01 20:00:35.531165', 13, 2356, 15, 0, 0, 0, 0, 0, 'ndtlaxiy', false, false, 69, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (109, '2021-02-01 19:00:36.507134', '2021-02-01 20:00:36.507134', 13, 7735, 15, 0, 0, 0, 0, 0, 'anepmpcf', false, false, 69, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (110, '2021-02-01 19:00:37.070369', '2021-02-01 20:00:37.070369', 24, 4491, 15, 0, 0, 0, 0, 0, 'jpbeioab', false, false, 68, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (111, '2021-02-01 19:00:38.040953', '2021-02-01 20:00:38.040953', 13, 4491, 15, 0, 0, 0, 0, 0, 'tslquxhx', false, false, 69, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (112, '2021-02-01 19:00:39.022082', '2021-02-01 20:00:39.022082', 13, 2356, 15, 0, 0, 0, 0, 0, 'drmsfncm', false, false, 69, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (113, '2021-02-01 19:00:39.982326', '2021-02-01 20:00:39.982326', 13, 7735, 15, 0, 0, 0, 0, 0, 'foothwwy', false, false, 69, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (114, '2021-02-01 19:00:40.637491', '2021-02-01 20:00:40.637491', 24, 4491, 15, 0, 0, 0, 0, 0, 'urlqgkxj', false, false, 68, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (115, '2021-02-01 19:00:41.564616', '2021-02-01 20:00:41.564616', 13, 4491, 15, 0, 0, 0, 0, 0, 'jtnolikc', false, false, 69, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (116, '2021-02-01 19:00:42.562694', '2021-02-01 20:00:42.562694', 13, 2356, 15, 0, 0, 0, 0, 0, 'xlkmtoff', false, false, 69, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (117, '2021-02-01 19:00:43.52685', '2021-02-01 20:00:43.52685', 13, 7735, 15, 0, 0, 0, 0, 0, 'oslvswwg', false, false, 69, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (118, '2021-02-01 19:00:44.119217', '2021-02-01 20:00:44.119217', 24, 4491, 15, 0, 0, 0, 0, 0, 'dvwmqisa', false, false, 68, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (119, '2021-02-01 19:00:45.045212', '2021-02-01 20:00:45.045212', 13, 4491, 15, 0, 0, 0, 0, 0, 'opiwhvby', false, false, 69, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (120, '2021-02-01 19:00:45.972486', '2021-02-01 20:00:45.972486', 13, 2356, 15, 0, 0, 0, 0, 0, 'fjtfztmw', false, false, 69, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (121, '2021-02-01 19:20:03.76308', '2021-02-01 20:20:03.76308', 24, 4491, 15, 0, 0, 0, 0, 0, 'ljqiekew', false, false, 68, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (122, '2021-02-01 19:20:07.249246', '2021-02-01 20:20:07.249246', 24, 4491, 15, 0, 0, 0, 0, 0, 'azwyuatc', false, false, 68, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (123, '2021-02-01 19:20:10.742879', '2021-02-01 20:20:10.742879', 24, 4491, 15, 0, 0, 0, 0, 0, 'bpwxxlri', false, false, 68, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (124, '2021-02-01 19:20:14.215456', '2021-02-01 20:20:14.215456', 24, 4491, 15, 0, 0, 0, 0, 0, 'yuvxcojq', false, false, 68, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (125, '2021-02-01 19:20:17.729156', '2021-02-01 20:20:17.729156', 24, 4491, 15, 0, 0, 0, 0, 0, 'qnsnnmxa', false, false, 68, false);
INSERT INTO public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id, cancelado) VALUES (126, '2021-02-01 19:20:21.218926', '2021-02-01 20:20:21.218926', 24, 4491, 15, 0, 0, 0, 0, 0, 'otxuuzvi', false, false, 68, false);


--
-- TOC entry 3692 (class 0 OID 21397)
-- Dependencies: 231
-- Data for Name: operacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.operacion (id, name) VALUES (13, 'INSERT');
INSERT INTO public.operacion (id, name) VALUES (14, 'UPDATE');
INSERT INTO public.operacion (id, name) VALUES (15, 'DELETE');


--
-- TOC entry 3717 (class 0 OID 104917)
-- Dependencies: 256
-- Data for Name: pedido_cliente; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.pedido_cliente (id, fecha, expiracion, vendido, hash_activacion, cliente_id, reservado, venta_id, cancelado) VALUES (44, '2021-02-01 19:01:18.532754', '2021-02-01 20:01:18.533798', false, 'rmavngnkigkfino', 7735, false, NULL, false);
INSERT INTO public.pedido_cliente (id, fecha, expiracion, vendido, hash_activacion, cliente_id, reservado, venta_id, cancelado) VALUES (45, '2021-02-01 19:01:24.294899', '2021-02-01 20:01:24.294899', false, 'hjhrsczqldbsbxy', 7735, false, NULL, false);
INSERT INTO public.pedido_cliente (id, fecha, expiracion, vendido, hash_activacion, cliente_id, reservado, venta_id, cancelado) VALUES (46, '2021-02-01 19:01:33.86846', '2021-02-01 20:01:33.86846', false, 'gepcoaumptzqoon', 7735, false, NULL, false);
INSERT INTO public.pedido_cliente (id, fecha, expiracion, vendido, hash_activacion, cliente_id, reservado, venta_id, cancelado) VALUES (47, '2021-02-01 19:01:34.727172', '2021-02-01 20:01:34.727172', false, 'xxaotlysfqabiqw', 7735, false, NULL, false);
INSERT INTO public.pedido_cliente (id, fecha, expiracion, vendido, hash_activacion, cliente_id, reservado, venta_id, cancelado) VALUES (48, '2021-02-01 19:01:44.406226', '2021-02-01 20:01:44.406226', false, 'xvfkbshdqdydefm', 7735, false, NULL, false);
INSERT INTO public.pedido_cliente (id, fecha, expiracion, vendido, hash_activacion, cliente_id, reservado, venta_id, cancelado) VALUES (49, '2021-02-01 19:04:50.076008', '2021-02-01 20:04:50.076008', false, 'dmmsmaantjjrkqd', 7735, false, NULL, false);
INSERT INTO public.pedido_cliente (id, fecha, expiracion, vendido, hash_activacion, cliente_id, reservado, venta_id, cancelado) VALUES (50, '2021-02-01 19:04:51.221517', '2021-02-01 20:04:51.221517', false, 'glzymqyfikkcaez', 7735, false, NULL, false);
INSERT INTO public.pedido_cliente (id, fecha, expiracion, vendido, hash_activacion, cliente_id, reservado, venta_id, cancelado) VALUES (51, '2021-02-01 19:04:52.47502', '2021-02-01 20:04:52.47502', false, 'lyrsmmytrighjdo', 7735, false, NULL, false);
INSERT INTO public.pedido_cliente (id, fecha, expiracion, vendido, hash_activacion, cliente_id, reservado, venta_id, cancelado) VALUES (52, '2021-02-01 19:04:55.529924', '2021-02-01 20:04:55.529924', false, 'klyktbqigsdyqlw', 7735, false, NULL, false);
INSERT INTO public.pedido_cliente (id, fecha, expiracion, vendido, hash_activacion, cliente_id, reservado, venta_id, cancelado) VALUES (55, '2021-02-01 19:04:58.933867', '2021-02-01 20:04:58.933867', false, 'zvvqnsbqjlobnke', 7735, false, NULL, false);
INSERT INTO public.pedido_cliente (id, fecha, expiracion, vendido, hash_activacion, cliente_id, reservado, venta_id, cancelado) VALUES (56, '2021-02-01 19:05:00.31456', '2021-02-01 20:05:00.31456', false, 'mtiyofsybyebuge', 7735, false, NULL, false);
INSERT INTO public.pedido_cliente (id, fecha, expiracion, vendido, hash_activacion, cliente_id, reservado, venta_id, cancelado) VALUES (53, '2021-02-01 19:04:56.158788', '2021-02-01 20:04:56.158788', false, 'dqupdhuvglnqmzl', 7735, true, NULL, false);
INSERT INTO public.pedido_cliente (id, fecha, expiracion, vendido, hash_activacion, cliente_id, reservado, venta_id, cancelado) VALUES (54, '2021-02-01 19:04:57.188083', '2021-02-01 20:04:57.188083', false, 'praucxsbdxuqbhv', 7735, true, NULL, false);


--
-- TOC entry 3713 (class 0 OID 104869)
-- Dependencies: 252
-- Data for Name: pedido_proveedor; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.pedido_proveedor (id, fecha, proveedor_id) VALUES (1, '2020-12-27 18:09:12.29223', 9);
INSERT INTO public.pedido_proveedor (id, fecha, proveedor_id) VALUES (2, '2020-12-27 18:09:16.658821', 9);
INSERT INTO public.pedido_proveedor (id, fecha, proveedor_id) VALUES (3, '2020-12-27 18:09:19.093506', 9);
INSERT INTO public.pedido_proveedor (id, fecha, proveedor_id) VALUES (4, '2021-02-01 19:20:03.869639', 5);
INSERT INTO public.pedido_proveedor (id, fecha, proveedor_id) VALUES (5, '2021-02-01 19:20:07.389871', 5);
INSERT INTO public.pedido_proveedor (id, fecha, proveedor_id) VALUES (6, '2021-02-01 19:20:10.880676', 5);
INSERT INTO public.pedido_proveedor (id, fecha, proveedor_id) VALUES (7, '2021-02-01 19:20:14.401979', 5);
INSERT INTO public.pedido_proveedor (id, fecha, proveedor_id) VALUES (8, '2021-02-01 19:20:17.903205', 5);
INSERT INTO public.pedido_proveedor (id, fecha, proveedor_id) VALUES (9, '2021-02-01 19:20:21.348102', 5);


--
-- TOC entry 3708 (class 0 OID 38876)
-- Dependencies: 247
-- Data for Name: productos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (22, true, 260, 50, 21, 1, 8, 2, 1, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (44, true, 104, 85, 20, 5, 55, 26, 300, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (14, true, 390, 39, 21, 1, 32, 4, 1, 'TINTO');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (15, true, 390, 74, 21, 1, 32, 4, 1, 'BLANCO');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (28, true, 52, 20, 11, 2, 40, 35, 25, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (42, true, 39, 40, 20, 2, 53, 25, 20, 'NARANJA');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (32, true, 156, 50, 20, 2, 48, 21, 390, 'Frambueza');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (35, true, 156, 50, 20, 2, 44, 21, 390, 'CIRUELA');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (4, true, 117, 29, 10, 2, 13, 13, 500, 'SOPERO');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (34, true, 156, 50, 20, 2, 44, 21, 390, 'NARANJA');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (5, true, 195, 28, 20, 2, 3, 1, 500, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (33, true, 182, 50, 20, 2, 48, 21, 450, 'FRUTOS DEL BOSQUE');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (9, true, 65, 50, 21, 2, 4, 11, 500, 'LEUDANTE');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (3, true, 117, 71, 10, 2, 13, 13, 500, 'TIRABUZON');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (6, true, 390, 43, 10, 3, 3, 1, 1, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (12, true, 65, 133, 21, 1, 30, 16, 1, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (7, true, 104, 50, 10, 2, 25, 1, 250, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (49, true, 20, 0, 21, 2, 53, 25, 20, 'PERA');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (25, true, 143, 128, 21, 2, 39, 32, 25, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (24, true, 52, 9, 21, 2, 38, 3, 330, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (2, true, 117, 4, 10, 2, 13, 13, 500, 'CODITO');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (26, true, 143, 120, 21, 2, 40, 33, 80, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (30, true, 143, 173, 21, 2, 39, 39, 50, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (20, true, 104, 100, 0, 1, 5, 2, 1, 'LIGTH');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (19, true, 104, 77, 21, 1, 5, 2, 1, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (18, true, 260, 64, 21, 1, 2, 2, 2, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (31, false, 0, 0, 21, 2, 1, 1, 300, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (13, true, 104, 98, 21, 5, 31, 17, 900, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (37, true, 156, 30, 20, 2, 51, 23, 300, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (38, true, 195, 29, 20, 2, 43, 24, 230, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (23, true, 52, 62, 21, 2, 6, 3, 125, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (8, false, 0, 0, 12, 3, 4, 11, 1, '000');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (1, true, 117, 36, 10, 2, 13, 13, 500, 'ESPAGUETI');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (17, true, 52, 35, 21, 4, 34, 20, 1, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (27, true, 78, 46, 21, 2, 40, 34, 250, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (43, true, 104, 65, 10, 5, 54, 26, 700, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (11, true, 104, 0, 21, 3, 29, 15, 1, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (45, true, 104, 120, 10, 5, 56, 26, 300, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (29, true, 65, 30, 21, 2, 39, 37, 25, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (36, true, 156, 20, 20, 2, 44, 22, 390, 'ENTERO');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (39, true, 39, 40, 20, 2, 53, 25, 20, 'MANZANA');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (40, true, 39, 40, 20, 2, 53, 25, 20, 'LIMON');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (46, true, 143, 40, 20, 2, 54, 27, 800, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (47, true, 78, 40, 21, 2, 54, 27, 400, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (48, true, 78, 80, 20, 2, 56, 27, 800, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (16, true, 78, 40, 21, 1, 33, 19, 1, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (10, true, 143, 257, 21, 3, 28, 14, 1, '');


--
-- TOC entry 3693 (class 0 OID 21405)
-- Dependencies: 232
-- Data for Name: proveedor; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.proveedor (id, cuit, nombre, apellido, domicilio, estado, "tipoClave_id", "idTipoPersona", ranking, idlocalidad, direccion, telefono_celular, correo) VALUES (9, '27-06690501-8', 'SILVIA', 'BEATRIZ', NULL, true, 4, 1, 0, NULL, '', NULL, 'tihaja4589@ahhtee.com');
INSERT INTO public.proveedor (id, cuit, nombre, apellido, domicilio, estado, "tipoClave_id", "idTipoPersona", ranking, idlocalidad, direccion, telefono_celular, correo) VALUES (11, '20-17662132-0', 'MARTIN', 'ARJONA', NULL, true, 3, 1, 0, 1, '', NULL, 'drrtjdrtfh@ahhtee.com');
INSERT INTO public.proveedor (id, cuit, nombre, apellido, domicilio, estado, "tipoClave_id", "idTipoPersona", ranking, idlocalidad, direccion, telefono_celular, correo) VALUES (6, '30-99924708-9', 'barselo', 'ricargdino', NULL, true, 3, 1, 0, NULL, 'junin 1649', NULL, 'fdbdn14354315@ahhtee.com');
INSERT INTO public.proveedor (id, cuit, nombre, apellido, domicilio, estado, "tipoClave_id", "idTipoPersona", ranking, idlocalidad, direccion, telefono_celular, correo) VALUES (8, '27-14515511-3', 'odulio', 'cortez', NULL, false, 2, 2, 0, NULL, '', NULL, 'odulio@ahhtee.com');
INSERT INTO public.proveedor (id, cuit, nombre, apellido, domicilio, estado, "tipoClave_id", "idTipoPersona", ranking, idlocalidad, direccion, telefono_celular, correo) VALUES (4, '20-41091788-3', 'enrique', 'sand', NULL, true, 4, 1, 0, 2, 'casa 55 barrio san justo', NULL, 'enrique@ahhtee.com');
INSERT INTO public.proveedor (id, cuit, nombre, apellido, domicilio, estado, "tipoClave_id", "idTipoPersona", ranking, idlocalidad, direccion, telefono_celular, correo) VALUES (10, '20-95279133-9', 'ALSIDIO', 'BENITEZ', NULL, false, 2, 1, 0, NULL, '', NULL, 'ALSIDIO@ahhtee.com');
INSERT INTO public.proveedor (id, cuit, nombre, apellido, domicilio, estado, "tipoClave_id", "idTipoPersona", ranking, idlocalidad, direccion, telefono_celular, correo) VALUES (7, '27-11077410-4', 'Uriel', 'Dosantos', NULL, true, 2, 1, 0, NULL, '', NULL, 'Uriel@ahhtee.com');
INSERT INTO public.proveedor (id, cuit, nombre, apellido, domicilio, estado, "tipoClave_id", "idTipoPersona", ranking, idlocalidad, direccion, telefono_celular, correo) VALUES (5, '30-13453456-3', 'Cortencio', 'Retondo', NULL, true, 2, 1, 0, NULL, '', NULL, 'cortencio@ahhtee.com');
INSERT INTO public.proveedor (id, cuit, nombre, apellido, domicilio, estado, "tipoClave_id", "idTipoPersona", ranking, idlocalidad, direccion, telefono_celular, correo) VALUES (12, '30-70728547-4', 'MAVENIC', 'S.R.L', NULL, true, 2, 2, 0, 1, '', NULL, '');


--
-- TOC entry 3733 (class 0 OID 105139)
-- Dependencies: 272
-- Data for Name: renglon; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (52, 125.84, 10, 72, 13, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (53, 94.38, 20, 72, 25, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (55, 218.4, 15, 74, 37, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (56, 47.19, 10, 74, 26, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (57, 125.84, 10, 75, 11, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (58, 187.2, 10, 75, 35, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (59, 234, 20, 75, 5, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (60, 114.4, 12, 76, 1, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (61, 62.92, 12, 76, 24, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (62, 187.2, 12, 76, 35, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (63, 125.84, 2, 77, 13, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (64, 62.92, 15, 78, 24, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (65, 125.84, 15, 78, 11, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (66, 187.2, 20, 79, 35, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (67, 234, 4, 79, 5, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (68, 125.84, 5, 79, 13, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (69, 125.84, 1, 80, 13, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (70, 173.03, 2, 80, 10, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (71, 204.49, 3, 80, 12, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (72, 187.2, 4, 81, 35, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (73, 173.03, 3, 81, 10, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (74, 94.38, 4, 82, 25, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (75, 218.4, 5, 82, 37, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (76, 204.49, 5, 83, 12, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (77, 125.84, 30, 83, 13, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (78, 125.84, 4, 84, 13, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (79, 187.2, 4, 84, 35, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (80, 125.84, 4, 84, 11, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (81, 62.92, 3, 87, 24, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (82, 125.84, 11, 87, 11, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (83, 125.84, 1, 88, 13, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (84, 125.84, 7, 90, 13, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (85, 182, 10, 91, 12, 5);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (86, 156, 10, 91, 19, 5);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (87, 114.4, 30, 92, 1, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (88, 114.4, 30, 92, 7, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (89, 204.49, 10, 93, 22, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (90, 220.22, 10, 93, 10, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (91, 114.4, 10, 93, 7, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (92, 220.22, 4, 94, 10, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (93, 143, 5, 94, 4, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (94, 114.4, 5, 94, 7, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (95, 62.92, 30, 98, 25, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (96, 114.4, 4, 98, 7, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (98, 125.84, 12, 100, 17, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (99, 114.4, 1, 100, 7, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (100, 125.84, 3, 101, 26, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (101, 204.49, 12, 101, 22, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (102, 188.76, 10, 102, 19, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (103, 143, 10, 102, 2, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (104, 114.4, 3, 103, 1, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (105, 94.38, 3, 103, 27, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (106, 78.65, 3, 103, 30, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (107, 114.4, 4, 104, 1, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (108, 125.84, 2, 104, 17, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (109, 62.92, 6, 107, 25, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (110, 114.4, 11, 107, 1, 6);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (111, 204.49, 7, 108, 22, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (112, 55.05, 3, 108, 23, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (113, 114.4, 3, 109, 3, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (114, 204.49, 1, 109, 22, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (115, 143, 10, 110, 2, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (116, 114.4, 2, 111, 3, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (117, 141.57, 10, 113, 25, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (118, 62.92, 5, 114, 17, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (119, 173.03, 4, 114, 10, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (120, 114.4, 40, 114, 43, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (121, 78, 1, 115, 44, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (122, 220.22, 1, 115, 12, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (123, 234, 1, 115, 5, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (124, 377.52, 1, 115, 18, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (125, 78.65, 2, 116, 26, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (126, 314.6, 2, 116, 15, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (127, 377.52, 2, 116, 18, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (128, 173.03, 40, 117, 10, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (129, 78.65, 10, 118, 26, 10);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (130, 128.7, 43, 119, 4, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (131, 234, 1, 119, 38, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (132, 62.92, 1, 119, 24, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (133, 114.4, 5, 120, 43, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (134, 62.92, 5, 120, 23, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (135, 429, 1, 120, 6, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (136, 78.65, 3, 121, 30, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (137, 377.52, 5, 121, 18, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (138, 429, 2, 121, 6, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (139, 62.92, 6, 122, 17, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (140, 78.65, 1, 122, 30, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (141, 94.38, 1, 122, 27, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (142, 314.6, 1, 122, 14, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (143, 128.7, 6, 123, 2, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (144, 188.76, 3, 123, 19, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (145, 314.6, 3, 123, 15, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (146, 62.92, 10, 123, 23, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (147, 78, 4, 124, 44, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (148, 220.22, 2, 124, 12, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (149, 234, 3, 124, 5, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (150, 78.65, 5, 125, 26, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (151, 128.7, 3, 125, 4, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (152, 314.6, 1, 125, 15, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (153, 128.7, 4, 126, 1, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (154, 220.22, 12, 126, 12, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (155, 429, 2, 126, 6, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (156, 377.52, 8, 127, 18, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (157, 234, 4, 127, 5, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (158, 220.22, 4, 127, 12, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (159, 78.65, 2, 127, 26, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (160, 78.65, 43, 128, 26, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (161, 128.7, 4, 129, 3, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (162, 429, 2, 129, 6, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (166, 314.6, 40, 131, 14, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (167, 62.92, 70, 131, 24, 40);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (168, 128.7, 50, 131, 2, 50);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (169, 125.84, 10, 132, 13, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (170, 173.03, 10, 132, 25, 0);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (171, 173.03, 2, 133, 25, 10);
INSERT INTO public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) VALUES (172, 125.84, 2, 133, 13, 0);


--
-- TOC entry 3737 (class 0 OID 105184)
-- Dependencies: 276
-- Data for Name: renglon_compras; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (61, 90, 40, 28, 1, 0, '2021-01-04', false, 36, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (77, 80, 50, 37, 20, 0, NULL, false, 50, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (78, 80, 50, 37, 19, 0, NULL, false, 50, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (22, 60, 30, 11, 25, 0, NULL, true, 0, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (36, 240, 30, 16, 18, 0, NULL, false, 14, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (23, 30, 15, 11, 26, 0, NULL, true, 0, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (24, 150, 30, 12, 5, 0, NULL, true, 0, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (33, 150, 30, 15, 5, 0, NULL, false, 28, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (20, 110, 40, 10, 10, 0, NULL, true, 0, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (31, 80, 50, 15, 7, 0, '2021-02-22', true, 0, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (46, 140, 100, 20, 12, 0, NULL, false, 83, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (47, 140, 100, 20, 10, 0, NULL, false, 77, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (79, 200, 50, 37, 18, 0, NULL, false, 50, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (45, 80, 60, 19, 26, 0, NULL, true, 0, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (41, 100, 40, 18, 4, 0, NULL, true, 0, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (38, 80, 40, 18, 3, 0, '2020-12-02', false, 31, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (32, 300, 50, 15, 6, 0, '2020-12-15', false, 43, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (66, 150, 30, 33, 38, 0, NULL, false, 29, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (50, 40, 30, 21, 25, 0, NULL, true, 0, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (39, 80, 40, 18, 1, 0, '2020-12-14', true, 0, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (80, 200, 50, 37, 22, 0, NULL, false, 50, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (52, 80, 50, 26, 43, 0, NULL, false, 5, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (37, 130, 30, 16, 22, 0, NULL, true, 0, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (81, 80, 60, 38, 43, 0, NULL, false, 60, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (28, 140, 20, 14, 37, 0, '2020-11-18', true, 0, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (82, 80, 60, 38, 44, 0, NULL, false, 60, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (19, 140, 40, 10, 13, 0, '2020-11-04', true, 0, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (83, 80, 60, 38, 45, 0, NULL, false, 60, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (26, 120, 50, 13, 35, 0, NULL, true, 0, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (30, 40, 30, 14, 24, 10, NULL, true, 0, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (25, 80, 40, 13, 11, 0, NULL, true, 0, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (84, 300, 30, 39, 14, 0, NULL, false, 30, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (34, 140, 50, 16, 20, 0, NULL, false, 50, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (85, 300, 30, 39, 15, 0, NULL, false, 30, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (54, 70, 60, 26, 45, 0, NULL, false, 60, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (86, 50, 30, 39, 29, 0, NULL, false, 30, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (55, 60, 40, 27, 27, 0, NULL, false, 40, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (21, 80, 20, 11, 13, 0, '2021-01-31', true, 0, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (62, 200, 50, 29, 14, 0, NULL, false, 9, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (87, 120, 20, 39, 36, 0, NULL, false, 20, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (29, 80, 20, 14, 1, 10, NULL, true, 0, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (88, 40, 20, 39, 28, 0, NULL, false, 20, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (56, 40, 20, 27, 17, 0, NULL, false, 20, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (89, 30, 40, 40, 39, 0, NULL, false, 40, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (49, 50, 30, 21, 30, 0, NULL, false, 23, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (90, 30, 40, 40, 40, 0, NULL, false, 40, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (57, 50, 20, 27, 26, 0, NULL, false, 20, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (58, 90, 40, 28, 3, 0, '2021-01-12', false, 40, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (91, 30, 40, 40, 42, 0, NULL, false, 40, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (65, 120, 30, 33, 37, 0, NULL, false, 30, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (64, 110, 30, 33, 10, 0, '2021-03-22', false, 30, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (67, 40, 20, 34, 23, 0, '2021-01-04', false, 20, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (51, 90, 10, 25, 25, 0, NULL, true, 0, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (43, 35, 60, 19, 24, 0, NULL, true, 0, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (92, 30, 40, 40, 48, 0, NULL, false, 40, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (40, 100, 40, 18, 2, 0, NULL, true, 0, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (59, 90, 40, 28, 2, 0, NULL, false, 4, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (93, 110, 40, 41, 46, 0, NULL, false, 40, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (94, 60, 40, 41, 47, 0, NULL, false, 40, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (35, 120, 50, 16, 19, 0, NULL, false, 27, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (95, 60, 40, 41, 48, 0, NULL, false, 40, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (42, 35, 60, 19, 23, 0, '2021-01-31', false, 42, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (53, 50, 30, 26, 44, 0, NULL, false, 25, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (27, 130, 20, 13, 12, 0, NULL, true, 0, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (96, 60, 40, 41, 16, 0, NULL, false, 40, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (98, 120, 50, 42, 35, 0, NULL, false, 50, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (60, 90, 40, 28, 4, 0, NULL, false, 29, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (63, 200, 50, 29, 15, 0, NULL, false, 44, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (71, 30, 50, 35, 30, 0, '2021-02-03', false, 50, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (68, 40, 20, 34, 24, 0, '2021-02-09', false, 9, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (44, 80, 60, 19, 17, 0, NULL, false, 15, 47);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (48, 60, 30, 21, 27, 0, NULL, false, 6, 48);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (69, 80, 20, 35, 13, 0, '2021-02-08', true, 0, 49);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (73, 110, 100, 36, 10, 0, NULL, false, 100, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (74, 110, 100, 36, 26, 0, NULL, false, 100, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (75, 110, 100, 36, 30, 0, NULL, false, 100, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (97, 120, 50, 42, 32, 0, '2021-02-23', false, 50, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (100, 140, 50, 42, 33, 0, '2021-02-26', false, 50, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (99, 120, 50, 42, 34, 0, '2021-02-27', false, 50, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (101, 50, 50, 43, 9, 10, NULL, false, 50, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (103, 110, 50, 43, 10, 10, NULL, false, 50, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (104, 80, 50, 43, 7, 10, NULL, false, 50, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (102, 50, 50, 43, 12, 10, '2021-02-15', false, 50, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (70, 40, 20, 35, 25, 0, NULL, false, 10, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (76, 110, 100, 36, 25, 0, NULL, false, 98, NULL);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote, "renglonPedidoWhatsapp_id") VALUES (72, 80, 100, 36, 13, 0, NULL, false, 88, NULL);


--
-- TOC entry 3719 (class 0 OID 104937)
-- Dependencies: 258
-- Data for Name: renglon_pedido; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.renglon_pedido (id, cantidad, pedido_proveedor_id, producto_id) VALUES (1, 60, 1, 23);
INSERT INTO public.renglon_pedido (id, cantidad, pedido_proveedor_id, producto_id) VALUES (2, 60, 2, 23);
INSERT INTO public.renglon_pedido (id, cantidad, pedido_proveedor_id, producto_id) VALUES (3, 60, 3, 23);
INSERT INTO public.renglon_pedido (id, cantidad, pedido_proveedor_id, producto_id) VALUES (4, 50, 4, 30);
INSERT INTO public.renglon_pedido (id, cantidad, pedido_proveedor_id, producto_id) VALUES (5, 40, 4, 13);
INSERT INTO public.renglon_pedido (id, cantidad, pedido_proveedor_id, producto_id) VALUES (6, 50, 5, 30);
INSERT INTO public.renglon_pedido (id, cantidad, pedido_proveedor_id, producto_id) VALUES (7, 40, 5, 13);
INSERT INTO public.renglon_pedido (id, cantidad, pedido_proveedor_id, producto_id) VALUES (8, 50, 6, 30);
INSERT INTO public.renglon_pedido (id, cantidad, pedido_proveedor_id, producto_id) VALUES (9, 40, 6, 13);
INSERT INTO public.renglon_pedido (id, cantidad, pedido_proveedor_id, producto_id) VALUES (10, 50, 7, 30);
INSERT INTO public.renglon_pedido (id, cantidad, pedido_proveedor_id, producto_id) VALUES (11, 40, 7, 13);
INSERT INTO public.renglon_pedido (id, cantidad, pedido_proveedor_id, producto_id) VALUES (12, 50, 8, 30);
INSERT INTO public.renglon_pedido (id, cantidad, pedido_proveedor_id, producto_id) VALUES (13, 40, 8, 13);
INSERT INTO public.renglon_pedido (id, cantidad, pedido_proveedor_id, producto_id) VALUES (14, 50, 9, 30);
INSERT INTO public.renglon_pedido (id, cantidad, pedido_proveedor_id, producto_id) VALUES (15, 40, 9, 13);


--
-- TOC entry 3723 (class 0 OID 105018)
-- Dependencies: 262
-- Data for Name: renglon_pedido_whatsapp; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.renglon_pedido_whatsapp (id, "precioVenta", cantidad, pedidocliente_id, producto_id, descuento) VALUES (46, 125.84, 10, 53, 13, 0);
INSERT INTO public.renglon_pedido_whatsapp (id, "precioVenta", cantidad, pedidocliente_id, producto_id, descuento) VALUES (47, 62.92, 20, 54, 17, 0);
INSERT INTO public.renglon_pedido_whatsapp (id, "precioVenta", cantidad, pedidocliente_id, producto_id, descuento) VALUES (48, 94.38, 20, 54, 27, 0);
INSERT INTO public.renglon_pedido_whatsapp (id, "precioVenta", cantidad, pedidocliente_id, producto_id, descuento) VALUES (49, 125.84, 10, 54, 13, 0);


--
-- TOC entry 3700 (class 0 OID 21855)
-- Dependencies: 239
-- Data for Name: tipoPersona; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."tipoPersona" ("idTipoPersona", "tipoPersona") VALUES (1, 'Fisica');
INSERT INTO public."tipoPersona" ("idTipoPersona", "tipoPersona") VALUES (2, 'Juridica');


--
-- TOC entry 3702 (class 0 OID 21865)
-- Dependencies: 241
-- Data for Name: tiposClave; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."tiposClave" (id, "tipoClave") VALUES (1, 'Consumidor Final');
INSERT INTO public."tiposClave" (id, "tipoClave") VALUES (2, 'Responsable Inscripto');
INSERT INTO public."tiposClave" (id, "tipoClave") VALUES (3, 'Monotributista');
INSERT INTO public."tiposClave" (id, "tipoClave") VALUES (4, 'Exento');


--
-- TOC entry 3695 (class 0 OID 21436)
-- Dependencies: 234
-- Data for Name: tiposDocumentos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."tiposDocumentos" (id, "tipoDocumento") VALUES (1, 'DNI');
INSERT INTO public."tiposDocumentos" (id, "tipoDocumento") VALUES (2, 'CUIT');


--
-- TOC entry 3697 (class 0 OID 21441)
-- Dependencies: 236
-- Data for Name: unidad_medida; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.unidad_medida (id, unidad) VALUES (1, 'LITRO');
INSERT INTO public.unidad_medida (id, unidad) VALUES (2, 'GRAMOS');
INSERT INTO public.unidad_medida (id, unidad) VALUES (3, 'KILO');
INSERT INTO public.unidad_medida (id, unidad) VALUES (4, 'MILILITRO');
INSERT INTO public.unidad_medida (id, unidad) VALUES (5, 'CC');
INSERT INTO public.unidad_medida (id, unidad) VALUES (6, 'CL');


--
-- TOC entry 3715 (class 0 OID 104882)
-- Dependencies: 254
-- Data for Name: ventas; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (74, true, '2020-11-05', 3747.9, 0, 3747.9, 7735, 0, 2);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (75, true, '2020-11-10', 7810.4, 0, 7810.4, 4428, 0, 3);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (76, true, '2020-11-10', 4374.24, 0, 4374.24, 4274, 0, 4);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (77, true, '2020-11-10', 251.68, 0, 251.68, 2356, 0, 5);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (78, true, '2020-11-10', 2831.4, 0, 2831.4, 4490, 0, 6);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (79, true, '2020-11-15', 5309.2, 0, 5309.2, 4491, 0, 7);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (80, true, '2020-11-15', 1085.37, 0, 1085.37, 4221, 0, 8);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (81, true, '2020-11-15', 1267.89, 0, 1267.89, 4, 0, 9);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (82, true, '2020-11-15', 1469.52, 0, 1469.52, 4205, 0, 10);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (83, true, '2020-11-15', 4797.65, 0, 4797.65, 4221, 0, 11);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (84, true, '2020-11-25', 1755.52, 0, 1755.52, 637, 0, 12);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (87, true, '2020-11-25', 1573, 0, 1573, 4490, 0, 13);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (88, true, '2020-12-10', 125.84, 0, 125.84, 7735, 0, 14);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (90, true, '2020-12-10', 880.88, 0, 880.88, 4428, 0, 15);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (91, true, '2020-12-10', 3211, 674.31, 3917.42, 4490, 1, 16);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (92, true, '2020-12-10', 6864, 0, 6864, 7735, 0, 17);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (93, true, '2020-12-10', 5391.1, 0, 5391.1, 2356, 0, 18);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (94, true, '2020-12-10', 2167.88, 0, 2167.88, 4, 0, 19);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (98, true, '2020-12-10', 2345.2, 0, 2345.2, 1, 0, 20);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (100, true, '2020-12-20', 1624.48, 0, 1624.48, 4491, 0, 21);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (101, true, '2020-12-20', 2831.4, 0, 2831.4, 4781, 0, 22);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (102, true, '2020-12-20', 3317.6, 0, 3317.6, 4491, 0, 23);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (103, true, '2020-12-20', 862.29, 0, 862.29, 4428, 0, 24);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (104, true, '2020-12-20', 709.28, 0, 709.28, 4215, 0, 25);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (107, true, '2020-12-20', 1560.41, 0, 1560.41, 4616, 0, 26);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (108, true, '2020-12-27', 1596.58, 0, 1596.58, 3888, 0, 27);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (109, true, '2020-12-27', 547.69, 0, 547.69, 4205, 0, 28);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (110, true, '2020-12-27', 1430, 0, 1430, 1, 0, 29);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (111, true, '2020-12-27', 228.8, 0, 228.8, 1, 0, 30);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (113, true, '2021-01-11', 1415.7, 0, 1415.7, 4491, 0, 31);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (114, true, '2021-01-11', 5582.72, 0, 5582.72, 7735, 0, 32);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (115, true, '2021-01-11', 909.74, 0, 909.74, 2356, 0, 33);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (116, true, '2021-01-11', 1541.54, 0, 1541.54, 1, 0, 34);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (117, true, '2021-01-11', 6921.2, 0, 6921.2, 4428, 0, 35);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (118, true, '2021-01-11', 707.85, 0, 707.85, 4221, 0, 36);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (119, true, '2021-01-11', 5831.02, 0, 5831.02, 4274, 0, 37);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (120, true, '2021-01-11', 1315.6, 0, 1315.6, 7735, 0, 38);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (121, true, '2021-01-11', 2981.55, 0, 2981.55, 1, 0, 39);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (122, true, '2021-01-11', 865.15, 0, 865.15, 4210, 0, 40);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (123, true, '2021-01-20', 2911.48, 0, 2911.48, 4490, 0, 41);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (124, true, '2021-01-20', 1454.44, 0, 1454.44, 4491, 0, 42);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (125, true, '2021-01-20', 1093.95, 0, 1093.95, 4205, 0, 43);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (126, true, '2021-01-20', 4015.44, 0, 4015.44, 4491, 0, 44);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (127, true, '2021-01-20', 4994.34, 0, 4994.34, 1, 0, 45);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (128, true, '2021-01-27', 3381.95, 0, 3381.95, 4428, 0, 46);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (129, true, '2021-01-27', 1372.8, 0, 1372.8, 4274, 0, 47);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (131, true, '2021-02-01', 18444.14, 0, 18444.14, 4491, 0, 48);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (132, true, '2021-02-10', 2988.7, 0, 2988.7, 4490, 0, 49);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (133, true, '2021-02-10', 563.13, 0, 563.13, 4490, 0, 50);
INSERT INTO public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) VALUES (72, false, '2020-11-05', 3146, 0, 3146, 4491, 0, 1);


--
-- TOC entry 3772 (class 0 OID 0)
-- Dependencies: 205
-- Name: ab_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_permission_id_seq', 60, true);


--
-- TOC entry 3773 (class 0 OID 0)
-- Dependencies: 207
-- Name: ab_permission_view_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_permission_view_id_seq', 614, true);


--
-- TOC entry 3774 (class 0 OID 0)
-- Dependencies: 209
-- Name: ab_permission_view_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_permission_view_role_id_seq', 679, true);


--
-- TOC entry 3775 (class 0 OID 0)
-- Dependencies: 211
-- Name: ab_register_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_register_user_id_seq', 33, true);


--
-- TOC entry 3776 (class 0 OID 0)
-- Dependencies: 213
-- Name: ab_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_role_id_seq', 9, true);


--
-- TOC entry 3777 (class 0 OID 0)
-- Dependencies: 215
-- Name: ab_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_user_id_seq', 17, true);


--
-- TOC entry 3778 (class 0 OID 0)
-- Dependencies: 217
-- Name: ab_user_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_user_role_id_seq', 27, true);


--
-- TOC entry 3779 (class 0 OID 0)
-- Dependencies: 219
-- Name: ab_view_menu_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_view_menu_id_seq', 247, true);


--
-- TOC entry 3780 (class 0 OID 0)
-- Dependencies: 220
-- Name: audit_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.audit_log_id_seq', 841, true);


--
-- TOC entry 3781 (class 0 OID 0)
-- Dependencies: 222
-- Name: categoria_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categoria_id_seq', 55, true);


--
-- TOC entry 3782 (class 0 OID 0)
-- Dependencies: 224
-- Name: clientes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.clientes_id_seq', 12069, true);


--
-- TOC entry 3783 (class 0 OID 0)
-- Dependencies: 242
-- Name: companiaTarjeta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."companiaTarjeta_id_seq"', 2809, true);


--
-- TOC entry 3784 (class 0 OID 0)
-- Dependencies: 267
-- Name: compras_comprobante_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.compras_comprobante_seq', 16, true);


--
-- TOC entry 3785 (class 0 OID 0)
-- Dependencies: 273
-- Name: compras_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.compras_id_seq', 43, true);


--
-- TOC entry 3786 (class 0 OID 0)
-- Dependencies: 248
-- Name: datosEmpresa_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."datosEmpresa_id_seq"', 451, true);


--
-- TOC entry 3787 (class 0 OID 0)
-- Dependencies: 269
-- Name: datosFormaPagosCompra_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."datosFormaPagosCompra_id_seq"', 14, true);


--
-- TOC entry 3788 (class 0 OID 0)
-- Dependencies: 263
-- Name: datosFormaPagos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."datosFormaPagos_id_seq"', 17, true);


--
-- TOC entry 3789 (class 0 OID 0)
-- Dependencies: 259
-- Name: forma_pago_venta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.forma_pago_venta_id_seq', 146, true);


--
-- TOC entry 3790 (class 0 OID 0)
-- Dependencies: 226
-- Name: formadepago_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.formadepago_id_seq', 7361, true);


--
-- TOC entry 3791 (class 0 OID 0)
-- Dependencies: 228
-- Name: localidad_idLocalidad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."localidad_idLocalidad_seq"', 6060, true);


--
-- TOC entry 3792 (class 0 OID 0)
-- Dependencies: 230
-- Name: marcas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.marcas_id_seq', 59, true);


--
-- TOC entry 3793 (class 0 OID 0)
-- Dependencies: 244
-- Name: modulos_configuracion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.modulos_configuracion_id_seq', 1, false);


--
-- TOC entry 3794 (class 0 OID 0)
-- Dependencies: 265
-- Name: oferta_whatsapp_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.oferta_whatsapp_id_seq', 126, true);


--
-- TOC entry 3795 (class 0 OID 0)
-- Dependencies: 255
-- Name: pedido_cliente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pedido_cliente_id_seq', 56, true);


--
-- TOC entry 3796 (class 0 OID 0)
-- Dependencies: 251
-- Name: pedido_proveedor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pedido_proveedor_id_seq', 9, true);


--
-- TOC entry 3797 (class 0 OID 0)
-- Dependencies: 246
-- Name: productos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.productos_id_seq', 49, true);


--
-- TOC entry 3798 (class 0 OID 0)
-- Dependencies: 233
-- Name: proveedor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.proveedor_id_seq', 12, true);


--
-- TOC entry 3799 (class 0 OID 0)
-- Dependencies: 275
-- Name: renglon_compras_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.renglon_compras_id_seq', 104, true);


--
-- TOC entry 3800 (class 0 OID 0)
-- Dependencies: 271
-- Name: renglon_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.renglon_id_seq', 172, true);


--
-- TOC entry 3801 (class 0 OID 0)
-- Dependencies: 257
-- Name: renglon_pedido_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.renglon_pedido_id_seq', 15, true);


--
-- TOC entry 3802 (class 0 OID 0)
-- Dependencies: 261
-- Name: renglon_pedido_whatsapp_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.renglon_pedido_whatsapp_id_seq', 49, true);


--
-- TOC entry 3803 (class 0 OID 0)
-- Dependencies: 238
-- Name: tipoPersona_idTipoPersona_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."tipoPersona_idTipoPersona_seq"', 2819, true);


--
-- TOC entry 3804 (class 0 OID 0)
-- Dependencies: 240
-- Name: tiposClave_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."tiposClave_id_seq"', 5605, true);


--
-- TOC entry 3805 (class 0 OID 0)
-- Dependencies: 235
-- Name: tiposDocumentos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."tiposDocumentos_id_seq"', 6853, true);


--
-- TOC entry 3806 (class 0 OID 0)
-- Dependencies: 237
-- Name: unidad_medida_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.unidad_medida_id_seq', 6, true);


--
-- TOC entry 3807 (class 0 OID 0)
-- Dependencies: 250
-- Name: ventas_comprobante_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ventas_comprobante_seq', 44, true);


--
-- TOC entry 3808 (class 0 OID 0)
-- Dependencies: 253
-- Name: ventas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ventas_id_seq', 133, true);


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


-- Completed on 2021-02-10 23:35:31

--
-- PostgreSQL database dump complete
--

