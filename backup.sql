--
-- PostgreSQL database dump
--

-- Dumped from database version 12.2
-- Dumped by pg_dump version 12.2

-- Started on 2020-11-07 09:45:03

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
-- TOC entry 3228 (class 1262 OID 73733)
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
-- TOC entry 723 (class 1247 OID 166904)
-- Name: companiatarjeta; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.companiatarjeta AS ENUM (
    'visa',
    'mastercard',
    'naranja'
);


ALTER TYPE public.companiatarjeta OWNER TO postgres;

--
-- TOC entry 730 (class 1247 OID 166922)
-- Name: metodospagos; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.metodospagos AS ENUM (
    'tarjeta',
    'contado'
);


ALTER TYPE public.metodospagos OWNER TO postgres;

--
-- TOC entry 713 (class 1247 OID 134040)
-- Name: tipoclaves; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.tipoclaves AS ENUM (
    'consumidorFinal',
    'responsableInscripto',
    'monotributista'
);


ALTER TYPE public.tipoclaves OWNER TO postgres;

--
-- TOC entry 716 (class 1247 OID 134106)
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
-- TOC entry 274 (class 1255 OID 208440)
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
-- TOC entry 259 (class 1255 OID 208434)
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
-- TOC entry 260 (class 1255 OID 208436)
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
-- TOC entry 273 (class 1255 OID 208438)
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
-- TOC entry 3229 (class 0 OID 0)
-- Dependencies: 251
-- Name: FormadePago_Venta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."FormadePago_Venta_id_seq" OWNED BY public."FormadePago_Venta".id;


--
-- TOC entry 220 (class 1259 OID 183299)
-- Name: ab_permission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_permission (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.ab_permission OWNER TO postgres;

--
-- TOC entry 202 (class 1259 OID 100450)
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
-- TOC entry 225 (class 1259 OID 183354)
-- Name: ab_permission_view; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_permission_view (
    id integer NOT NULL,
    permission_id integer,
    view_menu_id integer
);


ALTER TABLE public.ab_permission_view OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 100513)
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
-- TOC entry 227 (class 1259 OID 183388)
-- Name: ab_permission_view_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_permission_view_role (
    id integer NOT NULL,
    permission_view_id integer,
    role_id integer
);


ALTER TABLE public.ab_permission_view_role OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 100551)
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
-- TOC entry 224 (class 1259 OID 183344)
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
-- TOC entry 206 (class 1259 OID 100501)
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
-- TOC entry 222 (class 1259 OID 183313)
-- Name: ab_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_role (
    id integer NOT NULL,
    name character varying(64) NOT NULL
);


ALTER TABLE public.ab_role OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 100468)
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
-- TOC entry 223 (class 1259 OID 183320)
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
-- TOC entry 205 (class 1259 OID 100477)
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
-- TOC entry 226 (class 1259 OID 183371)
-- Name: ab_user_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_user_role (
    id integer NOT NULL,
    user_id integer,
    role_id integer
);


ALTER TABLE public.ab_user_role OWNER TO postgres;

--
-- TOC entry 208 (class 1259 OID 100532)
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
-- TOC entry 221 (class 1259 OID 183306)
-- Name: ab_view_menu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_view_menu (
    id integer NOT NULL,
    name character varying(250) NOT NULL
);


ALTER TABLE public.ab_view_menu OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 100459)
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
-- TOC entry 234 (class 1259 OID 191690)
-- Name: audit_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_log (
    id integer NOT NULL,
    message character varying(300) NOT NULL,
    username character varying(64) NOT NULL,
    created_on timestamp without time zone,
    operation_id integer NOT NULL,
    target character varying(150) NOT NULL
);


ALTER TABLE public.audit_log OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 191683)
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
-- TOC entry 215 (class 1259 OID 166824)
-- Name: categoria; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categoria (
    id integer NOT NULL,
    categoria character varying(50) NOT NULL
);


ALTER TABLE public.categoria OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 166822)
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
-- TOC entry 3230 (class 0 OID 0)
-- Dependencies: 214
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
-- TOC entry 3231 (class 0 OID 0)
-- Dependencies: 241
-- Name: clientes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.clientes_id_seq OWNED BY public.clientes.id;


--
-- TOC entry 217 (class 1259 OID 174960)
-- Name: companiaTarjeta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."companiaTarjeta" (
    id integer NOT NULL,
    compania character varying(50)
);


ALTER TABLE public."companiaTarjeta" OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 174958)
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
-- TOC entry 3232 (class 0 OID 0)
-- Dependencies: 216
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
-- TOC entry 3233 (class 0 OID 0)
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
-- TOC entry 3234 (class 0 OID 0)
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
-- TOC entry 3235 (class 0 OID 0)
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
-- TOC entry 3236 (class 0 OID 0)
-- Dependencies: 255
-- Name: datosFormaPagos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."datosFormaPagos_id_seq" OWNED BY public."datosFormaPagos".id;


--
-- TOC entry 219 (class 1259 OID 183168)
-- Name: formadepago; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.formadepago (
    id integer NOT NULL,
    "Metodo" character varying(50)
);


ALTER TABLE public.formadepago OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 183166)
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
-- TOC entry 3237 (class 0 OID 0)
-- Dependencies: 218
-- Name: formadepago_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.formadepago_id_seq OWNED BY public.formadepago.id;


--
-- TOC entry 213 (class 1259 OID 101175)
-- Name: marcas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.marcas (
    id integer NOT NULL,
    marca character varying(50) NOT NULL
);


ALTER TABLE public.marcas OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 101173)
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
-- TOC entry 3238 (class 0 OID 0)
-- Dependencies: 212
-- Name: marcas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.marcas_id_seq OWNED BY public.marcas.id;


--
-- TOC entry 233 (class 1259 OID 191685)
-- Name: operation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.operation (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.operation OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 191841)
-- Name: productos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.productos (
    id integer NOT NULL,
    estado boolean,
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
-- TOC entry 3239 (class 0 OID 0)
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
    "idTipoPersona" integer NOT NULL
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
-- TOC entry 3240 (class 0 OID 0)
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
-- TOC entry 3241 (class 0 OID 0)
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
-- TOC entry 3242 (class 0 OID 0)
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
-- TOC entry 3243 (class 0 OID 0)
-- Dependencies: 237
-- Name: tipoPersona_idTipoPersona_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."tipoPersona_idTipoPersona_seq" OWNED BY public."tipoPersona"."idTipoPersona";


--
-- TOC entry 229 (class 1259 OID 191344)
-- Name: tiposClave; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."tiposClave" (
    id integer NOT NULL,
    "tipoClave" character varying(30) NOT NULL
);


ALTER TABLE public."tiposClave" OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 191342)
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
-- TOC entry 3244 (class 0 OID 0)
-- Dependencies: 228
-- Name: tiposClave_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."tiposClave_id_seq" OWNED BY public."tiposClave".id;


