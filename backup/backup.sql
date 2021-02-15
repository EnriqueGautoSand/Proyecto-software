--
-- PostgreSQL database dump
--

-- Dumped from database version 12.3
-- Dumped by pg_dump version 12.3

-- Started on 2020-12-01 19:01:17

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
-- TOC entry 3736 (class 0 OID 0)
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
-- TOC entry 3737 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- TOC entry 989 (class 1247 OID 21226)
-- Name: companiatarjeta; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.companiatarjeta AS ENUM (
    'visa',
    'mastercard',
    'naranja'
);


ALTER TYPE public.companiatarjeta OWNER TO postgres;

--
-- TOC entry 992 (class 1247 OID 21234)
-- Name: metodospagos; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.metodospagos AS ENUM (
    'tarjeta',
    'contado'
);


ALTER TYPE public.metodospagos OWNER TO postgres;

--
-- TOC entry 995 (class 1247 OID 21240)
-- Name: tipoclaves; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.tipoclaves AS ENUM (
    'consumidorFinal',
    'responsableInscripto',
    'monotributista'
);


ALTER TYPE public.tipoclaves OWNER TO postgres;

--
-- TOC entry 998 (class 1247 OID 21248)
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
-- TOC entry 562 (class 1255 OID 39349)
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
-- TOC entry 553 (class 1255 OID 21268)
-- Name: audit_table(regclass); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.audit_table(target_table regclass) RETURNS void
    LANGUAGE sql
    AS $$
SELECT audit_table(target_table, ARRAY[]::text[]);
$$;


ALTER FUNCTION public.audit_table(target_table regclass) OWNER TO postgres;

--
-- TOC entry 554 (class 1255 OID 21269)
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
-- TOC entry 555 (class 1255 OID 21270)
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
-- TOC entry 559 (class 1255 OID 39343)
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
-- TOC entry 556 (class 1255 OID 21272)
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
-- TOC entry 557 (class 1255 OID 21273)
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
-- TOC entry 558 (class 1255 OID 21274)
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
-- TOC entry 560 (class 1255 OID 39345)
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
-- TOC entry 561 (class 1255 OID 39347)
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
-- TOC entry 1927 (class 2617 OID 21277)
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
-- TOC entry 204 (class 1259 OID 21278)
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
-- TOC entry 205 (class 1259 OID 21281)
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
-- TOC entry 3738 (class 0 OID 0)
-- Dependencies: 205
-- Name: FormadePago_Venta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."FormadePago_Venta_id_seq" OWNED BY public."FormadePago_Venta".id;


--
-- TOC entry 206 (class 1259 OID 21283)
-- Name: ab_permission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_permission (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.ab_permission OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 21286)
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
-- TOC entry 208 (class 1259 OID 21288)
-- Name: ab_permission_view; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_permission_view (
    id integer NOT NULL,
    permission_id integer,
    view_menu_id integer
);


ALTER TABLE public.ab_permission_view OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 21291)
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
-- TOC entry 210 (class 1259 OID 21293)
-- Name: ab_permission_view_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_permission_view_role (
    id integer NOT NULL,
    permission_view_id integer,
    role_id integer
);


ALTER TABLE public.ab_permission_view_role OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 21296)
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
-- TOC entry 212 (class 1259 OID 21298)
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
-- TOC entry 213 (class 1259 OID 21304)
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
-- TOC entry 214 (class 1259 OID 21306)
-- Name: ab_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_role (
    id integer NOT NULL,
    name character varying(64) NOT NULL
);


ALTER TABLE public.ab_role OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 21309)
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
-- TOC entry 216 (class 1259 OID 21311)
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
-- TOC entry 217 (class 1259 OID 21317)
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
-- TOC entry 218 (class 1259 OID 21319)
-- Name: ab_user_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_user_role (
    id integer NOT NULL,
    user_id integer,
    role_id integer
);


ALTER TABLE public.ab_user_role OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 21322)
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
-- TOC entry 220 (class 1259 OID 21324)
-- Name: ab_view_menu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_view_menu (
    id integer NOT NULL,
    name character varying(250) NOT NULL
);


ALTER TABLE public.ab_view_menu OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 21327)
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
-- TOC entry 222 (class 1259 OID 21329)
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
-- TOC entry 256 (class 1259 OID 38899)
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
-- TOC entry 223 (class 1259 OID 21337)
-- Name: categoria; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categoria (
    id integer NOT NULL,
    categoria character varying(50) NOT NULL
);


ALTER TABLE public.categoria OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 21340)
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
-- TOC entry 3739 (class 0 OID 0)
-- Dependencies: 224
-- Name: categoria_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categoria_id_seq OWNED BY public.categoria.id;


--
-- TOC entry 225 (class 1259 OID 21342)
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
-- TOC entry 226 (class 1259 OID 21345)
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
-- TOC entry 3740 (class 0 OID 0)
-- Dependencies: 226
-- Name: clientes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.clientes_id_seq OWNED BY public.clientes.id;


--
-- TOC entry 247 (class 1259 OID 22146)
-- Name: companiaTarjeta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."companiaTarjeta" (
    id integer NOT NULL,
    compania character varying(50),
    estado boolean
);


ALTER TABLE public."companiaTarjeta" OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 22144)
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
-- TOC entry 3741 (class 0 OID 0)
-- Dependencies: 246
-- Name: companiaTarjeta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."companiaTarjeta_id_seq" OWNED BY public."companiaTarjeta".id;


--
-- TOC entry 258 (class 1259 OID 38934)
-- Name: compras; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras (
    id integer NOT NULL,
    estado boolean,
    total double precision NOT NULL,
    "totalNeto" double precision NOT NULL,
    totaliva double precision,
    fecha timestamp without time zone NOT NULL,
    proveedor_id integer NOT NULL,
    formadepago_id integer NOT NULL,
    "datosFormaPagos_id" integer,
    percepcion double precision,
    comprobante bigint NOT NULL
);


ALTER TABLE public.compras OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 38932)
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
-- TOC entry 3742 (class 0 OID 0)
-- Dependencies: 257
-- Name: compras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.compras_id_seq OWNED BY public.compras.id;


--
-- TOC entry 227 (class 1259 OID 21359)
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
-- TOC entry 228 (class 1259 OID 21365)
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
-- TOC entry 3743 (class 0 OID 0)
-- Dependencies: 228
-- Name: datosEmpresa_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."datosEmpresa_id_seq" OWNED BY public."datosEmpresa".id;


--
-- TOC entry 274 (class 1259 OID 39325)
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
-- TOC entry 262 (class 1259 OID 39070)
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
-- TOC entry 261 (class 1259 OID 39068)
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
-- TOC entry 3744 (class 0 OID 0)
-- Dependencies: 261
-- Name: datosFormaPagosCompra_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."datosFormaPagosCompra_id_seq" OWNED BY public."datosFormaPagosCompra".id;


--
-- TOC entry 273 (class 1259 OID 39323)
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
-- TOC entry 3745 (class 0 OID 0)
-- Dependencies: 273
-- Name: datosFormaPagos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."datosFormaPagos_id_seq" OWNED BY public."datosFormaPagos".id;


--
-- TOC entry 272 (class 1259 OID 39307)
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
-- TOC entry 271 (class 1259 OID 39305)
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
-- TOC entry 3746 (class 0 OID 0)
-- Dependencies: 271
-- Name: forma_pago_venta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.forma_pago_venta_id_seq OWNED BY public.forma_pago_venta.id;


--
-- TOC entry 229 (class 1259 OID 21377)
-- Name: formadepago; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.formadepago (
    id integer NOT NULL,
    "Metodo" character varying(50)
);


ALTER TABLE public.formadepago OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 21380)
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
-- TOC entry 3747 (class 0 OID 0)
-- Dependencies: 230
-- Name: formadepago_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.formadepago_id_seq OWNED BY public.formadepago.id;


--
-- TOC entry 231 (class 1259 OID 21382)
-- Name: localidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.localidad (
    idlocalidad integer NOT NULL,
    localidad character varying(55) NOT NULL
);


ALTER TABLE public.localidad OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 21385)
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
-- TOC entry 3748 (class 0 OID 0)
-- Dependencies: 232
-- Name: localidad_idLocalidad_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."localidad_idLocalidad_seq" OWNED BY public.localidad.idlocalidad;


--
-- TOC entry 233 (class 1259 OID 21387)
-- Name: marcas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.marcas (
    id integer NOT NULL,
    marca character varying(50) NOT NULL
);


ALTER TABLE public.marcas OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 21390)
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
-- TOC entry 3749 (class 0 OID 0)
-- Dependencies: 234
-- Name: marcas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.marcas_id_seq OWNED BY public.marcas.id;


--
-- TOC entry 249 (class 1259 OID 38701)
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
-- TOC entry 248 (class 1259 OID 38699)
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
-- TOC entry 3750 (class 0 OID 0)
-- Dependencies: 248
-- Name: modulos_configuracion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.modulos_configuracion_id_seq OWNED BY public.modulos_configuracion.id;


--
-- TOC entry 264 (class 1259 OID 39151)
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
    renglon_compra_id integer NOT NULL
);


ALTER TABLE public.oferta_whatsapp OWNER TO postgres;

--
-- TOC entry 263 (class 1259 OID 39149)
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
-- TOC entry 3751 (class 0 OID 0)
-- Dependencies: 263
-- Name: oferta_whatsapp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.oferta_whatsapp_id_seq OWNED BY public.oferta_whatsapp.id;


--
-- TOC entry 235 (class 1259 OID 21397)
-- Name: operacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.operacion (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.operacion OWNER TO postgres;

--
-- TOC entry 266 (class 1259 OID 39216)
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
    venta_id integer
);


ALTER TABLE public.pedido_cliente OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 39214)
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
-- TOC entry 3752 (class 0 OID 0)
-- Dependencies: 265
-- Name: pedido_cliente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pedido_cliente_id_seq OWNED BY public.pedido_cliente.id;


--
-- TOC entry 251 (class 1259 OID 38746)
-- Name: pedido_proveedor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pedido_proveedor (
    id integer NOT NULL,
    fecha timestamp without time zone,
    proveedor_id integer NOT NULL
);


ALTER TABLE public.pedido_proveedor OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 38744)
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
-- TOC entry 3753 (class 0 OID 0)
-- Dependencies: 250
-- Name: pedido_proveedor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pedido_proveedor_id_seq OWNED BY public.pedido_proveedor.id;


--
-- TOC entry 255 (class 1259 OID 38876)
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
-- TOC entry 254 (class 1259 OID 38874)
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
-- TOC entry 3754 (class 0 OID 0)
-- Dependencies: 254
-- Name: productos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.productos_id_seq OWNED BY public.productos.id;


--
-- TOC entry 236 (class 1259 OID 21405)
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
-- TOC entry 237 (class 1259 OID 21411)
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
-- TOC entry 3755 (class 0 OID 0)
-- Dependencies: 237
-- Name: proveedor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.proveedor_id_seq OWNED BY public.proveedor.id;


--
-- TOC entry 270 (class 1259 OID 39269)
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
-- TOC entry 260 (class 1259 OID 38961)
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
    stock_lote integer NOT NULL
);


ALTER TABLE public.renglon_compras OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 38959)
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
-- TOC entry 3756 (class 0 OID 0)
-- Dependencies: 259
-- Name: renglon_compras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.renglon_compras_id_seq OWNED BY public.renglon_compras.id;


--
-- TOC entry 269 (class 1259 OID 39267)
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
-- TOC entry 3757 (class 0 OID 0)
-- Dependencies: 269
-- Name: renglon_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.renglon_id_seq OWNED BY public.renglon.id;


--
-- TOC entry 253 (class 1259 OID 38858)
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
-- TOC entry 252 (class 1259 OID 38856)
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
-- TOC entry 3758 (class 0 OID 0)
-- Dependencies: 252
-- Name: renglon_pedido_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.renglon_pedido_id_seq OWNED BY public.renglon_pedido.id;


--
-- TOC entry 243 (class 1259 OID 21855)
-- Name: tipoPersona; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."tipoPersona" (
    "idTipoPersona" integer NOT NULL,
    "tipoPersona" character varying(30) NOT NULL
);


ALTER TABLE public."tipoPersona" OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 21853)
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
-- TOC entry 3759 (class 0 OID 0)
-- Dependencies: 242
-- Name: tipoPersona_idTipoPersona_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."tipoPersona_idTipoPersona_seq" OWNED BY public."tipoPersona"."idTipoPersona";


--
-- TOC entry 245 (class 1259 OID 21865)
-- Name: tiposClave; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."tiposClave" (
    id integer NOT NULL,
    "tipoClave" character varying(30) NOT NULL
);


ALTER TABLE public."tiposClave" OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 21863)
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
-- TOC entry 3760 (class 0 OID 0)
-- Dependencies: 244
-- Name: tiposClave_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."tiposClave_id_seq" OWNED BY public."tiposClave".id;


--
-- TOC entry 238 (class 1259 OID 21436)
-- Name: tiposDocumentos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."tiposDocumentos" (
    id integer NOT NULL,
    "tipoDocumento" character varying(30) NOT NULL
);


ALTER TABLE public."tiposDocumentos" OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 21439)
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
-- TOC entry 3761 (class 0 OID 0)
-- Dependencies: 239
-- Name: tiposDocumentos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."tiposDocumentos_id_seq" OWNED BY public."tiposDocumentos".id;


