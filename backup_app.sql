PGDMP         '        	    	    x            almacen    12.2    12.2 �               0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false                       0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false                       0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false                       1262    73733    almacen    DATABASE     �   CREATE DATABASE almacen WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Spanish_Argentina.1252' LC_CTYPE = 'Spanish_Argentina.1252';
    DROP DATABASE almacen;
                postgres    false            �           1247    166904    companiatarjeta    TYPE     \   CREATE TYPE public.companiatarjeta AS ENUM (
    'visa',
    'mastercard',
    'naranja'
);
 "   DROP TYPE public.companiatarjeta;
       public          postgres    false            �           1247    166922    metodospagos    TYPE     J   CREATE TYPE public.metodospagos AS ENUM (
    'tarjeta',
    'contado'
);
    DROP TYPE public.metodospagos;
       public          postgres    false            �           1247    134040 
   tipoclaves    TYPE     s   CREATE TYPE public.tipoclaves AS ENUM (
    'consumidorFinal',
    'responsableInscripto',
    'monotributista'
);
    DROP TYPE public.tipoclaves;
       public          postgres    false            �           1247    134106    tiposdocumentos    TYPE     �   CREATE TYPE public.tiposdocumentos AS ENUM (
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
 "   DROP TYPE public.tiposdocumentos;
       public          postgres    false            �            1255    166994    sumarstockencompra()    FUNCTION     �   CREATE FUNCTION public.sumarstockencompra() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin

update productos set stock=stock+new.cantidad 
	where productos.id =new.producto_id;
return new;

end
$$;
 +   DROP FUNCTION public.sumarstockencompra();
       public          postgres    false            �            1259    100452    ab_permission    TABLE     i   CREATE TABLE public.ab_permission (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);
 !   DROP TABLE public.ab_permission;
       public         heap    postgres    false            �            1259    100450    ab_permission_id_seq    SEQUENCE     }   CREATE SEQUENCE public.ab_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.ab_permission_id_seq;
       public          postgres    false            �            1259    100515    ab_permission_view    TABLE     y   CREATE TABLE public.ab_permission_view (
    id integer NOT NULL,
    permission_id integer,
    view_menu_id integer
);
 &   DROP TABLE public.ab_permission_view;
       public         heap    postgres    false            �            1259    100513    ab_permission_view_id_seq    SEQUENCE     �   CREATE SEQUENCE public.ab_permission_view_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.ab_permission_view_id_seq;
       public          postgres    false            �            1259    100553    ab_permission_view_role    TABLE     ~   CREATE TABLE public.ab_permission_view_role (
    id integer NOT NULL,
    permission_view_id integer,
    role_id integer
);
 +   DROP TABLE public.ab_permission_view_role;
       public         heap    postgres    false            �            1259    100551    ab_permission_view_role_id_seq    SEQUENCE     �   CREATE SEQUENCE public.ab_permission_view_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE public.ab_permission_view_role_id_seq;
       public          postgres    false            �            1259    100503    ab_register_user    TABLE     |  CREATE TABLE public.ab_register_user (
    id integer NOT NULL,
    first_name character varying(64) NOT NULL,
    last_name character varying(64) NOT NULL,
    username character varying(64) NOT NULL,
    password character varying(256),
    email character varying(64) NOT NULL,
    registration_date timestamp without time zone,
    registration_hash character varying(256)
);
 $   DROP TABLE public.ab_register_user;
       public         heap    postgres    false            �            1259    100501    ab_register_user_id_seq    SEQUENCE     �   CREATE SEQUENCE public.ab_register_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.ab_register_user_id_seq;
       public          postgres    false            �            1259    100470    ab_role    TABLE     b   CREATE TABLE public.ab_role (
    id integer NOT NULL,
    name character varying(64) NOT NULL
);
    DROP TABLE public.ab_role;
       public         heap    postgres    false            �            1259    100468    ab_role_id_seq    SEQUENCE     w   CREATE SEQUENCE public.ab_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.ab_role_id_seq;
       public          postgres    false            �            1259    100479    ab_user    TABLE       CREATE TABLE public.ab_user (
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
    changed_by_fk integer
);
    DROP TABLE public.ab_user;
       public         heap    postgres    false            �            1259    100477    ab_user_id_seq    SEQUENCE     w   CREATE SEQUENCE public.ab_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.ab_user_id_seq;
       public          postgres    false            �            1259    100534    ab_user_role    TABLE     h   CREATE TABLE public.ab_user_role (
    id integer NOT NULL,
    user_id integer,
    role_id integer
);
     DROP TABLE public.ab_user_role;
       public         heap    postgres    false            �            1259    100532    ab_user_role_id_seq    SEQUENCE     |   CREATE SEQUENCE public.ab_user_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.ab_user_role_id_seq;
       public          postgres    false            �            1259    142331    ab_view_menu    TABLE     h   CREATE TABLE public.ab_view_menu (
    id integer NOT NULL,
    name character varying(250) NOT NULL
);
     DROP TABLE public.ab_view_menu;
       public         heap    postgres    false            �            1259    100459    ab_view_menu_id_seq    SEQUENCE     |   CREATE SEQUENCE public.ab_view_menu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.ab_view_menu_id_seq;
       public          postgres    false            �            1259    166824 	   categoria    TABLE     i   CREATE TABLE public.categoria (
    id integer NOT NULL,
    categoria character varying(50) NOT NULL
);
    DROP TABLE public.categoria;
       public         heap    postgres    false            �            1259    166822    categoria_id_seq    SEQUENCE     �   CREATE SEQUENCE public.categoria_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.categoria_id_seq;
       public          postgres    false    231                       0    0    categoria_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.categoria_id_seq OWNED BY public.categoria.id;
          public          postgres    false    230            �            1259    166939    clientes    TABLE     �  CREATE TABLE public.clientes (
    created_on timestamp without time zone NOT NULL,
    changed_on timestamp without time zone NOT NULL,
    id integer NOT NULL,
    documento character varying(30) NOT NULL,
    nombre character varying(30),
    apellido character varying(30),
    "tipoDocumento" public.tiposdocumentos,
    estado boolean,
    created_by_fk integer NOT NULL,
    changed_by_fk integer NOT NULL
);
    DROP TABLE public.clientes;
       public         heap    postgres    false    703            �            1259    166937    clientes_id_seq    SEQUENCE     �   CREATE SEQUENCE public.clientes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.clientes_id_seq;
       public          postgres    false    237                       0    0    clientes_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.clientes_id_seq OWNED BY public.clientes.id;
          public          postgres    false    236            �            1259    166978    compras    TABLE       CREATE TABLE public.compras (
    id integer NOT NULL,
    "Estado" boolean,
    total double precision NOT NULL,
    fecha date NOT NULL,
    "condicionFrenteIva" public.tipoclaves,
    proveedor_id integer NOT NULL,
    formadepago_id integer NOT NULL
);
    DROP TABLE public.compras;
       public         heap    postgres    false    700            �            1259    166976    compras_id_seq    SEQUENCE     �   CREATE SEQUENCE public.compras_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.compras_id_seq;
       public          postgres    false    241                       0    0    compras_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.compras_id_seq OWNED BY public.compras.id;
          public          postgres    false    240            �            1259    166929    formadepago    TABLE     �   CREATE TABLE public.formadepago (
    id integer NOT NULL,
    "Metodo" public.metodospagos,
    "numeroCupon" character varying(50),
    "companiaTarjeta" public.companiatarjeta,
    credito boolean,
    cuotas integer
);
    DROP TABLE public.formadepago;
       public         heap    postgres    false    733    736            �            1259    166927    formadepago_id_seq    SEQUENCE     �   CREATE SEQUENCE public.formadepago_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.formadepago_id_seq;
       public          postgres    false    235                       0    0    formadepago_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.formadepago_id_seq OWNED BY public.formadepago.id;
          public          postgres    false    234            �            1259    101175    marcas    TABLE     b   CREATE TABLE public.marcas (
    id integer NOT NULL,
    marca character varying(50) NOT NULL
);
    DROP TABLE public.marcas;
       public         heap    postgres    false            �            1259    101173    marcas_id_seq    SEQUENCE     �   CREATE SEQUENCE public.marcas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.marcas_id_seq;
       public          postgres    false    220                       0    0    marcas_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.marcas_id_seq OWNED BY public.marcas.id;
          public          postgres    false    219            �            1259    166870 	   productos    TABLE     �  CREATE TABLE public.productos (
    created_on timestamp without time zone NOT NULL,
    changed_on timestamp without time zone NOT NULL,
    id integer NOT NULL,
    precio double precision,
    stock integer,
    unidad_id integer NOT NULL,
    marcas_id integer NOT NULL,
    categoria_id integer NOT NULL,
    medida double precision,
    detalle character varying(255),
    created_by_fk integer NOT NULL,
    changed_by_fk integer NOT NULL
);
    DROP TABLE public.productos;
       public         heap    postgres    false            �            1259    166868    productos_id_seq    SEQUENCE     �   CREATE SEQUENCE public.productos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.productos_id_seq;
       public          postgres    false    233                       0    0    productos_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.productos_id_seq OWNED BY public.productos.id;
          public          postgres    false    232            �            1259    166768 	   proveedor    TABLE     �  CREATE TABLE public.proveedor (
    created_on timestamp without time zone NOT NULL,
    changed_on timestamp without time zone NOT NULL,
    id integer NOT NULL,
    cuit character varying(30) NOT NULL,
    nombre character varying(30),
    apellido character varying(30),
    domicilio character varying(255),
    correo character varying(100),
    estado boolean,
    created_by_fk integer NOT NULL,
    changed_by_fk integer NOT NULL
);
    DROP TABLE public.proveedor;
       public         heap    postgres    false            �            1259    166766    proveedor_id_seq    SEQUENCE     �   CREATE SEQUENCE public.proveedor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.proveedor_id_seq;
       public          postgres    false    227                       0    0    proveedor_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.proveedor_id_seq OWNED BY public.proveedor.id;
          public          postgres    false    226            �            1259    142642    renglon    TABLE     �   CREATE TABLE public.renglon (
    id integer NOT NULL,
    "precioVenta" double precision,
    cantidad integer,
    venta_id integer NOT NULL,
    producto_id integer NOT NULL
);
    DROP TABLE public.renglon;
       public         heap    postgres    false            �            1259    166806    renglon_compras    TABLE     �   CREATE TABLE public.renglon_compras (
    id integer NOT NULL,
    "precioCompra" double precision,
    cantidad integer,
    compra_id integer NOT NULL,
    producto_id integer NOT NULL
);
 #   DROP TABLE public.renglon_compras;
       public         heap    postgres    false            �            1259    166804    renglon_compras_id_seq    SEQUENCE     �   CREATE SEQUENCE public.renglon_compras_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.renglon_compras_id_seq;
       public          postgres    false    229                       0    0    renglon_compras_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.renglon_compras_id_seq OWNED BY public.renglon_compras.id;
          public          postgres    false    228            �            1259    142640    renglon_id_seq    SEQUENCE     �   CREATE SEQUENCE public.renglon_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.renglon_id_seq;
       public          postgres    false    223                       0    0    renglon_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.renglon_id_seq OWNED BY public.renglon.id;
          public          postgres    false    222            �            1259    101165    unidad_medida    TABLE     j   CREATE TABLE public.unidad_medida (
    id integer NOT NULL,
    unidad character varying(50) NOT NULL
);
 !   DROP TABLE public.unidad_medida;
       public         heap    postgres    false            �            1259    101163    unidad_medida_id_seq    SEQUENCE     �   CREATE SEQUENCE public.unidad_medida_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.unidad_medida_id_seq;
       public          postgres    false    218                        0    0    unidad_medida_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.unidad_medida_id_seq OWNED BY public.unidad_medida.id;
          public          postgres    false    217            �            1259    150384    users    TABLE     4  CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    password character varying(80) NOT NULL,
    email character varying(80) NOT NULL,
    rol character varying(80) NOT NULL,
    estado boolean NOT NULL,
    fechainicio date NOT NULL,
    fechafinal date
);
    DROP TABLE public.users;
       public         heap    postgres    false            �            1259    150382    users_id_seq    SEQUENCE     �   CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.users_id_seq;
       public          postgres    false    225            !           0    0    users_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;
          public          postgres    false    224            �            1259    166959    ventas    TABLE     �   CREATE TABLE public.ventas (
    id integer NOT NULL,
    "Estado" boolean,
    fecha date NOT NULL,
    "condicionFrenteIva" public.tipoclaves,
    total double precision NOT NULL,
    cliente_id integer NOT NULL,
    formadepago_id integer NOT NULL
);
    DROP TABLE public.ventas;
       public         heap    postgres    false    700            �            1259    166957    ventas_id_seq    SEQUENCE     �   CREATE SEQUENCE public.ventas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.ventas_id_seq;
       public          postgres    false    239            "           0    0    ventas_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.ventas_id_seq OWNED BY public.ventas.id;
          public          postgres    false    238                       2604    166827    categoria id    DEFAULT     l   ALTER TABLE ONLY public.categoria ALTER COLUMN id SET DEFAULT nextval('public.categoria_id_seq'::regclass);
 ;   ALTER TABLE public.categoria ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    231    230    231            	           2604    166942    clientes id    DEFAULT     j   ALTER TABLE ONLY public.clientes ALTER COLUMN id SET DEFAULT nextval('public.clientes_id_seq'::regclass);
 :   ALTER TABLE public.clientes ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    237    236    237                       2604    166981 
   compras id    DEFAULT     h   ALTER TABLE ONLY public.compras ALTER COLUMN id SET DEFAULT nextval('public.compras_id_seq'::regclass);
 9   ALTER TABLE public.compras ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    240    241    241                       2604    166932    formadepago id    DEFAULT     p   ALTER TABLE ONLY public.formadepago ALTER COLUMN id SET DEFAULT nextval('public.formadepago_id_seq'::regclass);
 =   ALTER TABLE public.formadepago ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    234    235    235                       2604    101178 	   marcas id    DEFAULT     f   ALTER TABLE ONLY public.marcas ALTER COLUMN id SET DEFAULT nextval('public.marcas_id_seq'::regclass);
 8   ALTER TABLE public.marcas ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    219    220    220                       2604    166873    productos id    DEFAULT     l   ALTER TABLE ONLY public.productos ALTER COLUMN id SET DEFAULT nextval('public.productos_id_seq'::regclass);
 ;   ALTER TABLE public.productos ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    232    233    233                       2604    166771    proveedor id    DEFAULT     l   ALTER TABLE ONLY public.proveedor ALTER COLUMN id SET DEFAULT nextval('public.proveedor_id_seq'::regclass);
 ;   ALTER TABLE public.proveedor ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    226    227    227                       2604    142645 
   renglon id    DEFAULT     h   ALTER TABLE ONLY public.renglon ALTER COLUMN id SET DEFAULT nextval('public.renglon_id_seq'::regclass);
 9   ALTER TABLE public.renglon ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    222    223    223                       2604    166809    renglon_compras id    DEFAULT     x   ALTER TABLE ONLY public.renglon_compras ALTER COLUMN id SET DEFAULT nextval('public.renglon_compras_id_seq'::regclass);
 A   ALTER TABLE public.renglon_compras ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    229    228    229                        2604    101168    unidad_medida id    DEFAULT     t   ALTER TABLE ONLY public.unidad_medida ALTER COLUMN id SET DEFAULT nextval('public.unidad_medida_id_seq'::regclass);
 ?   ALTER TABLE public.unidad_medida ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    218    217    218                       2604    150387    users id    DEFAULT     d   ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);
 7   ALTER TABLE public.users ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    225    224    225            
           2604    166962 	   ventas id    DEFAULT     f   ALTER TABLE ONLY public.ventas ALTER COLUMN id SET DEFAULT nextval('public.ventas_id_seq'::regclass);
 8   ALTER TABLE public.ventas ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    239    238    239            �          0    100452    ab_permission 
   TABLE DATA           1   COPY public.ab_permission (id, name) FROM stdin;
    public          postgres    false    203   Z�       �          0    100515    ab_permission_view 
   TABLE DATA           M   COPY public.ab_permission_view (id, permission_id, view_menu_id) FROM stdin;
    public          postgres    false    212   =�       �          0    100553    ab_permission_view_role 
   TABLE DATA           R   COPY public.ab_permission_view_role (id, permission_view_id, role_id) FROM stdin;
    public          postgres    false    216   7�       �          0    100503    ab_register_user 
   TABLE DATA           �   COPY public.ab_register_user (id, first_name, last_name, username, password, email, registration_date, registration_hash) FROM stdin;
    public          postgres    false    210   ��       �          0    100470    ab_role 
   TABLE DATA           +   COPY public.ab_role (id, name) FROM stdin;
    public          postgres    false    206   ��       �          0    100479    ab_user 
   TABLE DATA           �   COPY public.ab_user (id, first_name, last_name, username, password, active, email, last_login, login_count, fail_login_count, created_on, changed_on, created_by_fk, changed_by_fk) FROM stdin;
    public          postgres    false    208   B�       �          0    100534    ab_user_role 
   TABLE DATA           <   COPY public.ab_user_role (id, user_id, role_id) FROM stdin;
    public          postgres    false    214   ��       �          0    142331    ab_view_menu 
   TABLE DATA           0   COPY public.ab_view_menu (id, name) FROM stdin;
    public          postgres    false    221   ��                 0    166824 	   categoria 
   TABLE DATA           2   COPY public.categoria (id, categoria) FROM stdin;
    public          postgres    false    231   ��                 0    166939    clientes 
   TABLE DATA           �   COPY public.clientes (created_on, changed_on, id, documento, nombre, apellido, "tipoDocumento", estado, created_by_fk, changed_by_fk) FROM stdin;
    public          postgres    false    237   3�                 0    166978    compras 
   TABLE DATA           q   COPY public.compras (id, "Estado", total, fecha, "condicionFrenteIva", proveedor_id, formadepago_id) FROM stdin;
    public          postgres    false    241   ��       
          0    166929    formadepago 
   TABLE DATA           f   COPY public.formadepago (id, "Metodo", "numeroCupon", "companiaTarjeta", credito, cuotas) FROM stdin;
    public          postgres    false    235   )�       �          0    101175    marcas 
   TABLE DATA           +   COPY public.marcas (id, marca) FROM stdin;
    public          postgres    false    220   S�                 0    166870 	   productos 
   TABLE DATA           �   COPY public.productos (created_on, changed_on, id, precio, stock, unidad_id, marcas_id, categoria_id, medida, detalle, created_by_fk, changed_by_fk) FROM stdin;
    public          postgres    false    233   ��                 0    166768 	   proveedor 
   TABLE DATA           �   COPY public.proveedor (created_on, changed_on, id, cuit, nombre, apellido, domicilio, correo, estado, created_by_fk, changed_by_fk) FROM stdin;
    public          postgres    false    227   )�       �          0    142642    renglon 
   TABLE DATA           U   COPY public.renglon (id, "precioVenta", cantidad, venta_id, producto_id) FROM stdin;
    public          postgres    false    223   �                 0    166806    renglon_compras 
   TABLE DATA           _   COPY public.renglon_compras (id, "precioCompra", cantidad, compra_id, producto_id) FROM stdin;
    public          postgres    false    229   *�       �          0    101165    unidad_medida 
   TABLE DATA           3   COPY public.unidad_medida (id, unidad) FROM stdin;
    public          postgres    false    218   7�                  0    150384    users 
   TABLE DATA           d   COPY public.users (id, username, password, email, rol, estado, fechainicio, fechafinal) FROM stdin;
    public          postgres    false    225   t�                 0    166959    ventas 
   TABLE DATA           n   COPY public.ventas (id, "Estado", fecha, "condicionFrenteIva", total, cliente_id, formadepago_id) FROM stdin;
    public          postgres    false    239   ��       #           0    0    ab_permission_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.ab_permission_id_seq', 25, true);
          public          postgres    false    202            $           0    0    ab_permission_view_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.ab_permission_view_id_seq', 208, true);
          public          postgres    false    211            %           0    0    ab_permission_view_role_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.ab_permission_view_role_id_seq', 249, true);
          public          postgres    false    215            &           0    0    ab_register_user_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.ab_register_user_id_seq', 1, false);
          public          postgres    false    209            '           0    0    ab_role_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.ab_role_id_seq', 4, true);
          public          postgres    false    205            (           0    0    ab_user_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.ab_user_id_seq', 3, true);
          public          postgres    false    207            )           0    0    ab_user_role_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.ab_user_role_id_seq', 4, true);
          public          postgres    false    213            *           0    0    ab_view_menu_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.ab_view_menu_id_seq', 101, true);
          public          postgres    false    204            +           0    0    categoria_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.categoria_id_seq', 11, true);
          public          postgres    false    230            ,           0    0    clientes_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.clientes_id_seq', 373, true);
          public          postgres    false    236            -           0    0    compras_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.compras_id_seq', 28, true);
          public          postgres    false    240            .           0    0    formadepago_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.formadepago_id_seq', 257, true);
          public          postgres    false    234            /           0    0    marcas_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.marcas_id_seq', 19, true);
          public          postgres    false    219            0           0    0    productos_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.productos_id_seq', 11, true);
          public          postgres    false    232            1           0    0    proveedor_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.proveedor_id_seq', 4, true);
          public          postgres    false    226            2           0    0    renglon_compras_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.renglon_compras_id_seq', 38, true);
          public          postgres    false    228            3           0    0    renglon_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.renglon_id_seq', 103, true);
          public          postgres    false    222            4           0    0    unidad_medida_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.unidad_medida_id_seq', 4, true);
          public          postgres    false    217            5           0    0    users_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.users_id_seq', 1, false);
          public          postgres    false    224            6           0    0    ventas_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.ventas_id_seq', 6, true);
          public          postgres    false    238                       2606    100458 $   ab_permission ab_permission_name_key 
   CONSTRAINT     _   ALTER TABLE ONLY public.ab_permission
    ADD CONSTRAINT ab_permission_name_key UNIQUE (name);
 N   ALTER TABLE ONLY public.ab_permission DROP CONSTRAINT ab_permission_name_key;
       public            postgres    false    203                       2606    100456     ab_permission ab_permission_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.ab_permission
    ADD CONSTRAINT ab_permission_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.ab_permission DROP CONSTRAINT ab_permission_pkey;
       public            postgres    false    203                       2606    100521 D   ab_permission_view ab_permission_view_permission_id_view_menu_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_permission_id_view_menu_id_key UNIQUE (permission_id, view_menu_id);
 n   ALTER TABLE ONLY public.ab_permission_view DROP CONSTRAINT ab_permission_view_permission_id_view_menu_id_key;
       public            postgres    false    212    212            !           2606    100519 *   ab_permission_view ab_permission_view_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.ab_permission_view DROP CONSTRAINT ab_permission_view_pkey;
       public            postgres    false    212            '           2606    100559 N   ab_permission_view_role ab_permission_view_role_permission_view_id_role_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_permission_view_id_role_id_key UNIQUE (permission_view_id, role_id);
 x   ALTER TABLE ONLY public.ab_permission_view_role DROP CONSTRAINT ab_permission_view_role_permission_view_id_role_id_key;
       public            postgres    false    216    216            )           2606    100557 4   ab_permission_view_role ab_permission_view_role_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.ab_permission_view_role DROP CONSTRAINT ab_permission_view_role_pkey;
       public            postgres    false    216                       2606    100510 &   ab_register_user ab_register_user_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.ab_register_user
    ADD CONSTRAINT ab_register_user_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.ab_register_user DROP CONSTRAINT ab_register_user_pkey;
       public            postgres    false    210                       2606    100512 .   ab_register_user ab_register_user_username_key 
   CONSTRAINT     m   ALTER TABLE ONLY public.ab_register_user
    ADD CONSTRAINT ab_register_user_username_key UNIQUE (username);
 X   ALTER TABLE ONLY public.ab_register_user DROP CONSTRAINT ab_register_user_username_key;
       public            postgres    false    210                       2606    100476    ab_role ab_role_name_key 
   CONSTRAINT     S   ALTER TABLE ONLY public.ab_role
    ADD CONSTRAINT ab_role_name_key UNIQUE (name);
 B   ALTER TABLE ONLY public.ab_role DROP CONSTRAINT ab_role_name_key;
       public            postgres    false    206                       2606    100474    ab_role ab_role_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.ab_role
    ADD CONSTRAINT ab_role_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.ab_role DROP CONSTRAINT ab_role_pkey;
       public            postgres    false    206                       2606    100490    ab_user ab_user_email_key 
   CONSTRAINT     U   ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_email_key UNIQUE (email);
 C   ALTER TABLE ONLY public.ab_user DROP CONSTRAINT ab_user_email_key;
       public            postgres    false    208                       2606    100486    ab_user ab_user_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.ab_user DROP CONSTRAINT ab_user_pkey;
       public            postgres    false    208            #           2606    100538    ab_user_role ab_user_role_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.ab_user_role DROP CONSTRAINT ab_user_role_pkey;
       public            postgres    false    214            %           2606    100540 -   ab_user_role ab_user_role_user_id_role_id_key 
   CONSTRAINT     t   ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_user_id_role_id_key UNIQUE (user_id, role_id);
 W   ALTER TABLE ONLY public.ab_user_role DROP CONSTRAINT ab_user_role_user_id_role_id_key;
       public            postgres    false    214    214                       2606    100488    ab_user ab_user_username_key 
   CONSTRAINT     [   ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_username_key UNIQUE (username);
 F   ALTER TABLE ONLY public.ab_user DROP CONSTRAINT ab_user_username_key;
       public            postgres    false    208            3           2606    142337 "   ab_view_menu ab_view_menu_name_key 
   CONSTRAINT     ]   ALTER TABLE ONLY public.ab_view_menu
    ADD CONSTRAINT ab_view_menu_name_key UNIQUE (name);
 L   ALTER TABLE ONLY public.ab_view_menu DROP CONSTRAINT ab_view_menu_name_key;
       public            postgres    false    221            5           2606    142335    ab_view_menu ab_view_menu_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.ab_view_menu
    ADD CONSTRAINT ab_view_menu_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.ab_view_menu DROP CONSTRAINT ab_view_menu_pkey;
       public            postgres    false    221            C           2606    166831 !   categoria categoria_categoria_key 
   CONSTRAINT     a   ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_categoria_key UNIQUE (categoria);
 K   ALTER TABLE ONLY public.categoria DROP CONSTRAINT categoria_categoria_key;
       public            postgres    false    231            E           2606    166829    categoria categoria_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.categoria DROP CONSTRAINT categoria_pkey;
       public            postgres    false    231            O           2606    166944    clientes clientes_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.clientes DROP CONSTRAINT clientes_pkey;
       public            postgres    false    237            Q           2606    166946 -   clientes clientes_tipoDocumento_documento_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT "clientes_tipoDocumento_documento_key" UNIQUE ("tipoDocumento", documento);
 Y   ALTER TABLE ONLY public.clientes DROP CONSTRAINT "clientes_tipoDocumento_documento_key";
       public            postgres    false    237    237            U           2606    166983    compras compras_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.compras DROP CONSTRAINT compras_pkey;
       public            postgres    false    241            K           2606    166936 '   formadepago formadepago_numeroCupon_key 
   CONSTRAINT     m   ALTER TABLE ONLY public.formadepago
    ADD CONSTRAINT "formadepago_numeroCupon_key" UNIQUE ("numeroCupon");
 S   ALTER TABLE ONLY public.formadepago DROP CONSTRAINT "formadepago_numeroCupon_key";
       public            postgres    false    235            M           2606    166934    formadepago formadepago_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.formadepago
    ADD CONSTRAINT formadepago_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.formadepago DROP CONSTRAINT formadepago_pkey;
       public            postgres    false    235            /           2606    101182    marcas marcas_marca_key 
   CONSTRAINT     S   ALTER TABLE ONLY public.marcas
    ADD CONSTRAINT marcas_marca_key UNIQUE (marca);
 A   ALTER TABLE ONLY public.marcas DROP CONSTRAINT marcas_marca_key;
       public            postgres    false    220            1           2606    101180    marcas marcas_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.marcas
    ADD CONSTRAINT marcas_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.marcas DROP CONSTRAINT marcas_pkey;
       public            postgres    false    220            G           2606    166877 ?   productos productos_categoria_id_marcas_id_unidad_id_medida_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_categoria_id_marcas_id_unidad_id_medida_key UNIQUE (categoria_id, marcas_id, unidad_id, medida);
 i   ALTER TABLE ONLY public.productos DROP CONSTRAINT productos_categoria_id_marcas_id_unidad_id_medida_key;
       public            postgres    false    233    233    233    233            I           2606    166875    productos productos_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.productos DROP CONSTRAINT productos_pkey;
       public            postgres    false    233            =           2606    166775    proveedor proveedor_cuit_key 
   CONSTRAINT     W   ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT proveedor_cuit_key UNIQUE (cuit);
 F   ALTER TABLE ONLY public.proveedor DROP CONSTRAINT proveedor_cuit_key;
       public            postgres    false    227            ?           2606    166773    proveedor proveedor_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT proveedor_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.proveedor DROP CONSTRAINT proveedor_pkey;
       public            postgres    false    227            A           2606    166811 $   renglon_compras renglon_compras_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.renglon_compras
    ADD CONSTRAINT renglon_compras_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.renglon_compras DROP CONSTRAINT renglon_compras_pkey;
       public            postgres    false    229            7           2606    142647    renglon renglon_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.renglon
    ADD CONSTRAINT renglon_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.renglon DROP CONSTRAINT renglon_pkey;
       public            postgres    false    223            +           2606    101170     unidad_medida unidad_medida_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.unidad_medida
    ADD CONSTRAINT unidad_medida_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.unidad_medida DROP CONSTRAINT unidad_medida_pkey;
       public            postgres    false    218            -           2606    101172 &   unidad_medida unidad_medida_unidad_key 
   CONSTRAINT     c   ALTER TABLE ONLY public.unidad_medida
    ADD CONSTRAINT unidad_medida_unidad_key UNIQUE (unidad);
 P   ALTER TABLE ONLY public.unidad_medida DROP CONSTRAINT unidad_medida_unidad_key;
       public            postgres    false    218            9           2606    150389    users users_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public            postgres    false    225            ;           2606    150391    users users_username_key 
   CONSTRAINT     W   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_username_key;
       public            postgres    false    225            S           2606    166964    ventas ventas_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.ventas DROP CONSTRAINT ventas_pkey;
       public            postgres    false    239            j           2620    166995 %   renglon_compras updateproductoscompra    TRIGGER     �   CREATE TRIGGER updateproductoscompra AFTER INSERT ON public.renglon_compras FOR EACH ROW EXECUTE FUNCTION public.sumarstockencompra();
 >   DROP TRIGGER updateproductoscompra ON public.renglon_compras;
       public          postgres    false    229    242            X           2606    100522 8   ab_permission_view ab_permission_view_permission_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.ab_permission(id);
 b   ALTER TABLE ONLY public.ab_permission_view DROP CONSTRAINT ab_permission_view_permission_id_fkey;
       public          postgres    false    203    212    2831            [           2606    100560 G   ab_permission_view_role ab_permission_view_role_permission_view_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_permission_view_id_fkey FOREIGN KEY (permission_view_id) REFERENCES public.ab_permission_view(id);
 q   ALTER TABLE ONLY public.ab_permission_view_role DROP CONSTRAINT ab_permission_view_role_permission_view_id_fkey;
       public          postgres    false    216    2849    212            \           2606    100565 <   ab_permission_view_role ab_permission_view_role_role_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.ab_role(id);
 f   ALTER TABLE ONLY public.ab_permission_view_role DROP CONSTRAINT ab_permission_view_role_role_id_fkey;
       public          postgres    false    2835    216    206            W           2606    100496 "   ab_user ab_user_changed_by_fk_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_changed_by_fk_fkey FOREIGN KEY (changed_by_fk) REFERENCES public.ab_user(id);
 L   ALTER TABLE ONLY public.ab_user DROP CONSTRAINT ab_user_changed_by_fk_fkey;
       public          postgres    false    208    2839    208            V           2606    100491 "   ab_user ab_user_created_by_fk_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_created_by_fk_fkey FOREIGN KEY (created_by_fk) REFERENCES public.ab_user(id);
 L   ALTER TABLE ONLY public.ab_user DROP CONSTRAINT ab_user_created_by_fk_fkey;
       public          postgres    false    208    208    2839            Z           2606    100546 &   ab_user_role ab_user_role_role_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.ab_role(id);
 P   ALTER TABLE ONLY public.ab_user_role DROP CONSTRAINT ab_user_role_role_id_fkey;
       public          postgres    false    206    2835    214            Y           2606    100541 &   ab_user_role ab_user_role_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.ab_user(id);
 P   ALTER TABLE ONLY public.ab_user_role DROP CONSTRAINT ab_user_role_user_id_fkey;
       public          postgres    false    2839    208    214            e           2606    166952 $   clientes clientes_changed_by_fk_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_changed_by_fk_fkey FOREIGN KEY (changed_by_fk) REFERENCES public.ab_user(id);
 N   ALTER TABLE ONLY public.clientes DROP CONSTRAINT clientes_changed_by_fk_fkey;
       public          postgres    false    237    2839    208            d           2606    166947 $   clientes clientes_created_by_fk_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_created_by_fk_fkey FOREIGN KEY (created_by_fk) REFERENCES public.ab_user(id);
 N   ALTER TABLE ONLY public.clientes DROP CONSTRAINT clientes_created_by_fk_fkey;
       public          postgres    false    237    2839    208            i           2606    166989 #   compras compras_formadepago_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_formadepago_id_fkey FOREIGN KEY (formadepago_id) REFERENCES public.formadepago(id);
 M   ALTER TABLE ONLY public.compras DROP CONSTRAINT compras_formadepago_id_fkey;
       public          postgres    false    235    241    2893            h           2606    166984 !   compras compras_proveedor_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_proveedor_id_fkey FOREIGN KEY (proveedor_id) REFERENCES public.proveedor(id);
 K   ALTER TABLE ONLY public.compras DROP CONSTRAINT compras_proveedor_id_fkey;
       public          postgres    false    2879    227    241            a           2606    166888 %   productos productos_categoria_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_categoria_id_fkey FOREIGN KEY (categoria_id) REFERENCES public.categoria(id);
 O   ALTER TABLE ONLY public.productos DROP CONSTRAINT productos_categoria_id_fkey;
       public          postgres    false    233    2885    231            c           2606    166898 &   productos productos_changed_by_fk_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_changed_by_fk_fkey FOREIGN KEY (changed_by_fk) REFERENCES public.ab_user(id);
 P   ALTER TABLE ONLY public.productos DROP CONSTRAINT productos_changed_by_fk_fkey;
       public          postgres    false    233    2839    208            b           2606    166893 &   productos productos_created_by_fk_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_created_by_fk_fkey FOREIGN KEY (created_by_fk) REFERENCES public.ab_user(id);
 P   ALTER TABLE ONLY public.productos DROP CONSTRAINT productos_created_by_fk_fkey;
       public          postgres    false    208    233    2839            `           2606    166883 "   productos productos_marcas_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_marcas_id_fkey FOREIGN KEY (marcas_id) REFERENCES public.marcas(id);
 L   ALTER TABLE ONLY public.productos DROP CONSTRAINT productos_marcas_id_fkey;
       public          postgres    false    233    220    2865            _           2606    166878 "   productos productos_unidad_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad_medida(id);
 L   ALTER TABLE ONLY public.productos DROP CONSTRAINT productos_unidad_id_fkey;
       public          postgres    false    2859    218    233            ^           2606    166781 &   proveedor proveedor_changed_by_fk_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT proveedor_changed_by_fk_fkey FOREIGN KEY (changed_by_fk) REFERENCES public.ab_user(id);
 P   ALTER TABLE ONLY public.proveedor DROP CONSTRAINT proveedor_changed_by_fk_fkey;
       public          postgres    false    2839    227    208            ]           2606    166776 &   proveedor proveedor_created_by_fk_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT proveedor_created_by_fk_fkey FOREIGN KEY (created_by_fk) REFERENCES public.ab_user(id);
 P   ALTER TABLE ONLY public.proveedor DROP CONSTRAINT proveedor_created_by_fk_fkey;
       public          postgres    false    2839    227    208            f           2606    166965    ventas ventas_cliente_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id);
 G   ALTER TABLE ONLY public.ventas DROP CONSTRAINT ventas_cliente_id_fkey;
       public          postgres    false    2895    237    239            g           2606    166970 !   ventas ventas_formadepago_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_formadepago_id_fkey FOREIGN KEY (formadepago_id) REFERENCES public.formadepago(id);
 K   ALTER TABLE ONLY public.ventas DROP CONSTRAINT ventas_formadepago_id_fkey;
       public          postgres    false    239    2893    235            �   �   x�]P�n� {�}�ԣ����$�� q�F��QP�jo���8y��.Q��5�_R0��¢p�b����
Q�ҡ�:Zc33�ye�ک,�í�M��<3�i�$��(Nd� qHOA ��|п��(o�yO��-���J�#�_\m���Q	G�D�p@���5r����S�ek;����f��C��ŝ�:0cϩ��.��V�i���~> ��Nx�      �   �  x�-��q!�(ׂ�)���_�t� $�z�m�hC�)�1�;����8-[�mS�Ֆ~��6�9�h�,d6}�*DGw��i�ѿ��У���ShTV�2`M�G����&nG���`�S')����'�3p#�*250����葊���������1#v�j�:t9XE��b�*�UtyቹYxcJ/��������B�m���[~�HH�X���s�:|�X�RB���犍I}���$:�(]��ձ�DE,.b�C�8$<U
�7� v��6�Il�"�t[z�[ʹ���˹QY��GS����w1_��/�Q�-������e�3�|�sF�v�M*;
��R���a����ϣR���
�N���Ѥ&�j�s5�݄i�Ł��R=�t�)���D����d����MU��Wlp�.��j�V�u��v��3����Bo��6P�g���U��^�p/��*�$�
�f�<2:OR��w��aP�i���3�h�Id��K[t=��j�P<I�ڍG�<K&ʑ��sGIQ�	�u�}@� \��+�r*�R��SƎr�_t�xt��g��H�.�U2��y�k�����+[jCe�j5��G��2p+^my��]����:�\�!t�Ai�<n��@^9v[�K�n�T���Co��K��9m%��?KGxZ2\8/�WD7P/*��{)�/��NW��`�E7P��ܠղ�R���Ky������|=~"�f
t      �   �  x�-�K��0�֯3�d�w���9F|��h�a��!
�/�}��}-U_�V_�v_�N_�n_�^_c��_��<�8�h �h�h�h�h�h�h�JxJ��B�r*�e)��R�˭��G	/�^>%�94��Є7S�+�%�	o.MxskG޼���ӄWC�B�R��ʿY�h�j���V����WW��
�Z�Vh�[�oM-x������ւ���u�୧omx;���Ԇ��6�]����������G޾���ӆw��:�N��;S�)xg��;[�oJ�*��Ձw��;t��ЅwSޝ��n�»K�ݺ������/��tὡ���z��ԃ�J�[z��փ���w��6?���> �!y�a�C��b�6_������{�{�7�[�����^�������a#����jV1�eC���֋=��C�a�PdX;$M��C�a�Pe�3��]>������F�Ol���F�On���F�Op���@�<PȚY�@����|��d��,|������R�>���ZY�@,��e�����;�`�@��3H��9�h�A��s�� �9	�p�B�\}l��h�4�9�z�C ���D:���D �Ch�T"�/��w.�@G'#���t6)�@K�#���t>9�@��%���H��3H��:%���I��s���:)���J���H{�����;:��$n8/�L�����$n83�M�S����$n87���)l
S���1�WĴ�"��1���zEL�+�	7�?7�?7�ɸq�SyEL�+b�^�񊘮W�������7���G4q�}�n�C���&n8���iↃ���&n�\�nxwz�����vû�S���;��Tw�������'�˕�w��>�]��~��?�kF:      �      x������ � �      �   3   x�3�tL����2�(M��L�2�,K�KIM�/�2�LO-J�+I����� |H      �   x  x�}��n[!E׼����<�̰겋$]�U�*xiT۱�4j���j�V�@�ps��Sߵ��ܡ�کB���m�|�V(�`�u�l�t�tX7�j��c����VB�l~15�I��B��FI��+��{<uzw�-w���o�腇h���fDb'N2�b����U�c|-q&�$du�hBW��n�>���z��<�����������ՠK�V�*sO�B�nQ؊u�C�؀�>@�J��Ҫ�2 ��z���o<b2�3��9��pBZ!g��4kP��ts=���m��>�_n��o6��ï�5X���k�VS�hР��b��%֘e큓ii� ʗFg�<�r��qV�����@s�aߒƜn�i�~�!��      �      x�3�4�4�2�4�4�2�4�4����� !��      �   �  x�]�Mo� ��ï�͗��G�p�I�P���V���
�4ErM8��_`�]���3����tc���IZ���t)�1x���<*���f�J�zb��cw�Dh<��]��sLX1wߛN����Ҷҭ�
�Aw�S(�B����S0����S�ie�0b���j��bM��S� ��4�C����|�<;e�7��>iM����bT&�n���T�Ϣ�HS��IVhz�B)�Q(K����n�.�ԯIj�n���vN�aUO�V:�-9Gx1�Wø��L����T�r�^�z������C\+�p�^h�ga�ñ���A�<�����y\x:Of���ҫ�����|�~��7�����1'\��3v���좜]����$���ɢ�E=EHo��z��`Ѡg�:c�j��`mQ�Ŭb�(�b�7_�,��
�V�?!� ��/'         T   x��K
�0�u�a�����pk(��BZzz��z�O�H���ʘ��I�Ƙ�k.X(�wy+EM�f�b��(!�ή�q >y��         �   x���1
�@E��Sx������춊�E�4�@L���ӻ�U3��?��h� ,�mH�`[�cR�l�a�/�y�n����������%L&������/P+/�N�8�b��NV2��/$�gr�|��RD	KA����7��T��*
ǹ�F8��}z7�1�r�Ug         /  x���Kn�0D��]R��>�
��8i
H��v�_R	PTue��y�Ѭ�ZC����s���q>��}��A�@m���� �|Y�B����8.�y���!!"8Ifۀ���Z#��W��A�|K�~`T���"��N�wi'e<$�+�o�8��pz�ò��Z����,���e�-{���[�����O�;�Tu���6C��p��
:�7#4���n&�jC�U�<��J���,T��� 5�n�Ά	H�Q�=���~/�1ei�R!7Vg>���Hu��n��K/c?p�����#����7 �A'      
     x�u�[��J��g�`���t�DF��$�tL�J�M��J궾�佨\>�|�]?��|�p���/��Y�M�]��W-nZܵ����*�ª0+�
�²0-l+�ۊmŶb[���Vl+��f��l�}3�mf�̶�m3�f��lklklklk~����������������������5¶ζζζζ�m��-l[ض�;�m��-l[ٶ�me�ʶ�m+�V ��l[ٶ�mc�ƶ�m�6�ml�<�ض�mg�ζ�m;�v��l�ٶ�m��>��ޓ����=y~O��'��>����������z�s��qS����z�]�q��|r�U�{����x�,'b9!ˉY��X-1[b��p���%�K��X/1_b�Ā�&6L��X11cb�Đ�%S&�L��X31g2<s��� �����eǜj�Į�a�&�Ml�7�nb�ľ��'&Nl�9�rb��Ή�K'�Nl�;�vb��މ��'&Ol�=�zb�����'�Ol�?�~b����(&Pl�A��b��!K�,����*K�,�����g	�}���$?��n_�>]�>��Y����*{�졲��*{�졲����M��]��mW�l��?���~��?�c:���ð�qJ����e���m[�qe�׷������w��d�g��}Ro���������G�>fC[�I��5F�wո�O�Ǜ�?�=����
[[�c=]B{��>�������2���*#���2���*#���2���*o�}U�U�We_�}U�U�We_�}U�U��7�xD�;��18n��������40�      �   �   x����@��tF`9ix�2.#L�~��S�e&������M�DÕ^WAE�$:EMN>�M�,h�%''���FY�����t���VEO�ڸN�Y�5�x0�S�y�\��=T��.{'��+5�?� ����Ѫ9ؐ��i�����n;7           x�}�͑�@���& �������c���O��eu��� $�3��?�k�bB	�9@�%'���`��v�K��b�pf�5bB��'�\bi�|ǝ%#0�FD�О����H�14+㬴R�;��BT(�l\pwI�9�GgR�gk�����.҄ /O��ߌ)�Rzط��ܽe�z�F�8�E�x����v��	0����J4M�q{���C�'�y=��i�?�K�U����>�Iw���S�k����pκ3�|�GuG��۶��ݔ�         �   x�}�AN1EמSp�D�c;�,ˆ�݄i�Ji�?��Ĩj���������С=�%e>�,,��%N�h,9�z���¹��{���VJ�5�*9��㞙�pdN�Q�s]ڡ��C����h�B,A�)��SSs/����ڗ�?�k{��R�����C2�0ߺ��Q����Ԓ���e�'�����w~��:NR�      �     x�MT[�c!�ƋA �r�����U%�����J/VZ�2+A+�x-Ϋa��V���?U7:a���ϱ�meћ�3#y����ݤ&?��K�K����M�B9v��1�х֒����|K�Q,�!A0����!�6e�<���Քm�O��k�CwfU�)�	P�~j��ltͮ�rV�})(�.4_!7����	0T�l0�R[CJ�g$ rd~��y�Qz��$�z�&��d�t����X�����G��!�Y���~V3x��_ĭj� y�C����?eT��9�� ��O�B�OZj��T#��E���O��6�߸��o��_.���6>~�q�����l_b�>����x6�!��V(<���}uA6?Cy8�-���At��.�If��>���\�`\.b�v��9�e��'�Ņ9�T�z\`~A���@��f���k]�tZo���������v�G쳽��^G�Л�?tv.Kn c"crv�3��'�2�Z��/?H��M��;SϚ�ԕвX$�V�c3�����C���         �   x�5��q!D��`\H�8�8�-Ƈ��@�Y���27G4D���$�7�%aY��l��､a��-���y���|v-V;��D8�n��چ���j�N>Q�OӍ�F\{�9���;EZ·�ͥ�S��1�,����E��1tګ7��9[�\6Y��JD�H!�s���!��F�XM�s)*��
"Ԗ�����,i#�U�� ]$_�@m�a"SUV��FΖX�
�E)c�0�|=���,��-Cy�+e����Ot      �   -   x�3���,)��2�L/J��/�2������2����Ʉ���qqq 8�             x������ � �         |   x���;�0E�zf/A�alyH�&����a��������BB�@�Z���]r`!F9v��ԝ��%{��08`�h߰�}u;ޗ�Z���Uwd�/������j���X��	wA�AZ     