--
-- TOC entry 231 (class 1259 OID 191354)
-- Name: tiposDocumentos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."tiposDocumentos" (
    id integer NOT NULL,
    "tipoDocumento" character varying(30) NOT NULL
);


ALTER TABLE public."tiposDocumentos" OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 191352)
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
-- TOC entry 3245 (class 0 OID 0)
-- Dependencies: 230
-- Name: tiposDocumentos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."tiposDocumentos_id_seq" OWNED BY public."tiposDocumentos".id;


--
-- TOC entry 211 (class 1259 OID 101165)
-- Name: unidad_medida; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.unidad_medida (
    id integer NOT NULL,
    unidad character varying(50) NOT NULL
);


ALTER TABLE public.unidad_medida OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 101163)
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
-- TOC entry 3246 (class 0 OID 0)
-- Dependencies: 210
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
-- TOC entry 3247 (class 0 OID 0)
-- Dependencies: 245
-- Name: ventas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ventas_id_seq OWNED BY public.ventas.id;


--
-- TOC entry 2888 (class 2604 OID 208365)
-- Name: FormadePago_Venta id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FormadePago_Venta" ALTER COLUMN id SET DEFAULT nextval('public."FormadePago_Venta_id_seq"'::regclass);


--
-- TOC entry 2875 (class 2604 OID 166827)
-- Name: categoria id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria ALTER COLUMN id SET DEFAULT nextval('public.categoria_id_seq'::regclass);


--
-- TOC entry 2883 (class 2604 OID 199569)
-- Name: clientes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes ALTER COLUMN id SET DEFAULT nextval('public.clientes_id_seq'::regclass);


--
-- TOC entry 2876 (class 2604 OID 174963)
-- Name: companiaTarjeta id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."companiaTarjeta" ALTER COLUMN id SET DEFAULT nextval('public."companiaTarjeta_id_seq"'::regclass);


--
-- TOC entry 2887 (class 2604 OID 208342)
-- Name: compras id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras ALTER COLUMN id SET DEFAULT nextval('public.compras_id_seq'::regclass);


--
-- TOC entry 2884 (class 2604 OID 200117)
-- Name: datosEmpresa id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa" ALTER COLUMN id SET DEFAULT nextval('public."datosEmpresa_id_seq"'::regclass);


--
-- TOC entry 2890 (class 2604 OID 208401)
-- Name: datosFormaPagos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagos" ALTER COLUMN id SET DEFAULT nextval('public."datosFormaPagos_id_seq"'::regclass);


--
-- TOC entry 2886 (class 2604 OID 208322)
-- Name: datosFormaPagosCompra id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagosCompra" ALTER COLUMN id SET DEFAULT nextval('public."datosFormaPagosCompra_id_seq"'::regclass);


--
-- TOC entry 2877 (class 2604 OID 183171)
-- Name: formadepago id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.formadepago ALTER COLUMN id SET DEFAULT nextval('public.formadepago_id_seq'::regclass);


--
-- TOC entry 2874 (class 2604 OID 101178)
-- Name: marcas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marcas ALTER COLUMN id SET DEFAULT nextval('public.marcas_id_seq'::regclass);


--
-- TOC entry 2880 (class 2604 OID 191844)
-- Name: productos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos ALTER COLUMN id SET DEFAULT nextval('public.productos_id_seq'::regclass);


--
-- TOC entry 2882 (class 2604 OID 199549)
-- Name: proveedor id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedor ALTER COLUMN id SET DEFAULT nextval('public.proveedor_id_seq'::regclass);


--
-- TOC entry 2889 (class 2604 OID 208383)
-- Name: renglon id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon ALTER COLUMN id SET DEFAULT nextval('public.renglon_id_seq'::regclass);


--
-- TOC entry 2891 (class 2604 OID 208421)
-- Name: renglon_compras id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_compras ALTER COLUMN id SET DEFAULT nextval('public.renglon_compras_id_seq'::regclass);


--
-- TOC entry 2881 (class 2604 OID 199539)
-- Name: tipoPersona idTipoPersona; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tipoPersona" ALTER COLUMN "idTipoPersona" SET DEFAULT nextval('public."tipoPersona_idTipoPersona_seq"'::regclass);


--
-- TOC entry 2878 (class 2604 OID 191347)
-- Name: tiposClave id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tiposClave" ALTER COLUMN id SET DEFAULT nextval('public."tiposClave_id_seq"'::regclass);


--
-- TOC entry 2879 (class 2604 OID 191357)
-- Name: tiposDocumentos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tiposDocumentos" ALTER COLUMN id SET DEFAULT nextval('public."tiposDocumentos_id_seq"'::regclass);


--
-- TOC entry 2873 (class 2604 OID 101168)
-- Name: unidad_medida id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unidad_medida ALTER COLUMN id SET DEFAULT nextval('public.unidad_medida_id_seq'::regclass);


--
-- TOC entry 2885 (class 2604 OID 208309)
-- Name: ventas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas ALTER COLUMN id SET DEFAULT nextval('public.ventas_id_seq'::regclass);


--
-- TOC entry 3216 (class 0 OID 208362)
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


--
-- TOC entry 3184 (class 0 OID 183299)
-- Dependencies: 220
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
-- TOC entry 3189 (class 0 OID 183354)
-- Dependencies: 225
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


--
-- TOC entry 3191 (class 0 OID 183388)
-- Dependencies: 227
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


--
-- TOC entry 3188 (class 0 OID 183344)
-- Dependencies: 224
-- Data for Name: ab_register_user; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3186 (class 0 OID 183313)
-- Dependencies: 222
-- Data for Name: ab_role; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ab_role (id, name) VALUES (5, 'Admin');
INSERT INTO public.ab_role (id, name) VALUES (6, 'Public');
INSERT INTO public.ab_role (id, name) VALUES (7, 'Gerente');
INSERT INTO public.ab_role (id, name) VALUES (8, 'vendedor');