--
-- TOC entry 240 (class 1259 OID 21441)
-- Name: unidad_medida; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.unidad_medida (
    id integer NOT NULL,
    unidad character varying(50) NOT NULL
);


ALTER TABLE public.unidad_medida OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 21444)
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
-- TOC entry 3762 (class 0 OID 0)
-- Dependencies: 241
-- Name: unidad_medida_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.unidad_medida_id_seq OWNED BY public.unidad_medida.id;


--
-- TOC entry 268 (class 1259 OID 39236)
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
    comprobante bigint NOT NULL
);


ALTER TABLE public.ventas OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 39234)
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
-- TOC entry 3763 (class 0 OID 0)
-- Dependencies: 267
-- Name: ventas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ventas_id_seq OWNED BY public.ventas.id;


--
-- TOC entry 3326 (class 2604 OID 21453)
-- Name: FormadePago_Venta id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FormadePago_Venta" ALTER COLUMN id SET DEFAULT nextval('public."FormadePago_Venta_id_seq"'::regclass);


--
-- TOC entry 3327 (class 2604 OID 21454)
-- Name: categoria id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria ALTER COLUMN id SET DEFAULT nextval('public.categoria_id_seq'::regclass);


--
-- TOC entry 3328 (class 2604 OID 21455)
-- Name: clientes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes ALTER COLUMN id SET DEFAULT nextval('public.clientes_id_seq'::regclass);


--
-- TOC entry 3338 (class 2604 OID 22149)
-- Name: companiaTarjeta id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."companiaTarjeta" ALTER COLUMN id SET DEFAULT nextval('public."companiaTarjeta_id_seq"'::regclass);


--
-- TOC entry 3343 (class 2604 OID 38937)
-- Name: compras id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras ALTER COLUMN id SET DEFAULT nextval('public.compras_id_seq'::regclass);


--
-- TOC entry 3329 (class 2604 OID 21459)
-- Name: datosEmpresa id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa" ALTER COLUMN id SET DEFAULT nextval('public."datosEmpresa_id_seq"'::regclass);


--
-- TOC entry 3351 (class 2604 OID 39328)
-- Name: datosFormaPagos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagos" ALTER COLUMN id SET DEFAULT nextval('public."datosFormaPagos_id_seq"'::regclass);


--
-- TOC entry 3345 (class 2604 OID 39073)
-- Name: datosFormaPagosCompra id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagosCompra" ALTER COLUMN id SET DEFAULT nextval('public."datosFormaPagosCompra_id_seq"'::regclass);


--
-- TOC entry 3350 (class 2604 OID 39310)
-- Name: forma_pago_venta id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.forma_pago_venta ALTER COLUMN id SET DEFAULT nextval('public.forma_pago_venta_id_seq'::regclass);


--
-- TOC entry 3330 (class 2604 OID 21462)
-- Name: formadepago id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.formadepago ALTER COLUMN id SET DEFAULT nextval('public.formadepago_id_seq'::regclass);


--
-- TOC entry 3331 (class 2604 OID 21463)
-- Name: localidad idlocalidad; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.localidad ALTER COLUMN idlocalidad SET DEFAULT nextval('public."localidad_idLocalidad_seq"'::regclass);


--
-- TOC entry 3332 (class 2604 OID 21464)
-- Name: marcas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marcas ALTER COLUMN id SET DEFAULT nextval('public.marcas_id_seq'::regclass);


--
-- TOC entry 3339 (class 2604 OID 38704)
-- Name: modulos_configuracion id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modulos_configuracion ALTER COLUMN id SET DEFAULT nextval('public.modulos_configuracion_id_seq'::regclass);


--
-- TOC entry 3346 (class 2604 OID 39154)
-- Name: oferta_whatsapp id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oferta_whatsapp ALTER COLUMN id SET DEFAULT nextval('public.oferta_whatsapp_id_seq'::regclass);


--
-- TOC entry 3347 (class 2604 OID 39219)
-- Name: pedido_cliente id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedido_cliente ALTER COLUMN id SET DEFAULT nextval('public.pedido_cliente_id_seq'::regclass);


--
-- TOC entry 3340 (class 2604 OID 38749)
-- Name: pedido_proveedor id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedido_proveedor ALTER COLUMN id SET DEFAULT nextval('public.pedido_proveedor_id_seq'::regclass);


--
-- TOC entry 3342 (class 2604 OID 38879)
-- Name: productos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos ALTER COLUMN id SET DEFAULT nextval('public.productos_id_seq'::regclass);


--
-- TOC entry 3333 (class 2604 OID 21467)
-- Name: proveedor id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedor ALTER COLUMN id SET DEFAULT nextval('public.proveedor_id_seq'::regclass);


--
-- TOC entry 3349 (class 2604 OID 39272)
-- Name: renglon id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon ALTER COLUMN id SET DEFAULT nextval('public.renglon_id_seq'::regclass);


--
-- TOC entry 3344 (class 2604 OID 38964)
-- Name: renglon_compras id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_compras ALTER COLUMN id SET DEFAULT nextval('public.renglon_compras_id_seq'::regclass);


--
-- TOC entry 3341 (class 2604 OID 38861)
-- Name: renglon_pedido id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_pedido ALTER COLUMN id SET DEFAULT nextval('public.renglon_pedido_id_seq'::regclass);


--
-- TOC entry 3336 (class 2604 OID 21858)
-- Name: tipoPersona idTipoPersona; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tipoPersona" ALTER COLUMN "idTipoPersona" SET DEFAULT nextval('public."tipoPersona_idTipoPersona_seq"'::regclass);


--
-- TOC entry 3337 (class 2604 OID 21868)
-- Name: tiposClave id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tiposClave" ALTER COLUMN id SET DEFAULT nextval('public."tiposClave_id_seq"'::regclass);


--
-- TOC entry 3334 (class 2604 OID 21472)
-- Name: tiposDocumentos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tiposDocumentos" ALTER COLUMN id SET DEFAULT nextval('public."tiposDocumentos_id_seq"'::regclass);


--
-- TOC entry 3335 (class 2604 OID 21473)
-- Name: unidad_medida id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unidad_medida ALTER COLUMN id SET DEFAULT nextval('public.unidad_medida_id_seq'::regclass);


--
-- TOC entry 3348 (class 2604 OID 39239)
-- Name: ventas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas ALTER COLUMN id SET DEFAULT nextval('public.ventas_id_seq'::regclass);


--
-- TOC entry 3660 (class 0 OID 21278)
-- Dependencies: 204
-- Data for Name: FormadePago_Venta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."FormadePago_Venta" (id, monto, venta_id, formadepago_id) FROM stdin;
1	443	1	1
2	254	2	1
3	300	3	1
4	32	3	2
5	247.5	4	1
6	99	5	1
7	219.77999999999997	5	2
8	90	6	1
9	217	7	1
10	2201.5	8	1
11	284.6	9	1
12	100	10	1
13	99	11	1
14	99	12	1
15	117.6	13	1
16	100	14	1
17	100	15	1
18	120	16	1
19	120	17	1
20	100	18	1
21	100	19	1
22	100	20	1
23	72	21	1
24	99.82499999999999	22	1
25	99.82499999999999	23	1
26	99.82499999999999	24	1
27	61	25	1
28	61	26	1
29	61	27	1
30	61	28	1
31	61	29	1
32	61	30	1
33	61	31	1
34	55.50000000000001	32	1
35	146.4	33	1
36	55.50000000000001	34	1
37	55.50000000000001	35	1
38	55.50000000000001	36	1
39	333.00000000000006	37	1
40	146.4	38	1
41	55.50000000000001	39	1
42	333.00000000000006	40	1
43	146.4	41	1
44	55.50000000000001	42	1
45	333.00000000000006	43	1
46	166.50000000000003	44	1
47	146.4	45	1
48	138.75000000000003	46	1
49	333.00000000000006	47	1
50	333.00000000000006	48	1
51	333.00000000000006	49	1
52	333.00000000000006	50	1
53	146.4	51	1
54	336.33	52	1
55	635.25	53	1
57	73.2	55	1
58	333	56	1
59	84.7	57	1
60	351451	58	1
61	146.4	59	1
62	333	60	1
63	84.7	61	1
64	120	62	1
65	146.4	63	1
66	333	64	1
67	84.7	65	1
68	120	66	1
69	333	67	1
70	333	68	1
71	900	69	1
72	180	70	1
73	3354.1200000000003	71	1
74	6000	72	1
75	1800	73	1
76	2984.25	74	1
83	1245.89	81	1
84	49.44	82	1
85	120	85	1
86	662.75	86	1
89	600	91	1
90	5634.36	91	2
91	100	92	1
92	135.5	92	2
94	3346.2	2	1
95	21060	3	1
96	1928.22	4	1
97	23.4	5	1
98	4860.05	6	1
99	1047.62	7	1
100	707.85	8	1
103	17491.5	11	1
105	12409.8	13	1
106	124.1	14	1
107	50.05	15	1
108	100.1	17	1
109	50.05	18	1
110	2973	19	1
111	1179.75	20	1
112	3083.15	21	1
113	2654.44	22	1
114	1628.1	23	1
115	234.52	24	1
116	8740.16	25	2
117	2973	26	1
122	2006.94	29	1
123	4955	30	1
124	1486.5	31	1
125	3112.4	32	1
126	934.02	33	1
127	1486.49	34	1
128	3246.1	35	1
129	396.4	36	1
130	431.58	37	1
131	1294.11	38	1
132	781.36	39	1
133	747.28	40	1
134	1567.28	41	1
135	3964	42	1
136	2229.75	43	1
137	1132.56	44	1
\.


--
-- TOC entry 3662 (class 0 OID 21283)
-- Dependencies: 206
-- Data for Name: ab_permission; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ab_permission (id, name) FROM stdin;
30	can_this_form_get
31	can_this_form_post
32	can_download
33	can_list
34	can_add
35	can_delete
36	can_userinfo
37	can_edit
38	can_show
39	resetmypassword
40	resetpasswords
41	userinfoedit
42	menu_access
43	copyrole
44	can_chart
45	can_get
46	can_put
47	can_info
48	can_post
53	can_venta
54	can_access
56	can_show_static_pdf
57	can_download_pdf
58	anular_vencido
59	Confirmar_Venta
60	show_template
\.


--
-- TOC entry 3664 (class 0 OID 21288)
-- Dependencies: 208
-- Data for Name: ab_permission_view; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ab_permission_view (id, permission_id, view_menu_id) FROM stdin;
257	30	113
258	31	113
259	30	114
260	31	114
261	30	115
262	31	115
263	32	117
264	33	117
265	34	117
266	35	117
267	36	117
268	37	117
269	38	117
270	39	117
271	40	117
272	41	117
273	42	118
274	42	119
275	32	120
276	33	120
277	34	120
278	35	120
279	37	120
280	38	120
281	43	120
282	42	121
283	44	122
284	42	123
285	33	124
286	42	125
287	33	126
288	42	127
289	33	128
290	42	129
291	45	130
292	46	131
293	35	131
294	45	131
295	47	131
296	48	131
366	53	161
367	42	162
368	42	163
369	54	164
370	42	165
372	42	167
373	42	168
374	33	169
375	34	169
376	37	169
377	35	169
378	42	170
379	33	171
380	34	171
381	37	171
382	35	171
383	42	172
384	38	173
385	32	173
386	37	173
387	35	173
388	34	173
389	33	173
390	38	174
391	32	174
392	37	174
393	35	174
394	34	174
395	33	174
396	38	175
397	32	175
398	37	175
399	35	175
400	34	175
401	33	175
402	38	176
403	32	176
404	37	176
405	35	176
406	34	176
407	33	176
408	56	177
412	42	179
416	42	181
417	33	182
418	42	183
419	38	184
420	33	184
421	37	184
422	38	185
423	32	185
424	37	185
425	35	185
426	34	185
427	33	185
428	38	186
429	32	186
430	37	186
431	35	186
432	34	186
433	33	186
434	54	187
435	38	188
436	33	188
437	37	188
438	38	189
439	33	189
440	37	189
441	35	188
442	57	188
443	54	188
444	32	188
445	34	188
446	38	190
447	33	190
448	37	190
449	38	191
450	33	191
451	37	191
452	38	192
453	33	192
454	37	192
455	54	192
456	54	193
457	54	194
458	32	195
459	37	195
460	33	195
461	35	195
462	38	195
463	34	195
464	42	196
465	42	197
466	34	198
467	33	198
468	37	198
469	38	198
470	32	198
471	35	198
472	42	199
473	34	200
474	33	200
475	37	200
476	38	200
477	32	200
478	35	200
479	42	201
480	33	202
481	38	202
482	42	203
483	44	204
484	42	205
485	37	206
486	34	206
487	32	206
488	38	206
489	33	206
490	35	206
491	33	208
492	38	208
493	35	208
494	38	209
495	35	209
496	32	209
497	34	209
498	37	209
499	33	209
500	42	210
501	33	161
502	37	161
503	34	161
504	32	161
505	38	161
506	35	161
507	34	191
508	32	132
509	38	132
510	33	132
511	35	132
512	34	132
513	37	132
514	42	212
515	42	213
516	33	133
517	32	133
518	37	133
519	34	133
520	38	133
521	35	133
522	35	191
523	35	190
524	37	214
525	33	214
526	35	214
527	32	214
528	38	214
529	34	214
530	38	169
531	33	215
532	34	215
533	37	215
534	35	215
535	38	171
536	32	190
537	54	216
538	57	190
539	54	217
540	34	218
541	38	218
542	33	218
543	37	218
544	32	218
545	35	218
546	42	219
547	35	220
548	32	220
549	33	220
550	34	220
551	38	220
552	37	220
553	33	224
554	35	224
555	38	224
556	34	224
557	37	224
558	32	224
559	42	225
560	33	226
561	35	226
562	38	226
563	34	226
564	37	226
565	32	226
566	42	227
567	33	228
568	58	228
569	35	228
570	33	229
571	35	229
572	42	230
573	38	229
574	33	231
575	38	231
576	37	216
577	33	216
578	42	232
579	42	233
580	42	235
581	33	236
582	42	237
583	59	236
584	35	236
585	60	236
586	38	236
587	37	236
588	35	239
589	38	239
590	32	239
591	34	239
592	37	239
593	33	239
594	42	240
595	33	241
596	38	241
597	32	241
598	37	241
599	35	241
600	34	241
\.


