--
-- PostgreSQL database dump
--

-- Dumped from database version 12.2
-- Dumped by pg_dump version 12.2

-- Started on 2020-11-02 10:43:52

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
-- TOC entry 739 (class 1247 OID 166904)
-- Name: companiatarjeta; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.companiatarjeta AS ENUM (
    'visa',
    'mastercard',
    'naranja'
);


ALTER TYPE public.companiatarjeta OWNER TO postgres;

--
-- TOC entry 746 (class 1247 OID 166922)
-- Name: metodospagos; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.metodospagos AS ENUM (
    'tarjeta',
    'contado'
);


ALTER TYPE public.metodospagos OWNER TO postgres;

--
-- TOC entry 729 (class 1247 OID 134040)
-- Name: tipoclaves; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.tipoclaves AS ENUM (
    'consumidorFinal',
    'responsableInscripto',
    'monotributista'
);


ALTER TYPE public.tipoclaves OWNER TO postgres;

--
-- TOC entry 732 (class 1247 OID 134106)
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
-- TOC entry 274 (class 1255 OID 200110)
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
-- TOC entry 259 (class 1255 OID 200104)
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
-- TOC entry 260 (class 1255 OID 200106)
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
-- TOC entry 273 (class 1255 OID 200108)
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
-- TOC entry 246 (class 1259 OID 199852)
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
-- TOC entry 245 (class 1259 OID 199850)
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
-- TOC entry 3171 (class 0 OID 0)
-- Dependencies: 245
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
-- TOC entry 3172 (class 0 OID 0)
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
-- TOC entry 3173 (class 0 OID 0)
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
-- TOC entry 3174 (class 0 OID 0)
-- Dependencies: 216
-- Name: companiaTarjeta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."companiaTarjeta_id_seq" OWNED BY public."companiaTarjeta".id;


--
-- TOC entry 256 (class 1259 OID 200065)
-- Name: compras; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras (
    id integer NOT NULL,
    "Estado" boolean,
    total double precision NOT NULL,
    "totalNeto" double precision NOT NULL,
    fecha date NOT NULL,
    proveedor_id integer NOT NULL,
    formadepago_id integer NOT NULL,
    "datosFormaPagos_id" integer,
    percepcion double precision
);


ALTER TABLE public.compras OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 200063)
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
-- TOC entry 3175 (class 0 OID 0)
-- Dependencies: 255
-- Name: compras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.compras_id_seq OWNED BY public.compras.id;


--
-- TOC entry 252 (class 1259 OID 199949)
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
-- TOC entry 251 (class 1259 OID 199947)
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
-- TOC entry 3176 (class 0 OID 0)
-- Dependencies: 251
-- Name: datosEmpresa_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."datosEmpresa_id_seq" OWNED BY public."datosEmpresa".id;


--
-- TOC entry 250 (class 1259 OID 199888)
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
-- TOC entry 254 (class 1259 OID 200045)
-- Name: datosFormaPagosCompra; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."datosFormaPagosCompra" (
    id integer NOT NULL,
    "numeroCupon" character varying(50),
    credito boolean,
    cuotas integer,
    "companiaTarjeta_id" integer NOT NULL,
    formadepago_id integer NOT NULL
);


ALTER TABLE public."datosFormaPagosCompra" OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 200043)
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
-- TOC entry 3177 (class 0 OID 0)
-- Dependencies: 253
-- Name: datosFormaPagosCompra_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."datosFormaPagosCompra_id_seq" OWNED BY public."datosFormaPagosCompra".id;


--
-- TOC entry 249 (class 1259 OID 199886)
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
-- TOC entry 3178 (class 0 OID 0)
-- Dependencies: 249
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
-- TOC entry 3179 (class 0 OID 0)
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
-- TOC entry 3180 (class 0 OID 0)
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
-- TOC entry 3181 (class 0 OID 0)
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
-- TOC entry 3182 (class 0 OID 0)
-- Dependencies: 239
-- Name: proveedor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.proveedor_id_seq OWNED BY public.proveedor.id;


--
-- TOC entry 248 (class 1259 OID 199870)
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
-- TOC entry 258 (class 1259 OID 200088)
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
-- TOC entry 257 (class 1259 OID 200086)
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
-- TOC entry 3183 (class 0 OID 0)
-- Dependencies: 257
-- Name: renglon_compras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.renglon_compras_id_seq OWNED BY public.renglon_compras.id;