--
-- TOC entry 3187 (class 0 OID 183320)
-- Dependencies: 223
-- Data for Name: ab_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ab_user (id, first_name, last_name, username, password, active, email, last_login, login_count, fail_login_count, created_on, changed_on, created_by_fk, changed_by_fk, cuil) VALUES (8, 'enrique', 'sand', 'egsand', 'pbkdf2:sha256:50000$M2KUtiFD$2bbe3354fdf08e42d3a2b9cfb6e08ba7e693dbe72a933f530184e52c9353f827', true, 'xovibe4870@x1post.com', '2020-11-06 10:01:50.553639', 1, 0, '2020-11-06 09:50:56.941954', '2020-11-06 10:11:03.964096', NULL, 6, '27-05883446-2');
INSERT INTO public.ab_user (id, first_name, last_name, username, password, active, email, last_login, login_count, fail_login_count, created_on, changed_on, created_by_fk, changed_by_fk, cuil) VALUES (6, 'gerente', 'gerente', 'gerente1', 'pbkdf2:sha256:50000$Q5m5vE72$9a595328c91717556dc8d8e9a89b781f26a05c50016dc84e195797eb8bdcaac4', true, 'gerente@gmail.com', '2020-11-06 22:14:16.573668', 10, 0, '2020-10-15 18:33:32.22051', '2020-10-26 12:54:36.693305', 5, 5, '27-39441118-9');
INSERT INTO public.ab_user (id, first_name, last_name, username, password, active, email, last_login, login_count, fail_login_count, created_on, changed_on, created_by_fk, changed_by_fk, cuil) VALUES (5, 'admin', 'super', 'superadmin', 'pbkdf2:sha256:50000$DIByLH7T$9421fe78a224369623f4e330177bcbebf9f22d6384b72366d8f8f4ec3511d55e', true, 'admin@fab.org', '2020-11-06 22:24:33.807701', 25, 0, '2020-10-15 18:13:49.879222', '2020-10-15 18:13:49.879222', NULL, NULL, NULL);
INSERT INTO public.ab_user (id, first_name, last_name, username, password, active, email, last_login, login_count, fail_login_count, created_on, changed_on, created_by_fk, changed_by_fk, cuil) VALUES (14, 'pexow28768@x1post.com', 'pexow28768@x1post.com', 'pexow28768@x1post.com', 'pbkdf2:sha256:50000$dLyte5Rb$1956d95756f42ec00c2c574a27d080c39fc58f20fe673f4e8bb404d4ad747c4b', true, 'pexow28768@x1post.com', '2020-11-06 22:26:32.713031', 1, 0, '2020-11-06 22:26:23.960468', '2020-11-06 22:26:23.960468', NULL, NULL, NULL);


--
-- TOC entry 3190 (class 0 OID 183371)
-- Dependencies: 226
-- Data for Name: ab_user_role; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ab_user_role (id, user_id, role_id) VALUES (6, 5, 5);
INSERT INTO public.ab_user_role (id, user_id, role_id) VALUES (9, 6, 7);
INSERT INTO public.ab_user_role (id, user_id, role_id) VALUES (11, 8, 6);
INSERT INTO public.ab_user_role (id, user_id, role_id) VALUES (12, 8, 8);
INSERT INTO public.ab_user_role (id, user_id, role_id) VALUES (21, 14, 6);


--
-- TOC entry 3185 (class 0 OID 183306)
-- Dependencies: 221
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


--
-- TOC entry 3198 (class 0 OID 191690)
-- Dependencies: 234
-- Data for Name: audit_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.audit_log (id, message, username, created_on, operation_id, target) VALUES (4, 'Cuit 20-41091788-3 sand enrique', 'superadmin', '2020-11-01 12:30:33.852218', 1, 'ProveedorView');
INSERT INTO public.audit_log (id, message, username, created_on, operation_id, target) VALUES (5, 'Cuit 30-13453456-3 Retondo Cortencio', 'superadmin', '2020-11-02 12:55:48.405188', 1, 'ProveedorView');
INSERT INTO public.audit_log (id, message, username, created_on, operation_id, target) VALUES (6, 'Cuit 20-41091788-3 sand enrique 39397.5 False 2020-11-01', 'superadmin', '2020-11-02 12:57:33.715283', 2, 'CompraReportes');
INSERT INTO public.audit_log (id, message, username, created_on, operation_id, target) VALUES (7, 'Cuit 20-41091788-3 sand enrique 39397.5 True 2020-11-01', 'superadmin', '2020-11-02 12:58:20.990859', 2, 'CompraReportes');
INSERT INTO public.audit_log (id, message, username, created_on, operation_id, target) VALUES (8, 'Cuit 20-41091788-3 sand enrique', 'superadmin', '2020-11-03 16:12:41.496419', 2, 'ProveedorView');


--
-- TOC entry 3179 (class 0 OID 166824)
-- Dependencies: 215
-- Data for Name: categoria; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.categoria (id, categoria) VALUES (1, 'yerba');
INSERT INTO public.categoria (id, categoria) VALUES (2, 'gaseosa');
INSERT INTO public.categoria (id, categoria) VALUES (3, 'galletita');
INSERT INTO public.categoria (id, categoria) VALUES (4, 'vino');
INSERT INTO public.categoria (id, categoria) VALUES (5, 'cerveza');
INSERT INTO public.categoria (id, categoria) VALUES (6, 'cigarrillos');
INSERT INTO public.categoria (id, categoria) VALUES (7, 'dulces');
INSERT INTO public.categoria (id, categoria) VALUES (11, 'Harina');


--
-- TOC entry 3206 (class 0 OID 199566)
-- Dependencies: 242
-- Data for Name: clientes; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado) VALUES (1, 'Consumidor Final', NULL, NULL, 1, 1, 1, true);
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado) VALUES (2, '3905508741', NULL, NULL, 1, 1, 1, true);
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado) VALUES (3, '253648741', NULL, NULL, 1, 1, 1, true);
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado) VALUES (637, '27-10255123-6', 'Marcelo', 'Lobardy', 2, 2, 1, true);
INSERT INTO public.clientes (id, documento, nombre, apellido, "tipoDocumento_id", "tipoClave_id", "idTipoPersona", estado) VALUES (4, '131618746', 'juan', 'perez', 1, 3, 1, true);


--
-- TOC entry 3181 (class 0 OID 174960)
-- Dependencies: 217
-- Data for Name: companiaTarjeta; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."companiaTarjeta" (id, compania) VALUES (1, 'Visa');
INSERT INTO public."companiaTarjeta" (id, compania) VALUES (2, 'Mastercard');
INSERT INTO public."companiaTarjeta" (id, compania) VALUES (135, 'Naranja');
INSERT INTO public."companiaTarjeta" (id, compania) VALUES (730, 'Maestro');