--
-- TOC entry 3666 (class 0 OID 21293)
-- Dependencies: 210
-- Data for Name: ab_permission_view_role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ab_permission_view_role (id, permission_view_id, role_id) FROM stdin;
298	257	5
299	258	5
300	259	5
301	260	5
302	261	5
303	262	5
304	263	5
305	264	5
306	265	5
307	266	5
308	267	5
309	268	5
310	269	5
311	270	5
312	271	5
313	272	5
314	273	5
315	274	5
316	275	5
317	276	5
318	277	5
319	278	5
320	279	5
321	280	5
322	281	5
323	282	5
324	283	5
325	284	5
326	285	5
327	286	5
328	287	5
329	288	5
330	289	5
331	290	5
332	291	5
333	292	5
334	293	5
335	294	5
336	295	5
337	296	5
410	366	5
411	367	5
412	368	5
413	369	5
414	370	5
416	372	5
417	373	5
418	374	5
419	375	5
420	376	5
421	377	5
422	378	5
423	379	5
424	380	5
425	381	5
426	382	5
427	383	5
428	384	5
429	385	5
430	386	5
431	387	5
432	388	5
433	389	5
434	390	5
435	391	5
436	392	5
437	393	5
438	394	5
439	395	5
440	396	5
441	397	5
442	398	5
443	399	5
444	400	5
445	401	5
446	402	5
447	403	5
448	404	5
449	405	5
450	406	5
451	407	5
452	408	5
456	412	5
460	416	5
461	417	5
462	418	5
463	419	5
464	420	5
465	421	5
466	422	5
467	423	5
468	424	5
469	425	5
470	426	5
471	427	5
472	428	5
473	429	5
474	430	5
475	431	5
476	432	5
477	433	5
479	434	5
480	435	5
481	436	5
482	437	5
483	438	5
484	439	5
485	440	5
486	441	5
487	442	5
488	443	5
489	444	5
490	445	5
491	446	5
492	447	5
493	448	5
494	449	5
495	450	5
496	451	5
506	452	5
507	453	5
508	454	5
509	455	5
510	456	5
511	457	5
512	458	5
513	459	5
514	460	5
515	461	5
516	462	5
517	463	5
518	464	5
519	465	5
520	466	5
521	467	5
522	468	5
523	469	5
524	470	5
525	471	5
526	472	5
527	473	5
528	474	5
529	475	5
530	476	5
531	477	5
532	478	5
533	479	5
534	480	5
535	481	5
536	482	5
537	483	5
538	484	5
539	485	5
540	486	5
541	487	5
542	488	5
543	489	5
544	490	5
545	491	5
546	492	5
547	493	5
548	494	5
549	495	5
550	496	5
551	497	5
552	498	5
553	499	5
554	500	5
555	501	5
556	502	5
557	503	5
558	504	5
559	505	5
560	506	5
561	507	5
573	508	5
574	509	5
575	510	5
576	511	5
577	512	5
578	513	5
579	514	5
580	515	5
581	516	5
582	517	5
583	518	5
584	519	5
585	520	5
586	521	5
587	522	5
588	523	5
589	524	5
590	525	5
591	526	5
592	527	5
593	528	5
594	529	5
595	530	5
596	531	5
597	532	5
598	533	5
599	534	5
600	535	5
601	536	5
602	537	5
603	538	5
604	539	5
605	540	5
606	541	5
607	542	5
608	543	5
609	544	5
610	545	5
611	546	5
612	547	5
613	548	5
614	549	5
615	550	5
616	551	5
617	552	5
618	553	5
619	554	5
620	555	5
621	556	5
622	557	5
623	558	5
624	559	5
625	560	5
626	561	5
627	562	5
628	563	5
629	564	5
630	565	5
631	566	5
632	567	5
633	568	5
634	569	5
635	570	5
636	571	5
637	572	5
638	573	5
639	574	5
640	575	5
641	576	5
642	577	5
643	578	5
644	579	5
645	580	5
646	581	5
647	582	5
648	583	5
649	584	5
650	585	5
651	586	5
652	587	5
653	588	5
654	589	5
655	590	5
656	591	5
657	592	5
658	593	5
659	594	5
660	595	5
661	596	5
662	597	5
663	598	5
664	599	5
665	600	5
\.


--
-- TOC entry 3668 (class 0 OID 21298)
-- Dependencies: 212
-- Data for Name: ab_register_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ab_register_user (id, first_name, last_name, username, password, email, registration_date, registration_hash) FROM stdin;
\.


--
-- TOC entry 3670 (class 0 OID 21306)
-- Dependencies: 214
-- Data for Name: ab_role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ab_role (id, name) FROM stdin;
5	Admin
6	Public
7	Gerente
9	Vendedor
\.


--
-- TOC entry 3672 (class 0 OID 21311)
-- Dependencies: 216
-- Data for Name: ab_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ab_user (id, first_name, last_name, username, password, active, email, last_login, login_count, fail_login_count, created_on, changed_on, created_by_fk, changed_by_fk, cuil) FROM stdin;
8	enrique	sand	egsand	pbkdf2:sha256:50000$M2KUtiFD$2bbe3354fdf08e42d3a2b9cfb6e08ba7e693dbe72a933f530184e52c9353f827	t	xovibe4870@x1post.com	2020-11-06 10:01:50.553639	1	0	2020-11-06 09:50:56.941954	2020-11-06 10:11:03.964096	\N	6	27-05883446-2
16	jack	nickolson	jack	pbkdf2:sha256:50000$gPa5yVlC$ef4dea0120344212163d25b946edcba8ca9f5eafd782fe1f6d07cba7b4b61372	t	sirepo4423@x1post.com	2020-11-09 14:54:54.205387	1	0	2020-11-09 14:54:38.867965	2020-11-09 14:54:38.867965	\N	\N	\N
6	gerente	gerente	gerente1	pbkdf2:sha256:50000$Q5m5vE72$9a595328c91717556dc8d8e9a89b781f26a05c50016dc84e195797eb8bdcaac4	t	gerente@gmail.com	2020-11-22 15:51:00.35607	19	0	2020-10-15 18:33:32.22051	2020-10-26 12:54:36.693305	5	5	27-39441118-9
17	vendedor	1	vendedor	pbkdf2:sha256:50000$suwSLpY6$e59f815bc57ab0d88b389602b91d68744bcc684f30d7b6acf37eed744143b983	t	dayim53320@idcbill.com	2020-11-22 16:14:30.331351	5	0	2020-11-10 21:56:07.058721	2020-11-22 15:44:56.254073	\N	5	27-10604821-0
5	admin	super	superadmin	pbkdf2:sha256:50000$DIByLH7T$9421fe78a224369623f4e330177bcbebf9f22d6384b72366d8f8f4ec3511d55e	t	admin@fab.org	2020-11-13 15:48:53.134929	69	0	2020-10-15 18:13:49.879222	2020-10-15 18:13:49.879222	\N	\N	\N
\.


--
-- TOC entry 3674 (class 0 OID 21319)
-- Dependencies: 218
-- Data for Name: ab_user_role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ab_user_role (id, user_id, role_id) FROM stdin;
6	5	5
9	6	7
11	8	6
24	16	6
25	17	6
27	17	9
\.


--
-- TOC entry 3676 (class 0 OID 21324)
-- Dependencies: 220
-- Data for Name: ab_view_menu; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ab_view_menu (id, name) FROM stdin;
109	IndexView
110	UtilView
111	LocaleView
112	SecurityApi
113	ResetPasswordView
114	ResetMyPasswordView
115	UserInfoEditView
116	AuthDBView
117	MyUserDBModelView
118	List Users
119	Security
120	RoleModelView
121	List Roles
122	UserStatsChartView
123	User's Statistics
124	PermissionModelView
125	Base Permissions
126	ViewMenuModelView
127	Views/Menus
128	PermissionViewModelView
129	Permission on Views/Menus
130	MenuApi
131	ProductoApi
132	VentasApi
133	ComprasApi
161	VentaView
162	Realizar Ventas
163	Ventas
164	productocrud
165	Productos
167	Compra
168	Compras
169	ClientesView
170	Clientes
171	ProveedorView
172	Proveedor
173	ProductoModelview
174	MarcasModelview
175	unidadesModelView
176	CategoriaModelview
177	ReportesView
179	Reporte Ventas
181	Reporte Compras
182	Sistemaview
183	Datos Empresa
184	Empresaview
185	CompaniaTarjetaview
186	RenglonVentas
187	compraclass
188	comprarepo
189	ventarepo
190	CompraReportes
191	VentaReportes
192	empresa
193	crudempresa
194	tarjeta
195	compraauditoriaView
196	compra
197	compraaud
198	ventaauditoriaView
199	Ventaau
200	clientesauditoriaView
201	Clientesaud
202	AuditLogView
203	Audit Events
204	AuditLogChartView
205	Chart Events
206	MetododepagoVentas
207	RegisterUserDBView
208	RegisterUserModelView
209	PrecioMdelview
210	Control de Precios
211	MyRegisterUserDBView
212	Auditoria
213	Graficos de Auditoria
214	Clienteapi
215	proveedoraccess
216	PrecioMdelviewip
217	ventaclass
218	ModulosInteligentesView
219	Modulos Inteligentes
220	RenglonComprasView
221	smsreply
222	MyIndexView
223	Myauthdbview
224	PedidoView
225	Pedidos de Presupesto
226	RenglonPedidoView
227	Vencidos
228	RenglonComprasVencidos
229	RenglonComprasxVencer
230	Por Vencer
231	ProductoxVencer
232	Categoria Marca Unidad
233	Producto
234	ModeloWhatsapp
235	Auditoría
236	PedidosWhatsappView
237	Ofertas de Ventas Whtasapp
238	ModeloWhatsappPedido
239	PediddosClientesView
240	Pedidos de Ventas Whtasapp
241	ConvertirVenta
\.