--
-- TOC entry 247 (class 1259 OID 199868)
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
-- TOC entry 3184 (class 0 OID 0)
-- Dependencies: 247
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
-- TOC entry 3185 (class 0 OID 0)
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
-- TOC entry 3186 (class 0 OID 0)
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
-- TOC entry 3187 (class 0 OID 0)
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
-- TOC entry 3188 (class 0 OID 0)
-- Dependencies: 210
-- Name: unidad_medida_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.unidad_medida_id_seq OWNED BY public.unidad_medida.id;


--
-- TOC entry 244 (class 1259 OID 199839)
-- Name: ventas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ventas (
    id integer NOT NULL,
    "Estado" boolean,
    fecha date NOT NULL,
    "totalNeto" double precision NOT NULL,
    total double precision NOT NULL,
    cliente_id integer NOT NULL,
    percepcion double precision
);


ALTER TABLE public.ventas OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 199837)
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
-- TOC entry 3189 (class 0 OID 0)
-- Dependencies: 243
-- Name: ventas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ventas_id_seq OWNED BY public.ventas.id;


--
-- TOC entry 2885 (class 2604 OID 199855)
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
-- TOC entry 2890 (class 2604 OID 200068)
-- Name: compras id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras ALTER COLUMN id SET DEFAULT nextval('public.compras_id_seq'::regclass);


--
-- TOC entry 2888 (class 2604 OID 199952)
-- Name: datosEmpresa id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa" ALTER COLUMN id SET DEFAULT nextval('public."datosEmpresa_id_seq"'::regclass);


--
-- TOC entry 2887 (class 2604 OID 199891)
-- Name: datosFormaPagos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagos" ALTER COLUMN id SET DEFAULT nextval('public."datosFormaPagos_id_seq"'::regclass);


--
-- TOC entry 2889 (class 2604 OID 200048)
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
-- TOC entry 2886 (class 2604 OID 199873)
-- Name: renglon id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon ALTER COLUMN id SET DEFAULT nextval('public.renglon_id_seq'::regclass);


--
-- TOC entry 2891 (class 2604 OID 200091)
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
-- TOC entry 2884 (class 2604 OID 199842)
-- Name: ventas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas ALTER COLUMN id SET DEFAULT nextval('public.ventas_id_seq'::regclass);


--
-- TOC entry 2979 (class 2606 OID 199857)
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
-- TOC entry 3001 (class 2606 OID 200070)
-- Name: compras compras_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_pkey PRIMARY KEY (id);


--
-- TOC entry 2987 (class 2606 OID 199959)
-- Name: datosEmpresa datosEmpresa_compania_direccion_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_compania_direccion_key" UNIQUE (compania, direccion);


--
-- TOC entry 2989 (class 2606 OID 199961)
-- Name: datosEmpresa datosEmpresa_compania_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_compania_key" UNIQUE (compania);


--
-- TOC entry 2991 (class 2606 OID 199965)
-- Name: datosEmpresa datosEmpresa_cuit_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_cuit_key" UNIQUE (cuit);


--
-- TOC entry 2993 (class 2606 OID 199963)
-- Name: datosEmpresa datosEmpresa_direccion_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_direccion_key" UNIQUE (direccion);


--
-- TOC entry 2995 (class 2606 OID 199957)
-- Name: datosEmpresa datosEmpresa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_pkey" PRIMARY KEY (id);


--
-- TOC entry 2997 (class 2606 OID 200052)
-- Name: datosFormaPagosCompra datosFormaPagosCompra_numeroCupon_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagosCompra"
    ADD CONSTRAINT "datosFormaPagosCompra_numeroCupon_key" UNIQUE ("numeroCupon");


--
-- TOC entry 2999 (class 2606 OID 200050)
-- Name: datosFormaPagosCompra datosFormaPagosCompra_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagosCompra"
    ADD CONSTRAINT "datosFormaPagosCompra_pkey" PRIMARY KEY (id);


--
-- TOC entry 2983 (class 2606 OID 199895)
-- Name: datosFormaPagos datosFormaPagos_numeroCupon_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagos"
    ADD CONSTRAINT "datosFormaPagos_numeroCupon_key" UNIQUE ("numeroCupon");


--
-- TOC entry 2985 (class 2606 OID 199893)
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
-- TOC entry 3003 (class 2606 OID 200093)
-- Name: renglon_compras renglon_compras_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_compras
    ADD CONSTRAINT renglon_compras_pkey PRIMARY KEY (id);


--
-- TOC entry 2981 (class 2606 OID 199875)
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
-- TOC entry 2977 (class 2606 OID 199844)
-- Name: ventas ventas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_pkey PRIMARY KEY (id);