--
-- TOC entry 3214 (class 0 OID 208339)
-- Dependencies: 250
-- Data for Name: compras; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.compras (id, "Estado", total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion) VALUES (1, true, 217.8, 198, 19.8, '2020-11-04', 5, 1, NULL, 0);
INSERT INTO public.compras (id, "Estado", total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion) VALUES (2, true, 104.5, 95, 9.5, '2020-11-05', 5, 1, NULL, 0);
INSERT INTO public.compras (id, "Estado", total, "totalNeto", totaliva, fecha, proveedor_id, formadepago_id, "datosFormaPagos_id", percepcion) VALUES (3, true, 309, 300, 0, '2020-11-06', 5, 1, NULL, 3);


--
-- TOC entry 3208 (class 0 OID 200114)
-- Dependencies: 244
-- Data for Name: datosEmpresa; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."datosEmpresa" (id, compania, direccion, cuit, logo, "tipoClave_id") VALUES (1, 'Kiogestion', 'Avenida Roque Perez, 1522', '', '24a99ed4-1e9c-11eb-8bac-10c37b9bc0ef_sep_logo.jpg', 3);


--
-- TOC entry 3220 (class 0 OID 208398)
-- Dependencies: 256
-- Data for Name: datosFormaPagos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."datosFormaPagos" (id, "numeroCupon", credito, cuotas, "companiaTarjeta_id", formadepago_id) VALUES (1, '3243', false, 0, 730, 4);
INSERT INTO public."datosFormaPagos" (id, "numeroCupon", credito, cuotas, "companiaTarjeta_id", formadepago_id) VALUES (2, '4654654656', false, 0, 1, 7);


--
-- TOC entry 3212 (class 0 OID 208319)
-- Dependencies: 248
-- Data for Name: datosFormaPagosCompra; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3183 (class 0 OID 183168)
-- Dependencies: 219
-- Data for Name: formadepago; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.formadepago (id, "Metodo") VALUES (1, 'Contado');
INSERT INTO public.formadepago (id, "Metodo") VALUES (2, 'Tarjeta');


--
-- TOC entry 3177 (class 0 OID 101175)
-- Dependencies: 213
-- Data for Name: marcas; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.marcas (id, marca) VALUES (1, 'guarani');
INSERT INTO public.marcas (id, marca) VALUES (2, 'fanta');
INSERT INTO public.marcas (id, marca) VALUES (3, 'Romance');
INSERT INTO public.marcas (id, marca) VALUES (4, 'cañuelas');
INSERT INTO public.marcas (id, marca) VALUES (5, 'coca cola');
INSERT INTO public.marcas (id, marca) VALUES (6, 'rex');
INSERT INTO public.marcas (id, marca) VALUES (7, 'saladix');
INSERT INTO public.marcas (id, marca) VALUES (8, 'sprite');
INSERT INTO public.marcas (id, marca) VALUES (9, 'heigth');
INSERT INTO public.marcas (id, marca) VALUES (10, 'imperial');
INSERT INTO public.marcas (id, marca) VALUES (11, 'corona');
INSERT INTO public.marcas (id, marca) VALUES (12, 'miller');
INSERT INTO public.marcas (id, marca) VALUES (13, 'favoritas');
INSERT INTO public.marcas (id, marca) VALUES (14, 'reinharina');
INSERT INTO public.marcas (id, marca) VALUES (15, 'malboro');
INSERT INTO public.marcas (id, marca) VALUES (17, 'malbec');
INSERT INTO public.marcas (id, marca) VALUES (18, 'termidor');
INSERT INTO public.marcas (id, marca) VALUES (19, 'uvita');


--
-- TOC entry 3197 (class 0 OID 191685)
-- Dependencies: 233
-- Data for Name: operation; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.operation (id, name) VALUES (1, 'INSERT');
INSERT INTO public.operation (id, name) VALUES (2, 'UPDATE');
INSERT INTO public.operation (id, name) VALUES (3, 'DELETE');


--
-- TOC entry 3200 (class 0 OID 191841)
-- Dependencies: 236
-- Data for Name: productos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (1, true, 60, 571, 20, 2, 1, 1, 500, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (5, true, 50, 190, 21, 2, 7, 3, 250, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (3, true, 50, 258, 11, 1, 5, 2, 1.5, '');
INSERT INTO public.productos (id, estado, precio, stock, iva, unidad_id, marcas_id, categoria_id, medida, detalle) VALUES (4, true, 50, 68, 10, 2, 6, 3, 250, '');


--
-- TOC entry 3204 (class 0 OID 199546)
-- Dependencies: 240
-- Data for Name: proveedor; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.proveedor (id, cuit, nombre, apellido, domicilio, correo, estado, "tipoClave_id", "idTipoPersona") VALUES (5, '30-13453456-3', 'Cortencio', 'Retondo', NULL, '', true, 2, 1);
INSERT INTO public.proveedor (id, cuit, nombre, apellido, domicilio, correo, estado, "tipoClave_id", "idTipoPersona") VALUES (4, '20-41091788-3', 'enrique', 'sand', NULL, '', true, 3, 1);


--
-- TOC entry 3218 (class 0 OID 208380)
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


--
-- TOC entry 3222 (class 0 OID 208418)
-- Dependencies: 258
-- Data for Name: renglon_compras; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento) VALUES (1, 100, 2, 1, 4, 1);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento) VALUES (2, 50, 2, 2, 4, 5);
INSERT INTO public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id, descuento) VALUES (3, 150, 2, 3, 1, 0);


--
-- TOC entry 3202 (class 0 OID 199536)
-- Dependencies: 238
-- Data for Name: tipoPersona; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."tipoPersona" ("idTipoPersona", "tipoPersona") VALUES (1, 'Fisica');
INSERT INTO public."tipoPersona" ("idTipoPersona", "tipoPersona") VALUES (2, 'Juridica');


--
-- TOC entry 3193 (class 0 OID 191344)
-- Dependencies: 229
-- Data for Name: tiposClave; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."tiposClave" (id, "tipoClave") VALUES (1, 'Consumidor Final');
INSERT INTO public."tiposClave" (id, "tipoClave") VALUES (2, 'Responsable Inscripto');
INSERT INTO public."tiposClave" (id, "tipoClave") VALUES (3, 'Monotributista');
INSERT INTO public."tiposClave" (id, "tipoClave") VALUES (4, 'Exento');