--
-- TOC entry 3712 (class 0 OID 38899)
-- Dependencies: 256
-- Data for Name: auditoria; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auditoria (id, message, username, anterior, created_on, operation_id, target) FROM stdin;
590	ID 32 ESTADO True PRECIO 120.0 STOCK 0 IVA 20.0 UNIDAD_ID 2 MARCAS_ID 48 CATEGORIA_ID 21 MEDIDA 390.0 DETALLE  	superadmin		2020-12-13 15:23:45.385937	13	Productos
591	ID 33 ESTADO True PRECIO 120.0 STOCK 0 IVA 20.0 UNIDAD_ID 2 MARCAS_ID 48 CATEGORIA_ID 21 MEDIDA 450.0 DETALLE FRUTOS DEL BOSQUE 	superadmin		2020-12-13 15:24:26.036578	13	Productos
592	ID 34 ESTADO True PRECIO 100.0 STOCK 0 IVA 20.0 UNIDAD_ID 2 MARCAS_ID 44 CATEGORIA_ID 21 MEDIDA 390.0 DETALLE NARANJA 	superadmin		2020-12-13 15:26:01.054593	13	Productos
593	ID 35 ESTADO True PRECIO 100.0 STOCK 0 IVA 20.0 UNIDAD_ID 2 MARCAS_ID 44 CATEGORIA_ID 21 MEDIDA 390.0 DETALLE CIRUELA 	superadmin		2020-12-13 15:28:02.803532	13	Productos
594	ID 36 ESTADO True PRECIO 90.0 STOCK 0 IVA 20.0 UNIDAD_ID 2 MARCAS_ID 44 CATEGORIA_ID 22 MEDIDA 390.0 DETALLE ENTERO 	superadmin		2020-12-13 15:28:56.745791	13	Productos
595	ID 37 ESTADO True PRECIO 170.0 STOCK 0 IVA 20.0 UNIDAD_ID 2 MARCAS_ID 51 CATEGORIA_ID 23 MEDIDA 300.0 DETALLE  	superadmin		2020-12-13 15:29:37.183881	13	Productos
596	ID 38 ESTADO True PRECIO 170.0 STOCK 0 IVA 20.0 UNIDAD_ID 2 MARCAS_ID 43 CATEGORIA_ID 24 MEDIDA 230.0 DETALLE  	superadmin		2020-12-13 15:30:37.020568	13	Productos
597	ID 39 ESTADO True PRECIO 18.0 STOCK 0 IVA 20.0 UNIDAD_ID 2 MARCAS_ID 53 CATEGORIA_ID 25 MEDIDA 20.0 DETALLE MANZANA 	superadmin		2020-12-13 15:31:33.516162	13	Productos
598	ID 40 ESTADO True PRECIO 18.0 STOCK 0 IVA 20.0 UNIDAD_ID 2 MARCAS_ID 53 CATEGORIA_ID 25 MEDIDA 20.0 DETALLE LIMON 	superadmin		2020-12-13 15:31:57.025974	13	Productos
599	ID 42 ESTADO True PRECIO 20.0 STOCK 0 IVA 20.0 UNIDAD_ID 2 MARCAS_ID 53 CATEGORIA_ID 25 MEDIDA 20.0 DETALLE NARANJA 	superadmin		2020-12-13 15:33:29.889653	13	Productos
600	ID 43 ESTADO True PRECIO 65.0 STOCK 0 IVA 10.0 UNIDAD_ID 5 MARCAS_ID 54 CATEGORIA_ID 26 MEDIDA 700.0 DETALLE  	superadmin		2020-12-13 15:34:26.832997	13	Productos
601	ID 44 ESTADO True PRECIO 75.0 STOCK 0 IVA 20.0 UNIDAD_ID 5 MARCAS_ID 55 CATEGORIA_ID 26 MEDIDA 300.0 DETALLE  	superadmin		2020-12-13 15:35:05.339789	13	Productos
602	ID 45 ESTADO True PRECIO 55.0 STOCK 0 IVA 10.0 UNIDAD_ID 5 MARCAS_ID 56 CATEGORIA_ID 26 MEDIDA 300.0 DETALLE  	superadmin		2020-12-13 15:35:32.547591	13	Productos
603	ID 46 ESTADO True PRECIO 110.0 STOCK 0 IVA 20.0 UNIDAD_ID 2 MARCAS_ID 54 CATEGORIA_ID 27 MEDIDA 800.0 DETALLE  	superadmin		2020-12-13 15:36:13.872529	13	Productos
604	ID 47 ESTADO True PRECIO 60.0 STOCK 0 IVA 21.0 UNIDAD_ID 2 MARCAS_ID 54 CATEGORIA_ID 27 MEDIDA 400.0 DETALLE  	superadmin		2020-12-13 15:36:51.599417	13	Productos
605	ID 48 ESTADO True PRECIO 110.0 STOCK 0 IVA 20.0 UNIDAD_ID 2 MARCAS_ID 56 CATEGORIA_ID 27 MEDIDA 800.0 DETALLE  	superadmin		2020-12-13 15:37:19.625789	13	Productos
606	ID 13 ESTADO True TOTAL 1617.16 TOTALNETO 1336.5 TOTALIVA 280.66 FECHA 2020-11-13 15:48:35.167742 PROVEEDOR_ID 5 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 1 	superadmin		2020-11-13 15:48:35.242933	13	Compra
607	ID 14 ESTADO True TOTAL 8300.6 TOTALNETO 6860.0 TOTALIVA 1440.6 FECHA 2020-11-13 15:52:55.619885 PROVEEDOR_ID 5 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 2 	superadmin		2020-11-13 15:52:55.635885	13	Compra
608	ID 15 ESTADO True TOTAL 907.5 TOTALNETO 750.0 TOTALIVA 157.5 FECHA 2020-11-13 15:54:03.127711 PROVEEDOR_ID 5 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 3 	superadmin		2020-11-13 15:54:03.14357	13	Compra
609	ID 16 ESTADO True TOTAL 4154.0 TOTALNETO 3350.0 TOTALIVA 703.5 FECHA 2020-11-13 15:58:19.011711 PROVEEDOR_ID 7 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 3.0 COMPROBANTE 4 	superadmin		2020-11-13 15:58:19.027558	13	Compra
610	ID 17 ESTADO True TOTAL 2722.5 TOTALNETO 2250.0 TOTALIVA 472.5 FECHA 2020-11-13 15:58:49.211012 PROVEEDOR_ID 7 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 5 	superadmin		2020-11-13 15:58:49.226868	13	Compra
611	ID 18 ESTADO True TOTAL 1361.25 TOTALNETO 1125.0 TOTALIVA 236.25 FECHA 2020-11-13 16:00:53.123494 PROVEEDOR_ID 7 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 6 	superadmin		2020-11-13 16:00:53.203494	13	Compra
612	ID 19 ESTADO True TOTAL 18150.0 TOTALNETO 15000.0 TOTALIVA 3150.0 FECHA 2020-11-14 16:04:46.244801 PROVEEDOR_ID 10 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 7 	superadmin		2020-11-14 16:04:46.260802	13	Compra
613	ID 20 ESTADO True TOTAL 7200.0 TOTALNETO 6000.0 TOTALIVA 1200.0 FECHA 2020-11-14 16:05:51.660000 PROVEEDOR_ID 10 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 8 	superadmin		2020-11-14 16:05:51.676002	13	Compra
614	ID 21 ESTADO True TOTAL 9200.0 TOTALNETO 9200.0 TOTALIVA 0.0 FECHA 2020-11-14 16:06:39.912831 PROVEEDOR_ID 4 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 9 	superadmin		2020-11-14 16:06:39.928829	13	Compra
615	ID 22 ESTADO True TOTAL 2200.0 TOTALNETO 2200.0 TOTALIVA 0.0 FECHA 2020-11-14 16:08:49.564260 PROVEEDOR_ID 4 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 10 	superadmin		2020-11-14 16:08:49.580259	13	Compra
616	ID 23 ESTADO True TOTAL 5292.0 TOTALNETO 4410.0 TOTALIVA 882.0 FECHA 2020-11-20 16:10:15.758241 PROVEEDOR_ID 8 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 11 	superadmin		2020-11-20 16:10:15.800773	13	Compra
617	ID 24 ESTADO True TOTAL 19750.0 TOTALNETO 19750.0 TOTALIVA 1500.0 FECHA 2020-11-20 16:11:57.859849 PROVEEDOR_ID 6 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 12 	superadmin		2020-11-20 16:11:57.893141	13	Compra
618	ID 25 ESTADO True TOTAL 10980.0 TOTALNETO 9000.0 TOTALIVA 1890.0 FECHA 2020-11-20 16:15:25.508392 PROVEEDOR_ID 5 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 1.0 COMPROBANTE 13 	superadmin		2020-11-20 16:15:25.553963	13	Compra
619	ID 26 ESTADO True TOTAL 45694.5 TOTALNETO 41820.0 TOTALIVA 3874.5 FECHA 2020-11-20 16:16:43.311675 PROVEEDOR_ID 5 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 14 	superadmin		2020-11-20 16:16:43.380173	13	Compra
620	ID 27 ESTADO True TOTAL 23595.0 TOTALNETO 19500.0 TOTALIVA 4095.0 FECHA 2020-11-20 16:20:04.019881 PROVEEDOR_ID 7 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 15 	superadmin		2020-11-20 16:20:04.0747	13	Compra
621	ID 28 ESTADO True TOTAL 19300.0 TOTALNETO 19300.0 TOTALIVA 0.0 FECHA 2020-11-20 16:24:19.850827 PROVEEDOR_ID 9 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 16 	superadmin		2020-11-20 16:24:19.913827	13	Compra
622	ID 29 ESTADO True TOTAL 20066.56 TOTALNETO 16448.0 TOTALIVA 3289.6 FECHA 2020-11-20 16:37:29.658794 PROVEEDOR_ID 8 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 2.0 COMPROBANTE 17 	superadmin		2020-11-20 16:37:29.688955	13	Compra
623	ID 11 CUIT 20-17662132-0 NOMBRE MARTIN APELLIDO ARJONA RANKING 0 DOMICILIO None CORREO  ESTADO True TIPOCLAVE_ID 3 IDTIPOPERSONA 1 DIRECCION  IDLOCALIDAD None TELEFONO_CELULAR None 	superadmin		2020-11-20 16:48:49.530301	13	Proveedor
624	ID 10 ESTADO True FECHA 2020-11-21 TOTALNETO 662.23 TOTALIVA 0.0 TOTAL 662.23 CLIENTE_ID 7735 PERCEPCION 0.0 COMPROBANTE 1 	superadmin		2020-11-21 16:56:43.183593	13	Venta
625	ID 11 ESTADO True FECHA 2020-11-21 TOTALNETO 257.4 TOTALIVA 54.05 TOTAL 311.45 CLIENTE_ID 4490 PERCEPCION 0.0 COMPROBANTE 2 	superadmin		2020-11-21 16:57:10.390738	13	Venta
626	ID 12 ESTADO True FECHA 2020-11-21 TOTALNETO 5574.82 TOTALIVA 0.0 TOTAL 5574.82 CLIENTE_ID 2356 PERCEPCION 0.0 COMPROBANTE 3 	superadmin		2020-11-21 16:58:15.680326	13	Venta
627	ID 13 ESTADO True FECHA 2020-11-21 TOTALNETO 336.37 TOTALIVA 0.0 TOTAL 336.37 CLIENTE_ID 1 PERCEPCION 0.0 COMPROBANTE 4 	superadmin		2020-11-21 16:58:40.55522	13	Venta
628	ID 14 ESTADO True FECHA 2020-11-21 TOTALNETO 235.94 TOTALIVA 0.0 TOTAL 235.94 CLIENTE_ID 1 PERCEPCION 0.0 COMPROBANTE 5 	superadmin		2020-11-21 16:59:06.839434	13	Venta
629	ID 15 ESTADO True FECHA 2020-11-22 TOTALNETO 2730.0 TOTALIVA 560.3 TOTAL 3290.3 CLIENTE_ID 4781 PERCEPCION 0.0 COMPROBANTE 6 	superadmin		2020-11-22 17:01:02.002597	13	Venta
630	ID 16 ESTADO True FECHA 2020-11-22 TOTALNETO 1124.76 TOTALIVA 0.0 TOTAL 1124.76 CLIENTE_ID 4227 PERCEPCION 0.0 COMPROBANTE 7 	superadmin		2020-11-22 17:02:05.681189	13	Venta
631	ID 17 ESTADO True FECHA 2020-11-22 TOTALNETO 375.8 TOTALIVA 0.0 TOTAL 375.8 CLIENTE_ID 4210 PERCEPCION 0.0 COMPROBANTE 8 	superadmin		2020-11-22 17:02:46.918667	13	Venta
632	ID 18 ESTADO True FECHA 2020-11-24 TOTALNETO 1726.01 TOTALIVA 0.0 TOTAL 1726.01 CLIENTE_ID 4205 PERCEPCION 0.0 COMPROBANTE 9 	superadmin		2020-11-24 17:03:28.335303	13	Venta
633	ID 19 ESTADO True FECHA 2020-11-24 TOTALNETO 1000.7 TOTALIVA 0.0 TOTAL 1000.7 CLIENTE_ID 4 PERCEPCION 0.0 COMPROBANTE 10 	superadmin		2020-11-24 17:04:34.577699	13	Venta
634	ID 30 ESTADO True TOTAL 22500.0 TOTALNETO 22500.0 TOTALIVA 0.0 FECHA 2020-11-27 17:07:29.779989 PROVEEDOR_ID 11 FORMADEPAGO_ID 1 DATOSFORMAPAGOS_ID None PERCEPCION 0.0 COMPROBANTE 18 	superadmin		2020-11-27 17:07:29.857671	13	Compra
635	ID 20 ESTADO True FECHA 2020-11-27 TOTALNETO 962.0 TOTALIVA 202.02 TOTAL 1164.02 CLIENTE_ID 4616 PERCEPCION 0.0 COMPROBANTE 11 	superadmin		2020-11-27 17:11:26.419143	13	Venta
636	ID 21 ESTADO True FECHA 2020-11-27 TOTALNETO 47.19 TOTALIVA 0.0 TOTAL 47.19 CLIENTE_ID 7735 PERCEPCION 0.0 COMPROBANTE 12 	superadmin		2020-11-27 17:25:44.857983	13	Venta
637	ID 22 ESTADO True FECHA 2020-11-27 TOTALNETO 471.9 TOTALIVA 0.0 TOTAL 471.9 CLIENTE_ID 4227 PERCEPCION 0.0 COMPROBANTE 13 	superadmin		2020-11-27 17:29:35.555577	13	Venta
638	ID 23 ESTADO True FECHA 2020-11-27 TOTALNETO 486.2 TOTALIVA 0.0 TOTAL 486.2 CLIENTE_ID 4215 PERCEPCION 0.0 COMPROBANTE 14 	superadmin		2020-11-27 17:31:05.096328	13	Venta
639	ID 24 ESTADO True FECHA 2020-11-30 TOTALNETO 432.25 TOTALIVA 0.0 TOTAL 432.25 CLIENTE_ID 4274 PERCEPCION 0.0 COMPROBANTE 15 	superadmin		2020-11-30 17:31:40.38595	13	Venta
640	ID 25 ESTADO True FECHA 2020-11-30 TOTALNETO 585.0 TOTALIVA 117.0 TOTAL 702.0 CLIENTE_ID 637 PERCEPCION 0.0 COMPROBANTE 16 	superadmin		2020-11-30 17:32:23.891494	13	Venta
641	ID 26 ESTADO True FECHA 2020-11-30 TOTALNETO 1651.58 TOTALIVA 0.0 TOTAL 1651.58 CLIENTE_ID 4428 PERCEPCION 0.0 COMPROBANTE 17 	superadmin		2020-11-30 17:33:02.854883	13	Venta
642	ID 27 ESTADO True FECHA 2020-11-30 TOTALNETO 1092.0 TOTALIVA 228.15 TOTAL 1320.15 CLIENTE_ID 4490 PERCEPCION 0.0 COMPROBANTE 18 	superadmin		2020-11-30 17:37:54.496594	13	Venta
643	ID 28 ESTADO True FECHA 2020-11-30 TOTALNETO 552.07 TOTALIVA 0.0 TOTAL 552.07 CLIENTE_ID 2356 PERCEPCION 0.0 COMPROBANTE 19 	superadmin		2020-11-30 17:38:29.834717	13	Venta
644	ID 9 CUIT 27-06690501-8 NOMBRE SILVIA APELLIDO BEATRIZ RANKING 0 DOMICILIO None CORREO hereg11388@yektara.com ESTADO True TIPOCLAVE_ID 4 IDTIPOPERSONA 1 DIRECCION  IDLOCALIDAD None TELEFONO_CELULAR None 	superadmin	ID 9 CUIT 27-06690501-8 NOMBRE SILVIA APELLIDO BEATRIZ RANKING 0 DOMICILIO None CORREO None ESTADO True TIPOCLAVE_ID 4 IDTIPOPERSONA 1 DIRECCION  IDLOCALIDAD None TELEFONO_CELULAR None 	2020-12-01 18:25:34.345973	14	Proveedor
645	ID 3888 DOCUMENTO 41091788 NOMBRE enrique APELLIDO sand TIPODOCUMENTO_ID 1 TIPOCLAVE_ID 1 IDTIPOPERSONA 1 ESTADO True TELEFONO_CELULAR 3764247399 DIRECCION  IDLOCALIDAD None 	superadmin	ID 3888 DOCUMENTO 41091788 NOMBRE enrique APELLIDO sand TIPODOCUMENTO_ID 1 TIPOCLAVE_ID 1 IDTIPOPERSONA 1 ESTADO True TELEFONO_CELULAR None DIRECCION None IDLOCALIDAD None 	2020-12-01 18:31:44.696004	14	Clientes
646	ID 3888 DOCUMENTO 41091788 NOMBRE enrique APELLIDO sand TIPODOCUMENTO_ID 1 TIPOCLAVE_ID 1 IDTIPOPERSONA 1 ESTADO True TELEFONO_CELULAR  DIRECCION  IDLOCALIDAD None 	superadmin	ID 3888 DOCUMENTO 41091788 NOMBRE enrique APELLIDO sand TIPODOCUMENTO_ID 1 TIPOCLAVE_ID 1 IDTIPOPERSONA 1 ESTADO True TELEFONO_CELULAR 3764247399 DIRECCION  IDLOCALIDAD None 	2020-12-01 18:40:18.664813	14	Clientes
647	ID 2356 DOCUMENTO 3905508741 NOMBRE jorge APELLIDO Delpiano TIPODOCUMENTO_ID 1 TIPOCLAVE_ID 1 IDTIPOPERSONA 1 ESTADO True TELEFONO_CELULAR 3764247399 DIRECCION  IDLOCALIDAD None 	superadmin	ID 2356 DOCUMENTO 3905508741 NOMBRE jorge APELLIDO Delpiano TIPODOCUMENTO_ID 1 TIPOCLAVE_ID 1 IDTIPOPERSONA 1 ESTADO True TELEFONO_CELULAR None DIRECCION  IDLOCALIDAD None 	2020-12-01 18:40:44.573321	14	Clientes
\.