--
-- TOC entry 3039 (class 2620 OID 200107)
-- Name: renglon_compras updateproductoscompra; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER updateproductoscompra AFTER INSERT ON public.renglon_compras FOR EACH ROW EXECUTE FUNCTION public.sumarstockencompra();


--
-- TOC entry 3038 (class 2620 OID 200111)
-- Name: compras updateproductoscompranulada; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER updateproductoscompranulada AFTER UPDATE ON public.compras FOR EACH ROW EXECUTE FUNCTION public.actualiarstockencompranulada();


--
-- TOC entry 3037 (class 2620 OID 200105)
-- Name: renglon updateproductosventa; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER updateproductosventa AFTER INSERT ON public.renglon FOR EACH ROW EXECUTE FUNCTION public.descontarstockenventa();


--
-- TOC entry 3036 (class 2620 OID 200109)
-- Name: ventas updateproductosventanulada; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER updateproductosventanulada AFTER UPDATE ON public.ventas FOR EACH ROW EXECUTE FUNCTION public.sumarstockenventanulada();


--
-- TOC entry 3023 (class 2606 OID 199863)
-- Name: FormadePago_Venta FormadePago_Venta_formadepago_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FormadePago_Venta"
    ADD CONSTRAINT "FormadePago_Venta_formadepago_id_fkey" FOREIGN KEY (formadepago_id) REFERENCES public.formadepago(id);


--
-- TOC entry 3022 (class 2606 OID 199858)
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
-- TOC entry 3033 (class 2606 OID 200081)
-- Name: compras compras_datosFormaPagos_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT "compras_datosFormaPagos_id_fkey" FOREIGN KEY ("datosFormaPagos_id") REFERENCES public."datosFormaPagosCompra"(id);


--
-- TOC entry 3032 (class 2606 OID 200076)
-- Name: compras compras_formadepago_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_formadepago_id_fkey FOREIGN KEY (formadepago_id) REFERENCES public.formadepago(id);


--
-- TOC entry 3031 (class 2606 OID 200071)
-- Name: compras compras_proveedor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_proveedor_id_fkey FOREIGN KEY (proveedor_id) REFERENCES public.proveedor(id);


--
-- TOC entry 3028 (class 2606 OID 199966)
-- Name: datosEmpresa datosEmpresa_tipoClave_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosEmpresa"
    ADD CONSTRAINT "datosEmpresa_tipoClave_id_fkey" FOREIGN KEY ("tipoClave_id") REFERENCES public."tiposClave"(id);


--
-- TOC entry 3029 (class 2606 OID 200053)
-- Name: datosFormaPagosCompra datosFormaPagosCompra_companiaTarjeta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagosCompra"
    ADD CONSTRAINT "datosFormaPagosCompra_companiaTarjeta_id_fkey" FOREIGN KEY ("companiaTarjeta_id") REFERENCES public."companiaTarjeta"(id);


--
-- TOC entry 3030 (class 2606 OID 200058)
-- Name: datosFormaPagosCompra datosFormaPagosCompra_formadepago_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagosCompra"
    ADD CONSTRAINT "datosFormaPagosCompra_formadepago_id_fkey" FOREIGN KEY (formadepago_id) REFERENCES public.formadepago(id);


--
-- TOC entry 3026 (class 2606 OID 199896)
-- Name: datosFormaPagos datosFormaPagos_companiaTarjeta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."datosFormaPagos"
    ADD CONSTRAINT "datosFormaPagos_companiaTarjeta_id_fkey" FOREIGN KEY ("companiaTarjeta_id") REFERENCES public."companiaTarjeta"(id);


--
-- TOC entry 3027 (class 2606 OID 199901)
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
-- TOC entry 3034 (class 2606 OID 200094)
-- Name: renglon_compras renglon_compras_compra_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_compras
    ADD CONSTRAINT renglon_compras_compra_id_fkey FOREIGN KEY (compra_id) REFERENCES public.compras(id);


--
-- TOC entry 3035 (class 2606 OID 200099)
-- Name: renglon_compras renglon_compras_producto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon_compras
    ADD CONSTRAINT renglon_compras_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES public.productos(id);


--
-- TOC entry 3025 (class 2606 OID 199881)
-- Name: renglon renglon_producto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon
    ADD CONSTRAINT renglon_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES public.productos(id);


--
-- TOC entry 3024 (class 2606 OID 199876)
-- Name: renglon renglon_venta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renglon
    ADD CONSTRAINT renglon_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES public.ventas(id);


--
-- TOC entry 3021 (class 2606 OID 199845)
-- Name: ventas ventas_cliente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id);


-- Completed on 2020-11-02 10:43:53

--
-- PostgreSQL database dump complete
--