--
-- TOC entry 3195 (class 0 OID 191354)
-- Dependencies: 231
-- Data for Name: tiposDocumentos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."tiposDocumentos" (id, "tipoDocumento") VALUES (1, 'DNI');
INSERT INTO public."tiposDocumentos" (id, "tipoDocumento") VALUES (2, 'CUIT');


--
-- TOC entry 3175 (class 0 OID 101165)
-- Dependencies: 211
-- Data for Name: unidad_medida; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.unidad_medida (id, unidad) VALUES (1, 'litro');
INSERT INTO public.unidad_medida (id, unidad) VALUES (2, 'gramos');
INSERT INTO public.unidad_medida (id, unidad) VALUES (3, 'kilo');
INSERT INTO public.unidad_medida (id, unidad) VALUES (4, 'mililitro');


--
-- TOC entry 3210 (class 0 OID 208306)
-- Dependencies: 246
-- Data for Name: ventas; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (1, true, '2020-11-04', 400, 400, 443, 637, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (2, true, '2020-11-04', 220, 34, 254, 637, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (3, true, '2020-11-04', 300, 32, 332, 637, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (4, true, '2020-11-04', 247.5, 0, 247.5, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (5, true, '2020-11-04', 288, 30.78, 318.78, 637, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (6, true, '2020-11-04', 90, 0, 90, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (7, true, '2020-11-06', 217, 0, 217, 1, 0);
INSERT INTO public.ventas (id, "Estado", fecha, "totalNeto", totaliva, total, cliente_id, percepcion) VALUES (8, true, '2020-11-06', 2201.5, 0, 2201.5, 1, 0);


--
-- TOC entry 3248 (class 0 OID 0)
-- Dependencies: 251
-- Name: FormadePago_Venta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."FormadePago_Venta_id_seq"', 10, true);


--
-- TOC entry 3249 (class 0 OID 0)
-- Dependencies: 202
-- Name: ab_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_permission_id_seq', 57, true);


--
-- TOC entry 3250 (class 0 OID 0)
-- Dependencies: 207
-- Name: ab_permission_view_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_permission_view_id_seq', 500, true);


--
-- TOC entry 3251 (class 0 OID 0)
-- Dependencies: 209
-- Name: ab_permission_view_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_permission_view_role_id_seq', 554, true);


--
-- TOC entry 3252 (class 0 OID 0)
-- Dependencies: 206
-- Name: ab_register_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_register_user_id_seq', 12, true);


--
-- TOC entry 3253 (class 0 OID 0)
-- Dependencies: 204
-- Name: ab_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_role_id_seq', 8, true);


--
-- TOC entry 3254 (class 0 OID 0)
-- Dependencies: 205
-- Name: ab_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_user_id_seq', 14, true);


--
-- TOC entry 3255 (class 0 OID 0)
-- Dependencies: 208
-- Name: ab_user_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_user_role_id_seq', 21, true);


--
-- TOC entry 3256 (class 0 OID 0)
-- Dependencies: 203
-- Name: ab_view_menu_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_view_menu_id_seq', 211, true);


--
-- TOC entry 3257 (class 0 OID 0)
-- Dependencies: 232
-- Name: audit_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.audit_log_id_seq', 8, true);


--
-- TOC entry 3258 (class 0 OID 0)
-- Dependencies: 214
-- Name: categoria_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categoria_id_seq', 11, true);


--
-- TOC entry 3259 (class 0 OID 0)
-- Dependencies: 241
-- Name: clientes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.clientes_id_seq', 1750, true);


--
-- TOC entry 3260 (class 0 OID 0)
-- Dependencies: 216
-- Name: companiaTarjeta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."companiaTarjeta_id_seq"', 2395, true);


--
-- TOC entry 3261 (class 0 OID 0)
-- Dependencies: 249
-- Name: compras_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.compras_id_seq', 3, true);


--
-- TOC entry 3262 (class 0 OID 0)
-- Dependencies: 243
-- Name: datosEmpresa_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."datosEmpresa_id_seq"', 293, true);


--
-- TOC entry 3263 (class 0 OID 0)
-- Dependencies: 247
-- Name: datosFormaPagosCompra_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."datosFormaPagosCompra_id_seq"', 1, false);


--
-- TOC entry 3264 (class 0 OID 0)
-- Dependencies: 255
-- Name: datosFormaPagos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."datosFormaPagos_id_seq"', 2, true);


--
-- TOC entry 3265 (class 0 OID 0)
-- Dependencies: 218
-- Name: formadepago_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.formadepago_id_seq', 2171, true);


--
-- TOC entry 3266 (class 0 OID 0)
-- Dependencies: 212
-- Name: marcas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.marcas_id_seq', 19, true);


--
-- TOC entry 3267 (class 0 OID 0)
-- Dependencies: 235
-- Name: productos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.productos_id_seq', 5, true);


--
-- TOC entry 3268 (class 0 OID 0)
-- Dependencies: 239
-- Name: proveedor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.proveedor_id_seq', 5, true);


--
-- TOC entry 3269 (class 0 OID 0)
-- Dependencies: 257
-- Name: renglon_compras_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.renglon_compras_id_seq', 3, true);


--
-- TOC entry 3270 (class 0 OID 0)
-- Dependencies: 253
-- Name: renglon_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.renglon_id_seq', 17, true);


--
-- TOC entry 3271 (class 0 OID 0)
-- Dependencies: 237
-- Name: tipoPersona_idTipoPersona_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."tipoPersona_idTipoPersona_seq"', 891, true);


--
-- TOC entry 3272 (class 0 OID 0)
-- Dependencies: 228
-- Name: tiposClave_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."tiposClave_id_seq"', 3293, true);


--
-- TOC entry 3273 (class 0 OID 0)
-- Dependencies: 230
-- Name: tiposDocumentos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."tiposDocumentos_id_seq"', 1663, true);


--
-- TOC entry 3274 (class 0 OID 0)
-- Dependencies: 210
-- Name: unidad_medida_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.unidad_medida_id_seq', 4, true);


--
-- TOC entry 3275 (class 0 OID 0)
-- Dependencies: 245
-- Name: ventas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ventas_id_seq', 8, true);


--
-- TOC entry 2995 (class 2606 OID 208367)
-- Name: FormadePago_Venta FormadePago_Venta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FormadePago_Venta"
    ADD CONSTRAINT "FormadePago_Venta_pkey" PRIMARY KEY (id);


--
-- TOC entry 2913 (class 2606 OID 183305)
-- Name: ab_permission ab_permission_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission
    ADD CONSTRAINT ab_permission_name_key UNIQUE (name);


--
-- TOC entry 2915 (class 2606 OID 183303)
-- Name: ab_permission ab_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission
    ADD CONSTRAINT ab_permission_pkey PRIMARY KEY (id);


--
-- TOC entry 2937 (class 2606 OID 183360)
-- Name: ab_permission_view ab_permission_view_permission_id_view_menu_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_permission_id_view_menu_id_key UNIQUE (permission_id, view_menu_id);


--
-- TOC entry 2939 (class 2606 OID 183358)
-- Name: ab_permission_view ab_permission_view_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_pkey PRIMARY KEY (id);


--
-- TOC entry 2945 (class 2606 OID 183394)
-- Name: ab_permission_view_role ab_permission_view_role_permission_view_id_role_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_permission_view_id_role_id_key UNIQUE (permission_view_id, role_id);


--
-- TOC entry 2947 (class 2606 OID 183392)
-- Name: ab_permission_view_role ab_permission_view_role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_pkey PRIMARY KEY (id);


--
-- TOC entry 2933 (class 2606 OID 183351)
-- Name: ab_register_user ab_register_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_register_user
    ADD CONSTRAINT ab_register_user_pkey PRIMARY KEY (id);


--
-- TOC entry 2935 (class 2606 OID 183353)
-- Name: ab_register_user ab_register_user_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_register_user
    ADD CONSTRAINT ab_register_user_username_key UNIQUE (username);


--
-- TOC entry 2921 (class 2606 OID 183319)
-- Name: ab_role ab_role_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_role
    ADD CONSTRAINT ab_role_name_key UNIQUE (name);


--
-- TOC entry 2923 (class 2606 OID 183317)
-- Name: ab_role ab_role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_role
    ADD CONSTRAINT ab_role_pkey PRIMARY KEY (id);


--
-- TOC entry 2925 (class 2606 OID 183333)
-- Name: ab_user ab_user_cuil_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_cuil_key UNIQUE (cuil);


--
-- TOC entry 2927 (class 2606 OID 183331)
-- Name: ab_user ab_user_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_email_key UNIQUE (email);


--
-- TOC entry 2929 (class 2606 OID 183327)
-- Name: ab_user ab_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_pkey PRIMARY KEY (id);


--
-- TOC entry 2941 (class 2606 OID 183375)
-- Name: ab_user_role ab_user_role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_pkey PRIMARY KEY (id);


--
-- TOC entry 2943 (class 2606 OID 183377)
-- Name: ab_user_role ab_user_role_user_id_role_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_user_id_role_id_key UNIQUE (user_id, role_id);


--
-- TOC entry 2931 (class 2606 OID 183329)
-- Name: ab_user ab_user_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_username_key UNIQUE (username);


--
-- TOC entry 2917 (class 2606 OID 183312)
-- Name: ab_view_menu ab_view_menu_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_view_menu
    ADD CONSTRAINT ab_view_menu_name_key UNIQUE (name);


--
-- TOC entry 2919 (class 2606 OID 183310)
-- Name: ab_view_menu ab_view_menu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_view_menu
    ADD CONSTRAINT ab_view_menu_pkey PRIMARY KEY (id);


--
-- TOC entry 2959 (class 2606 OID 191697)
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--
-- TOC entry 2901 (class 2606 OID 166831)
-- Name: categoria categoria_categoria_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_categoria_key UNIQUE (categoria);


--
-- TOC entry 2903 (class 2606 OID 166829)
-- Name: categoria categoria_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_pkey PRIMARY KEY (id);


--
-- TOC entry 2973 (class 2606 OID 199573)
-- Name: clientes clientes_documento_tipoDocumento_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT "clientes_documento_tipoDocumento_id_key" UNIQUE (documento, "tipoDocumento_id");


--
-- TOC entry 2975 (class 2606 OID 199571)
-- Name: clientes clientes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (id);


--
-- TOC entry 2905 (class 2606 OID 174967)
-- Name: companiaTarjeta companiaTarjeta_compania_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."companiaTarjeta"
    ADD CONSTRAINT "companiaTarjeta_compania_key" UNIQUE (compania);


--
-- TOC entry 2907 (class 2606 OID 174965)
-- Name: companiaTarjeta companiaTarjeta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."companiaTarjeta"
    ADD CONSTRAINT "companiaTarjeta_pkey" PRIMARY KEY (id);


--
-- TOC entry 2993 (class 2606 OID 208344)
-- Name: compras compras_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_pkey PRIMARY KEY (id);


--
-- TOC entry 2977 (class 2606 OID 200124)
-- Name: datosEmpresa datosEmpresa_compania_direccion_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_compania_direccion_key" UNIQUE (compania, direccion);


--
-- TOC entry 2979 (class 2606 OID 200126)
-- Name: datosEmpresa datosEmpresa_compania_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_compania_key" UNIQUE (compania);


--
-- TOC entry 2981 (class 2606 OID 200130)
-- Name: datosEmpresa datosEmpresa_cuit_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_cuit_key" UNIQUE (cuit);


--
-- TOC entry 2983 (class 2606 OID 200128)
-- Name: datosEmpresa datosEmpresa_direccion_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_direccion_key" UNIQUE (direccion);


--
-- TOC entry 2985 (class 2606 OID 200122)
-- Name: datosEmpresa datosEmpresa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_pkey" PRIMARY KEY (id);


--
-- TOC entry 2989 (class 2606 OID 208326)
-- Name: datosFormaPagosCompra datosFormaPagosCompra_numeroCupon_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagosCompra"
    ADD CONSTRAINT "datosFormaPagosCompra_numeroCupon_key" UNIQUE ("numeroCupon");


--
-- TOC entry 2991 (class 2606 OID 208324)
-- Name: datosFormaPagosCompra datosFormaPagosCompra_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagosCompra"
    ADD CONSTRAINT "datosFormaPagosCompra_pkey" PRIMARY KEY (id);


--
-- TOC entry 2999 (class 2606 OID 208405)
-- Name: datosFormaPagos datosFormaPagos_numeroCupon_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagos"
    ADD CONSTRAINT "datosFormaPagos_numeroCupon_key" UNIQUE ("numeroCupon");


--
-- TOC entry 3001 (class 2606 OID 208403)
-- Name: datosFormaPagos datosFormaPagos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagos"
    ADD CONSTRAINT "datosFormaPagos_pkey" PRIMARY KEY (id);


--
-- TOC entry 2909 (class 2606 OID 183175)
-- Name: formadepago formadepago_Metodo_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.formadepago
    ADD CONSTRAINT "formadepago_Metodo_key" UNIQUE ("Metodo");


--
-- TOC entry 2911 (class 2606 OID 183173)
-- Name: formadepago formadepago_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.formadepago
    ADD CONSTRAINT formadepago_pkey PRIMARY KEY (id);


--
-- TOC entry 2897 (class 2606 OID 101182)
-- Name: marcas marcas_marca_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marcas
    ADD CONSTRAINT marcas_marca_key UNIQUE (marca);


--
-- TOC entry 2899 (class 2606 OID 101180)
-- Name: marcas marcas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marcas
    ADD CONSTRAINT marcas_pkey PRIMARY KEY (id);


--
-- TOC entry 2957 (class 2606 OID 191689)
-- Name: operation operation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.operation
    ADD CONSTRAINT operation_pkey PRIMARY KEY (id);


--
-- TOC entry 2961 (class 2606 OID 191848)
-- Name: productos productos_categoria_id_marcas_id_unidad_id_medida_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_categoria_id_marcas_id_unidad_id_medida_key UNIQUE (categoria_id, marcas_id, unidad_id, medida);


--
-- TOC entry 2963 (class 2606 OID 191846)
-- Name: productos productos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_pkey PRIMARY KEY (id);


--
-- TOC entry 2969 (class 2606 OID 199553)
-- Name: proveedor proveedor_cuit_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT proveedor_cuit_key UNIQUE (cuit);


--
-- TOC entry 2971 (class 2606 OID 199551)
-- Name: proveedor proveedor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT proveedor_pkey PRIMARY KEY (id);


--
-- TOC entry 3003 (class 2606 OID 208423)
-- Name: renglon_compras renglon_compras_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_compras
    ADD CONSTRAINT renglon_compras_pkey PRIMARY KEY (id);


--
-- TOC entry 2997 (class 2606 OID 208385)
-- Name: renglon renglon_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon
    ADD CONSTRAINT renglon_pkey PRIMARY KEY (id);


--
-- TOC entry 2965 (class 2606 OID 199541)
-- Name: tipoPersona tipoPersona_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tipoPersona"
    ADD CONSTRAINT "tipoPersona_pkey" PRIMARY KEY ("idTipoPersona");


--
-- TOC entry 2967 (class 2606 OID 199543)
-- Name: tipoPersona tipoPersona_tipoPersona_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tipoPersona"
    ADD CONSTRAINT "tipoPersona_tipoPersona_key" UNIQUE ("tipoPersona");


--
-- TOC entry 2949 (class 2606 OID 191349)
-- Name: tiposClave tiposClave_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tiposClave"
    ADD CONSTRAINT "tiposClave_pkey" PRIMARY KEY (id);


--
-- TOC entry 2951 (class 2606 OID 191351)
-- Name: tiposClave tiposClave_tipoClave_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tiposClave"
    ADD CONSTRAINT "tiposClave_tipoClave_key" UNIQUE ("tipoClave");


--
-- TOC entry 2953 (class 2606 OID 191359)
-- Name: tiposDocumentos tiposDocumentos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tiposDocumentos"
    ADD CONSTRAINT "tiposDocumentos_pkey" PRIMARY KEY (id);


--
-- TOC entry 2955 (class 2606 OID 191361)
-- Name: tiposDocumentos tiposDocumentos_tipoDocumento_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."tiposDocumentos"
    ADD CONSTRAINT "tiposDocumentos_tipoDocumento_key" UNIQUE ("tipoDocumento");


--
-- TOC entry 2893 (class 2606 OID 101170)
-- Name: unidad_medida unidad_medida_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unidad_medida
    ADD CONSTRAINT unidad_medida_pkey PRIMARY KEY (id);


--
-- TOC entry 2895 (class 2606 OID 101172)
-- Name: unidad_medida unidad_medida_unidad_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unidad_medida
    ADD CONSTRAINT unidad_medida_unidad_key UNIQUE (unidad);


--
-- TOC entry 2987 (class 2606 OID 208311)
-- Name: ventas ventas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_pkey PRIMARY KEY (id);


--
-- TOC entry 3039 (class 2620 OID 208437)
-- Name: renglon_compras updateproductoscompra; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER updateproductoscompra AFTER INSERT ON public.renglon_compras FOR EACH ROW EXECUTE FUNCTION public.sumarstockencompra();


--
-- TOC entry 3037 (class 2620 OID 208441)
-- Name: compras updateproductoscompranulada; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER updateproductoscompranulada AFTER UPDATE ON public.compras FOR EACH ROW EXECUTE FUNCTION public.actualiarstockencompranulada();


--
-- TOC entry 3038 (class 2620 OID 208435)
-- Name: renglon updateproductosventa; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER updateproductosventa AFTER INSERT ON public.renglon FOR EACH ROW EXECUTE FUNCTION public.descontarstockenventa();


--
-- TOC entry 3036 (class 2620 OID 208439)
-- Name: ventas updateproductosventanulada; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER updateproductosventanulada AFTER UPDATE ON public.ventas FOR EACH ROW EXECUTE FUNCTION public.sumarstockenventanulada();


--
-- TOC entry 3029 (class 2606 OID 208373)
-- Name: FormadePago_Venta FormadePago_Venta_formadepago_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FormadePago_Venta"
    ADD CONSTRAINT "FormadePago_Venta_formadepago_id_fkey" FOREIGN KEY (formadepago_id) REFERENCES public.formadepago(id);


--
-- TOC entry 3028 (class 2606 OID 208368)
-- Name: FormadePago_Venta FormadePago_Venta_venta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FormadePago_Venta"
    ADD CONSTRAINT "FormadePago_Venta_venta_id_fkey" FOREIGN KEY (venta_id) REFERENCES public.ventas(id);


--
-- TOC entry 3006 (class 2606 OID 183361)
-- Name: ab_permission_view ab_permission_view_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.ab_permission(id);


--
-- TOC entry 3010 (class 2606 OID 183395)
-- Name: ab_permission_view_role ab_permission_view_role_permission_view_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_permission_view_id_fkey FOREIGN KEY (permission_view_id) REFERENCES public.ab_permission_view(id);


--
-- TOC entry 3011 (class 2606 OID 183400)
-- Name: ab_permission_view_role ab_permission_view_role_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.ab_role(id);


--
-- TOC entry 3007 (class 2606 OID 183366)
-- Name: ab_permission_view ab_permission_view_view_menu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_view_menu_id_fkey FOREIGN KEY (view_menu_id) REFERENCES public.ab_view_menu(id);


--
-- TOC entry 3005 (class 2606 OID 183339)
-- Name: ab_user ab_user_changed_by_fk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_changed_by_fk_fkey FOREIGN KEY (changed_by_fk) REFERENCES public.ab_user(id);


--
-- TOC entry 3004 (class 2606 OID 183334)
-- Name: ab_user ab_user_created_by_fk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_created_by_fk_fkey FOREIGN KEY (created_by_fk) REFERENCES public.ab_user(id);


--
-- TOC entry 3009 (class 2606 OID 183383)
-- Name: ab_user_role ab_user_role_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.ab_role(id);


--
-- TOC entry 3008 (class 2606 OID 183378)
-- Name: ab_user_role ab_user_role_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.ab_user(id);


--
-- TOC entry 3012 (class 2606 OID 191698)
-- Name: audit_log audit_log_operation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_operation_id_fkey FOREIGN KEY (operation_id) REFERENCES public.operation(id);


--
-- TOC entry 3020 (class 2606 OID 199584)
-- Name: clientes clientes_idTipoPersona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT "clientes_idTipoPersona_fkey" FOREIGN KEY ("idTipoPersona") REFERENCES public."tipoPersona"("idTipoPersona");


--
-- TOC entry 3019 (class 2606 OID 199579)
-- Name: clientes clientes_tipoClave_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT "clientes_tipoClave_id_fkey" FOREIGN KEY ("tipoClave_id") REFERENCES public."tiposClave"(id);


--
-- TOC entry 3018 (class 2606 OID 199574)
-- Name: clientes clientes_tipoDocumento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT "clientes_tipoDocumento_id_fkey" FOREIGN KEY ("tipoDocumento_id") REFERENCES public."tiposDocumentos"(id);


--
-- TOC entry 3027 (class 2606 OID 208355)
-- Name: compras compras_datosFormaPagos_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT "compras_datosFormaPagos_id_fkey" FOREIGN KEY ("datosFormaPagos_id") REFERENCES public."datosFormaPagosCompra"(id);


--
-- TOC entry 3026 (class 2606 OID 208350)
-- Name: compras compras_formadepago_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_formadepago_id_fkey FOREIGN KEY (formadepago_id) REFERENCES public.formadepago(id);


--
-- TOC entry 3025 (class 2606 OID 208345)
-- Name: compras compras_proveedor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_proveedor_id_fkey FOREIGN KEY (proveedor_id) REFERENCES public.proveedor(id);


--
-- TOC entry 3021 (class 2606 OID 200131)
-- Name: datosEmpresa datosEmpresa_tipoClave_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_tipoClave_id_fkey" FOREIGN KEY ("tipoClave_id") REFERENCES public."tiposClave"(id);


--
-- TOC entry 3023 (class 2606 OID 208327)
-- Name: datosFormaPagosCompra datosFormaPagosCompra_companiaTarjeta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagosCompra"
    ADD CONSTRAINT "datosFormaPagosCompra_companiaTarjeta_id_fkey" FOREIGN KEY ("companiaTarjeta_id") REFERENCES public."companiaTarjeta"(id);


--
-- TOC entry 3024 (class 2606 OID 208332)
-- Name: datosFormaPagosCompra datosFormaPagosCompra_formadepago_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagosCompra"
    ADD CONSTRAINT "datosFormaPagosCompra_formadepago_id_fkey" FOREIGN KEY (formadepago_id) REFERENCES public.formadepago(id);


--
-- TOC entry 3032 (class 2606 OID 208406)
-- Name: datosFormaPagos datosFormaPagos_companiaTarjeta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagos"
    ADD CONSTRAINT "datosFormaPagos_companiaTarjeta_id_fkey" FOREIGN KEY ("companiaTarjeta_id") REFERENCES public."companiaTarjeta"(id);


--
-- TOC entry 3033 (class 2606 OID 208411)
-- Name: datosFormaPagos datosFormaPagos_formadepago_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagos"
    ADD CONSTRAINT "datosFormaPagos_formadepago_id_fkey" FOREIGN KEY (formadepago_id) REFERENCES public."FormadePago_Venta"(id);


--
-- TOC entry 3015 (class 2606 OID 191859)
-- Name: productos productos_categoria_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_categoria_id_fkey FOREIGN KEY (categoria_id) REFERENCES public.categoria(id);


--
-- TOC entry 3014 (class 2606 OID 191854)
-- Name: productos productos_marcas_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_marcas_id_fkey FOREIGN KEY (marcas_id) REFERENCES public.marcas(id);


--
-- TOC entry 3013 (class 2606 OID 191849)
-- Name: productos productos_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad_medida(id);


--
-- TOC entry 3017 (class 2606 OID 199559)
-- Name: proveedor proveedor_idTipoPersona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT "proveedor_idTipoPersona_fkey" FOREIGN KEY ("idTipoPersona") REFERENCES public."tipoPersona"("idTipoPersona");


--
-- TOC entry 3016 (class 2606 OID 199554)
-- Name: proveedor proveedor_tipoClave_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT "proveedor_tipoClave_id_fkey" FOREIGN KEY ("tipoClave_id") REFERENCES public."tiposClave"(id);


--
-- TOC entry 3034 (class 2606 OID 208424)
-- Name: renglon_compras renglon_compras_compra_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_compras
    ADD CONSTRAINT renglon_compras_compra_id_fkey FOREIGN KEY (compra_id) REFERENCES public.compras(id);


--
-- TOC entry 3035 (class 2606 OID 208429)
-- Name: renglon_compras renglon_compras_producto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_compras
    ADD CONSTRAINT renglon_compras_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES public.productos(id);


--
-- TOC entry 3031 (class 2606 OID 208391)
-- Name: renglon renglon_producto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon
    ADD CONSTRAINT renglon_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES public.productos(id);


--
-- TOC entry 3030 (class 2606 OID 208386)
-- Name: renglon renglon_venta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon
    ADD CONSTRAINT renglon_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES public.ventas(id);


--
-- TOC entry 3022 (class 2606 OID 208312)
-- Name: ventas ventas_cliente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id);


-- Completed on 2020-11-07 09:45:05

--
-- PostgreSQL database dump complete
--