--
-- TOC entry 3679 (class 0 OID 21337)
-- Dependencies: 223
-- Data for Name: categoria; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categoria (id, categoria) FROM stdin;
1	YERBA
2	GASEOSA
3	GALLETITA
4	VINO
5	CERVEZA
6	CIGARRILLOS
7	DULCES
11	HARINA
13	FIDEO
14	ARROZ
15	SAL
16	LECHE
17	ACEITE
19	LAVANDINA
20	AZUCAR
21	MERMELADA
22	TOMATE PERITA
23	CABALLA EN ACEITE
24	CABALLA AL NATURAL
25	JUGO EN POLVO
26	DETERGENTE
27	JAVON EN POLVO
28	JAVON LIQUIDO
29	LENTEJAS
30	MAÍS PISINGALLO
31	POROTOALUBIA
32	ADOBO
33	AZUCAR NEGRA
34	BICARBONATO DE SODIO
35	PIMIENTA NEGRA
36	AJI MOLIDO
37	PESTO
38	CONDIMENTO PARA ARROZ
39	COMINO MOLIDO
40	PIMIENTA BLANCA MOLIDA
41	KETCHUP
42	MOZTAZA
43	POROTOS
44	CHOCLO AMARILLO
45	GARBANZOS
46	CHAMPIÑONES EN TROZO
47	SALSA TIPO PORTUGUESA
48	SALSA DE PIZA
49	FILETO
50	FERNET
52	POROTO ALUBIA
55	DAMASCO
\.


--
-- TOC entry 3681 (class 0 OID 21342)
-- Dependencies: 225
-- Data for Name: clientes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado, direccion, idlocalidad, telefono_celular) FROM stdin;
7735	25626338	MARTIN 	SCORCESENs	1	3	1	t		3	\N
4490	20-94173793-6	macro	SRL	2	2	2	t		\N	\N
1	Consumidor Final			1	1	1	t		\N	\N
4781	27-04209000-5	IPLICSE	srl	2	2	2	t		\N	\N
4227	65435165	arguesto	arguellos	1	1	1	t	\N	\N	\N
4210	355316543	Ricardo Ernesto	godoy	1	1	1	t	\N	\N	\N
4616	20-06294674-2	Minimercado	srl	2	2	2	t	\N	\N	\N
4491	12153453213	german	Goicochea	1	1	1	t	\N	\N	\N
4205	6546516	julia	sanchez	1	1	1	t	\N	\N	\N
4	131618746	juan	perez	1	3	1	t	\N	\N	\N
4241	6551656	marcelo	ramos	1	1	1	f		\N	\N
4215	13698478	ricardo	godoy	1	1	1	t	\N	\N	\N
4274	5456165457	Gerardo	Mantizen	1	1	1	t	\N	\N	\N
2357	253648741	virginia	rosas	1	1	1	f	\N	\N	\N
4232	136849875	Gerundio	ortiz	1	1	1	f	\N	\N	\N
4221	26521648	arguesto	aruga	1	1	1	t	\N	\N	\N
637	27-10255123-6	Marcelo	Lobardys	2	2	1	t	junin 1643	1	\N
4428	30-67242739-4	mertin	salmone	2	4	1	t		2	\N
3888	41091788	enrique	sand	1	1	1	t		\N	
2356	3905508741	jorge	Delpiano	1	1	1	t		\N	3764247399
\.


--
-- TOC entry 3703 (class 0 OID 22146)
-- Dependencies: 247
-- Data for Name: companiaTarjeta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."companiaTarjeta" (id, compania, estado) FROM stdin;
1	Visa	t
2	Mastercard	t
\.


--
-- TOC entry 3714 (class 0 OID 38934)
-- Dependencies: 258
-- Data for Name: compras; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compras (id, estado, total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion, comprobante) FROM stdin;
13	t	1617.16	1336.5	280.66	2020-11-13 15:48:35.167742	5	1	\N	0	1
14	t	8300.6	6860	1440.6	2020-11-13 15:52:55.619885	5	1	\N	0	2
15	t	907.5	750	157.5	2020-11-13 15:54:03.127711	5	1	\N	0	3
16	t	4154	3350	703.5	2020-11-13 15:58:19.011711	7	1	\N	3	4
17	t	2722.5	2250	472.5	2020-11-13 15:58:49.211012	7	1	\N	0	5
18	t	1361.25	1125	236.25	2020-11-13 16:00:53.123494	7	1	\N	0	6
19	t	18150	15000	3150	2020-11-14 16:04:46.244801	10	1	\N	0	7
20	t	7200	6000	1200	2020-11-14 16:05:51.66	10	1	\N	0	8
21	t	9200	9200	0	2020-11-14 16:06:39.912831	4	1	\N	0	9
22	t	2200	2200	0	2020-11-14 16:08:49.56426	4	1	\N	0	10
23	t	5292	4410	882	2020-11-20 16:10:15.758241	8	1	\N	0	11
24	t	19750	19750	1500	2020-11-20 16:11:57.859849	6	1	\N	0	12
25	t	10980	9000	1890	2020-11-20 16:15:25.508392	5	1	\N	1	13
26	t	45694.5	41820	3874.5	2020-11-20 16:16:43.311675	5	1	\N	0	14
27	t	23595	19500	4095	2020-11-20 16:20:04.019881	7	1	\N	0	15
28	t	19300	19300	0	2020-11-20 16:24:19.850827	9	1	\N	0	16
29	t	20066.56	16448	3289.6	2020-11-20 16:37:29.658794	8	1	\N	2	17
30	t	22500	22500	0	2020-11-27 17:07:29.779989	11	1	\N	0	18
\.


--
-- TOC entry 3683 (class 0 OID 21359)
-- Dependencies: 227
-- Data for Name: datosEmpresa; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."datosEmpresa" (id, compania, direccion, cuit, logo, "tipoClave_id", idlocalidad) FROM stdin;
1	Kiogestion	Avenida Roque Perez, 1522	27-14515511-3	dd35c52c-2d04-11eb-8a6f-10c37b9bc0ef_sep_logo.jpg	2	1
\.


--
-- TOC entry 3730 (class 0 OID 39325)
-- Dependencies: 274
-- Data for Name: datosFormaPagos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."datosFormaPagos" (id, "numeroCupon", credito, cuotas, "companiaTarjeta_id", formadepago_id) FROM stdin;
6	1253453315	f	0	2	13
7	131532	f	0	1	16
8	15434	f	0	1	18
9	1244	f	0	1	23
10	313513	f	0	1	26
\.


--
-- TOC entry 3718 (class 0 OID 39070)
-- Dependencies: 262
-- Data for Name: datosFormaPagosCompra; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."datosFormaPagosCompra" (id, "numeroCupon", credito, cuotas, "companiaTarjeta_id", formadepago_id) FROM stdin;
\.


--
-- TOC entry 3728 (class 0 OID 39307)
-- Dependencies: 272
-- Data for Name: forma_pago_venta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.forma_pago_venta (id, monto, venta_id, formadepago_id) FROM stdin;
10	662.23	10	1
11	311.45	11	1
12	500	12	1
13	5074.82	12	2
14	336.37	13	1
15	235.94	14	1
16	3290.3	15	2
17	1000	16	1
18	124.75999999999999	16	2
19	375.8	17	1
20	1726.01	18	1
21	1000.7	19	1
22	100	20	1
23	1064.02	20	2
24	47.19	21	1
25	471.9	22	1
26	486.2	23	2
27	432.25	24	1
28	702	25	1
29	1651.58	26	1
30	1320.15	27	1
31	552.07	28	1
\.


--
-- TOC entry 3685 (class 0 OID 21377)
-- Dependencies: 229
-- Data for Name: formadepago; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.formadepago (id, "Metodo") FROM stdin;
1	Contado
2	Tarjeta
\.


--
-- TOC entry 3687 (class 0 OID 21382)
-- Dependencies: 231
-- Data for Name: localidad; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.localidad (idlocalidad, localidad) FROM stdin;
1	Apostoles
2	Posadas
3	Obera
\.


--
-- TOC entry 3689 (class 0 OID 21387)
-- Dependencies: 233
-- Data for Name: marcas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.marcas (id, marca) FROM stdin;
1	GUARANI
2	FANTA
3	ROMANCE
4	CAÑUELAS
5	COCA COLA
6	REX
7	SALADIX
8	SPRITE
9	HEIGTH
10	IMPERIAL
11	CORONA
12	MILLER
13	FAVORITAS
15	MALBORO
17	MALBEC
18	TERMIDOR
19	UVITA
20	COTTO
25	AS DE BASTOS
28	MANTULAK
29	COLOSAL
30	ILOLAY
31	NATURA
32	NATIVO
33	AYUDIN
34	LEDESMA
35	PEPSI
36	CRUSH
37	KESITAS
38	MEDIATARDE
39	INDIAS
40	DOS ANCLAS
41	DANICA
42	OKEY
43	COINCO
44	NOEL
45	BRANCA
46	CAPRI
47	VTTONE
48	EMETH
50	ONETA
51	MARBELLA
53	TANG
54	ALA
55	MAGISTRAL
56	ZORRO
57	GRAMBLE
58	SUSTENTO
\.


--
-- TOC entry 3705 (class 0 OID 38701)
-- Dependencies: 249
-- Data for Name: modulos_configuracion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.modulos_configuracion (id, modulo_pedido, dias_pedido, dias_atras, porcentaje_ventas, fecha_vencimiento, modulo_ofertas_whatsapp, dias_oferta, fecha_vencimiento_oferta, porcentaje_subida_precio, twilio_account_sid, twilio_auth_token, descuento) FROM stdin;
1	t	7	30	80	7	t	7	14	30	ACf1f795288eef0800ecd20d4b8baf966f	bc1eae95cabc327d5175311b4d1594fb	30
\.


--
-- TOC entry 3720 (class 0 OID 39151)
-- Dependencies: 264
-- Data for Name: oferta_whatsapp; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.oferta_whatsapp (id, fecha, expiracion, producto_id, cliente_id, descuento, cantidad, "totalNeto", totaliva, percepcion, percepcion_porcentaje, hash_activacion, reservado, vendido, renglon_compra_id) FROM stdin;
100	2020-12-01 18:52:16.804635	2020-12-01 19:52:16.804635	34	2356	30	0	0	0	0	0	qkqtzyzy	f	f	50
101	2020-12-01 18:52:20.513759	2020-12-01 19:52:20.513759	34	2356	30	0	0	0	0	0	zdllftxt	f	f	50
102	2020-12-01 18:52:23.805587	2020-12-01 19:52:23.805587	34	2356	30	0	0	0	0	0	vwdqkeoc	f	f	50
103	2020-12-01 18:52:27.490977	2020-12-01 19:52:27.490977	34	2356	30	0	0	0	0	0	irebaqpu	f	f	50
104	2020-12-01 18:52:30.795404	2020-12-01 19:52:30.795404	34	2356	30	0	0	0	0	0	ihhrebqd	f	f	50
\.


--
-- TOC entry 3691 (class 0 OID 21397)
-- Dependencies: 235
-- Data for Name: operacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.operacion (id, name) FROM stdin;
13	INSERT
14	UPDATE
15	DELETE
\.


--
-- TOC entry 3722 (class 0 OID 39216)
-- Dependencies: 266
-- Data for Name: pedido_cliente; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pedido_cliente (id, fecha, expiracion, vendido, hash_activacion, cliente_id, reservado, venta_id) FROM stdin;
\.


--
-- TOC entry 3707 (class 0 OID 38746)
-- Dependencies: 251
-- Data for Name: pedido_proveedor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pedido_proveedor (id, fecha, proveedor_id) FROM stdin;
\.


--
-- TOC entry 3711 (class 0 OID 38876)
-- Dependencies: 255
-- Data for Name: productos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) FROM stdin;
27	t	39	500	21	2	40	34	250	
30	t	52	230	21	2	39	39	50	
18	t	195	121	21	1	2	2	2	
24	t	97.5	123	21	2	38	3	330	
19	t	117	98	21	1	5	2	1	
14	t	0	0	21	1	32	4	1	TINTO
15	t	0	0	21	1	32	4	1	BLANCO
28	t	0	0	11	2	40	35	25	
31	f	0	0	21	1	1	1	\N	
16	t	0	0	21	1	33	19	1	
29	t	0	0	21	2	39	37	25	
8	f	0	0	12	3	4	11	1	000
11	t	0	0	21	3	29	15	1	
36	t	90	0	20	2	44	22	390	ENTERO
37	t	170	0	20	2	51	23	300	
39	t	18	0	20	2	53	25	20	MANZANA
40	t	18	0	20	2	53	25	20	LIMON
42	t	20	0	20	2	53	25	20	NARANJA
43	t	65	0	10	5	54	26	700	
45	t	55	0	10	5	56	26	300	
46	t	110	0	20	2	54	27	800	
47	t	60	0	21	2	54	27	400	
48	t	110	0	20	2	56	27	800	
32	t	130	40	20	2	48	21	390	
35	t	123.5	40	20	2	44	21	390	CIRUELA
25	t	39	25	21	2	39	32	25	
10	t	87.1	50	21	3	28	14	1	
34	t	123.5	40	20	2	44	21	390	NARANJA
38	t	260	30	20	2	43	24	230	
1	t	65	98	10	2	13	13	500	ESPAGUETI
13	t	143	80	21	5	31	17	900	
7	t	156	43	10	2	25	1	250	
33	t	130	48	20	2	48	21	450	FRUTOS DEL BOSQUE
2	t	65	100	10	2	13	13	500	CODITO
4	t	65	100	10	2	13	13	500	SOPERO
12	t	97.5	293	21	1	30	16	1	
17	t	97.5	25	21	4	34	20	1	
20	t	117	123	0	1	5	2	1	LIGTH
26	t	97.5	10	21	2	40	33	80	
22	t	130	123	0	1	8	2	1	
44	t	117	44	20	5	55	26	300	
23	t	97.5	130	21	2	6	3	125	
3	t	65	94	10	2	13	13	500	TIRABUZON
9	t	78	45	21	2	4	11	500	LEUDANTE
6	t	364	20	10	3	3	1	1	
5	t	182	40	20	2	3	1	500	
\.


--
-- TOC entry 3692 (class 0 OID 21405)
-- Dependencies: 236
-- Data for Name: proveedor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.proveedor (id, cuit, nombre, apellido, domicilio, estado, "tipoClave_id", "idTipoPersona", ranking, idlocalidad, direccion, telefono_celular, correo) FROM stdin;
5	30-13453456-3	Cortencio	Retondo	\N	t	2	1	0	\N		\N	\N
7	27-11077410-4	Uriel	Dosantos	\N	t	2	1	0	\N		\N	\N
10	20-95279133-9	ALSIDIO	BENITEZ	\N	f	2	1	0	\N	\N	\N	\N
4	20-41091788-3	enrique	sand	\N	t	4	1	0	2	casa 55 barrio san justo	\N	\N
8	27-14515511-3	odulio	cortez	\N	f	2	2	0	\N		\N	\N
6	30-99924708-9	barselo	ricargdino	\N	t	3	1	0	\N	junin 1649	\N	\N
11	20-17662132-0	MARTIN	ARJONA	\N	t	3	1	0	\N		\N	\N
9	27-06690501-8	SILVIA	BEATRIZ	\N	t	4	1	0	\N		\N	hereg11388@yektara.com
\.


--
-- TOC entry 3726 (class 0 OID 39269)
-- Dependencies: 270
-- Data for Name: renglon; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.renglon (id, "precioVenta", cantidad, venta_id, producto_id, descuento) FROM stdin;
10	143	2	10	13	0
11	87.1	3	10	10	0
12	52	5	11	30	1
13	97.5	4	12	17	0
14	97.5	42	12	24	0
15	123.5	1	12	34	0
16	97.5	1	13	24	0
17	182	1	13	5	0
18	97.5	2	14	24	0
19	143	10	15	13	0
20	130	10	15	33	0
21	39	4	16	25	0
22	260	3	16	38	0
23	52	1	17	30	0
24	65	2	17	3	0
25	117	2	17	19	40
26	39	4	18	27	0
27	65	5	18	2	0
28	195	5	18	18	0
29	87.1	4	19	10	4
30	78	4	19	9	4
31	195	1	19	18	1
32	39	10	20	27	0
33	52	11	20	30	0
34	39	1	21	27	0
35	195	2	22	18	0
36	65	2	23	1	0
37	156	2	23	7	0
38	65	2	24	3	5
39	130	2	24	33	5
40	117	5	25	44	0
41	97.5	7	26	24	0
42	97.5	7	26	12	0
43	97.5	5	27	17	0
44	97.5	5	27	26	0
45	117	1	27	44	0
46	65	4	28	3	3
47	117	2	28	19	3
\.


--
-- TOC entry 3716 (class 0 OID 38961)
-- Dependencies: 260
-- Data for Name: renglon_compras; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento, fecha_vencimiento, vendido, stock_lote) FROM stdin;
23	140	50	14	13	2	\N	f	48
24	30	25	15	25	0	\N	f	21
29	200	30	20	38	0	\N	f	27
34	50	100	24	2	0	\N	f	95
25	67	50	16	10	0	\N	f	43
43	60	45	28	9	0	2020-12-29	f	41
30	40	230	21	30	0	\N	f	213
28	30	500	19	27	0	\N	f	485
38	150	123	26	18	0	2020-11-30	f	115
36	50	100	24	1	5	\N	f	98
44	120	45	28	7	0	2021-01-15	f	43
47	100	50	29	33	0	2020-12-14	f	38
41	75	130	27	24	0	2020-11-29	f	78
31	110	20	22	13	0	\N	f	20
51	75	300	30	12	0	2020-12-19	f	293
26	75	30	17	17	0	\N	f	21
27	75	15	18	26	0	\N	f	10
32	90	50	23	44	2	\N	f	44
35	50	100	24	4	0	\N	f	100
33	50	100	24	3	0	\N	f	92
37	90	100	25	19	0	\N	f	96
39	90	123	26	20	0	2020-11-23	f	123
40	100	123	26	22	0	2020-11-30	f	123
42	75	130	27	23	0	2020-11-26	f	130
45	280	20	28	6	0	2021-01-23	f	20
49	95	40	29	35	2	2020-12-15	f	40
48	100	40	29	32	0	2020-12-12	f	40
50	95	40	29	34	2	2020-12-11	f	39
46	140	40	28	5	0	2021-01-19	f	39
22	135	10	13	13	1	\N	t	0
\.


--
-- TOC entry 3709 (class 0 OID 38858)
-- Dependencies: 253
-- Data for Name: renglon_pedido; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.renglon_pedido (id, cantidad, pedido_proveedor_id, producto_id) FROM stdin;
\.


--
-- TOC entry 3699 (class 0 OID 21855)
-- Dependencies: 243
-- Data for Name: tipoPersona; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."tipoPersona" ("idTipoPersona", "tipoPersona") FROM stdin;
1	Fisica
2	Juridica
\.


--
-- TOC entry 3701 (class 0 OID 21865)
-- Dependencies: 245
-- Data for Name: tiposClave; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."tiposClave" (id, "tipoClave") FROM stdin;
1	Consumidor Final
2	Responsable Inscripto
3	Monotributista
4	Exento
\.


--
-- TOC entry 3694 (class 0 OID 21436)
-- Dependencies: 238
-- Data for Name: tiposDocumentos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."tiposDocumentos" (id, "tipoDocumento") FROM stdin;
1	DNI
2	CUIT
\.


--
-- TOC entry 3696 (class 0 OID 21441)
-- Dependencies: 240
-- Data for Name: unidad_medida; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.unidad_medida (id, unidad) FROM stdin;
1	LITRO
2	GRAMOS
3	KILO
4	MILILITRO
5	CC
6	CL
\.


--
-- TOC entry 3724 (class 0 OID 39236)
-- Dependencies: 268
-- Data for Name: ventas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ventas (id, estado, fecha, "totalNeto", totaliva, total, cliente_id, percepcion, comprobante) FROM stdin;
10	t	2020-11-21	662.23	0	662.23	7735	0	1
11	t	2020-11-21	257.4	54.05	311.45	4490	0	2
12	t	2020-11-21	5574.82	0	5574.82	2356	0	3
13	t	2020-11-21	336.37	0	336.37	1	0	4
14	t	2020-11-21	235.94	0	235.94	1	0	5
15	t	2020-11-22	2730	560.3	3290.3	4781	0	6
16	t	2020-11-22	1124.76	0	1124.76	4227	0	7
17	t	2020-11-22	375.8	0	375.8	4210	0	8
18	t	2020-11-24	1726.01	0	1726.01	4205	0	9
19	t	2020-11-24	1000.7	0	1000.7	4	0	10
20	t	2020-11-27	962	202.02	1164.02	4616	0	11
21	t	2020-11-27	47.19	0	47.19	7735	0	12
22	t	2020-11-27	471.9	0	471.9	4227	0	13
23	t	2020-11-27	486.2	0	486.2	4215	0	14
24	t	2020-11-30	432.25	0	432.25	4274	0	15
25	t	2020-11-30	585	117	702	637	0	16
26	t	2020-11-30	1651.58	0	1651.58	4428	0	17
27	t	2020-11-30	1092	228.15	1320.15	4490	0	18
28	t	2020-11-30	552.07	0	552.07	2356	0	19
\.


--
-- TOC entry 3764 (class 0 OID 0)
-- Dependencies: 205
-- Name: FormadePago_Venta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."FormadePago_Venta_id_seq"', 137, true);


--
-- TOC entry 3765 (class 0 OID 0)
-- Dependencies: 207
-- Name: ab_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_permission_id_seq', 60, true);


--
-- TOC entry 3766 (class 0 OID 0)
-- Dependencies: 209
-- Name: ab_permission_view_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_permission_view_id_seq', 600, true);


--
-- TOC entry 3767 (class 0 OID 0)
-- Dependencies: 211
-- Name: ab_permission_view_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_permission_view_role_id_seq', 665, true);


--
-- TOC entry 3768 (class 0 OID 0)
-- Dependencies: 213
-- Name: ab_register_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_register_user_id_seq', 33, true);


--
-- TOC entry 3769 (class 0 OID 0)
-- Dependencies: 215
-- Name: ab_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_role_id_seq', 9, true);


--
-- TOC entry 3770 (class 0 OID 0)
-- Dependencies: 217
-- Name: ab_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_user_id_seq', 17, true);


--
-- TOC entry 3771 (class 0 OID 0)
-- Dependencies: 219
-- Name: ab_user_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_user_role_id_seq', 27, true);


--
-- TOC entry 3772 (class 0 OID 0)
-- Dependencies: 221
-- Name: ab_view_menu_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_view_menu_id_seq', 241, true);


--
-- TOC entry 3773 (class 0 OID 0)
-- Dependencies: 222
-- Name: audit_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.audit_log_id_seq', 647, true);


--
-- TOC entry 3774 (class 0 OID 0)
-- Dependencies: 224
-- Name: categoria_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categoria_id_seq', 55, true);


--
-- TOC entry 3775 (class 0 OID 0)
-- Dependencies: 226
-- Name: clientes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.clientes_id_seq', 9187, true);


--
-- TOC entry 3776 (class 0 OID 0)
-- Dependencies: 246
-- Name: companiaTarjeta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."companiaTarjeta_id_seq"', 1369, true);


--
-- TOC entry 3777 (class 0 OID 0)
-- Dependencies: 257
-- Name: compras_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.compras_id_seq', 30, true);


--
-- TOC entry 3778 (class 0 OID 0)
-- Dependencies: 228
-- Name: datosEmpresa_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."datosEmpresa_id_seq"', 974, true);


--
-- TOC entry 3779 (class 0 OID 0)
-- Dependencies: 261
-- Name: datosFormaPagosCompra_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."datosFormaPagosCompra_id_seq"', 1, false);


--
-- TOC entry 3780 (class 0 OID 0)
-- Dependencies: 273
-- Name: datosFormaPagos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."datosFormaPagos_id_seq"', 10, true);


--
-- TOC entry 3781 (class 0 OID 0)
-- Dependencies: 271
-- Name: forma_pago_venta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.forma_pago_venta_id_seq', 31, true);


--
-- TOC entry 3782 (class 0 OID 0)
-- Dependencies: 230
-- Name: formadepago_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.formadepago_id_seq', 5921, true);


--
-- TOC entry 3783 (class 0 OID 0)
-- Dependencies: 232
-- Name: localidad_idLocalidad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."localidad_idLocalidad_seq"', 3900, true);


--
-- TOC entry 3784 (class 0 OID 0)
-- Dependencies: 234
-- Name: marcas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.marcas_id_seq', 58, true);


--
-- TOC entry 3785 (class 0 OID 0)
-- Dependencies: 248
-- Name: modulos_configuracion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.modulos_configuracion_id_seq', 1, false);


--
-- TOC entry 3786 (class 0 OID 0)
-- Dependencies: 263
-- Name: oferta_whatsapp_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.oferta_whatsapp_id_seq', 104, true);


--
-- TOC entry 3787 (class 0 OID 0)
-- Dependencies: 265
-- Name: pedido_cliente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pedido_cliente_id_seq', 5, true);


--
-- TOC entry 3788 (class 0 OID 0)
-- Dependencies: 250
-- Name: pedido_proveedor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pedido_proveedor_id_seq', 30, true);


--
-- TOC entry 3789 (class 0 OID 0)
-- Dependencies: 254
-- Name: productos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.productos_id_seq', 48, true);


--
-- TOC entry 3790 (class 0 OID 0)
-- Dependencies: 237
-- Name: proveedor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.proveedor_id_seq', 11, true);


--
-- TOC entry 3791 (class 0 OID 0)
-- Dependencies: 259
-- Name: renglon_compras_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.renglon_compras_id_seq', 51, true);


--
-- TOC entry 3792 (class 0 OID 0)
-- Dependencies: 269
-- Name: renglon_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.renglon_id_seq', 47, true);


--
-- TOC entry 3793 (class 0 OID 0)
-- Dependencies: 252
-- Name: renglon_pedido_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.renglon_pedido_id_seq', 94, true);


--
-- TOC entry 3794 (class 0 OID 0)
-- Dependencies: 242
-- Name: tipoPersona_idTipoPersona_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."tipoPersona_idTipoPersona_seq"', 1379, true);


--
-- TOC entry 3795 (class 0 OID 0)
-- Dependencies: 244
-- Name: tiposClave_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."tiposClave_id_seq"', 2725, true);


--
-- TOC entry 3796 (class 0 OID 0)
-- Dependencies: 239
-- Name: tiposDocumentos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."tiposDocumentos_id_seq"', 5413, true);


--
-- TOC entry 3797 (class 0 OID 0)
-- Dependencies: 241
-- Name: unidad_medida_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.unidad_medida_id_seq', 6, true);


--
-- TOC entry 3798 (class 0 OID 0)
-- Dependencies: 267
-- Name: ventas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ventas_id_seq', 28, true);


--
-- TOC entry 3353 (class 2606 OID 21477)
-- Name: FormadePago_Venta FormadePago_Venta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FormadePago_Venta"
    ADD CONSTRAINT "FormadePago_Venta_pkey" PRIMARY KEY (id);


--
-- TOC entry 3355 (class 2606 OID 21479)
-- Name: ab_permission ab_permission_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission
    ADD CONSTRAINT ab_permission_name_key UNIQUE (name);


--
-- TOC entry 3357 (class 2606 OID 21481)
-- Name: ab_permission ab_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission
    ADD CONSTRAINT ab_permission_pkey PRIMARY KEY (id);


--
-- TOC entry 3359 (class 2606 OID 21483)
-- Name: ab_permission_view ab_permission_view_permission_id_view_menu_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_permission_id_view_menu_id_key UNIQUE (permission_id, view_menu_id);


--
-- TOC entry 3361 (class 2606 OID 21485)
-- Name: ab_permission_view ab_permission_view_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_pkey PRIMARY KEY (id);


--
-- TOC entry 3363 (class 2606 OID 21487)
-- Name: ab_permission_view_role ab_permission_view_role_permission_view_id_role_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_permission_view_id_role_id_key UNIQUE (permission_view_id, role_id);


--
-- TOC entry 3365 (class 2606 OID 21489)
-- Name: ab_permission_view_role ab_permission_view_role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_pkey PRIMARY KEY (id);


--
-- TOC entry 3367 (class 2606 OID 21491)
-- Name: ab_register_user ab_register_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_register_user
    ADD CONSTRAINT ab_register_user_pkey PRIMARY KEY (id);


--
-- TOC entry 3369 (class 2606 OID 21493)
-- Name: ab_register_user ab_register_user_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_register_user
    ADD CONSTRAINT ab_register_user_username_key UNIQUE (username);


--
-- TOC entry 3371 (class 2606 OID 21495)
-- Name: ab_role ab_role_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_role
    ADD CONSTRAINT ab_role_name_key UNIQUE (name);


--
-- TOC entry 3373 (class 2606 OID 21497)
-- Name: ab_role ab_role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_role
    ADD CONSTRAINT ab_role_pkey PRIMARY KEY (id);


--
-- TOC entry 3375 (class 2606 OID 21499)
-- Name: ab_user ab_user_cuil_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_cuil_key UNIQUE (cuil);


--
-- TOC entry 3377 (class 2606 OID 21501)
-- Name: ab_user ab_user_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_email_key UNIQUE (email);


--
-- TOC entry 3379 (class 2606 OID 21503)
-- Name: ab_user ab_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_pkey PRIMARY KEY (id);


--
-- TOC entry 3383 (class 2606 OID 21505)
-- Name: ab_user_role ab_user_role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_pkey PRIMARY KEY (id);


--
-- TOC entry 3385 (class 2606 OID 21507)
-- Name: ab_user_role ab_user_role_user_id_role_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_user_id_role_id_key UNIQUE (user_id, role_id);


--
-- TOC entry 3381 (class 2606 OID 21509)
-- Name: ab_user ab_user_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_username_key UNIQUE (username);


--
-- TOC entry 3387 (class 2606 OID 21511)
-- Name: ab_view_menu ab_view_menu_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_view_menu
    ADD CONSTRAINT ab_view_menu_name_key UNIQUE (name);


--
-- TOC entry 3389 (class 2606 OID 21513)
-- Name: ab_view_menu ab_view_menu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_view_menu
    ADD CONSTRAINT ab_view_menu_pkey PRIMARY KEY (id);


--
-- TOC entry 3463 (class 2606 OID 38906)
-- Name: auditoria auditoria_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria
    ADD CONSTRAINT auditoria_pkey PRIMARY KEY (id);


--
-- TOC entry 3391 (class 2606 OID 21517)
-- Name: categoria categoria_categoria_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_categoria_key UNIQUE (categoria);


--
-- TOC entry 3393 (class 2606 OID 21519)
-- Name: categoria categoria_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_pkey PRIMARY KEY (id);


--
-- TOC entry 3395 (class 2606 OID 21521)
-- Name: clientes clientes_documento_tipoDocumento_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT "clientes_documento_tipoDocumento_id_key" UNIQUE (documento, "tipoDocumento_id");


--
-- TOC entry 3397 (class 2606 OID 21523)
-- Name: clientes clientes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (id);


--
-- TOC entry 3449 (class 2606 OID 22153)
-- Name: companiaTarjeta companiaTarjeta_compania_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."companiaTarjeta"
    ADD CONSTRAINT "companiaTarjeta_compania_key" UNIQUE (compania);


--
-- TOC entry 3451 (class 2606 OID 22151)
-- Name: companiaTarjeta companiaTarjeta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."companiaTarjeta"
    ADD CONSTRAINT "companiaTarjeta_pkey" PRIMARY KEY (id);


--
-- TOC entry 3465 (class 2606 OID 38943)
-- Name: compras compras_comprobante_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_comprobante_key UNIQUE (comprobante);


--
-- TOC entry 3467 (class 2606 OID 38941)
-- Name: compras compras_comprobante_proveedor_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_comprobante_proveedor_id_key UNIQUE (comprobante, proveedor_id);


--
-- TOC entry 3469 (class 2606 OID 38939)
-- Name: compras compras_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_pkey PRIMARY KEY (id);


--
-- TOC entry 3425 (class 2606 OID 39375)
-- Name: proveedor correo_proveedor_unico; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT correo_proveedor_unico UNIQUE (correo);


--
-- TOC entry 3401 (class 2606 OID 21533)
-- Name: datosEmpresa datosEmpresa_compania_direccion_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_compania_direccion_key" UNIQUE (compania, direccion);


--
-- TOC entry 3403 (class 2606 OID 21535)
-- Name: datosEmpresa datosEmpresa_compania_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_compania_key" UNIQUE (compania);


--
-- TOC entry 3405 (class 2606 OID 21537)
-- Name: datosEmpresa datosEmpresa_cuit_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_cuit_key" UNIQUE (cuit);


--
-- TOC entry 3407 (class 2606 OID 21539)
-- Name: datosEmpresa datosEmpresa_direccion_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_direccion_key" UNIQUE (direccion);


--
-- TOC entry 3409 (class 2606 OID 21541)
-- Name: datosEmpresa datosEmpresa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_pkey" PRIMARY KEY (id);


--
-- TOC entry 3473 (class 2606 OID 39077)
-- Name: datosFormaPagosCompra datosFormaPagosCompra_numeroCupon_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagosCompra"
    ADD CONSTRAINT "datosFormaPagosCompra_numeroCupon_key" UNIQUE ("numeroCupon");


--
-- TOC entry 3475 (class 2606 OID 39075)
-- Name: datosFormaPagosCompra datosFormaPagosCompra_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagosCompra"
    ADD CONSTRAINT "datosFormaPagosCompra_pkey" PRIMARY KEY (id);


--
-- TOC entry 3491 (class 2606 OID 39332)
-- Name: datosFormaPagos datosFormaPagos_numeroCupon_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagos"
    ADD CONSTRAINT "datosFormaPagos_numeroCupon_key" UNIQUE ("numeroCupon");


--
-- TOC entry 3493 (class 2606 OID 39330)
-- Name: datosFormaPagos datosFormaPagos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagos"
    ADD CONSTRAINT "datosFormaPagos_pkey" PRIMARY KEY (id);


--
-- TOC entry 3489 (class 2606 OID 39312)
-- Name: forma_pago_venta forma_pago_venta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.forma_pago_venta
    ADD CONSTRAINT forma_pago_venta_pkey PRIMARY KEY (id);


--
-- TOC entry 3411 (class 2606 OID 21551)
-- Name: formadepago formadepago_Metodo_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.formadepago
    ADD CONSTRAINT "formadepago_Metodo_key" UNIQUE ("Metodo");


--
-- TOC entry 3413 (class 2606 OID 21553)
-- Name: formadepago formadepago_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.formadepago
    ADD CONSTRAINT formadepago_pkey PRIMARY KEY (id);


--
-- TOC entry 3415 (class 2606 OID 21555)
-- Name: localidad localidad_localidad_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.localidad
    ADD CONSTRAINT localidad_localidad_key UNIQUE (localidad);


--
-- TOC entry 3417 (class 2606 OID 21557)
-- Name: localidad localidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.localidad
    ADD CONSTRAINT localidad_pkey PRIMARY KEY (idlocalidad);


--
-- TOC entry 3419 (class 2606 OID 21559)
-- Name: marcas marcas_marca_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marcas
    ADD CONSTRAINT marcas_marca_key UNIQUE (marca);


--
-- TOC entry 3421 (class 2606 OID 21561)
-- Name: marcas marcas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marcas
    ADD CONSTRAINT marcas_pkey PRIMARY KEY (id);


--
-- TOC entry 3453 (class 2606 OID 38706)
-- Name: modulos_configuracion modulos_configuracion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modulos_configuracion
    ADD CONSTRAINT modulos_configuracion_pkey PRIMARY KEY (id);


--
-- TOC entry 3477 (class 2606 OID 39156)
-- Name: oferta_whatsapp oferta_whatsapp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oferta_whatsapp
    ADD CONSTRAINT oferta_whatsapp_pkey PRIMARY KEY (id);


--
-- TOC entry 3423 (class 2606 OID 21565)
-- Name: operacion operacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.operacion
    ADD CONSTRAINT operacion_pkey PRIMARY KEY (id);


--
-- TOC entry 3479 (class 2606 OID 39223)
-- Name: pedido_cliente pedido_cliente_hash_activacion_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedido_cliente
    ADD CONSTRAINT pedido_cliente_hash_activacion_key UNIQUE (hash_activacion);


--
-- TOC entry 3481 (class 2606 OID 39221)
-- Name: pedido_cliente pedido_cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedido_cliente
    ADD CONSTRAINT pedido_cliente_pkey PRIMARY KEY (id);


--
-- TOC entry 3455 (class 2606 OID 38751)
-- Name: pedido_proveedor pedido_proveedor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedido_proveedor
    ADD CONSTRAINT pedido_proveedor_pkey PRIMARY KEY (id);


--
-- TOC entry 3459 (class 2606 OID 38883)
-- Name: productos productos_categoria_id_marcas_id_unidad_id_medida_detalle_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_categoria_id_marcas_id_unidad_id_medida_detalle_key UNIQUE (categoria_id, marcas_id, unidad_id, medida, detalle);


--
-- TOC entry 3461 (class 2606 OID 38881)
-- Name: productos productos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_pkey PRIMARY KEY (id);


--
-- TOC entry 3427 (class 2606 OID 21571)
-- Name: proveedor proveedor_cuit_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT proveedor_cuit_key UNIQUE (cuit);


--
-- TOC entry 3429 (class 2606 OID 21573)
-- Name: proveedor proveedor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT proveedor_pkey PRIMARY KEY (id);


--
-- TOC entry 3471 (class 2606 OID 38966)
-- Name: renglon_compras renglon_compras_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_compras
    ADD CONSTRAINT renglon_compras_pkey PRIMARY KEY (id);


--
-- TOC entry 3457 (class 2606 OID 38863)
-- Name: renglon_pedido renglon_pedido_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_pedido
    ADD CONSTRAINT renglon_pedido_pkey PRIMARY KEY (id);


--
-- TOC entry 3487 (class 2606 OID 39274)
-- Name: renglon renglon_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon
    ADD CONSTRAINT renglon_pkey PRIMARY KEY (id);


--
-- TOC entry 3431 (class 2606 OID 39363)
-- Name: proveedor telefono_proveedor_unico; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT telefono_proveedor_unico UNIQUE (telefono_celular);


--
-- TOC entry 3399 (class 2606 OID 39361)
-- Name: clientes telefono_unico; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT telefono_unico UNIQUE (telefono_celular);


--
-- TOC entry 3441 (class 2606 OID 21860)
-- Name: tipoPersona tipoPersona_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tipoPersona"
    ADD CONSTRAINT "tipoPersona_pkey" PRIMARY KEY ("idTipoPersona");


--
-- TOC entry 3443 (class 2606 OID 21862)
-- Name: tipoPersona tipoPersona_tipoPersona_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tipoPersona"
    ADD CONSTRAINT "tipoPersona_tipoPersona_key" UNIQUE ("tipoPersona");


--
-- TOC entry 3445 (class 2606 OID 21870)
-- Name: tiposClave tiposClave_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tiposClave"
    ADD CONSTRAINT "tiposClave_pkey" PRIMARY KEY (id);


--
-- TOC entry 3447 (class 2606 OID 21872)
-- Name: tiposClave tiposClave_tipoClave_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tiposClave"
    ADD CONSTRAINT "tiposClave_tipoClave_key" UNIQUE ("tipoClave");


--
-- TOC entry 3433 (class 2606 OID 21587)
-- Name: tiposDocumentos tiposDocumentos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tiposDocumentos"
    ADD CONSTRAINT "tiposDocumentos_pkey" PRIMARY KEY (id);


--
-- TOC entry 3435 (class 2606 OID 21589)
-- Name: tiposDocumentos tiposDocumentos_tipoDocumento_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tiposDocumentos"
    ADD CONSTRAINT "tiposDocumentos_tipoDocumento_key" UNIQUE ("tipoDocumento");


--
-- TOC entry 3437 (class 2606 OID 21591)
-- Name: unidad_medida unidad_medida_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unidad_medida
    ADD CONSTRAINT unidad_medida_pkey PRIMARY KEY (id);


--
-- TOC entry 3439 (class 2606 OID 21593)
-- Name: unidad_medida unidad_medida_unidad_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unidad_medida
    ADD CONSTRAINT unidad_medida_unidad_key UNIQUE (unidad);


--
-- TOC entry 3483 (class 2606 OID 39243)
-- Name: ventas ventas_comprobante_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_comprobante_key UNIQUE (comprobante);


--
-- TOC entry 3485 (class 2606 OID 39241)
-- Name: ventas ventas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_pkey PRIMARY KEY (id);


--
-- TOC entry 3531 (class 2620 OID 39346)
-- Name: renglon_compras updateproductoscompra; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER updateproductoscompra AFTER INSERT ON public.renglon_compras FOR EACH ROW EXECUTE FUNCTION public.sumarstockencompra();


--
-- TOC entry 3530 (class 2620 OID 39350)
-- Name: compras updateproductoscompranulada; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER updateproductoscompranulada AFTER UPDATE ON public.compras FOR EACH ROW EXECUTE FUNCTION public.actualiarstockencompranulada();


--
-- TOC entry 3533 (class 2620 OID 39344)
-- Name: renglon updateproductosventa; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER updateproductosventa AFTER INSERT ON public.renglon FOR EACH ROW EXECUTE FUNCTION public.descontarstockenventa();


--
-- TOC entry 3532 (class 2620 OID 39348)
-- Name: ventas updateproductosventanulada; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER updateproductosventanulada AFTER UPDATE ON public.ventas FOR EACH ROW EXECUTE FUNCTION public.sumarstockenventanulada();


--
-- TOC entry 3494 (class 2606 OID 21602)
-- Name: FormadePago_Venta FormadePago_Venta_formadepago_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FormadePago_Venta"
    ADD CONSTRAINT "FormadePago_Venta_formadepago_id_fkey" FOREIGN KEY (formadepago_id) REFERENCES public.formadepago(id);


--
-- TOC entry 3495 (class 2606 OID 21612)
-- Name: ab_permission_view ab_permission_view_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.ab_permission(id);


--
-- TOC entry 3497 (class 2606 OID 21617)
-- Name: ab_permission_view_role ab_permission_view_role_permission_view_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_permission_view_id_fkey FOREIGN KEY (permission_view_id) REFERENCES public.ab_permission_view(id);


--
-- TOC entry 3498 (class 2606 OID 21622)
-- Name: ab_permission_view_role ab_permission_view_role_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.ab_role(id);


--
-- TOC entry 3496 (class 2606 OID 21627)
-- Name: ab_permission_view ab_permission_view_view_menu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_view_menu_id_fkey FOREIGN KEY (view_menu_id) REFERENCES public.ab_view_menu(id);


--
-- TOC entry 3499 (class 2606 OID 21632)
-- Name: ab_user ab_user_changed_by_fk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_changed_by_fk_fkey FOREIGN KEY (changed_by_fk) REFERENCES public.ab_user(id);


--
-- TOC entry 3500 (class 2606 OID 21637)
-- Name: ab_user ab_user_created_by_fk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_created_by_fk_fkey FOREIGN KEY (created_by_fk) REFERENCES public.ab_user(id);


--
-- TOC entry 3501 (class 2606 OID 21642)
-- Name: ab_user_role ab_user_role_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.ab_role(id);


--
-- TOC entry 3502 (class 2606 OID 21647)
-- Name: ab_user_role ab_user_role_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.ab_user(id);


--
-- TOC entry 3512 (class 2606 OID 38907)
-- Name: auditoria auditoria_operation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria
    ADD CONSTRAINT auditoria_operation_id_fkey FOREIGN KEY (operation_id) REFERENCES public.operacion(id);


--
-- TOC entry 3503 (class 2606 OID 21667)
-- Name: clientes clientes_tipoDocumento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT "clientes_tipoDocumento_id_fkey" FOREIGN KEY ("tipoDocumento_id") REFERENCES public."tiposDocumentos"(id);


--
-- TOC entry 3514 (class 2606 OID 38949)
-- Name: compras compras_formadepago_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_formadepago_id_fkey FOREIGN KEY (formadepago_id) REFERENCES public.formadepago(id);


--
-- TOC entry 3513 (class 2606 OID 38944)
-- Name: compras compras_proveedor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_proveedor_id_fkey FOREIGN KEY (proveedor_id) REFERENCES public.proveedor(id);


--
-- TOC entry 3505 (class 2606 OID 21687)
-- Name: datosEmpresa datosEmpresa_idlocalidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_idlocalidad_fkey" FOREIGN KEY (idlocalidad) REFERENCES public.localidad(idlocalidad);


--
-- TOC entry 3517 (class 2606 OID 39078)
-- Name: datosFormaPagosCompra datosFormaPagosCompra_companiaTarjeta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagosCompra"
    ADD CONSTRAINT "datosFormaPagosCompra_companiaTarjeta_id_fkey" FOREIGN KEY ("companiaTarjeta_id") REFERENCES public."companiaTarjeta"(id);


--
-- TOC entry 3518 (class 2606 OID 39083)
-- Name: datosFormaPagosCompra datosFormaPagosCompra_formadepago_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagosCompra"
    ADD CONSTRAINT "datosFormaPagosCompra_formadepago_id_fkey" FOREIGN KEY (formadepago_id) REFERENCES public.formadepago(id);


--
-- TOC entry 3528 (class 2606 OID 39333)
-- Name: datosFormaPagos datosFormaPagos_companiaTarjeta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagos"
    ADD CONSTRAINT "datosFormaPagos_companiaTarjeta_id_fkey" FOREIGN KEY ("companiaTarjeta_id") REFERENCES public."companiaTarjeta"(id);


--
-- TOC entry 3529 (class 2606 OID 39338)
-- Name: datosFormaPagos datosFormaPagos_formadepago_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagos"
    ADD CONSTRAINT "datosFormaPagos_formadepago_id_fkey" FOREIGN KEY (formadepago_id) REFERENCES public.forma_pago_venta(id);


--
-- TOC entry 3527 (class 2606 OID 39318)
-- Name: forma_pago_venta forma_pago_venta_formadepago_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.forma_pago_venta
    ADD CONSTRAINT forma_pago_venta_formadepago_id_fkey FOREIGN KEY (formadepago_id) REFERENCES public.formadepago(id);


--
-- TOC entry 3526 (class 2606 OID 39313)
-- Name: forma_pago_venta forma_pago_venta_venta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.forma_pago_venta
    ADD CONSTRAINT forma_pago_venta_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES public.ventas(id);


--
-- TOC entry 3504 (class 2606 OID 21717)
-- Name: clientes localidad_pkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT localidad_pkey FOREIGN KEY (idlocalidad) REFERENCES public.localidad(idlocalidad);


--
-- TOC entry 3506 (class 2606 OID 21722)
-- Name: proveedor localidad_pkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT localidad_pkey FOREIGN KEY (idlocalidad) REFERENCES public.localidad(idlocalidad);


--
-- TOC entry 3520 (class 2606 OID 39162)
-- Name: oferta_whatsapp oferta_whatsapp_cliente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oferta_whatsapp
    ADD CONSTRAINT oferta_whatsapp_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id);


--
-- TOC entry 3519 (class 2606 OID 39157)
-- Name: oferta_whatsapp oferta_whatsapp_producto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oferta_whatsapp
    ADD CONSTRAINT oferta_whatsapp_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES public.productos(id);


--
-- TOC entry 3521 (class 2606 OID 39167)
-- Name: oferta_whatsapp oferta_whatsapp_renglon_compra_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oferta_whatsapp
    ADD CONSTRAINT oferta_whatsapp_renglon_compra_id_fkey FOREIGN KEY (renglon_compra_id) REFERENCES public.renglon_compras(id);


--
-- TOC entry 3522 (class 2606 OID 39224)
-- Name: pedido_cliente pedido_cliente_cliente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedido_cliente
    ADD CONSTRAINT pedido_cliente_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id);


--
-- TOC entry 3507 (class 2606 OID 38752)
-- Name: pedido_proveedor pedido_proveedor_proveedor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedido_proveedor
    ADD CONSTRAINT pedido_proveedor_proveedor_id_fkey FOREIGN KEY (proveedor_id) REFERENCES public.proveedor(id);


--
-- TOC entry 3511 (class 2606 OID 38894)
-- Name: productos productos_categoria_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_categoria_id_fkey FOREIGN KEY (categoria_id) REFERENCES public.categoria(id);


--
-- TOC entry 3510 (class 2606 OID 38889)
-- Name: productos productos_marcas_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_marcas_id_fkey FOREIGN KEY (marcas_id) REFERENCES public.marcas(id);


--
-- TOC entry 3509 (class 2606 OID 38884)
-- Name: productos productos_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad_medida(id);


--
-- TOC entry 3515 (class 2606 OID 38967)
-- Name: renglon_compras renglon_compras_compra_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_compras
    ADD CONSTRAINT renglon_compras_compra_id_fkey FOREIGN KEY (compra_id) REFERENCES public.compras(id);


--
-- TOC entry 3516 (class 2606 OID 38972)
-- Name: renglon_compras renglon_compras_producto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_compras
    ADD CONSTRAINT renglon_compras_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES public.productos(id);


--
-- TOC entry 3508 (class 2606 OID 38864)
-- Name: renglon_pedido renglon_pedido_pedido_proveedor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_pedido
    ADD CONSTRAINT renglon_pedido_pedido_proveedor_id_fkey FOREIGN KEY (pedido_proveedor_id) REFERENCES public.pedido_proveedor(id);


--
-- TOC entry 3525 (class 2606 OID 39280)
-- Name: renglon renglon_producto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon
    ADD CONSTRAINT renglon_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES public.productos(id);


--
-- TOC entry 3524 (class 2606 OID 39275)
-- Name: renglon renglon_venta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon
    ADD CONSTRAINT renglon_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES public.ventas(id);


--
-- TOC entry 3523 (class 2606 OID 39244)
-- Name: ventas ventas_cliente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id);


-- Completed on 2020-12-01 19:01:17

--
-- PostgreSQL database dump complete
--

