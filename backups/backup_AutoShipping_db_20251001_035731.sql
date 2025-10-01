--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

-- Started on 2025-10-01 03:57:31 MSK

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE ONLY public.orders DROP CONSTRAINT orders_client_id_fkey;
ALTER TABLE ONLY public.orders DROP CONSTRAINT orders_car_id_fkey;
ALTER TABLE ONLY public.order_services DROP CONSTRAINT order_services_service_id_fkey;
ALTER TABLE ONLY public.order_services DROP CONSTRAINT order_services_order_id_fkey;
ALTER TABLE ONLY public.client_documents DROP CONSTRAINT client_documents_client_id_fkey;
ALTER TABLE ONLY public.cars DROP CONSTRAINT cars_supplier_id_fkey;
DROP INDEX public.idx_orders_order_date;
DROP INDEX public.idx_orders_client_id;
DROP INDEX public.idx_orders_car_id;
DROP INDEX public.idx_cars_supplier_id;
ALTER TABLE ONLY public.suppliers DROP CONSTRAINT suppliers_pkey;
ALTER TABLE ONLY public.services DROP CONSTRAINT services_pkey;
ALTER TABLE ONLY public.orders DROP CONSTRAINT orders_pkey;
ALTER TABLE ONLY public.order_services DROP CONSTRAINT order_services_pkey;
ALTER TABLE ONLY public.clients DROP CONSTRAINT clients_pkey;
ALTER TABLE ONLY public.clients DROP CONSTRAINT clients_email_key;
ALTER TABLE ONLY public.client_documents DROP CONSTRAINT client_documents_pkey;
ALTER TABLE ONLY public.client_documents DROP CONSTRAINT client_documents_client_id_key;
ALTER TABLE ONLY public.cars DROP CONSTRAINT cars_vin_key;
ALTER TABLE ONLY public.cars DROP CONSTRAINT cars_pkey;
ALTER TABLE public.suppliers ALTER COLUMN supplier_id DROP DEFAULT;
ALTER TABLE public.services ALTER COLUMN service_id DROP DEFAULT;
ALTER TABLE public.orders ALTER COLUMN order_id DROP DEFAULT;
ALTER TABLE public.clients ALTER COLUMN client_id DROP DEFAULT;
ALTER TABLE public.client_documents ALTER COLUMN document_id DROP DEFAULT;
ALTER TABLE public.cars ALTER COLUMN car_id DROP DEFAULT;
DROP SEQUENCE public.suppliers_supplier_id_seq;
DROP TABLE public.suppliers;
DROP SEQUENCE public.services_service_id_seq;
DROP TABLE public.services;
DROP SEQUENCE public.orders_order_id_seq;
DROP TABLE public.orders;
DROP TABLE public.order_services;
DROP SEQUENCE public.clients_client_id_seq;
DROP TABLE public.clients;
DROP SEQUENCE public.client_documents_document_id_seq;
DROP TABLE public.client_documents;
DROP SEQUENCE public.cars_car_id_seq;
DROP TABLE public.cars;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 222 (class 1259 OID 18295)
-- Name: cars; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cars (
    car_id integer NOT NULL,
    vin character varying(17) NOT NULL,
    brand character varying(50) NOT NULL,
    model character varying(50) NOT NULL,
    year integer NOT NULL,
    engine_volume numeric(3,1) NOT NULL,
    fuel_type character varying(20) NOT NULL,
    transmission character varying(20) NOT NULL,
    color character varying(30) NOT NULL,
    mileage integer DEFAULT 0,
    price_eur numeric(10,2) NOT NULL,
    supplier_id integer,
    CONSTRAINT cars_year_check CHECK (((year >= 1900) AND ((year)::numeric <= EXTRACT(year FROM CURRENT_DATE))))
);


--
-- TOC entry 221 (class 1259 OID 18294)
-- Name: cars_car_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cars_car_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3686 (class 0 OID 0)
-- Dependencies: 221
-- Name: cars_car_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cars_car_id_seq OWNED BY public.cars.car_id;


--
-- TOC entry 226 (class 1259 OID 18331)
-- Name: client_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.client_documents (
    document_id integer NOT NULL,
    client_id integer,
    passport_scan_path character varying(200),
    driver_license_path character varying(200),
    additional_docs_path character varying(200),
    upload_date date DEFAULT CURRENT_DATE
);


--
-- TOC entry 225 (class 1259 OID 18330)
-- Name: client_documents_document_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.client_documents_document_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3687 (class 0 OID 0)
-- Dependencies: 225
-- Name: client_documents_document_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.client_documents_document_id_seq OWNED BY public.client_documents.document_id;


--
-- TOC entry 218 (class 1259 OID 18276)
-- Name: clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clients (
    client_id integer NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    phone character varying(20) NOT NULL,
    email character varying(100) NOT NULL,
    passport_series character varying(10) NOT NULL,
    passport_number character varying(10) NOT NULL,
    registration_date date DEFAULT CURRENT_DATE,
    birth_date date NOT NULL
);


--
-- TOC entry 217 (class 1259 OID 18275)
-- Name: clients_client_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.clients_client_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3688 (class 0 OID 0)
-- Dependencies: 217
-- Name: clients_client_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.clients_client_id_seq OWNED BY public.clients.client_id;


--
-- TOC entry 229 (class 1259 OID 18356)
-- Name: order_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_services (
    order_id integer NOT NULL,
    service_id integer NOT NULL,
    quantity integer DEFAULT 1,
    price_rub numeric(10,2) NOT NULL
);


--
-- TOC entry 224 (class 1259 OID 18311)
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orders (
    order_id integer NOT NULL,
    client_id integer,
    car_id integer,
    order_date date DEFAULT CURRENT_DATE,
    expected_delivery_date date,
    actual_delivery_date date,
    total_cost_rub numeric(12,2) NOT NULL,
    status character varying(30) DEFAULT 'В обработке'::character varying,
    customs_cleared boolean DEFAULT false
);


--
-- TOC entry 223 (class 1259 OID 18310)
-- Name: orders_order_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.orders_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3689 (class 0 OID 0)
-- Dependencies: 223
-- Name: orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.orders_order_id_seq OWNED BY public.orders.order_id;


--
-- TOC entry 228 (class 1259 OID 18348)
-- Name: services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.services (
    service_id integer NOT NULL,
    service_name character varying(100) NOT NULL,
    description text,
    base_price_rub numeric(10,2) NOT NULL
);


--
-- TOC entry 227 (class 1259 OID 18347)
-- Name: services_service_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.services_service_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3690 (class 0 OID 0)
-- Dependencies: 227
-- Name: services_service_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.services_service_id_seq OWNED BY public.services.service_id;


--
-- TOC entry 220 (class 1259 OID 18286)
-- Name: suppliers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.suppliers (
    supplier_id integer NOT NULL,
    company_name character varying(100) NOT NULL,
    country character varying(50) NOT NULL,
    city character varying(50) NOT NULL,
    address text NOT NULL,
    contact_person character varying(100) NOT NULL,
    phone character varying(20) NOT NULL,
    email character varying(100) NOT NULL
);


--
-- TOC entry 219 (class 1259 OID 18285)
-- Name: suppliers_supplier_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.suppliers_supplier_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3691 (class 0 OID 0)
-- Dependencies: 219
-- Name: suppliers_supplier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.suppliers_supplier_id_seq OWNED BY public.suppliers.supplier_id;


--
-- TOC entry 3482 (class 2604 OID 18298)
-- Name: cars car_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cars ALTER COLUMN car_id SET DEFAULT nextval('public.cars_car_id_seq'::regclass);


--
-- TOC entry 3488 (class 2604 OID 18334)
-- Name: client_documents document_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_documents ALTER COLUMN document_id SET DEFAULT nextval('public.client_documents_document_id_seq'::regclass);


--
-- TOC entry 3479 (class 2604 OID 18279)
-- Name: clients client_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients ALTER COLUMN client_id SET DEFAULT nextval('public.clients_client_id_seq'::regclass);


--
-- TOC entry 3484 (class 2604 OID 18314)
-- Name: orders order_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders ALTER COLUMN order_id SET DEFAULT nextval('public.orders_order_id_seq'::regclass);


--
-- TOC entry 3490 (class 2604 OID 18351)
-- Name: services service_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services ALTER COLUMN service_id SET DEFAULT nextval('public.services_service_id_seq'::regclass);


--
-- TOC entry 3481 (class 2604 OID 18289)
-- Name: suppliers supplier_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suppliers ALTER COLUMN supplier_id SET DEFAULT nextval('public.suppliers_supplier_id_seq'::regclass);


--
-- TOC entry 3673 (class 0 OID 18295)
-- Dependencies: 222
-- Data for Name: cars; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cars (car_id, vin, brand, model, year, engine_volume, fuel_type, transmission, color, mileage, price_eur, supplier_id) FROM stdin;
89874	7NBK2WB0LMJ716972	Audi	Q5	2021	4.0	Электро	Вариатор	Серебристый	21720	20137.24	25368
89875	UJLS2BDHNX2Z3FAVA	BMW	X3	2024	2.9	Гибрид	Механика	Красный	33237	34461.44	25310
89876	SGPZP70DRLKZS7GBY	Ford	Model	2020	1.4	Дизель	Вариатор	Зеленый	44246	69458.09	25345
89877	MP27XLB7N8GHEA7GJ	Renault	Model	2017	3.0	Электро	Робот	Белый	31750	67433.02	25301
89878	EFHRLZLSS54G76JDE	Renault	Model	2023	1.7	Бензин	Робот	Серый	116753	54910.21	25479
89879	3XGG2JATW2XCJGYWE	Volkswagen	Tiguan	2020	2.9	Бензин	Робот	Коричневый	67898	65037.89	25336
89880	AD2AWW3NDSDVMFXJ6	Ford	Model	2017	3.2	Электро	Механика	Красный	34959	95605.09	25460
89881	V3LHUJ22SPRDNSSMW	Renault	Model	2016	3.2	Бензин	Робот	Черный	133473	88052.69	25308
89882	E9058G59HAWBN4NXL	Ford	Model	2024	2.0	Гибрид	Робот	Черный	9284	62359.92	25504
89883	65TUPTK16EB54FMJ1	Renault	Model	2024	3.6	Гибрид	Автомат	Коричневый	59697	79449.06	25423
89884	DNH1BV287HULZ65D1	Opel	Model	2024	3.7	Дизель	Автомат	Зеленый	24624	20627.99	25391
89885	271FVVHNPA641P85B	Opel	Model	2020	3.1	Гибрид	Механика	Красный	143102	90790.00	25338
89886	SYZFGZTJCX2986J46	Audi	A6	2019	2.6	Электро	Вариатор	Белый	72672	41413.37	25360
89887	WMUDWKM8ULNPHG9CG	Opel	Model	2024	3.1	Гибрид	Автомат	Зеленый	149018	77269.41	25273
89888	8M0E3TJ3J01X5LPS9	Volkswagen	Tiguan	2016	2.1	Электро	Робот	Белый	29648	56888.04	25445
89889	XNKUX82E71K7D0STL	Volkswagen	Passat	2019	2.0	Гибрид	Механика	Коричневый	119622	37836.72	25369
89890	17B90U452SH5MFKNL	Volkswagen	Tiguan	2020	1.6	Бензин	Автомат	Белый	102477	18216.53	25356
89891	5RACDJLTB09MWEP2Z	Porsche	Panamera	2016	1.6	Бензин	Автомат	Зеленый	79192	90805.90	25356
89892	49KTSTYJ8F1BJUH1Z	Audi	A6	2017	2.2	Гибрид	Механика	Белый	80969	19399.52	25331
89893	ZSNHT6H82JGAEF97J	Opel	Model	2019	2.5	Дизель	Механика	Коричневый	27294	58135.12	25500
89894	CW0345R7UKBL9K9N4	Ford	Model	2020	3.1	Бензин	Вариатор	Белый	68097	55904.09	25296
89895	494KFPA51K9XBH0FV	Audi	A4	2016	2.3	Гибрид	Автомат	Серебристый	14560	80203.17	25306
89896	5TCGCT134UE28MGRV	Volkswagen	Golf	2022	2.8	Дизель	Механика	Синий	69838	97224.44	25261
89897	KG3NBW8MBAHL806HE	Audi	A4	2016	1.5	Дизель	Механика	Серебристый	130713	64510.31	25495
89898	KWFA6YEGHKDSZXH3W	Opel	Model	2023	3.4	Бензин	Автомат	Серый	60278	97335.27	25322
89899	4UL1M3T5J269UDGF7	Renault	Model	2016	1.4	Электро	Автомат	Черный	95829	73505.88	25393
89900	JMHT9U4DAVYPW8E7T	Opel	Model	2020	4.0	Дизель	Автомат	Синий	42787	46185.68	25299
89901	YKH6FSR05CT88SKB0	Audi	A6	2020	2.3	Дизель	Вариатор	Серебристый	58231	61180.60	25347
89902	6482Y6DGRBWL57ZHF	Volkswagen	Tiguan	2019	2.5	Дизель	Робот	Красный	79396	37295.04	25431
89903	UGS5MKJK3DTX85VCH	Opel	Model	2017	1.5	Бензин	Механика	Синий	50522	68648.42	25420
89904	U7V0SEMGWVEHBB6ZK	Audi	A3	2019	2.9	Электро	Автомат	Синий	75534	42699.82	25381
89905	NY3C83FSU0XKYAH1F	Audi	Q5	2017	3.4	Дизель	Автомат	Белый	103387	70365.51	25464
89906	M7ZT7KU7BKUC3LGXV	Volkswagen	Passat	2018	3.0	Бензин	Механика	Зеленый	90058	35099.10	25472
89907	ZKGWKH67WXN7E5NWE	Opel	Model	2015	2.7	Электро	Вариатор	Зеленый	74498	38818.19	25303
89908	PTC5SVKZ3Y70KVZ9C	Volkswagen	Passat	2016	3.7	Бензин	Автомат	Красный	112142	24752.95	25279
89909	GK5PLS650AALR856F	Opel	Model	2023	2.1	Гибрид	Автомат	Черный	6104	40088.22	25461
89910	LBESAF8G6WE8JY8RP	Opel	Model	2023	4.0	Бензин	Механика	Серый	36680	20984.18	25448
89911	Y0G8TNGRGGBLMG1PT	Audi	A4	2021	1.0	Электро	Механика	Серый	55916	85927.45	25396
89912	5EXZE0AA6B4HLEVP5	Renault	Model	2020	1.8	Дизель	Робот	Серебристый	123768	40633.55	25482
89913	ADGUPM3NYB3GR16P6	Volkswagen	Polo	2022	1.7	Бензин	Автомат	Белый	42902	45947.85	25344
89914	BTBBGP7YEUHFPANG0	Volkswagen	Tiguan	2022	2.6	Дизель	Вариатор	Белый	64611	26823.45	25466
89915	W7N9MVRWP7UBZ938M	Audi	A4	2019	3.3	Электро	Робот	Серебристый	32223	69869.82	25336
89916	ACJ2RZ59PTFK7YA0H	Volkswagen	Tiguan	2023	3.9	Бензин	Механика	Белый	10559	90060.85	25321
89917	N27E6J03JWXR9U7VH	Audi	Q7	2021	1.6	Электро	Автомат	Красный	69562	75929.09	25473
89918	ZKV4C38JCMA9MFU9V	Renault	Model	2023	1.6	Электро	Вариатор	Серый	68848	98422.50	25322
89919	TYU14LGN2PDHV7EZ3	BMW	520d	2019	3.3	Дизель	Механика	Синий	98472	89076.46	25364
89920	L4K4D6EG603XCJV1D	Renault	Model	2024	3.9	Дизель	Автомат	Белый	9908	31501.60	25499
89921	XLTDPCX313XGZGWU0	BMW	520d	2016	2.2	Дизель	Механика	Зеленый	115732	55689.53	25481
89922	G009EDU319V7Z1K3X	Volkswagen	Golf	2022	3.2	Дизель	Автомат	Черный	51396	52294.54	25279
89923	UBE8PNT03LYGK2UDR	Ford	Model	2015	2.3	Электро	Вариатор	Серебристый	17026	26108.99	25270
89924	L643Z5CZBHGHREZHS	Ford	Model	2015	3.6	Бензин	Автомат	Серый	49162	36208.17	25485
89925	NKD2ES5SBME9FR608	Volkswagen	Golf	2022	1.9	Дизель	Механика	Черный	15849	55767.86	25380
89926	A6SYLUB7FVS1S5P39	Porsche	Macan	2023	3.5	Дизель	Автомат	Синий	48030	24835.85	25475
89927	CVK7DJMC55C4DYJ89	Opel	Model	2019	2.9	Гибрид	Автомат	Зеленый	100157	42462.69	25383
89928	H9PWT2S94C535PJXM	Audi	A6	2023	3.4	Бензин	Робот	Белый	14114	97230.06	25477
89929	6HPGF7XVMVT4J026P	BMW	X3	2018	3.8	Дизель	Робот	Серебристый	58088	94053.12	25393
89930	T8S8KLMBR3GS7RN4P	Volkswagen	Touareg	2024	2.0	Гибрид	Вариатор	Синий	21451	49871.55	25412
90787	UW6KK16Y5H9ZP0YC0	BMW	320d	2019	1.8	Электро	Робот	Синий	93687	78171.67	25496
89931	BDNXLEJZW9JCM3V9E	Mercedes-Benz	A-Class	2019	2.9	Электро	Автомат	Белый	26222	63655.96	25437
89932	07U9S3YM0VDNWNRPU	Opel	Model	2023	1.6	Бензин	Механика	Синий	81393	61218.46	25349
89933	AJP7MC2LKP7VY5UAS	Volkswagen	Tiguan	2020	1.9	Дизель	Робот	Зеленый	137586	54526.89	25474
89934	B6CJMUNJ9RWS2NBJ1	Ford	Model	2020	3.9	Гибрид	Вариатор	Красный	121816	45932.74	25317
89935	HLRUFJEZP391KXP1D	Audi	A4	2018	2.7	Электро	Автомат	Коричневый	129097	91630.92	25464
89936	N1U2PZAPF2TYY0MBB	Opel	Model	2021	2.1	Бензин	Автомат	Синий	106467	71455.19	25342
89937	810KV055P9A7SWG46	Ford	Model	2016	3.9	Гибрид	Механика	Красный	74427	43872.52	25282
89938	Y4V58Z2YT90FAYE0Y	BMW	320d	2019	3.9	Электро	Автомат	Серебристый	144947	29961.41	25395
89939	HYE4L7RN6R6JHEH12	Audi	Q5	2016	3.1	Гибрид	Вариатор	Коричневый	103516	91499.60	25353
89940	83ZECAM8ZTBNH779G	Volkswagen	Touareg	2018	1.1	Бензин	Робот	Красный	147837	48290.41	25402
89941	DVSWL1PG7MJPDUR8K	Audi	A6	2022	3.0	Бензин	Вариатор	Черный	85474	44161.20	25399
89942	3YYNSERZFPLZSES4N	Ford	Model	2020	1.6	Дизель	Механика	Зеленый	77328	59309.61	25275
89943	8ARVP0FD16H294ZL6	Porsche	Panamera	2016	2.4	Бензин	Автомат	Синий	47606	62586.66	25287
89944	7AKEHKP4521ATXSKC	Renault	Model	2018	2.0	Электро	Робот	Серебристый	45435	46727.55	25272
89945	KV1W2U0HUTE6C2GK9	Audi	A6	2023	2.2	Гибрид	Робот	Серебристый	136426	30607.38	25449
89946	J2BJVK54A4BGUVD8J	Ford	Model	2020	3.5	Бензин	Автомат	Серебристый	14949	26242.14	25321
89947	P205D5472BPVPFLF4	Opel	Model	2015	1.9	Дизель	Механика	Красный	94228	97935.77	25324
89948	2LFYCYHYL1A6TBPG3	Volkswagen	Touareg	2017	3.7	Электро	Вариатор	Серебристый	30461	24801.92	25508
89949	RPTWM6HR2V02XBH60	Porsche	Boxster	2020	3.0	Электро	Вариатор	Зеленый	73740	49377.78	25372
89950	YN0STREKR9UJRJKM2	Porsche	Boxster	2023	1.5	Дизель	Автомат	Коричневый	42534	87814.54	25295
89951	2MB082T22XEFYDZHS	Porsche	Cayenne	2020	1.5	Электро	Робот	Черный	16792	68919.51	25404
89952	8YJX9LNZ8HK79SB9G	Volkswagen	Tiguan	2017	3.3	Дизель	Вариатор	Серебристый	72168	35724.63	25450
89953	WTCKLXCP4HCH32H7X	Ford	Model	2024	3.0	Бензин	Вариатор	Зеленый	136459	95299.57	25379
89954	GJRZXVLT30F1LYS5L	Porsche	Cayenne	2023	1.4	Электро	Механика	Черный	21469	21047.27	25325
89955	WFNSJ2ZAZRBLY5DMM	Audi	Q5	2023	1.1	Бензин	Робот	Белый	120656	31299.91	25499
89956	D1F6VUA3YH33X9X3B	Volkswagen	Polo	2024	2.5	Электро	Вариатор	Синий	28907	30094.45	25351
89957	5NUW9YXA9TL36XXYG	Opel	Model	2020	1.7	Бензин	Робот	Синий	116087	70886.41	25278
89958	397BTFYA3GXVND986	Ford	Model	2024	2.8	Электро	Робот	Красный	85796	72057.46	25432
89959	MY5CMTAZJ4L35XU4G	Opel	Model	2024	2.2	Гибрид	Вариатор	Белый	72537	37858.71	25495
89960	D4JFYYMDAU2NJZ1CZ	Mercedes-Benz	E-Class	2019	2.1	Бензин	Автомат	Синий	109547	68700.70	25439
89961	78F9DV0XVE21MTHTV	BMW	X3	2022	3.5	Бензин	Робот	Серебристый	101674	82552.17	25335
89962	MX2M0AVCK63LUW4MP	Mercedes-Benz	GLC	2021	1.0	Электро	Вариатор	Черный	4679	27773.26	25484
89963	TE2ZHP6NP2XG52M3G	BMW	X3	2018	2.9	Гибрид	Вариатор	Красный	72623	90069.16	25334
89964	VXL5DYJRASP8KE5CV	Opel	Model	2021	2.3	Бензин	Робот	Серебристый	45022	27953.33	25303
89965	DVLFGL2N0ELPAJ55R	Audi	A4	2023	3.2	Дизель	Робот	Серебристый	124081	34140.07	25488
89966	G1FTALLZPNVBR4RXJ	Opel	Model	2022	1.6	Бензин	Автомат	Синий	133103	90626.02	25296
89967	8YFGKG92K89GCUZVY	Ford	Model	2021	1.2	Гибрид	Автомат	Красный	124171	72038.91	25477
89968	060KNNY3K37HX4MU3	BMW	520d	2017	1.9	Дизель	Робот	Серебристый	106372	74769.05	25378
89969	H3PJNETPMTSZGXRXV	Porsche	Macan	2019	3.7	Дизель	Автомат	Синий	25799	36296.17	25362
89970	GJPS2NUKLM2LUZTG7	Opel	Model	2016	2.3	Гибрид	Робот	Синий	29188	48046.66	25318
89971	9KDEW0UBGK608NX2G	Ford	Model	2020	2.1	Бензин	Вариатор	Черный	82036	37527.73	25463
89972	R3R04D2URCVEELJLL	Porsche	Boxster	2022	1.2	Бензин	Вариатор	Коричневый	82708	96043.46	25395
89973	CM0RX256TBDK7X9E6	BMW	X5	2023	1.7	Бензин	Робот	Зеленый	73706	41444.21	25420
89974	XU8A005NU22DFT50U	Porsche	Boxster	2021	2.4	Бензин	Вариатор	Серый	18778	63658.11	25498
89975	KND19UZTHRCS9PGH8	BMW	320d	2021	4.0	Дизель	Вариатор	Зеленый	44041	17349.22	25444
89976	4U5UBJSNLRA6KB0VE	Porsche	Panamera	2017	3.8	Дизель	Механика	Красный	59457	56515.02	25363
89977	9CSL62YLCGXFX8RCR	Opel	Model	2023	1.7	Гибрид	Вариатор	Коричневый	71328	52679.81	25410
89978	KW99Y4WRK34J5H340	Mercedes-Benz	A-Class	2024	1.6	Бензин	Робот	Черный	29440	61221.94	25376
89979	E7Y6ZMCNRMYS2AC6A	BMW	730d	2016	2.5	Электро	Робот	Синий	106051	16080.39	25283
89980	CY0YJHBK6CGV37162	Volkswagen	Touareg	2022	3.6	Бензин	Механика	Серый	123208	47494.78	25353
89981	M34SE9Y307JFCPJ7A	Mercedes-Benz	S-Class	2020	1.9	Бензин	Вариатор	Белый	119409	29236.51	25297
89982	K2K8BNAH4GLU59WU1	Mercedes-Benz	E-Class	2016	3.0	Дизель	Робот	Серебристый	104136	49206.00	25363
89983	7N7KL6WVDRLVBBY2J	Volkswagen	Passat	2019	3.0	Дизель	Робот	Белый	34272	88655.78	25359
89984	RD66HMKJ6WLBNZRRK	Audi	Q7	2015	3.1	Электро	Робот	Белый	34495	49830.29	25381
89985	RHRHR6940LALKVH1F	Renault	Model	2024	3.6	Дизель	Робот	Коричневый	30704	52012.83	25273
89986	U7RT69F7KMDJ5FVGY	Opel	Model	2016	3.4	Дизель	Робот	Черный	3324	60309.63	25296
89987	Y3RS6YYU0NT3PKMU2	Renault	Model	2024	2.0	Бензин	Робот	Зеленый	54554	53918.43	25316
89988	D42WC8X1PMWFBNDXC	Mercedes-Benz	S-Class	2015	3.8	Бензин	Механика	Черный	15455	98241.39	25318
89989	WWXXJH6YH2GN5HNEB	Ford	Model	2019	2.4	Бензин	Автомат	Белый	6882	89797.62	25310
89990	DASAHGLU7URFULHDK	Opel	Model	2024	3.1	Электро	Вариатор	Серебристый	25899	72494.82	25322
89991	L90VEBSY2H3LUX2LF	Porsche	Boxster	2015	3.7	Бензин	Механика	Коричневый	41774	67023.54	25296
89992	G6ECRWWE48BNM04PG	Volkswagen	Golf	2017	1.5	Электро	Автомат	Зеленый	65584	69421.57	25471
89993	T4WBH0T4LL6X9GXEE	Opel	Model	2019	1.7	Бензин	Робот	Серебристый	81527	15693.69	25467
89994	U1FDP8TKEMXSWDP9E	Ford	Model	2020	2.0	Дизель	Автомат	Серый	92939	66790.48	25424
89995	WJXU5C19HR7PR63E9	Porsche	Macan	2020	1.3	Дизель	Автомат	Серебристый	43102	85914.73	25404
89996	M4VPB95LL8LUWNY8R	BMW	320d	2024	2.2	Дизель	Робот	Синий	136149	71800.74	25449
89997	PCKMSCD72SHAATLRX	Porsche	Boxster	2016	3.8	Электро	Вариатор	Белый	111051	67267.52	25411
89998	3EWSLN0F8X4WUMP7N	Opel	Model	2016	2.1	Гибрид	Вариатор	Белый	128760	40348.98	25349
89999	CEJHKMWWVS4C3N9AS	Porsche	Cayenne	2015	1.8	Дизель	Механика	Зеленый	34376	97971.73	25309
90000	61Y6HXCS07XSZZUS4	Mercedes-Benz	E-Class	2022	2.0	Бензин	Вариатор	Зеленый	100583	20936.49	25311
90001	S4648ANLCNYRH9VL6	Volkswagen	Touareg	2017	1.4	Электро	Механика	Коричневый	75237	42271.96	25410
90002	Z91EAZWH5JLZ01WPY	Audi	Q5	2022	3.8	Дизель	Вариатор	Красный	141019	19956.63	25499
90003	BC6MJPXXZHVEPZFH8	BMW	730d	2019	3.6	Бензин	Робот	Серебристый	66215	36048.32	25478
90004	GS7KRANCMNNNRJ4RF	Renault	Model	2019	1.4	Гибрид	Механика	Серебристый	149963	99404.44	25272
90005	225K0S6S0KGUE4M57	Porsche	911	2022	1.9	Дизель	Автомат	Красный	132361	82643.24	25273
90006	78VH4XBN1JK3R08TW	Renault	Model	2023	1.8	Гибрид	Механика	Зеленый	94494	84034.06	25424
90007	N67BDYMTPKKJ7JCP4	Volkswagen	Polo	2016	3.9	Гибрид	Автомат	Белый	112901	30722.14	25357
90008	1U8WK8U8AXE9DVM4V	Volkswagen	Polo	2023	3.3	Бензин	Автомат	Серый	147659	50916.28	25486
90009	WKX8AAHXV9DH2XP7D	Ford	Model	2023	1.2	Бензин	Вариатор	Черный	45924	87022.88	25381
90010	TUPX9KX85HFJ1YS6X	Mercedes-Benz	GLC	2018	1.6	Электро	Автомат	Черный	92346	17024.64	25360
90011	87ZJDU1HXNBZJTNHZ	Renault	Model	2022	2.6	Бензин	Автомат	Коричневый	110868	69255.06	25288
90012	PDRSVEWXFHJEL61Y0	Mercedes-Benz	GLC	2023	3.7	Электро	Вариатор	Красный	21760	30643.91	25369
90013	VYSZCD1DEVKP43M1M	Ford	Model	2020	2.3	Дизель	Автомат	Зеленый	118219	97123.47	25263
90014	YPAPZKH9RY2PM1J9N	Renault	Model	2023	1.2	Электро	Вариатор	Красный	93929	17984.10	25468
90015	TKGUCJ3XWWA5Z1ZR7	Volkswagen	Touareg	2021	3.6	Бензин	Автомат	Зеленый	98812	89007.84	25414
90016	2X9V20MK3HFFMRR4B	BMW	730d	2021	1.5	Бензин	Автомат	Красный	76553	45750.72	25411
90017	M6MJB6T68CJ0F3Y2W	Opel	Model	2024	3.8	Дизель	Автомат	Коричневый	134356	25732.36	25275
90018	H1SE155WBBPJ2JC2E	BMW	320d	2017	2.5	Гибрид	Автомат	Синий	12477	35389.84	25505
90019	3KLZKZZ6RYUKB20H9	Mercedes-Benz	E-Class	2017	1.4	Бензин	Робот	Серый	23786	69804.37	25425
90020	V8F7KJP24FK2U4Y53	Renault	Model	2022	3.0	Бензин	Автомат	Черный	20867	40433.75	25370
90021	KP0ENAEJDVP0AVFGX	Volkswagen	Touareg	2018	3.4	Бензин	Робот	Белый	147828	67230.43	25385
90022	ZVETWCNZNU42S7V2V	Audi	A4	2018	1.7	Бензин	Вариатор	Зеленый	133402	77667.09	25431
90023	2N4THGLK5L42PU2N6	Opel	Model	2024	3.2	Дизель	Механика	Красный	1246	56750.16	25470
90024	9XWHZU72JXS2NJZJ5	Mercedes-Benz	S-Class	2019	3.4	Бензин	Робот	Зеленый	76843	34375.38	25449
90025	62Z4YYURL8XZJGZJS	Mercedes-Benz	A-Class	2022	3.8	Бензин	Автомат	Серебристый	42555	67727.76	25490
90026	15CXMK8D6UP3311PU	BMW	730d	2017	2.0	Гибрид	Робот	Серебристый	40087	22029.75	25261
90027	E9Y4HBZJ8UED1HUUM	BMW	X3	2022	2.0	Бензин	Автомат	Белый	41727	83384.31	25345
90028	9YKVLSCLL4K20L292	Opel	Model	2020	3.6	Электро	Автомат	Синий	130861	96956.66	25357
90029	JWH5JPFGM3MGKEG4S	Ford	Model	2024	3.4	Электро	Вариатор	Белый	40272	40379.60	25464
90030	MH5L2WNZLW3DZW1G1	BMW	320d	2021	2.1	Дизель	Вариатор	Зеленый	31045	46058.31	25294
90031	XZ38PH9SUV8Y51AWA	BMW	X3	2021	1.0	Бензин	Робот	Синий	100580	77707.56	25400
90032	G0VG7S1TSAYR7M0MA	BMW	320d	2024	1.3	Электро	Робот	Серый	121069	63496.60	25310
90033	7D93ZMDZUCD38E2N9	BMW	520d	2020	2.5	Гибрид	Автомат	Серебристый	80252	38705.40	25339
90034	DRULH386BMDM2GJE6	Renault	Model	2020	2.4	Бензин	Механика	Красный	53772	76396.72	25443
90035	E49CBHXUAXZX20RUW	BMW	730d	2018	1.2	Бензин	Механика	Зеленый	41435	36135.86	25457
90036	K1HVTCFF2S1YVXAAJ	Volkswagen	Passat	2017	1.3	Дизель	Вариатор	Белый	43074	83593.64	25294
90037	YB8RHKU13A80KJUUZ	Mercedes-Benz	GLC	2023	2.6	Гибрид	Механика	Зеленый	88255	60553.50	25322
90038	BTK79ABVPL2PTPUGX	Ford	Model	2016	1.9	Дизель	Механика	Синий	130814	84893.03	25506
90039	7E2X0UYL45GVAKJ11	Renault	Model	2015	2.6	Дизель	Вариатор	Зеленый	110527	79829.94	25445
90040	CR01T68E43SK3NLSL	Volkswagen	Polo	2018	1.7	Дизель	Вариатор	Красный	52436	37446.66	25441
90041	352TWV641J2GXLXVY	BMW	320d	2018	3.7	Дизель	Вариатор	Черный	40605	98687.79	25391
90042	WCV7V9LUWLKAYB7L7	Audi	A3	2020	3.6	Бензин	Механика	Черный	79596	55000.54	25369
90043	CES47B0E0BV8MFZU2	Porsche	Panamera	2020	3.2	Бензин	Робот	Серебристый	45808	68281.68	25309
90044	9JBS1K7JUV4SSU6LR	Opel	Model	2023	1.7	Электро	Робот	Красный	43067	60069.68	25393
90045	ZHKWYEERRH8Y2JV69	Renault	Model	2019	1.6	Дизель	Вариатор	Синий	105939	18004.22	25270
90046	ADBC66Y6CD8V8KLYY	Ford	Model	2024	2.3	Бензин	Вариатор	Зеленый	92240	87440.97	25481
90047	8TUDF9RGYR9757W8U	BMW	520d	2016	3.8	Электро	Вариатор	Серый	63521	87070.20	25476
90048	9WM9MRTFKPLRWF5WC	Ford	Model	2023	1.8	Бензин	Автомат	Черный	128416	91913.04	25350
90049	HFN50TPB6SZUAJ4CB	Volkswagen	Polo	2022	2.5	Электро	Робот	Зеленый	102552	86411.18	25443
90050	NY7V28460CKHKEGYV	Volkswagen	Tiguan	2021	1.3	Гибрид	Автомат	Черный	36937	31272.90	25312
90051	JYXEMLL39WUMLMVPF	Renault	Model	2021	1.6	Дизель	Вариатор	Зеленый	60030	34848.08	25398
90052	GMWKUF5SHD29PEZSP	Renault	Model	2022	3.6	Электро	Автомат	Синий	135463	71151.25	25427
90053	8JZB5W6NFVG8ER8ZN	Volkswagen	Polo	2023	3.3	Электро	Вариатор	Коричневый	130866	66921.81	25463
90054	1FMJXLBB2FRAVV3GF	Volkswagen	Touareg	2018	2.1	Дизель	Вариатор	Коричневый	67931	66505.29	25272
90055	UJP26E0V5VVDKZWDW	Mercedes-Benz	A-Class	2022	1.9	Дизель	Робот	Красный	7342	79580.14	25389
90056	VGT681EDJK31F9NB5	Volkswagen	Golf	2017	4.0	Бензин	Вариатор	Черный	142506	26831.09	25303
90057	T9YW3LSEU96WHFEH9	Porsche	Boxster	2022	1.4	Бензин	Робот	Коричневый	114586	17821.33	25330
90058	XHPSH6X0F0844HYE4	Opel	Model	2022	1.2	Дизель	Вариатор	Красный	16463	70087.55	25437
90059	X4UAYY9TRM0JUZUKB	Porsche	Cayenne	2015	1.4	Электро	Механика	Коричневый	26083	53495.78	25305
90060	9C7KNG3A1V7V110F5	Audi	A4	2021	3.2	Электро	Автомат	Черный	81357	31822.09	25268
90061	0HXUV39H8T0F7Y4PJ	Volkswagen	Passat	2021	3.0	Гибрид	Вариатор	Серебристый	92206	60051.39	25366
90062	59WE451G983TNFZPV	Opel	Model	2020	2.5	Дизель	Робот	Синий	22710	52224.39	25488
90063	N6X6XZVYSPFCB4HXJ	Porsche	Macan	2022	1.7	Дизель	Механика	Черный	44679	23353.02	25445
90064	UGT2SMDJANMPPZMH6	Renault	Model	2021	2.3	Дизель	Вариатор	Белый	24418	89743.72	25364
90065	S9CFP6FRZSKKDZN9J	Opel	Model	2015	3.4	Бензин	Робот	Черный	102554	39671.43	25444
90066	0ZG8402534NUFT67T	BMW	730d	2018	1.3	Гибрид	Вариатор	Серый	110381	34924.78	25368
90067	U0ZA49EDFS08PYXD1	Renault	Model	2019	1.3	Бензин	Вариатор	Синий	66797	81751.12	25319
90068	LYHVUYKVRSDJ0N95W	BMW	730d	2016	1.8	Гибрид	Механика	Красный	127254	18200.76	25289
90069	7YJGCXS1CJ2HJK449	Volkswagen	Passat	2017	1.0	Дизель	Робот	Черный	39464	34614.32	25443
90070	LA2GJ9UUR8K0NAPVN	BMW	X3	2019	3.6	Бензин	Автомат	Синий	52063	66034.48	25495
90071	NBFUM95ME2YGGN93V	Mercedes-Benz	S-Class	2022	1.9	Электро	Вариатор	Серебристый	62725	59150.38	25510
90072	XTWTUNJCKXBUJYD2C	Ford	Model	2019	3.6	Дизель	Робот	Красный	58050	82734.46	25411
90073	8TCG99H3JAZKZJU34	Audi	A6	2020	2.5	Дизель	Вариатор	Синий	48216	21893.42	25272
90074	M1C1U4F39PWGCG3AD	Audi	Q5	2023	3.6	Бензин	Автомат	Коричневый	143754	53616.84	25451
90075	D168DAJWSD7C8ZDDN	Ford	Model	2021	2.7	Гибрид	Механика	Коричневый	102746	51893.99	25339
90076	4FJF9WZR1DYN28Y1S	Mercedes-Benz	S-Class	2024	3.7	Дизель	Робот	Черный	44897	52403.50	25478
90077	SWDYLM186NEZG8WZ2	Porsche	Boxster	2016	1.0	Дизель	Механика	Зеленый	149676	50940.52	25337
90078	5PU3L91SZTH4UY6UF	BMW	730d	2015	2.6	Электро	Робот	Серебристый	47532	76131.64	25405
90079	T4PPC602LHY4HGXRH	BMW	X5	2022	2.0	Дизель	Робот	Серый	141105	59454.13	25467
90080	HLTNGFL1HYXY7YXE6	Volkswagen	Tiguan	2016	2.2	Гибрид	Вариатор	Коричневый	80975	81598.56	25388
90081	2SBUGD2EVAGTECFLH	BMW	X3	2021	3.8	Бензин	Вариатор	Красный	42682	74494.42	25393
90082	8GKJ71FXRLY1EY371	Ford	Model	2017	1.1	Дизель	Робот	Белый	116312	18181.91	25436
90083	UF2XMDMATCHR2JK39	Ford	Model	2018	3.9	Дизель	Робот	Синий	38952	60636.38	25358
90084	PWX28Z4T363FJSHRL	BMW	320d	2024	2.6	Электро	Автомат	Зеленый	67639	56656.48	25436
90085	J8EWXDFWBH3C1H3XY	Volkswagen	Golf	2019	2.6	Дизель	Автомат	Коричневый	95729	85254.96	25308
90086	7RWXCLP25U53WXK8B	Mercedes-Benz	A-Class	2015	3.5	Дизель	Вариатор	Серый	44867	26872.09	25274
90087	30E5SBV7MTAXNVDWG	Opel	Model	2020	3.1	Дизель	Автомат	Серебристый	37569	85537.12	25455
90088	FNU37T99HTW0UVFZ0	Mercedes-Benz	A-Class	2024	3.9	Дизель	Механика	Серебристый	16341	15622.61	25292
90089	M792BEK528K3SWZ0R	Porsche	Boxster	2019	3.9	Электро	Вариатор	Зеленый	107316	60755.71	25266
90090	0WYNJHE7CNUB03S0A	Renault	Model	2022	2.2	Дизель	Механика	Синий	55122	54907.17	25488
90091	ZH4MPAH04XHB2U2KL	Porsche	Macan	2021	1.9	Электро	Вариатор	Серый	19909	56797.85	25317
90092	P838VHA848VBAWECN	Ford	Model	2024	1.0	Гибрид	Робот	Серебристый	122615	83219.20	25409
90093	8M0DJJXEN7LZ7FWWC	Mercedes-Benz	GLC	2020	1.9	Гибрид	Автомат	Серый	15070	87696.42	25368
90094	JN5MADEDY9ALNRP8G	Opel	Model	2016	2.6	Гибрид	Механика	Красный	3413	70024.27	25267
90095	YJJEAVP7UVVRPYZDH	Renault	Model	2019	2.9	Электро	Механика	Черный	63770	81932.76	25496
90096	SHEGKK2D8LJW3MFHR	Renault	Model	2021	2.4	Электро	Автомат	Зеленый	49727	57059.63	25419
90097	BCRS8XYXZV3BCNUD8	Renault	Model	2019	1.1	Электро	Автомат	Белый	80732	18018.83	25339
90098	F79MRB6L6TSTR8KPC	Renault	Model	2024	1.3	Электро	Автомат	Красный	131823	96235.06	25381
90099	VMDFXRP0NRW0H42JS	Renault	Model	2022	1.4	Гибрид	Автомат	Коричневый	10494	73990.66	25404
90100	NXUHCV21Z137ZWCDA	Renault	Model	2016	3.7	Электро	Автомат	Черный	88111	35148.62	25329
90101	5T96B6N3HHGEH1K23	Opel	Model	2023	1.5	Гибрид	Робот	Серебристый	55851	76364.18	25415
90102	6S52JFE9S8JLXTF71	Porsche	Panamera	2021	2.0	Бензин	Робот	Красный	8236	76949.67	25304
90103	RMFBG1THYY8CF7GUV	Volkswagen	Touareg	2016	3.8	Гибрид	Вариатор	Синий	111495	26172.30	25437
90104	JK4J6097UJTC1M26R	Renault	Model	2023	2.6	Дизель	Механика	Красный	145079	25694.12	25380
90105	M79AYA0Z0T25D3TKD	Mercedes-Benz	C-Class	2015	2.1	Дизель	Автомат	Коричневый	146945	19454.41	25487
90106	6Z6PJH86UUE3CMFDA	Renault	Model	2018	2.7	Электро	Механика	Красный	42107	16976.23	25397
90107	S3DTKZKA8MH9BRVYT	BMW	320d	2023	3.2	Электро	Робот	Зеленый	63952	48437.07	25495
90108	WDNF0PT4JGTAUXE4A	Opel	Model	2020	3.7	Электро	Автомат	Коричневый	118970	52538.75	25354
90109	V5BSZ0UWKHRBF9GLU	Audi	A3	2022	3.4	Электро	Механика	Синий	22777	46167.07	25447
90110	2HCGSV095GFDF5LCX	BMW	320d	2017	2.5	Дизель	Механика	Серебристый	4882	34867.35	25366
90111	D55UXXDKMKFV1UH9J	Renault	Model	2024	2.2	Электро	Робот	Черный	33735	32203.72	25306
90112	TUVZC4GLMBL5KN2JL	Mercedes-Benz	GLC	2019	3.8	Бензин	Вариатор	Коричневый	117514	36047.90	25344
90113	MEZVWJ43TGGTFFSTP	Renault	Model	2022	2.5	Дизель	Автомат	Белый	61440	93088.74	25443
90114	AYCKMU07YC9TKGAGM	Mercedes-Benz	GLC	2019	3.5	Гибрид	Робот	Красный	27054	17247.67	25465
90115	S18KF8W0N6433EWCL	Renault	Model	2024	1.2	Дизель	Механика	Коричневый	31610	90520.72	25370
90116	9PWKY0RMM38Y5JKJ4	Porsche	Panamera	2020	1.4	Электро	Механика	Серый	68987	91335.46	25452
90117	LEC25H2R0MD7LJGAG	Porsche	Cayenne	2024	3.5	Гибрид	Робот	Белый	138427	23646.73	25468
90118	HDH5A05UYL3S11VKL	Volkswagen	Polo	2024	1.9	Электро	Автомат	Черный	93375	75263.32	25421
90119	HAU43WPS0PLK0Z87K	Porsche	Macan	2019	2.8	Электро	Вариатор	Белый	147704	33692.33	25337
90120	UVW1VJN516URUJK0A	Volkswagen	Polo	2017	3.8	Бензин	Робот	Серый	30975	17658.65	25267
90121	DERAL3KSNK8JF4CF0	Renault	Model	2017	3.9	Электро	Вариатор	Белый	146749	36917.30	25309
90122	E5PG1NFPKT0SKTB51	Opel	Model	2015	3.2	Бензин	Механика	Синий	18446	85086.57	25305
90123	F04M5WATLV6FUW62L	Mercedes-Benz	GLC	2015	3.4	Дизель	Вариатор	Коричневый	14565	86205.55	25483
90124	N4SB4ZTABL77CV5VC	Porsche	Boxster	2019	3.1	Бензин	Робот	Серый	52963	87641.25	25427
90125	P6JF623H2D78XPC25	Volkswagen	Passat	2019	1.9	Дизель	Вариатор	Серый	13059	97915.18	25483
90126	WX7WNUGZWB762T3PY	BMW	320d	2022	3.5	Электро	Механика	Синий	49793	63811.92	25333
90127	G0KPPHN17PCW7EY4U	Ford	Model	2016	4.0	Дизель	Вариатор	Белый	22062	52511.77	25409
90128	SK4ANBHV4FANRHSLF	Renault	Model	2020	3.3	Дизель	Механика	Коричневый	78792	79380.35	25495
90129	258Z9C075PN7BN3Y5	Renault	Model	2023	3.6	Гибрид	Робот	Зеленый	25425	47759.17	25475
90130	CJ2A6RZDP6KKCFKHD	Opel	Model	2024	1.2	Гибрид	Робот	Серебристый	24336	29212.28	25367
90131	ZCL99GCG2M1Z64TMA	Porsche	911	2024	1.1	Гибрид	Автомат	Серебристый	38773	38360.10	25313
90132	CM9X2ELY45NZ3378L	BMW	320d	2015	3.6	Бензин	Механика	Синий	141762	25481.81	25505
90133	MS3H8AZU08MM2JN88	Ford	Model	2024	2.1	Бензин	Вариатор	Черный	62535	24225.86	25392
90134	3JFE49UZU6PVBUBLU	Porsche	Boxster	2016	2.6	Дизель	Вариатор	Красный	107849	75014.14	25321
90135	5CKNFPR7660ZG4GT1	Renault	Model	2019	1.4	Дизель	Вариатор	Коричневый	149964	49351.25	25388
90136	K4E49PN85CVSL61WC	Porsche	Cayenne	2023	2.4	Дизель	Вариатор	Черный	2903	49376.92	25380
90137	GUKAH0H2G8DWRKDHK	Porsche	Boxster	2021	3.8	Дизель	Механика	Коричневый	21791	84540.03	25469
90138	FKP4J9YXNNZU7KR00	Volkswagen	Polo	2019	3.4	Дизель	Вариатор	Серый	52899	57106.25	25344
90139	VPTP8JK946FVU929V	Renault	Model	2021	1.2	Электро	Вариатор	Синий	24600	26383.52	25447
90140	WGHJC95MJXD4HCPNZ	Opel	Model	2020	3.6	Бензин	Вариатор	Синий	61309	58528.08	25500
90141	87NVBNZBTMH5VT10V	Opel	Model	2020	3.0	Гибрид	Вариатор	Синий	70429	57064.18	25262
90142	R85U80KNXGB865N4Z	BMW	320d	2021	1.2	Дизель	Вариатор	Красный	69610	15432.77	25302
90143	GU3REM5EYGYJAM679	Opel	Model	2016	3.4	Электро	Робот	Красный	4493	92308.57	25342
90144	GH38C5FK78XZ7BGBP	BMW	X5	2024	1.7	Бензин	Автомат	Коричневый	51377	86876.10	25263
90145	9SJ8KJ64H50NHZPY8	Opel	Model	2016	2.5	Бензин	Вариатор	Серый	106964	68574.19	25339
90146	SBVK6W64N1YM95HJK	Ford	Model	2020	2.1	Гибрид	Автомат	Коричневый	92060	23199.02	25286
90147	T26N1J6GZCKUPD9L1	Opel	Model	2021	1.1	Дизель	Автомат	Синий	64165	69687.80	25396
90148	XZHP8KFRPGJVYC2LR	Renault	Model	2024	3.7	Гибрид	Вариатор	Серебристый	42407	64789.82	25509
90149	SZTX95W18VE56BCSF	Renault	Model	2015	2.6	Электро	Механика	Черный	138465	50346.63	25448
90150	CKJ53JVG4XPADZNUG	Renault	Model	2016	3.3	Электро	Вариатор	Коричневый	131983	96772.72	25356
90151	CA3DXUXU8GN3KKED2	Ford	Model	2021	1.8	Дизель	Вариатор	Красный	91110	99705.38	25449
90152	7HED07KSJH55SV71E	Ford	Model	2022	1.2	Гибрид	Механика	Белый	132388	37298.09	25280
90153	U16YN1LFNHARG6JX4	Ford	Model	2024	2.5	Бензин	Автомат	Серебристый	18637	54295.17	25427
90154	U15L75BVWKA4WT7RF	Volkswagen	Passat	2016	1.3	Электро	Автомат	Серый	102774	45854.60	25316
90155	SN8T0E09A33WSGVGH	Opel	Model	2019	2.8	Гибрид	Вариатор	Черный	113504	23946.68	25299
90156	Y9CJFNX54R1039C47	Opel	Model	2024	2.3	Бензин	Робот	Белый	138753	57752.16	25340
90157	1CBRJ5FKW89AH1HZD	Volkswagen	Golf	2017	1.1	Гибрид	Автомат	Синий	14905	86989.00	25423
90158	4SLC0UMU49CDV5AML	BMW	520d	2021	3.5	Бензин	Вариатор	Коричневый	138650	66558.53	25494
90159	YBKSEPEW8VVP5MDPZ	Opel	Model	2017	3.4	Дизель	Механика	Серый	138513	85834.32	25407
90160	1CVYZHVJ2YBLDYAJA	Mercedes-Benz	A-Class	2021	3.7	Гибрид	Вариатор	Красный	106179	47867.82	25332
90161	Z6A28LNFM0PCW30XG	Mercedes-Benz	S-Class	2022	2.5	Электро	Механика	Серебристый	98558	25943.10	25289
90162	G98LMH78530KBY5XM	Audi	Q7	2019	3.7	Гибрид	Вариатор	Синий	123255	24585.00	25367
90163	MXFF18B2UMUK52PZ3	BMW	520d	2023	2.3	Дизель	Автомат	Зеленый	130138	37210.27	25462
90164	J7JD5HPYMGMY9KS1E	Opel	Model	2024	1.4	Гибрид	Робот	Белый	101264	98510.10	25385
90165	P7GJNT3LJ0ZYM4C0D	Opel	Model	2018	1.5	Гибрид	Автомат	Серый	110709	62548.50	25388
90166	AA7EZXPL5ZJ9TPN8X	Ford	Model	2016	1.4	Электро	Механика	Белый	79801	71061.19	25273
90167	1JCLDN6741UDZBC2Z	Ford	Model	2022	3.2	Гибрид	Робот	Зеленый	110953	32609.19	25340
90168	Z23B6BY9KCC6TUXJZ	Ford	Model	2016	2.6	Гибрид	Робот	Синий	22647	73336.89	25287
90169	SHB4WSZM6K724BSGG	Porsche	Panamera	2019	2.5	Гибрид	Робот	Белый	18114	21075.39	25457
90170	VF2FS1GFTPPZLGG6H	Opel	Model	2022	1.1	Гибрид	Робот	Серый	44702	37113.47	25307
90171	EDXMHZ74N4XX9S8NY	BMW	X3	2018	2.2	Бензин	Робот	Черный	145945	51852.57	25312
90172	UCZ435U5N6UWANFSY	Renault	Model	2022	1.0	Электро	Автомат	Черный	59363	48342.06	25355
90173	V4NA1XCZH97LR3DMR	BMW	X3	2024	2.8	Дизель	Робот	Серебристый	77400	22702.19	25425
90174	XGBNYP4J7K0PL8KV1	Opel	Model	2018	2.7	Дизель	Вариатор	Зеленый	88306	53746.91	25351
90175	G553NNGZZM08HMG7Z	Opel	Model	2021	3.7	Гибрид	Механика	Серебристый	103069	84760.48	25320
90176	SRPSMM4GJ0EP5P3NJ	Renault	Model	2015	2.7	Электро	Робот	Зеленый	85358	48593.18	25295
90177	LH0LPKRC4JPEG6VPW	Mercedes-Benz	GLC	2024	1.4	Электро	Вариатор	Серый	137095	37418.43	25389
90178	PBGKBR01T098DKE55	Porsche	Panamera	2022	2.6	Электро	Механика	Синий	92822	74280.58	25414
90179	WJJCJLDE6UKCW1S97	Porsche	Macan	2018	2.7	Дизель	Вариатор	Коричневый	144492	81109.55	25319
90180	112HJ97EVHMVN6SL2	Porsche	911	2019	3.9	Бензин	Вариатор	Черный	26890	83717.68	25322
90181	TZRAZHATUUL5NNJYA	Mercedes-Benz	GLC	2020	3.3	Электро	Автомат	Зеленый	39954	57125.14	25338
90182	G7A8KT4DKCZPP546N	Audi	A3	2015	1.1	Бензин	Вариатор	Белый	60930	96764.86	25473
90183	EWPBV498JN9ZR4TVM	Volkswagen	Touareg	2016	2.7	Гибрид	Робот	Серый	18152	54580.59	25336
90184	VMH96EWN9TY762T0C	Mercedes-Benz	C-Class	2024	2.1	Бензин	Механика	Красный	145515	54430.40	25385
90185	PU25YEGVFD356ZY1U	Renault	Model	2022	2.2	Гибрид	Вариатор	Красный	70700	56301.92	25317
90186	5WYS6AWEB61GNF9BC	Opel	Model	2021	3.8	Дизель	Автомат	Серый	53446	35077.66	25279
90187	DJSZP4HN422NPJ6G6	BMW	X5	2021	1.7	Гибрид	Механика	Серебристый	133493	70093.10	25309
90188	FCHSYK0A4JE29EUT0	Volkswagen	Golf	2022	2.9	Гибрид	Автомат	Синий	128041	70483.97	25491
90189	9S0ZPVXJ9GEM7JKVN	Mercedes-Benz	E-Class	2017	1.9	Электро	Вариатор	Синий	131290	44446.60	25326
90190	PMZSR0381SKS1WV3A	Opel	Model	2019	2.4	Электро	Автомат	Зеленый	25068	21157.91	25285
90191	X3E4Z4UA95FTCAEU9	Ford	Model	2023	1.8	Гибрид	Автомат	Черный	102787	62123.00	25416
90192	TT1TXWBW9AAJAKZ3Y	BMW	520d	2018	1.9	Дизель	Вариатор	Красный	41631	97508.10	25435
90193	5S2HMB4HBU6U8TCT7	Mercedes-Benz	A-Class	2020	4.0	Электро	Механика	Красный	61982	86447.87	25495
90194	HG0Y0M98WYAB23EDL	Mercedes-Benz	C-Class	2024	2.4	Электро	Автомат	Черный	64962	16377.93	25399
90195	F3M1YMLP6KFKKNBZ9	Mercedes-Benz	A-Class	2015	3.2	Дизель	Автомат	Коричневый	149776	82365.52	25331
90196	FTMAR1K48THENAV5R	Audi	A6	2021	3.5	Дизель	Вариатор	Коричневый	118128	91210.32	25400
90197	6MNTF3E2BX83ST3DA	Volkswagen	Golf	2016	3.9	Гибрид	Автомат	Серебристый	134596	43318.35	25401
90198	XKPZGZA9TDLMZAX9J	Porsche	Macan	2022	2.3	Дизель	Автомат	Зеленый	23822	63903.02	25281
90199	KU8WL4HAGTJEHHHEV	Renault	Model	2020	1.6	Гибрид	Автомат	Синий	47700	48792.71	25297
90200	18H6TLFJGTKLTMBVH	Audi	A6	2015	3.9	Бензин	Автомат	Белый	139070	97005.41	25355
90201	YBP18DBY6E64R8Z9H	Opel	Model	2020	2.6	Бензин	Автомат	Коричневый	41497	67697.68	25355
90202	SCARLC8CJ5Y0E3VES	Opel	Model	2021	1.0	Гибрид	Вариатор	Красный	93904	41433.06	25494
90203	NUJPK0BVM02AY6H7W	Opel	Model	2018	1.2	Дизель	Робот	Зеленый	77495	37003.76	25281
90204	XFCR2E5PPJZW8ASMB	Porsche	Panamera	2015	3.1	Электро	Робот	Красный	19814	80189.45	25427
90205	ZRF2BGY96F8A35J64	Renault	Model	2015	3.5	Гибрид	Вариатор	Черный	145868	27253.45	25410
90206	LKE2YY9FERMFRU22Y	Volkswagen	Polo	2019	2.2	Бензин	Механика	Серебристый	84878	55334.74	25313
90207	YS811CS7Y8KFB7CR5	Audi	Q7	2022	3.2	Электро	Робот	Коричневый	90047	29594.49	25271
90208	UMU48BGZS4Z3TKV1J	Renault	Model	2016	1.7	Бензин	Автомат	Зеленый	6328	67728.42	25436
90209	TYD21S5BX685N7APJ	Opel	Model	2019	2.8	Гибрид	Механика	Красный	23487	44210.52	25381
90210	8TC2UREKUC9Y6TM4Y	Volkswagen	Passat	2019	3.0	Гибрид	Автомат	Серый	43774	85065.28	25479
90211	ZE5UYSR71EYV3WWJR	Porsche	Panamera	2023	2.4	Бензин	Вариатор	Белый	85804	52758.39	25351
90212	HR3E1HJC57NSBVWNU	BMW	X5	2017	3.6	Дизель	Робот	Коричневый	28379	30996.93	25276
90213	P6P30E3TC2YTH9LVN	BMW	X3	2020	1.0	Дизель	Автомат	Коричневый	6325	29096.11	25302
90214	SZ87Y7KX5AJPV6PT8	Ford	Model	2017	2.2	Бензин	Вариатор	Черный	137525	71101.70	25376
90215	3CN7KMVA3VZDT9XVJ	Volkswagen	Touareg	2016	3.6	Бензин	Механика	Синий	22389	98413.26	25385
90216	1A17JE09YRVHPTPD0	Opel	Model	2022	1.9	Электро	Вариатор	Коричневый	32055	61708.86	25360
90217	E2JAVWCKJMRDVY6FL	Volkswagen	Tiguan	2022	1.4	Бензин	Автомат	Коричневый	65160	43698.16	25273
90218	D7234DZLZG48HVDJ7	BMW	520d	2019	4.0	Электро	Робот	Зеленый	14007	57972.59	25337
90219	APNJALM3C9L6SW24P	Opel	Model	2021	3.2	Электро	Механика	Коричневый	97815	30985.09	25427
90220	0B4ZAWVYNTJ35WBTR	Audi	A3	2023	2.4	Дизель	Робот	Серебристый	66172	48682.12	25439
90221	6WLZXS99FJZZM9N5U	Porsche	911	2024	1.4	Электро	Робот	Синий	1017	97109.43	25423
90222	2V8T6B41FWPS1TFTJ	Volkswagen	Golf	2021	2.1	Гибрид	Вариатор	Черный	100423	39161.61	25272
90223	E0L4WNUZL6UR1B8C9	Volkswagen	Touareg	2020	3.7	Дизель	Робот	Черный	83766	97164.53	25440
90224	52JHN7H1W6E1NYGK0	BMW	730d	2023	2.4	Дизель	Механика	Синий	44189	72024.28	25337
90225	63EYEAS7E4NUECRNA	Ford	Model	2022	2.0	Гибрид	Вариатор	Черный	8394	33881.72	25496
90226	WHUAB4545D2PDWFWM	Audi	Q7	2021	2.7	Дизель	Робот	Серебристый	74969	18586.11	25365
90227	L2C0JDTYDMJN2GM0E	Ford	Model	2020	2.0	Гибрид	Робот	Белый	20403	27399.92	25264
90228	49DLN8E3HX4VTVW82	Opel	Model	2024	2.8	Электро	Механика	Черный	99630	94407.80	25495
90229	0W83PTF8SRK9EW1GV	Opel	Model	2016	4.0	Гибрид	Автомат	Коричневый	50452	33289.25	25279
90230	WM89PSL7459MC6MNW	Ford	Model	2015	2.4	Электро	Автомат	Белый	102866	37441.55	25467
90231	Z3DF915GFALXKJM0F	Ford	Model	2024	1.2	Гибрид	Механика	Коричневый	138102	67122.64	25492
90232	J9T0X0CY61M6PWTUP	Volkswagen	Golf	2018	3.5	Бензин	Автомат	Зеленый	28767	52709.80	25464
90233	5V5M4TA7F4A1ZV1AU	Porsche	911	2019	2.4	Дизель	Робот	Коричневый	105487	91642.51	25497
90234	RMKX7APEL7CNE2FB6	Porsche	Panamera	2023	2.3	Бензин	Вариатор	Серый	56842	43711.46	25365
90235	55EMU03FZGCW5K6RY	BMW	X5	2021	3.8	Бензин	Механика	Серый	68918	67614.02	25377
90236	6GYBFLSV7P5XTG4X0	BMW	520d	2017	1.1	Бензин	Вариатор	Белый	131011	15135.42	25366
90237	0SNBRJTM3WR6JCA0Y	BMW	730d	2019	2.3	Гибрид	Автомат	Коричневый	46023	76572.47	25504
90238	09EV2E2RPVXBK9MLW	Porsche	Cayenne	2017	3.1	Дизель	Автомат	Синий	57138	21562.92	25461
90239	0U4G0NUXNX9NUMRHC	Renault	Model	2017	2.3	Гибрид	Автомат	Синий	147258	91307.19	25292
90240	YZ5XHYKS47BVXLYPY	Renault	Model	2022	1.8	Дизель	Автомат	Серебристый	1100	53261.54	25376
90241	M9ZCK0RSX0E9RK4DM	Mercedes-Benz	C-Class	2018	2.5	Электро	Механика	Коричневый	80707	63960.33	25369
90242	4JC81JAFVCG401CLN	BMW	320d	2022	1.1	Дизель	Робот	Белый	127274	37210.08	25328
90243	4G0BWFDPBVX70KNGZ	Porsche	911	2023	3.5	Гибрид	Механика	Красный	52705	58834.58	25444
90244	011NHVNLCTHJVFBTS	Porsche	Cayenne	2017	3.5	Дизель	Вариатор	Черный	35851	20270.93	25481
90245	Z27P8SD56GCK4610P	Audi	A6	2015	3.0	Бензин	Автомат	Красный	58767	92994.59	25405
90246	4E90U8S7VZSP3WJT4	Ford	Model	2017	3.2	Дизель	Робот	Черный	64918	38277.94	25450
90247	NTD38Y0SSUDX0UD8D	BMW	X5	2021	1.5	Бензин	Робот	Серебристый	116797	92086.85	25340
90248	1CN6A6TD0DN59G03L	Mercedes-Benz	E-Class	2021	1.9	Гибрид	Автомат	Серый	46983	41440.05	25311
90249	H0LW1YV7UYA2J81VX	Volkswagen	Touareg	2023	3.8	Бензин	Робот	Серебристый	142707	72450.64	25378
90250	N240YR4T0A4A08WV0	Opel	Model	2019	1.7	Гибрид	Робот	Красный	60787	87556.35	25413
90251	XDK30EZM3VR1JS65L	Mercedes-Benz	C-Class	2020	3.3	Гибрид	Механика	Синий	138527	79652.32	25302
90252	ZC3HHXYW8746E2X8C	Volkswagen	Touareg	2023	3.2	Электро	Робот	Зеленый	65517	85224.70	25361
90253	JZ28TPS27U0S8ZLG2	Mercedes-Benz	E-Class	2022	3.1	Электро	Вариатор	Белый	26149	24701.53	25495
90254	2UGZLH1VAL3ADB0F0	Opel	Model	2020	1.4	Гибрид	Механика	Серый	58405	47190.58	25326
90255	59E90Z2W6UYBJ4HC5	Renault	Model	2016	3.2	Электро	Робот	Красный	26352	66630.56	25461
90256	LECZ40CKK2H4EZ0G4	Audi	A4	2015	3.5	Бензин	Механика	Белый	10467	91856.64	25321
90257	U0B421NMS8TBF1ANX	Volkswagen	Passat	2018	2.0	Дизель	Механика	Серебристый	147863	82068.10	25343
90258	UGNHBF9T1NSTWZWH4	Porsche	Macan	2015	3.9	Гибрид	Автомат	Зеленый	30141	21437.69	25434
90259	842NGFD7U23SXXA9N	Audi	Q5	2021	3.4	Бензин	Робот	Белый	96123	55904.55	25401
90260	T4E6V46GWF0KDYU12	Renault	Model	2018	3.2	Дизель	Робот	Черный	43290	75069.99	25299
90261	19XL424SMTBFZRDMX	Ford	Model	2015	3.3	Электро	Автомат	Серебристый	33959	60005.32	25285
90262	X3MNBC9EV1TT6G5W6	Volkswagen	Passat	2022	3.7	Бензин	Механика	Красный	124514	92985.12	25427
90263	NZHTX1SZBDZMPDS8Z	Mercedes-Benz	C-Class	2021	2.9	Гибрид	Механика	Красный	106677	85777.21	25269
90264	UR41W3PNXFXV6TE0B	Opel	Model	2015	1.6	Бензин	Робот	Зеленый	16796	76483.22	25368
90265	ESRCPNA5N5DTJHLBJ	Audi	A6	2020	1.0	Электро	Робот	Серебристый	27432	50312.47	25460
90266	CU7KB6FR1Y6RCPNFR	Porsche	Panamera	2020	2.8	Бензин	Робот	Коричневый	77807	51307.69	25391
90267	FKZ6WXEEZ3EKKPKLD	BMW	X5	2020	2.2	Бензин	Вариатор	Черный	36728	47951.45	25382
90268	ABATMNK4ZURE5MNVW	Ford	Model	2016	2.8	Электро	Вариатор	Серый	50366	39037.25	25310
90269	MF6LFC0XZTMCH2S8L	Mercedes-Benz	C-Class	2024	3.0	Гибрид	Вариатор	Синий	75967	74749.81	25308
90270	HCXDL6JR025ERTBCX	Renault	Model	2017	3.6	Бензин	Механика	Серебристый	91476	69406.02	25411
90271	Y6ZJTPY2R6RE30F4M	BMW	320d	2020	1.5	Электро	Робот	Синий	136580	70263.09	25379
90272	LPP6TWXZ91HGW3NZD	Audi	A3	2019	3.9	Дизель	Автомат	Зеленый	138624	34114.28	25373
90273	T924T0D607B6CL955	Volkswagen	Passat	2020	3.0	Электро	Вариатор	Синий	94756	44856.71	25420
90274	CHFA3CZNDYDVYXECJ	Ford	Model	2018	3.4	Гибрид	Автомат	Серебристый	118766	39384.11	25324
90275	JW9GC5LV5E60LCWV6	Ford	Model	2015	1.6	Бензин	Вариатор	Синий	54949	68343.55	25509
90276	417Z8KCFCKMU2CH4U	Volkswagen	Passat	2022	3.9	Бензин	Робот	Красный	120273	37663.57	25339
90277	C9A9W96N75WZTK0T5	BMW	X3	2023	3.7	Бензин	Робот	Красный	113044	47944.88	25403
90278	1AUXM1KN8UV63YL9R	Ford	Model	2018	2.5	Электро	Вариатор	Серый	110555	60734.59	25468
90279	ZNZS4K0KY0LGCTC97	Renault	Model	2021	1.3	Электро	Робот	Серый	91024	37773.61	25452
90280	VYWA2T4GB4G1PYSWY	Porsche	Cayenne	2017	1.8	Бензин	Робот	Белый	104454	96608.51	25320
90281	V0YRSZSS63LSSL7LU	BMW	X5	2023	2.3	Дизель	Автомат	Красный	126339	55873.09	25266
90282	R980TPWHE8126BW0E	Mercedes-Benz	E-Class	2022	3.9	Бензин	Автомат	Коричневый	44499	94013.31	25460
90283	NB3Z3636Z627D23X2	BMW	X3	2022	3.1	Бензин	Автомат	Серый	105486	43118.76	25488
90284	74TVD2LFBKMBDYB5V	Audi	A4	2022	1.1	Бензин	Вариатор	Серебристый	140890	51363.55	25399
90285	FU53JEUNYWCWJEK7N	Audi	Q5	2016	2.1	Дизель	Робот	Серебристый	54244	74607.16	25476
90286	J9BYJKF6Y0XJFWE1H	Mercedes-Benz	GLC	2018	1.9	Электро	Автомат	Синий	65203	33061.60	25424
90287	7EBSUXGRMVSLLS0P3	Volkswagen	Golf	2018	1.3	Электро	Вариатор	Зеленый	83752	16985.75	25462
90288	VPRMH9Z9ZR1ZV2J0H	Porsche	Cayenne	2019	3.3	Гибрид	Автомат	Белый	7398	23665.76	25445
90289	183RMFHA223Y0HP2E	Renault	Model	2024	1.6	Гибрид	Механика	Зеленый	146634	52094.40	25405
90290	VKYSNX7F8PBPZ499X	Renault	Model	2015	1.1	Гибрид	Робот	Коричневый	94281	34117.54	25478
90291	JG0X1BN4JCWTUV627	Volkswagen	Passat	2019	3.1	Электро	Механика	Серебристый	68519	67779.79	25404
90292	4CRY53FRYG4C2ZCVB	Audi	Q7	2015	3.6	Бензин	Вариатор	Серебристый	44136	74378.58	25489
90293	0H5CLL5RDXNVTH021	Porsche	Boxster	2019	1.7	Дизель	Робот	Красный	46101	82779.17	25399
90294	6LYFCVFA8RGRR9XYG	Ford	Model	2019	1.3	Дизель	Вариатор	Красный	54933	37719.12	25396
90295	L437Z3N13R8KYZMUU	Ford	Model	2022	1.9	Дизель	Автомат	Черный	62777	50565.31	25492
90296	V6AZH5GXWA486TJHY	Volkswagen	Passat	2018	3.9	Гибрид	Вариатор	Серебристый	119803	96571.26	25462
90297	3073FEZT3HB4FCNMM	Porsche	Macan	2018	2.5	Гибрид	Вариатор	Серебристый	126265	61111.79	25510
90298	KAGUJPSFH3JNYK1M5	Audi	Q5	2022	1.8	Электро	Автомат	Серый	22650	68586.78	25318
90299	09VH22ETEJUX55JXH	Porsche	Panamera	2019	3.9	Электро	Вариатор	Серый	109178	49807.22	25408
90300	5YYEX6PWWKVWPUUND	Porsche	911	2022	2.5	Бензин	Вариатор	Серый	142637	22067.81	25407
90301	WVKJU3HZKCDCUYCW1	Volkswagen	Passat	2015	2.8	Электро	Вариатор	Синий	115992	53475.32	25304
90302	P7LW75SWYZHYN36VU	BMW	X3	2022	1.7	Гибрид	Робот	Белый	73962	24673.40	25280
90303	CX8SVAM24MM6XRNL0	Ford	Model	2015	2.1	Электро	Автомат	Черный	123285	81507.71	25277
90304	0FZHAC1SL2LZGYJRJ	Volkswagen	Touareg	2022	3.1	Гибрид	Автомат	Коричневый	65971	22488.77	25504
90305	VL4CZJB4USK03PZUP	Opel	Model	2017	3.3	Электро	Вариатор	Белый	12573	99853.85	25340
90306	WKLV3NYMLGCMPZVKV	Renault	Model	2021	3.2	Гибрид	Робот	Черный	1970	45311.25	25372
90307	D16DDY3WD3NH5JSDC	Opel	Model	2022	2.4	Гибрид	Механика	Белый	125746	73417.20	25364
90308	BKHFKS62URW8LLLC4	Porsche	Macan	2020	3.0	Электро	Механика	Зеленый	9171	50278.60	25399
90309	8RHMXCW7R9N6RA7WK	Opel	Model	2018	2.4	Гибрид	Робот	Черный	40747	80876.33	25315
90310	1WVYLXHV9GNU02R33	Porsche	Boxster	2022	3.6	Дизель	Автомат	Белый	53398	57156.72	25500
90311	5CXRE35FYVN865V9F	Ford	Model	2016	3.4	Бензин	Вариатор	Черный	140345	31832.77	25373
90312	4VN0ZFWRLNBSLH432	Opel	Model	2019	2.0	Электро	Робот	Коричневый	102848	43144.11	25333
90313	ULLX5VXP6BP42UYH6	BMW	320d	2018	3.1	Дизель	Вариатор	Зеленый	22895	17620.94	25499
90314	RDEH09WN31SN1D8JB	Volkswagen	Golf	2020	3.4	Бензин	Автомат	Серебристый	32267	45698.83	25318
90315	61HHLUUT6NPVLWN7P	Ford	Model	2022	1.9	Гибрид	Вариатор	Зеленый	73588	30901.73	25318
90316	A9XLYWSXYGSEUKMWV	Volkswagen	Passat	2022	1.2	Дизель	Вариатор	Серый	123951	26209.86	25341
90317	0K70X10YF6AN8FC62	Opel	Model	2024	1.0	Дизель	Механика	Коричневый	27052	82252.12	25489
90318	S2SE30TJE24GEU79M	Opel	Model	2016	3.7	Гибрид	Вариатор	Синий	132481	44637.21	25359
90319	PXV1ZKE800YJ98EAE	Opel	Model	2016	3.6	Электро	Робот	Серебристый	40851	36841.80	25450
90320	FX5KXWS647FT5VJ4V	Ford	Model	2022	1.9	Дизель	Вариатор	Синий	18254	54806.00	25480
90321	NVHMJ0WELBAPH3U3T	Opel	Model	2023	2.4	Бензин	Робот	Серый	31042	43323.02	25471
90322	575K3MMMSKYPDAX1S	BMW	X5	2016	1.9	Электро	Робот	Красный	138518	91838.80	25287
90323	GLD932YLN2BZY756L	Porsche	Boxster	2020	3.1	Гибрид	Робот	Серый	60559	34758.88	25429
90324	3E92V07JXKSRFSHN4	Volkswagen	Tiguan	2019	3.7	Дизель	Механика	Белый	58607	46356.98	25461
90325	DDA0Z8RYS1MFCLLM3	Renault	Model	2021	2.9	Дизель	Механика	Красный	145389	79433.22	25322
90326	H3ZPSDKE2XE9X7UZF	Mercedes-Benz	E-Class	2024	3.0	Гибрид	Робот	Зеленый	78510	47889.48	25312
90327	3VEW37KS346KHHGGH	Mercedes-Benz	E-Class	2024	1.9	Дизель	Автомат	Серый	35950	79048.28	25274
90328	1JYJWUN5KPA9PXEJF	BMW	X3	2019	1.5	Гибрид	Автомат	Серый	91100	81574.68	25489
90329	WU3XMUADLBYKAY4RP	Renault	Model	2015	3.3	Гибрид	Автомат	Красный	13091	63447.21	25339
90330	14A8X4X2PT5VW67NU	Mercedes-Benz	GLC	2023	3.9	Дизель	Робот	Красный	77483	94370.12	25280
90331	B8WB2D9R0XK1P7ABL	Volkswagen	Tiguan	2022	1.5	Бензин	Механика	Серый	115362	94248.61	25440
90332	8PVSEP0F4G7CFCJ2Z	Porsche	Macan	2019	2.2	Бензин	Механика	Коричневый	65262	54267.28	25323
90333	73JDJNY2PJSP6BPH9	Volkswagen	Polo	2020	3.1	Электро	Робот	Белый	108669	31515.08	25263
90334	CJXAY0SW99FENCSLP	Renault	Model	2020	2.6	Гибрид	Вариатор	Синий	19485	54450.18	25429
90335	KW5RRFY2EX2E1T4TG	Ford	Model	2019	1.4	Гибрид	Механика	Серый	44472	99457.84	25407
90336	KHB93FFKJXSRG7JK5	BMW	X5	2022	3.7	Гибрид	Робот	Коричневый	89074	88052.27	25380
90337	AD599CTHP7YKZNHS8	Audi	A6	2015	1.2	Электро	Автомат	Черный	106407	66654.60	25474
90338	W3UCGSV1L0YHHB169	Ford	Model	2016	2.3	Дизель	Автомат	Красный	71097	33670.97	25424
90339	CC3XXNPJJJUTVHZJZ	Opel	Model	2023	3.0	Бензин	Робот	Черный	80862	55516.93	25437
90340	S6VE576WJ2TH6BW4V	Ford	Model	2018	1.4	Дизель	Робот	Черный	52782	50371.60	25358
90341	T7MYR9W5A5Y0L7BS2	Porsche	Boxster	2016	1.7	Бензин	Автомат	Коричневый	122893	21432.26	25332
90342	FV72VDRR7587ZK4UY	Porsche	Cayenne	2022	2.4	Электро	Вариатор	Серый	19013	23203.91	25418
90343	U60BADDMZMFYSYV6H	Volkswagen	Golf	2016	1.8	Дизель	Механика	Синий	87812	36770.00	25375
90344	D7D7FWT57RFWJ1H81	Opel	Model	2022	2.6	Дизель	Робот	Синий	58548	43419.99	25413
90345	NZAJZ4HDN5PHU5NDG	Mercedes-Benz	A-Class	2023	3.8	Бензин	Механика	Коричневый	103729	19657.09	25406
90346	A2SFHM8LMPKBJJ4N2	Mercedes-Benz	C-Class	2020	2.8	Электро	Автомат	Коричневый	145422	16674.47	25463
90347	GNNU940XMD8WSPAYN	Ford	Model	2022	2.9	Электро	Вариатор	Черный	20813	75077.93	25263
90348	0AFX9VTLM6TJ3PVMN	Renault	Model	2018	2.6	Дизель	Вариатор	Коричневый	138033	51117.09	25501
90349	FNYMCTXVY1FFPZHXA	Porsche	Macan	2018	1.9	Дизель	Вариатор	Белый	118783	24145.46	25312
90350	ZKCNP38K13X0SX19Z	BMW	X5	2024	1.9	Гибрид	Робот	Серебристый	126205	64164.52	25277
90351	R3WD6SNSXR3YNYZCE	Renault	Model	2016	1.3	Электро	Механика	Черный	93032	26743.40	25320
90352	7JKPXUE9REYWFJT23	Opel	Model	2024	1.8	Дизель	Механика	Серебристый	17911	56962.14	25497
90353	2GEA89V0FNNJDVXRT	Opel	Model	2024	2.4	Гибрид	Автомат	Серый	147337	96633.59	25342
90354	30T7HRYA9S87MGTPL	Audi	Q5	2024	1.5	Бензин	Автомат	Синий	98309	40582.61	25262
90355	NK0FZ452K73Z4XD1H	Ford	Model	2020	1.0	Бензин	Механика	Серый	72921	89881.79	25339
90356	CU0ZEJ8R7XME1G4BS	Ford	Model	2015	1.4	Дизель	Автомат	Красный	82519	97644.53	25438
90357	4ZHXEPPG2MWJ9G22U	Audi	A3	2020	1.9	Дизель	Механика	Белый	51291	57935.64	25507
90358	5JW83D3RJDH201PY4	Mercedes-Benz	E-Class	2024	2.5	Гибрид	Робот	Коричневый	101345	16463.85	25475
90359	E06ZDYRS1E66Y110D	Mercedes-Benz	C-Class	2017	1.6	Бензин	Механика	Синий	8363	66147.02	25297
90360	JU1BTXZD2LWUGKK65	Volkswagen	Golf	2020	1.6	Дизель	Робот	Белый	104407	40627.72	25402
90361	ZRBLLP9NCRFJ6Z1G3	Porsche	Panamera	2024	1.7	Гибрид	Робот	Зеленый	105660	85819.92	25400
90362	M7WVYFGM9WG091ZM6	Ford	Model	2019	2.3	Электро	Вариатор	Коричневый	107099	82078.42	25447
90363	VSAT3B3E555KDHD8P	Opel	Model	2024	2.3	Дизель	Робот	Черный	76928	99109.83	25283
90364	M8N6YFT0F12SANC95	Ford	Model	2023	3.4	Гибрид	Автомат	Белый	27033	68661.91	25429
90365	JZ0M5SWDGBA20W2G8	Porsche	Panamera	2018	1.9	Дизель	Вариатор	Белый	3327	65998.81	25468
90366	74DF9P4E30T6T3DFN	Volkswagen	Golf	2020	1.8	Дизель	Робот	Коричневый	83325	85172.05	25429
90367	JVMB1D25T4JR7XM8L	Porsche	Cayenne	2018	1.4	Электро	Автомат	Красный	27932	23520.00	25453
90368	2NXEGAW3YLJ9UP8TY	Opel	Model	2017	2.1	Дизель	Механика	Белый	132308	38635.72	25443
90369	F75LL83G05FUTAFGL	Mercedes-Benz	E-Class	2018	1.2	Гибрид	Вариатор	Зеленый	93980	15477.89	25508
90370	FLD8B8J9J38SAJBDG	Mercedes-Benz	A-Class	2024	2.5	Бензин	Вариатор	Белый	2402	42428.46	25354
90371	Y51EKNC4133XDPVDL	Audi	A4	2021	1.7	Бензин	Робот	Зеленый	70994	66973.04	25301
90372	YRYNVRETK1VFZVHS9	Volkswagen	Touareg	2023	2.6	Бензин	Автомат	Белый	136814	43597.65	25362
90373	YXEAHNLXPSTUJFZ8N	Volkswagen	Tiguan	2024	3.0	Дизель	Автомат	Черный	14313	27737.00	25472
90374	MS9F2LK52WMJPANR4	Volkswagen	Tiguan	2016	3.7	Дизель	Вариатор	Серый	124323	20932.31	25474
90375	N90HSMH3RWG9BY99S	BMW	520d	2017	1.9	Бензин	Робот	Серебристый	95206	87997.46	25400
90376	N2TWRYZZFK9SHP78R	Renault	Model	2022	1.5	Бензин	Робот	Синий	343	43791.93	25366
90377	EJJ33XD23R1U9VNXB	Mercedes-Benz	S-Class	2017	2.4	Электро	Робот	Белый	2916	95773.66	25467
90378	CVK630722M0JUZSNT	Volkswagen	Polo	2016	3.9	Дизель	Автомат	Белый	105696	34974.18	25293
90379	FKBZK5PY63D3V6M46	BMW	X3	2023	3.8	Бензин	Механика	Серый	90668	27510.60	25448
90380	56D2M38UFEA7RLKLY	BMW	X3	2017	1.0	Электро	Робот	Зеленый	94025	60944.38	25441
90381	8LCG5JE3CY0BKL76V	Renault	Model	2015	2.5	Гибрид	Робот	Черный	70775	27375.28	25486
90382	3VPTHMV7YJF3WMBXK	Mercedes-Benz	E-Class	2023	1.6	Бензин	Автомат	Белый	85000	84788.21	25382
90383	TNDJEZXSMSZHS7VEE	Ford	Model	2022	2.4	Гибрид	Механика	Красный	118468	64719.55	25264
90384	H4MD205EN2HXER3NR	Opel	Model	2019	1.2	Электро	Автомат	Коричневый	53077	75435.38	25266
90385	FNTK8RE4CSAKESMAA	Ford	Model	2023	2.1	Электро	Автомат	Черный	9265	80052.11	25472
90386	HUK47RNTFYEC2DXNC	Porsche	Boxster	2017	1.9	Гибрид	Автомат	Черный	53551	98431.94	25302
90387	C54N3G0LE5SEXH61V	BMW	520d	2018	3.0	Электро	Вариатор	Серый	71835	17633.67	25380
90388	747ZXHT6U5PBHFDDZ	Ford	Model	2021	3.4	Электро	Робот	Зеленый	132018	15394.14	25387
90389	E6825K60GACUYX913	Audi	A3	2022	1.2	Электро	Робот	Зеленый	136752	70904.13	25274
90390	GCXJ2LSVCXS1WEZZD	Mercedes-Benz	GLC	2023	2.7	Бензин	Механика	Черный	144770	79541.81	25295
90391	YZAWJ0GD0NR296ABZ	Mercedes-Benz	C-Class	2020	1.6	Дизель	Автомат	Серебристый	116697	89980.40	25418
90392	71J6AWYCV81YNZB1N	Porsche	911	2018	1.8	Гибрид	Механика	Серый	70919	26094.08	25441
90393	ZFUU4R9UEX3L18BGX	Mercedes-Benz	GLC	2022	2.5	Гибрид	Механика	Белый	115628	25129.83	25355
90394	GNF26NP2L4FLPGWUC	BMW	X5	2022	2.2	Дизель	Вариатор	Коричневый	37644	77415.23	25266
90395	FKW5CZTVZBRWE256F	Porsche	Cayenne	2017	1.1	Бензин	Автомат	Синий	70990	22314.00	25297
90396	8BM9E9H9NT4N8UMW7	BMW	520d	2024	1.3	Электро	Робот	Белый	69027	80677.87	25422
90397	ZB2D7AMPPELZC27SM	BMW	320d	2021	3.2	Бензин	Робот	Зеленый	72074	86305.74	25267
90398	F8JK5AMBY58DWB5RT	Mercedes-Benz	GLC	2023	3.9	Бензин	Автомат	Коричневый	106984	81446.14	25464
90399	A4W64B2UC4WKREUGU	Renault	Model	2018	1.6	Гибрид	Робот	Черный	94195	48558.16	25419
90400	FBMLVRUKW2C55Z6WP	Audi	A4	2017	1.4	Бензин	Вариатор	Черный	9337	40542.50	25331
90401	JN497LH3UWBKU1NSU	Mercedes-Benz	E-Class	2021	2.3	Гибрид	Вариатор	Белый	97550	56931.19	25304
90402	4JCDF2PCBNNZACPNF	Opel	Model	2022	3.4	Гибрид	Вариатор	Серый	62014	19253.74	25458
90403	SC263STVSXN6AUEVT	Audi	A6	2022	2.9	Гибрид	Робот	Белый	1013	46337.32	25502
90404	E9WPBEUCVD8ZY7XW6	Porsche	Cayenne	2017	3.3	Бензин	Робот	Коричневый	52281	96561.57	25427
90405	X8N2JZSSATDS5XC3Y	Renault	Model	2019	2.7	Гибрид	Робот	Серый	13843	28791.97	25401
90406	1PMXPLASW55A7J457	Audi	Q5	2020	3.7	Дизель	Вариатор	Белый	99756	17293.86	25262
90407	90KV5SP68CVJ8JZ4N	BMW	X5	2023	1.1	Дизель	Робот	Коричневый	104001	17291.60	25382
90408	2CDYGLNGT6CPFU1PV	Audi	Q7	2023	1.1	Электро	Автомат	Черный	73940	59596.04	25457
90409	LKZA247DUZKPS3U87	Audi	Q7	2015	3.9	Бензин	Вариатор	Синий	99255	43807.18	25380
90410	N54AUGR5EEB9ZLNU5	Porsche	Panamera	2024	2.7	Бензин	Робот	Зеленый	46014	19509.41	25452
90411	4F2TG62ZLSTBP37P9	Audi	Q7	2024	1.8	Дизель	Автомат	Зеленый	39562	92182.01	25305
90412	HPDDF33LE6CE98MG0	BMW	X5	2019	3.1	Бензин	Вариатор	Зеленый	114842	66232.50	25409
90413	L633YXSHPAL6XG9FE	Renault	Model	2019	1.6	Электро	Механика	Красный	131781	33808.03	25464
90414	WJKYEFB7N9E9ZTJ52	Renault	Model	2017	3.1	Дизель	Робот	Зеленый	103510	28948.66	25419
90415	1ESDLAX2ZKN6FG1Z1	BMW	730d	2020	1.8	Гибрид	Робот	Красный	85713	95808.39	25333
90416	7A2B2DNDRLWXEHKX9	Ford	Model	2022	3.3	Электро	Вариатор	Зеленый	148577	90206.82	25296
90417	P63VCWPD00PW5RRBR	Opel	Model	2024	3.9	Бензин	Робот	Серый	31129	25454.74	25325
90418	HXAZLUSW3Z5YEYF8P	Ford	Model	2023	2.4	Гибрид	Робот	Синий	140001	71877.90	25273
90419	6VCGXH8CJSJCDCFF4	Audi	Q7	2017	2.2	Бензин	Автомат	Серебристый	72275	92981.83	25498
90420	1DA1UDXP1N7J5UNKR	BMW	X5	2020	2.8	Дизель	Робот	Коричневый	88880	31198.03	25458
90421	RYE8481GTZZYXK34D	Audi	A3	2020	2.1	Электро	Механика	Белый	97114	88333.08	25276
90422	5YNAHC734WEN0LT50	Audi	Q5	2015	1.6	Бензин	Вариатор	Коричневый	75863	71352.35	25484
90423	GVBNCT27FBG288YN5	Mercedes-Benz	S-Class	2016	3.3	Электро	Робот	Серый	76183	83649.04	25270
90424	8WRU3H0YW0YUFXDTE	Ford	Model	2022	1.7	Гибрид	Автомат	Коричневый	70877	34006.12	25409
90425	5SP5T79D9NU2B7N8T	Mercedes-Benz	S-Class	2024	1.3	Электро	Вариатор	Серый	89034	26664.33	25345
90426	7KKEH7CFY5BX1V0E5	Volkswagen	Polo	2021	1.9	Электро	Автомат	Серебристый	73960	68668.59	25448
90427	FJSPRRDHC6RMMKJD6	Renault	Model	2021	2.5	Электро	Механика	Зеленый	147242	18675.74	25317
90428	6E1SCUNZPMEAJKN18	Opel	Model	2017	1.3	Электро	Вариатор	Красный	4384	59200.84	25423
90429	ADK0XL6MTU6G5UN7A	BMW	730d	2019	1.5	Электро	Автомат	Красный	34289	75768.77	25421
90430	Y2U3WTGLX81WAAKSM	Mercedes-Benz	GLC	2020	2.7	Дизель	Механика	Красный	78693	33632.52	25469
90431	YJ53F4366FE57YPB2	BMW	X3	2017	1.7	Электро	Механика	Серебристый	62813	98538.72	25291
90432	BUNJV3UE8SVXN6YNF	Audi	A6	2019	1.2	Дизель	Механика	Коричневый	108417	19765.76	25337
90433	48MSNH7J4S62JRW92	Audi	Q7	2016	3.0	Дизель	Вариатор	Зеленый	44114	69810.81	25292
90434	ELGY3X8LDDJCSKDG1	Mercedes-Benz	S-Class	2024	3.3	Дизель	Автомат	Белый	61845	75382.17	25359
90435	X3R5B686F3FTDGTXH	Porsche	Panamera	2019	1.7	Электро	Вариатор	Серебристый	34538	69026.35	25296
90436	ADSUBND84HJJ28R99	Renault	Model	2017	3.4	Электро	Вариатор	Серый	105117	44531.13	25340
90437	JBTG8018TYYS5AV2F	Renault	Model	2024	3.8	Электро	Вариатор	Серебристый	48573	93891.73	25428
90438	CYEE4KD4US1V6UN27	Renault	Model	2022	3.3	Гибрид	Вариатор	Красный	69855	29280.94	25433
90439	7BT0V4TZZX42SYHBR	Mercedes-Benz	A-Class	2021	1.7	Гибрид	Механика	Черный	23255	44998.24	25351
90440	3TW1F8K3M50LMFLW2	Porsche	Macan	2020	4.0	Бензин	Механика	Зеленый	133266	86318.61	25343
90441	6KMV7Y2ZJ399J73P8	Renault	Model	2017	2.3	Гибрид	Робот	Зеленый	146	45838.31	25268
90442	AW9ZUCMJR1GR087PB	Porsche	911	2016	3.7	Бензин	Робот	Красный	94777	58409.38	25267
90443	SNFJ7AH8EENGE5UZY	Audi	A6	2018	1.4	Дизель	Автомат	Зеленый	120469	64367.80	25380
90444	MEB6U356CY7HKFZJ0	Volkswagen	Polo	2021	2.1	Бензин	Автомат	Зеленый	41559	77187.51	25403
90445	GDC0A06U0WXL4AHS0	Ford	Model	2020	1.9	Электро	Автомат	Черный	77332	71149.80	25278
90446	BK2BE67CA86DRMWHP	Porsche	911	2019	3.5	Бензин	Робот	Зеленый	44504	99815.03	25412
90447	6A7SEUYAGU4SB4VCV	Audi	Q5	2017	3.5	Электро	Вариатор	Черный	33429	29042.79	25449
90448	K5W6U2CJAKRJ9GPXC	Volkswagen	Golf	2016	2.5	Гибрид	Робот	Белый	136745	27902.41	25380
90449	CCLRBATNRZ6SZ0F62	Renault	Model	2016	2.0	Дизель	Вариатор	Зеленый	71434	21673.83	25362
90450	L67RWRWBAFR53NCKE	BMW	520d	2020	2.2	Дизель	Механика	Зеленый	85608	26364.28	25431
90451	44B8AS3CRZCLS1K5K	Porsche	Macan	2018	1.9	Бензин	Автомат	Коричневый	99601	44777.51	25419
90452	01MUPEGU7K93JDN97	Renault	Model	2020	1.7	Бензин	Вариатор	Белый	63327	29090.17	25476
90453	BKERG4G7RLCLSPP5H	Audi	Q5	2024	3.5	Бензин	Механика	Зеленый	73825	60191.73	25394
90454	JLJPAM0GMD2J3GTRG	Opel	Model	2018	3.1	Дизель	Робот	Белый	81344	57452.81	25372
90455	SWKAAVS6J5XMY8LZA	Porsche	911	2016	2.6	Бензин	Робот	Серый	42345	55293.64	25303
90456	0S7EA5VYYT7L3CUV5	BMW	X5	2015	1.8	Электро	Автомат	Зеленый	143765	34506.64	25365
90457	69NTT6K4SH76K1T8H	Porsche	911	2018	2.7	Бензин	Автомат	Белый	127175	91068.39	25481
90458	UBAYBLY2G1JS531FV	BMW	X3	2018	2.9	Электро	Автомат	Зеленый	55621	59606.69	25447
90459	7Z97B65D55MA5R6VH	Volkswagen	Tiguan	2021	1.7	Дизель	Вариатор	Черный	88277	69273.96	25409
90460	73R1RVVCKAB1RRUAB	Volkswagen	Golf	2023	1.9	Бензин	Механика	Красный	100536	91604.54	25368
90461	9CZ9RT0U22NSG5C8D	Ford	Model	2019	2.5	Электро	Механика	Серебристый	4902	36136.57	25319
90462	311VG7A0PV12BTJ8B	Porsche	Macan	2020	1.5	Дизель	Вариатор	Синий	105182	39539.23	25420
90463	UDF9FL9UBSYGK68EU	Opel	Model	2020	1.3	Гибрид	Вариатор	Белый	104024	81004.94	25307
90464	1CNAUU9UV7A1JHLVN	Volkswagen	Tiguan	2021	3.2	Бензин	Робот	Белый	53470	18264.29	25275
90465	LB08NAR6Z50DF7ZTY	Audi	Q5	2024	1.3	Бензин	Робот	Зеленый	303	18021.28	25502
90466	AUEG5E8KYHYFSZ226	BMW	730d	2019	3.8	Гибрид	Механика	Черный	145124	67223.97	25377
90467	JMWNGASPUAKXL0BAP	Porsche	911	2017	3.2	Дизель	Вариатор	Зеленый	55494	97462.46	25398
90468	UWL3KYBKNR2JZA2YU	Opel	Model	2017	2.6	Электро	Автомат	Зеленый	27888	63373.82	25461
90469	U4DHG2FAD7W6J7LK5	Renault	Model	2017	3.4	Дизель	Автомат	Синий	22053	54282.44	25333
90470	6LAMWCJ3FAVHU49WS	Renault	Model	2021	3.1	Электро	Механика	Серый	72589	57971.95	25462
90471	AMBE6D7C8X8H1YUB8	Volkswagen	Golf	2020	1.1	Гибрид	Робот	Коричневый	133426	28856.67	25280
90472	5CMWC8D526SZFG0B8	Volkswagen	Polo	2024	3.6	Бензин	Автомат	Синий	82067	44420.00	25483
90473	UXXW7EUZDR08W3XBW	Audi	A4	2020	3.9	Дизель	Вариатор	Черный	48371	99103.50	25353
90474	5KJ1B24RZ31PXURWB	Porsche	Macan	2022	1.9	Гибрид	Робот	Серый	124224	89903.67	25375
90475	KVHU12S1X85Y6AGY8	Porsche	Cayenne	2020	3.4	Электро	Автомат	Зеленый	83431	70451.65	25392
90476	X2XUG1EPNACY6Z3V2	Volkswagen	Passat	2015	2.6	Бензин	Робот	Зеленый	72646	42725.86	25485
90477	YS37F671HMGX6UBDW	Renault	Model	2023	3.1	Дизель	Механика	Серебристый	72706	65833.58	25407
90478	2ZV6TY1MGPHC7Y0UX	Opel	Model	2019	2.1	Бензин	Автомат	Коричневый	74698	34053.14	25291
90479	WV3PKLCD3X8HVUSUN	Ford	Model	2021	2.7	Бензин	Робот	Серый	93831	34663.22	25453
90480	W0AYD11V88J4AFFMJ	Renault	Model	2019	2.0	Бензин	Механика	Белый	26492	22842.81	25312
90481	CA35A1F8LPEUEE246	Porsche	Boxster	2023	1.1	Гибрид	Робот	Синий	135719	89860.05	25332
90482	F8R220Y4E7AP1ZH1F	Volkswagen	Tiguan	2017	2.8	Бензин	Робот	Белый	71836	52529.39	25368
90483	RN6ZY05PRK9W9KPNF	Audi	A4	2015	4.0	Дизель	Механика	Черный	22139	23736.77	25345
90484	D4RCM7EWEF5123XHH	Ford	Model	2023	3.0	Гибрид	Робот	Серебристый	76738	31900.47	25261
90485	AXCJN5XG89LKAG5LX	Volkswagen	Golf	2021	2.6	Гибрид	Вариатор	Черный	80903	35363.55	25417
90486	U4UZBM9RYSPWSY0E9	Mercedes-Benz	A-Class	2023	1.5	Дизель	Автомат	Черный	45241	31733.21	25319
90487	DA5U66SMZBF2T59AB	Audi	A3	2024	2.1	Гибрид	Робот	Красный	85315	56863.33	25367
90488	CWKW6A9M7ZYED8XXY	Mercedes-Benz	A-Class	2023	1.2	Гибрид	Автомат	Серый	42582	70836.49	25317
90489	31K7TY4ZST0KT87AA	Mercedes-Benz	S-Class	2020	3.0	Бензин	Механика	Черный	83533	53366.20	25387
90490	BC8TM2XR5R6CDVL5C	Renault	Model	2023	3.3	Гибрид	Автомат	Белый	37707	79924.17	25488
90491	5DJPGGFXP1W5C2JD5	Ford	Model	2019	2.9	Дизель	Механика	Коричневый	107164	87399.86	25436
90492	R4VDCHZK0KEHY8JFF	Mercedes-Benz	GLC	2023	1.3	Электро	Вариатор	Серебристый	7707	95906.90	25444
90493	TCHH3EEY7UN39ZAUM	Volkswagen	Golf	2017	3.2	Бензин	Вариатор	Серебристый	77707	35893.96	25416
90494	PG1VWE38ZDWU18ST9	Mercedes-Benz	A-Class	2022	1.4	Гибрид	Робот	Красный	136366	73309.30	25361
90495	6WJKRSNDN6B5F4PK6	Renault	Model	2024	3.3	Гибрид	Робот	Коричневый	63914	84375.13	25437
90496	K10X7ET2FESK9EUWX	Ford	Model	2023	1.1	Гибрид	Робот	Серый	90535	96166.72	25466
90497	09YU6AY82KBPSNEPB	Audi	A6	2016	2.2	Бензин	Вариатор	Красный	137258	55053.31	25277
90498	1ZE4HR86MVDPZXN21	Renault	Model	2019	3.6	Гибрид	Робот	Белый	79470	26806.25	25452
90499	AABB1A0K02KYD075S	Volkswagen	Polo	2020	3.2	Дизель	Механика	Серебристый	37164	19862.05	25452
90500	ZVC8FHKDPWSNKNVF0	Opel	Model	2018	3.4	Бензин	Автомат	Серебристый	88403	74881.50	25491
90501	55M5P4ECL90V12A14	Opel	Model	2024	2.5	Дизель	Механика	Серебристый	104631	95695.65	25477
90502	8UB1EX6FR55GLTME4	Porsche	Boxster	2018	2.7	Дизель	Робот	Серебристый	20769	82881.44	25378
90503	4W3J1YG6XW9CLK2B2	Audi	Q5	2021	2.5	Дизель	Автомат	Серый	70008	27788.82	25484
90504	W5NG4GMCR2XXRSGCJ	Renault	Model	2021	2.9	Электро	Механика	Коричневый	42085	87288.50	25464
90505	ND98G76PK5CVUFJ5L	Audi	Q5	2015	3.3	Дизель	Робот	Красный	121074	83601.32	25312
90506	H12NP4RX5669DUE25	Opel	Model	2019	1.8	Электро	Механика	Коричневый	58012	71689.43	25468
90507	169A9L81ZA28CRPHY	Renault	Model	2023	1.2	Гибрид	Вариатор	Белый	19104	42392.51	25389
90508	H950G5CW7VPH8UVS2	Audi	Q7	2023	2.1	Дизель	Механика	Коричневый	42629	93748.63	25416
90509	XG1F2GST71RAZD77L	Mercedes-Benz	GLC	2017	2.3	Гибрид	Механика	Красный	73546	29936.87	25446
90510	H50J3DXERUPA3BBXR	Ford	Model	2022	2.3	Гибрид	Механика	Черный	78131	87841.88	25305
90511	9STF7SFF4RYY6J80E	Mercedes-Benz	C-Class	2016	3.4	Дизель	Автомат	Черный	146041	25445.53	25457
90512	GDRYMZAA9CZWE826F	Opel	Model	2017	3.6	Бензин	Механика	Зеленый	145083	61545.95	25434
90513	T4YZ159HSYPUJBU9G	Porsche	911	2017	3.1	Дизель	Механика	Черный	55034	71937.60	25483
90514	4F3Z49262FEUXD0BL	Mercedes-Benz	E-Class	2018	1.0	Бензин	Механика	Синий	149321	66239.72	25261
90515	5ZK36FZGSRHKX0EBU	Audi	A6	2023	3.4	Гибрид	Робот	Серебристый	106693	44211.14	25436
90516	DEPRWRCMDYS84CXK8	Audi	Q7	2024	1.6	Гибрид	Автомат	Черный	78618	97519.79	25447
90517	SUNJYE9R4W394H9GD	Mercedes-Benz	E-Class	2019	2.8	Электро	Механика	Зеленый	50871	63497.88	25441
90518	YXUSUK2MZD6AHSCJ1	Audi	A6	2023	1.4	Бензин	Автомат	Белый	45119	46674.59	25326
90519	M1PZR7AZH5D6D1EUL	Opel	Model	2018	1.9	Гибрид	Механика	Синий	45074	39654.43	25422
90520	1FDP2MMXKPW6E4JCP	Porsche	911	2015	3.4	Бензин	Вариатор	Серый	66397	67656.07	25490
90521	PGDG747R8CGK32ZXD	Volkswagen	Tiguan	2019	1.6	Дизель	Вариатор	Красный	68113	27539.93	25459
90522	TXF8PTUWEDWMMGA3T	Mercedes-Benz	E-Class	2024	3.7	Гибрид	Вариатор	Серебристый	16538	93886.73	25438
90523	184BGV1MDBR3ZEFXD	Renault	Model	2016	3.4	Гибрид	Вариатор	Зеленый	27452	29942.47	25284
90524	BT7PUWCE8SDX9E5YN	Renault	Model	2016	1.8	Дизель	Механика	Синий	52951	51670.96	25432
90525	0E4P9U8FAFNU4RM76	Volkswagen	Passat	2015	2.8	Дизель	Вариатор	Коричневый	67709	70471.00	25271
90526	PB781D3MCXKCM1RV9	Porsche	Panamera	2022	3.3	Гибрид	Автомат	Черный	46778	73487.62	25491
90527	MV6WN9J6CJ4MGZHXN	Mercedes-Benz	C-Class	2022	3.6	Дизель	Вариатор	Серый	107230	26475.77	25386
90528	AHKX9ZY6BFHDUF3J1	Mercedes-Benz	E-Class	2019	3.8	Электро	Вариатор	Серый	61744	62916.98	25375
90529	GHUH7RXUYVR90L6Z9	Opel	Model	2018	2.5	Дизель	Робот	Белый	60955	32140.38	25397
90530	5ZMK2Y9YD6APWGBHM	BMW	520d	2022	3.4	Дизель	Вариатор	Коричневый	56423	31603.43	25449
90531	Y41G31K6TKNW75380	Opel	Model	2018	3.7	Гибрид	Механика	Зеленый	17824	97497.59	25361
90532	GVF9DJNYZLT31RS47	Renault	Model	2018	2.7	Гибрид	Робот	Зеленый	132083	87699.23	25300
90533	TKM0EX6L9SBN7A90F	Renault	Model	2019	2.4	Дизель	Механика	Красный	101852	79219.70	25397
90534	VVTE24RE9JNZT6J9V	Mercedes-Benz	A-Class	2022	1.1	Электро	Механика	Красный	8936	36690.21	25375
90535	MEFC7LP0AU4PD309X	Mercedes-Benz	E-Class	2018	1.7	Электро	Механика	Серебристый	19856	58774.47	25437
90536	APP3T6Z6CZN479VEG	Opel	Model	2023	2.6	Бензин	Механика	Белый	107391	39374.48	25481
90537	UBWLWHWRVUTS1KJ7B	BMW	320d	2018	3.8	Гибрид	Автомат	Серый	142835	37275.14	25332
90538	MK2P4BY4NPSCTWY3S	Audi	Q7	2019	2.0	Дизель	Автомат	Красный	86945	41266.91	25490
90539	PASTA73A5YLFV59RH	Opel	Model	2017	3.8	Гибрид	Механика	Коричневый	25816	85787.45	25370
90540	H48VJ019JJJ43VBAD	Porsche	Panamera	2018	2.6	Электро	Вариатор	Серый	149059	92756.51	25425
90541	T4VPSZAE7SLNVA2EJ	Mercedes-Benz	C-Class	2017	3.5	Гибрид	Вариатор	Белый	101498	72476.54	25275
90542	V6L8MKZGH20JJC2UX	Audi	Q7	2017	2.3	Бензин	Вариатор	Зеленый	6755	60795.53	25268
90543	PRET0PW1HSTE4A708	Mercedes-Benz	GLC	2015	1.2	Электро	Вариатор	Красный	113358	75939.16	25375
90544	V17770EBBKAXPHFGZ	Opel	Model	2016	3.8	Бензин	Вариатор	Синий	44044	57092.79	25484
90545	7XX8EX428J303ZRLY	Renault	Model	2021	1.9	Дизель	Автомат	Белый	40087	83514.54	25291
90546	GNKV901ZLT7S3MNWL	Volkswagen	Golf	2020	2.7	Гибрид	Механика	Серебристый	95897	67808.22	25279
90547	Y1MXFT1LNND0R98F5	BMW	520d	2023	3.4	Бензин	Вариатор	Белый	133134	16495.00	25341
90548	AWMZRJ4CV8UAL388E	Opel	Model	2015	1.9	Дизель	Автомат	Черный	127695	28423.24	25498
90549	1KAY7YC07KFBE8MAU	Porsche	Panamera	2022	2.0	Дизель	Робот	Белый	85515	68105.43	25349
90550	9TY4UXZ3D3Z80M2SU	Opel	Model	2019	2.6	Бензин	Автомат	Черный	125915	93778.38	25466
90551	MJSFHLSNK7VVPFYBH	Ford	Model	2018	3.9	Дизель	Механика	Коричневый	45377	95815.27	25313
90552	FXSCTX2MGVE7MYMF1	Ford	Model	2019	2.5	Дизель	Автомат	Серый	36799	46169.36	25299
90553	0PTTKHRTFLNH8X337	Volkswagen	Golf	2019	1.8	Электро	Вариатор	Белый	143551	47098.26	25464
90554	BXWRL9A79UWMVC2NN	Renault	Model	2016	3.4	Бензин	Робот	Зеленый	2703	17788.43	25264
90555	MBYPB64PVHY95EYF9	Renault	Model	2023	1.6	Гибрид	Вариатор	Серый	161	19985.52	25284
90556	NJG3LYEK5JJC4M1ZZ	Opel	Model	2023	1.5	Электро	Механика	Белый	2278	21770.48	25459
90557	FB492TV6K8M5F9RK1	Ford	Model	2015	3.1	Электро	Автомат	Зеленый	3801	59253.28	25381
90558	HMAK70RZWACPGYFAU	Opel	Model	2018	2.8	Бензин	Механика	Красный	118736	28294.35	25476
90559	MS7M7LBE0H5LXKPK0	Mercedes-Benz	C-Class	2024	2.6	Гибрид	Робот	Серебристый	85647	16841.89	25448
90560	TFBD16E274Z6MJ7CP	Renault	Model	2018	1.6	Дизель	Робот	Синий	46005	78938.51	25351
90561	2LERM6AD811X2ZYF7	Mercedes-Benz	S-Class	2018	3.1	Электро	Робот	Серебристый	119631	18143.63	25489
90562	D9DVS56S5VMBJXA6B	Renault	Model	2023	2.4	Гибрид	Робот	Серебристый	88190	73532.65	25398
90563	V3BG0KWJNVHWGWYZ8	BMW	730d	2017	1.6	Дизель	Автомат	Синий	75513	32372.74	25351
90564	B3M8NHHSKJZCGDHL6	Porsche	Cayenne	2016	2.6	Бензин	Автомат	Синий	23155	31414.37	25429
90565	3JYFW27AX8Y54TWAA	Renault	Model	2016	3.7	Гибрид	Автомат	Серебристый	135736	93181.25	25483
90566	GEEY671063Z4CKJHP	Audi	A6	2020	3.2	Гибрид	Автомат	Серебристый	18596	19905.96	25366
90567	D5VTF1REME40MY7TN	Renault	Model	2019	2.8	Бензин	Автомат	Черный	108018	60084.51	25262
90568	8C4WSUC51MZ2J1FYZ	Opel	Model	2020	2.6	Бензин	Вариатор	Синий	111367	86292.93	25477
90569	K184W3ZX0XABEJVJ6	Mercedes-Benz	S-Class	2017	1.8	Бензин	Робот	Белый	19686	35630.45	25414
90570	705MGMBX42EKXDS1J	Ford	Model	2017	2.7	Электро	Механика	Серый	149535	93899.11	25360
90571	A49ZGYB6JGCFEUFJR	Opel	Model	2017	3.5	Гибрид	Автомат	Серебристый	89309	27929.14	25344
90572	46A10HF5ZWJAHVFND	Ford	Model	2018	3.4	Бензин	Механика	Серебристый	45289	83011.39	25375
90573	3KULPNP02KSN5C2C6	Renault	Model	2022	3.9	Дизель	Робот	Белый	20917	20425.38	25509
90574	F11CLAM09511F2KZV	Renault	Model	2017	2.1	Бензин	Механика	Красный	133822	93820.98	25462
90575	X4UA715TMBZ6PJU6S	Porsche	Cayenne	2022	1.3	Гибрид	Робот	Белый	101287	61454.05	25385
90576	7CSXKXY6B7Y69TY07	Mercedes-Benz	GLC	2022	1.6	Электро	Вариатор	Зеленый	46384	63784.11	25292
90577	VK1GGMT7LFG1YWU6U	Mercedes-Benz	GLC	2017	3.8	Бензин	Робот	Коричневый	95173	82180.33	25422
90578	VYFR6NBHL4E9CM4EH	BMW	X5	2016	2.5	Дизель	Вариатор	Коричневый	133923	43926.44	25408
90579	2DLHG5HDPKRZXCTX6	BMW	320d	2015	1.9	Бензин	Робот	Серый	74116	15409.86	25369
90580	Y54JJ60DD4NV1MN3U	Renault	Model	2016	1.6	Бензин	Механика	Серый	89548	83340.45	25425
90581	FATYCS1SNBZ6BFTYC	Audi	A3	2015	3.6	Дизель	Автомат	Белый	13422	18715.76	25504
90582	F2D852X8GPVDJRBKG	Audi	Q7	2019	2.0	Электро	Автомат	Красный	125599	58052.82	25349
90583	BY0N6NRVFFRRG68DF	Renault	Model	2017	1.5	Бензин	Вариатор	Красный	73631	17010.84	25295
90584	7K1YZJA415N85WUZ0	Porsche	911	2020	2.7	Гибрид	Механика	Белый	62620	33795.06	25328
90585	3HUSV9BBL7AAYJ587	Opel	Model	2016	2.4	Дизель	Вариатор	Серый	136075	17332.91	25339
90586	MARUR4RWUPP1Y59NG	Volkswagen	Passat	2015	4.0	Бензин	Вариатор	Зеленый	40639	21811.72	25469
90587	XHHWC50EJL23SVMX9	Mercedes-Benz	E-Class	2023	2.5	Бензин	Автомат	Коричневый	74107	41939.94	25421
90588	CFZ7JPUGLA3MZTNZS	Volkswagen	Passat	2019	4.0	Электро	Автомат	Черный	48995	28720.19	25494
90589	1W3W003JAZALFGTAP	Opel	Model	2021	2.5	Дизель	Автомат	Синий	137235	78876.70	25428
90590	F09SE15NTG3F0KYYP	Opel	Model	2018	3.4	Гибрид	Механика	Белый	107240	83280.21	25264
90591	48M57N81CHFPWN6JT	Mercedes-Benz	A-Class	2020	2.9	Дизель	Вариатор	Серый	97356	19651.86	25340
90592	TBCMHFUXH9T5E1BEM	BMW	730d	2017	3.2	Электро	Автомат	Белый	4689	93357.82	25489
90593	GCGVYBHR712XALSFH	Audi	Q5	2022	3.5	Бензин	Робот	Красный	57507	15574.80	25286
90594	VWK99NG8UKJ5YNSEZ	Ford	Model	2022	1.7	Дизель	Механика	Серый	67880	68650.60	25396
90595	DYE9UJ6YTEGLZ227Y	Porsche	Cayenne	2015	1.2	Бензин	Вариатор	Серый	81386	83573.12	25351
90596	A5YJ2X0YH8A8PFMRG	Volkswagen	Polo	2016	3.8	Бензин	Вариатор	Серый	89701	63925.37	25356
90597	RN5CFHFPK3X3F7TUR	BMW	X5	2020	1.2	Гибрид	Механика	Серебристый	49682	99733.45	25453
90598	WAZBTAMMCBHATWRZ8	Volkswagen	Tiguan	2015	2.9	Гибрид	Автомат	Белый	101951	90459.51	25433
90599	46VZ2FN5PR0ZG919M	Ford	Model	2015	2.1	Дизель	Автомат	Коричневый	9331	78998.31	25287
90600	YW2ZWFJDZ8T3JSNXL	Audi	Q7	2015	1.2	Бензин	Механика	Черный	26391	31565.96	25429
90601	43HFCG2S958FHS9UT	BMW	730d	2017	1.0	Бензин	Вариатор	Серый	71040	41739.16	25354
90602	YAS6T6BCCFZS06KDY	Renault	Model	2018	2.7	Электро	Механика	Черный	24507	36742.19	25269
90603	W99L3Y9FMND1XMMTT	Renault	Model	2024	3.8	Гибрид	Механика	Черный	18884	33206.71	25440
90604	WSLE184626GJN9N00	BMW	520d	2017	3.0	Электро	Робот	Белый	120815	58090.99	25395
90605	VH5L5SR1EZ39H64HF	Volkswagen	Polo	2024	1.9	Гибрид	Автомат	Белый	5462	60625.01	25302
90606	DJ98GDHTYWLRBH3B2	Volkswagen	Golf	2022	2.3	Бензин	Автомат	Серебристый	126429	72379.65	25315
90607	9GGPWTMWUHSXBC8CF	Porsche	Cayenne	2020	2.3	Электро	Механика	Синий	48310	25101.32	25476
90608	F3ARG10960VPNJ1FC	BMW	X3	2020	3.3	Дизель	Робот	Зеленый	102544	53106.24	25345
90609	XSB24JGK9V50UP2BN	Volkswagen	Touareg	2019	2.3	Гибрид	Робот	Синий	92270	32187.91	25455
90610	HJLZKZ017GS7MZ1DM	BMW	520d	2020	1.8	Дизель	Автомат	Серый	75554	23403.28	25416
90611	UKKLNZZ77PKCVLZ24	Ford	Model	2023	3.7	Дизель	Вариатор	Серый	60321	33431.77	25466
90612	H7UP4Z4P201WP4BE4	Renault	Model	2024	3.4	Электро	Робот	Красный	4636	24091.16	25318
90613	EM9BNZK1PRF98M8TG	Porsche	Macan	2016	1.6	Электро	Автомат	Красный	88006	92622.99	25294
90614	99D3P1WMG6NTPKBCZ	Volkswagen	Passat	2021	1.8	Бензин	Автомат	Черный	3857	83695.92	25497
90615	KXRXPPV5J4BU0CNGF	BMW	520d	2020	1.2	Гибрид	Робот	Черный	69911	35642.04	25282
90616	UW1AUTGG0S5D4BKSW	Ford	Model	2023	3.9	Дизель	Вариатор	Зеленый	40087	68421.88	25310
90617	JAZ3HLUFYXAWVXTPN	Audi	Q7	2020	3.0	Электро	Автомат	Зеленый	80007	37328.34	25417
90618	40T9GV9ZWUSNU1TUL	Ford	Model	2017	4.0	Бензин	Механика	Белый	82159	80494.86	25282
90619	SHUMDHDE4KKFA8925	Ford	Model	2018	1.1	Дизель	Механика	Зеленый	113264	33118.79	25458
90620	TA92H4AR5V8D7X683	BMW	730d	2022	3.5	Электро	Вариатор	Коричневый	29984	32327.42	25384
90621	B0VXYDA0U8RLBWSN4	Opel	Model	2022	1.3	Электро	Автомат	Серый	127055	58150.64	25427
90622	TTP1J9KBET98S4MEF	Mercedes-Benz	C-Class	2022	2.0	Электро	Автомат	Коричневый	140898	57062.60	25473
90623	JW6UZBDUNZR9HX9CB	Opel	Model	2015	3.6	Гибрид	Вариатор	Серый	21591	54332.90	25466
90624	1MKLEG397W2R9MY5E	Opel	Model	2021	3.9	Дизель	Робот	Синий	7411	89761.24	25392
90625	ENUAW88PGH342GP8B	BMW	X3	2023	2.7	Гибрид	Автомат	Коричневый	108811	45545.36	25486
90626	31UXW2K5LJVT8YSAC	Mercedes-Benz	C-Class	2015	1.8	Бензин	Автомат	Серебристый	80921	84457.88	25377
90627	KYNX8P757PY47MHH0	Volkswagen	Touareg	2023	2.8	Дизель	Вариатор	Серебристый	8465	82218.32	25491
90628	1FLN7WEGE6J88APCM	Audi	A6	2024	1.3	Дизель	Механика	Коричневый	82628	88526.56	25473
90629	GNL5W391XBWWHY5N5	Porsche	Panamera	2020	2.3	Гибрид	Механика	Коричневый	27559	20086.19	25503
90630	3H0EN52NP60WV3JXY	Renault	Model	2015	3.3	Дизель	Механика	Белый	62149	46917.40	25456
90631	Y3KBKC3GSH1TS335W	Volkswagen	Tiguan	2016	3.7	Бензин	Вариатор	Красный	92169	38013.05	25483
90632	CHHW4ZCGL3W82WLF9	Porsche	911	2015	1.2	Гибрид	Автомат	Серый	41408	55991.85	25298
90633	DK93JVDMJJK4Z09XE	Volkswagen	Tiguan	2016	3.8	Дизель	Автомат	Серый	126850	90366.33	25451
90634	CPBZAERXLGYPY7HRC	Audi	Q5	2018	1.2	Дизель	Автомат	Белый	147362	38372.15	25419
90635	6VC5G2EK1B8NPGSBT	Volkswagen	Touareg	2021	3.1	Электро	Механика	Коричневый	50338	56387.85	25379
90636	W5NUYT768S8JWGU25	Ford	Model	2018	3.0	Электро	Вариатор	Черный	123174	24781.12	25508
90637	EL0CCB3G611AKG46C	BMW	X5	2017	1.2	Дизель	Вариатор	Красный	93739	17382.19	25282
90638	CX1FWCP6B45WHE9HA	BMW	520d	2015	2.7	Дизель	Автомат	Белый	37063	44953.81	25310
90639	L7YFL5XKZ0TSZ1WCP	BMW	X3	2021	2.3	Бензин	Робот	Черный	27858	34717.29	25390
90640	PXJJVWZ0PT8EDPJLT	Ford	Model	2017	1.3	Бензин	Механика	Красный	142360	55219.39	25426
90641	5DSEAYXV0GTG63S5D	Opel	Model	2016	1.2	Дизель	Робот	Белый	127967	66750.49	25456
90642	6ARLVNZ2ZHARF33K2	Renault	Model	2024	3.7	Дизель	Робот	Синий	129367	38997.84	25312
90643	97D1EEDZDWTH3NPPR	BMW	730d	2023	3.7	Дизель	Автомат	Серебристый	6425	75353.39	25292
90644	GEAGTXV5VHA6Y63FE	Mercedes-Benz	S-Class	2017	3.1	Дизель	Вариатор	Черный	115904	15058.76	25387
90645	AB13Z22CY3ZDWU6PM	BMW	730d	2017	2.7	Бензин	Вариатор	Серебристый	4824	44112.62	25473
90646	JWFLA78GY49US2CBG	Renault	Model	2020	1.8	Дизель	Механика	Серый	144076	68685.48	25312
90647	HZASK26UARB41RP3V	Audi	A3	2020	1.1	Гибрид	Вариатор	Серый	141814	96494.67	25331
90648	1H2LPSLK6J6BMC482	Audi	A4	2023	1.1	Электро	Робот	Серебристый	127575	74152.65	25299
90649	9YM1EKNBRPYSF2MKU	Ford	Model	2023	3.5	Электро	Робот	Зеленый	116464	52574.48	25482
90650	Y5YKJWPDARJTKK1V3	BMW	520d	2022	2.2	Бензин	Автомат	Коричневый	95543	43103.02	25396
90651	2772NECHCRSZ6CGZH	Porsche	Panamera	2020	2.7	Дизель	Автомат	Серый	17969	18049.94	25291
90652	N7W1091TX7F0UD3VR	Mercedes-Benz	GLC	2024	1.4	Электро	Робот	Красный	140552	16673.17	25268
90653	BF1G3KNLML3HX93D7	Opel	Model	2022	2.3	Дизель	Автомат	Синий	1716	47702.05	25336
90654	8KXU9TTPM3XT0WP8E	Ford	Model	2016	2.7	Бензин	Механика	Синий	148197	41327.31	25401
90655	994WF6FE3WK60S94K	Ford	Model	2020	1.3	Бензин	Робот	Белый	93173	85664.60	25302
90656	UD5AJA23HAH7BKZ6L	Mercedes-Benz	E-Class	2016	3.6	Гибрид	Автомат	Черный	73536	20750.77	25344
90657	BTJRDA315BD4K5M1B	Mercedes-Benz	S-Class	2017	2.1	Гибрид	Механика	Красный	100166	35819.15	25360
90658	G80DHN1ZLGJGYD7SH	Audi	Q7	2020	1.2	Электро	Робот	Серый	105934	85204.83	25305
90659	68XRJG2W7VSBYPLDS	Opel	Model	2016	1.2	Дизель	Механика	Коричневый	114314	91373.75	25348
90660	2P2T9EW5VFNEU53ET	Audi	Q7	2020	1.2	Дизель	Вариатор	Коричневый	35014	19493.43	25408
90661	U6D6EPUHKR606LPN9	Ford	Model	2023	3.0	Электро	Робот	Зеленый	95438	34860.38	25306
90662	XCGDWF066D9FDDY5R	Renault	Model	2018	2.7	Дизель	Робот	Зеленый	25022	47625.14	25446
90663	V61USK9H557XDER1U	Ford	Model	2023	2.3	Бензин	Вариатор	Черный	148322	52100.58	25495
90664	VFVKN39S16YHLYDH3	Audi	Q7	2023	1.4	Электро	Автомат	Синий	92716	20728.61	25284
90665	5L41WZCZT6SZBXRK3	Renault	Model	2020	3.6	Бензин	Автомат	Белый	140562	73001.49	25472
90666	YT8CKRS90JX6HVJXU	Porsche	911	2021	2.6	Электро	Механика	Зеленый	13174	32606.93	25303
90667	8ZH4Z3VU8TKXFBL7W	BMW	X5	2019	2.0	Дизель	Робот	Красный	138768	46882.30	25498
90668	73PRTR1CESZ9BJYPY	BMW	520d	2022	3.2	Дизель	Автомат	Красный	108253	77201.34	25349
90669	7VMT6RR4XTPANP4YR	Volkswagen	Polo	2024	3.4	Дизель	Автомат	Синий	47552	67336.73	25267
90670	4TPTHJ883NVPMX04P	BMW	X3	2023	2.6	Бензин	Робот	Коричневый	121199	87871.08	25280
90671	91KNPWVV97ZRGB3G2	Opel	Model	2020	3.0	Бензин	Вариатор	Серебристый	67943	70801.82	25431
90672	ZL1GFSH7AYH70DH87	Porsche	Cayenne	2017	3.1	Дизель	Механика	Белый	17229	99988.16	25296
90673	CAR87AP1C1VN87J8W	BMW	730d	2017	2.7	Дизель	Вариатор	Коричневый	129331	87611.87	25453
90674	H72R5JTZ3T0PYSWMG	Volkswagen	Polo	2021	3.1	Электро	Робот	Белый	115689	76979.21	25478
90675	TRWAVKR2WXR3UVPKM	Opel	Model	2021	3.4	Гибрид	Механика	Серый	14124	46013.46	25303
90676	W10UFMXYN887YEWZ3	Opel	Model	2024	3.2	Бензин	Автомат	Зеленый	136332	44256.39	25344
90677	ZYK8VYUEGM6E042V5	Porsche	911	2024	3.7	Дизель	Автомат	Черный	58297	43417.44	25439
90678	STGYYG1H3U9GAW0A0	BMW	520d	2018	2.0	Электро	Автомат	Синий	34953	20205.03	25508
90679	DZTEVB7UKBT823J94	BMW	520d	2016	2.4	Дизель	Вариатор	Серебристый	98133	32750.06	25384
90680	35SVGBY8BNUSTCS99	Renault	Model	2022	2.9	Гибрид	Автомат	Серый	8372	89755.27	25367
90681	48S16RVMJL6P7WU2G	Volkswagen	Touareg	2024	3.1	Дизель	Механика	Черный	97604	23689.46	25411
90682	HHXCH77F2LTMJ2T3A	Opel	Model	2024	3.1	Бензин	Робот	Коричневый	26349	26703.12	25287
90683	TKUPSY034WG3S7HML	Volkswagen	Polo	2021	1.8	Гибрид	Механика	Черный	77213	97849.17	25326
90684	9EAH9NJCU2CB1L0V7	Ford	Model	2018	2.9	Электро	Вариатор	Коричневый	1291	53492.84	25474
90685	V1YSW1DHJP1K1P3FB	Opel	Model	2019	1.7	Электро	Вариатор	Красный	25507	68329.93	25288
90686	NRH6Y8Z59R7JXL8SB	Mercedes-Benz	E-Class	2015	1.4	Гибрид	Вариатор	Черный	79286	49799.08	25476
90687	053E3P6FZW0CGEYNG	Mercedes-Benz	E-Class	2017	1.6	Бензин	Робот	Серебристый	81186	18037.18	25376
90688	LM7PC6JCFRCR99WX9	Volkswagen	Polo	2023	3.5	Гибрид	Вариатор	Серебристый	67269	57114.21	25476
90689	CMA77P6YFRFVGHFSB	Opel	Model	2022	3.5	Электро	Вариатор	Синий	21794	82169.18	25363
90690	B3DGUFA3G1922XYNS	Ford	Model	2023	2.8	Гибрид	Механика	Белый	142790	70499.72	25304
90691	YB49U4KXA6PK2NZU0	Opel	Model	2016	1.0	Бензин	Автомат	Красный	82042	92047.87	25281
90692	8G13TDDRTBY19WR3F	Audi	A6	2017	1.5	Дизель	Механика	Красный	24677	78826.73	25266
90693	K57Y7CUTK1BXU9Y6R	Porsche	Boxster	2017	3.2	Бензин	Автомат	Серебристый	62561	37704.97	25291
90694	FJ0UX7CHLEJ1PAYFX	Porsche	Boxster	2015	1.5	Гибрид	Механика	Красный	82299	36825.94	25341
90695	AG5YRE4Y1RC6XWP3A	Audi	Q7	2017	2.0	Бензин	Робот	Зеленый	54287	56314.96	25456
90696	0WD09GRAN1RRW9H00	Renault	Model	2024	2.1	Бензин	Механика	Черный	14655	65270.50	25270
90697	UNJ0SYCJFN9V1FEX8	Ford	Model	2018	1.7	Дизель	Механика	Коричневый	123889	53312.59	25374
90698	EPW97BH61M6GG29V8	Porsche	Boxster	2019	3.5	Электро	Автомат	Белый	113616	46343.51	25470
90699	EN3LEEVD3GDGVMB0S	Renault	Model	2017	3.9	Электро	Механика	Коричневый	58060	75755.53	25262
90700	LUKCYD3PBHU12972G	Mercedes-Benz	S-Class	2024	2.8	Электро	Робот	Белый	65609	39826.67	25476
90701	LXP5280M9GCDT433S	Audi	Q7	2018	2.7	Гибрид	Вариатор	Серебристый	16826	26576.95	25401
90702	VTNB0H05H896YS7V7	Mercedes-Benz	E-Class	2016	3.4	Бензин	Робот	Зеленый	72972	80587.85	25278
90703	7212PRX0H7RH4MSGM	Ford	Model	2021	1.4	Электро	Робот	Белый	39921	23099.01	25394
90704	V3P4RM8L3KCVSMTW1	Ford	Model	2021	1.7	Бензин	Робот	Серый	104592	68007.33	25382
90705	HM443SBU9LK6CVPAC	Volkswagen	Passat	2023	2.9	Электро	Вариатор	Серый	25697	94741.94	25467
90706	GPAYYMUDJHM0L3EC6	Volkswagen	Touareg	2023	3.7	Бензин	Вариатор	Зеленый	140831	87897.01	25338
90707	RF18JF6JVVGZM9X4W	Audi	A3	2021	2.5	Гибрид	Механика	Красный	14651	72353.39	25287
90708	S6MN1593HDXDHAWTY	Porsche	911	2020	2.9	Гибрид	Механика	Черный	40001	82949.51	25383
90709	Y4M2WP0VTB3JGJYAJ	Volkswagen	Polo	2016	1.5	Гибрид	Механика	Красный	127938	43234.58	25359
90710	G25BD9ZGEV6K9RZ7K	Ford	Model	2023	1.0	Дизель	Робот	Коричневый	40028	86614.02	25384
90711	7HMP5WELW9UR8ZU31	BMW	X3	2020	3.5	Бензин	Вариатор	Красный	29514	94074.45	25345
90712	UPDRU8A9T0L9P0198	Volkswagen	Tiguan	2018	3.8	Гибрид	Робот	Черный	57135	78078.62	25444
90713	D4Z1UUXCSCC7LJ636	Ford	Model	2024	1.3	Электро	Вариатор	Зеленый	149709	30858.59	25463
90714	LMHVXWN58LPBGGM8D	Volkswagen	Touareg	2018	1.9	Бензин	Вариатор	Зеленый	127792	21151.78	25472
90715	S27J3GRWA6T0D25VA	Volkswagen	Touareg	2018	2.6	Дизель	Автомат	Серебристый	50604	52410.39	25437
90716	6P7Z19H8H31PEL7XV	Volkswagen	Passat	2020	2.6	Электро	Механика	Серебристый	140341	47844.17	25347
90717	TRLLR4FNKS257G44M	Mercedes-Benz	E-Class	2017	1.8	Электро	Вариатор	Красный	37149	57374.84	25331
90718	JE0HC8LLP64AW3FES	Volkswagen	Touareg	2023	2.0	Бензин	Механика	Синий	60380	47604.52	25291
90719	FSLJYVT850M6LV5D1	BMW	X5	2017	1.7	Электро	Робот	Черный	76569	75381.35	25496
90720	L8TPXV4PJTY2HPP4P	Audi	A4	2020	3.7	Электро	Вариатор	Зеленый	22112	37968.14	25484
90721	HTHK8TMF2SVCAKA11	Opel	Model	2020	2.8	Бензин	Робот	Белый	28370	46706.81	25478
90722	9WJJFDUTKJBZ23D9U	BMW	X5	2019	3.0	Гибрид	Вариатор	Серый	113754	22382.12	25508
90723	0NXSSATVS33ECU2YC	Ford	Model	2021	1.4	Дизель	Робот	Серебристый	108306	78651.92	25334
90724	GTXVKWDDLY9JVT18W	Renault	Model	2024	1.7	Бензин	Механика	Коричневый	38208	40897.64	25428
90725	HF21RSXX12RS26BW3	BMW	730d	2021	1.4	Бензин	Механика	Зеленый	105458	87886.42	25418
90726	PZNYERUZNL8XA4E69	Porsche	Panamera	2015	2.6	Гибрид	Механика	Зеленый	124406	64549.62	25302
90727	B5U0PCV33EH4K26X0	Volkswagen	Polo	2015	2.7	Дизель	Вариатор	Черный	130396	50185.36	25372
90728	ZWK3SXUL53XWA6W7F	Mercedes-Benz	A-Class	2022	1.9	Гибрид	Робот	Серебристый	85199	41522.91	25263
90729	FKBPB37D89WUPR7YZ	Porsche	911	2017	1.6	Дизель	Автомат	Красный	75399	67321.58	25491
90730	1RJ4W00JV6CDMSZXJ	Ford	Model	2020	2.1	Электро	Робот	Красный	125918	94818.57	25384
90731	EC7M6LLPVC4STN162	Volkswagen	Touareg	2015	2.9	Бензин	Механика	Зеленый	124402	54218.39	25281
90732	PND5KC0UXN5DN33EM	Ford	Model	2015	2.7	Дизель	Вариатор	Синий	87790	18470.85	25437
90733	YU9WFEAHE1GUJLJLB	Ford	Model	2019	2.2	Дизель	Автомат	Коричневый	32947	21958.08	25322
90734	TV34SZXEZHDKJP91R	Renault	Model	2019	2.1	Электро	Автомат	Белый	70207	70221.85	25498
90735	06U0TJG3CR97G379K	BMW	520d	2015	2.4	Электро	Робот	Зеленый	133655	15566.02	25292
90736	RGPV9WY23SNPLPD9S	BMW	730d	2021	2.0	Гибрид	Механика	Коричневый	97164	43035.67	25301
90737	RTE1FLTWBCXUW7UT3	Ford	Model	2019	2.5	Электро	Механика	Зеленый	143248	35960.90	25483
90738	LH4WEB861M7G4TJ7F	Audi	Q7	2017	3.1	Дизель	Автомат	Белый	76570	91212.95	25456
90739	J19H8MXSDER11GX4D	Audi	A6	2020	2.5	Бензин	Вариатор	Черный	94113	68296.74	25293
90740	H86H5WPUU9BXT44W4	Ford	Model	2018	3.3	Гибрид	Механика	Коричневый	98497	72512.78	25437
90741	2Y9E6GW7A8F0T6D2N	Ford	Model	2019	2.3	Электро	Механика	Красный	23462	65158.15	25306
90742	219XVEE7NJC2XNMPB	Ford	Model	2017	2.6	Бензин	Механика	Черный	76945	18536.67	25468
90743	N9AX18E1LBE25UBCK	Mercedes-Benz	E-Class	2021	1.1	Электро	Вариатор	Черный	70198	79050.94	25432
90744	724DESAMVKJ3A6U61	Renault	Model	2015	3.4	Дизель	Механика	Синий	112131	55776.88	25438
90745	16YYVEJP5F5632VU8	BMW	X5	2015	2.8	Гибрид	Робот	Зеленый	37255	74824.27	25318
90746	MKPLBT7N7FW8863DG	BMW	320d	2016	3.2	Бензин	Автомат	Красный	122067	95675.15	25273
90747	PFF9GVTT2B5LUYZX2	Porsche	Cayenne	2024	3.8	Электро	Механика	Коричневый	142369	62832.89	25421
90748	2T32P406WBZ2SV283	Audi	A4	2020	1.8	Гибрид	Робот	Серый	96348	91656.02	25306
90749	J9CTNY5VEY0SGF766	Ford	Model	2023	2.1	Электро	Автомат	Синий	89623	24505.81	25483
90750	XFTU63TETV2AAA2PG	Audi	A3	2022	4.0	Гибрид	Автомат	Серый	137736	98116.71	25420
90751	LZGN7Y9RE3ZKKEWVL	Renault	Model	2015	2.7	Электро	Механика	Серебристый	142574	24473.73	25387
90752	9D8HHALXVKKGD9FEW	Ford	Model	2021	3.9	Гибрид	Механика	Черный	75537	48964.87	25490
90753	Y42WTDLCWB6KM4GDH	Opel	Model	2022	1.0	Гибрид	Автомат	Серый	130972	40596.04	25391
90754	GK96YEW4XX561LMJM	Mercedes-Benz	A-Class	2021	3.2	Гибрид	Робот	Белый	84995	55777.79	25420
90755	HJLM2S2K4F4XW4KLP	Mercedes-Benz	A-Class	2016	2.6	Электро	Вариатор	Белый	77178	65018.45	25314
90756	RN4359TEF5PSMGFJW	BMW	X5	2018	3.9	Гибрид	Механика	Серый	98195	99329.04	25294
90757	VNMB69CVKM61PCHMJ	Opel	Model	2021	2.0	Электро	Вариатор	Черный	68084	94886.22	25326
90758	9WUBEP9NNP9W10DGT	Opel	Model	2024	2.9	Бензин	Вариатор	Синий	78916	33897.46	25464
90759	YU9BJER3TTW4U62AX	Ford	Model	2018	2.4	Бензин	Вариатор	Серый	18346	50361.63	25459
90760	ZBL5LF1960L509ELR	Volkswagen	Tiguan	2016	3.6	Дизель	Автомат	Белый	81804	16697.39	25471
90761	V3HBASE4FM753YGUC	Porsche	Macan	2023	1.2	Бензин	Механика	Зеленый	54399	50598.96	25459
90762	AXWR3EXF06PBGF3K2	Porsche	Panamera	2019	1.3	Электро	Механика	Зеленый	45823	26541.69	25434
90763	8U13TFV3LZBPFZDL8	Volkswagen	Passat	2018	3.9	Бензин	Механика	Синий	78621	61095.41	25436
90764	XA2WVKTG62UAN0PYH	Audi	A4	2016	1.2	Дизель	Робот	Красный	7896	84336.02	25408
90765	X9WV160PJZWMXBT1E	Opel	Model	2015	3.2	Гибрид	Робот	Серый	21419	22469.93	25494
90766	L026VWX1BWWKDC7YE	Ford	Model	2017	1.7	Гибрид	Автомат	Серебристый	105851	81984.28	25322
90767	6JK942VWLVM1B0KD7	Opel	Model	2023	2.2	Бензин	Робот	Зеленый	145071	60636.93	25265
90768	H6FW9X0TM1KNFB0VV	Volkswagen	Golf	2015	3.4	Электро	Робот	Коричневый	141632	28787.74	25342
90769	E74J4TF3NNJK7MHM7	Porsche	Cayenne	2024	2.6	Бензин	Механика	Белый	73009	26501.45	25399
90770	MJXTU5CWDYUP7PPFX	Opel	Model	2019	1.1	Электро	Механика	Серый	117344	72668.37	25436
90771	DPPMLLS981FP0ZJZS	Ford	Model	2015	3.0	Бензин	Автомат	Белый	23096	23383.26	25368
90772	FUUKSA47ZYCGW1TP8	Porsche	Macan	2023	2.4	Электро	Механика	Зеленый	19220	23036.73	25342
90773	0ELVLZELALA503GG6	Renault	Model	2018	1.5	Дизель	Робот	Красный	55492	28660.75	25449
90774	MSH6X92JDHDFXY2AG	Volkswagen	Golf	2018	3.9	Электро	Вариатор	Белый	12457	98938.90	25435
90775	XLGZ4X36XXV4Z88C6	Porsche	Panamera	2016	2.4	Дизель	Вариатор	Синий	122789	53109.34	25296
90776	AW2R8YD9X152K6BVA	Opel	Model	2024	2.9	Электро	Робот	Синий	31997	28763.64	25373
90777	H4Y1KD0AP8S8C3RAF	Audi	A3	2023	1.6	Бензин	Автомат	Красный	6849	16229.92	25267
90778	PY6L782UYKHL8SERL	Volkswagen	Polo	2015	2.5	Дизель	Механика	Синий	101219	61169.95	25320
90779	YKV2DX090L27E2VWR	Opel	Model	2019	3.8	Бензин	Автомат	Зеленый	90060	31292.60	25355
90780	5YDRGTZT7DF32ZKBX	BMW	730d	2021	1.6	Бензин	Автомат	Белый	103862	18827.30	25350
90781	H51XLC3NKVZ8PVMFL	Ford	Model	2018	1.2	Бензин	Робот	Зеленый	24273	37956.12	25400
90782	YVJXLEP9L2V06FGUY	BMW	X3	2018	3.0	Электро	Автомат	Черный	62627	66899.82	25301
90783	AHZK18CVGTMW1GGJ5	Renault	Model	2017	3.0	Гибрид	Вариатор	Серый	64215	80899.90	25348
90784	WEMRS6D77TWFU1T1G	Opel	Model	2020	1.6	Электро	Автомат	Черный	64665	59411.65	25336
90785	9EKST7YD704U83108	Opel	Model	2023	2.9	Электро	Робот	Серебристый	75951	56804.40	25278
90786	BDX7T7WRHJSN453DG	Audi	Q5	2021	2.0	Гибрид	Автомат	Красный	125986	45589.21	25455
90788	4U2ZTB1REZWWF39K5	BMW	X5	2024	2.3	Бензин	Механика	Коричневый	99041	77440.13	25281
90789	DAKSPDB7TGYC7K0CE	Renault	Model	2019	3.4	Гибрид	Вариатор	Серый	8435	96485.74	25483
90790	FD47LE6LH8Y9YSPPS	Porsche	Panamera	2015	4.0	Электро	Автомат	Зеленый	88943	40582.94	25460
90791	VBLX5GKT1CM7892WK	Audi	Q7	2017	1.6	Бензин	Робот	Белый	34075	36771.79	25492
90792	1F2B1A8XZEH4ZJMTK	Ford	Model	2022	2.1	Дизель	Вариатор	Черный	21178	50452.21	25503
90793	BD14PEX06MMJYW6VJ	Volkswagen	Passat	2018	1.9	Гибрид	Механика	Синий	116279	54294.06	25479
90794	S53WWW9SDE0HTTESS	Ford	Model	2023	1.7	Бензин	Робот	Красный	145685	91507.09	25379
90795	M5YL1GZ7YVE2XUM9L	Ford	Model	2016	1.8	Электро	Автомат	Серый	49749	61644.86	25262
90796	N08DCK7UMY2UAS5VS	Mercedes-Benz	GLC	2022	3.0	Дизель	Автомат	Белый	127806	87718.38	25509
90797	JPY4E2AWCA1MPWNV1	Audi	A6	2020	2.4	Электро	Автомат	Синий	75973	15747.20	25389
90798	ZNZRAJYFHVZTDR2U6	Porsche	Panamera	2018	3.7	Электро	Вариатор	Зеленый	33514	81935.68	25467
90799	TWAB59F5VTC6XE61Z	BMW	X3	2018	1.7	Дизель	Вариатор	Синий	134008	22903.27	25488
90800	PAKLJA83TBFSTT6A3	Renault	Model	2022	3.7	Дизель	Механика	Серый	31899	99741.63	25419
90801	KGFS0JMTUAVVJX9RZ	Mercedes-Benz	C-Class	2018	2.3	Дизель	Вариатор	Коричневый	60384	84101.25	25507
90802	5ACPKTVKA32LVEBC6	Opel	Model	2023	3.5	Бензин	Вариатор	Серебристый	24217	39292.71	25488
90803	AFLUUJR6CFR4XW2VZ	BMW	X5	2015	3.0	Бензин	Автомат	Зеленый	148602	42889.67	25488
90804	BX1TZ9Y998PTWWNCG	Porsche	Panamera	2021	1.3	Гибрид	Механика	Зеленый	28863	47548.97	25446
90805	7N9JRKB9M9THB85V3	Porsche	Boxster	2015	2.9	Дизель	Вариатор	Красный	99396	94322.96	25439
90806	GFL0P1AEUM88CD6V7	Opel	Model	2015	2.6	Электро	Автомат	Зеленый	130013	16346.90	25311
90807	UF5T1R9JHH5P9PV0E	Volkswagen	Tiguan	2019	1.2	Бензин	Механика	Синий	134491	35880.92	25431
90808	4F03L6FY57LBF8FYK	Opel	Model	2017	2.7	Гибрид	Автомат	Белый	19393	98717.48	25438
90809	D4CPPZ2KCA01V90YH	Opel	Model	2017	3.2	Гибрид	Механика	Белый	21447	28791.00	25476
90810	JRJKL6K2WT1MR689J	Opel	Model	2018	1.7	Дизель	Вариатор	Зеленый	118594	65763.83	25413
90811	YGTCEC4LWFLA0DP3A	Audi	A3	2017	2.5	Дизель	Робот	Синий	68319	47512.95	25468
90812	T4P11N62A7BTRCRA0	Ford	Model	2023	1.1	Дизель	Автомат	Серебристый	132118	81346.79	25307
90813	E4SR77R7AVLJ3SXKV	Audi	Q5	2017	1.9	Бензин	Робот	Красный	149589	75156.54	25395
90814	VBUBL0DWL39SZ2Y7R	BMW	520d	2021	2.5	Гибрид	Вариатор	Серебристый	102742	69879.84	25410
90815	NBGDKB578FSJ58UKH	Ford	Model	2019	2.6	Бензин	Вариатор	Зеленый	73951	23557.72	25291
90816	V3WFAMUT0TUDAUF28	BMW	X5	2018	3.4	Электро	Механика	Серебристый	77870	96075.14	25319
90817	GGEWRUWBBTSXT7F9B	Volkswagen	Touareg	2018	3.5	Электро	Автомат	Серый	102629	49566.98	25378
90818	9ZC9R7H7RSR4H6ZNU	BMW	730d	2016	2.7	Гибрид	Робот	Черный	130776	24046.29	25367
90819	DJ1M1GC0JKARM3SM3	Mercedes-Benz	C-Class	2015	1.8	Электро	Робот	Серебристый	55926	71194.75	25383
90820	79WF8GB0ER428TGMB	Porsche	Macan	2024	1.3	Бензин	Автомат	Черный	47191	19427.79	25311
90821	RXC1H1903S1T9PDGR	Renault	Model	2015	1.8	Гибрид	Механика	Синий	84763	76719.69	25499
90822	YKYYSN5A8TLSUXVGK	Ford	Model	2019	2.6	Дизель	Автомат	Зеленый	97848	94050.20	25476
90823	23YC2RFCWXWF37Z0U	Mercedes-Benz	E-Class	2024	2.6	Бензин	Механика	Коричневый	29092	87687.72	25303
90824	9UB4UC6MDZZJ8HL0M	BMW	730d	2018	3.3	Бензин	Механика	Серебристый	29879	45853.07	25264
90825	GD52HRVW5411A2B29	Opel	Model	2022	1.9	Электро	Механика	Черный	51400	58816.50	25349
90826	T37FP38TP32RXTGCL	Mercedes-Benz	GLC	2020	2.0	Бензин	Вариатор	Белый	52550	54493.45	25357
90827	7HRM17LTM6MEGR5WG	Mercedes-Benz	GLC	2017	1.7	Бензин	Механика	Серебристый	75627	76735.18	25468
90828	5U1U173H871BEPV5P	Porsche	Panamera	2016	1.4	Гибрид	Механика	Красный	51128	81750.40	25289
90829	ZWSXD8118KCUEX6SG	Opel	Model	2016	1.7	Электро	Автомат	Красный	111447	67192.07	25486
90830	L0876GA744RSHZ8T7	BMW	X5	2017	1.5	Бензин	Механика	Красный	74333	26920.98	25277
90831	AXRFD9UC7FJTFNZG4	Volkswagen	Tiguan	2020	1.6	Бензин	Механика	Зеленый	118687	49765.77	25406
90832	R07TJVK2BE64MUPGV	Porsche	Cayenne	2023	3.1	Дизель	Механика	Коричневый	66628	27154.94	25475
90833	W97YBZH8HC5KM0YGA	Porsche	Cayenne	2018	1.5	Гибрид	Вариатор	Белый	107787	35415.20	25312
90834	HLC65VPBUKVRBZ4P9	Mercedes-Benz	A-Class	2024	2.9	Дизель	Автомат	Черный	40100	83295.59	25383
90835	BASVKN1MUCRVSF4GE	Porsche	911	2015	1.6	Гибрид	Автомат	Серебристый	136989	35975.13	25345
90836	CL0K34XTH5TLR28BD	BMW	520d	2018	3.7	Гибрид	Вариатор	Зеленый	61541	30402.43	25378
90837	MEWFK8FN8CNUYBJZ9	Porsche	Macan	2022	1.6	Дизель	Робот	Синий	40636	77365.86	25494
90838	2J9WT1N3S7RG3A69C	Mercedes-Benz	C-Class	2023	2.6	Электро	Робот	Серебристый	121282	30395.88	25443
90839	KYA2PRWFPJEVXGK01	Porsche	Boxster	2016	3.6	Гибрид	Вариатор	Синий	27631	89554.48	25276
90840	J281MYT17B98HASS5	Renault	Model	2020	3.3	Электро	Вариатор	Синий	32702	58954.88	25428
90841	XZPVY1B6CNGSV53U6	Porsche	911	2023	3.0	Гибрид	Робот	Зеленый	128332	34701.96	25383
90842	03XL8FNF89ZTYW397	Audi	A6	2017	2.0	Дизель	Автомат	Серый	2509	90342.01	25294
90843	3KDGR2FH9UWUEHEXS	Audi	Q5	2024	2.2	Бензин	Механика	Черный	20369	72775.30	25488
90844	43YW3VWF860TXELWG	Opel	Model	2020	2.0	Электро	Вариатор	Зеленый	98539	82453.39	25474
90845	LM8FY2E7NYE6GHKS3	BMW	730d	2022	3.0	Гибрид	Вариатор	Серебристый	73234	62657.06	25470
90846	0K66YHUPS3MAAH89Z	Mercedes-Benz	A-Class	2015	2.2	Дизель	Вариатор	Красный	103649	51334.90	25460
90847	Y0ENSAKA2JUGP8LWS	Ford	Model	2018	3.4	Дизель	Механика	Красный	80317	15927.98	25408
90848	43VC4BCFCTKE7F8P4	BMW	730d	2016	1.2	Бензин	Вариатор	Серебристый	121578	25446.70	25279
90849	4F8HYGL4ST4ZYRTE8	Volkswagen	Polo	2020	2.0	Электро	Робот	Синий	56997	31367.16	25405
90850	X7FKFZ32ABY2ZW3YZ	Volkswagen	Passat	2023	4.0	Бензин	Вариатор	Зеленый	49601	34822.18	25281
90851	74RZE92N7X2TWAMH7	Opel	Model	2018	2.2	Бензин	Механика	Коричневый	82243	56983.62	25363
90852	5S8271ZLJ6L1RUCFN	Mercedes-Benz	C-Class	2021	2.1	Электро	Автомат	Зеленый	27956	30259.43	25426
90853	EENSP010TPK9NA1ZC	Volkswagen	Polo	2024	2.4	Бензин	Робот	Синий	91047	30102.66	25369
90854	F10WC3DB4TE7FJE3K	Mercedes-Benz	A-Class	2015	1.6	Электро	Робот	Белый	52648	17432.68	25359
90855	MWAEKBBWRCDXWMHDG	Ford	Model	2015	1.1	Дизель	Автомат	Красный	122072	62575.84	25264
90856	3U32CJ5PGZW6ZK6F7	Volkswagen	Touareg	2016	3.7	Гибрид	Механика	Красный	53960	79240.58	25278
90857	Z7H7G4D44L79FVSY7	BMW	X3	2015	2.7	Бензин	Вариатор	Белый	8634	40939.87	25278
90858	659UXTY4VGK9E7907	Opel	Model	2021	1.7	Бензин	Механика	Красный	54955	24689.03	25351
90859	8TLBANEJWN9EKZTCP	Mercedes-Benz	A-Class	2021	2.2	Электро	Вариатор	Серый	7925	96726.69	25499
90860	KN2XCBBNCS4FCNH5E	Renault	Model	2021	3.4	Электро	Механика	Зеленый	108257	43187.68	25400
90861	CAJHHWDE67X4B1CER	Opel	Model	2020	2.7	Дизель	Автомат	Серый	5591	96273.38	25379
90862	64U267ZZNJE8ZKTUA	Porsche	Panamera	2016	2.0	Электро	Вариатор	Синий	124816	41828.34	25311
90863	ENKY4US2HA6YKD1E3	Audi	A6	2024	2.0	Электро	Робот	Серый	119429	65043.93	25436
90864	YGNHH7RVWKXW159R0	Ford	Model	2018	1.5	Дизель	Вариатор	Белый	42845	19729.73	25491
90865	HH1KAZWRJTC3C32LW	Renault	Model	2017	2.9	Электро	Механика	Красный	100581	27740.88	25510
90866	YH2KGCS9KJ173W7BT	Porsche	Macan	2015	2.1	Электро	Механика	Красный	145532	15407.80	25472
90867	V9YH0VUJPMBEMVJBH	BMW	X3	2016	1.8	Электро	Робот	Красный	73525	36590.09	25391
90868	L4E1UB2R4RSP6U29C	Ford	Model	2016	1.8	Дизель	Робот	Красный	56702	88434.34	25469
90869	VCEMGXWYGMGPKCTN4	Audi	Q5	2023	3.1	Электро	Механика	Синий	72334	65983.06	25496
90870	3SV9DN0UMMKXD0BE1	Audi	Q5	2024	2.5	Электро	Автомат	Красный	4638	96253.20	25332
90871	3JG0LFHR8BVVR63Z2	Renault	Model	2016	2.1	Дизель	Робот	Синий	48138	27232.10	25469
90872	785UL7AU95E1TFFV9	Renault	Model	2020	2.3	Бензин	Автомат	Коричневый	30728	31805.25	25386
90873	YJ4RADFLF5UR4SJ1U	Opel	Model	2024	2.4	Гибрид	Робот	Зеленый	24404	41111.44	25463
\.


--
-- TOC entry 3677 (class 0 OID 18331)
-- Dependencies: 226
-- Data for Name: client_documents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.client_documents (document_id, client_id, passport_scan_path, driver_license_path, additional_docs_path, upload_date) FROM stdin;
30177	89890	/docs/passports/client_89890_passport.pdf	/docs/licenses/client_89890_license.pdf	\N	2025-09-16
30178	90220	/docs/passports/client_90220_passport.pdf	/docs/licenses/client_90220_license.pdf	\N	2025-09-16
30179	90238	/docs/passports/client_90238_passport.pdf	/docs/licenses/client_90238_license.pdf	\N	2025-09-16
30180	89894	/docs/passports/client_89894_passport.pdf	/docs/licenses/client_89894_license.pdf	\N	2025-09-16
30181	89830	/docs/passports/client_89830_passport.pdf	/docs/licenses/client_89830_license.pdf	\N	2025-09-16
30182	90191	/docs/passports/client_90191_passport.pdf	/docs/licenses/client_90191_license.pdf	/docs/additional/client_90191_additional.pdf	2025-09-16
30183	90163	/docs/passports/client_90163_passport.pdf	/docs/licenses/client_90163_license.pdf	\N	2025-09-16
30184	90266	/docs/passports/client_90266_passport.pdf	/docs/licenses/client_90266_license.pdf	/docs/additional/client_90266_additional.pdf	2025-09-16
30185	90041	/docs/passports/client_90041_passport.pdf	/docs/licenses/client_90041_license.pdf	/docs/additional/client_90041_additional.pdf	2025-09-16
30186	89902	/docs/passports/client_89902_passport.pdf	/docs/licenses/client_89902_license.pdf	\N	2025-09-16
30187	89926	/docs/passports/client_89926_passport.pdf	/docs/licenses/client_89926_license.pdf	\N	2025-09-16
30188	89886	/docs/passports/client_89886_passport.pdf	/docs/licenses/client_89886_license.pdf	\N	2025-09-16
30189	90065	/docs/passports/client_90065_passport.pdf	/docs/licenses/client_90065_license.pdf	\N	2025-09-16
30190	90180	/docs/passports/client_90180_passport.pdf	/docs/licenses/client_90180_license.pdf	\N	2025-09-16
30191	90279	/docs/passports/client_90279_passport.pdf	/docs/licenses/client_90279_license.pdf	/docs/additional/client_90279_additional.pdf	2025-09-16
30192	90014	/docs/passports/client_90014_passport.pdf	/docs/licenses/client_90014_license.pdf	\N	2025-09-16
30193	90293	/docs/passports/client_90293_passport.pdf	/docs/licenses/client_90293_license.pdf	\N	2025-09-16
30194	89878	/docs/passports/client_89878_passport.pdf	/docs/licenses/client_89878_license.pdf	\N	2025-09-16
30195	89914	/docs/passports/client_89914_passport.pdf	/docs/licenses/client_89914_license.pdf	\N	2025-09-16
30196	90323	/docs/passports/client_90323_passport.pdf	/docs/licenses/client_90323_license.pdf	\N	2025-09-16
30197	89963	/docs/passports/client_89963_passport.pdf	/docs/licenses/client_89963_license.pdf	\N	2025-09-16
30198	90017	/docs/passports/client_90017_passport.pdf	/docs/licenses/client_90017_license.pdf	\N	2025-09-16
30199	90125	/docs/passports/client_90125_passport.pdf	/docs/licenses/client_90125_license.pdf	/docs/additional/client_90125_additional.pdf	2025-09-16
30200	90037	/docs/passports/client_90037_passport.pdf	/docs/licenses/client_90037_license.pdf	\N	2025-09-16
30201	90287	/docs/passports/client_90287_passport.pdf	/docs/licenses/client_90287_license.pdf	/docs/additional/client_90287_additional.pdf	2025-09-16
30202	89833	/docs/passports/client_89833_passport.pdf	/docs/licenses/client_89833_license.pdf	\N	2025-09-16
30203	90292	/docs/passports/client_90292_passport.pdf	/docs/licenses/client_90292_license.pdf	/docs/additional/client_90292_additional.pdf	2025-09-16
30204	90153	/docs/passports/client_90153_passport.pdf	/docs/licenses/client_90153_license.pdf	/docs/additional/client_90153_additional.pdf	2025-09-16
30205	89855	/docs/passports/client_89855_passport.pdf	/docs/licenses/client_89855_license.pdf	\N	2025-09-16
30206	90052	/docs/passports/client_90052_passport.pdf	/docs/licenses/client_90052_license.pdf	\N	2025-09-16
30207	89865	/docs/passports/client_89865_passport.pdf	/docs/licenses/client_89865_license.pdf	/docs/additional/client_89865_additional.pdf	2025-09-16
30208	90128	/docs/passports/client_90128_passport.pdf	/docs/licenses/client_90128_license.pdf	\N	2025-09-16
30209	90047	/docs/passports/client_90047_passport.pdf	/docs/licenses/client_90047_license.pdf	/docs/additional/client_90047_additional.pdf	2025-09-16
30210	90233	/docs/passports/client_90233_passport.pdf	/docs/licenses/client_90233_license.pdf	/docs/additional/client_90233_additional.pdf	2025-09-16
30211	89978	/docs/passports/client_89978_passport.pdf	/docs/licenses/client_89978_license.pdf	\N	2025-09-16
30212	90117	/docs/passports/client_90117_passport.pdf	/docs/licenses/client_90117_license.pdf	/docs/additional/client_90117_additional.pdf	2025-09-16
30213	90008	/docs/passports/client_90008_passport.pdf	/docs/licenses/client_90008_license.pdf	\N	2025-09-16
30214	90032	/docs/passports/client_90032_passport.pdf	/docs/licenses/client_90032_license.pdf	\N	2025-09-16
30215	89829	/docs/passports/client_89829_passport.pdf	/docs/licenses/client_89829_license.pdf	\N	2025-09-16
30216	90305	/docs/passports/client_90305_passport.pdf	/docs/licenses/client_90305_license.pdf	/docs/additional/client_90305_additional.pdf	2025-09-16
30217	90212	/docs/passports/client_90212_passport.pdf	/docs/licenses/client_90212_license.pdf	/docs/additional/client_90212_additional.pdf	2025-09-16
30218	90097	/docs/passports/client_90097_passport.pdf	/docs/licenses/client_90097_license.pdf	/docs/additional/client_90097_additional.pdf	2025-09-16
30219	90253	/docs/passports/client_90253_passport.pdf	/docs/licenses/client_90253_license.pdf	\N	2025-09-16
30220	90061	/docs/passports/client_90061_passport.pdf	/docs/licenses/client_90061_license.pdf	\N	2025-09-16
30221	90309	/docs/passports/client_90309_passport.pdf	/docs/licenses/client_90309_license.pdf	\N	2025-09-16
30222	90157	/docs/passports/client_90157_passport.pdf	/docs/licenses/client_90157_license.pdf	/docs/additional/client_90157_additional.pdf	2025-09-16
30223	89996	/docs/passports/client_89996_passport.pdf	/docs/licenses/client_89996_license.pdf	\N	2025-09-16
30224	90003	/docs/passports/client_90003_passport.pdf	/docs/licenses/client_90003_license.pdf	\N	2025-09-16
30225	90228	/docs/passports/client_90228_passport.pdf	/docs/licenses/client_90228_license.pdf	\N	2025-09-16
30226	90251	/docs/passports/client_90251_passport.pdf	/docs/licenses/client_90251_license.pdf	\N	2025-09-16
30227	90044	/docs/passports/client_90044_passport.pdf	/docs/licenses/client_90044_license.pdf	\N	2025-09-16
30228	89915	/docs/passports/client_89915_passport.pdf	/docs/licenses/client_89915_license.pdf	\N	2025-09-16
30229	90039	/docs/passports/client_90039_passport.pdf	/docs/licenses/client_90039_license.pdf	\N	2025-09-16
30230	90230	/docs/passports/client_90230_passport.pdf	/docs/licenses/client_90230_license.pdf	/docs/additional/client_90230_additional.pdf	2025-09-16
30231	89904	/docs/passports/client_89904_passport.pdf	/docs/licenses/client_89904_license.pdf	\N	2025-09-16
30232	90296	/docs/passports/client_90296_passport.pdf	/docs/licenses/client_90296_license.pdf	\N	2025-09-16
30233	90020	/docs/passports/client_90020_passport.pdf	/docs/licenses/client_90020_license.pdf	/docs/additional/client_90020_additional.pdf	2025-09-16
30234	90083	/docs/passports/client_90083_passport.pdf	/docs/licenses/client_90083_license.pdf	\N	2025-09-16
30235	90170	/docs/passports/client_90170_passport.pdf	/docs/licenses/client_90170_license.pdf	\N	2025-09-16
30236	90322	/docs/passports/client_90322_passport.pdf	/docs/licenses/client_90322_license.pdf	\N	2025-09-16
30237	89943	/docs/passports/client_89943_passport.pdf	/docs/licenses/client_89943_license.pdf	\N	2025-09-16
30238	89827	/docs/passports/client_89827_passport.pdf	/docs/licenses/client_89827_license.pdf	\N	2025-09-16
30239	90116	/docs/passports/client_90116_passport.pdf	/docs/licenses/client_90116_license.pdf	\N	2025-09-16
30240	89891	/docs/passports/client_89891_passport.pdf	/docs/licenses/client_89891_license.pdf	\N	2025-09-16
30241	90318	/docs/passports/client_90318_passport.pdf	/docs/licenses/client_90318_license.pdf	/docs/additional/client_90318_additional.pdf	2025-09-16
30242	90221	/docs/passports/client_90221_passport.pdf	/docs/licenses/client_90221_license.pdf	\N	2025-09-16
30243	89981	/docs/passports/client_89981_passport.pdf	/docs/licenses/client_89981_license.pdf	\N	2025-09-16
30244	90211	/docs/passports/client_90211_passport.pdf	/docs/licenses/client_90211_license.pdf	\N	2025-09-16
30245	89924	/docs/passports/client_89924_passport.pdf	/docs/licenses/client_89924_license.pdf	/docs/additional/client_89924_additional.pdf	2025-09-16
30246	90016	/docs/passports/client_90016_passport.pdf	/docs/licenses/client_90016_license.pdf	\N	2025-09-16
30247	90098	/docs/passports/client_90098_passport.pdf	/docs/licenses/client_90098_license.pdf	\N	2025-09-16
30248	90067	/docs/passports/client_90067_passport.pdf	/docs/licenses/client_90067_license.pdf	\N	2025-09-16
30249	90080	/docs/passports/client_90080_passport.pdf	/docs/licenses/client_90080_license.pdf	/docs/additional/client_90080_additional.pdf	2025-09-16
30250	90150	/docs/passports/client_90150_passport.pdf	/docs/licenses/client_90150_license.pdf	\N	2025-09-16
30251	90178	/docs/passports/client_90178_passport.pdf	/docs/licenses/client_90178_license.pdf	/docs/additional/client_90178_additional.pdf	2025-09-16
30252	90118	/docs/passports/client_90118_passport.pdf	/docs/licenses/client_90118_license.pdf	\N	2025-09-16
30253	89938	/docs/passports/client_89938_passport.pdf	/docs/licenses/client_89938_license.pdf	\N	2025-09-16
30254	90160	/docs/passports/client_90160_passport.pdf	/docs/licenses/client_90160_license.pdf	\N	2025-09-16
30255	89934	/docs/passports/client_89934_passport.pdf	/docs/licenses/client_89934_license.pdf	\N	2025-09-16
30256	89901	/docs/passports/client_89901_passport.pdf	/docs/licenses/client_89901_license.pdf	/docs/additional/client_89901_additional.pdf	2025-09-16
30257	90105	/docs/passports/client_90105_passport.pdf	/docs/licenses/client_90105_license.pdf	\N	2025-09-16
30258	90303	/docs/passports/client_90303_passport.pdf	/docs/licenses/client_90303_license.pdf	/docs/additional/client_90303_additional.pdf	2025-09-16
30259	90158	/docs/passports/client_90158_passport.pdf	/docs/licenses/client_90158_license.pdf	\N	2025-09-16
30260	89971	/docs/passports/client_89971_passport.pdf	/docs/licenses/client_89971_license.pdf	/docs/additional/client_89971_additional.pdf	2025-09-16
30261	90172	/docs/passports/client_90172_passport.pdf	/docs/licenses/client_90172_license.pdf	\N	2025-09-16
30262	89999	/docs/passports/client_89999_passport.pdf	/docs/licenses/client_89999_license.pdf	\N	2025-09-16
30263	90074	/docs/passports/client_90074_passport.pdf	/docs/licenses/client_90074_license.pdf	/docs/additional/client_90074_additional.pdf	2025-09-16
30264	90051	/docs/passports/client_90051_passport.pdf	/docs/licenses/client_90051_license.pdf	\N	2025-09-16
30265	89909	/docs/passports/client_89909_passport.pdf	/docs/licenses/client_89909_license.pdf	\N	2025-09-16
30266	89870	/docs/passports/client_89870_passport.pdf	/docs/licenses/client_89870_license.pdf	\N	2025-09-16
30267	89888	/docs/passports/client_89888_passport.pdf	/docs/licenses/client_89888_license.pdf	\N	2025-09-16
30268	89862	/docs/passports/client_89862_passport.pdf	/docs/licenses/client_89862_license.pdf	\N	2025-09-16
30269	89942	/docs/passports/client_89942_passport.pdf	/docs/licenses/client_89942_license.pdf	\N	2025-09-16
30270	90099	/docs/passports/client_90099_passport.pdf	/docs/licenses/client_90099_license.pdf	\N	2025-09-16
30271	90222	/docs/passports/client_90222_passport.pdf	/docs/licenses/client_90222_license.pdf	\N	2025-09-16
30272	90070	/docs/passports/client_90070_passport.pdf	/docs/licenses/client_90070_license.pdf	/docs/additional/client_90070_additional.pdf	2025-09-16
30273	90054	/docs/passports/client_90054_passport.pdf	/docs/licenses/client_90054_license.pdf	/docs/additional/client_90054_additional.pdf	2025-09-16
30274	90263	/docs/passports/client_90263_passport.pdf	/docs/licenses/client_90263_license.pdf	\N	2025-09-16
30275	89946	/docs/passports/client_89946_passport.pdf	/docs/licenses/client_89946_license.pdf	\N	2025-09-16
30276	90236	/docs/passports/client_90236_passport.pdf	/docs/licenses/client_90236_license.pdf	/docs/additional/client_90236_additional.pdf	2025-09-16
30277	90119	/docs/passports/client_90119_passport.pdf	/docs/licenses/client_90119_license.pdf	/docs/additional/client_90119_additional.pdf	2025-09-16
30278	90245	/docs/passports/client_90245_passport.pdf	/docs/licenses/client_90245_license.pdf	/docs/additional/client_90245_additional.pdf	2025-09-16
30279	90031	/docs/passports/client_90031_passport.pdf	/docs/licenses/client_90031_license.pdf	/docs/additional/client_90031_additional.pdf	2025-09-16
30280	90324	/docs/passports/client_90324_passport.pdf	/docs/licenses/client_90324_license.pdf	/docs/additional/client_90324_additional.pdf	2025-09-16
30281	90121	/docs/passports/client_90121_passport.pdf	/docs/licenses/client_90121_license.pdf	\N	2025-09-16
30282	90291	/docs/passports/client_90291_passport.pdf	/docs/licenses/client_90291_license.pdf	/docs/additional/client_90291_additional.pdf	2025-09-16
30283	89831	/docs/passports/client_89831_passport.pdf	/docs/licenses/client_89831_license.pdf	/docs/additional/client_89831_additional.pdf	2025-09-16
30284	89877	/docs/passports/client_89877_passport.pdf	/docs/licenses/client_89877_license.pdf	\N	2025-09-16
30285	90062	/docs/passports/client_90062_passport.pdf	/docs/licenses/client_90062_license.pdf	/docs/additional/client_90062_additional.pdf	2025-09-16
30286	89921	/docs/passports/client_89921_passport.pdf	/docs/licenses/client_89921_license.pdf	\N	2025-09-16
30287	90234	/docs/passports/client_90234_passport.pdf	/docs/licenses/client_90234_license.pdf	\N	2025-09-16
30288	90075	/docs/passports/client_90075_passport.pdf	/docs/licenses/client_90075_license.pdf	\N	2025-09-16
30289	89953	/docs/passports/client_89953_passport.pdf	/docs/licenses/client_89953_license.pdf	\N	2025-09-16
30290	90187	/docs/passports/client_90187_passport.pdf	/docs/licenses/client_90187_license.pdf	/docs/additional/client_90187_additional.pdf	2025-09-16
30291	90011	/docs/passports/client_90011_passport.pdf	/docs/licenses/client_90011_license.pdf	\N	2025-09-16
30292	89842	/docs/passports/client_89842_passport.pdf	/docs/licenses/client_89842_license.pdf	/docs/additional/client_89842_additional.pdf	2025-09-16
30293	90215	/docs/passports/client_90215_passport.pdf	/docs/licenses/client_90215_license.pdf	\N	2025-09-16
30294	89931	/docs/passports/client_89931_passport.pdf	/docs/licenses/client_89931_license.pdf	/docs/additional/client_89931_additional.pdf	2025-09-16
30295	90198	/docs/passports/client_90198_passport.pdf	/docs/licenses/client_90198_license.pdf	\N	2025-09-16
30296	89858	/docs/passports/client_89858_passport.pdf	/docs/licenses/client_89858_license.pdf	\N	2025-09-16
30297	90250	/docs/passports/client_90250_passport.pdf	/docs/licenses/client_90250_license.pdf	/docs/additional/client_90250_additional.pdf	2025-09-16
30298	89974	/docs/passports/client_89974_passport.pdf	/docs/licenses/client_89974_license.pdf	/docs/additional/client_89974_additional.pdf	2025-09-16
30299	90273	/docs/passports/client_90273_passport.pdf	/docs/licenses/client_90273_license.pdf	\N	2025-09-16
30300	89836	/docs/passports/client_89836_passport.pdf	/docs/licenses/client_89836_license.pdf	/docs/additional/client_89836_additional.pdf	2025-09-16
30301	90181	/docs/passports/client_90181_passport.pdf	/docs/licenses/client_90181_license.pdf	/docs/additional/client_90181_additional.pdf	2025-09-16
30302	89919	/docs/passports/client_89919_passport.pdf	/docs/licenses/client_89919_license.pdf	\N	2025-09-16
30303	89908	/docs/passports/client_89908_passport.pdf	/docs/licenses/client_89908_license.pdf	/docs/additional/client_89908_additional.pdf	2025-09-16
30304	89848	/docs/passports/client_89848_passport.pdf	/docs/licenses/client_89848_license.pdf	/docs/additional/client_89848_additional.pdf	2025-09-16
30305	90127	/docs/passports/client_90127_passport.pdf	/docs/licenses/client_90127_license.pdf	\N	2025-09-16
30306	90162	/docs/passports/client_90162_passport.pdf	/docs/licenses/client_90162_license.pdf	\N	2025-09-16
30307	90197	/docs/passports/client_90197_passport.pdf	/docs/licenses/client_90197_license.pdf	/docs/additional/client_90197_additional.pdf	2025-09-16
30308	89876	/docs/passports/client_89876_passport.pdf	/docs/licenses/client_89876_license.pdf	/docs/additional/client_89876_additional.pdf	2025-09-16
30309	90124	/docs/passports/client_90124_passport.pdf	/docs/licenses/client_90124_license.pdf	/docs/additional/client_90124_additional.pdf	2025-09-16
30310	90156	/docs/passports/client_90156_passport.pdf	/docs/licenses/client_90156_license.pdf	/docs/additional/client_90156_additional.pdf	2025-09-16
30311	90295	/docs/passports/client_90295_passport.pdf	/docs/licenses/client_90295_license.pdf	\N	2025-09-16
30312	89887	/docs/passports/client_89887_passport.pdf	/docs/licenses/client_89887_license.pdf	\N	2025-09-16
30313	90206	/docs/passports/client_90206_passport.pdf	/docs/licenses/client_90206_license.pdf	\N	2025-09-16
30314	90205	/docs/passports/client_90205_passport.pdf	/docs/licenses/client_90205_license.pdf	/docs/additional/client_90205_additional.pdf	2025-09-16
30315	90239	/docs/passports/client_90239_passport.pdf	/docs/licenses/client_90239_license.pdf	/docs/additional/client_90239_additional.pdf	2025-09-16
30316	89988	/docs/passports/client_89988_passport.pdf	/docs/licenses/client_89988_license.pdf	\N	2025-09-16
30317	90038	/docs/passports/client_90038_passport.pdf	/docs/licenses/client_90038_license.pdf	\N	2025-09-16
30318	89884	/docs/passports/client_89884_passport.pdf	/docs/licenses/client_89884_license.pdf	\N	2025-09-16
30319	90264	/docs/passports/client_90264_passport.pdf	/docs/licenses/client_90264_license.pdf	/docs/additional/client_90264_additional.pdf	2025-09-16
30320	89935	/docs/passports/client_89935_passport.pdf	/docs/licenses/client_89935_license.pdf	\N	2025-09-16
30321	90161	/docs/passports/client_90161_passport.pdf	/docs/licenses/client_90161_license.pdf	\N	2025-09-16
30322	90091	/docs/passports/client_90091_passport.pdf	/docs/licenses/client_90091_license.pdf	\N	2025-09-16
30323	90138	/docs/passports/client_90138_passport.pdf	/docs/licenses/client_90138_license.pdf	\N	2025-09-16
30324	90313	/docs/passports/client_90313_passport.pdf	/docs/licenses/client_90313_license.pdf	\N	2025-09-16
30325	89992	/docs/passports/client_89992_passport.pdf	/docs/licenses/client_89992_license.pdf	/docs/additional/client_89992_additional.pdf	2025-09-16
30326	90155	/docs/passports/client_90155_passport.pdf	/docs/licenses/client_90155_license.pdf	/docs/additional/client_90155_additional.pdf	2025-09-16
30327	90050	/docs/passports/client_90050_passport.pdf	/docs/licenses/client_90050_license.pdf	/docs/additional/client_90050_additional.pdf	2025-09-16
30328	90034	/docs/passports/client_90034_passport.pdf	/docs/licenses/client_90034_license.pdf	\N	2025-09-16
30329	90201	/docs/passports/client_90201_passport.pdf	/docs/licenses/client_90201_license.pdf	/docs/additional/client_90201_additional.pdf	2025-09-16
30330	90190	/docs/passports/client_90190_passport.pdf	/docs/licenses/client_90190_license.pdf	\N	2025-09-16
30331	89995	/docs/passports/client_89995_passport.pdf	/docs/licenses/client_89995_license.pdf	/docs/additional/client_89995_additional.pdf	2025-09-16
30332	90278	/docs/passports/client_90278_passport.pdf	/docs/licenses/client_90278_license.pdf	\N	2025-09-16
30333	90177	/docs/passports/client_90177_passport.pdf	/docs/licenses/client_90177_license.pdf	\N	2025-09-16
30334	89871	/docs/passports/client_89871_passport.pdf	/docs/licenses/client_89871_license.pdf	\N	2025-09-16
30335	90071	/docs/passports/client_90071_passport.pdf	/docs/licenses/client_90071_license.pdf	\N	2025-09-16
30336	89987	/docs/passports/client_89987_passport.pdf	/docs/licenses/client_89987_license.pdf	\N	2025-09-16
30337	89881	/docs/passports/client_89881_passport.pdf	/docs/licenses/client_89881_license.pdf	\N	2025-09-16
30338	89889	/docs/passports/client_89889_passport.pdf	/docs/licenses/client_89889_license.pdf	\N	2025-09-16
30339	90225	/docs/passports/client_90225_passport.pdf	/docs/licenses/client_90225_license.pdf	\N	2025-09-16
30340	90147	/docs/passports/client_90147_passport.pdf	/docs/licenses/client_90147_license.pdf	\N	2025-09-16
30341	90210	/docs/passports/client_90210_passport.pdf	/docs/licenses/client_90210_license.pdf	\N	2025-09-16
30342	89997	/docs/passports/client_89997_passport.pdf	/docs/licenses/client_89997_license.pdf	\N	2025-09-16
30343	89969	/docs/passports/client_89969_passport.pdf	/docs/licenses/client_89969_license.pdf	\N	2025-09-16
30344	90304	/docs/passports/client_90304_passport.pdf	/docs/licenses/client_90304_license.pdf	\N	2025-09-16
30345	90109	/docs/passports/client_90109_passport.pdf	/docs/licenses/client_90109_license.pdf	\N	2025-09-16
30346	90042	/docs/passports/client_90042_passport.pdf	/docs/licenses/client_90042_license.pdf	/docs/additional/client_90042_additional.pdf	2025-09-16
30347	90023	/docs/passports/client_90023_passport.pdf	/docs/licenses/client_90023_license.pdf	\N	2025-09-16
30348	89869	/docs/passports/client_89869_passport.pdf	/docs/licenses/client_89869_license.pdf	\N	2025-09-16
30349	90289	/docs/passports/client_90289_passport.pdf	/docs/licenses/client_90289_license.pdf	\N	2025-09-16
30409	90073	/docs/passports/client_90073_passport.pdf	/docs/licenses/client_90073_license.pdf	\N	2025-09-16
30350	89912	/docs/passports/client_89912_passport.pdf	/docs/licenses/client_89912_license.pdf	/docs/additional/client_89912_additional.pdf	2025-09-16
30351	90171	/docs/passports/client_90171_passport.pdf	/docs/licenses/client_90171_license.pdf	\N	2025-09-16
30352	90302	/docs/passports/client_90302_passport.pdf	/docs/licenses/client_90302_license.pdf	\N	2025-09-16
30353	89925	/docs/passports/client_89925_passport.pdf	/docs/licenses/client_89925_license.pdf	\N	2025-09-16
30354	90126	/docs/passports/client_90126_passport.pdf	/docs/licenses/client_90126_license.pdf	\N	2025-09-16
30355	89986	/docs/passports/client_89986_passport.pdf	/docs/licenses/client_89986_license.pdf	\N	2025-09-16
30356	90146	/docs/passports/client_90146_passport.pdf	/docs/licenses/client_90146_license.pdf	/docs/additional/client_90146_additional.pdf	2025-09-16
30357	89973	/docs/passports/client_89973_passport.pdf	/docs/licenses/client_89973_license.pdf	\N	2025-09-16
30358	89873	/docs/passports/client_89873_passport.pdf	/docs/licenses/client_89873_license.pdf	\N	2025-09-16
30359	89979	/docs/passports/client_89979_passport.pdf	/docs/licenses/client_89979_license.pdf	/docs/additional/client_89979_additional.pdf	2025-09-16
30360	89954	/docs/passports/client_89954_passport.pdf	/docs/licenses/client_89954_license.pdf	\N	2025-09-16
30361	89966	/docs/passports/client_89966_passport.pdf	/docs/licenses/client_89966_license.pdf	\N	2025-09-16
30362	90282	/docs/passports/client_90282_passport.pdf	/docs/licenses/client_90282_license.pdf	\N	2025-09-16
30363	90256	/docs/passports/client_90256_passport.pdf	/docs/licenses/client_90256_license.pdf	\N	2025-09-16
30364	90079	/docs/passports/client_90079_passport.pdf	/docs/licenses/client_90079_license.pdf	/docs/additional/client_90079_additional.pdf	2025-09-16
30365	90306	/docs/passports/client_90306_passport.pdf	/docs/licenses/client_90306_license.pdf	\N	2025-09-16
30366	90298	/docs/passports/client_90298_passport.pdf	/docs/licenses/client_90298_license.pdf	\N	2025-09-16
30367	90242	/docs/passports/client_90242_passport.pdf	/docs/licenses/client_90242_license.pdf	\N	2025-09-16
30368	90133	/docs/passports/client_90133_passport.pdf	/docs/licenses/client_90133_license.pdf	/docs/additional/client_90133_additional.pdf	2025-09-16
30369	90249	/docs/passports/client_90249_passport.pdf	/docs/licenses/client_90249_license.pdf	\N	2025-09-16
30370	90261	/docs/passports/client_90261_passport.pdf	/docs/licenses/client_90261_license.pdf	\N	2025-09-16
30371	89932	/docs/passports/client_89932_passport.pdf	/docs/licenses/client_89932_license.pdf	\N	2025-09-16
30372	90223	/docs/passports/client_90223_passport.pdf	/docs/licenses/client_90223_license.pdf	\N	2025-09-16
30373	89911	/docs/passports/client_89911_passport.pdf	/docs/licenses/client_89911_license.pdf	\N	2025-09-16
30374	90247	/docs/passports/client_90247_passport.pdf	/docs/licenses/client_90247_license.pdf	/docs/additional/client_90247_additional.pdf	2025-09-16
30375	89917	/docs/passports/client_89917_passport.pdf	/docs/licenses/client_89917_license.pdf	\N	2025-09-16
30376	90175	/docs/passports/client_90175_passport.pdf	/docs/licenses/client_90175_license.pdf	\N	2025-09-16
30377	90102	/docs/passports/client_90102_passport.pdf	/docs/licenses/client_90102_license.pdf	\N	2025-09-16
30378	90218	/docs/passports/client_90218_passport.pdf	/docs/licenses/client_90218_license.pdf	/docs/additional/client_90218_additional.pdf	2025-09-16
30379	90140	/docs/passports/client_90140_passport.pdf	/docs/licenses/client_90140_license.pdf	/docs/additional/client_90140_additional.pdf	2025-09-16
30380	90030	/docs/passports/client_90030_passport.pdf	/docs/licenses/client_90030_license.pdf	\N	2025-09-16
30381	89913	/docs/passports/client_89913_passport.pdf	/docs/licenses/client_89913_license.pdf	/docs/additional/client_89913_additional.pdf	2025-09-16
30382	90307	/docs/passports/client_90307_passport.pdf	/docs/licenses/client_90307_license.pdf	/docs/additional/client_90307_additional.pdf	2025-09-16
30383	89947	/docs/passports/client_89947_passport.pdf	/docs/licenses/client_89947_license.pdf	\N	2025-09-16
30384	90107	/docs/passports/client_90107_passport.pdf	/docs/licenses/client_90107_license.pdf	/docs/additional/client_90107_additional.pdf	2025-09-16
30385	89922	/docs/passports/client_89922_passport.pdf	/docs/licenses/client_89922_license.pdf	\N	2025-09-16
30386	89861	/docs/passports/client_89861_passport.pdf	/docs/licenses/client_89861_license.pdf	\N	2025-09-16
30387	90120	/docs/passports/client_90120_passport.pdf	/docs/licenses/client_90120_license.pdf	/docs/additional/client_90120_additional.pdf	2025-09-16
30388	90086	/docs/passports/client_90086_passport.pdf	/docs/licenses/client_90086_license.pdf	\N	2025-09-16
30389	89880	/docs/passports/client_89880_passport.pdf	/docs/licenses/client_89880_license.pdf	\N	2025-09-16
30390	89998	/docs/passports/client_89998_passport.pdf	/docs/licenses/client_89998_license.pdf	\N	2025-09-16
30391	90113	/docs/passports/client_90113_passport.pdf	/docs/licenses/client_90113_license.pdf	\N	2025-09-16
30392	89895	/docs/passports/client_89895_passport.pdf	/docs/licenses/client_89895_license.pdf	\N	2025-09-16
30393	90193	/docs/passports/client_90193_passport.pdf	/docs/licenses/client_90193_license.pdf	\N	2025-09-16
30394	90092	/docs/passports/client_90092_passport.pdf	/docs/licenses/client_90092_license.pdf	/docs/additional/client_90092_additional.pdf	2025-09-16
30395	90179	/docs/passports/client_90179_passport.pdf	/docs/licenses/client_90179_license.pdf	\N	2025-09-16
30396	90104	/docs/passports/client_90104_passport.pdf	/docs/licenses/client_90104_license.pdf	\N	2025-09-16
30397	89872	/docs/passports/client_89872_passport.pdf	/docs/licenses/client_89872_license.pdf	/docs/additional/client_89872_additional.pdf	2025-09-16
30398	89898	/docs/passports/client_89898_passport.pdf	/docs/licenses/client_89898_license.pdf	/docs/additional/client_89898_additional.pdf	2025-09-16
30399	89826	/docs/passports/client_89826_passport.pdf	/docs/licenses/client_89826_license.pdf	\N	2025-09-16
30400	89916	/docs/passports/client_89916_passport.pdf	/docs/licenses/client_89916_license.pdf	\N	2025-09-16
30401	89857	/docs/passports/client_89857_passport.pdf	/docs/licenses/client_89857_license.pdf	\N	2025-09-16
30402	90136	/docs/passports/client_90136_passport.pdf	/docs/licenses/client_90136_license.pdf	\N	2025-09-16
30403	90005	/docs/passports/client_90005_passport.pdf	/docs/licenses/client_90005_license.pdf	\N	2025-09-16
30404	90281	/docs/passports/client_90281_passport.pdf	/docs/licenses/client_90281_license.pdf	/docs/additional/client_90281_additional.pdf	2025-09-16
30405	90231	/docs/passports/client_90231_passport.pdf	/docs/licenses/client_90231_license.pdf	\N	2025-09-16
30406	89856	/docs/passports/client_89856_passport.pdf	/docs/licenses/client_89856_license.pdf	\N	2025-09-16
30407	90285	/docs/passports/client_90285_passport.pdf	/docs/licenses/client_90285_license.pdf	/docs/additional/client_90285_additional.pdf	2025-09-16
30408	89983	/docs/passports/client_89983_passport.pdf	/docs/licenses/client_89983_license.pdf	\N	2025-09-16
30410	90154	/docs/passports/client_90154_passport.pdf	/docs/licenses/client_90154_license.pdf	\N	2025-09-16
30411	90267	/docs/passports/client_90267_passport.pdf	/docs/licenses/client_90267_license.pdf	\N	2025-09-16
30412	90033	/docs/passports/client_90033_passport.pdf	/docs/licenses/client_90033_license.pdf	/docs/additional/client_90033_additional.pdf	2025-09-16
30413	90270	/docs/passports/client_90270_passport.pdf	/docs/licenses/client_90270_license.pdf	\N	2025-09-16
30414	90007	/docs/passports/client_90007_passport.pdf	/docs/licenses/client_90007_license.pdf	\N	2025-09-16
30415	90149	/docs/passports/client_90149_passport.pdf	/docs/licenses/client_90149_license.pdf	\N	2025-09-16
30416	90207	/docs/passports/client_90207_passport.pdf	/docs/licenses/client_90207_license.pdf	\N	2025-09-16
30417	89875	/docs/passports/client_89875_passport.pdf	/docs/licenses/client_89875_license.pdf	/docs/additional/client_89875_additional.pdf	2025-09-16
30418	90019	/docs/passports/client_90019_passport.pdf	/docs/licenses/client_90019_license.pdf	\N	2025-09-16
30419	89961	/docs/passports/client_89961_passport.pdf	/docs/licenses/client_89961_license.pdf	/docs/additional/client_89961_additional.pdf	2025-09-16
30420	89867	/docs/passports/client_89867_passport.pdf	/docs/licenses/client_89867_license.pdf	\N	2025-09-16
30421	89923	/docs/passports/client_89923_passport.pdf	/docs/licenses/client_89923_license.pdf	/docs/additional/client_89923_additional.pdf	2025-09-16
30422	90131	/docs/passports/client_90131_passport.pdf	/docs/licenses/client_90131_license.pdf	\N	2025-09-16
30423	90226	/docs/passports/client_90226_passport.pdf	/docs/licenses/client_90226_license.pdf	\N	2025-09-16
30424	90093	/docs/passports/client_90093_passport.pdf	/docs/licenses/client_90093_license.pdf	\N	2025-09-16
30425	90308	/docs/passports/client_90308_passport.pdf	/docs/licenses/client_90308_license.pdf	\N	2025-09-16
30426	89950	/docs/passports/client_89950_passport.pdf	/docs/licenses/client_89950_license.pdf	\N	2025-09-16
30427	90057	/docs/passports/client_90057_passport.pdf	/docs/licenses/client_90057_license.pdf	\N	2025-09-16
30428	90286	/docs/passports/client_90286_passport.pdf	/docs/licenses/client_90286_license.pdf	\N	2025-09-16
30429	89985	/docs/passports/client_89985_passport.pdf	/docs/licenses/client_89985_license.pdf	\N	2025-09-16
30430	89939	/docs/passports/client_89939_passport.pdf	/docs/licenses/client_89939_license.pdf	\N	2025-09-16
30431	90145	/docs/passports/client_90145_passport.pdf	/docs/licenses/client_90145_license.pdf	/docs/additional/client_90145_additional.pdf	2025-09-16
30432	89852	/docs/passports/client_89852_passport.pdf	/docs/licenses/client_89852_license.pdf	\N	2025-09-16
30433	89905	/docs/passports/client_89905_passport.pdf	/docs/licenses/client_89905_license.pdf	\N	2025-09-16
30434	90029	/docs/passports/client_90029_passport.pdf	/docs/licenses/client_90029_license.pdf	\N	2025-09-16
30435	90319	/docs/passports/client_90319_passport.pdf	/docs/licenses/client_90319_license.pdf	\N	2025-09-16
30436	90089	/docs/passports/client_90089_passport.pdf	/docs/licenses/client_90089_license.pdf	\N	2025-09-16
30437	90103	/docs/passports/client_90103_passport.pdf	/docs/licenses/client_90103_license.pdf	/docs/additional/client_90103_additional.pdf	2025-09-16
30438	90108	/docs/passports/client_90108_passport.pdf	/docs/licenses/client_90108_license.pdf	\N	2025-09-16
30439	90159	/docs/passports/client_90159_passport.pdf	/docs/licenses/client_90159_license.pdf	\N	2025-09-16
30440	90081	/docs/passports/client_90081_passport.pdf	/docs/licenses/client_90081_license.pdf	/docs/additional/client_90081_additional.pdf	2025-09-16
30441	90199	/docs/passports/client_90199_passport.pdf	/docs/licenses/client_90199_license.pdf	\N	2025-09-16
30442	90185	/docs/passports/client_90185_passport.pdf	/docs/licenses/client_90185_license.pdf	\N	2025-09-16
30443	89883	/docs/passports/client_89883_passport.pdf	/docs/licenses/client_89883_license.pdf	/docs/additional/client_89883_additional.pdf	2025-09-16
30444	89920	/docs/passports/client_89920_passport.pdf	/docs/licenses/client_89920_license.pdf	\N	2025-09-16
30445	89977	/docs/passports/client_89977_passport.pdf	/docs/licenses/client_89977_license.pdf	\N	2025-09-16
30446	90130	/docs/passports/client_90130_passport.pdf	/docs/licenses/client_90130_license.pdf	/docs/additional/client_90130_additional.pdf	2025-09-16
30447	90311	/docs/passports/client_90311_passport.pdf	/docs/licenses/client_90311_license.pdf	\N	2025-09-16
30448	89944	/docs/passports/client_89944_passport.pdf	/docs/licenses/client_89944_license.pdf	/docs/additional/client_89944_additional.pdf	2025-09-16
30449	90006	/docs/passports/client_90006_passport.pdf	/docs/licenses/client_90006_license.pdf	\N	2025-09-16
30450	90241	/docs/passports/client_90241_passport.pdf	/docs/licenses/client_90241_license.pdf	\N	2025-09-16
30451	90123	/docs/passports/client_90123_passport.pdf	/docs/licenses/client_90123_license.pdf	/docs/additional/client_90123_additional.pdf	2025-09-16
30452	90106	/docs/passports/client_90106_passport.pdf	/docs/licenses/client_90106_license.pdf	/docs/additional/client_90106_additional.pdf	2025-09-16
30453	90139	/docs/passports/client_90139_passport.pdf	/docs/licenses/client_90139_license.pdf	/docs/additional/client_90139_additional.pdf	2025-09-16
30454	90096	/docs/passports/client_90096_passport.pdf	/docs/licenses/client_90096_license.pdf	\N	2025-09-16
30455	89839	/docs/passports/client_89839_passport.pdf	/docs/licenses/client_89839_license.pdf	\N	2025-09-16
30456	90022	/docs/passports/client_90022_passport.pdf	/docs/licenses/client_90022_license.pdf	\N	2025-09-16
30457	90002	/docs/passports/client_90002_passport.pdf	/docs/licenses/client_90002_license.pdf	/docs/additional/client_90002_additional.pdf	2025-09-16
30458	90219	/docs/passports/client_90219_passport.pdf	/docs/licenses/client_90219_license.pdf	\N	2025-09-16
30459	90035	/docs/passports/client_90035_passport.pdf	/docs/licenses/client_90035_license.pdf	\N	2025-09-16
30460	89896	/docs/passports/client_89896_passport.pdf	/docs/licenses/client_89896_license.pdf	\N	2025-09-16
30461	89835	/docs/passports/client_89835_passport.pdf	/docs/licenses/client_89835_license.pdf	\N	2025-09-16
30462	89949	/docs/passports/client_89949_passport.pdf	/docs/licenses/client_89949_license.pdf	\N	2025-09-16
30463	89945	/docs/passports/client_89945_passport.pdf	/docs/licenses/client_89945_license.pdf	\N	2025-09-16
30464	90027	/docs/passports/client_90027_passport.pdf	/docs/licenses/client_90027_license.pdf	\N	2025-09-16
30465	89975	/docs/passports/client_89975_passport.pdf	/docs/licenses/client_89975_license.pdf	/docs/additional/client_89975_additional.pdf	2025-09-16
30466	89864	/docs/passports/client_89864_passport.pdf	/docs/licenses/client_89864_license.pdf	/docs/additional/client_89864_additional.pdf	2025-09-16
30467	90315	/docs/passports/client_90315_passport.pdf	/docs/licenses/client_90315_license.pdf	/docs/additional/client_90315_additional.pdf	2025-09-16
30468	90196	/docs/passports/client_90196_passport.pdf	/docs/licenses/client_90196_license.pdf	\N	2025-09-16
30469	90271	/docs/passports/client_90271_passport.pdf	/docs/licenses/client_90271_license.pdf	\N	2025-09-16
30470	90229	/docs/passports/client_90229_passport.pdf	/docs/licenses/client_90229_license.pdf	/docs/additional/client_90229_additional.pdf	2025-09-16
30471	89936	/docs/passports/client_89936_passport.pdf	/docs/licenses/client_89936_license.pdf	/docs/additional/client_89936_additional.pdf	2025-09-16
30472	90183	/docs/passports/client_90183_passport.pdf	/docs/licenses/client_90183_license.pdf	/docs/additional/client_90183_additional.pdf	2025-09-16
30473	90237	/docs/passports/client_90237_passport.pdf	/docs/licenses/client_90237_license.pdf	\N	2025-09-16
30474	90036	/docs/passports/client_90036_passport.pdf	/docs/licenses/client_90036_license.pdf	/docs/additional/client_90036_additional.pdf	2025-09-16
30475	90209	/docs/passports/client_90209_passport.pdf	/docs/licenses/client_90209_license.pdf	/docs/additional/client_90209_additional.pdf	2025-09-16
30476	89940	/docs/passports/client_89940_passport.pdf	/docs/licenses/client_89940_license.pdf	\N	2025-09-16
30477	90087	/docs/passports/client_90087_passport.pdf	/docs/licenses/client_90087_license.pdf	\N	2025-09-16
30478	90055	/docs/passports/client_90055_passport.pdf	/docs/licenses/client_90055_license.pdf	/docs/additional/client_90055_additional.pdf	2025-09-16
30479	90001	/docs/passports/client_90001_passport.pdf	/docs/licenses/client_90001_license.pdf	\N	2025-09-16
30480	90078	/docs/passports/client_90078_passport.pdf	/docs/licenses/client_90078_license.pdf	\N	2025-09-16
30481	90246	/docs/passports/client_90246_passport.pdf	/docs/licenses/client_90246_license.pdf	\N	2025-09-16
30482	90049	/docs/passports/client_90049_passport.pdf	/docs/licenses/client_90049_license.pdf	\N	2025-09-16
30483	90152	/docs/passports/client_90152_passport.pdf	/docs/licenses/client_90152_license.pdf	\N	2025-09-16
30484	89885	/docs/passports/client_89885_passport.pdf	/docs/licenses/client_89885_license.pdf	/docs/additional/client_89885_additional.pdf	2025-09-16
30485	89976	/docs/passports/client_89976_passport.pdf	/docs/licenses/client_89976_license.pdf	/docs/additional/client_89976_additional.pdf	2025-09-16
30486	90182	/docs/passports/client_90182_passport.pdf	/docs/licenses/client_90182_license.pdf	/docs/additional/client_90182_additional.pdf	2025-09-16
30487	89900	/docs/passports/client_89900_passport.pdf	/docs/licenses/client_89900_license.pdf	\N	2025-09-16
30488	90026	/docs/passports/client_90026_passport.pdf	/docs/licenses/client_90026_license.pdf	/docs/additional/client_90026_additional.pdf	2025-09-16
30489	90192	/docs/passports/client_90192_passport.pdf	/docs/licenses/client_90192_license.pdf	/docs/additional/client_90192_additional.pdf	2025-09-16
30490	90312	/docs/passports/client_90312_passport.pdf	/docs/licenses/client_90312_license.pdf	\N	2025-09-16
30491	90255	/docs/passports/client_90255_passport.pdf	/docs/licenses/client_90255_license.pdf	\N	2025-09-16
30492	90200	/docs/passports/client_90200_passport.pdf	/docs/licenses/client_90200_license.pdf	\N	2025-09-16
30493	90164	/docs/passports/client_90164_passport.pdf	/docs/licenses/client_90164_license.pdf	\N	2025-09-16
30494	89967	/docs/passports/client_89967_passport.pdf	/docs/licenses/client_89967_license.pdf	\N	2025-09-16
30495	90151	/docs/passports/client_90151_passport.pdf	/docs/licenses/client_90151_license.pdf	\N	2025-09-16
30496	89838	/docs/passports/client_89838_passport.pdf	/docs/licenses/client_89838_license.pdf	/docs/additional/client_89838_additional.pdf	2025-09-16
30497	89991	/docs/passports/client_89991_passport.pdf	/docs/licenses/client_89991_license.pdf	\N	2025-09-16
30498	90243	/docs/passports/client_90243_passport.pdf	/docs/licenses/client_90243_license.pdf	\N	2025-09-16
30499	90144	/docs/passports/client_90144_passport.pdf	/docs/licenses/client_90144_license.pdf	\N	2025-09-16
30500	89965	/docs/passports/client_89965_passport.pdf	/docs/licenses/client_89965_license.pdf	/docs/additional/client_89965_additional.pdf	2025-09-16
30501	90316	/docs/passports/client_90316_passport.pdf	/docs/licenses/client_90316_license.pdf	\N	2025-09-16
30502	89892	/docs/passports/client_89892_passport.pdf	/docs/licenses/client_89892_license.pdf	\N	2025-09-16
30503	90169	/docs/passports/client_90169_passport.pdf	/docs/licenses/client_90169_license.pdf	\N	2025-09-16
30504	90321	/docs/passports/client_90321_passport.pdf	/docs/licenses/client_90321_license.pdf	\N	2025-09-16
30505	90114	/docs/passports/client_90114_passport.pdf	/docs/licenses/client_90114_license.pdf	\N	2025-09-16
30506	90134	/docs/passports/client_90134_passport.pdf	/docs/licenses/client_90134_license.pdf	\N	2025-09-16
30507	89851	/docs/passports/client_89851_passport.pdf	/docs/licenses/client_89851_license.pdf	/docs/additional/client_89851_additional.pdf	2025-09-16
30508	90320	/docs/passports/client_90320_passport.pdf	/docs/licenses/client_90320_license.pdf	\N	2025-09-16
30509	89970	/docs/passports/client_89970_passport.pdf	/docs/licenses/client_89970_license.pdf	\N	2025-09-16
30510	90268	/docs/passports/client_90268_passport.pdf	/docs/licenses/client_90268_license.pdf	/docs/additional/client_90268_additional.pdf	2025-09-16
30511	89956	/docs/passports/client_89956_passport.pdf	/docs/licenses/client_89956_license.pdf	/docs/additional/client_89956_additional.pdf	2025-09-16
30512	89933	/docs/passports/client_89933_passport.pdf	/docs/licenses/client_89933_license.pdf	/docs/additional/client_89933_additional.pdf	2025-09-16
30513	90283	/docs/passports/client_90283_passport.pdf	/docs/licenses/client_90283_license.pdf	/docs/additional/client_90283_additional.pdf	2025-09-16
30514	90060	/docs/passports/client_90060_passport.pdf	/docs/licenses/client_90060_license.pdf	\N	2025-09-16
30515	90101	/docs/passports/client_90101_passport.pdf	/docs/licenses/client_90101_license.pdf	\N	2025-09-16
30516	90137	/docs/passports/client_90137_passport.pdf	/docs/licenses/client_90137_license.pdf	\N	2025-09-16
30517	89980	/docs/passports/client_89980_passport.pdf	/docs/licenses/client_89980_license.pdf	\N	2025-09-16
30518	90004	/docs/passports/client_90004_passport.pdf	/docs/licenses/client_90004_license.pdf	/docs/additional/client_90004_additional.pdf	2025-09-16
30519	90112	/docs/passports/client_90112_passport.pdf	/docs/licenses/client_90112_license.pdf	/docs/additional/client_90112_additional.pdf	2025-09-16
30520	90252	/docs/passports/client_90252_passport.pdf	/docs/licenses/client_90252_license.pdf	/docs/additional/client_90252_additional.pdf	2025-09-16
30521	89968	/docs/passports/client_89968_passport.pdf	/docs/licenses/client_89968_license.pdf	\N	2025-09-16
30522	90227	/docs/passports/client_90227_passport.pdf	/docs/licenses/client_90227_license.pdf	\N	2025-09-16
30523	90165	/docs/passports/client_90165_passport.pdf	/docs/licenses/client_90165_license.pdf	\N	2025-09-16
30524	90290	/docs/passports/client_90290_passport.pdf	/docs/licenses/client_90290_license.pdf	/docs/additional/client_90290_additional.pdf	2025-09-16
30525	90284	/docs/passports/client_90284_passport.pdf	/docs/licenses/client_90284_license.pdf	\N	2025-09-16
30526	90082	/docs/passports/client_90082_passport.pdf	/docs/licenses/client_90082_license.pdf	\N	2025-09-16
\.


--
-- TOC entry 3669 (class 0 OID 18276)
-- Dependencies: 218
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.clients (client_id, first_name, last_name, phone, email, passport_series, passport_number, registration_date, birth_date) FROM stdin;
89825	Алексей	Иванов	+7-977-370-60-81	алексей.иванов1@email.ru	4560	210171	2025-09-16	1962-11-17
89826	Татьяна	Иванов	+7-908-521-58-48	татьяна.иванов2@email.ru	4574	973304	2025-09-16	1995-06-17
89827	Дмитрий	Смирнов	+7-990-313-59-96	дмитрий.смирнов3@email.ru	4510	792779	2025-09-16	2005-01-01
89828	Ольга	Волков	+7-943-757-73-69	ольга.волков4@email.ru	4513	468002	2025-09-16	1989-10-31
89829	Ирина	Фёдоров	+7-956-131-94-92	ирина.фёдоров5@email.ru	4561	771809	2025-09-16	1981-08-08
89830	Ольга	Петров	+7-912-913-43-91	ольга.петров6@email.ru	4555	682667	2025-09-16	1975-05-04
89831	Михаил	Кузнецов	+7-957-777-63-73	михаил.кузнецов7@email.ru	4534	125317	2025-09-16	1973-05-02
89832	Елена	Попов	+7-917-971-43-33	елена.попов8@email.ru	4580	763364	2025-09-16	1971-06-23
89833	Ирина	Иванов	+7-910-384-62-25	ирина.иванов9@email.ru	4577	751153	2025-09-16	1998-06-27
89834	Ольга	Соколов	+7-940-609-25-28	ольга.соколов10@email.ru	4524	306634	2025-09-16	2000-05-28
89835	Михаил	Фёдоров	+7-958-839-82-66	михаил.фёдоров11@email.ru	4574	626681	2025-09-16	1981-03-15
89836	Елена	Петров	+7-938-225-71-85	елена.петров12@email.ru	4523	859163	2025-09-16	1982-07-24
89837	Анна	Иванов	+7-935-194-72-68	анна.иванов13@email.ru	4528	852516	2025-09-16	1992-10-31
89838	Александр	Михайлов	+7-986-653-11-58	александр.михайлов14@email.ru	4568	970347	2025-09-16	1968-05-27
89839	Ирина	Сидоров	+7-991-124-73-85	ирина.сидоров15@email.ru	4547	201636	2025-09-16	1998-10-27
89840	Сергей	Петров	+7-987-420-25-11	сергей.петров16@email.ru	4565	851764	2025-09-16	1966-08-20
89841	Владимир	Фёдоров	+7-969-738-53-61	владимир.фёдоров17@email.ru	4596	476419	2025-09-16	1995-07-23
89842	Александр	Лебедев	+7-981-286-14-17	александр.лебедев18@email.ru	4575	764087	2025-09-16	2004-12-07
89843	Игорь	Новиков	+7-943-824-61-96	игорь.новиков19@email.ru	4513	316372	2025-09-16	2003-09-09
89844	Михаил	Лебедев	+7-908-903-63-28	михаил.лебедев20@email.ru	4582	933054	2025-09-16	1979-08-27
89845	Татьяна	Волков	+7-905-142-31-47	татьяна.волков21@email.ru	4559	719233	2025-09-16	1999-09-27
89846	Наталья	Попов	+7-994-775-36-19	наталья.попов22@email.ru	4568	950444	2025-09-16	1985-07-09
89847	Алексей	Петров	+7-964-488-47-69	алексей.петров23@email.ru	4576	823402	2025-09-16	1986-05-09
89848	Сергей	Фёдоров	+7-977-684-77-40	сергей.фёдоров24@email.ru	4520	345849	2025-09-16	2000-07-24
89849	Сергей	Морозов	+7-925-163-18-84	сергей.морозов25@email.ru	4560	906690	2025-09-16	1957-01-20
89850	Марина	Морозов	+7-920-705-75-50	марина.морозов26@email.ru	4595	659520	2025-09-16	1979-02-01
89851	Сергей	Новиков	+7-947-925-44-29	сергей.новиков27@email.ru	4532	672608	2025-09-16	1957-12-30
89852	Алексей	Смирнов	+7-937-946-72-57	алексей.смирнов28@email.ru	4550	152779	2025-09-16	1959-05-12
89853	Михаил	Сидоров	+7-934-670-93-21	михаил.сидоров29@email.ru	4530	560651	2025-09-16	1996-05-06
89854	Игорь	Попов	+7-938-710-25-21	игорь.попов30@email.ru	4532	487805	2025-09-16	1972-02-10
89855	Татьяна	Смирнов	+7-944-230-83-88	татьяна.смирнов31@email.ru	4597	814364	2025-09-16	1983-11-17
89856	Сергей	Смирнов	+7-922-623-91-30	сергей.смирнов32@email.ru	4557	162391	2025-09-16	1992-08-18
89857	Михаил	Волков	+7-974-851-11-66	михаил.волков33@email.ru	4557	204012	2025-09-16	1970-06-10
89858	Ольга	Иванов	+7-926-522-53-63	ольга.иванов34@email.ru	4555	160145	2025-09-16	1994-06-11
89859	Ирина	Смирнов	+7-983-933-41-54	ирина.смирнов35@email.ru	4571	348143	2025-09-16	1962-10-18
89860	Михаил	Козлов	+7-987-356-58-18	михаил.козлов36@email.ru	4550	414245	2025-09-16	1965-01-19
89861	Алексей	Сидоров	+7-997-788-31-68	алексей.сидоров37@email.ru	4570	779911	2025-09-16	1999-04-10
89862	Наталья	Волков	+7-982-204-78-23	наталья.волков38@email.ru	4556	231751	2025-09-16	1970-09-27
89863	Сергей	Попов	+7-908-183-63-48	сергей.попов39@email.ru	4564	651800	2025-09-16	1959-06-29
89864	Анна	Соколов	+7-984-796-72-82	анна.соколов40@email.ru	4539	677459	2025-09-16	1973-06-14
89865	Игорь	Фёдоров	+7-958-955-97-58	игорь.фёдоров41@email.ru	4512	937345	2025-09-16	1995-01-21
89866	Игорь	Козлов	+7-986-282-16-59	игорь.козлов42@email.ru	4554	689042	2025-09-16	1962-01-25
89867	Игорь	Соколов	+7-949-381-77-59	игорь.соколов43@email.ru	4509	998686	2025-09-16	1983-01-22
89868	Владимир	Соколов	+7-917-843-90-61	владимир.соколов44@email.ru	4566	907869	2025-09-16	2001-02-28
89869	Наталья	Фёдоров	+7-934-936-36-78	наталья.фёдоров45@email.ru	4502	396729	2025-09-16	1963-11-13
89870	Алексей	Морозов	+7-967-196-31-57	алексей.морозов46@email.ru	4532	884871	2025-09-16	1964-05-26
89871	Владимир	Петров	+7-972-190-91-57	владимир.петров47@email.ru	4593	578826	2025-09-16	1988-03-20
89872	Марина	Смирнов	+7-967-576-19-69	марина.смирнов48@email.ru	4593	962704	2025-09-16	1975-06-08
89873	Марина	Михайлов	+7-913-899-31-48	марина.михайлов49@email.ru	4544	758774	2025-09-16	1996-01-05
89874	Александр	Фёдоров	+7-919-990-19-92	александр.фёдоров50@email.ru	4568	252647	2025-09-16	1989-01-10
89875	Анна	Смирнов	+7-903-403-67-64	анна.смирнов51@email.ru	4582	158808	2025-09-16	1995-12-21
89876	Игорь	Соколов	+7-999-609-84-65	игорь.соколов52@email.ru	4543	664015	2025-09-16	1964-04-11
89877	Татьяна	Иванов	+7-967-557-99-67	татьяна.иванов53@email.ru	4549	401754	2025-09-16	1997-05-16
89878	Ирина	Соколов	+7-925-461-50-83	ирина.соколов54@email.ru	4583	979944	2025-09-16	1976-06-25
89879	Дмитрий	Новиков	+7-955-153-80-43	дмитрий.новиков55@email.ru	4550	136437	2025-09-16	1965-10-14
89880	Алексей	Соколов	+7-903-848-44-92	алексей.соколов56@email.ru	4550	892287	2025-09-16	1976-07-05
89881	Наталья	Петров	+7-947-666-43-73	наталья.петров57@email.ru	4599	771244	2025-09-16	1990-06-03
89882	Марина	Козлов	+7-998-966-50-80	марина.козлов58@email.ru	4519	730968	2025-09-16	1985-11-25
89883	Владимир	Волков	+7-955-597-85-87	владимир.волков59@email.ru	4509	287801	2025-09-16	1976-11-12
89884	Татьяна	Кузнецов	+7-971-172-16-84	татьяна.кузнецов60@email.ru	4599	184268	2025-09-16	2003-10-18
89885	Ирина	Морозов	+7-962-951-51-77	ирина.морозов61@email.ru	4565	653669	2025-09-16	1971-08-28
89886	Анна	Петров	+7-939-847-19-29	анна.петров62@email.ru	4588	798908	2025-09-16	1990-03-25
89887	Владимир	Михайлов	+7-981-941-82-19	владимир.михайлов63@email.ru	4595	853349	2025-09-16	1978-03-09
89888	Алексей	Иванов	+7-941-835-33-43	алексей.иванов64@email.ru	4567	981702	2025-09-16	2001-04-24
89889	Дмитрий	Фёдоров	+7-991-916-35-86	дмитрий.фёдоров65@email.ru	4571	911855	2025-09-16	2004-07-09
89890	Дмитрий	Волков	+7-977-840-85-10	дмитрий.волков66@email.ru	4514	258495	2025-09-16	1977-09-30
89891	Дмитрий	Фёдоров	+7-999-770-39-32	дмитрий.фёдоров67@email.ru	4590	614020	2025-09-16	1975-05-23
89892	Сергей	Новиков	+7-929-574-64-59	сергей.новиков68@email.ru	4552	426505	2025-09-16	1966-09-14
89893	Наталья	Михайлов	+7-927-133-88-23	наталья.михайлов69@email.ru	4525	476335	2025-09-16	1995-08-25
89894	Михаил	Морозов	+7-933-112-42-13	михаил.морозов70@email.ru	4517	348586	2025-09-16	2006-10-30
89895	Татьяна	Иванов	+7-962-275-94-80	татьяна.иванов71@email.ru	4567	746010	2025-09-16	1985-11-11
89896	Анна	Новиков	+7-907-104-42-22	анна.новиков72@email.ru	4530	948211	2025-09-16	2004-04-25
89897	Наталья	Сидоров	+7-968-974-14-72	наталья.сидоров73@email.ru	4507	834092	2025-09-16	1969-06-29
89898	Александр	Петров	+7-905-991-27-83	александр.петров74@email.ru	4570	629236	2025-09-16	1966-04-30
89899	Дмитрий	Михайлов	+7-919-567-48-19	дмитрий.михайлов75@email.ru	4595	852959	2025-09-16	1962-08-17
89900	Александр	Петров	+7-927-687-28-70	александр.петров76@email.ru	4574	316227	2025-09-16	2004-09-10
89901	Игорь	Михайлов	+7-972-686-70-82	игорь.михайлов77@email.ru	4580	656400	2025-09-16	1971-10-06
89902	Игорь	Иванов	+7-914-184-92-77	игорь.иванов78@email.ru	4568	814483	2025-09-16	2002-03-08
89903	Марина	Кузнецов	+7-987-892-19-10	марина.кузнецов79@email.ru	4533	640127	2025-09-16	1985-05-24
89904	Ольга	Морозов	+7-934-831-41-87	ольга.морозов80@email.ru	4514	472802	2025-09-16	2005-10-25
89905	Ольга	Волков	+7-985-543-89-73	ольга.волков81@email.ru	4522	136598	2025-09-16	1981-08-24
89906	Татьяна	Иванов	+7-937-340-72-90	татьяна.иванов82@email.ru	4538	256524	2025-09-16	1977-04-02
89907	Татьяна	Попов	+7-919-316-42-68	татьяна.попов83@email.ru	4572	739992	2025-09-16	1995-12-26
89908	Анна	Фёдоров	+7-997-837-49-40	анна.фёдоров84@email.ru	4517	566913	2025-09-16	1993-12-31
89909	Александр	Попов	+7-964-947-52-51	александр.попов85@email.ru	4545	316438	2025-09-16	1970-07-19
89910	Наталья	Петров	+7-918-781-28-22	наталья.петров86@email.ru	4543	704455	2025-09-16	1988-08-22
89911	Татьяна	Иванов	+7-967-883-84-60	татьяна.иванов87@email.ru	4516	308270	2025-09-16	1975-10-14
89912	Игорь	Попов	+7-950-589-55-64	игорь.попов88@email.ru	4576	272218	2025-09-16	1983-09-02
89913	Елена	Сидоров	+7-972-176-96-96	елена.сидоров89@email.ru	4589	754855	2025-09-16	1981-12-25
89914	Елена	Козлов	+7-991-257-38-84	елена.козлов90@email.ru	4533	148640	2025-09-16	1959-08-10
89915	Дмитрий	Смирнов	+7-942-185-20-80	дмитрий.смирнов91@email.ru	4547	970231	2025-09-16	1964-01-21
89916	Алексей	Сидоров	+7-944-341-57-36	алексей.сидоров92@email.ru	4511	960335	2025-09-16	1982-11-21
89917	Владимир	Иванов	+7-918-322-51-66	владимир.иванов93@email.ru	4588	169281	2025-09-16	1969-08-01
89918	Марина	Соколов	+7-962-916-25-68	марина.соколов94@email.ru	4536	196935	2025-09-16	1986-10-09
89919	Марина	Лебедев	+7-928-537-77-82	марина.лебедев95@email.ru	4597	535962	2025-09-16	1986-03-20
89920	Татьяна	Иванов	+7-901-250-92-16	татьяна.иванов96@email.ru	4536	728899	2025-09-16	2002-11-23
89921	Михаил	Михайлов	+7-901-647-13-59	михаил.михайлов97@email.ru	4552	441920	2025-09-16	1997-07-10
89922	Ольга	Лебедев	+7-909-633-57-71	ольга.лебедев98@email.ru	4590	559652	2025-09-16	1989-07-14
89923	Ольга	Новиков	+7-952-755-47-58	ольга.новиков99@email.ru	4506	143570	2025-09-16	1961-01-04
89924	Ирина	Волков	+7-991-406-71-79	ирина.волков100@email.ru	4573	399890	2025-09-16	1957-01-08
89925	Александр	Козлов	+7-964-709-64-72	александр.козлов101@email.ru	4596	910443	2025-09-16	1979-12-11
89926	Алексей	Соколов	+7-921-512-64-17	алексей.соколов102@email.ru	4564	925125	2025-09-16	2000-11-12
89927	Владимир	Иванов	+7-902-935-46-27	владимир.иванов103@email.ru	4573	146853	2025-09-16	1962-09-13
89928	Анна	Смирнов	+7-937-459-82-38	анна.смирнов104@email.ru	4567	376009	2025-09-16	1968-07-17
89929	Владимир	Михайлов	+7-989-593-29-54	владимир.михайлов105@email.ru	4562	419686	2025-09-16	1970-01-12
89930	Владимир	Кузнецов	+7-923-313-17-18	владимир.кузнецов106@email.ru	4525	316112	2025-09-16	1995-04-13
89931	Анна	Михайлов	+7-907-587-63-85	анна.михайлов107@email.ru	4509	188195	2025-09-16	1956-02-02
89932	Владимир	Попов	+7-961-114-49-59	владимир.попов108@email.ru	4525	999618	2025-09-16	1987-04-06
89933	Марина	Соколов	+7-965-348-33-92	марина.соколов109@email.ru	4577	630083	2025-09-16	1965-03-11
89934	Сергей	Морозов	+7-974-899-67-43	сергей.морозов110@email.ru	4533	628401	2025-09-16	1981-01-10
89935	Ольга	Смирнов	+7-928-835-29-35	ольга.смирнов111@email.ru	4517	168063	2025-09-16	1963-01-02
89936	Елена	Соколов	+7-958-428-12-12	елена.соколов112@email.ru	4557	251653	2025-09-16	2005-10-18
89937	Александр	Морозов	+7-916-913-15-29	александр.морозов113@email.ru	4514	487263	2025-09-16	2005-03-07
89938	Татьяна	Козлов	+7-988-723-98-40	татьяна.козлов114@email.ru	4519	421187	2025-09-16	1999-08-05
89939	Ирина	Соколов	+7-956-815-66-73	ирина.соколов115@email.ru	4580	525963	2025-09-16	1969-03-09
89940	Ирина	Новиков	+7-906-841-84-37	ирина.новиков116@email.ru	4548	590643	2025-09-16	1957-05-01
89941	Елена	Козлов	+7-920-988-84-32	елена.козлов117@email.ru	4532	509296	2025-09-16	1975-09-09
89942	Татьяна	Попов	+7-926-218-30-76	татьяна.попов118@email.ru	4506	390787	2025-09-16	1992-03-11
89943	Алексей	Иванов	+7-970-979-60-63	алексей.иванов119@email.ru	4535	605028	2025-09-16	1974-10-23
89944	Игорь	Новиков	+7-931-685-32-97	игорь.новиков120@email.ru	4533	782674	2025-09-16	1985-06-19
89945	Елена	Сидоров	+7-936-217-60-89	елена.сидоров121@email.ru	4546	665651	2025-09-16	1975-09-08
89946	Ольга	Лебедев	+7-934-376-75-98	ольга.лебедев122@email.ru	4566	102097	2025-09-16	1971-09-12
89947	Анна	Петров	+7-967-931-56-73	анна.петров123@email.ru	4530	577712	2025-09-16	1960-12-22
89948	Михаил	Новиков	+7-994-942-27-66	михаил.новиков124@email.ru	4554	254120	2025-09-16	1957-05-04
89949	Игорь	Иванов	+7-987-188-99-23	игорь.иванов125@email.ru	4529	766633	2025-09-16	2006-10-24
89950	Анна	Лебедев	+7-927-432-38-76	анна.лебедев126@email.ru	4568	762843	2025-09-16	1958-10-18
89951	Елена	Кузнецов	+7-958-310-46-37	елена.кузнецов127@email.ru	4592	244103	2025-09-16	1963-06-18
89952	Михаил	Попов	+7-983-817-75-40	михаил.попов128@email.ru	4556	235752	2025-09-16	1993-12-27
89953	Анна	Морозов	+7-916-738-41-55	анна.морозов129@email.ru	4595	909445	2025-09-16	1971-05-26
89954	Ольга	Новиков	+7-934-785-51-52	ольга.новиков130@email.ru	4503	533537	2025-09-16	1981-01-12
89955	Михаил	Смирнов	+7-934-370-81-13	михаил.смирнов131@email.ru	4517	977122	2025-09-16	1999-10-30
89956	Игорь	Сидоров	+7-929-398-88-43	игорь.сидоров132@email.ru	4595	540281	2025-09-16	1959-10-07
89957	Алексей	Новиков	+7-972-626-47-14	алексей.новиков133@email.ru	4519	166084	2025-09-16	1976-01-20
89958	Елена	Сидоров	+7-918-180-27-93	елена.сидоров134@email.ru	4573	554881	2025-09-16	1986-11-10
89959	Ирина	Козлов	+7-927-822-11-26	ирина.козлов135@email.ru	4551	850100	2025-09-16	1962-07-18
89960	Елена	Новиков	+7-919-753-27-41	елена.новиков136@email.ru	4565	388385	2025-09-16	1980-07-09
89961	Ольга	Петров	+7-965-146-86-71	ольга.петров137@email.ru	4557	302037	2025-09-16	1974-05-25
89962	Татьяна	Кузнецов	+7-942-341-38-78	татьяна.кузнецов138@email.ru	4522	444237	2025-09-16	1956-01-01
89963	Марина	Козлов	+7-982-732-92-59	марина.козлов139@email.ru	4532	886058	2025-09-16	2003-01-28
89964	Сергей	Фёдоров	+7-903-565-94-88	сергей.фёдоров140@email.ru	4532	150669	2025-09-16	1965-08-18
89965	Дмитрий	Козлов	+7-914-616-50-78	дмитрий.козлов141@email.ru	4595	492693	2025-09-16	1966-11-11
89966	Ольга	Петров	+7-998-495-47-71	ольга.петров142@email.ru	4564	244571	2025-09-16	1965-03-10
89967	Александр	Иванов	+7-951-749-84-30	александр.иванов143@email.ru	4586	311592	2025-09-16	1994-12-14
89968	Елена	Козлов	+7-907-116-26-70	елена.козлов144@email.ru	4588	480322	2025-09-16	1981-06-24
89969	Ольга	Фёдоров	+7-985-250-84-15	ольга.фёдоров145@email.ru	4554	855561	2025-09-16	1979-02-11
89970	Алексей	Петров	+7-977-398-71-22	алексей.петров146@email.ru	4533	701929	2025-09-16	1997-09-13
89971	Ольга	Кузнецов	+7-942-599-59-94	ольга.кузнецов147@email.ru	4505	102013	2025-09-16	2004-09-16
89972	Татьяна	Лебедев	+7-936-333-79-12	татьяна.лебедев148@email.ru	4525	402488	2025-09-16	2005-12-30
89973	Александр	Соколов	+7-993-318-40-71	александр.соколов149@email.ru	4569	972357	2025-09-16	1970-03-15
89974	Михаил	Попов	+7-959-274-13-59	михаил.попов150@email.ru	4517	975881	2025-09-16	2005-12-11
89975	Анна	Михайлов	+7-970-326-78-97	анна.михайлов151@email.ru	4589	661038	2025-09-16	1966-09-24
89976	Татьяна	Попов	+7-971-971-41-85	татьяна.попов152@email.ru	4591	639872	2025-09-16	1990-04-26
89977	Михаил	Морозов	+7-944-633-44-14	михаил.морозов153@email.ru	4523	951042	2025-09-16	1966-01-17
89978	Игорь	Морозов	+7-923-644-18-64	игорь.морозов154@email.ru	4531	879617	2025-09-16	1987-10-27
89979	Дмитрий	Лебедев	+7-983-413-13-57	дмитрий.лебедев155@email.ru	4590	657063	2025-09-16	1967-04-18
89980	Игорь	Петров	+7-968-806-91-93	игорь.петров156@email.ru	4569	110395	2025-09-16	1982-05-22
89981	Дмитрий	Кузнецов	+7-925-743-79-73	дмитрий.кузнецов157@email.ru	4509	758289	2025-09-16	2006-04-05
89982	Ольга	Козлов	+7-933-408-46-24	ольга.козлов158@email.ru	4596	463745	2025-09-16	2001-11-12
89983	Владимир	Петров	+7-937-698-23-49	владимир.петров159@email.ru	4527	532339	2025-09-16	1983-05-09
89984	Алексей	Лебедев	+7-993-954-13-98	алексей.лебедев160@email.ru	4560	476154	2025-09-16	1993-02-02
89985	Игорь	Иванов	+7-973-454-42-38	игорь.иванов161@email.ru	4570	257154	2025-09-16	1973-07-25
89986	Елена	Михайлов	+7-995-923-72-15	елена.михайлов162@email.ru	4508	873814	2025-09-16	1970-02-16
89987	Александр	Лебедев	+7-968-242-79-17	александр.лебедев163@email.ru	4561	927371	2025-09-16	1994-10-08
89988	Татьяна	Иванов	+7-945-894-35-53	татьяна.иванов164@email.ru	4564	433804	2025-09-16	1957-10-23
89989	Анна	Соколов	+7-923-541-31-26	анна.соколов165@email.ru	4533	191469	2025-09-16	1956-12-03
89990	Дмитрий	Михайлов	+7-979-543-42-87	дмитрий.михайлов166@email.ru	4531	978595	2025-09-16	2002-01-08
89991	Ольга	Соколов	+7-937-334-90-21	ольга.соколов167@email.ru	4502	383077	2025-09-16	1967-01-06
89992	Сергей	Петров	+7-992-838-89-56	сергей.петров168@email.ru	4573	718790	2025-09-16	1971-10-31
89993	Алексей	Соколов	+7-932-155-41-83	алексей.соколов169@email.ru	4533	520201	2025-09-16	1991-05-19
89994	Михаил	Козлов	+7-954-335-85-18	михаил.козлов170@email.ru	4591	410871	2025-09-16	1975-02-28
89995	Наталья	Петров	+7-964-332-44-63	наталья.петров171@email.ru	4524	348386	2025-09-16	1973-03-16
89996	Сергей	Михайлов	+7-962-994-65-36	сергей.михайлов172@email.ru	4524	229436	2025-09-16	2001-10-31
89997	Марина	Лебедев	+7-947-648-79-49	марина.лебедев173@email.ru	4510	330028	2025-09-16	1985-07-05
89998	Дмитрий	Лебедев	+7-945-411-13-63	дмитрий.лебедев174@email.ru	4568	698334	2025-09-16	1963-01-17
89999	Игорь	Фёдоров	+7-976-539-25-14	игорь.фёдоров175@email.ru	4585	148946	2025-09-16	1973-04-18
90000	Анна	Смирнов	+7-934-233-82-60	анна.смирнов176@email.ru	4565	764235	2025-09-16	1981-10-01
90001	Александр	Козлов	+7-931-643-60-17	александр.козлов177@email.ru	4578	685896	2025-09-16	2007-03-01
90002	Марина	Новиков	+7-915-496-88-87	марина.новиков178@email.ru	4532	816397	2025-09-16	1958-08-15
90003	Алексей	Кузнецов	+7-936-867-74-43	алексей.кузнецов179@email.ru	4553	758250	2025-09-16	1994-06-20
90004	Михаил	Фёдоров	+7-986-691-33-38	михаил.фёдоров180@email.ru	4566	423424	2025-09-16	2001-09-11
90005	Игорь	Лебедев	+7-907-826-53-83	игорь.лебедев181@email.ru	4503	779266	2025-09-16	1989-03-14
90006	Анна	Попов	+7-944-818-72-85	анна.попов182@email.ru	4535	775309	2025-09-16	1962-11-22
90007	Наталья	Иванов	+7-919-575-94-55	наталья.иванов183@email.ru	4596	479378	2025-09-16	2002-03-05
90008	Михаил	Смирнов	+7-935-753-45-35	михаил.смирнов184@email.ru	4552	388113	2025-09-16	1980-04-21
90009	Алексей	Фёдоров	+7-957-566-85-27	алексей.фёдоров185@email.ru	4553	928247	2025-09-16	1977-04-28
90010	Игорь	Иванов	+7-907-475-45-75	игорь.иванов186@email.ru	4506	684936	2025-09-16	1998-11-19
90011	Михаил	Смирнов	+7-924-855-42-63	михаил.смирнов187@email.ru	4500	249963	2025-09-16	1985-06-12
90012	Марина	Новиков	+7-926-989-21-10	марина.новиков188@email.ru	4562	581482	2025-09-16	1963-10-21
90013	Ольга	Волков	+7-974-786-81-33	ольга.волков189@email.ru	4535	740691	2025-09-16	1993-07-08
90014	Марина	Смирнов	+7-996-323-64-91	марина.смирнов190@email.ru	4546	171452	2025-09-16	1964-08-27
90015	Елена	Соколов	+7-976-947-63-55	елена.соколов191@email.ru	4536	667660	2025-09-16	2003-02-05
90016	Владимир	Лебедев	+7-964-489-49-28	владимир.лебедев192@email.ru	4546	573450	2025-09-16	1986-05-04
90017	Сергей	Козлов	+7-921-328-28-82	сергей.козлов193@email.ru	4572	833853	2025-09-16	1989-04-14
90018	Владимир	Новиков	+7-988-908-20-37	владимир.новиков194@email.ru	4595	888034	2025-09-16	1961-10-08
90019	Наталья	Волков	+7-945-512-69-15	наталья.волков195@email.ru	4537	224137	2025-09-16	1996-02-27
90020	Дмитрий	Волков	+7-992-551-21-71	дмитрий.волков196@email.ru	4500	311938	2025-09-16	1995-06-26
90021	Ольга	Новиков	+7-928-826-13-86	ольга.новиков197@email.ru	4527	506090	2025-09-16	1988-01-11
90022	Дмитрий	Кузнецов	+7-998-916-50-84	дмитрий.кузнецов198@email.ru	4511	221314	2025-09-16	1965-07-20
90023	Михаил	Морозов	+7-907-215-15-86	михаил.морозов199@email.ru	4595	281589	2025-09-16	1977-04-09
90024	Дмитрий	Фёдоров	+7-988-539-63-66	дмитрий.фёдоров200@email.ru	4578	536788	2025-09-16	2004-02-27
90025	Александр	Сидоров	+7-935-218-39-81	александр.сидоров201@email.ru	4576	742712	2025-09-16	1966-05-06
90026	Владимир	Петров	+7-920-932-67-33	владимир.петров202@email.ru	4575	427645	2025-09-16	1972-12-21
90027	Татьяна	Смирнов	+7-930-201-87-61	татьяна.смирнов203@email.ru	4574	891716	2025-09-16	1960-07-26
90028	Анна	Сидоров	+7-999-722-91-19	анна.сидоров204@email.ru	4519	807113	2025-09-16	1975-07-28
90029	Александр	Попов	+7-980-875-92-32	александр.попов205@email.ru	4508	381163	2025-09-16	1962-08-06
90030	Елена	Фёдоров	+7-927-250-32-40	елена.фёдоров206@email.ru	4512	317735	2025-09-16	2002-09-27
90031	Наталья	Иванов	+7-951-461-61-46	наталья.иванов207@email.ru	4586	878413	2025-09-16	1978-06-15
90032	Марина	Соколов	+7-949-869-39-96	марина.соколов208@email.ru	4512	872256	2025-09-16	1996-02-01
90033	Марина	Кузнецов	+7-915-441-55-62	марина.кузнецов209@email.ru	4530	284056	2025-09-16	1966-05-26
90034	Анна	Попов	+7-930-755-86-49	анна.попов210@email.ru	4583	329571	2025-09-16	1975-10-21
90035	Дмитрий	Фёдоров	+7-927-568-93-72	дмитрий.фёдоров211@email.ru	4559	753698	2025-09-16	1965-01-24
90036	Марина	Иванов	+7-946-275-27-67	марина.иванов212@email.ru	4551	723306	2025-09-16	2005-05-26
90037	Дмитрий	Кузнецов	+7-996-630-15-53	дмитрий.кузнецов213@email.ru	4524	589334	2025-09-16	1978-12-21
90038	Марина	Кузнецов	+7-918-810-28-75	марина.кузнецов214@email.ru	4517	266740	2025-09-16	2003-11-07
90039	Наталья	Волков	+7-945-924-34-15	наталья.волков215@email.ru	4521	743010	2025-09-16	1975-12-14
90040	Алексей	Иванов	+7-931-318-94-70	алексей.иванов216@email.ru	4530	336054	2025-09-16	2005-03-08
90041	Владимир	Новиков	+7-998-809-33-35	владимир.новиков217@email.ru	4536	853077	2025-09-16	2005-09-09
90042	Ирина	Иванов	+7-982-277-22-36	ирина.иванов218@email.ru	4554	136145	2025-09-16	1982-01-10
90043	Александр	Петров	+7-937-558-87-31	александр.петров219@email.ru	4561	252203	2025-09-16	1972-12-06
90044	Владимир	Волков	+7-954-365-56-27	владимир.волков220@email.ru	4594	654719	2025-09-16	1962-03-11
90045	Игорь	Смирнов	+7-994-663-55-79	игорь.смирнов221@email.ru	4527	382091	2025-09-16	1958-12-26
90046	Анна	Лебедев	+7-946-401-12-34	анна.лебедев222@email.ru	4570	983162	2025-09-16	1965-11-23
90047	Марина	Петров	+7-914-672-65-62	марина.петров223@email.ru	4590	509951	2025-09-16	1999-12-30
90048	Владимир	Новиков	+7-909-455-77-68	владимир.новиков224@email.ru	4555	974583	2025-09-16	1988-09-24
90049	Елена	Михайлов	+7-993-406-16-13	елена.михайлов225@email.ru	4530	640961	2025-09-16	1979-09-01
90050	Дмитрий	Сидоров	+7-975-496-50-98	дмитрий.сидоров226@email.ru	4584	868620	2025-09-16	1957-11-06
90051	Елена	Иванов	+7-939-735-74-74	елена.иванов227@email.ru	4537	883108	2025-09-16	1973-12-19
90052	Сергей	Волков	+7-990-373-91-80	сергей.волков228@email.ru	4507	228052	2025-09-16	1976-05-25
90053	Владимир	Иванов	+7-932-396-33-45	владимир.иванов229@email.ru	4585	928690	2025-09-16	1975-07-18
90054	Алексей	Лебедев	+7-938-752-78-88	алексей.лебедев230@email.ru	4582	295083	2025-09-16	1977-07-30
90055	Анна	Морозов	+7-992-658-90-62	анна.морозов231@email.ru	4564	685820	2025-09-16	1997-05-09
90056	Алексей	Морозов	+7-997-955-76-11	алексей.морозов232@email.ru	4591	676434	2025-09-16	1958-06-10
90057	Александр	Новиков	+7-910-477-38-59	александр.новиков233@email.ru	4535	763752	2025-09-16	1972-06-28
90058	Анна	Иванов	+7-901-724-37-77	анна.иванов234@email.ru	4508	719994	2025-09-16	2002-12-20
90059	Елена	Смирнов	+7-922-724-93-68	елена.смирнов235@email.ru	4539	410091	2025-09-16	1975-09-15
90060	Марина	Сидоров	+7-983-235-78-63	марина.сидоров236@email.ru	4558	728636	2025-09-16	1958-11-16
90061	Игорь	Михайлов	+7-927-889-61-72	игорь.михайлов237@email.ru	4582	162212	2025-09-16	1958-01-20
90062	Ольга	Морозов	+7-943-201-46-92	ольга.морозов238@email.ru	4554	834001	2025-09-16	2000-07-03
90063	Елена	Козлов	+7-952-839-64-39	елена.козлов239@email.ru	4526	858255	2025-09-16	1988-01-18
90064	Игорь	Козлов	+7-948-462-16-84	игорь.козлов240@email.ru	4543	914161	2025-09-16	1970-11-14
90065	Дмитрий	Сидоров	+7-918-969-60-16	дмитрий.сидоров241@email.ru	4585	894726	2025-09-16	1989-04-01
90066	Наталья	Фёдоров	+7-987-248-63-52	наталья.фёдоров242@email.ru	4549	523098	2025-09-16	1972-09-13
90067	Наталья	Кузнецов	+7-932-515-97-84	наталья.кузнецов243@email.ru	4595	313479	2025-09-16	1971-01-17
90068	Игорь	Волков	+7-916-201-72-31	игорь.волков244@email.ru	4588	287250	2025-09-16	2003-03-09
90069	Дмитрий	Морозов	+7-908-360-59-94	дмитрий.морозов245@email.ru	4564	685585	2025-09-16	1959-09-17
90070	Владимир	Петров	+7-916-313-45-67	владимир.петров246@email.ru	4561	775378	2025-09-16	1960-08-13
90071	Владимир	Морозов	+7-913-110-31-29	владимир.морозов247@email.ru	4556	891661	2025-09-16	1983-09-07
90072	Дмитрий	Смирнов	+7-982-601-33-34	дмитрий.смирнов248@email.ru	4552	128693	2025-09-16	2004-08-28
90073	Анна	Фёдоров	+7-912-978-57-69	анна.фёдоров249@email.ru	4599	104933	2025-09-16	2005-08-30
90074	Дмитрий	Михайлов	+7-925-416-48-43	дмитрий.михайлов250@email.ru	4598	345364	2025-09-16	1989-05-02
90075	Елена	Сидоров	+7-905-153-72-12	елена.сидоров251@email.ru	4566	556894	2025-09-16	1980-07-15
90076	Михаил	Сидоров	+7-916-284-46-99	михаил.сидоров252@email.ru	4546	661233	2025-09-16	1985-03-02
90077	Ольга	Петров	+7-976-142-81-11	ольга.петров253@email.ru	4549	119082	2025-09-16	1983-08-25
90078	Алексей	Козлов	+7-927-348-90-10	алексей.козлов254@email.ru	4591	938448	2025-09-16	1961-03-14
90079	Анна	Лебедев	+7-924-764-45-15	анна.лебедев255@email.ru	4531	815865	2025-09-16	1986-05-22
90080	Наталья	Морозов	+7-970-472-61-55	наталья.морозов256@email.ru	4508	943240	2025-09-16	1961-12-02
90081	Алексей	Петров	+7-991-566-50-53	алексей.петров257@email.ru	4553	528441	2025-09-16	1972-11-13
90082	Дмитрий	Кузнецов	+7-913-845-22-92	дмитрий.кузнецов258@email.ru	4503	574962	2025-09-16	1999-08-28
90083	Михаил	Лебедев	+7-965-250-84-56	михаил.лебедев259@email.ru	4568	624674	2025-09-16	1999-09-24
90084	Наталья	Соколов	+7-988-787-90-14	наталья.соколов260@email.ru	4506	580727	2025-09-16	1997-11-22
90085	Александр	Смирнов	+7-940-721-72-35	александр.смирнов261@email.ru	4545	210209	2025-09-16	1976-01-19
90086	Наталья	Фёдоров	+7-947-522-58-13	наталья.фёдоров262@email.ru	4534	968101	2025-09-16	1988-05-30
90087	Александр	Лебедев	+7-948-929-68-99	александр.лебедев263@email.ru	4543	939735	2025-09-16	1996-02-16
90088	Марина	Соколов	+7-914-188-13-22	марина.соколов264@email.ru	4569	146012	2025-09-16	1997-05-16
90089	Дмитрий	Лебедев	+7-975-593-90-97	дмитрий.лебедев265@email.ru	4599	207496	2025-09-16	1998-04-11
90090	Александр	Морозов	+7-985-140-15-62	александр.морозов266@email.ru	4517	461857	2025-09-16	1961-08-01
90091	Елена	Петров	+7-912-796-68-41	елена.петров267@email.ru	4532	343750	2025-09-16	1965-08-27
90092	Наталья	Новиков	+7-967-731-34-13	наталья.новиков268@email.ru	4551	946514	2025-09-16	1983-06-07
90093	Игорь	Михайлов	+7-949-175-27-64	игорь.михайлов269@email.ru	4575	198362	2025-09-16	1961-07-29
90094	Ольга	Фёдоров	+7-959-195-16-16	ольга.фёдоров270@email.ru	4568	444722	2025-09-16	2003-01-27
90095	Наталья	Петров	+7-929-881-19-37	наталья.петров271@email.ru	4550	566034	2025-09-16	1983-11-30
90096	Марина	Морозов	+7-943-868-30-59	марина.морозов272@email.ru	4517	735986	2025-09-16	1957-09-29
90097	Владимир	Михайлов	+7-966-981-61-77	владимир.михайлов273@email.ru	4529	401032	2025-09-16	1964-09-12
90098	Татьяна	Сидоров	+7-971-895-10-14	татьяна.сидоров274@email.ru	4533	320848	2025-09-16	1999-03-30
90099	Марина	Соколов	+7-911-942-33-62	марина.соколов275@email.ru	4555	729572	2025-09-16	1957-11-01
90100	Ирина	Попов	+7-938-375-94-29	ирина.попов276@email.ru	4580	180861	2025-09-16	1968-05-24
90101	Елена	Попов	+7-984-532-25-85	елена.попов277@email.ru	4586	417578	2025-09-16	2003-06-16
90102	Марина	Козлов	+7-935-932-38-28	марина.козлов278@email.ru	4500	571205	2025-09-16	1959-10-10
90103	Дмитрий	Фёдоров	+7-949-439-43-82	дмитрий.фёдоров279@email.ru	4554	240902	2025-09-16	1965-12-28
90104	Елена	Козлов	+7-980-688-25-96	елена.козлов280@email.ru	4506	403009	2025-09-16	1967-12-22
90105	Марина	Морозов	+7-945-592-59-14	марина.морозов281@email.ru	4548	832361	2025-09-16	1966-09-17
90106	Анна	Морозов	+7-997-700-54-33	анна.морозов282@email.ru	4542	132034	2025-09-16	1956-08-31
90107	Анна	Новиков	+7-924-568-58-85	анна.новиков283@email.ru	4551	416363	2025-09-16	1959-03-27
90108	Дмитрий	Михайлов	+7-971-984-71-81	дмитрий.михайлов284@email.ru	4576	830400	2025-09-16	1980-07-19
90109	Анна	Соколов	+7-951-441-85-52	анна.соколов285@email.ru	4505	230434	2025-09-16	1956-01-27
90110	Сергей	Фёдоров	+7-989-732-98-21	сергей.фёдоров286@email.ru	4572	708516	2025-09-16	1966-06-02
90111	Анна	Сидоров	+7-963-678-11-71	анна.сидоров287@email.ru	4532	684657	2025-09-16	1962-09-03
90112	Елена	Попов	+7-971-163-52-94	елена.попов288@email.ru	4543	783886	2025-09-16	1961-11-05
90113	Михаил	Кузнецов	+7-987-532-52-27	михаил.кузнецов289@email.ru	4512	146954	2025-09-16	1971-07-27
90114	Сергей	Попов	+7-928-932-26-57	сергей.попов290@email.ru	4521	289713	2025-09-16	2001-10-05
90115	Сергей	Соколов	+7-934-389-80-98	сергей.соколов291@email.ru	4552	165880	2025-09-16	1960-02-27
90116	Игорь	Иванов	+7-944-641-36-67	игорь.иванов292@email.ru	4583	693254	2025-09-16	1981-10-02
90117	Игорь	Иванов	+7-990-434-32-52	игорь.иванов293@email.ru	4595	786545	2025-09-16	1978-08-21
90118	Марина	Попов	+7-945-817-99-24	марина.попов294@email.ru	4590	813252	2025-09-16	1986-08-09
90119	Владимир	Новиков	+7-950-548-42-30	владимир.новиков295@email.ru	4561	111425	2025-09-16	1995-07-20
90120	Владимир	Петров	+7-999-622-68-73	владимир.петров296@email.ru	4550	723068	2025-09-16	1980-04-21
90121	Алексей	Новиков	+7-933-894-45-42	алексей.новиков297@email.ru	4520	743626	2025-09-16	1994-12-12
90122	Михаил	Соколов	+7-968-927-94-93	михаил.соколов298@email.ru	4538	772387	2025-09-16	2000-07-20
90123	Дмитрий	Кузнецов	+7-928-741-60-42	дмитрий.кузнецов299@email.ru	4551	241367	2025-09-16	1961-02-23
90124	Ирина	Попов	+7-983-331-14-69	ирина.попов300@email.ru	4577	449544	2025-09-16	1998-08-15
90125	Елена	Попов	+7-981-497-39-80	елена.попов301@email.ru	4513	860223	2025-09-16	1992-04-23
90126	Марина	Морозов	+7-959-309-75-36	марина.морозов302@email.ru	4546	729087	2025-09-16	1963-10-11
90127	Ольга	Михайлов	+7-932-190-29-20	ольга.михайлов303@email.ru	4571	908953	2025-09-16	1980-01-31
90128	Михаил	Волков	+7-956-576-25-92	михаил.волков304@email.ru	4579	518932	2025-09-16	1997-04-02
90129	Алексей	Попов	+7-940-477-79-60	алексей.попов305@email.ru	4556	981497	2025-09-16	2002-06-28
90130	Александр	Михайлов	+7-951-216-46-69	александр.михайлов306@email.ru	4523	311927	2025-09-16	1999-02-19
90131	Сергей	Сидоров	+7-900-419-58-93	сергей.сидоров307@email.ru	4514	947246	2025-09-16	1988-03-27
90132	Дмитрий	Смирнов	+7-983-657-21-36	дмитрий.смирнов308@email.ru	4502	467227	2025-09-16	1977-03-13
90133	Наталья	Лебедев	+7-930-181-79-19	наталья.лебедев309@email.ru	4515	166637	2025-09-16	2002-10-17
90134	Дмитрий	Волков	+7-948-522-62-93	дмитрий.волков310@email.ru	4528	919891	2025-09-16	1989-09-18
90135	Елена	Петров	+7-947-618-48-17	елена.петров311@email.ru	4513	377701	2025-09-16	1983-10-03
90136	Татьяна	Иванов	+7-973-265-93-38	татьяна.иванов312@email.ru	4554	934924	2025-09-16	1986-05-03
90137	Ольга	Кузнецов	+7-953-260-17-17	ольга.кузнецов313@email.ru	4574	799550	2025-09-16	2000-09-03
90138	Елена	Смирнов	+7-927-915-64-24	елена.смирнов314@email.ru	4533	322846	2025-09-16	1957-01-02
90139	Михаил	Кузнецов	+7-921-115-94-57	михаил.кузнецов315@email.ru	4548	539121	2025-09-16	1992-03-06
90140	Елена	Соколов	+7-931-110-25-45	елена.соколов316@email.ru	4511	562151	2025-09-16	1957-07-07
90141	Владимир	Сидоров	+7-962-906-98-38	владимир.сидоров317@email.ru	4526	419413	2025-09-16	1992-04-22
90142	Татьяна	Козлов	+7-951-663-48-51	татьяна.козлов318@email.ru	4581	487207	2025-09-16	1999-09-02
90143	Сергей	Сидоров	+7-963-812-79-52	сергей.сидоров319@email.ru	4569	880976	2025-09-16	1974-05-24
90144	Владимир	Морозов	+7-964-601-42-65	владимир.морозов320@email.ru	4508	505912	2025-09-16	1959-07-13
90145	Владимир	Иванов	+7-931-940-38-38	владимир.иванов321@email.ru	4555	453909	2025-09-16	1956-04-30
90146	Игорь	Волков	+7-984-490-25-71	игорь.волков322@email.ru	4561	559152	2025-09-16	1980-08-10
90147	Ирина	Козлов	+7-905-995-11-56	ирина.козлов323@email.ru	4506	900337	2025-09-16	2004-01-24
90148	Елена	Смирнов	+7-930-385-60-81	елена.смирнов324@email.ru	4593	891047	2025-09-16	1957-04-09
90149	Владимир	Волков	+7-916-766-57-12	владимир.волков325@email.ru	4540	424481	2025-09-16	2003-04-20
90150	Алексей	Морозов	+7-928-796-52-33	алексей.морозов326@email.ru	4538	762589	2025-09-16	1962-02-05
90151	Елена	Кузнецов	+7-906-921-99-69	елена.кузнецов327@email.ru	4532	638452	2025-09-16	1980-10-26
90152	Марина	Волков	+7-927-448-80-31	марина.волков328@email.ru	4584	155169	2025-09-16	1965-11-06
90153	Татьяна	Иванов	+7-996-662-26-24	татьяна.иванов329@email.ru	4560	618175	2025-09-16	1985-07-27
90154	Ирина	Кузнецов	+7-954-365-44-46	ирина.кузнецов330@email.ru	4542	787824	2025-09-16	1978-08-01
90155	Ирина	Иванов	+7-912-941-93-70	ирина.иванов331@email.ru	4553	381128	2025-09-16	2000-05-15
90156	Марина	Иванов	+7-942-399-68-71	марина.иванов332@email.ru	4506	698350	2025-09-16	1986-03-05
90157	Владимир	Фёдоров	+7-960-578-14-45	владимир.фёдоров333@email.ru	4597	483515	2025-09-16	1999-05-17
90158	Александр	Кузнецов	+7-943-178-96-63	александр.кузнецов334@email.ru	4562	648201	2025-09-16	1979-04-01
90159	Ольга	Морозов	+7-993-542-47-70	ольга.морозов335@email.ru	4599	889545	2025-09-16	1980-04-07
90160	Татьяна	Иванов	+7-991-731-32-12	татьяна.иванов336@email.ru	4548	657734	2025-09-16	1961-09-16
90161	Сергей	Козлов	+7-932-155-57-74	сергей.козлов337@email.ru	4510	211855	2025-09-16	1967-09-08
90162	Ольга	Михайлов	+7-953-283-80-29	ольга.михайлов338@email.ru	4561	620957	2025-09-16	1995-05-17
90163	Сергей	Петров	+7-967-173-30-11	сергей.петров339@email.ru	4517	118537	2025-09-16	1967-08-25
90164	Марина	Смирнов	+7-914-274-84-20	марина.смирнов340@email.ru	4520	171172	2025-09-16	1961-06-17
90165	Игорь	Попов	+7-980-844-89-58	игорь.попов341@email.ru	4596	177157	2025-09-16	1994-03-24
90166	Марина	Новиков	+7-978-111-20-26	марина.новиков342@email.ru	4527	333286	2025-09-16	1963-07-29
90167	Игорь	Фёдоров	+7-917-734-28-70	игорь.фёдоров343@email.ru	4542	815335	2025-09-16	2006-01-12
90168	Марина	Козлов	+7-939-917-26-46	марина.козлов344@email.ru	4559	137175	2025-09-16	1960-02-29
90169	Анна	Козлов	+7-913-832-29-75	анна.козлов345@email.ru	4589	187317	2025-09-16	2000-08-23
90170	Дмитрий	Смирнов	+7-973-966-79-44	дмитрий.смирнов346@email.ru	4534	832438	2025-09-16	1982-09-25
90171	Алексей	Попов	+7-964-945-46-60	алексей.попов347@email.ru	4523	742561	2025-09-16	2001-05-11
90172	Михаил	Кузнецов	+7-937-282-65-98	михаил.кузнецов348@email.ru	4562	692795	2025-09-16	1984-02-11
90173	Алексей	Кузнецов	+7-959-656-43-21	алексей.кузнецов349@email.ru	4519	155875	2025-09-16	1972-03-19
90174	Дмитрий	Попов	+7-900-693-42-47	дмитрий.попов350@email.ru	4577	682544	2025-09-16	1998-05-20
90175	Наталья	Михайлов	+7-955-335-93-44	наталья.михайлов351@email.ru	4525	246239	2025-09-16	1959-01-06
90176	Ирина	Иванов	+7-992-655-14-28	ирина.иванов352@email.ru	4583	477572	2025-09-16	2005-11-05
90177	Сергей	Соколов	+7-911-803-14-45	сергей.соколов353@email.ru	4571	312775	2025-09-16	1990-08-30
90178	Игорь	Соколов	+7-904-824-71-17	игорь.соколов354@email.ru	4538	720551	2025-09-16	1987-03-30
90179	Дмитрий	Соколов	+7-912-211-74-52	дмитрий.соколов355@email.ru	4509	974550	2025-09-16	1958-12-01
90180	Игорь	Волков	+7-922-913-35-10	игорь.волков356@email.ru	4566	302297	2025-09-16	2002-04-06
90181	Алексей	Кузнецов	+7-962-910-21-62	алексей.кузнецов357@email.ru	4583	962263	2025-09-16	1984-09-15
90182	Татьяна	Волков	+7-917-350-56-62	татьяна.волков358@email.ru	4532	561907	2025-09-16	1985-11-19
90183	Сергей	Новиков	+7-979-245-29-68	сергей.новиков359@email.ru	4535	782315	2025-09-16	1966-05-26
90184	Владимир	Козлов	+7-963-288-33-70	владимир.козлов360@email.ru	4532	488089	2025-09-16	1991-02-27
90185	Татьяна	Новиков	+7-968-889-14-91	татьяна.новиков361@email.ru	4588	884247	2025-09-16	2000-10-17
90186	Алексей	Лебедев	+7-999-925-64-37	алексей.лебедев362@email.ru	4567	338311	2025-09-16	2002-08-01
90187	Игорь	Фёдоров	+7-934-532-96-65	игорь.фёдоров363@email.ru	4587	752023	2025-09-16	1990-08-15
90188	Алексей	Смирнов	+7-909-581-50-30	алексей.смирнов364@email.ru	4588	305043	2025-09-16	1994-09-27
90189	Татьяна	Сидоров	+7-915-413-58-68	татьяна.сидоров365@email.ru	4582	210853	2025-09-16	1990-05-06
90190	Дмитрий	Новиков	+7-946-206-94-28	дмитрий.новиков366@email.ru	4591	358850	2025-09-16	1988-04-02
90191	Сергей	Кузнецов	+7-950-573-88-29	сергей.кузнецов367@email.ru	4576	130206	2025-09-16	1972-10-22
90192	Елена	Соколов	+7-934-467-50-17	елена.соколов368@email.ru	4540	494037	2025-09-16	2001-01-31
90193	Дмитрий	Лебедев	+7-945-481-86-23	дмитрий.лебедев369@email.ru	4540	123664	2025-09-16	1980-08-07
90194	Анна	Козлов	+7-925-532-19-61	анна.козлов370@email.ru	4528	490200	2025-09-16	2000-08-03
90195	Михаил	Морозов	+7-982-750-97-53	михаил.морозов371@email.ru	4548	923967	2025-09-16	1989-06-21
90196	Марина	Фёдоров	+7-917-774-31-31	марина.фёдоров372@email.ru	4500	899601	2025-09-16	1972-11-11
90197	Владимир	Петров	+7-910-966-67-78	владимир.петров373@email.ru	4589	646981	2025-09-16	2003-07-14
90198	Наталья	Сидоров	+7-907-690-10-34	наталья.сидоров374@email.ru	4548	811786	2025-09-16	2003-04-15
90199	Ирина	Новиков	+7-928-814-18-37	ирина.новиков375@email.ru	4574	688930	2025-09-16	1971-03-06
90200	Ирина	Попов	+7-913-798-25-52	ирина.попов376@email.ru	4570	418315	2025-09-16	2001-11-08
90201	Анна	Лебедев	+7-911-338-62-85	анна.лебедев377@email.ru	4519	410005	2025-09-16	1986-07-31
90202	Елена	Новиков	+7-917-493-42-63	елена.новиков378@email.ru	4583	566929	2025-09-16	1965-04-01
90203	Наталья	Новиков	+7-915-909-19-13	наталья.новиков379@email.ru	4585	907243	2025-09-16	2004-03-21
90204	Сергей	Попов	+7-957-483-94-81	сергей.попов380@email.ru	4557	932498	2025-09-16	1969-09-17
90205	Александр	Михайлов	+7-916-674-33-72	александр.михайлов381@email.ru	4573	612722	2025-09-16	1990-04-24
90206	Наталья	Волков	+7-983-475-18-78	наталья.волков382@email.ru	4565	724213	2025-09-16	1985-08-20
90207	Ольга	Сидоров	+7-939-463-17-92	ольга.сидоров383@email.ru	4567	404727	2025-09-16	1965-06-26
90208	Сергей	Михайлов	+7-965-581-11-11	сергей.михайлов384@email.ru	4555	298482	2025-09-16	2005-12-26
90209	Ольга	Фёдоров	+7-995-212-68-51	ольга.фёдоров385@email.ru	4504	640554	2025-09-16	1974-12-14
90210	Татьяна	Михайлов	+7-934-683-73-74	татьяна.михайлов386@email.ru	4569	374342	2025-09-16	1981-07-17
90211	Игорь	Кузнецов	+7-990-485-32-20	игорь.кузнецов387@email.ru	4595	445632	2025-09-16	2000-10-17
90212	Ирина	Сидоров	+7-942-966-51-65	ирина.сидоров388@email.ru	4531	389362	2025-09-16	2004-09-13
90213	Владимир	Сидоров	+7-907-409-99-55	владимир.сидоров389@email.ru	4530	782930	2025-09-16	2004-04-02
90214	Александр	Морозов	+7-970-905-92-64	александр.морозов390@email.ru	4520	700666	2025-09-16	1973-02-21
90215	Елена	Михайлов	+7-947-529-27-55	елена.михайлов391@email.ru	4500	602656	2025-09-16	1983-07-03
90216	Ольга	Сидоров	+7-970-994-36-64	ольга.сидоров392@email.ru	4588	479438	2025-09-16	2003-09-24
90217	Ирина	Петров	+7-914-512-37-69	ирина.петров393@email.ru	4526	371413	2025-09-16	1990-06-02
90218	Алексей	Соколов	+7-950-681-39-22	алексей.соколов394@email.ru	4528	265201	2025-09-16	1996-04-12
90219	Михаил	Смирнов	+7-947-371-97-58	михаил.смирнов395@email.ru	4570	507519	2025-09-16	1982-09-10
90220	Марина	Смирнов	+7-903-390-17-77	марина.смирнов396@email.ru	4567	366120	2025-09-16	1984-07-31
90221	Игорь	Иванов	+7-918-904-35-44	игорь.иванов397@email.ru	4523	579798	2025-09-16	1976-08-19
90222	Михаил	Лебедев	+7-961-320-15-45	михаил.лебедев398@email.ru	4538	366652	2025-09-16	1962-05-16
90223	Елена	Иванов	+7-912-395-53-27	елена.иванов399@email.ru	4557	290164	2025-09-16	1990-08-19
90224	Елена	Лебедев	+7-990-498-44-86	елена.лебедев400@email.ru	4555	652630	2025-09-16	1990-01-07
90225	Владимир	Козлов	+7-958-289-21-61	владимир.козлов401@email.ru	4521	569011	2025-09-16	1968-04-24
90226	Татьяна	Сидоров	+7-965-982-81-19	татьяна.сидоров402@email.ru	4516	121606	2025-09-16	1996-04-08
90227	Анна	Соколов	+7-981-261-92-60	анна.соколов403@email.ru	4597	557393	2025-09-16	1962-05-14
90228	Ольга	Волков	+7-913-276-36-74	ольга.волков404@email.ru	4529	702717	2025-09-16	1977-05-14
90229	Татьяна	Козлов	+7-908-376-16-87	татьяна.козлов405@email.ru	4546	474262	2025-09-16	1960-06-10
90230	Владимир	Петров	+7-974-600-72-62	владимир.петров406@email.ru	4592	926478	2025-09-16	1992-11-02
90231	Анна	Соколов	+7-949-931-36-35	анна.соколов407@email.ru	4530	988370	2025-09-16	1964-03-27
90232	Татьяна	Кузнецов	+7-967-162-94-65	татьяна.кузнецов408@email.ru	4518	549600	2025-09-16	2002-07-21
90233	Ольга	Новиков	+7-950-800-28-95	ольга.новиков409@email.ru	4568	710722	2025-09-16	1967-01-27
90234	Елена	Лебедев	+7-966-877-57-38	елена.лебедев410@email.ru	4562	955366	2025-09-16	1972-03-23
90235	Владимир	Волков	+7-937-386-95-47	владимир.волков411@email.ru	4575	158039	2025-09-16	2006-03-28
90236	Ольга	Новиков	+7-914-360-68-80	ольга.новиков412@email.ru	4526	563985	2025-09-16	1965-03-01
90237	Владимир	Кузнецов	+7-933-223-75-39	владимир.кузнецов413@email.ru	4573	133585	2025-09-16	2005-05-23
90238	Сергей	Сидоров	+7-954-594-42-27	сергей.сидоров414@email.ru	4506	308052	2025-09-16	1964-01-11
90239	Елена	Лебедев	+7-927-889-45-41	елена.лебедев415@email.ru	4525	702141	2025-09-16	1996-10-05
90240	Владимир	Волков	+7-972-146-40-97	владимир.волков416@email.ru	4554	231346	2025-09-16	1968-09-15
90241	Алексей	Кузнецов	+7-984-396-45-30	алексей.кузнецов417@email.ru	4580	354516	2025-09-16	1959-04-12
90242	Сергей	Сидоров	+7-935-437-79-75	сергей.сидоров418@email.ru	4540	441142	2025-09-16	1983-12-29
90243	Дмитрий	Попов	+7-994-234-99-37	дмитрий.попов419@email.ru	4511	642822	2025-09-16	1977-04-12
90244	Ирина	Сидоров	+7-980-772-86-66	ирина.сидоров420@email.ru	4524	317404	2025-09-16	1980-04-26
90245	Дмитрий	Волков	+7-999-419-14-46	дмитрий.волков421@email.ru	4529	771215	2025-09-16	1977-08-27
90246	Игорь	Лебедев	+7-901-436-17-30	игорь.лебедев422@email.ru	4514	809696	2025-09-16	1968-11-20
90247	Александр	Попов	+7-938-492-28-84	александр.попов423@email.ru	4517	579163	2025-09-16	1974-08-03
90248	Сергей	Фёдоров	+7-946-824-83-98	сергей.фёдоров424@email.ru	4583	201747	2025-09-16	1998-06-01
90249	Наталья	Волков	+7-939-131-45-77	наталья.волков425@email.ru	4573	415615	2025-09-16	1964-09-19
90250	Михаил	Морозов	+7-994-941-62-93	михаил.морозов426@email.ru	4531	439350	2025-09-16	1978-02-09
90251	Ирина	Волков	+7-976-209-85-86	ирина.волков427@email.ru	4563	919989	2025-09-16	1996-07-11
90252	Владимир	Новиков	+7-937-160-52-47	владимир.новиков428@email.ru	4543	733921	2025-09-16	1960-10-21
90253	Владимир	Морозов	+7-940-456-96-90	владимир.морозов429@email.ru	4580	405270	2025-09-16	1963-12-16
90254	Игорь	Фёдоров	+7-919-378-22-81	игорь.фёдоров430@email.ru	4594	444537	2025-09-16	1955-10-22
90255	Михаил	Кузнецов	+7-961-214-14-31	михаил.кузнецов431@email.ru	4585	704951	2025-09-16	1976-12-27
90256	Дмитрий	Петров	+7-975-924-88-17	дмитрий.петров432@email.ru	4552	917409	2025-09-16	1960-05-14
90257	Михаил	Соколов	+7-901-155-92-52	михаил.соколов433@email.ru	4500	458125	2025-09-16	1982-06-17
90258	Игорь	Соколов	+7-982-979-36-84	игорь.соколов434@email.ru	4558	301360	2025-09-16	1991-11-21
90259	Алексей	Козлов	+7-950-843-86-81	алексей.козлов435@email.ru	4506	115023	2025-09-16	1961-02-06
90260	Анна	Новиков	+7-924-447-61-90	анна.новиков436@email.ru	4581	361807	2025-09-16	1972-06-09
90261	Ольга	Лебедев	+7-976-240-79-25	ольга.лебедев437@email.ru	4564	529463	2025-09-16	2003-08-22
90262	Марина	Смирнов	+7-981-953-34-56	марина.смирнов438@email.ru	4523	878861	2025-09-16	2006-11-05
90263	Алексей	Фёдоров	+7-912-309-38-11	алексей.фёдоров439@email.ru	4509	713337	2025-09-16	1989-02-14
90264	Елена	Петров	+7-925-189-71-53	елена.петров440@email.ru	4533	198515	2025-09-16	1972-02-05
90265	Сергей	Козлов	+7-954-886-49-59	сергей.козлов441@email.ru	4585	166893	2025-09-16	2004-03-22
90266	Михаил	Кузнецов	+7-907-129-48-62	михаил.кузнецов442@email.ru	4544	145071	2025-09-16	1996-05-01
90267	Анна	Фёдоров	+7-945-319-74-98	анна.фёдоров443@email.ru	4594	180030	2025-09-16	1996-09-28
90268	Дмитрий	Иванов	+7-957-309-24-41	дмитрий.иванов444@email.ru	4539	953715	2025-09-16	1982-04-23
90269	Елена	Иванов	+7-909-573-91-98	елена.иванов445@email.ru	4525	298714	2025-09-16	1974-10-18
90270	Татьяна	Попов	+7-981-894-52-33	татьяна.попов446@email.ru	4514	982417	2025-09-16	2003-09-13
90271	Елена	Волков	+7-921-672-58-33	елена.волков447@email.ru	4581	697912	2025-09-16	1987-01-19
90272	Александр	Соколов	+7-919-916-37-33	александр.соколов448@email.ru	4589	385207	2025-09-16	1990-02-15
90273	Наталья	Новиков	+7-929-904-84-58	наталья.новиков449@email.ru	4542	755732	2025-09-16	1962-08-28
90274	Марина	Лебедев	+7-957-436-69-76	марина.лебедев450@email.ru	4550	258371	2025-09-16	1972-04-28
90275	Алексей	Петров	+7-918-972-42-87	алексей.петров451@email.ru	4591	640283	2025-09-16	1962-11-22
90276	Александр	Фёдоров	+7-910-288-94-75	александр.фёдоров452@email.ru	4597	543792	2025-09-16	1959-07-07
90277	Елена	Фёдоров	+7-931-968-61-94	елена.фёдоров453@email.ru	4557	479793	2025-09-16	1996-03-16
90278	Игорь	Лебедев	+7-990-346-92-20	игорь.лебедев454@email.ru	4523	730481	2025-09-16	1993-12-03
90279	Игорь	Кузнецов	+7-905-752-61-97	игорь.кузнецов455@email.ru	4567	207017	2025-09-16	1978-12-04
90280	Михаил	Попов	+7-914-432-39-40	михаил.попов456@email.ru	4522	873888	2025-09-16	2002-05-07
90281	Дмитрий	Кузнецов	+7-934-650-65-56	дмитрий.кузнецов457@email.ru	4504	193763	2025-09-16	1966-04-07
90282	Марина	Козлов	+7-909-597-10-12	марина.козлов458@email.ru	4599	447869	2025-09-16	1996-11-30
90283	Александр	Фёдоров	+7-903-246-58-28	александр.фёдоров459@email.ru	4546	747290	2025-09-16	1961-05-13
90284	Игорь	Волков	+7-931-241-42-70	игорь.волков460@email.ru	4508	224356	2025-09-16	1959-12-17
90285	Татьяна	Иванов	+7-967-548-36-14	татьяна.иванов461@email.ru	4512	620960	2025-09-16	1987-06-11
90286	Елена	Петров	+7-934-800-87-34	елена.петров462@email.ru	4574	421186	2025-09-16	1982-04-14
90287	Анна	Сидоров	+7-966-800-83-51	анна.сидоров463@email.ru	4542	927058	2025-09-16	1987-11-05
90288	Татьяна	Морозов	+7-973-144-36-59	татьяна.морозов464@email.ru	4555	758419	2025-09-16	1986-05-20
90289	Наталья	Лебедев	+7-900-165-87-92	наталья.лебедев465@email.ru	4520	728597	2025-09-16	1974-05-25
90290	Александр	Новиков	+7-961-689-41-37	александр.новиков466@email.ru	4586	566985	2025-09-16	1964-07-28
90291	Александр	Кузнецов	+7-916-135-38-55	александр.кузнецов467@email.ru	4589	223396	2025-09-16	1976-07-17
90292	Дмитрий	Сидоров	+7-964-461-27-90	дмитрий.сидоров468@email.ru	4501	937202	2025-09-16	2006-12-17
90293	Елена	Сидоров	+7-962-275-29-91	елена.сидоров469@email.ru	4591	517167	2025-09-16	1966-10-21
90294	Наталья	Соколов	+7-974-964-25-23	наталья.соколов470@email.ru	4562	149641	2025-09-16	1997-07-21
90295	Дмитрий	Попов	+7-915-577-92-69	дмитрий.попов471@email.ru	4585	927177	2025-09-16	2005-02-02
90296	Сергей	Лебедев	+7-959-110-41-12	сергей.лебедев472@email.ru	4583	723638	2025-09-16	1957-11-06
90297	Наталья	Лебедев	+7-952-619-27-64	наталья.лебедев473@email.ru	4521	636976	2025-09-16	1997-09-18
90298	Ольга	Морозов	+7-961-453-41-49	ольга.морозов474@email.ru	4525	564067	2025-09-16	1959-04-21
90299	Марина	Козлов	+7-988-484-83-65	марина.козлов475@email.ru	4528	933047	2025-09-16	1992-08-14
90300	Татьяна	Сидоров	+7-977-381-60-50	татьяна.сидоров476@email.ru	4510	903226	2025-09-16	1979-02-23
90301	Ольга	Лебедев	+7-905-861-33-54	ольга.лебедев477@email.ru	4524	829856	2025-09-16	1981-01-23
90302	Игорь	Лебедев	+7-978-893-28-85	игорь.лебедев478@email.ru	4517	111700	2025-09-16	2005-01-18
90303	Ольга	Козлов	+7-973-560-88-16	ольга.козлов479@email.ru	4553	619521	2025-09-16	1982-02-11
90304	Игорь	Иванов	+7-969-376-31-97	игорь.иванов480@email.ru	4581	693255	2025-09-16	1963-08-27
90305	Ольга	Лебедев	+7-990-918-37-20	ольга.лебедев481@email.ru	4547	543782	2025-09-16	1967-07-01
90306	Сергей	Волков	+7-901-286-64-55	сергей.волков482@email.ru	4576	862808	2025-09-16	1994-04-14
90307	Александр	Михайлов	+7-994-533-71-58	александр.михайлов483@email.ru	4588	476855	2025-09-16	1969-05-06
90308	Елена	Морозов	+7-920-165-79-47	елена.морозов484@email.ru	4551	721817	2025-09-16	1978-04-29
90309	Наталья	Петров	+7-970-517-88-75	наталья.петров485@email.ru	4519	102313	2025-09-16	1996-04-27
90310	Алексей	Козлов	+7-928-397-25-21	алексей.козлов486@email.ru	4520	493394	2025-09-16	1988-05-04
90311	Ольга	Волков	+7-913-130-21-38	ольга.волков487@email.ru	4557	129816	2025-09-16	1989-02-25
90312	Дмитрий	Новиков	+7-984-671-98-40	дмитрий.новиков488@email.ru	4536	693645	2025-09-16	1958-08-15
90313	Александр	Новиков	+7-944-805-41-55	александр.новиков489@email.ru	4591	353839	2025-09-16	1971-04-04
90314	Марина	Петров	+7-995-121-79-96	марина.петров490@email.ru	4554	993802	2025-09-16	1977-12-25
90315	Игорь	Морозов	+7-966-117-40-40	игорь.морозов491@email.ru	4516	502750	2025-09-16	1994-03-04
90316	Игорь	Сидоров	+7-947-288-57-37	игорь.сидоров492@email.ru	4533	175589	2025-09-16	1998-01-27
90317	Михаил	Михайлов	+7-990-655-51-40	михаил.михайлов493@email.ru	4583	747547	2025-09-16	1968-08-12
90318	Владимир	Фёдоров	+7-998-645-56-50	владимир.фёдоров494@email.ru	4523	894486	2025-09-16	1993-07-13
90319	Дмитрий	Козлов	+7-900-165-74-44	дмитрий.козлов495@email.ru	4537	806918	2025-09-16	1998-08-05
90320	Владимир	Волков	+7-950-450-55-51	владимир.волков496@email.ru	4584	111331	2025-09-16	1960-02-18
90321	Марина	Кузнецов	+7-913-502-48-68	марина.кузнецов497@email.ru	4531	129411	2025-09-16	2004-08-01
90322	Игорь	Иванов	+7-962-608-19-57	игорь.иванов498@email.ru	4558	288372	2025-09-16	1963-06-08
90323	Алексей	Морозов	+7-909-382-20-23	алексей.морозов499@email.ru	4518	678452	2025-09-16	1965-02-03
90324	Игорь	Петров	+7-966-116-86-86	игорь.петров500@email.ru	4545	277543	2025-09-16	1989-06-09
90325	Ирина	Соколов	+7-996-564-49-98	ирина.соколов501@email.ru	4519	732577	2025-09-16	1963-03-23
90326	Анна	Козлов	+7-905-647-57-20	анна.козлов502@email.ru	4540	606323	2025-09-16	1962-09-03
90327	Ирина	Сидоров	+7-999-173-62-98	ирина.сидоров503@email.ru	4560	718505	2025-09-16	1998-07-27
90328	Марина	Сидоров	+7-957-383-45-31	марина.сидоров504@email.ru	4599	913695	2025-09-16	1962-04-17
90329	Алексей	Фёдоров	+7-932-686-93-86	алексей.фёдоров505@email.ru	4526	980994	2025-09-16	2006-03-28
90330	Алексей	Морозов	+7-933-174-49-85	алексей.морозов506@email.ru	4553	512067	2025-09-16	1956-01-11
90331	Ирина	Попов	+7-965-966-41-27	ирина.попов507@email.ru	4595	579745	2025-09-16	1956-05-31
90332	Дмитрий	Соколов	+7-930-746-17-18	дмитрий.соколов508@email.ru	4537	509064	2025-09-16	2000-12-23
90333	Наталья	Лебедев	+7-974-889-56-22	наталья.лебедев509@email.ru	4519	376694	2025-09-16	1980-04-01
90334	Ирина	Фёдоров	+7-994-271-39-39	ирина.фёдоров510@email.ru	4573	820461	2025-09-16	1981-05-06
90335	Владимир	Морозов	+7-962-485-83-80	владимир.морозов511@email.ru	4507	295737	2025-09-16	1980-05-16
90336	Елена	Волков	+7-934-553-40-88	елена.волков512@email.ru	4590	219879	2025-09-16	1986-03-24
90337	Татьяна	Козлов	+7-962-742-99-77	татьяна.козлов513@email.ru	4518	760584	2025-09-16	1975-04-15
90338	Михаил	Козлов	+7-914-869-79-50	михаил.козлов514@email.ru	4528	798036	2025-09-16	2005-11-29
90339	Сергей	Иванов	+7-952-660-56-64	сергей.иванов515@email.ru	4593	420323	2025-09-16	1959-07-01
90340	Анна	Смирнов	+7-972-549-67-88	анна.смирнов516@email.ru	4506	157829	2025-09-16	1957-04-25
90341	Михаил	Кузнецов	+7-910-843-43-92	михаил.кузнецов517@email.ru	4526	817864	2025-09-16	1973-04-04
90342	Владимир	Иванов	+7-983-870-86-11	владимир.иванов518@email.ru	4581	225396	2025-09-16	1958-07-15
90343	Марина	Кузнецов	+7-985-776-69-52	марина.кузнецов519@email.ru	4522	800502	2025-09-16	1998-10-11
90344	Игорь	Кузнецов	+7-941-850-53-83	игорь.кузнецов520@email.ru	4533	455867	2025-09-16	1974-04-05
90345	Марина	Новиков	+7-952-888-83-84	марина.новиков521@email.ru	4542	607563	2025-09-16	1986-07-24
90346	Марина	Петров	+7-942-323-84-29	марина.петров522@email.ru	4543	780073	2025-09-16	1981-05-19
90347	Елена	Смирнов	+7-990-816-85-42	елена.смирнов523@email.ru	4557	964534	2025-09-16	1979-01-26
90348	Татьяна	Волков	+7-914-413-29-15	татьяна.волков524@email.ru	4531	774049	2025-09-16	2000-06-18
90349	Сергей	Попов	+7-919-750-94-84	сергей.попов525@email.ru	4557	473963	2025-09-16	2006-08-31
90350	Марина	Кузнецов	+7-918-424-64-60	марина.кузнецов526@email.ru	4511	379309	2025-09-16	2003-05-15
90351	Татьяна	Михайлов	+7-904-699-17-43	татьяна.михайлов527@email.ru	4532	754677	2025-09-16	1957-04-20
90352	Наталья	Попов	+7-987-604-48-58	наталья.попов528@email.ru	4513	812936	2025-09-16	1988-11-02
90353	Сергей	Попов	+7-983-694-39-57	сергей.попов529@email.ru	4545	714190	2025-09-16	1982-11-01
90354	Татьяна	Петров	+7-950-386-67-36	татьяна.петров530@email.ru	4536	758259	2025-09-16	1996-10-23
90355	Дмитрий	Лебедев	+7-934-823-44-19	дмитрий.лебедев531@email.ru	4536	632522	2025-09-16	1960-02-28
90356	Игорь	Лебедев	+7-981-672-51-23	игорь.лебедев532@email.ru	4573	645734	2025-09-16	1960-02-12
90357	Владимир	Петров	+7-913-726-19-44	владимир.петров533@email.ru	4542	135594	2025-09-16	1966-03-07
90358	Ольга	Волков	+7-960-876-51-14	ольга.волков534@email.ru	4588	376664	2025-09-16	2003-01-07
90359	Марина	Козлов	+7-972-629-25-80	марина.козлов535@email.ru	4579	940922	2025-09-16	1975-09-24
90360	Ольга	Кузнецов	+7-955-234-93-52	ольга.кузнецов536@email.ru	4557	856040	2025-09-16	1993-06-03
90361	Дмитрий	Морозов	+7-992-388-56-56	дмитрий.морозов537@email.ru	4554	957731	2025-09-16	1967-06-03
90362	Татьяна	Новиков	+7-984-537-73-82	татьяна.новиков538@email.ru	4509	649789	2025-09-16	1968-11-27
90363	Александр	Лебедев	+7-953-526-58-77	александр.лебедев539@email.ru	4522	956478	2025-09-16	1956-01-04
90364	Александр	Попов	+7-949-776-19-63	александр.попов540@email.ru	4571	402563	2025-09-16	1984-07-28
90365	Владимир	Соколов	+7-985-256-55-27	владимир.соколов541@email.ru	4584	459737	2025-09-16	1980-11-12
90366	Ирина	Фёдоров	+7-934-351-43-32	ирина.фёдоров542@email.ru	4588	233256	2025-09-16	1956-11-18
90367	Анна	Волков	+7-973-607-75-63	анна.волков543@email.ru	4503	974957	2025-09-16	1961-06-16
90368	Елена	Попов	+7-945-444-14-87	елена.попов544@email.ru	4536	229915	2025-09-16	1981-09-11
90369	Ольга	Козлов	+7-992-864-87-58	ольга.козлов545@email.ru	4585	412176	2025-09-16	1968-05-31
90370	Ирина	Новиков	+7-993-184-32-84	ирина.новиков546@email.ru	4563	459096	2025-09-16	1969-09-15
90371	Михаил	Михайлов	+7-913-919-41-63	михаил.михайлов547@email.ru	4582	127851	2025-09-16	1997-09-15
90372	Дмитрий	Сидоров	+7-986-322-52-67	дмитрий.сидоров548@email.ru	4529	296862	2025-09-16	1970-11-30
90373	Марина	Михайлов	+7-941-649-84-86	марина.михайлов549@email.ru	4548	785519	2025-09-16	1993-03-08
90374	Дмитрий	Новиков	+7-900-371-42-70	дмитрий.новиков550@email.ru	4525	206762	2025-09-16	1986-11-25
90375	Ольга	Соколов	+7-991-763-83-16	ольга.соколов551@email.ru	4587	692748	2025-09-16	1982-01-01
90376	Елена	Петров	+7-936-242-49-46	елена.петров552@email.ru	4591	622445	2025-09-16	1959-02-04
90377	Ирина	Фёдоров	+7-907-265-12-58	ирина.фёдоров553@email.ru	4522	532207	2025-09-16	1983-03-19
90378	Александр	Козлов	+7-965-461-69-67	александр.козлов554@email.ru	4578	664431	2025-09-16	1977-06-21
90379	Ольга	Соколов	+7-951-383-42-83	ольга.соколов555@email.ru	4571	864168	2025-09-16	1991-04-07
90380	Анна	Волков	+7-920-189-25-75	анна.волков556@email.ru	4592	985612	2025-09-16	1991-11-14
90381	Сергей	Сидоров	+7-929-615-29-14	сергей.сидоров557@email.ru	4533	678369	2025-09-16	1971-01-11
90382	Михаил	Волков	+7-938-890-71-16	михаил.волков558@email.ru	4519	703764	2025-09-16	1970-01-03
90383	Елена	Смирнов	+7-958-130-69-38	елена.смирнов559@email.ru	4547	822932	2025-09-16	2006-04-25
90384	Татьяна	Петров	+7-926-674-46-81	татьяна.петров560@email.ru	4530	963196	2025-09-16	1998-12-06
90385	Сергей	Сидоров	+7-906-151-76-56	сергей.сидоров561@email.ru	4503	838276	2025-09-16	2005-10-04
90386	Ольга	Фёдоров	+7-970-787-62-53	ольга.фёдоров562@email.ru	4565	485213	2025-09-16	2006-08-13
90387	Ольга	Иванов	+7-971-250-39-87	ольга.иванов563@email.ru	4509	719314	2025-09-16	1968-03-25
90388	Ирина	Новиков	+7-921-188-56-60	ирина.новиков564@email.ru	4531	296962	2025-09-16	1982-02-21
90389	Александр	Новиков	+7-928-890-81-89	александр.новиков565@email.ru	4570	641796	2025-09-16	1990-05-12
90390	Михаил	Лебедев	+7-901-825-76-86	михаил.лебедев566@email.ru	4504	711629	2025-09-16	1958-10-20
90391	Дмитрий	Иванов	+7-983-325-87-29	дмитрий.иванов567@email.ru	4502	890724	2025-09-16	1962-09-01
90392	Марина	Попов	+7-939-252-49-46	марина.попов568@email.ru	4564	618648	2025-09-16	1967-06-03
90393	Дмитрий	Попов	+7-998-435-26-67	дмитрий.попов569@email.ru	4547	761220	2025-09-16	1991-04-15
90394	Сергей	Волков	+7-927-263-47-64	сергей.волков570@email.ru	4565	259131	2025-09-16	1959-08-30
90395	Ольга	Петров	+7-973-538-94-83	ольга.петров571@email.ru	4512	161789	2025-09-16	2005-08-24
90396	Ольга	Соколов	+7-979-640-95-30	ольга.соколов572@email.ru	4507	700323	2025-09-16	1962-12-24
90397	Михаил	Волков	+7-974-491-86-21	михаил.волков573@email.ru	4571	713106	2025-09-16	1960-06-18
90398	Татьяна	Петров	+7-963-126-63-40	татьяна.петров574@email.ru	4588	612133	2025-09-16	1977-04-19
90399	Татьяна	Новиков	+7-954-931-55-42	татьяна.новиков575@email.ru	4536	549361	2025-09-16	1966-08-14
90400	Михаил	Михайлов	+7-988-594-84-54	михаил.михайлов576@email.ru	4548	909864	2025-09-16	1987-04-16
90401	Александр	Кузнецов	+7-950-469-42-81	александр.кузнецов577@email.ru	4588	768676	2025-09-16	2004-12-16
90402	Михаил	Петров	+7-908-122-94-97	михаил.петров578@email.ru	4522	421808	2025-09-16	1969-11-22
90403	Александр	Смирнов	+7-985-149-16-68	александр.смирнов579@email.ru	4559	995258	2025-09-16	1997-11-23
90404	Ирина	Новиков	+7-984-371-89-38	ирина.новиков580@email.ru	4571	348003	2025-09-16	1997-12-31
90405	Марина	Волков	+7-968-976-40-78	марина.волков581@email.ru	4580	369283	2025-09-16	1996-06-09
90406	Александр	Петров	+7-935-753-30-78	александр.петров582@email.ru	4563	402646	2025-09-16	1983-08-17
90407	Наталья	Новиков	+7-933-761-84-84	наталья.новиков583@email.ru	4513	557715	2025-09-16	1984-02-21
90408	Алексей	Новиков	+7-999-377-72-63	алексей.новиков584@email.ru	4553	862407	2025-09-16	1960-04-01
90409	Михаил	Морозов	+7-988-461-57-29	михаил.морозов585@email.ru	4502	415432	2025-09-16	1994-02-05
90410	Александр	Лебедев	+7-935-501-28-38	александр.лебедев586@email.ru	4598	736886	2025-09-16	1977-07-16
90411	Сергей	Новиков	+7-910-934-37-59	сергей.новиков587@email.ru	4527	304034	2025-09-16	1990-07-09
90412	Ольга	Новиков	+7-906-524-90-79	ольга.новиков588@email.ru	4539	145930	2025-09-16	2005-04-25
90413	Анна	Морозов	+7-960-422-69-62	анна.морозов589@email.ru	4555	596347	2025-09-16	1999-10-26
90414	Анна	Новиков	+7-957-121-55-12	анна.новиков590@email.ru	4560	838437	2025-09-16	1983-04-18
90415	Владимир	Козлов	+7-977-804-72-93	владимир.козлов591@email.ru	4524	667291	2025-09-16	1970-09-12
90416	Марина	Сидоров	+7-953-876-92-88	марина.сидоров592@email.ru	4546	312835	2025-09-16	1976-09-28
90417	Ольга	Кузнецов	+7-955-124-94-63	ольга.кузнецов593@email.ru	4517	786845	2025-09-16	2003-06-27
90418	Марина	Попов	+7-962-881-29-25	марина.попов594@email.ru	4568	753112	2025-09-16	1994-07-20
90419	Михаил	Лебедев	+7-911-746-84-19	михаил.лебедев595@email.ru	4508	691942	2025-09-16	2002-07-19
90420	Ольга	Лебедев	+7-943-369-40-36	ольга.лебедев596@email.ru	4587	959015	2025-09-16	2001-01-07
90421	Марина	Козлов	+7-992-346-72-83	марина.козлов597@email.ru	4582	310869	2025-09-16	1979-08-26
90422	Владимир	Козлов	+7-996-908-99-94	владимир.козлов598@email.ru	4549	686849	2025-09-16	1994-03-04
90423	Ольга	Попов	+7-909-716-78-31	ольга.попов599@email.ru	4597	916667	2025-09-16	1968-05-28
90424	Дмитрий	Лебедев	+7-972-287-45-69	дмитрий.лебедев600@email.ru	4502	221417	2025-09-16	1960-03-15
90425	Игорь	Новиков	+7-916-342-24-90	игорь.новиков601@email.ru	4575	687977	2025-09-16	1986-05-05
90426	Михаил	Кузнецов	+7-976-907-90-62	михаил.кузнецов602@email.ru	4517	935713	2025-09-16	1968-07-06
90427	Игорь	Смирнов	+7-995-237-81-92	игорь.смирнов603@email.ru	4572	240469	2025-09-16	1979-07-06
90428	Алексей	Смирнов	+7-985-953-38-83	алексей.смирнов604@email.ru	4539	688962	2025-09-16	1973-02-24
90429	Ирина	Сидоров	+7-982-322-45-86	ирина.сидоров605@email.ru	4544	841047	2025-09-16	1964-11-07
90430	Марина	Козлов	+7-955-130-74-77	марина.козлов606@email.ru	4538	900457	2025-09-16	1965-03-14
90431	Владимир	Козлов	+7-925-132-91-99	владимир.козлов607@email.ru	4526	609204	2025-09-16	1957-12-02
90432	Ирина	Лебедев	+7-946-864-35-35	ирина.лебедев608@email.ru	4552	748136	2025-09-16	1961-05-03
90433	Елена	Новиков	+7-991-367-23-50	елена.новиков609@email.ru	4576	711335	2025-09-16	1982-02-17
90434	Елена	Новиков	+7-912-630-27-99	елена.новиков610@email.ru	4548	571623	2025-09-16	1959-11-23
90435	Елена	Новиков	+7-925-444-25-21	елена.новиков611@email.ru	4588	458213	2025-09-16	1968-05-25
90436	Владимир	Петров	+7-929-430-77-43	владимир.петров612@email.ru	4506	702739	2025-09-16	1990-02-05
90437	Татьяна	Козлов	+7-975-686-98-49	татьяна.козлов613@email.ru	4577	549891	2025-09-16	1957-11-24
90438	Сергей	Иванов	+7-910-706-39-18	сергей.иванов614@email.ru	4591	353777	2025-09-16	1988-07-20
90439	Елена	Попов	+7-920-960-72-27	елена.попов615@email.ru	4541	966078	2025-09-16	1970-04-28
90440	Владимир	Козлов	+7-939-926-69-11	владимир.козлов616@email.ru	4594	988684	2025-09-16	1968-03-20
90441	Ирина	Соколов	+7-950-482-94-43	ирина.соколов617@email.ru	4556	125115	2025-09-16	1979-04-05
90442	Ольга	Лебедев	+7-954-336-64-89	ольга.лебедев618@email.ru	4547	437085	2025-09-16	1957-03-21
90443	Александр	Попов	+7-935-528-45-16	александр.попов619@email.ru	4510	431509	2025-09-16	1994-08-21
90444	Сергей	Морозов	+7-964-897-33-64	сергей.морозов620@email.ru	4557	359839	2025-09-16	1984-01-16
90445	Ольга	Волков	+7-935-424-15-59	ольга.волков621@email.ru	4563	292432	2025-09-16	1970-02-27
90446	Марина	Лебедев	+7-997-313-29-39	марина.лебедев622@email.ru	4554	915551	2025-09-16	1982-10-01
90447	Ирина	Новиков	+7-994-437-97-61	ирина.новиков623@email.ru	4595	519874	2025-09-16	1994-01-16
90448	Сергей	Попов	+7-994-941-60-98	сергей.попов624@email.ru	4570	998205	2025-09-16	1959-02-10
90449	Алексей	Лебедев	+7-937-326-38-77	алексей.лебедев625@email.ru	4578	844261	2025-09-16	1992-11-02
90450	Анна	Морозов	+7-922-103-74-14	анна.морозов626@email.ru	4537	859536	2025-09-16	1983-03-27
90451	Дмитрий	Михайлов	+7-933-731-23-88	дмитрий.михайлов627@email.ru	4588	914788	2025-09-16	1972-06-17
90452	Александр	Иванов	+7-919-915-29-66	александр.иванов628@email.ru	4527	882209	2025-09-16	1967-04-23
90453	Игорь	Фёдоров	+7-933-917-91-38	игорь.фёдоров629@email.ru	4547	549656	2025-09-16	1982-04-14
90454	Дмитрий	Козлов	+7-925-867-54-30	дмитрий.козлов630@email.ru	4561	565114	2025-09-16	1955-11-24
90455	Владимир	Лебедев	+7-976-264-67-18	владимир.лебедев631@email.ru	4519	287849	2025-09-16	1992-12-03
90456	Наталья	Сидоров	+7-966-473-59-61	наталья.сидоров632@email.ru	4540	467177	2025-09-16	1956-11-12
90457	Марина	Михайлов	+7-978-205-58-91	марина.михайлов633@email.ru	4524	554629	2025-09-16	2003-04-13
90458	Владимир	Михайлов	+7-943-625-61-17	владимир.михайлов634@email.ru	4504	682074	2025-09-16	1995-11-08
90459	Сергей	Петров	+7-942-241-67-15	сергей.петров635@email.ru	4511	893444	2025-09-16	1970-07-08
90460	Алексей	Михайлов	+7-938-821-15-21	алексей.михайлов636@email.ru	4500	961261	2025-09-16	1966-06-07
90461	Алексей	Михайлов	+7-918-562-80-12	алексей.михайлов637@email.ru	4550	530299	2025-09-16	2006-06-21
90462	Сергей	Лебедев	+7-979-103-63-24	сергей.лебедев638@email.ru	4590	560440	2025-09-16	1998-09-05
90463	Наталья	Смирнов	+7-935-522-47-83	наталья.смирнов639@email.ru	4591	894966	2025-09-16	1976-07-18
90464	Ирина	Морозов	+7-902-794-83-59	ирина.морозов640@email.ru	4540	544267	2025-09-16	1967-06-29
90465	Ирина	Лебедев	+7-913-139-88-22	ирина.лебедев641@email.ru	4568	829838	2025-09-16	1994-05-01
90466	Марина	Кузнецов	+7-989-504-53-75	марина.кузнецов642@email.ru	4515	900349	2025-09-16	1974-10-07
90467	Наталья	Волков	+7-917-394-86-66	наталья.волков643@email.ru	4548	530784	2025-09-16	2007-01-12
90468	Наталья	Фёдоров	+7-942-679-44-58	наталья.фёдоров644@email.ru	4500	303237	2025-09-16	1962-04-22
90469	Ирина	Фёдоров	+7-963-604-42-92	ирина.фёдоров645@email.ru	4572	428390	2025-09-16	2001-09-18
90470	Алексей	Иванов	+7-994-353-90-56	алексей.иванов646@email.ru	4580	776187	2025-09-16	1960-02-06
90471	Наталья	Михайлов	+7-970-467-93-96	наталья.михайлов647@email.ru	4578	941433	2025-09-16	1979-07-07
90472	Марина	Соколов	+7-979-909-63-43	марина.соколов648@email.ru	4596	358902	2025-09-16	1998-07-09
90473	Михаил	Новиков	+7-926-689-12-37	михаил.новиков649@email.ru	4541	189779	2025-09-16	1991-03-01
90474	Дмитрий	Смирнов	+7-923-144-66-98	дмитрий.смирнов650@email.ru	4560	232719	2025-09-16	1987-05-05
90475	Михаил	Иванов	+7-983-539-50-31	михаил.иванов651@email.ru	4593	471117	2025-09-16	1964-08-20
90476	Марина	Михайлов	+7-999-418-21-64	марина.михайлов652@email.ru	4552	485118	2025-09-16	1996-06-14
90477	Анна	Кузнецов	+7-969-328-67-89	анна.кузнецов653@email.ru	4547	792041	2025-09-16	1987-08-04
90478	Игорь	Фёдоров	+7-915-294-62-86	игорь.фёдоров654@email.ru	4540	236348	2025-09-16	1966-03-16
90479	Владимир	Волков	+7-973-895-83-53	владимир.волков655@email.ru	4524	952588	2025-09-16	1992-02-09
90480	Татьяна	Козлов	+7-964-617-33-37	татьяна.козлов656@email.ru	4597	313037	2025-09-16	1980-03-09
90481	Елена	Лебедев	+7-934-228-90-87	елена.лебедев657@email.ru	4548	373548	2025-09-16	2002-03-01
90482	Ольга	Попов	+7-967-716-99-92	ольга.попов658@email.ru	4533	494870	2025-09-16	1994-09-16
90483	Марина	Лебедев	+7-984-948-70-17	марина.лебедев659@email.ru	4502	799090	2025-09-16	2001-11-06
90484	Дмитрий	Морозов	+7-928-100-61-49	дмитрий.морозов660@email.ru	4562	626351	2025-09-16	1979-12-16
90485	Ирина	Сидоров	+7-938-751-21-87	ирина.сидоров661@email.ru	4554	974601	2025-09-16	2000-10-03
90486	Елена	Козлов	+7-988-760-66-97	елена.козлов662@email.ru	4512	951357	2025-09-16	1974-07-13
90487	Ольга	Попов	+7-973-789-96-10	ольга.попов663@email.ru	4576	720392	2025-09-16	2002-11-27
90488	Татьяна	Новиков	+7-932-315-17-54	татьяна.новиков664@email.ru	4543	624660	2025-09-16	1991-12-04
90489	Анна	Лебедев	+7-981-490-74-59	анна.лебедев665@email.ru	4539	197206	2025-09-16	1991-12-01
90490	Сергей	Иванов	+7-954-510-48-86	сергей.иванов666@email.ru	4573	586430	2025-09-16	1985-03-18
90491	Игорь	Попов	+7-976-327-80-47	игорь.попов667@email.ru	4544	609855	2025-09-16	1965-02-26
90492	Анна	Иванов	+7-974-198-91-40	анна.иванов668@email.ru	4587	976130	2025-09-16	1956-07-26
90493	Татьяна	Иванов	+7-924-145-97-86	татьяна.иванов669@email.ru	4537	200469	2025-09-16	1958-08-23
90494	Татьяна	Морозов	+7-930-236-58-20	татьяна.морозов670@email.ru	4574	495166	2025-09-16	2005-09-09
90495	Наталья	Кузнецов	+7-957-881-41-66	наталья.кузнецов671@email.ru	4581	960916	2025-09-16	1975-05-02
90496	Марина	Морозов	+7-964-743-66-91	марина.морозов672@email.ru	4596	917151	2025-09-16	1994-05-26
90497	Михаил	Новиков	+7-950-230-76-12	михаил.новиков673@email.ru	4530	102861	2025-09-16	2003-01-21
90498	Сергей	Морозов	+7-939-891-48-21	сергей.морозов674@email.ru	4593	654748	2025-09-16	1990-12-04
90499	Наталья	Михайлов	+7-955-149-64-28	наталья.михайлов675@email.ru	4509	865452	2025-09-16	1985-03-14
90500	Наталья	Петров	+7-946-931-23-14	наталья.петров676@email.ru	4562	812618	2025-09-16	1980-03-21
90501	Елена	Волков	+7-900-756-71-34	елена.волков677@email.ru	4508	686918	2025-09-16	1994-03-03
90502	Дмитрий	Козлов	+7-951-446-31-45	дмитрий.козлов678@email.ru	4590	388396	2025-09-16	2003-07-29
90503	Михаил	Попов	+7-942-508-57-26	михаил.попов679@email.ru	4505	183989	2025-09-16	1977-08-24
90504	Владимир	Смирнов	+7-999-237-26-82	владимир.смирнов680@email.ru	4522	743055	2025-09-16	1982-06-18
90505	Анна	Михайлов	+7-912-128-73-74	анна.михайлов681@email.ru	4589	996260	2025-09-16	1981-10-03
90506	Елена	Иванов	+7-979-140-69-50	елена.иванов682@email.ru	4539	487509	2025-09-16	1984-12-22
90507	Ольга	Иванов	+7-944-726-51-97	ольга.иванов683@email.ru	4589	117270	2025-09-16	1991-02-07
90508	Александр	Фёдоров	+7-934-893-71-29	александр.фёдоров684@email.ru	4516	290695	2025-09-16	2004-04-14
90509	Татьяна	Петров	+7-905-954-76-20	татьяна.петров685@email.ru	4532	677476	2025-09-16	1981-08-07
90510	Ирина	Сидоров	+7-979-730-21-33	ирина.сидоров686@email.ru	4514	788050	2025-09-16	1998-09-03
90511	Елена	Соколов	+7-998-177-53-21	елена.соколов687@email.ru	4590	694060	2025-09-16	1996-06-17
90512	Александр	Михайлов	+7-918-462-42-30	александр.михайлов688@email.ru	4559	615379	2025-09-16	1975-01-16
90513	Ольга	Фёдоров	+7-922-523-35-92	ольга.фёдоров689@email.ru	4563	386677	2025-09-16	1980-01-08
90514	Марина	Кузнецов	+7-961-871-24-29	марина.кузнецов690@email.ru	4555	342068	2025-09-16	1985-12-20
90515	Марина	Михайлов	+7-911-961-24-40	марина.михайлов691@email.ru	4528	431503	2025-09-16	1999-04-21
90516	Марина	Кузнецов	+7-959-984-40-98	марина.кузнецов692@email.ru	4594	741518	2025-09-16	1975-09-25
90517	Владимир	Петров	+7-948-511-72-82	владимир.петров693@email.ru	4561	970029	2025-09-16	2003-01-14
90518	Татьяна	Лебедев	+7-962-475-70-36	татьяна.лебедев694@email.ru	4500	439642	2025-09-16	1993-05-13
90519	Сергей	Фёдоров	+7-904-730-93-66	сергей.фёдоров695@email.ru	4508	181016	2025-09-16	2007-08-16
90520	Александр	Морозов	+7-933-428-54-18	александр.морозов696@email.ru	4548	777306	2025-09-16	1961-02-06
90521	Дмитрий	Соколов	+7-973-390-75-55	дмитрий.соколов697@email.ru	4569	902026	2025-09-16	1982-11-19
90522	Михаил	Смирнов	+7-919-443-43-30	михаил.смирнов698@email.ru	4570	582962	2025-09-16	1968-09-01
90523	Наталья	Смирнов	+7-988-884-80-26	наталья.смирнов699@email.ru	4556	118883	2025-09-16	1964-07-17
90524	Анна	Волков	+7-933-668-33-83	анна.волков700@email.ru	4508	714094	2025-09-16	2005-09-16
90525	Александр	Михайлов	+7-900-967-97-10	александр.михайлов701@email.ru	4577	217722	2025-09-16	2007-04-02
90526	Игорь	Петров	+7-915-553-88-47	игорь.петров702@email.ru	4524	569122	2025-09-16	2001-12-13
90527	Елена	Фёдоров	+7-983-182-52-79	елена.фёдоров703@email.ru	4526	636305	2025-09-16	2001-09-08
90528	Александр	Лебедев	+7-934-215-90-94	александр.лебедев704@email.ru	4501	551800	2025-09-16	2007-01-31
90529	Анна	Фёдоров	+7-985-191-95-61	анна.фёдоров705@email.ru	4589	688587	2025-09-16	1995-01-27
90530	Дмитрий	Михайлов	+7-972-486-68-38	дмитрий.михайлов706@email.ru	4577	548691	2025-09-16	1962-07-11
90531	Татьяна	Попов	+7-989-425-53-99	татьяна.попов707@email.ru	4521	636243	2025-09-16	1978-01-29
90532	Михаил	Соколов	+7-999-576-81-31	михаил.соколов708@email.ru	4582	477110	2025-09-16	1987-11-25
90533	Сергей	Сидоров	+7-970-267-89-48	сергей.сидоров709@email.ru	4561	426894	2025-09-16	1988-10-05
90534	Сергей	Фёдоров	+7-983-661-32-31	сергей.фёдоров710@email.ru	4524	441633	2025-09-16	1958-12-19
90535	Дмитрий	Волков	+7-928-292-36-67	дмитрий.волков711@email.ru	4523	310341	2025-09-16	1975-12-11
90536	Марина	Новиков	+7-997-370-51-99	марина.новиков712@email.ru	4579	748134	2025-09-16	1978-11-08
90537	Наталья	Соколов	+7-982-508-73-14	наталья.соколов713@email.ru	4586	947865	2025-09-16	1990-10-11
90538	Анна	Петров	+7-960-877-91-59	анна.петров714@email.ru	4538	838333	2025-09-16	1981-12-20
90539	Сергей	Новиков	+7-909-817-53-15	сергей.новиков715@email.ru	4575	187949	2025-09-16	1989-10-16
90540	Ирина	Попов	+7-911-399-45-35	ирина.попов716@email.ru	4544	199505	2025-09-16	1955-12-17
90541	Ольга	Козлов	+7-994-507-83-21	ольга.козлов717@email.ru	4576	790351	2025-09-16	1965-01-02
90542	Марина	Сидоров	+7-915-667-87-35	марина.сидоров718@email.ru	4574	915221	2025-09-16	1976-10-29
90543	Владимир	Волков	+7-920-229-70-68	владимир.волков719@email.ru	4587	331395	2025-09-16	1997-08-19
90544	Дмитрий	Новиков	+7-904-970-69-78	дмитрий.новиков720@email.ru	4572	274054	2025-09-16	1992-01-16
90545	Ирина	Петров	+7-939-825-95-36	ирина.петров721@email.ru	4529	245441	2025-09-16	2005-03-31
90546	Михаил	Петров	+7-968-675-83-94	михаил.петров722@email.ru	4553	706266	2025-09-16	1968-07-19
90547	Татьяна	Михайлов	+7-969-384-95-27	татьяна.михайлов723@email.ru	4570	482757	2025-09-16	1975-08-19
90548	Александр	Попов	+7-998-638-28-92	александр.попов724@email.ru	4502	486255	2025-09-16	1967-08-23
90549	Михаил	Смирнов	+7-997-304-37-45	михаил.смирнов725@email.ru	4537	412168	2025-09-16	1980-11-29
90550	Александр	Морозов	+7-994-962-59-81	александр.морозов726@email.ru	4503	165371	2025-09-16	1964-07-27
90551	Дмитрий	Лебедев	+7-934-124-27-47	дмитрий.лебедев727@email.ru	4521	365669	2025-09-16	2007-01-23
90552	Ольга	Соколов	+7-913-860-53-30	ольга.соколов728@email.ru	4501	219920	2025-09-16	1982-12-01
90553	Сергей	Лебедев	+7-920-810-51-91	сергей.лебедев729@email.ru	4566	961006	2025-09-16	1989-10-01
90554	Татьяна	Фёдоров	+7-943-984-49-65	татьяна.фёдоров730@email.ru	4569	627011	2025-09-16	2004-10-26
90555	Марина	Новиков	+7-925-319-50-30	марина.новиков731@email.ru	4598	132956	2025-09-16	1999-08-31
90556	Дмитрий	Фёдоров	+7-997-648-34-94	дмитрий.фёдоров732@email.ru	4510	138731	2025-09-16	1980-04-18
90557	Ольга	Волков	+7-973-567-99-93	ольга.волков733@email.ru	4561	956264	2025-09-16	1981-06-11
90558	Татьяна	Петров	+7-968-806-42-28	татьяна.петров734@email.ru	4511	779685	2025-09-16	1999-08-20
90559	Ирина	Волков	+7-966-972-41-26	ирина.волков735@email.ru	4560	387624	2025-09-16	1965-05-16
90560	Алексей	Сидоров	+7-947-972-76-31	алексей.сидоров736@email.ru	4586	119815	2025-09-16	1968-11-08
90561	Александр	Лебедев	+7-955-456-86-52	александр.лебедев737@email.ru	4530	683077	2025-09-16	1956-05-08
90562	Татьяна	Фёдоров	+7-962-895-41-26	татьяна.фёдоров738@email.ru	4514	500876	2025-09-16	1979-12-02
90563	Ирина	Михайлов	+7-916-761-97-96	ирина.михайлов739@email.ru	4521	260730	2025-09-16	1958-04-16
90564	Марина	Лебедев	+7-937-487-41-70	марина.лебедев740@email.ru	4545	130082	2025-09-16	1994-03-25
90565	Татьяна	Петров	+7-918-245-97-91	татьяна.петров741@email.ru	4546	917181	2025-09-16	1999-12-11
90566	Ольга	Михайлов	+7-903-581-13-80	ольга.михайлов742@email.ru	4554	830223	2025-09-16	1967-07-23
90567	Наталья	Попов	+7-918-422-68-83	наталья.попов743@email.ru	4551	887645	2025-09-16	1979-07-22
90568	Дмитрий	Попов	+7-955-552-65-50	дмитрий.попов744@email.ru	4553	151189	2025-09-16	1979-03-27
90569	Ирина	Кузнецов	+7-904-980-49-21	ирина.кузнецов745@email.ru	4512	455247	2025-09-16	1962-02-04
90570	Михаил	Петров	+7-982-936-29-29	михаил.петров746@email.ru	4539	496414	2025-09-16	2003-10-13
90571	Марина	Сидоров	+7-996-529-10-82	марина.сидоров747@email.ru	4597	292736	2025-09-16	1977-07-31
90572	Наталья	Петров	+7-970-987-63-62	наталья.петров748@email.ru	4552	894052	2025-09-16	1962-03-31
90573	Наталья	Новиков	+7-973-880-38-33	наталья.новиков749@email.ru	4547	128668	2025-09-16	1999-03-15
90574	Александр	Козлов	+7-976-412-56-93	александр.козлов750@email.ru	4562	545167	2025-09-16	1956-08-02
90575	Дмитрий	Сидоров	+7-941-345-78-87	дмитрий.сидоров751@email.ru	4535	661892	2025-09-16	1974-02-04
90576	Дмитрий	Попов	+7-919-359-11-80	дмитрий.попов752@email.ru	4523	248989	2025-09-16	1958-07-10
90577	Елена	Иванов	+7-958-249-13-43	елена.иванов753@email.ru	4555	898615	2025-09-16	1967-02-08
90578	Марина	Сидоров	+7-914-228-12-45	марина.сидоров754@email.ru	4520	912623	2025-09-16	1998-03-30
90579	Игорь	Петров	+7-958-186-73-31	игорь.петров755@email.ru	4503	925656	2025-09-16	1978-04-05
90580	Игорь	Иванов	+7-954-254-90-26	игорь.иванов756@email.ru	4553	372341	2025-09-16	1968-12-27
90581	Татьяна	Смирнов	+7-988-242-35-88	татьяна.смирнов757@email.ru	4510	584364	2025-09-16	1958-07-08
90582	Ольга	Кузнецов	+7-943-816-92-50	ольга.кузнецов758@email.ru	4549	262445	2025-09-16	1976-12-03
90583	Наталья	Новиков	+7-989-395-16-69	наталья.новиков759@email.ru	4566	357562	2025-09-16	1957-11-29
90584	Наталья	Морозов	+7-912-802-38-82	наталья.морозов760@email.ru	4568	426778	2025-09-16	1986-09-25
90585	Игорь	Смирнов	+7-924-674-16-35	игорь.смирнов761@email.ru	4582	617236	2025-09-16	1979-06-26
90586	Ольга	Волков	+7-933-900-58-65	ольга.волков762@email.ru	4521	154141	2025-09-16	1983-11-09
90587	Алексей	Фёдоров	+7-907-225-42-48	алексей.фёдоров763@email.ru	4583	648136	2025-09-16	1994-03-15
90588	Татьяна	Морозов	+7-913-993-12-42	татьяна.морозов764@email.ru	4537	702400	2025-09-16	1973-05-13
90589	Наталья	Кузнецов	+7-937-963-60-51	наталья.кузнецов765@email.ru	4589	709370	2025-09-16	1988-07-08
90590	Анна	Смирнов	+7-915-205-22-18	анна.смирнов766@email.ru	4584	478482	2025-09-16	1971-06-12
90591	Наталья	Петров	+7-964-925-62-93	наталья.петров767@email.ru	4585	330471	2025-09-16	1978-09-10
90592	Игорь	Волков	+7-957-213-70-70	игорь.волков768@email.ru	4512	620579	2025-09-16	1981-08-03
90593	Елена	Морозов	+7-958-691-36-50	елена.морозов769@email.ru	4513	767309	2025-09-16	1996-09-05
90594	Ирина	Морозов	+7-965-430-95-24	ирина.морозов770@email.ru	4575	543658	2025-09-16	1974-11-17
90595	Александр	Петров	+7-916-287-88-86	александр.петров771@email.ru	4540	474437	2025-09-16	2001-06-20
90596	Игорь	Смирнов	+7-949-497-61-34	игорь.смирнов772@email.ru	4560	662181	2025-09-16	1961-08-27
90597	Марина	Сидоров	+7-925-268-74-55	марина.сидоров773@email.ru	4535	378886	2025-09-16	1970-01-23
90598	Марина	Фёдоров	+7-919-705-37-86	марина.фёдоров774@email.ru	4543	174850	2025-09-16	1962-05-25
90599	Марина	Иванов	+7-909-990-16-59	марина.иванов775@email.ru	4542	957628	2025-09-16	1957-12-15
90600	Игорь	Сидоров	+7-967-343-48-60	игорь.сидоров776@email.ru	4536	576418	2025-09-16	1958-06-30
90601	Сергей	Морозов	+7-973-797-60-37	сергей.морозов777@email.ru	4547	792733	2025-09-16	1959-11-24
90602	Марина	Лебедев	+7-905-478-13-75	марина.лебедев778@email.ru	4549	792379	2025-09-16	1958-10-26
90603	Владимир	Кузнецов	+7-992-949-71-57	владимир.кузнецов779@email.ru	4508	244234	2025-09-16	1964-09-03
90604	Дмитрий	Новиков	+7-978-926-37-51	дмитрий.новиков780@email.ru	4521	218975	2025-09-16	1985-03-06
90605	Михаил	Сидоров	+7-909-878-71-32	михаил.сидоров781@email.ru	4577	179086	2025-09-16	1958-01-18
90606	Марина	Сидоров	+7-991-611-62-29	марина.сидоров782@email.ru	4557	880438	2025-09-16	1962-01-09
90607	Ольга	Фёдоров	+7-935-606-35-41	ольга.фёдоров783@email.ru	4575	988860	2025-09-16	1996-10-15
90608	Анна	Михайлов	+7-933-529-24-69	анна.михайлов784@email.ru	4536	588792	2025-09-16	1983-01-26
90609	Дмитрий	Михайлов	+7-918-297-62-89	дмитрий.михайлов785@email.ru	4585	742480	2025-09-16	1996-04-10
90610	Алексей	Лебедев	+7-931-591-32-80	алексей.лебедев786@email.ru	4586	298899	2025-09-16	2005-07-10
90611	Наталья	Волков	+7-979-160-73-13	наталья.волков787@email.ru	4566	846054	2025-09-16	1969-07-27
90612	Ирина	Новиков	+7-996-420-86-10	ирина.новиков788@email.ru	4528	732200	2025-09-16	1972-11-26
90613	Марина	Кузнецов	+7-952-119-60-79	марина.кузнецов789@email.ru	4587	625174	2025-09-16	1976-12-26
90614	Михаил	Попов	+7-980-834-84-82	михаил.попов790@email.ru	4529	118202	2025-09-16	1977-10-31
90615	Дмитрий	Попов	+7-995-528-46-46	дмитрий.попов791@email.ru	4570	619088	2025-09-16	1964-02-23
90616	Михаил	Попов	+7-977-750-37-67	михаил.попов792@email.ru	4593	898955	2025-09-16	1997-01-01
90617	Дмитрий	Фёдоров	+7-949-805-94-17	дмитрий.фёдоров793@email.ru	4578	145852	2025-09-16	1967-07-20
90618	Марина	Соколов	+7-948-132-77-16	марина.соколов794@email.ru	4550	729160	2025-09-16	1958-07-05
90619	Анна	Сидоров	+7-952-135-33-95	анна.сидоров795@email.ru	4533	838950	2025-09-16	1994-06-23
90620	Игорь	Кузнецов	+7-977-164-31-16	игорь.кузнецов796@email.ru	4505	601613	2025-09-16	1980-05-31
90621	Сергей	Лебедев	+7-996-331-55-90	сергей.лебедев797@email.ru	4508	479706	2025-09-16	1961-03-05
90622	Ирина	Попов	+7-909-962-23-27	ирина.попов798@email.ru	4525	620404	2025-09-16	1962-04-14
90623	Марина	Кузнецов	+7-966-489-16-60	марина.кузнецов799@email.ru	4560	547158	2025-09-16	1981-07-16
90624	Наталья	Михайлов	+7-957-273-40-44	наталья.михайлов800@email.ru	4571	553364	2025-09-16	1970-03-19
90625	Татьяна	Иванов	+7-974-482-23-13	татьяна.иванов801@email.ru	4514	137498	2025-09-16	1969-05-28
90626	Дмитрий	Попов	+7-966-579-81-95	дмитрий.попов802@email.ru	4597	141309	2025-09-16	1996-01-02
90627	Марина	Козлов	+7-997-980-15-38	марина.козлов803@email.ru	4546	987591	2025-09-16	1980-10-09
90628	Алексей	Новиков	+7-981-835-78-46	алексей.новиков804@email.ru	4509	231242	2025-09-16	1956-07-28
90629	Алексей	Фёдоров	+7-974-984-56-73	алексей.фёдоров805@email.ru	4561	583496	2025-09-16	1970-09-09
90630	Марина	Попов	+7-951-942-19-45	марина.попов806@email.ru	4507	928013	2025-09-16	1984-05-04
90631	Ольга	Попов	+7-931-278-31-89	ольга.попов807@email.ru	4512	103511	2025-09-16	1995-08-08
90632	Ирина	Кузнецов	+7-967-744-70-70	ирина.кузнецов808@email.ru	4599	567189	2025-09-16	1988-12-05
90633	Марина	Козлов	+7-951-464-25-26	марина.козлов809@email.ru	4588	588080	2025-09-16	1959-09-02
90634	Елена	Смирнов	+7-904-475-36-92	елена.смирнов810@email.ru	4564	196782	2025-09-16	1987-07-13
90635	Ирина	Волков	+7-902-952-58-32	ирина.волков811@email.ru	4524	792541	2025-09-16	1970-11-01
90636	Владимир	Морозов	+7-930-941-48-48	владимир.морозов812@email.ru	4553	723616	2025-09-16	1985-02-14
90637	Дмитрий	Лебедев	+7-947-466-84-54	дмитрий.лебедев813@email.ru	4505	350317	2025-09-16	1998-02-23
90638	Михаил	Волков	+7-998-647-74-36	михаил.волков814@email.ru	4587	244093	2025-09-16	2001-06-01
90639	Александр	Новиков	+7-986-199-73-16	александр.новиков815@email.ru	4501	636515	2025-09-16	1970-01-01
90640	Дмитрий	Соколов	+7-986-603-48-57	дмитрий.соколов816@email.ru	4509	509408	2025-09-16	1978-11-17
90641	Наталья	Попов	+7-919-521-80-87	наталья.попов817@email.ru	4505	748302	2025-09-16	1966-07-20
90642	Алексей	Соколов	+7-965-815-91-26	алексей.соколов818@email.ru	4599	838496	2025-09-16	1956-11-30
90643	Владимир	Фёдоров	+7-902-226-95-38	владимир.фёдоров819@email.ru	4534	199453	2025-09-16	1990-11-12
90644	Алексей	Смирнов	+7-946-341-99-92	алексей.смирнов820@email.ru	4585	624115	2025-09-16	1959-10-06
90645	Владимир	Фёдоров	+7-974-253-13-18	владимир.фёдоров821@email.ru	4594	589098	2025-09-16	1973-01-21
90646	Ирина	Сидоров	+7-966-317-10-60	ирина.сидоров822@email.ru	4533	755887	2025-09-16	1978-05-03
90647	Татьяна	Лебедев	+7-997-419-29-97	татьяна.лебедев823@email.ru	4545	244086	2025-09-16	2001-02-28
90648	Сергей	Фёдоров	+7-924-598-70-78	сергей.фёдоров824@email.ru	4570	637272	2025-09-16	1994-10-20
90649	Ирина	Лебедев	+7-954-466-80-91	ирина.лебедев825@email.ru	4516	408252	2025-09-16	1996-12-18
90650	Наталья	Смирнов	+7-905-555-21-76	наталья.смирнов826@email.ru	4562	517745	2025-09-16	1983-05-16
90651	Ольга	Попов	+7-992-454-93-10	ольга.попов827@email.ru	4525	636026	2025-09-16	1976-01-26
90652	Марина	Кузнецов	+7-911-216-46-32	марина.кузнецов828@email.ru	4547	878362	2025-09-16	1993-02-18
90653	Алексей	Лебедев	+7-992-505-15-43	алексей.лебедев829@email.ru	4519	380311	2025-09-16	2003-10-04
90654	Наталья	Козлов	+7-969-258-57-83	наталья.козлов830@email.ru	4531	762044	2025-09-16	1982-02-22
90655	Татьяна	Новиков	+7-994-944-27-44	татьяна.новиков831@email.ru	4554	980428	2025-09-16	1970-08-24
90656	Ольга	Смирнов	+7-950-838-43-32	ольга.смирнов832@email.ru	4535	503138	2025-09-16	1987-09-20
90657	Анна	Новиков	+7-911-551-21-66	анна.новиков833@email.ru	4506	440554	2025-09-16	1982-05-13
90658	Владимир	Смирнов	+7-921-925-37-72	владимир.смирнов834@email.ru	4539	842489	2025-09-16	2005-05-17
90659	Татьяна	Морозов	+7-905-707-84-40	татьяна.морозов835@email.ru	4598	226345	2025-09-16	1988-08-23
90660	Наталья	Смирнов	+7-979-611-69-43	наталья.смирнов836@email.ru	4557	864201	2025-09-16	1971-04-26
90661	Наталья	Морозов	+7-998-206-15-40	наталья.морозов837@email.ru	4561	696301	2025-09-16	2007-02-11
90662	Марина	Иванов	+7-947-607-93-31	марина.иванов838@email.ru	4544	832573	2025-09-16	2005-08-01
90663	Татьяна	Кузнецов	+7-942-167-29-70	татьяна.кузнецов839@email.ru	4508	643069	2025-09-16	1986-03-04
90664	Ольга	Михайлов	+7-911-496-39-28	ольга.михайлов840@email.ru	4575	919590	2025-09-16	1989-11-25
90665	Марина	Михайлов	+7-909-731-29-69	марина.михайлов841@email.ru	4560	465782	2025-09-16	1962-01-02
90666	Владимир	Козлов	+7-910-277-60-17	владимир.козлов842@email.ru	4517	841376	2025-09-16	1973-05-14
90667	Владимир	Петров	+7-926-240-79-74	владимир.петров843@email.ru	4547	377479	2025-09-16	1958-07-18
90668	Елена	Морозов	+7-981-768-73-73	елена.морозов844@email.ru	4541	380501	2025-09-16	2001-09-01
90669	Владимир	Козлов	+7-950-169-33-32	владимир.козлов845@email.ru	4521	556561	2025-09-16	1961-11-02
90670	Наталья	Иванов	+7-975-318-42-85	наталья.иванов846@email.ru	4574	837393	2025-09-16	1990-12-28
90671	Татьяна	Морозов	+7-990-643-67-31	татьяна.морозов847@email.ru	4511	978071	2025-09-16	1961-05-13
90672	Игорь	Попов	+7-926-291-59-17	игорь.попов848@email.ru	4577	422219	2025-09-16	1960-06-29
90673	Сергей	Новиков	+7-965-267-88-68	сергей.новиков849@email.ru	4544	781342	2025-09-16	1964-06-01
90674	Михаил	Козлов	+7-993-731-35-37	михаил.козлов850@email.ru	4561	623362	2025-09-16	1986-05-13
90675	Анна	Иванов	+7-957-740-10-94	анна.иванов851@email.ru	4501	826785	2025-09-16	1957-09-30
90676	Наталья	Петров	+7-962-444-26-84	наталья.петров852@email.ru	4585	580143	2025-09-16	2001-10-12
90677	Марина	Волков	+7-977-499-56-19	марина.волков853@email.ru	4595	479776	2025-09-16	1966-08-24
90678	Владимир	Кузнецов	+7-952-937-66-55	владимир.кузнецов854@email.ru	4587	607879	2025-09-16	1999-02-03
90679	Анна	Морозов	+7-983-597-57-73	анна.морозов855@email.ru	4548	484114	2025-09-16	1956-01-23
90680	Александр	Кузнецов	+7-937-352-66-78	александр.кузнецов856@email.ru	4549	488575	2025-09-16	1971-02-14
90681	Дмитрий	Кузнецов	+7-952-529-45-91	дмитрий.кузнецов857@email.ru	4585	201436	2025-09-16	1968-01-28
90682	Наталья	Волков	+7-978-509-38-44	наталья.волков858@email.ru	4542	228857	2025-09-16	1993-10-22
90683	Алексей	Михайлов	+7-913-474-44-92	алексей.михайлов859@email.ru	4527	925849	2025-09-16	1973-11-05
90684	Марина	Михайлов	+7-965-781-99-33	марина.михайлов860@email.ru	4511	672620	2025-09-16	2004-09-30
90685	Татьяна	Кузнецов	+7-948-177-25-43	татьяна.кузнецов861@email.ru	4555	556287	2025-09-16	1971-04-16
90686	Ирина	Морозов	+7-960-387-43-38	ирина.морозов862@email.ru	4544	150376	2025-09-16	1959-11-16
90687	Александр	Фёдоров	+7-988-786-42-78	александр.фёдоров863@email.ru	4582	641743	2025-09-16	1971-03-27
90688	Елена	Соколов	+7-902-205-73-77	елена.соколов864@email.ru	4524	524243	2025-09-16	1988-06-12
90689	Сергей	Морозов	+7-973-393-97-50	сергей.морозов865@email.ru	4537	197650	2025-09-16	1992-02-18
90690	Татьяна	Волков	+7-992-841-12-74	татьяна.волков866@email.ru	4565	560835	2025-09-16	1988-09-16
90691	Владимир	Новиков	+7-953-333-43-60	владимир.новиков867@email.ru	4529	370137	2025-09-16	1978-12-26
90692	Татьяна	Фёдоров	+7-931-219-98-55	татьяна.фёдоров868@email.ru	4506	701150	2025-09-16	1964-08-27
90693	Елена	Козлов	+7-909-578-89-84	елена.козлов869@email.ru	4567	920364	2025-09-16	1976-09-10
90694	Наталья	Лебедев	+7-966-556-11-16	наталья.лебедев870@email.ru	4523	842046	2025-09-16	1963-02-19
90695	Алексей	Соколов	+7-998-226-18-72	алексей.соколов871@email.ru	4502	489782	2025-09-16	1990-12-01
90696	Дмитрий	Соколов	+7-977-788-77-58	дмитрий.соколов872@email.ru	4507	300040	2025-09-16	1957-03-11
90697	Наталья	Соколов	+7-991-195-30-75	наталья.соколов873@email.ru	4568	521767	2025-09-16	1961-01-02
90698	Сергей	Попов	+7-954-345-70-26	сергей.попов874@email.ru	4520	775179	2025-09-16	2005-08-23
90699	Александр	Козлов	+7-908-611-30-76	александр.козлов875@email.ru	4529	436129	2025-09-16	1989-05-16
90700	Александр	Кузнецов	+7-915-199-74-27	александр.кузнецов876@email.ru	4596	546459	2025-09-16	1980-07-08
90701	Михаил	Морозов	+7-916-714-28-11	михаил.морозов877@email.ru	4579	355990	2025-09-16	1967-04-02
90702	Анна	Сидоров	+7-966-352-87-11	анна.сидоров878@email.ru	4589	271286	2025-09-16	1998-06-18
90703	Ольга	Смирнов	+7-916-669-20-78	ольга.смирнов879@email.ru	4592	616510	2025-09-16	1958-03-26
90704	Ольга	Лебедев	+7-930-817-64-66	ольга.лебедев880@email.ru	4564	308484	2025-09-16	1999-09-02
90705	Ирина	Фёдоров	+7-906-705-43-60	ирина.фёдоров881@email.ru	4516	252208	2025-09-16	1972-12-18
90706	Дмитрий	Михайлов	+7-982-359-88-32	дмитрий.михайлов882@email.ru	4589	722617	2025-09-16	1990-12-15
90707	Михаил	Петров	+7-942-497-42-57	михаил.петров883@email.ru	4527	576493	2025-09-16	2005-11-19
90708	Елена	Морозов	+7-911-550-55-29	елена.морозов884@email.ru	4564	939491	2025-09-16	1961-04-29
90709	Татьяна	Фёдоров	+7-951-214-29-43	татьяна.фёдоров885@email.ru	4512	426357	2025-09-16	1976-04-07
90710	Наталья	Морозов	+7-992-420-21-52	наталья.морозов886@email.ru	4571	384369	2025-09-16	1963-12-01
90711	Марина	Волков	+7-990-657-34-90	марина.волков887@email.ru	4537	905594	2025-09-16	1981-12-22
90712	Наталья	Соколов	+7-934-812-73-20	наталья.соколов888@email.ru	4506	324907	2025-09-16	1988-07-15
90713	Игорь	Соколов	+7-952-878-49-77	игорь.соколов889@email.ru	4537	158863	2025-09-16	1993-06-09
90714	Анна	Лебедев	+7-999-819-58-85	анна.лебедев890@email.ru	4554	948177	2025-09-16	1995-08-20
90715	Марина	Волков	+7-955-925-65-44	марина.волков891@email.ru	4598	828949	2025-09-16	1988-02-15
90716	Марина	Новиков	+7-944-411-92-14	марина.новиков892@email.ru	4589	217085	2025-09-16	1973-08-08
90717	Ольга	Кузнецов	+7-902-263-60-22	ольга.кузнецов893@email.ru	4524	477159	2025-09-16	1985-11-21
90718	Владимир	Морозов	+7-967-180-43-52	владимир.морозов894@email.ru	4535	680189	2025-09-16	1998-12-05
90719	Ольга	Соколов	+7-933-853-26-43	ольга.соколов895@email.ru	4578	193284	2025-09-16	1965-09-15
90720	Наталья	Новиков	+7-970-101-79-83	наталья.новиков896@email.ru	4556	607004	2025-09-16	1999-07-01
90721	Александр	Петров	+7-978-691-46-79	александр.петров897@email.ru	4532	272010	2025-09-16	1974-06-18
90722	Дмитрий	Сидоров	+7-958-618-61-52	дмитрий.сидоров898@email.ru	4541	526460	2025-09-16	2001-07-06
90723	Марина	Лебедев	+7-978-491-41-54	марина.лебедев899@email.ru	4538	458445	2025-09-16	1975-12-03
90724	Анна	Соколов	+7-982-136-83-98	анна.соколов900@email.ru	4529	486004	2025-09-16	1972-08-09
90725	Дмитрий	Фёдоров	+7-966-971-14-70	дмитрий.фёдоров901@email.ru	4551	713148	2025-09-16	1962-01-07
90726	Наталья	Кузнецов	+7-935-513-32-71	наталья.кузнецов902@email.ru	4534	703675	2025-09-16	1992-04-29
90727	Игорь	Петров	+7-980-436-47-90	игорь.петров903@email.ru	4502	362954	2025-09-16	1966-02-18
90728	Алексей	Волков	+7-901-862-25-56	алексей.волков904@email.ru	4552	639004	2025-09-16	1969-07-24
90729	Михаил	Кузнецов	+7-960-317-33-78	михаил.кузнецов905@email.ru	4508	693389	2025-09-16	2004-10-08
90730	Михаил	Фёдоров	+7-994-264-39-66	михаил.фёдоров906@email.ru	4581	588032	2025-09-16	2005-02-18
90731	Елена	Фёдоров	+7-970-387-59-13	елена.фёдоров907@email.ru	4544	761815	2025-09-16	1969-05-26
90732	Анна	Новиков	+7-958-648-43-48	анна.новиков908@email.ru	4537	714118	2025-09-16	1977-05-28
90733	Александр	Соколов	+7-939-196-34-92	александр.соколов909@email.ru	4533	506505	2025-09-16	2005-10-19
90734	Михаил	Михайлов	+7-952-116-10-94	михаил.михайлов910@email.ru	4528	699648	2025-09-16	1959-04-29
90735	Владимир	Фёдоров	+7-936-612-26-40	владимир.фёдоров911@email.ru	4586	428793	2025-09-16	1972-01-01
90736	Марина	Козлов	+7-991-522-23-52	марина.козлов912@email.ru	4517	650380	2025-09-16	1978-05-22
90737	Сергей	Кузнецов	+7-999-552-50-65	сергей.кузнецов913@email.ru	4547	752757	2025-09-16	2003-01-19
90738	Анна	Кузнецов	+7-915-701-27-33	анна.кузнецов914@email.ru	4589	115649	2025-09-16	1977-07-06
90739	Наталья	Морозов	+7-975-663-86-87	наталья.морозов915@email.ru	4592	374488	2025-09-16	1991-05-22
90740	Алексей	Иванов	+7-985-411-60-53	алексей.иванов916@email.ru	4577	773821	2025-09-16	1980-09-30
90741	Анна	Кузнецов	+7-963-228-79-72	анна.кузнецов917@email.ru	4597	149680	2025-09-16	1963-06-06
90742	Дмитрий	Фёдоров	+7-927-158-59-49	дмитрий.фёдоров918@email.ru	4546	476905	2025-09-16	2005-07-31
90743	Дмитрий	Сидоров	+7-937-234-73-77	дмитрий.сидоров919@email.ru	4584	843472	2025-09-16	1982-10-22
90744	Владимир	Козлов	+7-995-951-60-37	владимир.козлов920@email.ru	4521	145516	2025-09-16	2005-09-10
90745	Ольга	Морозов	+7-941-479-60-71	ольга.морозов921@email.ru	4519	322836	2025-09-16	1984-03-18
90746	Наталья	Фёдоров	+7-945-793-37-12	наталья.фёдоров922@email.ru	4501	680027	2025-09-16	1972-05-17
90747	Анна	Новиков	+7-915-269-59-87	анна.новиков923@email.ru	4599	164852	2025-09-16	1971-09-29
90748	Наталья	Иванов	+7-935-513-81-90	наталья.иванов924@email.ru	4587	543047	2025-09-16	1960-06-16
90749	Владимир	Козлов	+7-987-181-37-49	владимир.козлов925@email.ru	4555	734470	2025-09-16	1969-11-09
90750	Сергей	Волков	+7-996-231-40-81	сергей.волков926@email.ru	4527	461249	2025-09-16	1993-01-15
90751	Ольга	Морозов	+7-922-374-10-93	ольга.морозов927@email.ru	4557	641364	2025-09-16	1976-03-20
90752	Ольга	Иванов	+7-975-836-38-46	ольга.иванов928@email.ru	4535	611760	2025-09-16	1993-07-13
90753	Алексей	Сидоров	+7-954-307-88-83	алексей.сидоров929@email.ru	4578	545371	2025-09-16	1965-07-25
90754	Александр	Новиков	+7-909-390-28-23	александр.новиков930@email.ru	4584	752769	2025-09-16	1973-11-20
90755	Ольга	Иванов	+7-949-241-17-46	ольга.иванов931@email.ru	4513	479382	2025-09-16	1958-03-27
90756	Татьяна	Михайлов	+7-979-273-62-95	татьяна.михайлов932@email.ru	4546	549632	2025-09-16	2003-04-19
90757	Татьяна	Козлов	+7-952-776-78-81	татьяна.козлов933@email.ru	4562	950128	2025-09-16	1984-08-10
90758	Дмитрий	Новиков	+7-914-492-14-92	дмитрий.новиков934@email.ru	4522	872676	2025-09-16	1965-10-29
90759	Сергей	Иванов	+7-988-172-64-43	сергей.иванов935@email.ru	4505	802585	2025-09-16	1990-01-18
90760	Анна	Михайлов	+7-912-650-95-93	анна.михайлов936@email.ru	4525	795724	2025-09-16	1997-08-21
90761	Сергей	Кузнецов	+7-995-772-55-50	сергей.кузнецов937@email.ru	4515	347433	2025-09-16	1981-08-30
90762	Михаил	Лебедев	+7-941-412-95-94	михаил.лебедев938@email.ru	4512	365202	2025-09-16	1993-01-16
90763	Анна	Сидоров	+7-904-587-16-29	анна.сидоров939@email.ru	4543	292138	2025-09-16	1960-01-21
90764	Ирина	Козлов	+7-998-648-45-69	ирина.козлов940@email.ru	4552	625533	2025-09-16	1984-11-16
90765	Ирина	Волков	+7-943-700-32-39	ирина.волков941@email.ru	4559	818822	2025-09-16	1963-12-24
90766	Алексей	Волков	+7-923-329-10-26	алексей.волков942@email.ru	4590	971866	2025-09-16	1980-12-31
90767	Анна	Соколов	+7-991-217-52-16	анна.соколов943@email.ru	4516	683236	2025-09-16	1958-12-09
90768	Игорь	Петров	+7-957-213-10-49	игорь.петров944@email.ru	4566	202578	2025-09-16	2000-03-25
90769	Ирина	Сидоров	+7-928-698-74-64	ирина.сидоров945@email.ru	4519	723605	2025-09-16	1972-06-05
90770	Владимир	Лебедев	+7-902-200-76-78	владимир.лебедев946@email.ru	4568	710376	2025-09-16	1956-03-13
90771	Марина	Козлов	+7-977-939-62-96	марина.козлов947@email.ru	4528	565306	2025-09-16	2000-08-11
90772	Анна	Соколов	+7-993-735-49-51	анна.соколов948@email.ru	4575	830174	2025-09-16	1980-12-26
90773	Дмитрий	Сидоров	+7-965-619-82-76	дмитрий.сидоров949@email.ru	4588	270309	2025-09-16	1985-06-14
90774	Ольга	Фёдоров	+7-987-461-82-92	ольга.фёдоров950@email.ru	4511	491799	2025-09-16	1967-11-16
90775	Алексей	Петров	+7-938-606-23-85	алексей.петров951@email.ru	4574	433753	2025-09-16	1996-05-17
90776	Алексей	Волков	+7-976-397-20-77	алексей.волков952@email.ru	4507	548932	2025-09-16	1963-10-20
90777	Сергей	Попов	+7-928-184-65-53	сергей.попов953@email.ru	4521	677017	2025-09-16	1986-08-31
90778	Александр	Новиков	+7-995-244-95-43	александр.новиков954@email.ru	4517	545147	2025-09-16	1956-10-23
90779	Сергей	Михайлов	+7-994-748-88-29	сергей.михайлов955@email.ru	4564	821114	2025-09-16	1973-05-10
90780	Татьяна	Морозов	+7-951-384-47-87	татьяна.морозов956@email.ru	4539	579390	2025-09-16	1968-07-05
90781	Ольга	Морозов	+7-924-196-53-51	ольга.морозов957@email.ru	4529	141350	2025-09-16	1978-02-26
90782	Марина	Сидоров	+7-948-321-71-69	марина.сидоров958@email.ru	4536	813333	2025-09-16	1987-10-27
90783	Александр	Волков	+7-920-767-71-23	александр.волков959@email.ru	4505	171109	2025-09-16	1981-05-27
90784	Ирина	Новиков	+7-965-668-35-16	ирина.новиков960@email.ru	4555	920716	2025-09-16	1986-11-09
90785	Александр	Смирнов	+7-933-585-92-66	александр.смирнов961@email.ru	4566	132850	2025-09-16	1957-02-14
90786	Михаил	Морозов	+7-992-560-65-35	михаил.морозов962@email.ru	4527	567054	2025-09-16	1973-01-25
90787	Марина	Волков	+7-906-280-81-47	марина.волков963@email.ru	4537	496513	2025-09-16	1999-08-05
90788	Владимир	Новиков	+7-927-884-12-33	владимир.новиков964@email.ru	4594	612769	2025-09-16	1973-02-22
90789	Александр	Михайлов	+7-971-895-64-46	александр.михайлов965@email.ru	4571	766457	2025-09-16	1977-06-22
90790	Анна	Иванов	+7-916-749-40-62	анна.иванов966@email.ru	4509	269283	2025-09-16	1994-05-15
90791	Наталья	Козлов	+7-992-879-63-70	наталья.козлов967@email.ru	4533	281999	2025-09-16	2003-05-14
90792	Сергей	Петров	+7-931-474-53-60	сергей.петров968@email.ru	4578	895344	2025-09-16	2004-03-04
90793	Анна	Смирнов	+7-910-904-21-73	анна.смирнов969@email.ru	4582	235422	2025-09-16	1979-10-09
90794	Игорь	Смирнов	+7-905-472-90-50	игорь.смирнов970@email.ru	4514	697577	2025-09-16	1969-12-28
90795	Сергей	Кузнецов	+7-943-460-16-71	сергей.кузнецов971@email.ru	4508	557143	2025-09-16	1976-10-29
90796	Ирина	Соколов	+7-967-823-81-76	ирина.соколов972@email.ru	4550	607486	2025-09-16	1998-11-25
90797	Александр	Соколов	+7-992-872-88-45	александр.соколов973@email.ru	4507	469103	2025-09-16	1973-08-07
90798	Игорь	Смирнов	+7-978-904-41-83	игорь.смирнов974@email.ru	4530	719466	2025-09-16	1959-12-10
90799	Владимир	Петров	+7-928-700-31-92	владимир.петров975@email.ru	4574	163687	2025-09-16	1993-08-07
90800	Татьяна	Лебедев	+7-981-510-30-26	татьяна.лебедев976@email.ru	4521	181111	2025-09-16	1970-03-17
90801	Александр	Смирнов	+7-922-361-58-43	александр.смирнов977@email.ru	4507	493663	2025-09-16	1999-02-16
90802	Ирина	Сидоров	+7-990-544-49-90	ирина.сидоров978@email.ru	4556	286457	2025-09-16	1993-12-23
90803	Владимир	Петров	+7-999-798-44-48	владимир.петров979@email.ru	4545	262413	2025-09-16	1993-03-08
90804	Сергей	Михайлов	+7-991-703-93-68	сергей.михайлов980@email.ru	4544	267759	2025-09-16	2006-02-17
90805	Марина	Иванов	+7-957-722-31-13	марина.иванов981@email.ru	4569	833600	2025-09-16	1975-03-10
90806	Анна	Михайлов	+7-964-137-52-86	анна.михайлов982@email.ru	4542	622459	2025-09-16	1966-03-15
90807	Игорь	Петров	+7-907-865-35-24	игорь.петров983@email.ru	4566	803643	2025-09-16	1977-07-11
90808	Игорь	Лебедев	+7-913-299-27-36	игорь.лебедев984@email.ru	4515	463809	2025-09-16	1990-07-25
90809	Елена	Козлов	+7-971-613-68-25	елена.козлов985@email.ru	4572	453657	2025-09-16	1993-05-15
90810	Анна	Козлов	+7-919-693-72-54	анна.козлов986@email.ru	4541	594438	2025-09-16	1991-02-22
90811	Сергей	Лебедев	+7-929-844-56-76	сергей.лебедев987@email.ru	4596	709543	2025-09-16	1996-10-16
90812	Дмитрий	Иванов	+7-990-563-12-35	дмитрий.иванов988@email.ru	4583	148248	2025-09-16	2007-07-04
90813	Александр	Михайлов	+7-977-469-13-95	александр.михайлов989@email.ru	4568	899365	2025-09-16	2001-07-13
90814	Алексей	Фёдоров	+7-975-672-51-60	алексей.фёдоров990@email.ru	4550	730496	2025-09-16	2000-02-26
90815	Игорь	Фёдоров	+7-968-541-86-26	игорь.фёдоров991@email.ru	4532	274138	2025-09-16	2002-12-09
90816	Елена	Козлов	+7-991-946-97-87	елена.козлов992@email.ru	4598	162095	2025-09-16	1987-05-25
90817	Владимир	Иванов	+7-938-237-47-66	владимир.иванов993@email.ru	4525	696688	2025-09-16	1997-11-20
90818	Александр	Кузнецов	+7-996-167-38-14	александр.кузнецов994@email.ru	4593	447077	2025-09-16	1962-01-28
90819	Татьяна	Новиков	+7-929-973-49-59	татьяна.новиков995@email.ru	4528	529948	2025-09-16	1967-11-05
90820	Ольга	Волков	+7-969-323-37-13	ольга.волков996@email.ru	4514	383509	2025-09-16	1986-10-16
90821	Ирина	Фёдоров	+7-983-761-17-74	ирина.фёдоров997@email.ru	4594	574957	2025-09-16	1995-10-04
90822	Дмитрий	Попов	+7-950-689-16-53	дмитрий.попов998@email.ru	4542	307870	2025-09-16	1989-09-06
90823	Михаил	Смирнов	+7-969-559-53-81	михаил.смирнов999@email.ru	4567	769797	2025-09-16	1967-07-06
90824	Алексей	Волков	+7-956-882-34-72	алексей.волков1000@email.ru	4520	138373	2025-09-16	2003-01-28
\.


--
-- TOC entry 3680 (class 0 OID 18356)
-- Dependencies: 229
-- Data for Name: order_services; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_services (order_id, service_id, quantity, price_rub) FROM stdin;
89928	319	1	90418.95
89928	15	1	21097.27
89928	32	1	96247.30
89929	436	1	67555.73
89929	17	2	91156.77
89930	184	2	8279.47
89930	187	2	33554.53
89931	136	2	107788.24
89931	65	2	57391.25
89932	216	1	60097.89
89932	268	1	59481.15
89933	119	2	21586.76
89933	5	1	75267.67
89933	381	2	116800.08
89933	428	2	101712.64
89933	360	1	79083.27
89934	19	2	48114.79
89934	308	2	86576.00
89935	184	1	63213.14
89935	498	1	52647.48
89935	389	1	54344.62
89935	350	2	113044.41
89936	500	2	54273.27
89936	154	2	59695.88
89936	443	2	72784.34
89936	454	2	44890.51
89936	287	1	51130.62
89937	458	1	23505.09
89937	300	1	21212.68
89938	434	2	62887.73
89938	469	2	119898.10
89938	126	2	112832.95
89939	84	2	109758.30
89939	259	2	116598.89
89940	308	1	46193.66
89940	65	2	110728.50
89940	13	1	11465.39
89941	248	2	6871.33
89941	373	2	112484.41
89941	258	2	55777.13
89942	138	1	35233.01
89942	450	2	45569.04
89943	59	1	29847.10
89943	98	2	101919.70
89943	264	1	90192.25
89943	326	1	46951.42
89944	240	2	72968.09
89944	156	2	75040.52
89944	65	2	75370.45
89944	282	2	11177.57
89944	69	1	41927.52
89945	75	2	78085.15
89945	98	2	55706.03
89946	122	1	56427.13
89946	48	1	85038.56
89947	420	2	52426.06
89947	58	1	89668.23
89947	313	2	12410.75
89947	78	2	40294.22
89948	349	2	44011.44
89948	355	1	60453.59
89949	312	2	72308.13
89949	177	2	85252.96
89949	204	1	51890.00
89949	42	1	5724.69
89949	1	2	64323.62
89950	261	1	63073.06
89950	353	2	23758.37
89950	337	1	70682.23
89950	403	1	103453.65
89950	223	2	18668.02
89951	192	1	96780.01
89951	187	1	29401.86
89951	90	1	9581.87
89951	33	2	118472.73
89952	383	1	75275.48
89952	162	2	97848.41
89952	1	2	43488.05
89952	11	2	51381.87
89952	442	2	101367.82
89953	424	2	22697.87
89953	357	2	27969.39
89953	179	2	76528.71
89953	440	1	18914.56
89953	267	1	119951.86
89954	389	1	60081.59
89954	115	1	28873.10
89954	274	2	33068.05
89954	327	1	70526.69
89955	465	2	78554.37
89955	440	2	84703.45
89956	360	1	12755.44
89956	311	2	5608.31
89956	418	1	38722.49
89956	450	1	49282.10
89957	231	2	109619.04
89957	506	2	94903.70
89957	186	2	96380.35
89957	407	2	34220.41
89957	504	1	114991.00
89958	53	1	114564.60
89958	447	1	41652.73
89958	11	2	28667.82
89959	404	2	60680.84
89959	45	1	96315.68
89959	413	1	76196.91
89959	239	1	43681.50
89960	76	1	115262.27
89960	175	1	89755.07
89960	173	2	30101.74
89960	487	1	9607.64
89961	237	1	100271.20
89961	209	2	78762.76
89961	373	1	100877.71
89961	444	1	29987.69
89962	240	1	30786.23
89962	424	1	64014.40
89963	205	2	42023.19
89963	113	1	10088.47
89963	132	2	103677.44
89963	65	2	80250.90
89963	55	1	116473.16
89964	256	2	37189.52
89964	325	1	17102.92
89964	145	2	78729.35
89965	264	2	13237.43
89965	11	1	68596.75
89965	348	1	36405.53
89966	498	1	94853.00
89966	126	2	101989.11
89966	86	1	117991.09
89967	48	1	67041.20
89967	221	1	13620.08
89967	404	1	72582.49
89967	121	1	7046.94
89967	252	2	30349.68
89968	232	2	102902.74
89968	7	2	91579.71
89968	92	1	46865.14
89969	87	2	10552.56
89969	428	1	106485.67
89970	349	2	111685.13
89970	29	1	58168.24
89970	171	1	47830.78
89971	32	1	34790.04
89971	440	2	85567.14
89971	86	1	106655.28
89971	315	2	97696.04
89971	508	2	110371.73
89972	52	1	38842.94
89972	299	1	30680.23
89972	176	2	54824.61
89972	505	2	16687.25
89973	305	1	68413.97
89973	339	1	90180.63
89973	258	1	114860.45
89973	326	2	63797.26
89973	60	2	47450.90
89974	232	2	26395.65
89974	469	1	46097.49
89974	285	2	44870.83
89974	402	2	59334.10
89975	372	2	13044.85
89975	478	2	24810.35
89975	185	2	27436.94
89976	37	2	59043.73
89976	154	2	105642.13
89977	459	2	61664.20
89977	272	1	53826.85
89977	20	2	117898.41
89978	233	2	106880.74
89978	401	2	110934.12
89978	437	1	21119.61
89979	112	1	79525.85
89979	338	1	74807.89
89980	364	2	96608.33
89980	465	2	100823.27
89980	382	2	68442.24
89980	56	1	59588.95
89980	41	1	109655.56
89981	104	2	71707.03
89981	277	1	95820.12
89981	225	1	40721.27
89981	124	1	52684.39
89982	383	2	107752.05
89982	354	2	27554.99
89982	212	1	14492.18
89983	356	1	114146.33
89983	190	2	97903.21
89983	79	1	108030.43
89983	300	2	80241.45
89983	366	2	119891.25
89984	17	1	100810.61
89984	208	1	100166.74
89984	521	1	57014.14
89984	176	1	44307.77
89984	106	1	43743.72
89985	112	1	107096.79
89985	74	2	80830.24
89985	301	2	99723.23
89986	488	2	15897.42
89986	231	1	81543.51
89987	225	1	19305.13
89987	178	2	10279.02
89987	209	1	27083.95
89987	40	1	92357.42
89987	323	1	89606.97
89988	475	2	24940.58
89988	239	2	71478.05
89988	391	2	90787.32
89989	448	1	52489.45
89989	98	1	94153.05
89989	17	2	39004.89
89990	369	1	49506.64
89990	208	1	56937.90
89990	112	1	6114.38
89990	11	2	81742.47
89990	285	2	111233.25
89991	131	2	111425.07
89991	256	1	108713.50
89991	247	1	87480.41
89992	493	2	52106.94
89992	205	2	23756.96
89992	274	1	58099.88
89993	178	2	62392.95
89993	478	2	78730.61
89994	32	2	88299.56
89994	362	2	21745.88
89994	443	1	61973.11
89994	351	2	33820.86
89995	520	2	41069.22
89995	291	1	82938.14
89995	334	2	44460.86
89996	298	1	115118.42
89996	343	2	82528.06
89996	90	1	39238.35
89996	414	1	40034.59
89997	59	1	12904.05
89997	394	2	61922.98
89997	132	1	85525.65
89997	461	1	68052.73
89998	136	1	89497.40
89998	425	2	8324.76
89999	82	1	58126.26
89999	66	2	113981.75
90000	513	1	103617.92
90000	178	2	15660.30
90000	518	2	118489.32
90000	165	2	66633.61
90001	145	1	18530.86
90001	407	2	91207.46
90001	142	2	73529.53
90001	58	1	96343.59
90002	246	2	51614.98
90002	303	1	37530.14
90002	204	2	117016.84
90002	172	1	29706.91
90002	136	1	27149.96
90003	506	1	69848.84
90003	376	1	102516.08
90003	290	1	64917.69
90003	90	2	14832.80
90004	346	1	119140.09
90004	213	1	19601.47
90004	202	1	7889.07
90004	354	1	117734.82
90005	322	1	44822.67
90005	487	1	45824.05
90005	60	2	64002.75
90006	454	2	36397.07
90006	508	2	91884.25
90007	40	1	88353.85
90007	372	1	40901.48
90008	128	2	10321.04
90008	502	1	83172.57
90008	36	1	67893.53
90009	428	2	108441.00
90009	225	1	77251.97
90010	188	1	76617.12
90010	209	2	112118.83
90011	420	2	100491.07
90011	512	1	7250.31
90011	97	2	88382.78
90011	256	2	33068.85
90012	342	2	30503.68
90012	189	2	36127.49
90013	299	2	82271.58
90013	474	2	90971.54
90013	426	2	81336.06
90013	318	1	112072.36
90013	199	1	86372.84
90014	392	1	7835.91
90014	369	2	71129.17
90014	107	1	84693.78
90014	482	1	105553.67
90014	229	1	16008.10
90015	27	1	84977.74
90015	505	2	79355.04
90015	498	2	54360.40
90015	115	1	9437.76
90016	398	1	12804.55
90016	366	1	60179.53
90016	503	2	86937.21
90016	250	2	106844.34
90016	441	1	86924.98
90017	249	1	105176.22
90017	274	2	28707.08
90017	20	2	6089.96
90017	376	2	14278.94
90018	166	2	98737.25
90018	327	2	92555.38
90018	377	1	42344.49
90019	165	2	62294.19
90019	297	2	103527.61
90020	151	2	69888.98
90020	2	2	107657.57
90021	328	2	112929.33
90021	78	1	19816.00
90021	181	1	31054.19
90021	29	1	49662.38
90022	92	1	101402.71
90022	496	2	107827.30
90022	65	1	33050.39
90022	99	2	76075.98
90022	393	2	47209.87
90023	516	1	7009.84
90023	109	1	68986.50
90023	127	1	73092.04
90023	77	2	48772.79
90024	11	1	7801.71
90024	168	1	35602.69
90025	47	2	117156.37
90025	462	2	23241.24
90025	2	2	58884.11
90025	161	2	35321.24
90026	168	1	7903.09
90026	501	1	31200.03
90027	241	2	91628.74
90027	54	1	83720.56
90027	297	2	20866.90
90027	51	2	87143.01
90028	201	1	63025.07
90028	147	2	115881.41
90028	206	2	28434.58
90028	341	1	66759.39
90028	244	2	103751.31
90029	367	1	116710.65
90029	284	2	78262.00
90029	277	2	53864.82
90030	433	2	97230.71
90030	419	1	5630.56
90030	162	2	11586.07
90030	138	1	107603.88
90031	495	1	32790.99
90031	523	1	30788.24
90031	83	1	34305.79
90032	164	1	79050.18
90032	377	1	74620.00
90032	231	2	69119.34
90032	120	2	36548.87
90032	222	1	30470.89
90033	242	2	97449.18
90033	461	2	63795.47
90033	59	2	32181.14
90034	9	2	86654.96
90034	200	2	80558.19
90034	164	2	68430.41
90035	21	2	15264.62
90035	146	2	60033.89
90035	154	2	104982.22
90035	147	2	36821.97
90036	421	2	9320.75
90036	97	1	45667.36
90036	426	1	42780.08
90037	113	1	68302.51
90037	2	2	67642.25
90037	316	2	67039.04
90037	390	1	63145.05
90038	112	2	16712.98
90038	506	1	42919.27
90038	484	2	24739.75
90039	184	2	20166.90
90039	332	2	21688.92
90040	200	2	81388.36
90040	327	2	49781.15
90040	462	2	65353.60
90041	304	2	41973.55
90041	351	2	110682.79
90041	335	1	64353.72
90041	100	1	71349.49
90042	459	2	92641.87
90042	430	1	28765.87
90043	243	2	75964.35
90043	458	2	19371.04
90043	385	2	16875.80
90043	308	1	71126.98
90044	231	2	16408.95
90044	161	1	49501.60
90044	450	1	100700.11
90044	245	2	79231.97
90045	220	2	98235.05
90045	162	1	45268.31
90045	471	2	82516.67
90045	462	1	22504.06
90046	155	2	26224.00
90046	172	1	91966.19
90046	369	1	6110.35
90046	141	1	119555.59
90046	220	1	34968.72
90047	96	1	100492.63
90047	330	1	37813.92
90047	438	1	41148.46
90048	33	2	112719.47
90048	211	1	61300.83
90048	277	2	46804.39
90049	388	1	50532.73
90049	370	1	34957.10
90049	237	1	37559.00
90049	25	1	38574.21
90049	327	2	90115.44
90050	432	1	79786.28
90050	233	1	41877.81
90050	368	2	27663.72
90051	327	2	11447.77
90051	342	1	34550.51
90051	114	2	93403.01
90052	7	1	35723.65
90052	504	2	105463.35
90052	70	2	38526.88
90052	158	1	41997.16
90052	467	1	85708.82
90053	302	1	41499.20
90053	512	2	106915.02
90053	324	2	119010.76
90053	313	2	7782.32
90053	451	1	73651.18
90054	339	1	102892.03
90054	267	2	82184.59
90054	301	1	97173.97
90054	42	1	29471.10
90055	399	2	95785.99
90055	448	1	43080.90
90056	418	2	57079.56
90056	453	2	35637.72
90056	388	2	101021.03
90057	387	2	10581.72
90057	256	2	79191.21
90057	217	2	46097.69
90058	265	2	94337.25
90058	274	2	12522.26
90059	262	2	36422.24
90059	510	2	16224.38
90060	386	2	62296.07
90060	48	2	64810.92
90060	101	2	24769.37
90061	290	1	86542.88
90061	126	1	59773.40
90061	31	1	91279.09
90061	454	1	55689.78
90061	105	1	107213.93
90062	25	2	65576.25
90062	370	1	49992.94
90062	125	2	21133.10
90062	16	2	46441.65
90062	316	1	78797.76
90063	158	2	94798.16
90063	192	2	7110.39
90064	329	2	67577.05
90064	449	2	36224.28
90065	515	2	114535.26
90065	269	2	17997.26
90065	207	1	15951.29
90065	200	2	48521.77
90066	368	2	12142.97
90066	466	1	73261.75
90066	56	1	117387.12
90067	273	1	89122.80
90067	36	2	72659.79
90067	395	1	63843.23
90067	45	2	45361.95
90067	206	2	119941.43
90068	227	1	20879.28
90068	272	2	28024.86
90069	507	2	113867.97
90069	318	1	108005.61
90069	277	1	36114.28
90070	160	1	35988.07
90070	332	2	76277.33
90070	488	1	53661.25
90070	120	2	23465.45
90070	117	2	50814.27
90071	390	2	57063.55
90071	472	1	9074.24
90071	331	1	32402.90
90071	438	2	18374.01
90072	406	2	41002.03
90072	88	2	64882.36
90073	265	1	75018.20
90073	45	1	44048.92
90073	409	1	90426.44
90073	92	2	6007.66
90073	386	1	29928.51
90074	90	2	112486.58
90074	22	2	39598.89
90074	317	1	54343.75
90074	311	1	80436.90
90075	510	1	119593.34
90075	288	2	111046.88
90076	313	1	7157.76
90076	352	1	40969.93
90076	433	1	68812.63
90076	172	2	103891.44
90077	97	1	62905.46
90077	198	1	100144.75
90077	492	2	41095.08
90078	15	1	16660.70
90078	327	2	26722.83
90078	363	2	47686.61
90079	375	2	47584.63
90079	293	2	64250.37
90080	315	1	15667.48
90080	73	1	42196.41
90080	480	2	83450.74
90080	277	1	98669.67
90081	489	2	57476.29
90081	280	1	90411.82
90081	444	1	119180.60
90081	161	1	75280.59
90081	325	1	39625.82
90082	86	2	31420.51
90082	281	2	62966.74
90082	99	1	42770.04
90083	244	1	61372.75
90083	354	2	96709.30
90083	81	2	46828.36
90083	228	2	74721.55
90084	420	1	53131.40
90084	502	1	48317.17
90084	100	1	64658.03
90084	9	1	86646.28
90085	288	1	5986.53
90085	61	2	80454.14
90085	326	1	13330.79
90085	96	1	67341.57
90086	501	2	61910.77
90086	378	1	117842.18
90087	42	1	96737.29
90087	29	2	29567.10
90087	219	1	43341.26
90088	434	2	36546.62
90088	494	2	68035.46
90088	99	1	92016.21
90088	144	1	97919.11
90089	404	2	68593.88
90089	107	1	88890.20
90089	385	2	8733.59
90089	118	2	17506.32
90090	81	2	96942.90
90090	265	2	9269.61
90090	326	1	83980.77
90091	59	1	74030.19
90091	459	2	96901.88
90091	389	1	33546.29
90091	487	2	7346.72
90091	417	2	36461.47
90092	304	2	112658.31
90092	227	1	76362.45
90092	95	1	97979.33
90093	274	2	114965.45
90093	113	1	13872.42
90094	28	1	76887.14
90094	278	2	29371.62
90094	463	1	71018.73
90094	473	1	70187.97
90094	229	1	88007.37
90095	401	2	61843.52
90095	317	1	114104.43
90095	508	1	22233.94
90095	236	1	11509.89
90095	302	1	20151.14
90096	404	2	43309.31
90096	374	2	50674.63
90097	184	1	104992.66
90097	322	2	55529.37
90098	519	2	114811.05
90098	461	2	99405.60
90099	291	1	85847.30
90099	474	1	73387.81
90099	179	2	64612.92
90100	377	2	77633.29
90100	306	2	54262.54
90100	135	1	18433.40
90101	256	2	98668.36
90101	431	2	68776.76
90101	450	2	28691.03
90102	109	1	101100.55
90102	186	2	64434.43
90103	107	2	97253.50
90103	295	1	54546.24
90103	450	1	41987.09
90104	217	2	104845.04
90104	316	1	20744.66
90104	467	2	92165.51
90104	67	1	29537.79
90104	299	1	71202.35
90105	468	1	41182.89
90105	127	2	82957.33
90106	9	1	56238.82
90106	240	1	93710.98
90106	464	2	112126.31
90106	29	2	12415.33
90107	467	2	11175.99
90107	129	2	115480.13
90108	347	2	35401.74
90108	81	2	106539.24
90108	175	2	5454.20
90109	20	1	17874.35
90109	31	2	61801.21
90109	45	2	98676.42
90109	107	2	118744.32
90110	107	1	35481.83
90110	219	1	105969.55
90110	227	2	91098.36
90110	278	2	53186.54
90110	240	2	81457.20
90111	152	1	43509.15
90111	406	1	31592.32
90111	412	2	40110.74
90111	239	1	15997.06
90112	322	2	35696.33
90112	128	2	43204.91
90112	87	2	82852.34
90112	290	2	19117.62
90113	206	2	109672.00
90113	321	1	40299.36
90113	205	1	115817.27
90113	52	2	45975.17
90114	372	2	54762.01
90114	338	1	51483.79
90114	275	1	9302.36
90115	102	2	103496.36
90115	498	1	80066.89
90115	344	2	116570.74
90115	192	2	37367.87
90116	30	2	96849.46
90116	329	1	31177.98
90116	189	2	58716.49
90117	156	2	48945.07
90117	149	2	36546.41
90118	10	1	21356.03
90118	444	2	91094.17
90118	235	1	21452.39
90119	266	2	96104.54
90119	173	1	93976.96
90119	169	2	46409.49
90120	392	2	105026.36
90120	19	2	69272.62
90120	173	1	53474.30
90120	313	1	63663.21
90121	215	2	55204.81
90121	440	1	109248.60
90121	88	1	82682.23
90121	288	2	116857.38
90122	488	2	117869.51
90122	192	2	115830.33
90122	7	2	65930.31
90122	181	1	51466.03
90123	111	1	38099.88
90123	137	1	76855.25
90123	91	2	100425.32
90123	58	1	11737.41
90123	516	1	75875.03
90124	175	1	26613.06
90124	252	1	101333.96
90124	178	2	55701.25
90124	144	2	58891.89
90125	401	1	92328.08
90125	85	1	70007.09
90126	457	1	23415.95
90126	414	2	118006.54
90127	114	2	86828.69
90127	111	2	76608.24
90128	383	2	41990.97
90128	424	2	50174.85
90129	469	2	20693.32
90129	233	1	79308.33
90129	463	1	84601.03
90129	179	2	46107.48
90130	127	2	98902.17
90130	373	1	39696.02
90131	144	2	32013.14
90131	110	1	87165.85
90131	270	1	77776.60
90132	435	2	56670.02
90132	322	2	114292.49
90132	397	2	71454.05
90132	321	1	41509.42
90132	267	1	31649.21
90133	222	1	8516.46
90133	43	1	9414.08
90134	61	2	55849.59
90134	154	1	86619.84
90134	226	2	13736.33
90135	334	2	69306.27
90135	168	1	16588.29
90136	210	2	89255.43
90136	102	1	36562.63
90136	407	1	16546.51
90136	520	2	98770.75
90136	383	1	115312.09
90137	167	2	96734.36
90137	135	1	9644.89
90137	378	2	62569.80
90137	521	1	60896.40
90137	494	2	97435.18
90138	34	1	85317.37
90138	191	2	20139.88
90138	38	2	103383.52
90139	195	1	37304.72
90139	4	2	58944.07
90140	316	1	38076.51
90140	69	1	87816.92
90140	402	2	70363.10
90140	407	1	74045.44
90140	36	1	54495.77
90141	435	1	64834.64
90141	445	2	92468.24
90141	116	1	65962.15
90142	349	2	16260.94
90142	400	2	31725.05
90142	389	2	29482.80
90142	91	1	30912.71
90143	213	1	6017.93
90143	362	2	115893.38
90144	498	2	85967.64
90144	410	1	21737.64
90144	140	1	10884.78
90145	233	1	86484.87
90145	285	1	111100.94
90145	86	2	23474.62
90145	138	1	43181.69
90145	183	1	86603.88
90146	127	2	32527.17
90146	510	2	78643.17
90147	267	2	8268.47
90147	144	1	75127.02
90147	173	1	42042.16
90147	455	2	76670.01
90148	81	1	9405.01
90148	242	2	103957.70
90149	494	2	71105.29
90149	504	1	57560.54
90150	195	1	44597.79
90150	445	2	11579.91
90150	247	2	64785.07
90150	176	2	26279.67
90151	234	2	88502.03
90151	525	2	102287.20
90151	103	2	119155.49
90152	497	1	115043.96
90152	53	1	56058.68
90153	4	2	12375.32
90153	397	1	64496.05
90153	515	1	111869.88
90153	506	2	26074.23
90154	222	1	8737.29
90154	216	2	117607.92
90154	46	2	86156.49
90154	179	1	86862.92
90155	211	2	111865.52
90155	390	1	85862.47
90155	123	1	29153.06
90155	428	2	42037.85
90155	37	2	44626.98
90156	524	2	110601.29
90156	337	2	13559.04
90156	525	2	44599.79
90156	446	2	64070.35
90156	89	2	94007.41
90157	182	1	15814.79
90157	485	1	108149.87
90157	352	2	87358.14
90157	62	2	99500.56
90157	235	2	85335.90
90158	387	2	85958.49
90158	18	2	32384.53
90158	182	1	18312.14
90159	504	2	75649.41
90159	41	2	26516.41
90159	236	2	23615.66
90160	502	1	49541.77
90160	471	2	5460.75
90161	35	1	5740.73
90161	52	1	14607.72
90161	498	2	118526.53
90161	361	2	98339.33
90161	412	1	69930.62
90162	189	1	82001.31
90162	23	2	27553.27
90163	479	1	97726.59
90163	328	1	61743.72
90163	524	2	35527.15
90163	195	1	87775.45
90164	217	1	119973.53
90164	358	2	37085.48
90165	187	1	94800.30
90165	30	2	46054.09
90165	500	2	35125.48
90165	152	1	57589.28
90165	408	1	21301.55
90166	31	1	17001.08
90166	448	1	84372.68
90167	63	2	96666.89
90167	475	2	65496.70
90168	88	1	26162.61
90168	115	1	98830.30
90169	345	2	114217.77
90169	295	1	48088.67
90169	249	1	53898.97
90169	117	1	12296.81
90169	114	2	10781.30
90170	28	1	101974.41
90170	179	2	50740.87
90170	377	1	102427.68
90171	4	2	86155.56
90171	506	1	112310.70
90171	115	2	51639.57
90171	268	1	67970.16
90171	331	2	40690.87
90172	506	1	98454.77
90172	258	2	100314.39
90172	457	2	63992.32
90172	271	2	33782.31
90173	256	1	94858.91
90173	77	2	20619.99
90173	507	1	37458.51
90174	237	2	105820.06
90174	29	2	117617.39
90174	32	1	83483.33
90175	176	2	72418.43
90175	337	2	83170.28
90175	201	2	31895.12
90176	378	2	62965.32
90176	255	1	8501.94
90176	228	2	40084.51
90176	195	1	86440.07
90176	459	1	33260.05
90177	289	1	74119.03
90177	309	2	17940.64
90178	78	1	15014.10
90178	92	2	44305.93
90178	467	2	118866.53
90178	213	1	68625.13
90178	326	1	85965.41
90179	391	1	70922.67
90179	82	1	29146.17
90179	298	2	33398.15
90179	120	1	103291.80
90179	23	2	92692.27
90180	344	2	37323.49
90180	497	2	50203.62
90181	392	1	57805.03
90181	376	2	54044.17
90181	315	1	98164.43
90182	301	1	67011.07
90182	492	1	10053.65
90182	220	2	108120.05
90182	386	1	86145.68
90182	100	2	18608.69
90183	91	1	54034.56
90183	510	1	11505.77
90183	499	1	15363.25
90183	169	2	56733.06
90184	279	2	6253.18
90184	251	1	99504.75
90184	77	2	27324.41
90184	226	1	28389.12
90185	290	2	93363.81
90185	19	2	51319.94
90186	450	2	15880.65
90186	326	1	84440.44
90186	96	2	13117.26
90187	181	1	30855.90
90187	315	2	117698.59
90187	53	2	66927.72
90188	299	2	29641.78
90188	237	2	85200.32
90188	380	2	14071.78
90188	472	2	36064.48
90188	286	2	66487.78
90189	506	2	47183.87
90189	24	1	76338.26
90189	230	2	54078.88
90190	117	1	68900.49
90190	129	1	29679.45
90190	356	1	78509.53
90190	109	2	119440.71
90190	31	2	34567.06
90191	433	2	111942.57
90191	449	2	69098.14
90191	40	2	93478.97
90191	282	1	73992.24
90191	4	1	64770.48
90192	299	1	113641.98
90192	292	2	17378.54
90193	2	2	73944.62
90193	239	2	102693.86
90193	401	2	43520.38
90193	340	2	55713.43
90193	220	1	23837.30
90194	100	1	103872.55
90194	248	1	103188.76
90195	100	1	83541.19
90195	96	1	46811.09
90196	269	2	56880.99
90196	150	1	106393.47
90196	301	2	26002.03
90196	25	1	79140.36
90197	225	2	6508.97
90197	269	1	83963.96
90197	476	1	5323.90
90198	185	2	39707.76
90198	204	2	114395.21
90198	117	2	51049.35
90198	437	2	111852.13
90198	94	1	86440.03
90199	186	1	29801.95
90199	266	1	100212.16
90199	516	1	14197.86
90199	288	1	66530.74
90199	445	1	70142.61
90200	479	1	109161.41
90200	176	2	43387.44
90200	53	2	101237.28
90200	379	2	106492.50
90201	407	1	32454.73
90201	313	2	108079.09
90201	283	1	96847.97
90201	430	1	103617.71
90202	472	1	21346.63
90202	58	1	79880.04
90202	379	2	31973.44
90202	166	2	71326.47
90203	523	1	88609.95
90203	167	1	38168.69
90204	63	1	36730.70
90204	251	1	82574.54
90204	429	2	86306.66
90204	52	2	107053.46
90205	105	1	64196.95
90205	316	2	24474.83
90205	11	2	83065.54
90205	248	2	92464.29
90206	251	1	37676.76
90206	166	2	40792.04
90207	276	2	37443.18
90207	382	1	52318.86
90207	101	2	74949.81
90208	59	1	102700.48
90208	19	1	39270.74
90208	517	2	17771.13
90209	156	1	56184.17
90209	29	2	66121.91
90209	372	1	8721.18
90209	85	1	117345.73
90210	343	1	20801.37
90210	276	1	25761.48
90211	209	1	8339.07
90211	128	1	91181.91
90211	399	1	117637.47
90211	391	1	5532.19
90211	151	1	33668.01
90212	509	1	52362.64
90212	99	1	22123.48
90213	329	2	98002.34
90213	333	1	74818.49
90213	465	2	104900.58
90214	333	1	8087.24
90214	123	1	65985.88
90214	356	1	27374.29
90214	281	2	35830.33
90215	180	1	111887.26
90215	12	1	114392.84
90215	284	2	58316.58
90215	105	2	77072.81
90215	323	1	116616.85
90216	65	1	84831.05
90216	412	1	13681.81
90216	236	2	13462.13
90216	82	2	55115.24
90217	331	1	114719.73
90217	177	1	66359.16
90218	143	2	37738.43
90218	351	1	114898.79
90218	332	1	28540.23
90218	346	1	22746.77
90218	331	2	68611.24
90219	154	1	24603.02
90219	38	1	100395.22
90220	16	2	93544.94
90220	6	1	48372.11
90220	198	2	64736.79
90220	118	1	55584.08
90221	252	2	18864.86
90221	74	1	40090.43
90221	353	1	34698.93
90221	399	1	86756.68
90221	75	1	94502.93
90222	264	1	13288.89
90222	372	1	49689.51
90222	323	2	113214.49
90223	273	1	10163.66
90223	137	2	48665.15
90224	465	1	66758.49
90224	385	2	64180.69
90224	324	1	17439.06
90225	46	1	94181.22
90225	29	1	53574.86
90225	138	2	71497.99
90226	353	2	45845.09
90226	505	1	22432.12
90226	195	2	85327.15
90226	10	2	103512.09
90226	316	1	19302.62
90227	404	1	54360.70
90227	415	2	113616.55
90228	118	1	7556.94
90228	8	1	28482.91
90228	350	2	29439.91
90228	135	1	61702.56
90229	483	1	108217.97
90229	519	2	68170.27
90229	455	1	66249.78
90229	504	2	39877.67
90230	268	2	26980.42
90230	58	2	119609.51
90230	525	2	83740.87
90231	525	1	69623.45
90231	403	1	20710.61
90231	487	2	6260.46
90231	280	1	85840.53
90231	69	2	88688.18
90232	41	2	95344.67
90232	283	2	87747.96
90232	439	2	58658.65
90232	130	1	56971.94
90232	60	2	7220.79
90233	336	1	60712.46
90233	111	1	26551.12
90233	187	1	60153.56
90233	233	1	33344.30
90233	124	2	65324.81
90234	84	2	69615.78
90234	332	1	101105.28
90234	389	1	46764.94
90234	213	1	18595.78
90234	387	2	24960.86
90235	288	2	117502.58
90235	71	2	54699.02
90235	196	2	117376.75
90235	268	1	77574.76
90236	314	2	94503.20
90236	247	2	55896.40
90236	288	2	105580.19
90237	259	1	81636.93
90237	58	2	37453.55
90237	470	1	117517.16
90238	512	2	46614.82
90238	476	2	40421.34
90238	436	2	99818.26
90238	374	1	18005.60
90239	118	2	108568.12
90239	160	2	27434.74
90240	426	1	19046.87
90240	437	1	98989.02
90240	57	2	72457.50
90240	288	2	72157.64
90241	172	1	72076.85
90241	281	2	22689.59
90241	7	2	37188.23
90242	164	1	12854.41
90242	462	1	37283.09
90242	291	1	64297.93
90243	280	1	13718.01
90243	161	1	59169.31
90243	64	1	66246.94
90243	387	1	53613.49
90244	289	1	27772.44
90244	344	1	47427.20
90244	98	1	107540.89
90244	61	1	54812.09
90245	49	2	54262.27
90245	387	2	37692.80
90245	201	2	12219.56
90246	468	1	21651.27
90246	285	2	8578.04
90246	66	1	80009.41
90246	158	1	73639.07
90247	413	1	30726.81
90247	270	1	96103.54
90247	176	2	17972.75
90248	151	2	83942.56
90248	246	1	42008.84
90248	440	1	100042.51
90248	377	1	105111.99
90248	212	1	115725.79
90249	525	2	25590.80
90249	50	1	29173.87
90249	1	2	48071.08
90249	469	2	56281.09
90250	212	1	52947.20
90250	467	1	113045.50
90251	508	1	76165.31
90251	439	2	44009.46
90251	119	2	100397.76
90252	11	2	48607.77
90252	195	2	35002.31
90252	277	1	35731.02
90253	216	2	13404.35
90253	368	1	67589.48
90254	101	2	90495.57
90254	386	2	38024.36
90255	27	1	46527.60
90255	172	1	89050.74
90256	352	1	20230.40
90256	436	2	82657.28
90256	479	2	18560.43
90256	391	2	41236.36
90257	215	1	41899.51
90257	49	2	97221.01
90257	162	2	29550.42
90257	520	2	97801.66
90257	254	1	33818.08
90258	189	2	11833.32
90258	174	2	22348.25
90259	17	2	80684.24
90259	117	2	33369.35
90259	468	2	90489.10
90259	307	1	94065.01
90260	316	2	22437.25
90260	413	1	92916.82
90261	512	2	55358.53
90261	251	2	10812.94
90262	386	1	70240.30
90262	391	2	23843.20
90262	462	2	67192.09
90262	280	1	76903.86
90263	230	1	108783.63
90263	3	2	45130.50
90263	163	1	15732.83
90264	114	1	52106.65
90264	101	2	5438.81
90265	356	1	34226.44
90265	113	1	23182.85
90265	279	1	35734.15
90265	147	2	18779.01
90265	350	2	35949.08
90266	470	2	96382.48
90266	97	1	63267.60
90266	427	2	85559.07
90266	415	2	99123.60
90266	387	1	113421.63
90267	167	2	16426.00
90267	477	1	54794.97
90267	305	1	44969.63
90268	381	2	63220.02
90268	314	2	78277.47
90269	478	2	9955.86
90269	270	2	77552.46
90269	41	1	31404.01
90269	346	1	30172.21
90270	380	2	114852.05
90270	139	1	113585.41
90270	405	2	54513.54
90270	389	1	39709.34
90271	167	1	49179.36
90271	321	1	33592.84
90271	28	1	91103.75
90271	313	2	39043.22
90272	484	1	7965.35
90272	479	1	28518.96
90272	119	1	16914.41
90273	92	1	81586.30
90273	382	1	8236.89
90273	276	2	81224.32
90274	18	2	95366.86
90274	147	2	9869.54
90274	310	2	75071.13
90275	328	1	64452.30
90275	403	1	20890.66
90276	226	2	9672.62
90276	97	1	86049.08
90276	503	2	69737.21
90276	77	1	70960.20
90276	153	1	97569.78
90277	176	2	92012.32
90277	471	1	98569.12
90277	305	2	28846.27
90277	266	2	74758.28
90278	369	1	78833.11
90278	333	1	45983.38
90278	154	2	23207.58
90278	496	2	47136.68
90278	22	1	5871.54
90279	74	1	26823.62
90279	334	2	40095.20
90279	491	2	81010.05
90280	89	2	119832.67
90280	11	1	75563.34
90280	300	1	81520.78
90280	126	2	98467.48
90281	179	2	19764.88
90281	420	2	101530.91
90281	332	1	14959.66
90281	298	2	58624.63
90282	299	1	75814.92
90282	168	1	37310.36
90282	423	2	38594.12
90282	220	1	106301.16
90282	101	1	74878.50
90283	309	1	42779.78
90283	133	1	71617.79
90283	241	2	38397.90
90283	259	2	21937.16
90284	326	2	107929.87
90284	340	1	91656.35
90284	142	1	51822.65
90285	12	1	36283.89
90285	407	1	15156.72
90286	423	1	8549.55
90286	366	2	5151.58
90286	347	2	98414.75
90287	16	2	107072.23
90287	507	2	9840.38
90287	268	2	119893.30
90288	252	1	106536.88
90288	339	2	91789.85
90289	521	1	55157.74
90289	187	2	82352.23
90289	79	2	60802.00
90289	385	2	81792.44
90289	456	2	21458.84
90290	101	1	23233.32
90290	376	2	60766.58
90291	377	2	58146.31
90291	369	1	16105.69
90291	156	1	51483.62
90291	288	2	57271.35
90292	223	2	117980.13
90292	317	1	56562.72
90293	339	2	104210.06
90293	521	2	11453.56
90293	34	1	70141.43
90293	317	2	35173.41
90293	27	1	8989.54
90294	174	2	19811.63
90294	24	2	20206.75
90294	384	2	85343.70
90295	462	1	83155.84
90295	162	1	54128.30
90296	310	1	13131.33
90296	117	2	76006.54
90296	31	2	25648.99
90296	343	2	12375.11
90297	102	1	104261.33
90297	316	2	95019.94
90297	147	1	38100.66
90297	10	1	111037.32
90298	64	1	109273.73
90298	412	2	54085.30
90298	21	2	108086.50
90298	94	1	35621.16
90299	510	2	102345.54
90299	91	2	90543.35
90300	228	1	13958.56
90300	82	1	53808.61
90300	285	1	81463.19
90300	360	1	5042.83
90300	391	1	112980.89
90301	212	1	56022.85
90301	236	2	119010.46
90301	442	2	5133.80
90302	277	2	68273.35
90302	206	1	76952.48
90302	437	2	79462.14
90303	94	1	104821.21
90303	510	1	79194.37
90303	274	2	77322.00
90304	61	1	89135.00
90304	439	2	77857.38
90304	22	2	67423.60
90305	33	1	64246.52
90305	379	2	106662.08
90306	76	1	41538.61
90306	157	2	37524.67
90306	309	2	115455.16
90306	411	2	118353.71
90306	217	2	36663.47
90307	384	2	108334.84
90307	363	2	94608.71
90307	423	2	59044.61
90307	11	1	74812.93
90307	253	2	19411.35
90308	115	1	72614.46
90308	289	1	57800.69
90308	165	1	111996.99
90309	223	1	79218.71
90309	341	2	96537.44
90309	42	1	107970.10
90310	410	2	91746.31
90310	310	2	95187.85
90311	238	1	114213.50
90311	95	1	70006.61
90311	504	1	54704.05
90311	420	2	70389.40
90311	512	1	74527.12
90312	467	2	20360.91
90312	290	1	71183.34
90312	26	1	80335.70
90312	445	1	19411.09
90312	390	1	87190.01
90313	453	1	99220.87
90313	74	2	6377.21
90314	370	2	33214.83
90314	501	2	14941.68
90314	221	1	95900.55
90314	150	1	31178.86
90314	3	1	22852.86
90315	11	1	28977.54
90315	243	1	40009.15
90315	185	1	6740.94
90316	503	1	95832.21
90316	41	2	89046.36
90316	24	2	50746.62
90317	391	1	43600.03
90317	326	2	62155.92
90317	222	2	70691.84
90317	216	1	36299.40
90317	255	1	105383.88
90318	359	2	37909.23
90318	188	2	118115.02
90319	462	1	21895.55
90319	231	2	101396.39
90319	44	1	8008.52
90319	187	2	8773.07
90320	500	1	39745.33
90320	300	1	115096.29
90320	13	1	32972.67
90321	394	2	9670.25
90321	36	2	60453.87
90321	294	1	59522.25
90322	280	1	59638.09
90322	457	2	32913.65
90322	512	1	72124.64
90322	52	2	45639.74
90323	405	1	71834.76
90323	267	2	112750.73
90323	202	1	18487.63
90324	188	1	12524.63
90324	256	2	22360.32
90324	321	2	93139.67
90325	192	2	33158.82
90325	403	1	81217.03
90325	333	2	73654.04
90325	446	1	76577.61
90326	404	1	110662.07
90326	453	1	53853.48
90327	118	2	119052.99
90327	427	2	78939.33
90327	483	2	93546.71
90327	456	1	118228.13
90328	45	1	109785.71
90328	510	1	108894.32
90328	379	2	48125.47
90329	365	2	34280.16
90329	53	1	82266.12
90329	431	2	35457.28
90330	333	2	6591.78
90330	421	2	78494.46
90330	207	2	73901.55
90330	312	1	76880.77
90331	39	1	22283.01
90331	281	2	38103.62
90331	216	1	62364.00
90331	436	2	43558.52
90331	481	1	73682.76
90332	80	1	118098.12
90332	388	1	53751.15
90332	469	2	47611.57
90332	504	1	87899.15
90332	243	2	30467.47
90333	185	2	35560.26
90333	500	1	72382.86
90333	250	2	100695.30
90334	317	2	29177.87
90334	325	1	19996.89
90334	387	2	92093.36
90334	451	2	109980.61
90335	518	1	109615.45
90335	167	1	52455.31
90335	245	2	91173.56
90335	195	1	89277.92
90336	342	1	8956.05
90336	311	1	40687.76
90336	11	1	99998.05
90337	223	1	18728.34
90337	133	1	61847.07
90337	113	2	103280.15
90337	3	2	48213.60
90337	230	2	31713.49
90338	511	1	109555.91
90338	277	1	102028.42
90338	325	2	70454.89
90338	328	2	5547.28
90339	181	1	95086.21
90339	400	2	115684.79
90339	166	1	62639.15
90340	122	1	7522.46
90340	257	1	49162.31
90340	433	2	118298.85
90340	121	2	109496.70
90340	194	1	24874.81
90341	319	1	6050.91
90341	482	1	102579.25
90342	315	2	10053.48
90342	274	2	69846.34
90342	312	1	32222.16
90343	396	1	87362.20
90343	254	1	116169.92
90343	503	2	63136.38
90343	126	2	72750.63
90343	154	1	101115.64
90344	305	2	39875.08
90344	32	1	54659.29
90344	486	2	53088.12
90344	153	2	37562.60
90344	470	1	91229.85
90345	473	2	44930.24
90345	337	1	8767.68
90345	443	2	77886.28
90345	2	2	27323.78
90346	250	2	90117.65
90346	430	1	83239.31
90346	239	1	35808.87
90346	474	1	91946.44
90346	119	2	50163.87
90347	521	1	61112.62
90347	304	1	15971.08
90348	263	1	47154.02
90348	218	1	54630.96
90348	113	1	36373.59
90348	175	2	82545.82
90348	290	1	71717.87
90349	63	1	65996.13
90349	326	1	106465.73
90350	323	1	105912.24
90350	56	1	102633.07
90350	135	2	21011.90
90350	512	1	35145.52
90351	238	2	50755.61
90351	169	2	80014.84
90352	423	2	41851.22
90352	85	2	109560.32
90352	194	2	62592.04
90352	111	2	74215.77
90353	463	1	108229.77
90353	397	1	117446.62
90353	474	1	8528.34
90354	229	1	31464.75
90354	131	2	10089.85
90355	487	1	90431.61
90355	65	2	104157.47
90355	481	2	54330.99
90356	512	1	61089.75
90356	498	2	74378.58
90357	429	1	96394.76
90357	3	2	73181.73
90357	97	2	70125.34
90357	513	2	110401.75
90358	504	1	44205.55
90358	431	2	74573.38
90359	475	2	50324.07
90359	391	1	49559.94
90359	449	2	91492.67
90359	226	1	101244.24
90359	279	2	113135.80
90360	471	2	14540.79
90360	291	2	45277.03
90361	522	1	52683.81
90361	343	1	52877.19
90361	461	2	56808.98
90362	215	2	112070.30
90362	265	1	35044.26
90362	375	1	48865.26
90362	163	1	81461.30
90362	63	2	11769.81
90363	351	1	24731.92
90363	466	1	50554.45
90363	343	2	114203.44
90363	213	1	57365.98
90363	214	2	89361.73
90364	489	2	105393.37
90364	345	1	66508.12
90364	398	1	56826.31
90364	287	2	80101.69
90365	465	2	42238.04
90365	143	2	95325.50
90366	226	2	19254.71
90366	483	1	109687.67
90366	167	1	79241.01
90366	97	1	74441.11
90366	424	1	116642.56
90367	186	1	116150.05
90367	498	1	6541.75
90367	214	2	114250.13
90368	67	2	23548.45
90368	316	2	94789.11
90369	79	1	47390.65
90369	367	1	59748.40
90369	12	2	8782.83
90369	489	1	36306.31
90369	388	1	10244.69
90370	483	2	69456.41
90370	184	1	59014.35
90370	521	1	49902.55
90371	521	2	106734.58
90371	333	1	71727.79
90371	20	1	46487.77
90372	226	2	51148.17
90372	6	2	66968.39
90373	71	1	50270.19
90373	290	2	84188.34
90373	334	1	14605.53
90374	90	1	79316.45
90374	286	1	46605.40
90374	364	2	8604.66
90375	156	1	88529.39
90375	256	2	102865.65
90375	170	2	8855.62
90376	514	2	79020.73
90376	384	1	72287.12
90377	347	1	14219.63
90377	515	1	86870.60
90377	339	1	45817.11
90378	78	1	97003.35
90378	67	1	103508.25
90378	156	2	12484.31
90378	333	2	66546.75
90378	442	2	30776.16
90379	247	2	107404.12
90379	176	2	55151.68
90379	85	1	20767.71
90379	229	2	101425.98
90380	127	2	10605.49
90380	429	2	81081.73
90380	347	1	108535.60
90381	440	1	82493.80
90381	506	2	65729.57
90381	278	1	63831.66
90381	484	2	44610.02
90381	48	1	42617.58
90382	451	1	109975.23
90382	217	1	7616.95
90382	361	2	88928.67
90382	91	1	42418.53
90383	103	1	79160.47
90383	160	1	118392.96
90383	363	2	44502.45
90383	276	1	10525.49
90383	303	2	64946.60
90384	248	2	86912.71
90384	294	2	43826.12
90385	356	2	13362.70
90385	86	2	100064.00
90386	319	1	78001.91
90386	133	2	107569.27
90386	101	1	30665.07
90386	475	1	8329.88
90387	289	1	78262.69
90387	91	1	7656.80
90387	79	2	14377.00
90387	466	1	56594.18
90388	152	2	11502.09
90388	412	2	117278.20
90388	233	1	109153.13
90388	28	2	18307.95
90388	79	2	73197.34
90389	147	2	66318.47
90389	350	1	41599.47
90389	88	1	42634.06
90389	485	1	116552.38
90389	151	2	35302.04
90390	470	2	108485.18
90390	106	1	88939.60
90390	124	2	85478.59
90390	127	2	29603.37
90391	188	2	17684.50
90391	487	1	104946.72
90391	121	1	25920.63
90392	469	1	40915.25
90392	72	2	42193.70
90393	28	2	112985.01
90393	82	2	81467.49
90394	307	2	26662.60
90394	129	1	100896.60
90394	244	1	108948.73
90394	456	2	66534.00
90394	227	1	41645.79
90395	276	2	112874.99
90395	173	1	44924.71
90395	271	1	27622.02
90395	139	2	118724.03
90395	109	2	84333.54
90396	27	2	77077.16
90396	400	2	110195.00
90396	229	2	70985.77
90396	122	1	93183.03
90396	160	2	33333.29
90397	148	1	9851.23
90397	472	1	60868.62
90397	155	1	67157.04
90397	201	2	30170.02
90398	267	2	62614.53
90398	107	2	8776.32
90398	223	2	21427.72
90398	315	2	39504.76
90399	313	1	67366.07
90399	464	1	50768.85
90400	448	1	22097.26
90400	354	2	43642.79
90401	475	2	42485.04
90401	478	1	87823.72
90401	376	2	99620.22
90401	432	1	85767.24
90401	516	2	93241.08
90402	376	1	78315.55
90402	258	2	43104.52
90402	267	2	91781.22
90403	249	2	103837.10
90403	6	2	28219.71
90403	94	1	82755.56
90403	447	2	35123.35
90403	298	2	17172.16
90404	35	2	22919.18
90404	361	1	58445.74
90404	341	2	10397.60
90404	29	1	57186.33
90405	124	2	31807.01
90405	69	2	17299.45
90406	342	2	19150.30
90406	55	1	74620.04
90406	505	2	116121.38
90406	57	2	119993.89
90406	273	1	13101.31
90407	189	2	48390.78
90407	331	1	110790.05
90407	291	2	116748.25
90407	413	1	29453.68
90407	458	2	5473.07
90408	314	2	81225.31
90408	71	2	20095.92
90408	126	2	92175.08
90408	175	2	72939.79
90408	450	2	76044.29
90409	208	1	25964.92
90409	141	2	119685.07
90409	420	1	47154.53
90409	315	2	17873.33
90410	42	2	20267.29
90410	327	1	107909.43
90410	184	1	54374.66
90411	508	1	61925.39
90411	372	2	42373.82
90411	74	1	64615.12
90412	119	2	100255.15
90412	190	1	106231.86
90412	52	2	57055.92
90412	97	2	46140.41
90413	22	2	31550.81
90413	400	1	64305.19
90414	326	1	83914.65
90414	401	1	63002.31
90414	107	1	56091.53
90414	196	1	44485.32
90415	390	2	50404.49
90415	524	1	51703.44
90415	29	1	84456.31
90415	57	1	59228.04
90415	67	1	110619.47
90416	230	2	14630.19
90416	193	2	47243.51
90416	278	2	21203.51
90416	5	2	27443.66
90416	252	2	50698.98
90417	33	2	101805.36
90417	503	1	85985.76
90417	281	2	6100.51
90417	261	1	28084.99
90418	512	1	68881.96
90418	22	2	75385.41
90418	83	1	13451.99
90419	334	1	96911.88
90419	72	2	116727.92
90419	489	2	102553.31
90420	287	1	102028.80
90420	284	1	60723.35
90420	133	2	28679.38
90420	34	1	52836.80
90420	359	1	108288.97
90421	68	2	28415.81
90421	61	1	47144.53
90422	446	1	79967.21
90422	79	2	111580.47
90422	149	2	67044.71
90422	45	1	83054.16
90422	288	1	119429.92
90423	419	1	81038.36
90423	286	1	28675.38
90423	368	1	7428.02
90423	283	1	101417.99
90423	236	2	67515.58
90424	316	2	91503.19
90424	392	2	17290.27
90424	309	2	23487.72
90425	2	1	19874.38
90425	104	1	57311.63
90425	156	2	31768.90
90425	462	2	114905.69
90426	153	2	71771.07
90426	491	2	31891.62
90426	271	1	44739.82
90427	283	2	74913.78
90427	137	2	81856.02
90427	62	1	51501.63
90427	40	1	96235.60
90428	498	2	19597.25
90428	369	2	67496.77
90428	158	1	72704.46
90428	117	1	43085.75
90429	389	1	99973.83
90429	77	2	46112.72
90430	309	1	27145.50
90430	142	1	36541.35
90431	413	1	114233.13
90431	35	1	86861.17
90431	315	1	43744.75
90432	116	2	42757.28
90432	425	2	108038.27
90432	113	2	14396.14
90433	112	1	26962.40
90433	228	1	62685.67
90433	431	1	27985.85
90433	424	1	110707.04
90434	451	1	118794.01
90434	85	1	10635.36
90434	143	1	94245.99
90435	227	2	22865.85
90435	372	2	15951.71
90435	307	2	102717.44
90435	101	2	97509.66
90435	394	1	112480.67
90436	290	1	77258.86
90436	158	1	33161.50
90436	311	2	96173.04
90437	251	1	26349.41
90437	154	2	77871.84
90437	464	1	111520.79
90437	461	1	31155.40
90438	496	1	5034.72
90438	391	1	63160.88
90439	116	2	27584.44
90439	142	1	104725.22
90439	54	1	84073.71
90439	97	2	86837.10
90440	257	1	9228.54
90440	420	1	96754.49
90440	191	1	50708.01
90440	477	2	33578.62
90440	504	1	49725.95
90441	152	2	56565.09
90441	332	2	114496.45
90442	171	1	66965.00
90442	501	1	16912.08
90442	32	1	64244.93
90443	42	2	11345.14
90443	403	2	30259.47
90443	283	2	44863.06
90443	432	2	22141.41
90443	484	2	20467.56
90444	191	2	36083.08
90444	312	1	19154.76
90445	126	1	26791.67
90445	437	2	48196.08
90445	522	2	48785.11
90445	250	2	115796.19
90446	423	2	47551.19
90446	452	1	66682.97
90447	522	2	63724.23
90447	176	2	31581.48
90447	218	1	99820.68
90447	151	1	57082.39
90447	436	1	63627.60
90448	481	1	74202.00
90448	220	2	35644.68
90449	339	1	41281.65
90449	244	2	87996.22
90449	435	2	83933.57
90450	338	1	40322.36
90450	491	2	34838.34
90450	95	2	116143.87
90450	263	2	61661.49
90451	201	1	23005.47
90451	430	1	84123.03
90451	52	2	92176.74
90452	256	2	21280.43
90452	395	1	112955.97
90452	491	1	53207.00
90452	422	1	38024.72
90452	318	2	115539.27
90453	431	1	63724.65
90453	222	2	56705.09
90453	98	1	106895.67
90453	460	1	35401.73
90453	239	1	8751.05
90454	376	2	8990.89
90454	284	2	40206.78
90454	200	2	48421.07
90454	38	1	8400.07
90454	465	1	80039.01
90455	428	1	58428.40
90455	291	2	17084.03
90455	343	2	58271.27
90456	402	1	12503.08
90456	152	1	33912.34
90456	415	1	97979.06
90457	525	1	79890.53
90457	268	1	46743.25
90457	437	2	35611.64
90457	464	2	117881.22
90458	520	2	91746.72
90458	304	2	51546.97
90458	180	2	39563.95
90459	434	1	74327.57
90459	50	2	105703.41
90459	365	2	27146.66
90459	317	2	61426.27
90459	411	2	15063.73
90460	507	1	88005.87
90460	95	2	50305.32
90460	347	1	15393.54
90460	351	2	40692.33
90460	125	2	49694.17
90461	245	1	64601.38
90461	425	2	112390.77
90461	244	1	72038.68
90461	115	1	65279.94
90462	269	2	101257.39
90462	317	2	74124.48
90462	463	1	6655.33
90462	237	1	40127.26
90462	59	1	34077.03
90463	516	2	28019.75
90463	28	1	34019.68
90463	295	2	112672.21
90463	155	2	113771.01
90464	513	2	36335.62
90464	447	2	55535.91
90465	308	2	109168.10
90465	323	2	27690.01
90466	60	2	42903.56
90466	122	1	28838.36
90467	328	2	25148.10
90467	68	1	109204.03
90468	187	2	85208.53
90468	306	1	16994.30
90468	148	2	57674.90
90469	212	2	61631.98
90469	71	2	49522.97
90469	143	1	10867.04
90470	485	1	7358.39
90470	104	1	6084.58
90470	193	1	44019.19
90471	484	2	47786.55
90471	99	1	112723.94
90471	458	2	99232.07
90471	15	2	113269.14
90471	437	2	116269.13
90472	287	1	76320.88
90472	191	2	42126.53
90472	312	2	103300.93
90473	186	2	81960.74
90473	491	1	93350.27
90474	389	2	44909.98
90474	246	1	71596.81
90475	141	2	19184.00
90475	386	2	23123.89
90475	352	1	14266.89
90475	276	1	111247.08
90476	165	2	80762.60
90476	48	1	61162.20
90476	489	1	27380.57
90476	217	1	117918.77
90477	400	1	57136.10
90477	96	1	87654.56
90477	332	2	51921.59
90477	9	2	71271.33
90478	212	1	119760.02
90478	36	1	109609.52
90478	51	1	21836.22
90479	419	1	31251.46
90479	2	2	114339.18
90479	381	1	29603.50
90479	171	2	117335.20
90480	109	2	107274.09
90480	283	1	13941.05
90481	450	2	92780.45
90481	328	1	44151.63
90481	250	1	58549.74
90482	295	2	59739.72
90482	232	1	65992.85
90482	305	2	99560.79
90482	462	2	110963.52
90482	131	2	31017.60
90483	146	1	15196.85
90483	254	2	78211.79
90483	395	2	96706.29
90483	479	1	104118.46
90483	239	1	37453.09
90484	150	2	115050.39
90484	247	1	101831.27
90485	338	2	24545.26
90485	156	2	31125.21
90486	223	2	13447.11
90486	505	2	113391.95
90487	149	1	113793.14
90487	436	2	57592.99
90487	81	2	118913.64
90487	460	1	17258.03
90487	295	2	15541.31
90488	219	1	80076.82
90488	290	2	57284.33
90489	270	1	57720.57
90489	201	1	59922.76
90489	286	2	13972.99
90489	128	2	16635.22
90489	240	1	26309.43
90490	216	2	80440.09
90490	486	1	39230.86
90490	42	2	48383.16
90491	110	1	39457.95
90491	389	1	92313.41
90491	39	2	44292.25
90492	11	1	20469.36
90492	87	2	93584.73
90492	77	2	88046.21
90492	320	2	78385.71
90493	65	2	100901.37
90493	263	2	57364.47
90493	424	1	111501.59
90494	209	2	97327.52
90494	371	2	66625.45
90495	187	2	8800.46
90495	420	1	104391.30
90495	482	2	9413.12
90495	275	2	67239.24
90495	330	1	115477.25
90496	43	1	71636.00
90496	283	1	49794.01
90496	193	2	74438.61
90497	431	2	117874.58
90497	360	1	46051.24
90497	50	2	84369.01
90497	313	2	93115.41
90498	457	1	87976.53
90498	348	2	115760.74
90499	271	2	87740.49
90499	516	1	114675.69
90499	33	2	81101.52
90500	427	2	12298.00
90500	50	2	53784.75
90501	6	2	18620.06
90501	171	1	26850.92
90501	98	2	43125.73
90502	28	2	77244.92
90502	373	1	86639.81
90503	399	2	83192.28
90503	281	1	115786.17
90503	175	2	34020.47
90504	146	2	31116.01
90504	317	2	64356.44
90504	66	1	76025.85
90504	397	1	23119.41
90505	142	2	61196.83
90505	63	2	101807.61
90506	461	2	68984.22
90506	31	2	23694.24
90506	419	2	68767.80
90507	56	2	9491.92
90507	424	2	43255.51
90507	332	2	43794.69
90507	471	1	113424.32
90508	307	2	89972.55
90508	288	1	38604.95
90509	71	1	6704.08
90509	130	1	10395.29
90509	210	2	7534.69
90510	519	1	96945.86
90510	453	1	86215.11
90510	11	1	18117.72
90510	14	1	109690.70
90511	192	1	78107.61
90511	226	1	41504.09
90512	253	2	48691.94
90512	218	2	26689.88
90512	297	1	95531.59
90513	185	1	66574.67
90513	488	2	61507.48
90513	126	1	104151.54
90513	271	1	105252.87
90514	419	1	102942.05
90514	187	1	15010.99
90515	377	2	100080.15
90515	356	1	30518.96
90515	92	1	6622.30
90515	222	1	26816.37
90516	496	2	94777.18
90516	210	2	23889.39
90516	173	1	85600.31
90516	38	2	96236.86
90516	223	2	24893.07
90517	158	1	46905.87
90517	286	1	103569.35
90517	77	2	113175.14
90517	415	1	18515.54
90517	279	2	47102.82
90518	454	1	45242.83
90518	18	1	96902.44
90518	221	1	96784.21
90518	465	2	52132.53
90518	169	1	43381.73
90519	372	2	96709.97
90519	404	1	81514.17
90519	311	2	34984.33
90519	400	1	91151.28
90520	378	2	22109.00
90520	75	1	33362.03
90521	181	1	71186.70
90521	92	1	27425.37
90522	171	2	47473.49
90522	418	2	83001.28
90522	264	1	100673.44
90523	93	1	14351.79
90523	160	1	56276.88
90524	102	2	25718.24
90524	377	1	97905.59
90525	117	2	36621.60
90525	419	2	111255.97
90525	343	1	38397.53
90525	297	2	59686.79
90526	278	2	113652.64
90526	265	2	19258.35
90527	32	2	15059.97
90527	15	1	96617.98
90527	188	1	73441.65
90527	42	1	20886.66
90527	243	1	48056.46
90528	525	1	10113.43
90528	314	2	79215.91
90528	436	1	80075.76
90528	267	1	58883.54
90528	198	2	62817.21
90529	383	2	97092.63
90529	290	1	74697.90
90529	136	2	69392.43
90529	299	2	31001.50
90530	343	1	37914.48
90530	376	1	14131.99
90530	346	1	27513.02
90531	53	2	37631.78
90531	455	1	84167.05
90531	202	2	48302.72
90531	87	1	44801.76
90531	427	2	9295.81
90532	180	1	59967.13
90532	523	2	84292.16
90533	180	1	111548.10
90533	462	2	104256.16
90533	153	1	57780.03
90533	440	2	43916.02
90533	291	2	21852.85
90534	441	1	29092.64
90534	27	1	23236.89
90534	187	2	56716.73
90534	484	1	74203.51
90535	377	1	24467.31
90535	292	2	40020.92
90535	237	2	108905.43
90535	80	2	69682.93
90535	490	2	58520.74
90536	178	1	42700.26
90536	408	1	29740.39
90536	376	2	59251.83
90536	198	2	118410.62
90536	38	2	46378.19
90537	468	2	84293.39
90537	146	1	97985.04
90538	265	2	60432.91
90538	62	1	47837.26
90538	359	1	86059.52
90539	417	2	43151.26
90539	185	1	54984.23
90539	105	2	45955.42
90539	339	2	55834.96
90539	295	1	27951.16
90540	383	2	36038.51
90540	419	1	37400.90
90540	200	2	36467.39
90541	352	2	86549.18
90541	69	1	79156.16
90541	119	1	65492.36
90541	47	1	113691.43
90541	344	2	83949.61
90542	368	1	80332.47
90542	352	2	113408.68
90543	377	1	84303.34
90543	399	2	54327.24
90544	69	1	107910.82
90544	113	1	45423.02
90544	151	1	88806.48
90544	204	1	91199.73
90544	99	1	89563.68
90545	9	1	16381.89
90545	38	2	97782.66
90545	381	2	106319.02
90545	131	1	68532.58
90545	277	1	107602.78
90546	60	2	14851.03
90546	269	2	74298.82
90546	37	2	98316.75
90546	55	1	57458.86
90546	387	1	90963.77
90547	338	1	81434.64
90547	242	2	58860.02
90548	472	2	52687.73
90548	512	2	92270.86
90548	45	2	32997.63
90549	115	2	40688.43
90549	489	2	91874.34
90549	97	2	63992.32
90550	398	2	6853.96
90550	348	1	71429.19
90551	15	1	94699.24
90551	460	1	111982.69
90551	238	1	55669.92
90551	46	2	41603.72
90551	7	2	101394.28
90552	255	2	29390.83
90552	183	2	112694.94
90552	490	2	69278.60
90552	402	1	97408.01
90552	466	2	71734.88
90553	126	1	100313.04
90553	523	1	52725.60
90554	217	2	118769.48
90554	134	1	104843.45
90554	116	2	93781.33
90554	517	1	44058.03
90555	218	2	54789.46
90555	70	1	21391.54
90555	83	2	114309.78
90555	2	1	88005.83
90556	157	2	53087.55
90556	229	1	111180.14
90556	19	2	19093.61
90557	492	1	48964.16
90557	165	1	24532.93
90558	42	1	78684.90
90558	2	1	114967.11
90558	330	1	65205.43
90559	15	1	80635.35
90559	96	2	66194.51
90559	446	1	65997.05
90559	370	2	32571.72
90560	251	2	17466.70
90560	25	1	59525.36
90560	385	2	34773.12
90560	46	1	113806.70
90561	32	2	27489.71
90561	50	2	73691.44
90562	27	2	54065.69
90562	305	2	99417.38
90562	142	1	13390.04
90563	376	1	59186.21
90563	146	2	20679.38
90563	118	1	7036.32
90564	240	1	66829.22
90564	128	2	118258.44
90564	293	2	60279.39
90564	453	2	61289.07
90564	397	2	66396.39
90565	412	1	71425.06
90565	238	1	23184.16
90565	179	2	51887.13
90566	259	1	58584.38
90566	349	1	18259.36
90566	168	2	35982.20
90566	65	2	50207.29
90566	80	1	44422.48
90567	389	2	117659.08
90567	330	2	12379.59
90567	373	2	12108.42
90568	410	2	13173.04
90568	222	2	90074.27
90568	2	2	88448.76
90568	290	2	107752.60
90569	267	2	117998.37
90569	121	1	62472.35
90569	499	1	52057.10
90570	422	2	73318.17
90570	96	2	99794.05
90570	507	2	89811.49
90570	346	1	35000.67
90571	477	2	106321.00
90571	81	2	46303.84
90571	21	2	83964.13
90571	61	1	10334.98
90571	412	2	38640.13
90572	319	1	15773.10
90572	317	1	8508.01
90572	200	2	17484.41
90572	116	2	5611.36
90573	51	1	60954.66
90573	339	1	65105.01
90573	429	1	93484.32
90574	14	1	63766.15
90574	180	2	65012.62
90574	272	2	61547.12
90575	195	2	6950.38
90575	271	2	90644.55
90576	460	1	86913.81
90576	194	1	91707.89
90576	300	1	116960.25
90576	490	1	102912.95
90576	372	1	64092.07
90577	194	2	48263.33
90577	124	1	62566.64
90577	4	1	83132.49
90577	122	2	43783.75
90578	309	2	39635.06
90578	172	1	14197.17
90578	507	2	86335.84
90579	347	1	80410.50
90579	296	2	45290.95
90579	444	1	14637.67
90580	474	2	77090.79
90580	510	2	15664.86
90580	187	1	29118.19
90581	411	1	31107.48
90581	219	1	111941.23
90582	468	1	41895.07
90582	351	2	97388.31
90582	173	2	78089.02
90582	309	2	48053.10
90582	140	1	40945.94
90583	322	1	118549.44
90583	279	1	52077.85
90583	72	2	99502.12
90584	155	2	86928.77
90584	337	2	15375.31
90585	113	1	70425.02
90585	160	1	75325.44
90585	167	1	98332.00
90586	182	2	16426.61
90586	465	2	107967.61
90586	469	2	113887.88
90587	367	2	72121.88
90587	422	1	57296.12
90588	379	2	95711.24
90588	416	2	42659.86
90589	224	1	105171.76
90589	384	2	47106.58
90589	490	1	93854.98
90589	150	1	36265.29
90589	388	1	101459.32
90590	465	2	102006.41
90590	361	1	56570.44
90590	166	2	7433.15
90590	218	2	20219.78
90591	371	2	78093.22
90591	148	2	105432.67
90591	214	1	65486.65
90591	44	1	72328.39
90591	232	1	77834.31
90592	187	2	24755.00
90592	238	1	41108.55
90592	186	2	43058.63
90592	172	2	90367.46
90592	430	1	88853.88
90593	65	2	64669.88
90593	60	2	5773.77
90593	249	2	27232.49
90593	273	2	102061.58
90594	108	2	106897.37
90594	398	2	48300.83
90595	263	1	84627.17
90595	5	2	119958.46
90595	272	1	100015.38
90596	513	2	106326.29
90596	119	2	59669.62
90596	403	2	66104.38
90596	143	1	101081.63
90596	415	2	24628.98
90597	489	1	79298.29
90597	401	2	94821.71
90597	300	1	91620.64
90598	84	1	68366.91
90598	368	2	96404.87
90598	347	1	48879.04
90598	108	1	107577.90
90599	340	2	118308.79
90599	230	2	21868.34
90599	333	1	114832.56
90599	268	2	74246.79
90599	469	1	35486.99
90600	463	1	109733.42
90600	479	2	23562.90
90600	365	1	100294.48
90601	42	2	35854.53
90601	94	2	103310.42
90602	462	2	59339.33
90602	90	1	41290.81
90602	341	2	59127.82
90602	70	1	57424.09
90603	436	2	79250.31
90603	360	2	36234.87
90603	89	2	79437.19
90603	512	2	54482.39
90603	202	2	98469.18
90604	47	2	52736.00
90604	88	2	19452.39
90605	483	1	95352.86
90605	408	2	70132.40
90605	452	1	70013.24
90606	120	2	104934.32
90606	170	1	21653.92
90606	408	2	22232.64
90607	66	1	89254.61
90607	71	1	51276.50
90608	198	2	91016.20
90608	504	1	47756.48
90608	437	2	30664.28
90608	91	2	39580.51
90608	217	2	41434.80
90609	109	2	60194.47
90609	340	1	89113.35
90609	31	2	38591.00
90609	228	2	99065.94
90609	493	1	97020.23
90610	515	2	52903.91
90610	401	1	58981.96
90611	318	2	9535.24
90611	17	2	25980.29
90611	261	1	111566.28
90611	206	1	49830.68
90611	279	2	66915.53
90612	344	1	109100.86
90612	472	1	45934.30
90612	94	1	22862.39
90613	314	1	70880.75
90613	335	1	81031.93
90614	319	2	71929.81
90614	122	2	119719.53
90614	253	1	8417.84
90614	489	1	73436.77
90615	257	2	71921.06
90615	517	1	47886.31
90615	332	2	58353.37
90616	145	1	111008.70
90616	414	2	24141.96
90617	123	2	54338.84
90617	436	1	36806.25
90617	164	1	52837.51
90617	432	2	62460.30
90618	244	2	116756.38
90618	480	1	9402.99
90618	349	1	46372.78
90618	226	2	100785.75
90618	224	2	75208.20
90619	350	2	107587.22
90619	112	1	68432.78
90620	354	2	19921.20
90620	154	1	37064.47
90621	163	2	51340.60
90621	179	2	56461.11
90621	503	2	95759.04
90622	236	1	67392.37
90622	55	2	61056.26
90623	475	1	115260.28
90623	441	1	104889.58
90623	322	2	36865.80
90623	371	1	22467.62
90624	409	1	7672.58
90624	378	1	106461.10
90624	59	2	101064.05
90624	116	2	64974.91
90625	48	2	15234.78
90625	104	1	41431.80
90625	150	1	47342.78
90625	229	2	106002.45
90625	255	1	118787.34
90626	197	1	16318.02
90626	132	2	95336.36
90626	433	1	50873.12
90626	385	1	42504.71
90626	261	1	69726.98
90627	370	2	44277.93
90627	400	2	17010.42
90628	320	2	96652.31
90628	40	1	115368.67
90628	199	1	28846.01
90629	150	2	114704.92
90629	424	2	73773.25
90630	189	2	47393.34
90630	96	1	48814.41
90631	290	1	75403.81
90631	512	2	111276.49
90632	138	2	90720.44
90632	512	1	59390.87
90633	476	2	96177.78
90633	140	2	93444.60
90633	432	2	44615.96
90634	231	1	117156.65
90634	262	2	17636.21
90635	281	1	54640.64
90635	335	1	37138.29
90635	40	1	33517.66
90635	439	2	80210.51
90636	413	1	114333.57
90636	128	2	54193.96
90637	314	2	99420.90
90637	7	2	59632.32
90637	211	1	103945.24
90638	404	2	61226.82
90638	441	2	66291.99
90638	469	1	62937.06
90639	494	1	84040.48
90639	277	1	91158.34
90640	449	2	37978.23
90640	325	1	39672.05
90640	218	1	36161.67
90640	401	1	5806.42
90640	300	1	27000.05
90641	404	2	31877.10
90641	466	2	71216.75
90641	363	2	97804.19
90642	502	2	60512.84
90642	221	2	9441.25
90642	50	1	118065.86
90642	460	2	23531.67
90643	320	2	13652.95
90643	122	1	13189.84
90643	98	1	117516.58
90643	449	2	111457.92
90644	227	2	52217.90
90644	199	2	70209.88
90644	88	1	111357.41
90644	234	1	70159.23
90644	270	2	12602.85
90645	230	1	111104.00
90645	292	2	22922.25
90645	138	2	69049.75
90645	329	2	115619.30
90646	481	2	113551.55
90646	443	1	50584.55
90646	338	1	31816.57
90646	120	1	66484.79
90646	363	1	17087.90
90647	520	1	38250.94
90647	428	1	12795.33
90648	55	1	35157.12
90648	29	2	118733.00
90648	372	2	17337.07
90648	198	2	46405.37
90649	121	1	105107.81
90649	247	2	42771.17
90649	168	2	106827.38
90649	386	1	12424.94
90650	177	2	70759.13
90650	323	1	16557.81
90650	349	2	104185.75
90650	354	2	39318.44
90650	232	1	45109.26
90651	264	1	9611.70
90651	201	1	17452.08
90651	361	2	41565.09
90651	26	1	107246.50
90652	161	2	118083.14
90652	115	2	100833.40
90652	493	1	93532.81
90653	57	2	15913.92
90653	163	1	18076.55
90654	77	1	55683.44
90654	384	2	99353.56
90654	60	2	90084.91
90654	259	2	93234.37
90655	81	1	34944.27
90655	364	1	51007.74
90655	70	1	85927.30
90655	29	1	14708.41
90656	89	1	9403.83
90656	415	2	111807.66
90656	442	1	18594.75
90656	60	2	18411.38
90657	233	2	55467.97
90657	49	2	54253.27
90658	278	2	88818.30
90658	408	1	58749.90
90658	106	2	110544.77
90658	133	2	17317.52
90659	428	1	15695.81
90659	203	2	74495.65
90659	88	2	85993.58
90660	291	1	74342.59
90660	414	2	103332.62
90661	248	2	31763.20
90661	261	1	61018.94
90661	188	1	7624.94
90662	134	1	84290.32
90662	306	2	115934.28
90662	416	1	61803.03
90662	204	1	38202.81
90662	1	1	57811.83
90663	265	2	111890.68
90663	425	1	92568.62
90663	383	2	58737.11
90664	187	1	87379.94
90664	405	1	11393.99
90664	113	2	42516.43
90665	205	2	111507.79
90665	310	2	81983.70
90666	382	1	70494.98
90666	298	2	38929.45
90666	443	1	78608.95
90666	467	1	60940.06
90666	206	2	44570.30
90667	182	2	9599.28
90667	294	2	71191.63
90667	30	1	12068.15
90667	239	1	86910.26
90667	19	1	65181.08
90668	219	2	28186.93
90668	294	1	98620.62
90668	503	2	56730.56
90668	181	2	28467.62
90668	489	2	9485.53
90669	414	2	21770.33
90669	503	2	43173.91
90669	333	2	75486.39
90669	516	1	44124.49
90669	383	1	54208.17
90670	305	1	10424.68
90670	214	2	115919.99
90670	407	1	118765.04
90670	98	2	74487.13
90671	232	2	111969.93
90671	413	2	72016.37
90671	468	1	39870.50
90671	289	1	106248.66
90672	1	1	22572.34
90672	213	2	84350.41
90672	224	1	38110.50
90672	363	2	61240.82
90672	412	1	104027.94
90673	146	1	104363.08
90673	77	1	46147.71
90674	402	2	110511.81
90674	414	2	6870.69
90675	2	1	89623.96
90675	11	1	75031.66
90675	223	2	116384.03
90675	356	1	107664.38
90675	477	1	74481.87
90676	55	1	63820.53
90676	129	2	19953.48
90677	504	2	51057.50
90677	278	2	16963.12
90678	347	2	76423.50
90678	106	2	102610.00
90678	316	2	88245.56
90678	189	1	103115.86
90679	393	1	62579.59
90679	25	2	104271.14
90679	499	1	115216.79
90679	148	1	11632.21
90679	344	1	29130.07
90680	226	2	37921.81
90680	334	1	73162.80
90680	124	1	34601.27
90681	59	1	113878.43
90681	515	1	112656.05
90682	188	2	56624.34
90682	198	1	48391.68
90682	400	1	113886.27
90683	36	1	82201.32
90683	175	1	84563.05
90683	372	2	35427.26
90683	279	2	47962.60
90683	130	1	31316.51
90684	304	2	100311.88
90684	368	2	82145.56
90684	117	2	42546.49
90684	377	2	114067.62
90685	319	2	93526.78
90685	352	1	81076.12
90685	12	2	32721.46
90685	307	2	22427.78
90685	493	2	24896.31
90686	462	2	32925.67
90686	218	2	111283.01
90686	232	2	33264.02
90687	132	1	90635.42
90687	82	1	20471.04
90688	174	2	41442.42
90688	304	1	107870.02
90688	359	2	112671.35
90688	522	1	66646.23
90689	92	1	9053.43
90689	125	2	6295.33
90689	4	1	105178.58
90689	520	1	18522.74
90689	474	2	91085.92
90690	266	1	117629.64
90690	382	1	29250.37
90690	352	2	7891.56
90691	518	1	61979.10
90691	236	2	59247.71
90691	484	1	30313.51
90692	239	1	38283.02
90692	517	1	35144.90
90692	219	2	67892.56
90692	139	2	56311.04
90692	268	1	63947.40
90693	354	2	38294.50
90693	280	2	19261.36
90693	120	1	67456.44
90694	426	2	97741.07
90694	270	1	41028.52
90694	147	2	24574.31
90694	504	2	88755.90
90695	7	2	96041.29
90695	322	2	32604.19
90695	512	1	64906.68
90695	29	2	92597.29
90696	489	2	61472.03
90696	203	2	119370.24
90696	493	2	40118.48
90697	434	1	50072.77
90697	60	1	59972.99
90698	26	2	74796.78
90698	73	1	37492.75
90698	325	2	66749.59
90699	492	2	56418.98
90699	252	1	37653.11
90699	270	1	92650.96
90699	101	1	72431.10
90700	414	2	38746.07
90700	47	2	80048.07
90700	100	1	5063.16
90701	227	2	95749.30
90701	182	2	45219.09
90701	467	2	33160.47
90701	158	1	49997.85
90701	328	2	73503.08
90702	366	2	54276.31
90702	471	1	66219.63
90702	507	1	91405.56
90702	315	1	91372.02
90702	125	2	64664.71
90703	441	1	32449.62
90703	3	2	34105.50
90703	375	2	83389.55
90703	7	2	30832.97
90704	487	2	60801.62
90704	81	2	119497.89
90704	321	2	46715.92
90704	349	2	63277.14
90704	257	2	92460.98
90705	158	2	64801.36
90705	117	2	104974.20
90705	95	1	55016.37
90706	209	1	5468.65
90706	10	2	93308.00
90706	91	2	76294.80
90706	506	1	65333.28
90707	369	1	73744.51
90707	38	1	17771.59
90707	523	2	80579.44
90708	16	1	19839.05
90708	29	2	30096.41
90708	480	2	11935.61
90708	120	2	90357.91
90708	345	2	80751.46
90709	426	1	92542.29
90709	201	2	63671.32
90710	455	1	111523.02
90710	403	1	55869.10
90711	221	2	48027.98
90711	440	1	44914.50
90711	349	1	33462.04
90711	154	2	43870.60
90712	141	2	15941.48
90712	218	2	51980.58
90712	131	1	44176.54
90712	199	2	115176.00
90712	72	2	85095.30
90713	56	2	19741.20
90713	348	2	107712.63
90713	69	1	87300.65
90713	434	2	39337.38
90713	372	2	40412.90
90714	386	2	95557.34
90714	253	1	97574.81
90714	183	2	45607.83
90714	513	1	101027.61
90714	174	1	58832.21
90715	74	2	62107.36
90715	277	1	45346.85
90716	399	2	60045.67
90716	480	2	9926.03
90716	516	2	101608.55
90716	449	2	46757.66
90716	242	2	114586.22
90717	314	2	26183.90
90717	13	1	21932.99
90717	35	1	111444.62
90718	194	1	35512.71
90718	462	2	66674.05
90718	335	2	66722.89
90719	409	1	69334.39
90719	461	2	28024.61
90719	144	1	36513.50
90719	518	2	94718.79
90720	240	1	11973.95
90720	221	2	15483.13
90720	262	1	116981.44
90721	52	2	57569.21
90721	335	1	112636.19
90722	435	1	22277.07
90722	111	1	86098.78
90723	471	2	58059.76
90723	112	1	17216.52
90723	101	2	51441.84
90723	235	1	11293.10
90724	43	2	7669.05
90724	160	1	7634.10
90724	317	2	50186.20
90725	77	1	51328.41
90725	391	2	58466.01
90725	401	2	37428.74
90726	25	1	116937.10
90726	328	1	112415.67
90726	379	2	19356.78
90727	318	1	31682.45
90727	299	2	101230.49
90727	251	1	75709.26
90727	172	2	25828.44
90728	365	1	70640.14
90728	237	1	115909.43
90728	514	1	39824.77
90728	300	2	57886.09
90728	502	1	59148.48
90729	270	2	63896.64
90729	102	2	118310.40
90730	457	1	16094.75
90730	351	2	43736.39
90730	259	2	50407.20
90730	96	1	67936.78
90731	344	1	115650.52
90731	525	2	87622.98
90732	457	1	118957.00
90732	32	2	82971.01
90733	258	1	77643.27
90733	80	2	48083.27
90733	130	1	14206.89
90734	350	2	86990.51
90734	390	2	30550.13
90734	163	2	88906.39
90734	475	1	36220.94
90735	45	1	69652.12
90735	74	2	64573.31
90735	166	1	93378.99
90736	408	2	48715.10
90736	222	1	74723.76
90736	118	2	84775.59
90736	310	2	31329.41
90737	500	2	116260.40
90737	503	2	65143.59
90737	264	1	72690.82
90738	366	1	117223.81
90738	501	1	48003.84
90738	21	1	47882.29
90739	228	2	109676.76
90739	15	2	118841.98
90739	111	1	84125.51
90740	83	1	105154.43
90740	134	2	35067.28
90741	523	1	26472.90
90741	411	1	77945.14
90741	277	1	22709.50
90742	359	2	58348.96
90742	14	2	18519.34
90742	178	1	111203.97
90743	379	2	72890.82
90743	473	1	16851.37
90743	427	2	117108.16
90743	406	2	103552.48
90744	257	2	71680.14
90744	2	2	112086.85
90744	123	1	99272.10
90744	449	2	65440.95
90744	211	2	96463.83
90745	281	2	32065.35
90745	114	1	68311.90
90745	116	2	90094.50
90745	223	2	37123.28
90746	75	1	49316.85
90746	13	1	8680.34
90746	41	2	21840.10
90746	52	2	82629.90
90746	362	1	113971.50
90747	49	2	37797.09
90747	334	2	30322.08
90747	358	2	100435.99
90748	148	2	42609.40
90748	510	2	91996.69
90748	453	2	19428.54
90748	488	1	42577.16
90748	90	1	95498.37
90749	356	2	110931.66
90749	281	1	75842.56
90749	32	1	88479.64
90749	411	2	48391.17
90750	129	2	111898.94
90750	43	2	78256.18
90750	510	1	20315.99
90750	318	1	99848.77
90751	159	2	93507.71
90751	352	1	8655.18
90752	262	1	50446.46
90752	314	1	110692.12
90753	265	2	93310.34
90753	296	1	111632.29
90753	300	1	40448.18
90753	69	2	50927.64
90753	322	2	63364.71
90754	78	2	109891.70
90754	97	2	34130.69
90755	334	2	72445.58
90755	342	2	118929.54
90755	396	1	22404.31
90755	471	2	111251.22
90755	390	1	49332.37
90756	329	1	101944.06
90756	404	1	114999.82
90756	385	1	23813.82
90756	482	2	30663.03
90756	366	2	106914.60
90757	31	1	62233.18
90757	150	1	114918.79
90758	280	2	82947.70
90758	315	2	61570.07
90759	248	1	50809.79
90759	43	1	93184.80
90759	237	2	59354.93
90759	71	1	101819.13
90759	51	1	85987.94
90760	493	2	90174.83
90760	485	2	119706.91
90761	366	1	8281.14
90761	237	2	54826.86
90761	456	2	55348.19
90761	396	2	110580.32
90762	417	2	109570.24
90762	415	1	71125.51
90762	142	1	53886.56
90762	104	1	87206.69
90762	121	2	34743.23
90763	506	2	64215.37
90763	271	2	106820.62
90763	446	2	14208.69
90764	248	2	96237.26
90764	257	1	65615.78
90764	34	1	33047.06
90764	264	2	90656.43
90764	522	1	90811.63
90765	390	1	81134.07
90765	503	2	50991.98
90765	439	1	110829.49
90765	211	2	114203.02
90766	111	1	117459.01
90766	455	2	92389.86
90766	275	1	104443.60
90766	196	2	73094.93
90766	203	1	14441.37
90767	465	2	88604.53
90767	441	2	65880.15
90767	192	1	50708.19
90768	357	1	85003.16
90768	24	2	114851.05
90768	387	1	80755.13
90768	417	2	118033.45
90768	245	2	81742.41
90769	137	2	20806.00
90769	525	1	101326.39
90769	276	1	117799.02
90769	424	2	86536.08
90770	478	2	68774.28
90770	267	2	48904.23
90770	153	1	117644.28
90770	240	1	57123.24
90770	234	1	39791.57
90771	57	2	46603.24
90771	149	1	112736.39
90771	165	1	88909.04
90772	105	1	117701.76
90772	278	1	50349.02
90773	351	1	23363.31
90773	265	1	58901.74
90773	335	2	16226.30
90773	77	2	109202.82
90773	513	1	40147.78
90774	329	2	25307.91
90774	311	1	83058.61
90774	140	1	89651.00
90775	259	1	103661.49
90775	144	1	16292.73
90775	509	2	114630.20
90776	516	1	83191.91
90776	67	2	42997.96
90776	289	2	5219.70
90777	259	1	110888.14
90777	430	2	40504.36
90777	144	1	12239.21
90778	192	2	75929.72
90778	385	1	7123.47
90778	494	2	91063.34
90778	267	1	65369.85
90779	501	2	104676.01
90779	38	1	20547.12
90779	278	1	41270.40
90779	383	2	71042.66
90780	152	1	108837.19
90780	66	2	72267.67
90780	7	1	87482.55
90781	429	2	14757.16
90781	292	1	86216.52
90781	425	1	108490.72
90781	466	2	38954.99
90781	370	1	85601.39
90782	47	1	101706.18
90782	41	2	8400.62
90782	349	2	10139.86
90783	170	2	110928.50
90783	85	1	6910.22
90783	344	1	52195.59
90784	355	2	12455.34
90784	428	2	22537.45
90784	243	2	16903.04
90785	235	2	108184.59
90785	122	1	66558.35
90785	256	2	22119.36
90785	443	2	88733.05
90786	172	2	100189.59
90786	460	1	105062.34
90787	11	2	27967.16
90787	367	1	50932.61
90787	439	1	47967.26
90788	359	1	82820.63
90788	354	1	51260.53
90788	511	2	62837.08
90788	13	2	20868.12
90788	69	2	89050.22
90789	454	1	17199.89
90789	465	2	50598.98
90790	161	2	72435.19
90790	426	2	105214.66
90790	9	2	95644.79
90790	466	2	102892.23
90790	478	1	94203.25
90791	124	2	65331.61
90791	123	1	110110.54
90791	512	2	96782.73
90791	103	1	19491.96
90792	124	2	89546.57
90792	369	1	13684.17
90792	465	1	92119.36
90792	265	2	81891.20
90792	497	1	64218.82
90793	68	1	106052.52
90793	304	2	50338.44
90794	26	2	28600.20
90794	111	1	77571.46
90794	500	2	85479.84
90794	410	2	13145.32
90794	86	1	52894.15
90795	350	1	113933.05
90795	290	1	72424.29
90795	506	1	28986.87
90795	476	2	16305.31
90795	339	2	82546.08
90796	334	2	111056.36
90796	236	2	76989.30
90796	191	1	28314.73
90797	52	1	41971.64
90797	38	2	35693.73
90797	246	1	99064.47
90798	504	1	22028.54
90798	111	1	42788.72
90798	481	2	83581.03
90798	444	2	119372.83
90798	73	2	41017.85
90799	107	1	70903.71
90799	81	2	46836.76
90800	492	1	62709.58
90800	419	1	49307.30
90800	125	1	41158.64
90800	348	2	65581.84
90801	141	2	36382.27
90801	80	1	46981.77
90801	96	2	41418.40
90802	96	2	86067.62
90802	138	2	26474.74
90803	204	2	100253.38
90803	376	1	79610.83
90804	264	1	35328.08
90804	30	2	93185.03
90804	201	1	68115.33
90805	442	2	14644.97
90805	91	2	73946.13
90805	409	2	90268.68
90805	5	1	88975.69
90806	27	1	68536.39
90806	119	1	50249.64
90806	412	2	91338.89
90806	206	2	81105.58
90806	286	1	102627.44
90807	422	1	45639.30
90807	460	1	33164.48
90807	321	2	80248.25
90807	185	2	40767.66
90807	313	1	29096.69
90808	389	1	86442.08
90808	433	1	79113.27
90808	429	1	31506.00
90809	401	1	48296.44
90809	70	1	106153.25
90809	197	2	23210.20
90809	364	2	23186.20
90809	381	1	36791.35
90810	179	2	51635.40
90810	92	1	61288.39
90810	161	1	8955.03
90810	182	2	106294.50
90810	475	1	78531.93
90811	384	2	45493.16
90811	484	1	73513.47
90811	492	1	71564.41
90811	198	2	22492.88
90812	367	1	95860.08
90812	506	1	64976.47
90812	525	1	61584.90
90812	497	1	19747.16
90812	239	2	118810.95
90813	367	1	95041.95
90813	87	2	44591.58
90813	446	2	12908.47
90814	209	1	30945.83
90814	315	2	23272.90
90814	286	1	84758.54
90814	216	1	70965.79
90815	240	1	39893.29
90815	6	1	7660.66
90816	430	1	36697.29
90816	17	1	89196.58
90816	496	2	7668.22
90816	290	2	54601.25
90817	345	1	85064.56
90817	198	2	72377.48
90817	424	1	91417.30
90818	242	2	59744.09
90818	200	1	45615.24
90819	342	1	114910.18
90819	277	2	14128.84
90819	19	1	98878.91
90819	18	2	98648.08
90820	373	2	107013.65
90820	465	2	100022.89
90820	499	2	55235.24
90820	110	1	96291.98
90820	385	2	84852.73
90821	17	1	41726.87
90821	499	1	116260.18
90821	356	1	90756.31
90821	510	1	102262.60
90822	189	1	17367.51
90822	241	1	55123.23
90822	27	1	83284.83
90822	477	2	16349.18
90822	262	1	67249.16
90823	59	1	29669.12
90823	164	1	70386.12
90823	478	1	83590.44
90824	267	2	116294.53
90824	97	2	86745.56
90824	87	2	25046.34
90824	339	2	95796.66
90824	62	2	65339.00
90825	474	1	28366.31
90825	242	2	22675.12
90825	523	1	79381.41
90826	75	1	17846.00
90826	518	1	66802.54
90826	52	1	56946.44
90827	295	1	67636.79
90827	490	1	113927.88
90827	309	1	56658.24
90827	21	1	99785.77
90827	25	1	64732.63
90828	474	2	36525.21
90828	419	2	87577.34
90828	463	1	63729.54
90828	74	1	118322.58
90829	517	1	77069.40
90829	393	2	48140.24
90829	486	2	66698.52
90829	60	1	17928.22
90829	168	2	22266.07
90830	304	2	22132.95
90830	200	1	111673.52
90830	81	2	104257.10
90830	430	2	115274.40
90830	36	2	64640.79
90831	89	2	87781.39
90831	492	2	115861.80
90832	56	2	93584.32
90832	518	1	103836.69
90833	357	2	13016.15
90833	446	2	64825.80
90833	112	1	6213.32
90833	143	1	25558.51
90833	283	1	68648.19
90834	319	1	103613.11
90834	373	1	17328.45
90834	101	1	23671.98
90834	251	2	112944.45
90834	459	1	5829.16
90835	155	2	88195.89
90835	96	2	9708.17
90836	132	1	60199.97
90836	92	2	115157.55
90836	21	2	35910.99
90837	372	1	24939.99
90837	468	1	6785.93
90838	510	1	108535.10
90838	3	1	109037.60
90838	39	1	87446.71
90838	256	2	87418.51
90839	435	2	78339.02
90839	104	2	39566.44
90840	23	1	82384.99
90840	225	2	24589.21
90841	101	2	45766.14
90841	330	1	76032.14
90841	211	2	102055.63
90841	124	2	24702.79
90842	269	2	90284.11
90842	326	1	42082.69
90842	284	2	63723.74
90842	100	2	46846.12
90843	104	2	88521.36
90843	306	1	68548.57
90843	277	1	100695.81
90843	116	1	81738.10
90844	348	1	67956.64
90844	397	2	7004.97
90845	147	1	93908.55
90845	407	2	83190.45
90845	401	1	104178.87
90845	435	1	118927.94
90846	69	2	109270.52
90846	153	1	11900.51
90846	507	2	75516.02
90846	452	1	107522.91
90846	251	2	25651.96
90847	311	2	75542.31
90847	462	1	45106.61
90847	164	2	112618.84
90847	116	1	103434.45
90847	473	1	105826.34
90848	224	2	50989.81
90848	426	2	92090.40
90849	340	1	38416.39
90849	307	2	12631.03
90849	283	1	25610.98
90849	289	1	11215.49
90849	30	2	29579.11
90850	112	2	105213.05
90850	440	2	45217.47
90850	491	2	67721.66
90850	49	2	55906.73
90850	70	1	94660.49
90851	293	2	115199.63
90851	434	1	51626.16
90851	7	1	100727.04
90851	525	2	60030.46
90852	491	1	117847.13
90852	266	1	84592.60
90853	155	2	10618.74
90853	29	2	44370.50
90853	17	1	16163.47
90854	391	1	18483.45
90854	389	1	6752.20
90854	340	1	5062.09
90854	509	2	30838.18
90855	463	2	90650.23
90855	238	2	84028.86
90855	430	2	78674.76
90855	93	2	31666.18
90856	14	2	116381.41
90856	220	1	107523.10
90856	3	2	102750.30
90856	106	2	35655.80
90856	333	2	84063.66
90857	301	1	89502.51
90857	27	1	85361.70
90858	116	1	92257.56
90858	64	2	119559.32
90858	328	1	19443.45
90858	84	1	108018.14
90858	411	1	15755.31
90859	36	1	117421.35
90859	286	2	48542.69
90859	459	1	105684.00
90859	293	2	100716.60
90860	485	1	23419.83
90860	125	1	16078.94
90860	10	2	38553.80
90861	86	2	119480.56
90861	318	1	77236.47
90861	418	1	61729.37
90861	447	1	106760.50
90862	306	1	86783.88
90862	459	1	8071.92
90862	352	2	93567.12
90862	168	1	11839.45
90862	347	1	92109.66
90863	54	2	15314.55
90863	130	1	5680.10
90864	185	1	56910.66
90864	80	1	6909.76
90865	464	2	61751.38
90865	342	2	88899.27
90865	166	1	57676.54
90865	286	1	67726.36
90865	10	1	85562.55
90866	102	2	95964.53
90866	224	1	48597.53
90866	344	2	75463.24
90866	426	2	33112.10
90867	57	1	14591.67
90867	272	2	26666.48
90867	344	1	118131.90
90867	381	2	59275.02
90868	33	2	38988.03
90868	285	1	70337.03
90869	479	2	39589.49
90869	115	1	19564.42
90870	332	2	38405.20
90870	510	2	63913.03
90870	17	1	46509.62
90870	16	1	11154.69
90870	154	1	83560.72
90871	193	2	34963.89
90871	250	2	28638.04
90872	302	1	75630.28
90872	252	1	43837.44
90872	75	1	11018.10
90872	477	1	34473.83
90872	13	2	59927.15
90873	201	1	35387.73
90873	263	2	60923.09
90873	180	1	102584.40
90873	409	1	24617.47
90873	351	1	41776.69
90874	298	2	89704.13
90874	276	1	59078.71
90875	30	1	76341.13
90875	521	1	13484.59
90875	66	2	70538.66
90875	497	1	62707.74
90876	168	2	14536.07
90876	315	2	16606.18
90876	275	2	40754.93
90876	149	2	31499.30
90876	121	1	99256.83
90877	503	2	41075.57
90877	16	1	24952.32
90877	116	2	57390.73
90877	98	2	106632.93
90877	25	2	51257.12
90878	223	2	115146.65
90878	45	2	24179.11
90878	239	2	90248.97
90878	422	2	21029.36
90879	148	2	80766.25
90879	459	1	119048.78
90879	388	2	44833.47
90880	404	2	12718.05
90880	3	1	20731.65
90880	266	1	58847.16
90880	57	2	106364.48
90881	418	2	7623.61
90881	181	1	82589.89
90882	214	1	25795.13
90882	473	1	56639.50
90882	283	2	95900.79
90882	3	2	9966.50
90882	489	2	114864.81
90883	21	2	62464.93
90883	90	2	78073.62
90883	85	2	62720.48
90883	107	1	99940.95
90883	265	2	7270.37
90884	363	2	42494.27
90884	202	1	102719.13
90884	78	1	96350.55
90885	498	1	92188.30
90885	77	2	113970.70
90885	29	2	34726.24
90886	20	1	99129.26
90886	263	2	71357.69
90887	227	2	58359.59
90887	40	2	54990.25
90887	70	2	67994.17
90888	370	2	65024.89
90888	395	1	29266.65
90888	220	1	86560.26
90888	165	1	18397.56
90889	460	1	104262.06
90889	232	2	68881.67
90889	318	2	76112.51
90890	512	2	47259.23
90890	213	2	50180.91
90890	245	1	83719.38
90891	110	2	98727.79
90891	490	1	17520.54
90891	97	1	22533.46
90891	377	2	10395.38
90891	174	2	108335.53
90892	433	2	110050.47
90892	9	2	96655.26
90892	504	2	27550.28
90892	437	1	48440.86
90892	195	2	78789.60
90893	459	1	94740.29
90893	91	2	83372.38
90894	499	1	78030.00
90894	176	2	55940.23
90895	245	1	51510.53
90895	239	1	13340.37
90895	459	1	54583.46
90896	139	2	87257.93
90896	328	2	46232.16
90896	404	2	42961.56
90897	21	2	27714.42
90897	468	1	43542.81
90897	515	2	62032.68
90897	326	2	75394.07
90898	22	1	17267.80
90898	517	2	68306.82
90898	496	1	57136.10
90899	266	2	57413.70
90899	427	2	33574.44
90899	319	2	87154.82
90899	171	1	35109.63
90899	256	1	57243.66
90900	111	2	73852.99
90900	354	1	90395.66
90900	250	2	64598.51
90901	241	2	65240.42
90901	195	2	52831.66
90901	159	2	100047.69
90901	160	2	58667.23
90901	21	1	37433.57
90902	100	1	24898.43
90902	501	1	73836.41
90902	32	1	75744.86
90902	298	2	116847.79
90903	337	2	116621.52
90903	8	2	79422.75
90903	136	2	34234.84
90904	241	1	16331.47
90904	428	2	103160.16
90905	471	1	23334.24
90905	442	1	26002.64
90906	289	2	54786.03
90906	197	1	71037.97
90906	277	1	86099.04
90907	93	1	98865.46
90907	86	2	44315.22
90907	348	2	8882.08
90908	142	2	37277.80
90908	496	1	65269.20
90908	509	2	98862.55
90909	317	2	59833.41
90909	75	1	43629.85
90909	18	1	85508.52
90909	500	1	90939.04
90909	441	1	7104.18
90910	195	1	77227.07
90910	111	2	70289.05
90910	57	2	61952.67
90910	380	2	66892.73
90911	228	2	59919.19
90911	215	2	26728.87
90912	346	1	5008.35
90912	101	2	92391.74
90912	82	1	39703.74
90912	393	2	10954.98
90912	330	1	69223.94
90913	481	1	109999.60
90913	327	2	58529.03
90913	144	2	16448.10
90914	405	1	85356.73
90914	99	1	90425.38
90914	411	2	44369.60
90914	135	1	66644.51
90914	171	1	100607.82
90915	63	1	16900.69
90915	382	1	95892.36
90916	133	1	55274.40
90916	137	2	17364.72
90916	26	1	10513.59
90916	456	2	89871.38
90916	155	2	76169.78
90917	110	2	52145.59
90917	509	1	29442.60
90917	83	1	58907.59
90918	115	1	24851.76
90918	401	2	38058.15
90918	124	1	51946.70
90918	297	2	63545.24
90919	239	2	48807.12
90919	49	2	92687.10
90919	517	2	93192.88
90919	249	2	101958.50
90920	353	1	89615.73
90920	328	1	55655.36
90920	405	1	35678.09
90920	342	2	57880.63
90921	377	1	38477.69
90921	485	1	34384.87
90921	329	1	67358.06
90922	438	1	9486.26
90922	331	2	76175.71
90922	31	1	58066.78
90923	66	2	29779.40
90923	304	2	58253.19
90923	405	2	72056.98
90924	76	2	44210.57
90924	131	2	16303.08
90924	327	2	119927.62
90924	462	1	33257.17
90925	235	2	115447.81
90925	339	1	6843.91
90925	186	1	29941.59
90925	448	1	110983.76
90926	364	2	82712.21
90926	60	1	81724.38
90927	271	2	57390.68
90927	200	2	67078.15
90927	325	2	42135.80
90927	22	1	14380.15
90927	355	2	113171.41
\.


--
-- TOC entry 3675 (class 0 OID 18311)
-- Dependencies: 224
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.orders (order_id, client_id, car_id, order_date, expected_delivery_date, actual_delivery_date, total_cost_rub, status, customs_cleared) FROM stdin;
89928	90032	90269	2025-04-11	2025-05-16	\N	3833510.77	Ожидает оплаты	f
89929	90653	90626	2025-04-03	2025-05-08	2025-05-08	1967146.06	В пути	t
89930	90184	90742	2025-05-07	2025-06-22	2025-06-22	5104435.06	Ожидает оплаты	t
89931	90534	90250	2025-01-15	2025-03-03	2025-03-03	4014923.12	Доставлен	t
89932	90487	89988	2024-11-06	2024-12-21	2024-12-21	3823543.06	Доставлен	f
89933	90086	90647	2025-07-14	2025-09-08	2025-09-08	4566426.26	В обработке	t
89934	90678	90362	2025-01-05	2025-02-28	2025-02-28	2000859.76	В обработке	f
89935	90376	90388	2025-06-26	2025-08-11	\N	6085677.46	В обработке	f
89936	90822	90593	2025-01-23	2025-03-05	2025-03-05	5214259.95	В обработке	t
89937	90157	90240	2025-05-12	2025-06-12	\N	7383110.66	Ожидает оплаты	t
89938	90024	90783	2024-09-27	2024-11-18	2024-11-18	5405517.63	Таможенное оформление	t
89939	89851	90337	2025-04-08	2025-05-29	2025-05-29	1569365.40	В обработке	f
89940	90496	90263	2024-11-14	2025-01-12	2025-01-12	2796368.38	Доставлен	t
89941	90179	90561	2024-10-18	2024-11-26	2024-11-26	4856667.11	В пути	f
89942	90514	90349	2024-09-24	2024-11-12	\N	5863889.60	Таможенное оформление	t
89943	90387	90029	2025-05-08	2025-06-29	2025-06-29	3639926.61	В пути	f
89944	90593	90021	2025-04-02	2025-05-15	2025-05-15	2367924.69	В обработке	f
89945	90079	89953	2025-01-01	2025-02-09	\N	4172141.55	Ожидает оплаты	t
89946	90653	90180	2025-06-16	2025-07-29	2025-07-29	4622224.09	Доставлен	t
89947	90528	90566	2024-09-23	2024-11-01	2024-11-01	6990112.22	В пути	t
89948	90178	90740	2024-11-16	2024-12-17	2024-12-17	4257891.77	Доставлен	f
89949	90174	90726	2025-04-16	2025-06-10	2025-06-10	7464288.85	В обработке	t
89950	90118	90799	2025-09-16	2025-10-24	\N	3382355.45	Ожидает оплаты	t
89951	90289	90660	2025-02-07	2025-03-24	\N	5703318.60	Таможенное оформление	t
89952	90466	90566	2024-10-28	2024-12-15	\N	3667114.34	Ожидает оплаты	f
89953	89827	89875	2025-01-18	2025-03-03	\N	5722409.01	Доставлен	f
89954	89985	90149	2025-04-11	2025-05-20	2025-05-20	2079906.25	Ожидает оплаты	f
89955	90303	90814	2025-01-28	2025-03-27	2025-03-27	7381375.15	Таможенное оформление	t
89956	90636	90627	2025-01-01	2025-02-16	\N	4709992.13	Таможенное оформление	f
89957	89945	90201	2025-05-16	2025-06-30	\N	1560026.60	Таможенное оформление	f
89958	90698	90004	2024-12-10	2025-02-05	2025-02-05	4521373.25	Таможенное оформление	t
89959	90434	90076	2025-08-21	2025-10-20	2025-10-20	2879341.61	В пути	t
89960	90137	90108	2025-05-20	2025-06-20	\N	5648023.52	В обработке	t
89961	90153	90191	2025-02-22	2025-04-23	\N	2367582.02	В пути	t
89962	89836	90613	2025-03-14	2025-04-21	\N	2279660.76	Таможенное оформление	f
89963	90730	90097	2024-10-29	2024-12-08	\N	2936357.06	В обработке	t
89964	90735	90489	2024-11-25	2025-01-06	2025-01-06	5960844.40	Таможенное оформление	t
89965	90055	90176	2025-05-25	2025-07-03	\N	1751881.68	В обработке	f
89966	90413	90462	2025-07-09	2025-08-22	\N	2125675.02	Ожидает оплаты	t
89967	90037	90747	2025-04-22	2025-06-08	\N	7522459.59	В пути	f
89968	90200	90862	2025-03-20	2025-04-23	2025-04-23	6573066.36	Доставлен	f
89969	90376	90074	2024-11-10	2024-12-19	2024-12-19	2990357.86	В пути	t
89970	90760	89874	2024-12-13	2025-01-18	2025-01-18	3309411.24	В пути	t
89971	90180	89910	2025-05-02	2025-06-01	\N	4750493.14	В обработке	t
89972	90514	90101	2024-12-30	2025-02-03	2025-02-03	3986973.19	В обработке	f
89973	90334	90734	2024-11-25	2024-12-26	\N	4223447.13	В обработке	f
89974	90668	90465	2025-02-26	2025-04-24	2025-04-24	4598752.36	Таможенное оформление	f
89975	90592	89891	2025-03-16	2025-04-29	2025-04-29	4811510.93	Таможенное оформление	t
89976	90792	90246	2025-04-17	2025-05-23	2025-05-23	2683441.73	В пути	f
89977	90087	89957	2025-04-24	2025-06-05	2025-06-05	3484755.72	В обработке	f
89978	90513	90872	2025-08-17	2025-09-19	\N	3450752.45	Доставлен	t
89979	89984	90360	2025-01-14	2025-02-25	\N	2135549.94	Таможенное оформление	f
89980	90138	90521	2024-11-30	2024-12-30	2024-12-30	7812523.51	Ожидает оплаты	t
89981	90334	90250	2025-01-29	2025-03-11	2025-03-11	7914808.48	Доставлен	t
89982	90815	90560	2025-01-20	2025-03-09	2025-03-09	6348524.03	В пути	t
89983	90092	90780	2024-10-11	2024-11-19	2024-11-19	2692146.49	В пути	f
89984	90236	89960	2025-04-05	2025-06-04	2025-06-04	6280860.91	Таможенное оформление	t
89985	90511	90726	2025-03-11	2025-04-14	2025-04-14	5310971.33	В пути	f
89986	90710	90060	2024-10-13	2024-12-07	\N	4050765.47	В обработке	t
89987	89963	90844	2025-01-28	2025-03-24	\N	5288903.97	Доставлен	f
89988	89868	90042	2025-05-31	2025-07-13	\N	2932966.69	В обработке	f
89989	89957	90774	2025-05-16	2025-06-16	\N	6909323.12	В обработке	f
89990	90405	90507	2025-01-21	2025-03-10	\N	4813876.96	В пути	f
89991	90067	89977	2025-07-16	2025-08-16	2025-08-16	5463878.33	В пути	t
89992	90484	90582	2025-03-17	2025-05-12	2025-05-12	3574294.00	В пути	f
89993	90736	90062	2025-06-29	2025-08-21	2025-08-21	2746389.51	Ожидает оплаты	f
89994	90739	90123	2025-02-22	2025-04-13	\N	2132034.59	Ожидает оплаты	f
89995	90328	90180	2025-07-14	2025-08-17	2025-08-17	6589405.19	Доставлен	f
89996	90692	90320	2024-11-09	2024-12-15	2024-12-15	6977823.40	Таможенное оформление	t
89997	90051	89879	2025-01-26	2025-03-22	\N	4770018.21	Доставлен	t
89998	89993	90336	2025-09-11	2025-10-15	\N	7363421.82	Таможенное оформление	f
89999	90551	90798	2024-11-06	2024-12-20	\N	5460852.59	В обработке	f
90000	90180	90276	2025-06-03	2025-07-31	\N	7133596.99	Таможенное оформление	f
90001	90582	90190	2025-04-14	2025-05-25	\N	7340580.88	Таможенное оформление	f
90002	90354	90801	2025-03-19	2025-05-05	2025-05-05	5820724.39	Доставлен	f
90003	90711	90774	2025-04-15	2025-05-23	\N	4760226.75	Ожидает оплаты	t
90004	90606	90574	2025-03-02	2025-04-08	2025-04-08	6810162.08	В пути	t
90005	90081	90082	2024-11-08	2024-12-16	\N	7975298.88	Таможенное оформление	t
90006	90613	90676	2024-09-26	2024-11-18	\N	7420988.97	В обработке	f
90007	90638	90494	2024-12-14	2025-01-13	\N	3751415.75	Ожидает оплаты	f
90008	90309	90573	2025-08-04	2025-09-15	2025-09-15	7981924.69	Ожидает оплаты	t
90009	90043	90199	2024-10-03	2024-11-24	2024-11-24	4918666.13	В обработке	t
90010	90564	89950	2025-03-04	2025-04-20	\N	1782338.02	Ожидает оплаты	t
90011	90096	90306	2025-06-09	2025-07-26	\N	2347814.51	Таможенное оформление	t
90012	89990	90631	2024-10-30	2024-12-13	2024-12-13	5611413.21	Доставлен	t
90013	90345	90608	2025-01-13	2025-03-12	\N	2098512.92	Ожидает оплаты	f
90014	90314	90158	2025-02-11	2025-04-01	2025-04-01	2518184.88	В обработке	f
90015	89932	89888	2025-03-25	2025-05-07	\N	4133565.35	Ожидает оплаты	t
90016	89879	90435	2025-09-02	2025-10-23	2025-10-23	3316027.42	Таможенное оформление	t
90017	90161	90182	2025-07-02	2025-08-12	2025-08-12	3081412.61	В обработке	f
90018	90250	90367	2025-03-26	2025-05-08	2025-05-08	5667248.44	Доставлен	t
90019	90119	90554	2025-01-22	2025-03-04	\N	5225760.88	Доставлен	f
90020	90277	90611	2025-06-27	2025-08-21	\N	5077146.79	Ожидает оплаты	t
90021	90279	90204	2025-01-22	2025-02-22	\N	4207036.20	В пути	t
90022	90505	90333	2024-09-18	2024-10-18	2024-10-18	3259152.01	Таможенное оформление	f
90023	90688	90307	2024-10-20	2024-12-09	2024-12-09	3958796.95	Таможенное оформление	t
90024	89828	90523	2025-05-28	2025-07-10	\N	2581910.17	Ожидает оплаты	t
90025	90571	90056	2024-12-27	2025-02-15	\N	4866114.80	Таможенное оформление	t
90026	90094	89962	2024-11-09	2024-12-14	\N	2453043.43	В обработке	t
90027	90286	90316	2025-03-11	2025-05-10	2025-05-10	2007657.40	В пути	t
90028	90071	90666	2025-01-06	2025-02-16	2025-02-16	7883861.75	Таможенное оформление	f
90029	90365	90260	2025-02-25	2025-04-15	2025-04-15	2305781.11	Ожидает оплаты	t
90030	90307	90251	2024-11-13	2024-12-26	\N	2282306.91	В пути	t
90031	90630	89881	2025-05-01	2025-06-12	\N	3955894.99	В обработке	t
90032	90766	90434	2025-07-14	2025-08-24	\N	5076462.24	Доставлен	f
90033	90822	90312	2025-07-30	2025-09-19	\N	6903098.00	Таможенное оформление	t
90034	90493	90188	2024-10-25	2024-12-08	2024-12-08	7120672.10	Таможенное оформление	t
90035	90248	89910	2024-11-10	2024-12-29	\N	3000038.48	Таможенное оформление	t
90036	90661	90784	2025-06-07	2025-07-31	\N	6985366.33	В обработке	t
90037	90471	90408	2025-03-01	2025-04-15	\N	4645182.16	Таможенное оформление	f
90038	90546	90084	2024-11-06	2024-12-26	2024-12-26	5646089.72	В обработке	f
90039	90012	89888	2025-05-07	2025-06-06	\N	4493913.98	Доставлен	t
90040	90022	90790	2025-03-09	2025-05-06	\N	3871690.76	Доставлен	t
90041	90713	90178	2025-02-17	2025-03-31	2025-03-31	2684002.59	Таможенное оформление	t
90042	90021	90381	2025-04-06	2025-05-30	\N	7501374.91	В пути	t
90043	90284	90209	2025-06-24	2025-08-02	2025-08-02	3551570.60	Доставлен	t
90044	90323	90785	2025-04-28	2025-06-26	\N	3781409.18	Ожидает оплаты	t
90045	90190	90212	2024-10-15	2024-11-27	2024-11-27	7255762.31	Доставлен	t
90046	90178	89908	2024-11-20	2024-12-20	2024-12-20	3734087.03	В обработке	f
90047	90258	90572	2025-01-06	2025-02-08	\N	4587637.24	Ожидает оплаты	f
90048	89887	90803	2024-12-16	2025-01-19	\N	2922198.71	В пути	t
90049	90556	90862	2025-03-11	2025-04-10	2025-04-10	3085363.67	В пути	t
90050	89905	90702	2024-12-31	2025-01-31	2025-01-31	6156220.89	Доставлен	t
90051	90802	89969	2024-10-02	2024-12-01	\N	5041545.10	В обработке	t
90052	90454	90635	2025-03-01	2025-04-17	\N	4023676.66	Ожидает оплаты	f
90053	90762	90269	2025-08-15	2025-09-23	\N	4232143.40	В пути	t
90054	90660	90606	2025-03-26	2025-05-06	\N	5622018.71	Доставлен	t
90055	90776	90687	2025-01-22	2025-03-06	\N	2285253.12	В обработке	t
90056	90303	90709	2025-07-04	2025-08-09	2025-08-09	2299143.11	Доставлен	t
90057	90787	90091	2025-01-23	2025-02-22	\N	3364064.41	В пути	f
90058	90181	90507	2025-08-07	2025-09-06	2025-09-06	4476763.78	В пути	t
90059	90778	89972	2025-08-15	2025-09-18	\N	3268606.52	Доставлен	f
90060	90380	89879	2025-02-11	2025-03-20	\N	2440333.11	В пути	t
90061	90656	90560	2025-06-16	2025-08-03	2025-08-03	4127085.18	В пути	f
90062	90321	90479	2025-01-25	2025-03-10	2025-03-10	2039239.41	Доставлен	f
90063	90351	90099	2025-07-19	2025-08-20	2025-08-20	3916988.51	Доставлен	f
90064	90721	90428	2025-05-05	2025-06-04	2025-06-04	6241483.14	Доставлен	f
90065	90351	90233	2024-10-24	2024-12-12	2024-12-12	2016294.56	В обработке	f
90066	90477	90737	2025-05-17	2025-07-03	\N	4403266.11	Ожидает оплаты	t
90067	90162	89936	2024-12-27	2025-02-07	\N	4524509.98	В пути	t
90068	90211	90422	2025-02-24	2025-04-25	2025-04-25	5043744.62	Доставлен	t
90069	90034	90711	2025-01-23	2025-02-28	2025-02-28	4993554.29	В пути	f
90070	90717	90421	2025-08-01	2025-09-27	\N	4962603.51	В пути	t
90071	90024	90233	2025-07-19	2025-09-02	2025-09-02	6514282.28	Ожидает оплаты	t
90072	90225	90721	2025-05-22	2025-06-29	\N	7875852.88	Таможенное оформление	t
90073	90562	90072	2025-03-26	2025-05-16	\N	7063586.68	Таможенное оформление	t
90074	90588	90311	2025-05-08	2025-07-05	2025-07-05	4342921.47	В пути	f
90075	90425	90145	2025-01-24	2025-03-07	\N	5676068.43	Ожидает оплаты	f
90076	90645	90699	2025-07-21	2025-09-18	\N	7310251.95	Ожидает оплаты	t
90077	90121	90259	2025-09-03	2025-10-22	2025-10-22	2863008.36	В пути	f
90078	90812	90703	2024-12-22	2025-02-12	\N	2623341.42	В пути	f
90079	90634	90011	2024-10-18	2024-12-08	2024-12-08	4284219.30	Ожидает оплаты	t
90080	90644	90691	2025-09-05	2025-10-15	\N	4551697.63	Доставлен	f
90081	90774	90767	2025-04-24	2025-06-13	2025-06-13	7192535.36	Ожидает оплаты	t
90082	90069	90772	2025-04-15	2025-06-06	2025-06-06	4115437.56	В пути	t
90083	89910	90745	2025-07-12	2025-08-20	2025-08-20	5091399.79	Доставлен	t
90084	90285	90102	2024-09-25	2024-11-22	\N	4851988.57	Ожидает оплаты	t
90085	90792	90681	2025-01-06	2025-02-11	\N	6509793.12	Таможенное оформление	f
90086	90728	90479	2025-06-13	2025-07-16	2025-07-16	3031698.44	В обработке	t
90087	90272	90732	2025-02-28	2025-04-20	\N	7618184.54	В обработке	t
90088	90427	90560	2025-03-22	2025-05-08	\N	7877965.56	Доставлен	f
90089	90469	90456	2024-10-13	2024-11-28	\N	4758354.06	Таможенное оформление	t
90090	90009	90104	2025-05-19	2025-07-10	2025-07-10	5754671.32	В пути	f
90091	90427	90002	2025-03-05	2025-04-24	2025-04-24	3419455.24	Доставлен	f
90092	89918	90474	2024-10-20	2024-11-23	2024-11-23	4252735.22	Ожидает оплаты	f
90093	90678	90811	2025-07-20	2025-08-30	2025-08-30	3179530.27	В пути	t
90094	89843	90239	2024-10-14	2024-11-24	\N	3847797.86	Доставлен	t
90095	89931	89997	2025-06-24	2025-07-30	2025-07-30	5884890.94	В пути	f
90096	90132	90779	2025-08-29	2025-10-17	\N	7070776.30	Таможенное оформление	f
90097	90410	90021	2025-06-22	2025-08-02	\N	3918887.09	Таможенное оформление	t
90098	90626	90135	2024-09-30	2024-11-17	2024-11-17	2705736.26	Доставлен	f
90099	90656	90504	2025-03-24	2025-05-08	\N	2707594.30	Доставлен	t
90100	90130	90701	2025-05-23	2025-07-03	2025-07-03	4504815.42	В обработке	f
90101	90769	90190	2025-05-26	2025-07-04	2025-07-04	1906347.49	В пути	t
90102	89905	90407	2025-04-12	2025-05-24	2025-05-24	6459288.04	Таможенное оформление	f
90103	90238	90226	2025-02-14	2025-04-02	2025-04-02	7713083.63	Таможенное оформление	t
90104	89959	90145	2025-01-13	2025-02-13	\N	4285889.77	Ожидает оплаты	t
90105	89994	90787	2025-04-27	2025-06-09	2025-06-09	2513874.96	Таможенное оформление	t
90106	90717	90775	2024-09-17	2024-10-22	2024-10-22	2367650.20	В обработке	f
90107	90071	89917	2024-11-20	2024-12-21	\N	7896186.05	Таможенное оформление	t
90108	90011	90653	2025-01-06	2025-02-22	\N	2151003.88	В обработке	f
90109	90328	90679	2025-01-01	2025-02-22	2025-02-22	7905125.30	В обработке	t
90110	90072	90629	2025-07-23	2025-08-22	\N	7287370.49	Таможенное оформление	f
90111	90160	90219	2024-10-25	2024-12-10	2024-12-10	4130910.92	Таможенное оформление	f
90112	89928	90750	2025-06-06	2025-07-11	2025-07-11	3127570.35	В обработке	t
90113	90357	90343	2025-01-18	2025-02-21	\N	4863831.13	В пути	t
90114	90182	90099	2025-07-30	2025-09-17	2025-09-17	7870491.90	Таможенное оформление	t
90115	90079	90694	2025-08-16	2025-09-25	2025-09-25	5021436.03	Таможенное оформление	f
90116	90069	89875	2025-03-12	2025-05-07	2025-05-07	1515255.86	Таможенное оформление	f
90117	90000	90196	2025-04-11	2025-05-23	\N	7695031.82	Ожидает оплаты	f
90118	90344	90276	2025-05-01	2025-06-30	2025-06-30	4017383.62	Доставлен	t
90119	90579	89993	2025-04-18	2025-05-20	\N	2718200.96	Ожидает оплаты	t
90120	90129	90533	2025-06-13	2025-07-23	\N	2178362.86	Таможенное оформление	t
90121	90529	90395	2025-07-30	2025-09-09	2025-09-09	5601770.40	Доставлен	t
90122	90016	90236	2024-09-16	2024-11-03	\N	6055283.97	В пути	f
90123	89999	90141	2025-03-04	2025-04-15	2025-04-15	3431653.13	В обработке	f
90124	90030	90388	2024-09-18	2024-11-03	\N	3254167.28	Ожидает оплаты	t
90125	90762	90716	2025-07-26	2025-09-04	2025-09-04	1533193.06	Таможенное оформление	f
90126	90385	90622	2025-04-28	2025-06-23	2025-06-23	5697173.03	Ожидает оплаты	t
90127	90240	89884	2025-06-03	2025-07-25	2025-07-25	2849880.66	Ожидает оплаты	f
90128	90687	90011	2025-07-31	2025-09-26	\N	3239843.03	Таможенное оформление	f
90129	90754	90842	2024-12-05	2025-01-06	\N	7122094.50	В пути	t
90130	90232	90550	2025-02-06	2025-03-25	\N	2694393.58	Доставлен	t
90131	90010	90701	2025-05-31	2025-07-15	\N	1813335.92	В пути	f
90132	89942	90349	2025-06-01	2025-07-09	\N	3924369.28	В обработке	f
90133	90571	90822	2025-04-12	2025-06-09	\N	6265736.84	В пути	t
90134	89997	90670	2025-07-15	2025-08-20	\N	5043321.88	В пути	t
90135	90464	90557	2024-11-05	2024-12-23	\N	7835988.98	Таможенное оформление	t
90136	90153	90087	2025-04-18	2025-06-13	2025-06-13	4141298.60	В пути	f
90137	90462	90772	2025-08-22	2025-10-04	2025-10-04	4664807.98	В обработке	t
90138	89869	89913	2025-05-01	2025-06-01	\N	1505532.01	Таможенное оформление	t
90139	89846	89906	2025-01-25	2025-02-28	2025-02-28	4514492.29	Ожидает оплаты	f
90140	90093	90173	2025-04-12	2025-05-31	2025-05-31	7457658.62	В обработке	t
90141	89889	90059	2025-08-02	2025-09-01	\N	6556164.46	Доставлен	t
90142	90697	90099	2025-08-10	2025-10-07	2025-10-07	7010279.41	В пути	f
90143	90753	89899	2025-06-07	2025-08-01	2025-08-01	7900126.35	В пути	t
90144	90525	90195	2025-01-13	2025-02-28	2025-02-28	2154253.01	В пути	f
90145	90689	90341	2025-03-31	2025-05-17	2025-05-17	4679478.76	Ожидает оплаты	t
90146	89887	90539	2025-05-11	2025-06-16	\N	2448760.58	Ожидает оплаты	t
90147	90790	90322	2025-05-07	2025-06-13	\N	6647995.10	Доставлен	f
90148	89864	90674	2024-11-29	2025-01-21	\N	3634803.95	Ожидает оплаты	t
90149	90694	90670	2025-01-21	2025-03-02	\N	4474924.78	Таможенное оформление	f
90150	89942	90572	2024-09-25	2024-11-24	2024-11-24	2179147.04	Ожидает оплаты	f
90151	90001	90546	2025-04-29	2025-06-26	2025-06-26	6552559.31	В пути	t
90152	89950	90451	2025-01-09	2025-02-24	2025-02-24	6941677.04	В обработке	t
90153	90503	90750	2025-08-28	2025-10-14	\N	6575625.34	В обработке	t
90154	90302	90349	2025-07-14	2025-08-17	\N	2561802.05	Ожидает оплаты	f
90155	90466	89889	2024-11-19	2025-01-02	\N	7074193.62	В обработке	t
90156	90480	90183	2025-09-15	2025-10-28	2025-10-28	2013318.35	В пути	t
90157	90652	90769	2024-11-03	2024-12-30	2024-12-30	7916300.55	В пути	f
90158	90573	90499	2025-03-10	2025-04-25	2025-04-25	2646542.89	В обработке	f
90159	90449	90363	2025-09-04	2025-10-04	\N	7518051.86	В обработке	t
90160	90526	89954	2025-06-04	2025-07-27	\N	6782332.20	В пути	f
90161	90360	90314	2025-07-07	2025-08-15	\N	6336539.80	Таможенное оформление	t
90162	90760	90146	2025-02-09	2025-03-15	2025-03-15	5388776.66	Доставлен	t
90163	90752	90276	2025-06-25	2025-07-29	\N	5555990.89	Таможенное оформление	f
90164	90744	90325	2025-07-21	2025-09-19	2025-09-19	6538321.60	Ожидает оплаты	t
90165	90579	90392	2025-08-25	2025-10-24	2025-10-24	5495846.99	Доставлен	f
90166	90742	90303	2025-07-03	2025-08-19	2025-08-19	2285465.56	Доставлен	t
90167	90588	89938	2024-11-05	2024-12-19	2024-12-19	7664943.00	Доставлен	f
90168	90070	90094	2025-08-05	2025-09-21	2025-09-21	3890140.29	Доставлен	f
90169	90507	90598	2025-02-25	2025-04-10	2025-04-10	4440449.10	Таможенное оформление	t
90170	90306	90434	2025-04-16	2025-06-04	\N	7835415.87	Таможенное оформление	f
90171	89896	90228	2025-05-19	2025-07-03	2025-07-03	7806147.87	Ожидает оплаты	t
90172	90170	90346	2025-05-23	2025-07-09	2025-07-09	7828284.42	Ожидает оплаты	t
90173	90056	90839	2025-08-12	2025-10-10	\N	3451118.76	В обработке	t
90174	90053	90712	2025-03-29	2025-05-16	2025-05-16	5570330.72	В обработке	f
90175	90059	89977	2024-12-14	2025-01-18	2025-01-18	4163010.36	В обработке	f
90176	90035	90727	2025-08-28	2025-10-25	2025-10-25	6334791.07	В обработке	t
90177	90637	90076	2025-02-03	2025-03-31	2025-03-31	7123700.63	Доставлен	f
90178	89898	90841	2025-01-01	2025-02-03	2025-02-03	3018699.59	В пути	t
90179	90502	90072	2025-05-25	2025-06-27	\N	3343504.19	Ожидает оплаты	f
90180	90146	90466	2025-08-11	2025-09-13	\N	3209325.38	Таможенное оформление	f
90181	90803	89897	2025-09-10	2025-11-04	\N	3948831.16	Ожидает оплаты	f
90182	90567	90130	2025-01-15	2025-02-15	2025-02-15	6194063.57	Таможенное оформление	t
90183	90530	90626	2024-12-01	2025-01-09	\N	5675938.17	В обработке	t
90184	89843	90707	2024-11-23	2025-01-09	2025-01-09	5543299.98	В обработке	t
90185	90712	90179	2025-08-30	2025-10-12	\N	3464650.35	В обработке	t
90186	90136	90353	2025-05-15	2025-07-08	\N	7358576.96	В пути	f
90187	90704	90595	2025-01-28	2025-03-29	\N	7389373.53	В пути	t
90188	90448	89940	2025-01-07	2025-02-07	2025-02-07	3004595.97	В пути	t
90189	90240	90785	2025-07-07	2025-08-30	\N	2523381.59	В пути	t
90190	90250	90616	2025-08-27	2025-10-11	\N	4787823.83	В обработке	f
90191	90374	89930	2025-07-26	2025-08-31	\N	6047704.73	Доставлен	t
90192	90564	90869	2025-04-17	2025-06-09	2025-06-09	1575055.86	Таможенное оформление	f
90193	90824	90310	2025-02-20	2025-04-14	2025-04-14	2112972.40	Ожидает оплаты	f
90194	90582	90439	2025-02-15	2025-03-20	2025-03-20	6016121.72	В пути	t
90195	90229	90277	2025-07-22	2025-09-16	2025-09-16	4767426.42	Доставлен	f
90196	90569	89960	2025-01-03	2025-02-12	\N	7363426.99	В пути	t
90197	90409	90405	2024-11-05	2024-12-08	2024-12-08	4488329.38	Ожидает оплаты	t
90198	90420	89985	2025-04-16	2025-06-09	2025-06-09	7126704.55	Доставлен	f
90199	90301	90546	2025-04-25	2025-05-26	2025-05-26	5638940.88	В пути	t
90200	90689	90671	2025-05-09	2025-06-24	\N	3225061.69	Ожидает оплаты	f
90201	89834	90340	2024-11-10	2024-12-13	\N	3215379.05	В обработке	t
90202	90412	90473	2024-12-23	2025-01-24	2025-01-24	6016928.11	Ожидает оплаты	t
90203	90384	90614	2024-12-24	2025-02-02	\N	7129286.07	Доставлен	f
90204	90793	90079	2025-02-18	2025-04-07	2025-04-07	4811198.00	Ожидает оплаты	t
90205	90624	90215	2024-10-16	2024-11-24	2024-11-24	3740625.40	Доставлен	f
90206	90642	90672	2025-05-08	2025-06-22	\N	3887788.34	В обработке	f
90207	90531	90209	2024-12-09	2025-02-02	\N	2257069.95	Таможенное оформление	f
90208	90773	90517	2025-07-28	2025-09-14	2025-09-14	3767037.84	Доставлен	t
90209	89955	90316	2025-09-04	2025-11-03	\N	4986790.14	Таможенное оформление	t
90210	90490	90314	2025-08-24	2025-10-06	2025-10-06	5571431.08	Доставлен	t
90211	90463	89993	2025-02-06	2025-03-15	\N	4594862.74	Таможенное оформление	t
90212	90509	90583	2025-03-23	2025-04-27	\N	2930600.43	Доставлен	t
90213	90361	90678	2025-04-27	2025-06-04	2025-06-04	6083737.12	В пути	f
90214	90174	90461	2025-06-24	2025-08-06	\N	5985137.31	В обработке	f
90215	90321	90248	2025-05-26	2025-06-26	2025-06-26	7499622.75	Ожидает оплаты	t
90216	90122	89905	2025-03-10	2025-04-14	2025-04-14	7160792.14	Таможенное оформление	t
90217	90033	90526	2025-08-09	2025-09-26	\N	5536155.31	Таможенное оформление	f
90218	90017	90132	2025-08-13	2025-09-28	\N	6602384.21	В пути	f
90219	89989	90275	2025-08-16	2025-10-01	\N	7576543.22	Доставлен	f
90220	90172	90276	2025-01-20	2025-03-10	2025-03-10	4131269.32	В обработке	t
90221	90564	90004	2025-01-15	2025-02-14	2025-02-14	3184576.52	Доставлен	f
90222	90115	90323	2025-02-13	2025-03-25	2025-03-25	5220380.77	Доставлен	t
90223	90048	90820	2025-02-10	2025-04-11	2025-04-11	1554721.97	Ожидает оплаты	t
90224	90019	90298	2025-04-04	2025-05-20	\N	3079505.73	Доставлен	t
90225	90079	90822	2024-12-15	2025-01-26	2025-01-26	4928964.07	Доставлен	t
90226	90652	90828	2025-03-01	2025-04-01	2025-04-01	6000975.37	В пути	t
90227	90346	90061	2024-09-24	2024-10-28	2024-10-28	7963560.10	В пути	f
90228	90156	90863	2025-04-18	2025-05-20	2025-05-20	2935181.13	Доставлен	t
90229	90223	89916	2025-06-17	2025-08-07	\N	3345410.73	Доставлен	t
90230	90382	90088	2025-02-22	2025-03-30	2025-03-30	5966357.41	В пути	t
90231	90744	90049	2025-08-23	2025-10-04	\N	6584610.27	Доставлен	f
90232	90705	90846	2025-04-25	2025-06-01	\N	2274475.26	В обработке	t
90233	90813	90780	2025-06-07	2025-07-14	2025-07-14	6675989.03	В пути	f
90234	90393	90241	2025-07-29	2025-09-02	2025-09-02	2223101.10	В пути	f
90235	89875	90160	2025-05-21	2025-07-08	2025-07-08	4864363.16	В обработке	t
90236	89878	90748	2025-02-18	2025-04-13	\N	4868277.44	Таможенное оформление	f
90237	89947	90541	2025-07-26	2025-09-03	\N	5076819.01	Таможенное оформление	f
90238	90349	90805	2025-05-19	2025-07-07	2025-07-07	4999062.30	Доставлен	f
90239	90531	90790	2025-08-09	2025-09-25	\N	2576974.56	Доставлен	f
90240	90530	90542	2024-09-19	2024-11-02	2024-11-02	2151877.50	Доставлен	t
90241	90624	90524	2025-06-20	2025-08-02	2025-08-02	6795413.15	В обработке	f
90242	90654	90248	2025-03-31	2025-04-30	2025-04-30	2221094.62	Таможенное оформление	t
90243	90545	90642	2025-06-03	2025-07-06	\N	2960247.73	Таможенное оформление	t
90244	90081	90248	2024-12-24	2025-02-01	2025-02-01	2015216.17	Ожидает оплаты	f
90245	90232	90350	2025-01-03	2025-02-16	\N	1712959.95	В обработке	f
90246	89987	90801	2025-01-07	2025-02-25	\N	7904077.15	Таможенное оформление	t
90247	90823	90648	2025-01-08	2025-02-28	\N	3849842.51	В обработке	f
90248	90531	89886	2025-07-21	2025-09-07	2025-09-07	3959355.37	В пути	t
90249	90558	89995	2024-10-13	2024-11-20	2024-11-20	1594144.63	Ожидает оплаты	f
90250	89882	89890	2024-09-22	2024-11-01	2024-11-01	3687979.95	Ожидает оплаты	t
90251	89864	89887	2025-02-25	2025-04-19	2025-04-19	6569163.35	Ожидает оплаты	t
90252	90461	90869	2025-08-14	2025-09-19	\N	1557815.69	Доставлен	f
90253	90570	90733	2025-01-26	2025-03-09	\N	2086531.76	В пути	t
90254	90044	90783	2025-08-05	2025-09-24	\N	3146122.51	Таможенное оформление	f
90255	90181	90596	2025-09-13	2025-10-25	2025-10-25	1613032.82	В обработке	t
90256	90101	90841	2025-01-08	2025-03-04	2025-03-04	6142127.53	В обработке	f
90257	90041	90814	2024-10-18	2024-12-16	\N	6841577.15	В обработке	t
90258	89858	89941	2025-05-19	2025-06-23	2025-06-23	2266376.43	В обработке	t
90259	90059	90661	2025-01-05	2025-03-02	\N	6899809.61	В пути	t
90260	90137	90353	2025-05-31	2025-07-30	2025-07-30	6192765.98	Таможенное оформление	f
90261	89923	90356	2024-10-30	2024-12-09	\N	3030724.97	Таможенное оформление	t
90262	90536	90463	2024-12-09	2025-01-23	2025-01-23	7624010.59	Ожидает оплаты	f
90263	90135	90512	2025-04-19	2025-05-20	\N	1555740.11	Ожидает оплаты	t
90264	90614	90366	2025-08-04	2025-09-13	2025-09-13	4558897.46	В пути	f
90265	90549	89922	2025-07-10	2025-08-11	2025-08-11	7299582.19	В обработке	t
90266	90778	90366	2024-11-15	2025-01-11	2025-01-11	7104580.05	Таможенное оформление	f
90267	90750	90497	2024-10-04	2024-12-02	2024-12-02	5555980.35	В обработке	f
90268	89965	90535	2025-03-17	2025-05-03	\N	3481128.51	Таможенное оформление	f
90269	90512	90762	2025-01-25	2025-03-07	\N	4287127.31	В обработке	f
90270	90805	90806	2024-12-31	2025-02-11	2025-02-11	2510510.35	В пути	f
90271	89858	90271	2025-01-10	2025-03-07	2025-03-07	3245324.04	В обработке	f
90272	90331	90346	2025-02-07	2025-03-09	\N	2563537.31	Доставлен	t
90273	89836	90456	2024-11-14	2024-12-21	2024-12-21	3514610.98	В пути	f
90274	90165	90498	2025-07-18	2025-08-28	2025-08-28	2484015.47	В обработке	f
90275	90608	90278	2024-10-21	2024-12-09	2024-12-09	5635550.82	Доставлен	f
90276	89972	90095	2025-04-21	2025-06-18	\N	6032244.53	Таможенное оформление	t
90277	89855	90083	2025-04-09	2025-05-28	2025-05-28	3461342.75	В пути	f
90278	89994	90646	2025-04-03	2025-05-29	2025-05-29	2142461.92	Доставлен	f
90279	90256	90472	2025-05-21	2025-07-15	2025-07-15	4772265.18	Доставлен	t
90280	89893	90624	2024-11-07	2024-12-18	2024-12-18	7126159.81	В обработке	t
90281	90685	90450	2025-04-29	2025-06-13	\N	6149353.28	Доставлен	f
90282	90465	90173	2025-05-06	2025-06-15	\N	4061065.68	В обработке	t
90283	90259	90308	2025-07-07	2025-08-08	2025-08-08	6743049.01	В обработке	f
90284	90679	90699	2025-05-14	2025-07-04	\N	4218015.28	В пути	t
90285	90437	90532	2025-04-24	2025-05-30	\N	7370566.78	В пути	t
90286	90766	90095	2024-10-02	2024-11-17	2024-11-17	2207971.83	Доставлен	t
90287	89854	90755	2025-02-04	2025-03-30	2025-03-30	2083159.16	Ожидает оплаты	f
90288	90402	90251	2025-02-09	2025-03-26	2025-03-26	2463462.55	Таможенное оформление	f
90289	90497	90276	2024-11-29	2025-01-21	\N	1777703.00	Ожидает оплаты	f
90290	90722	90582	2025-04-17	2025-06-13	2025-06-13	3941127.22	Доставлен	t
90291	90431	90701	2025-08-22	2025-10-09	2025-10-09	2999427.27	В пути	f
90292	90024	90158	2025-08-05	2025-09-15	2025-09-15	4569739.57	Таможенное оформление	t
90293	90470	90074	2025-01-20	2025-03-13	2025-03-13	7695333.65	В пути	t
90294	89940	90479	2024-11-24	2025-01-21	2025-01-21	7046355.60	Доставлен	f
90295	90614	90145	2025-02-16	2025-03-23	\N	5897681.63	В обработке	f
90296	90587	90782	2024-10-20	2024-12-03	2024-12-03	3483536.67	В обработке	t
90297	89939	90478	2024-12-31	2025-02-26	2025-02-26	2600521.23	В пути	f
90298	90761	90731	2024-10-20	2024-11-24	2024-11-24	1815967.79	Ожидает оплаты	t
90299	90279	90149	2024-12-04	2025-01-03	\N	6511173.61	Таможенное оформление	t
90300	90716	90677	2024-11-02	2024-12-13	\N	2782086.95	Таможенное оформление	f
90301	90178	90639	2024-11-28	2025-01-09	2025-01-09	4408455.87	Ожидает оплаты	t
90302	90200	90699	2024-10-22	2024-12-12	2024-12-12	3889240.34	В обработке	t
90303	90211	90260	2025-05-22	2025-06-22	2025-06-22	5991899.26	Доставлен	f
90304	90443	90176	2025-02-19	2025-04-06	2025-04-06	3933107.77	В пути	t
90305	89905	90093	2025-06-20	2025-08-18	\N	2440055.33	В пути	t
90306	90337	90019	2024-10-17	2024-12-11	\N	7404880.51	Ожидает оплаты	f
90307	90652	90820	2025-05-24	2025-07-19	2025-07-19	2693261.91	Ожидает оплаты	f
90308	90303	90833	2025-03-01	2025-04-24	2025-04-24	1979436.79	Ожидает оплаты	f
90309	89851	90398	2025-05-11	2025-06-20	2025-06-20	7438518.58	В обработке	t
90310	90351	90416	2025-08-24	2025-10-10	2025-10-10	3176158.03	Ожидает оплаты	t
90311	90754	90137	2024-12-28	2025-02-24	2025-02-24	3502508.58	В обработке	f
90312	90812	89934	2025-07-31	2025-09-02	2025-09-02	4926945.21	Ожидает оплаты	t
90313	90429	90686	2025-04-23	2025-05-25	2025-05-25	5286741.84	Доставлен	t
90314	90021	90525	2025-01-16	2025-03-03	2025-03-03	4024863.47	В обработке	f
90315	90080	90182	2025-02-02	2025-03-20	2025-03-20	4072803.60	Доставлен	f
90316	90562	90377	2024-10-29	2024-12-20	\N	4542288.79	Таможенное оформление	f
90317	90297	90281	2025-05-20	2025-07-13	\N	7335825.38	Доставлен	t
90318	90155	89889	2025-01-14	2025-02-26	\N	5620600.25	Доставлен	t
90319	90415	90632	2025-05-16	2025-06-15	2025-06-15	7358435.47	Таможенное оформление	t
90320	89962	90167	2025-03-26	2025-04-30	2025-04-30	1617719.73	В обработке	t
90321	90651	89919	2025-09-16	2025-11-10	2025-11-10	2156014.00	В пути	t
90322	90422	89919	2025-07-18	2025-09-06	2025-09-06	3024627.64	В обработке	t
90323	90408	89952	2025-04-24	2025-06-10	\N	4105617.61	Таможенное оформление	f
90324	90406	90263	2025-03-01	2025-04-13	\N	5920134.70	В обработке	f
90325	89835	90586	2025-01-03	2025-02-23	\N	7520474.51	В пути	f
90326	90379	90737	2025-07-19	2025-08-19	\N	3831073.52	В обработке	f
90327	90107	90507	2025-01-06	2025-02-13	\N	1933715.79	В обработке	t
90328	90496	90479	2025-06-28	2025-08-07	2025-08-07	6100643.61	В пути	f
90329	90420	90813	2025-05-28	2025-06-29	\N	7065135.03	Доставлен	t
90330	89944	90512	2025-03-12	2025-04-12	2025-04-12	6828471.68	В обработке	t
90331	90364	90537	2024-11-08	2024-12-13	2024-12-13	4927919.77	Таможенное оформление	f
90332	90566	90310	2025-07-19	2025-09-09	2025-09-09	3176465.41	В обработке	f
90333	90315	90263	2025-05-16	2025-06-20	2025-06-20	5335042.89	Доставлен	t
90334	90249	90645	2025-01-31	2025-03-16	\N	2934021.08	Доставлен	f
90335	89956	90267	2025-02-05	2025-03-13	\N	3184928.53	Ожидает оплаты	t
90336	90068	90456	2025-05-20	2025-07-12	2025-07-12	5234542.86	Доставлен	t
90337	90554	90368	2025-04-06	2025-05-23	\N	6011528.24	Таможенное оформление	t
90338	89844	89937	2025-01-10	2025-03-04	2025-03-04	4492181.10	В пути	f
90339	90536	90141	2025-06-19	2025-08-16	\N	7827573.59	В пути	f
90340	90660	89908	2025-03-25	2025-04-24	2025-04-24	4628449.28	Таможенное оформление	f
90341	90688	90154	2024-12-12	2025-01-20	\N	2005850.73	Ожидает оплаты	t
90342	90596	90805	2024-09-27	2024-10-28	\N	4986929.83	Ожидает оплаты	f
90343	90338	90519	2025-09-10	2025-11-09	\N	5052845.37	Доставлен	t
90344	90287	90719	2025-04-19	2025-05-24	\N	5150100.37	Доставлен	t
90345	89913	90321	2025-04-14	2025-06-11	\N	4570985.09	Ожидает оплаты	f
90346	90240	90095	2025-07-13	2025-08-30	2025-08-30	3954859.46	В пути	t
90347	90520	90167	2025-04-27	2025-06-13	2025-06-13	2948096.55	Таможенное оформление	f
90348	90804	90077	2025-04-21	2025-05-24	\N	6027958.56	Доставлен	f
90349	89857	90156	2025-09-09	2025-10-17	2025-10-17	3123447.35	Таможенное оформление	f
90350	90024	90707	2024-10-12	2024-11-22	\N	4967170.80	В обработке	t
90351	89868	89911	2025-01-15	2025-03-06	\N	7303654.19	Доставлен	t
90352	90100	90249	2025-02-26	2025-04-09	2025-04-09	1887038.65	В пути	t
90353	90027	90626	2025-05-09	2025-06-30	\N	5648878.63	В обработке	t
90354	90361	90278	2024-11-09	2024-12-24	2024-12-24	4446660.65	В обработке	t
90355	90635	90370	2024-12-18	2025-01-19	2025-01-19	5864291.38	Доставлен	t
90356	90561	90858	2024-11-17	2025-01-07	2025-01-07	3003067.43	Таможенное оформление	t
90357	90483	90763	2025-07-29	2025-09-06	2025-09-06	5501052.63	Доставлен	f
90358	89841	90532	2025-06-17	2025-08-12	2025-08-12	6834845.26	В пути	f
90359	90295	90795	2024-11-01	2024-12-20	2024-12-20	5852123.38	В пути	f
90360	90251	90421	2025-08-25	2025-10-22	2025-10-22	5795912.19	Таможенное оформление	t
90361	89941	90115	2024-10-18	2024-11-21	\N	7759800.84	Доставлен	t
90362	90038	90656	2024-11-17	2025-01-09	2025-01-09	7318179.59	В обработке	f
90363	90366	90371	2025-01-06	2025-02-26	\N	3260806.30	Доставлен	t
90364	90038	90810	2024-09-20	2024-10-29	2024-10-29	5687701.21	В обработке	t
90365	90732	90851	2025-08-23	2025-10-01	\N	7125635.10	В обработке	f
90366	90738	89968	2025-05-02	2025-06-08	\N	6608491.71	Таможенное оформление	f
90367	90373	90541	2024-12-30	2025-02-09	\N	2706503.27	В пути	t
90368	90066	90321	2024-10-14	2024-11-20	2024-11-20	3736516.17	В пути	f
90369	90088	90262	2025-04-10	2025-05-10	\N	3743410.91	Доставлен	t
90370	90587	90595	2025-05-05	2025-06-07	\N	7415091.03	Таможенное оформление	f
90371	90748	90294	2025-04-28	2025-06-15	2025-06-15	6800179.36	В обработке	f
90372	89984	90770	2025-02-15	2025-03-23	\N	1861565.40	Таможенное оформление	f
90373	90137	90602	2025-08-05	2025-10-02	2025-10-02	3641243.26	В обработке	f
90374	89933	90843	2025-03-17	2025-04-18	2025-04-18	3851360.54	В пути	f
90375	90205	90022	2024-11-06	2024-12-31	\N	1519650.85	В обработке	t
90376	90446	90762	2024-12-28	2025-02-25	2025-02-25	6208684.14	В пути	f
90377	90171	90286	2024-10-31	2024-12-09	\N	6979290.37	В обработке	t
90378	90077	90389	2024-10-13	2024-11-15	2024-11-15	4147095.90	В обработке	f
90379	90484	90150	2025-03-06	2025-04-27	2025-04-27	7845465.87	В обработке	t
90380	90698	90041	2025-07-13	2025-08-16	\N	1812444.07	Доставлен	t
90381	90262	90634	2024-12-03	2025-01-31	\N	7548193.52	Доставлен	t
90382	90464	90651	2025-01-12	2025-03-06	2025-03-06	3426288.91	Доставлен	f
90383	90472	90225	2025-02-13	2025-03-21	2025-03-21	1575540.65	В обработке	f
90384	90669	90826	2025-03-25	2025-04-26	2025-04-26	7524090.46	В пути	t
90385	90439	90375	2025-08-21	2025-09-22	\N	3476390.85	Доставлен	f
90386	89905	90775	2025-04-11	2025-05-23	2025-05-23	2947678.05	Ожидает оплаты	f
90387	89983	89884	2025-01-21	2025-03-18	\N	6782829.14	Таможенное оформление	f
90388	89845	89877	2025-04-01	2025-05-25	2025-05-25	2884313.96	В пути	f
90389	90646	90153	2024-12-28	2025-02-23	\N	4032359.05	В пути	f
90390	89872	89966	2024-11-30	2025-01-24	\N	2194949.02	Ожидает оплаты	f
90391	90582	90160	2025-07-20	2025-09-02	\N	6207849.43	В обработке	t
90392	90809	90487	2025-09-06	2025-10-29	2025-10-29	6906861.87	Таможенное оформление	t
90393	90610	90717	2024-09-20	2024-10-24	2024-10-24	5668148.11	Таможенное оформление	t
90394	90157	90846	2024-11-16	2024-12-30	2024-12-30	6625940.00	Доставлен	f
90395	89864	90681	2024-10-14	2024-11-20	2024-11-20	2160974.63	Ожидает оплаты	f
90396	89827	90560	2025-07-30	2025-09-16	\N	4924254.22	Ожидает оплаты	t
90397	90348	89916	2025-02-24	2025-04-03	\N	5551441.09	Таможенное оформление	t
90398	90769	89984	2025-05-10	2025-06-10	2025-06-10	3612249.81	Таможенное оформление	t
90399	90244	90831	2024-12-01	2025-01-02	2025-01-02	6129859.13	В пути	t
90400	90230	90165	2025-08-05	2025-09-21	2025-09-21	6765793.10	В пути	f
90401	90754	90592	2025-04-08	2025-05-22	2025-05-22	6494109.28	Ожидает оплаты	t
90402	90789	90719	2025-02-23	2025-04-18	\N	6621788.42	Доставлен	f
90403	89866	90062	2025-01-14	2025-02-15	2025-02-15	7829381.22	Ожидает оплаты	f
90404	90618	90167	2024-12-24	2025-02-05	\N	4600540.30	В обработке	f
90405	90471	89944	2025-08-02	2025-09-13	2025-09-13	7738174.23	В пути	f
90406	90346	89925	2025-04-24	2025-06-15	\N	4870045.12	Ожидает оплаты	f
90407	90787	89942	2025-07-30	2025-09-19	2025-09-19	6165134.62	Таможенное оформление	f
90408	89889	90147	2025-09-06	2025-11-02	\N	7468760.70	Доставлен	t
90409	90495	90696	2025-09-06	2025-10-17	\N	6351916.98	Доставлен	t
90410	90326	90361	2025-06-09	2025-08-01	2025-08-01	6478981.14	В обработке	f
90411	90708	90097	2025-09-12	2025-11-11	\N	6807067.01	Таможенное оформление	f
90412	90174	90242	2025-01-18	2025-02-20	2025-02-20	3279896.99	Таможенное оформление	t
90413	90579	90766	2025-08-28	2025-10-16	2025-10-16	5883713.36	В пути	f
90414	90428	90309	2025-01-26	2025-03-05	2025-03-05	5842733.04	В пути	t
90415	90138	90693	2025-06-18	2025-07-23	2025-07-23	2550535.75	Ожидает оплаты	t
90416	90721	89875	2024-10-08	2024-11-09	2024-11-09	3400093.01	Доставлен	f
90417	90230	90604	2025-06-29	2025-08-26	2025-08-26	3797035.44	В обработке	f
90418	90476	90459	2025-01-01	2025-02-15	\N	4623179.00	Доставлен	f
90419	89851	89970	2025-08-11	2025-09-26	\N	6927817.32	В пути	t
90420	90096	89920	2025-08-26	2025-09-29	2025-09-29	1613654.81	Доставлен	t
90421	90217	90206	2025-09-08	2025-11-07	2025-11-07	3321341.37	Доставлен	f
90422	90397	90296	2025-02-12	2025-04-07	\N	3172879.56	В обработке	f
90423	90611	90673	2025-08-20	2025-09-19	\N	4865129.98	Таможенное оформление	t
90424	90464	90758	2024-11-01	2024-12-07	2024-12-07	2264703.39	В обработке	t
90425	90140	90075	2024-09-25	2024-11-21	2024-11-21	7915020.64	Доставлен	f
90426	90772	90342	2024-10-26	2024-11-28	2024-11-28	7903587.14	Ожидает оплаты	f
90427	90511	89994	2025-07-06	2025-08-06	2025-08-06	2053461.23	В пути	f
90428	90473	89889	2025-05-10	2025-06-13	\N	2091543.50	В обработке	t
90429	90208	90804	2025-02-04	2025-03-13	\N	5219091.06	Доставлен	t
90430	90038	90716	2025-01-26	2025-03-15	2025-03-15	2444096.18	Ожидает оплаты	f
90431	89854	90012	2024-12-23	2025-02-10	2025-02-10	6248341.35	Ожидает оплаты	f
90432	90080	90346	2025-08-05	2025-09-12	2025-09-12	7210087.88	В пути	t
90433	90735	90497	2025-04-15	2025-06-13	\N	5310791.22	В пути	t
90434	90138	90730	2024-12-19	2025-02-07	\N	7681778.56	Ожидает оплаты	t
90435	89864	90600	2025-02-11	2025-04-09	\N	3725290.76	Таможенное оформление	t
90436	90628	90856	2025-02-08	2025-03-15	\N	1705375.31	В пути	t
90437	90160	89940	2025-05-17	2025-07-06	\N	5737869.74	Доставлен	t
90438	90153	90705	2024-12-23	2025-02-03	\N	3655402.73	Таможенное оформление	t
90439	90462	90208	2024-12-27	2025-02-10	\N	4720771.12	Ожидает оплаты	t
90440	90242	90185	2024-12-15	2025-02-08	\N	4362345.39	В обработке	f
90441	90703	90085	2025-06-21	2025-08-03	\N	3493501.08	Доставлен	t
90442	90408	90701	2025-02-26	2025-04-08	2025-04-08	1589766.04	Доставлен	f
90443	90295	90318	2024-10-01	2024-10-31	2024-10-31	2415989.63	Ожидает оплаты	f
90444	90157	90077	2025-04-03	2025-05-12	\N	5037347.16	Таможенное оформление	t
90445	89930	89937	2024-11-07	2024-12-20	2024-12-20	1748730.40	В пути	f
90446	90449	90001	2025-03-03	2025-04-30	\N	2459031.49	В обработке	t
90447	90036	90519	2024-12-21	2025-01-31	2025-01-31	7836406.49	Доставлен	f
90448	90087	90054	2025-06-19	2025-08-10	\N	7722632.55	Ожидает оплаты	t
90449	90114	90638	2025-04-30	2025-06-23	2025-06-23	6093000.46	Ожидает оплаты	t
90450	90431	90336	2024-09-20	2024-11-17	\N	2360039.82	В пути	t
90451	90448	89931	2024-11-26	2025-01-09	\N	5363276.63	В обработке	f
90452	90357	90444	2025-04-29	2025-05-31	2025-05-31	5490739.94	В пути	t
90453	90110	90240	2025-03-29	2025-05-14	2025-05-14	5986974.08	В пути	f
90454	90581	89889	2024-12-03	2025-01-03	\N	5689939.78	В обработке	t
90455	90390	90061	2025-01-26	2025-03-20	2025-03-20	7787248.74	В обработке	t
90456	89950	90145	2025-03-03	2025-04-26	\N	1581946.17	В обработке	f
90457	90073	90676	2024-11-09	2025-01-02	\N	6455158.23	В обработке	t
90458	89832	90764	2025-06-26	2025-08-14	\N	3238610.29	Доставлен	f
90459	90550	90691	2025-06-12	2025-07-31	\N	7758304.88	Доставлен	f
90460	90524	90026	2024-11-28	2025-01-18	\N	7439994.86	Доставлен	f
90461	90587	90139	2025-04-09	2025-05-13	2025-05-13	6715282.88	В пути	f
90462	90157	90742	2025-05-10	2025-06-26	2025-06-26	4564120.07	Ожидает оплаты	t
90463	90716	90589	2025-07-09	2025-09-05	\N	7084664.67	Таможенное оформление	t
90464	90268	90448	2025-08-11	2025-09-23	\N	5361381.46	В обработке	t
90465	90136	90803	2024-11-02	2024-12-27	\N	4336677.05	В обработке	f
90466	89954	90769	2025-09-05	2025-10-16	\N	4164234.06	Таможенное оформление	t
90467	90471	90353	2025-02-26	2025-04-20	\N	7436074.72	Таможенное оформление	f
90468	90752	90061	2025-07-24	2025-09-05	2025-09-05	4915443.34	В обработке	t
90469	89848	90229	2025-08-30	2025-10-02	2025-10-02	7963139.94	Ожидает оплаты	f
90470	90130	89975	2025-06-28	2025-08-11	\N	1791830.38	Таможенное оформление	t
90471	90422	90358	2024-10-13	2024-11-26	2024-11-26	2484294.50	В пути	t
90472	90030	90295	2024-11-27	2024-12-28	2024-12-28	2385158.15	Доставлен	t
90473	89998	90435	2025-05-20	2025-07-02	\N	3024687.34	Таможенное оформление	f
90474	90744	90069	2025-04-02	2025-05-16	2025-05-16	6341893.78	Доставлен	f
90475	90656	90474	2024-10-09	2024-11-10	2024-11-10	3577035.35	В обработке	f
90476	90610	90009	2024-11-07	2024-12-10	\N	3348815.51	В обработке	t
90477	90058	90133	2024-12-25	2025-02-13	\N	6907813.46	В пути	t
90478	90355	90302	2025-05-25	2025-07-24	\N	5367567.49	В пути	f
90479	89908	90575	2025-08-04	2025-09-06	2025-09-06	4809742.68	В пути	t
90480	90611	90646	2024-12-25	2025-01-25	2025-01-25	4186511.78	Таможенное оформление	t
90481	90812	89956	2025-02-06	2025-03-15	2025-03-15	6388458.63	Таможенное оформление	f
90482	90333	89922	2025-03-15	2025-05-01	\N	6237867.63	Доставлен	f
90483	90476	90479	2024-11-02	2024-12-27	2024-12-27	6755587.60	Доставлен	t
90484	89864	90191	2025-05-02	2025-06-10	2025-06-10	6452301.71	Доставлен	f
90485	90096	90580	2025-05-12	2025-06-29	\N	3212658.02	В пути	f
90486	90666	90771	2024-11-03	2024-12-13	2024-12-13	4634868.68	В обработке	f
90487	90230	90762	2024-09-28	2024-11-26	2024-11-26	6481299.18	Доставлен	f
90488	90093	89929	2025-05-02	2025-06-28	\N	7122942.32	В пути	t
90489	90386	90168	2024-12-25	2025-02-18	\N	3297235.99	В пути	t
90490	90434	90330	2025-08-29	2025-10-11	2025-10-11	7809621.97	В обработке	f
90491	90510	90008	2025-04-09	2025-05-28	\N	4786017.51	В обработке	f
90492	90566	90147	2025-06-02	2025-07-22	2025-07-22	2358326.61	Таможенное оформление	t
90493	90139	90018	2025-01-28	2025-03-18	\N	5336460.95	Таможенное оформление	f
90494	90133	90741	2025-04-16	2025-06-04	2025-06-04	6704571.72	Доставлен	t
90495	90045	90184	2024-09-20	2024-11-10	\N	2853219.18	В обработке	f
90496	90711	90006	2024-10-16	2024-12-14	\N	4462512.34	Доставлен	f
90497	90691	90246	2025-02-24	2025-04-24	2025-04-24	2042412.23	Ожидает оплаты	t
90498	89995	90234	2025-04-06	2025-06-05	\N	3848669.88	Таможенное оформление	t
90499	90450	90114	2025-02-16	2025-04-01	2025-04-01	5485028.26	Ожидает оплаты	f
90500	90698	90836	2025-06-27	2025-08-06	2025-08-06	6193592.56	В обработке	t
90501	90620	90607	2024-12-06	2025-01-10	2025-01-10	4275379.05	Таможенное оформление	t
90502	90546	90739	2025-04-26	2025-06-16	2025-06-16	6386462.25	Ожидает оплаты	t
90503	89901	90221	2025-01-05	2025-02-17	2025-02-17	2610822.88	Ожидает оплаты	t
90504	90631	90135	2025-09-02	2025-10-04	2025-10-04	4476362.52	Таможенное оформление	t
90505	90614	90870	2025-06-27	2025-08-03	\N	6453492.24	Доставлен	f
90506	90490	90219	2024-12-17	2025-02-06	\N	2367645.09	В пути	f
90507	89932	90843	2024-12-18	2025-02-11	2025-02-11	2065222.07	Доставлен	f
90508	90626	90549	2024-11-20	2024-12-23	\N	4521720.97	В обработке	t
90509	90304	90533	2025-01-29	2025-03-12	2025-03-12	5739779.57	В обработке	t
90510	89930	90058	2025-06-17	2025-08-10	\N	6395336.01	В обработке	t
90511	90096	90015	2025-07-08	2025-08-11	2025-08-11	7300990.59	Ожидает оплаты	t
90512	90117	90426	2024-12-03	2025-01-19	2025-01-19	5557869.48	Доставлен	f
90513	90596	90683	2024-11-30	2025-01-04	\N	4128761.05	Ожидает оплаты	t
90514	90641	90748	2025-08-28	2025-10-09	2025-10-09	2775376.87	Таможенное оформление	t
90515	89907	90608	2024-12-17	2025-02-13	2025-02-13	5901684.81	Ожидает оплаты	t
90516	90230	89998	2024-11-08	2024-12-23	2024-12-23	3706692.67	Ожидает оплаты	t
90517	90160	90609	2025-09-10	2025-10-13	2025-10-13	4036143.99	Доставлен	t
90518	90332	90074	2025-07-14	2025-08-22	\N	2470987.29	В обработке	f
90519	90746	90319	2025-06-23	2025-08-02	2025-08-02	3111117.01	Таможенное оформление	f
90520	90310	89901	2025-05-17	2025-06-29	2025-06-29	5878892.27	Доставлен	t
90521	90116	90054	2025-06-12	2025-07-15	2025-07-15	5821355.91	Ожидает оплаты	f
90522	90090	89884	2024-10-21	2024-11-27	2024-11-27	6497222.47	В пути	f
90523	90558	90872	2025-04-22	2025-06-09	2025-06-09	6832165.03	Таможенное оформление	f
90524	90171	90044	2025-04-16	2025-05-26	\N	5232397.97	Доставлен	f
90525	90545	90599	2024-11-27	2024-12-30	\N	4658273.71	В пути	f
90526	89936	90247	2024-12-09	2025-02-06	2025-02-06	3844100.52	Доставлен	f
90527	90582	90477	2025-09-08	2025-10-18	2025-10-18	4092175.58	Таможенное оформление	f
90528	89925	90569	2025-05-01	2025-06-26	2025-06-26	1736166.26	В обработке	t
90529	90576	90541	2024-09-24	2024-11-12	2024-11-12	7596578.19	В обработке	f
90530	90530	90452	2025-04-24	2025-06-11	2025-06-11	7311735.68	Ожидает оплаты	t
90531	90157	90424	2025-01-06	2025-02-27	\N	3994884.39	В пути	t
90532	89913	89997	2025-05-09	2025-06-19	2025-06-19	2284690.73	В пути	t
90533	90232	89887	2025-05-01	2025-06-05	\N	4896191.84	В пути	t
90534	90544	90551	2024-12-02	2025-01-29	\N	1590841.93	В обработке	f
90535	90428	90529	2024-11-15	2025-01-04	\N	6549972.25	В пути	t
90536	90081	90748	2025-02-22	2025-03-30	\N	7891404.35	Таможенное оформление	f
90537	90722	90132	2025-09-10	2025-11-01	2025-11-01	7732812.84	Ожидает оплаты	f
90538	90477	90379	2025-05-06	2025-06-12	\N	4124999.75	Доставлен	f
90539	89948	90408	2025-04-02	2025-05-24	2025-05-24	7607552.07	Таможенное оформление	f
90540	90033	90761	2025-04-04	2025-05-08	\N	6128908.90	Ожидает оплаты	t
90541	90418	90782	2024-09-16	2024-11-02	\N	5807349.53	В обработке	f
90542	90583	90688	2025-07-10	2025-08-09	2025-08-09	1846683.19	В пути	f
90543	89847	90188	2025-09-06	2025-10-21	\N	4001634.51	В обработке	f
90544	90313	90542	2024-12-15	2025-01-17	\N	2741833.93	Таможенное оформление	t
90545	89944	90482	2025-07-20	2025-08-30	2025-08-30	3359216.18	Доставлен	f
90546	90072	90690	2024-09-19	2024-10-29	\N	6857896.35	Таможенное оформление	f
90547	90402	90178	2025-04-17	2025-06-04	2025-06-04	2142834.64	Ожидает оплаты	f
90548	90604	90126	2025-01-11	2025-02-15	2025-02-15	6389279.64	В пути	f
90549	90558	90821	2025-01-17	2025-03-05	\N	3902485.35	Доставлен	f
90550	90051	90071	2024-10-10	2024-11-25	\N	4226493.33	Таможенное оформление	f
90551	90339	90268	2024-11-16	2025-01-09	2025-01-09	4370048.46	В пути	t
90552	89979	90542	2025-01-07	2025-02-13	2025-02-13	7082201.17	Таможенное оформление	f
90553	89869	90828	2024-11-09	2024-12-15	\N	7243590.62	Ожидает оплаты	t
90554	90118	90422	2025-01-28	2025-03-05	2025-03-05	7285482.83	В пути	f
90555	90044	89910	2025-09-15	2025-10-18	\N	6016724.82	Ожидает оплаты	t
90556	90080	90218	2024-11-30	2025-01-26	\N	4613935.79	Ожидает оплаты	t
90557	90818	90347	2025-07-13	2025-09-02	\N	4467179.38	Таможенное оформление	t
90558	90382	90553	2024-09-21	2024-11-03	\N	1878446.06	В обработке	f
90559	90039	90763	2025-05-18	2025-07-09	2025-07-09	4943883.09	Доставлен	f
90560	90260	90733	2025-04-15	2025-05-28	2025-05-28	2323466.87	Ожидает оплаты	t
90561	90683	90565	2025-02-01	2025-03-11	2025-03-11	2046011.68	В обработке	f
90562	89943	90007	2025-01-19	2025-03-18	\N	5289693.30	Ожидает оплаты	t
90563	90169	90274	2025-07-07	2025-08-15	2025-08-15	3797075.70	Ожидает оплаты	f
90564	90748	90790	2025-06-22	2025-08-02	2025-08-02	3281246.82	В обработке	t
90565	90770	90230	2025-08-10	2025-10-06	\N	4766130.98	В обработке	t
90566	90381	90210	2025-02-14	2025-04-12	2025-04-12	5290033.39	В обработке	f
90567	89908	90256	2025-05-13	2025-07-03	\N	4390402.64	Таможенное оформление	f
90568	90787	90499	2025-06-23	2025-08-15	\N	6146755.99	Таможенное оформление	f
90569	89967	89921	2025-04-05	2025-05-16	2025-05-16	7654882.46	Ожидает оплаты	t
90570	90747	90865	2025-04-24	2025-06-12	2025-06-12	7105812.26	Таможенное оформление	f
90571	90188	90074	2025-05-03	2025-06-26	2025-06-26	4865411.98	Доставлен	f
90572	90661	90780	2025-05-14	2025-07-04	2025-07-04	4850433.58	В обработке	f
90573	90559	89939	2024-10-28	2024-12-15	2024-12-15	5434587.06	Таможенное оформление	t
90574	90675	89916	2024-11-15	2025-01-10	\N	5499337.50	В пути	t
90575	89958	90453	2025-03-04	2025-04-11	\N	2603446.69	В обработке	t
90576	90252	90260	2025-05-10	2025-06-13	\N	3096556.93	Таможенное оформление	f
90577	89849	90455	2025-02-26	2025-04-02	2025-04-02	2416831.19	В пути	t
90578	90602	90758	2025-05-30	2025-06-30	\N	1668676.24	Доставлен	t
90579	90113	90019	2024-12-19	2025-02-03	\N	7164577.32	В обработке	t
90580	90335	90027	2024-11-05	2024-12-11	2024-12-11	2566768.08	В обработке	t
90581	90125	89950	2024-11-09	2024-12-21	\N	7497824.49	Доставлен	f
90582	90811	89974	2025-05-24	2025-07-19	\N	4749873.99	В пути	t
90583	90157	90067	2025-05-04	2025-07-02	\N	6822933.10	В обработке	t
90584	90225	90621	2025-03-21	2025-04-28	2025-04-28	3563744.02	В обработке	t
90585	90435	90285	2025-03-28	2025-05-12	2025-05-12	1663643.24	Доставлен	t
90586	90416	90314	2025-06-15	2025-08-12	\N	5731218.81	В обработке	t
90587	90023	90303	2024-10-21	2024-12-06	2024-12-06	2346176.67	В обработке	t
90588	90708	90368	2024-12-14	2025-01-18	2025-01-18	3349543.46	В пути	t
90589	90045	89993	2024-11-10	2025-01-08	\N	1674848.68	В обработке	f
90590	90007	90059	2024-10-12	2024-12-03	2024-12-03	2445056.26	В обработке	f
90591	90101	89941	2025-03-31	2025-05-06	2025-05-06	3420714.62	В пути	f
90592	90090	89997	2025-05-04	2025-06-07	\N	6009484.35	Таможенное оформление	f
90593	89934	90322	2025-06-02	2025-07-17	\N	6578588.53	В пути	f
90594	90666	89947	2025-07-28	2025-09-01	\N	6495576.49	В обработке	t
90595	90123	90435	2025-03-01	2025-04-04	2025-04-04	2662261.68	Доставлен	t
90596	90767	90217	2025-03-28	2025-05-12	\N	4656948.84	В обработке	t
90597	90633	90772	2025-05-10	2025-06-30	2025-06-30	6246593.78	Ожидает оплаты	f
90598	90126	90566	2024-12-31	2025-02-09	2025-02-09	6247974.84	Доставлен	t
90599	90203	90425	2025-06-07	2025-07-31	2025-07-31	3902422.75	Ожидает оплаты	f
90600	90654	89945	2025-01-11	2025-02-14	2025-02-14	3950233.73	В обработке	f
90601	90345	90044	2024-12-31	2025-02-10	\N	3220017.39	Доставлен	t
90602	90500	90848	2025-01-17	2025-02-28	\N	3606815.91	Ожидает оплаты	t
90603	90453	90415	2024-10-04	2024-11-10	2024-11-10	6361847.01	Таможенное оформление	t
90604	90661	90032	2025-05-24	2025-07-16	2025-07-16	2615890.91	Доставлен	f
90605	90017	90533	2025-02-08	2025-04-05	\N	5645155.92	В обработке	f
90606	90119	90592	2025-09-15	2025-11-11	2025-11-11	6151208.05	Ожидает оплаты	t
90607	90357	89987	2024-11-28	2024-12-29	2024-12-29	6681726.21	В обработке	f
90608	90141	90102	2025-04-05	2025-05-09	2025-05-09	5949799.38	Ожидает оплаты	f
90609	90298	90230	2025-07-22	2025-08-24	2025-08-24	6227194.49	В обработке	f
90610	90707	90535	2025-05-26	2025-07-22	\N	3431064.24	Доставлен	f
90611	90322	90827	2025-06-16	2025-07-31	2025-07-31	3329391.76	В пути	f
90612	90290	90169	2024-10-22	2024-12-02	\N	4497166.05	Таможенное оформление	f
90613	90744	90126	2025-07-05	2025-08-13	2025-08-13	4287550.75	Ожидает оплаты	t
90614	90220	90612	2025-02-07	2025-03-19	\N	3561323.87	В обработке	t
90615	90713	90871	2025-05-03	2025-06-08	\N	4551541.70	В обработке	f
90616	90305	90767	2025-05-07	2025-06-24	\N	4408245.80	В обработке	t
90617	90654	90170	2025-08-06	2025-09-14	\N	5345879.58	В обработке	t
90618	90661	90821	2025-01-17	2025-03-05	2025-03-05	1934854.31	В обработке	f
90619	90076	89971	2025-06-15	2025-07-27	\N	2409929.73	Доставлен	f
90620	90507	89908	2024-10-31	2024-12-29	2024-12-29	5810365.36	В обработке	t
90621	90669	90135	2025-03-22	2025-04-25	\N	1582937.64	Ожидает оплаты	t
90622	89855	90381	2025-01-25	2025-03-20	\N	3546814.84	В пути	t
90623	90611	90616	2025-09-07	2025-10-20	2025-10-20	1855492.99	В пути	t
90624	90138	90850	2025-03-20	2025-05-04	\N	5393707.12	В пути	t
90625	89933	90274	2025-01-19	2025-03-14	2025-03-14	6918781.96	Ожидает оплаты	f
90626	90359	90031	2025-05-26	2025-07-08	\N	4109739.38	Таможенное оформление	f
90627	90074	89988	2024-11-20	2024-12-20	2024-12-20	5607935.55	Таможенное оформление	f
90628	90369	90259	2024-11-22	2025-01-15	2025-01-15	7318310.65	Ожидает оплаты	f
90629	90302	90694	2024-09-18	2024-10-18	\N	5520600.64	Ожидает оплаты	f
90630	90433	90803	2025-01-27	2025-03-07	\N	7644852.17	Доставлен	f
90631	90693	89991	2025-06-11	2025-07-27	2025-07-27	4264969.36	Таможенное оформление	f
90632	90150	90065	2025-05-15	2025-06-27	\N	7257283.99	В обработке	f
90633	89893	90180	2025-02-15	2025-04-02	\N	4936109.46	Доставлен	t
90634	90098	90679	2024-12-20	2025-02-13	2025-02-13	7801182.38	В обработке	t
90635	90776	89971	2024-10-04	2024-11-06	\N	2540004.55	Доставлен	f
90636	90216	90581	2025-03-21	2025-04-29	2025-04-29	4239984.15	Таможенное оформление	t
90637	90397	90580	2024-10-17	2024-12-15	\N	2665607.66	В пути	f
90638	90810	90110	2025-05-24	2025-07-21	2025-07-21	5370225.35	Таможенное оформление	f
90639	90543	90675	2025-08-10	2025-09-22	\N	2137776.46	Таможенное оформление	t
90640	90522	90735	2025-05-29	2025-07-25	\N	3991847.98	Таможенное оформление	f
90641	89949	90103	2025-09-15	2025-11-13	\N	6139708.12	В пути	t
90642	89880	90581	2024-11-29	2025-01-20	\N	6724326.35	В обработке	t
90643	90764	90272	2025-05-28	2025-07-22	\N	5931690.64	В обработке	f
90644	90401	90552	2024-12-08	2025-01-16	\N	7314095.44	В обработке	f
90645	90675	90292	2025-01-13	2025-03-13	2025-03-13	5343774.47	Доставлен	f
90646	90259	90558	2024-11-26	2025-01-14	2025-01-14	6587697.59	Таможенное оформление	f
90647	90630	90314	2025-01-29	2025-03-26	\N	1731740.47	Доставлен	f
90648	90787	90313	2024-10-21	2024-11-24	2024-11-24	4872523.30	Таможенное оформление	f
90649	90301	90867	2025-03-18	2025-04-25	\N	5879082.99	В пути	f
90650	90009	90036	2024-11-24	2024-12-30	\N	4489384.29	Доставлен	f
90651	90428	90561	2025-06-16	2025-07-20	\N	5439441.26	Доставлен	t
90652	90034	90777	2024-11-10	2025-01-09	2025-01-09	3205709.49	В пути	t
90653	89944	90710	2024-12-11	2025-01-15	\N	1612483.37	В пути	f
90654	90174	90551	2024-10-23	2024-12-17	\N	2403406.41	Ожидает оплаты	f
90655	90257	90092	2025-08-03	2025-09-22	2025-09-22	3819716.25	В обработке	t
90656	90057	90537	2025-02-21	2025-04-09	\N	1735975.32	Доставлен	f
90657	90289	90290	2025-05-22	2025-06-29	\N	7167640.68	В пути	t
90658	90245	90038	2025-04-07	2025-06-06	\N	2743889.92	Таможенное оформление	f
90659	90624	89969	2025-01-15	2025-02-26	2025-02-26	2654764.17	Ожидает оплаты	f
90660	90758	89888	2025-05-27	2025-07-18	2025-07-18	2360276.43	В пути	t
90661	90288	89944	2024-11-21	2024-12-22	2024-12-22	2343253.71	В обработке	t
90662	90088	90339	2025-01-21	2025-03-06	\N	3286953.83	Ожидает оплаты	t
90663	90689	90024	2024-12-30	2025-02-17	2025-02-17	1530904.61	Ожидает оплаты	t
90664	90512	90136	2024-10-19	2024-11-24	\N	7199375.16	Таможенное оформление	t
90665	90539	90631	2025-08-21	2025-09-30	2025-09-30	6161862.59	В пути	f
90666	90612	90860	2025-03-16	2025-04-16	\N	6558787.67	Ожидает оплаты	t
90667	90460	90038	2025-02-24	2025-03-30	2025-03-30	3261213.14	В обработке	f
90668	90816	90484	2024-09-24	2024-11-08	2024-11-08	6509512.37	Ожидает оплаты	t
90669	90130	90650	2024-11-12	2024-12-16	\N	6482616.97	Доставлен	f
90670	90588	90432	2025-08-30	2025-10-03	\N	6809635.13	В пути	f
90671	90583	90339	2025-08-31	2025-10-20	\N	5664936.08	В пути	t
90672	90618	90109	2024-10-19	2024-11-30	2024-11-30	6310104.52	Таможенное оформление	t
90673	90623	89876	2025-09-04	2025-10-17	2025-10-17	6814112.57	Ожидает оплаты	f
90674	90489	90585	2025-02-06	2025-04-01	2025-04-01	6124489.39	В пути	f
90675	90247	90700	2025-02-09	2025-04-02	2025-04-02	7831549.04	Таможенное оформление	t
90676	90446	89994	2025-04-12	2025-06-11	\N	3514960.20	Доставлен	t
90677	90218	90873	2025-06-02	2025-07-31	\N	6989276.75	В пути	t
90678	89947	90441	2025-04-08	2025-05-23	\N	5171140.69	В обработке	t
90679	90641	90294	2025-05-31	2025-07-19	\N	6492752.74	Таможенное оформление	t
90680	90737	90377	2024-12-24	2025-01-30	2025-01-30	7135985.30	Доставлен	f
90681	90772	90567	2025-06-30	2025-08-05	2025-08-05	7347128.60	Ожидает оплаты	f
90682	90438	90574	2025-06-08	2025-07-29	2025-07-29	2260567.24	Ожидает оплаты	t
90683	90495	90789	2024-11-01	2024-12-11	\N	7347463.70	В пути	f
90684	90310	90269	2024-09-24	2024-10-26	2024-10-26	4347557.85	В обработке	t
90685	90366	90121	2025-02-28	2025-04-01	\N	4041611.82	В обработке	f
90686	89985	90367	2024-12-31	2025-02-21	2025-02-21	3714708.94	В обработке	f
90687	90577	90742	2025-07-09	2025-08-10	\N	2753433.02	Ожидает оплаты	f
90688	90379	90090	2025-08-08	2025-09-20	2025-09-20	4301124.03	Таможенное оформление	t
90689	89996	90321	2025-05-14	2025-07-01	\N	7263741.47	Таможенное оформление	t
90690	90129	90595	2025-06-05	2025-07-26	\N	2530401.81	Ожидает оплаты	f
90691	90824	90456	2025-04-30	2025-06-05	\N	5476941.71	Ожидает оплаты	t
90692	90806	90198	2025-02-21	2025-03-29	\N	2579749.00	Доставлен	f
90693	90761	90424	2025-02-03	2025-03-10	\N	5334126.38	В обработке	t
90694	90327	90545	2025-08-29	2025-10-20	2025-10-20	4189136.13	Ожидает оплаты	f
90695	89961	90696	2024-09-29	2024-11-14	2024-11-14	7458273.44	Доставлен	t
90696	90534	89898	2025-04-10	2025-05-22	\N	3953950.69	Доставлен	f
90697	90196	90837	2025-06-08	2025-07-09	\N	2736164.95	Таможенное оформление	t
90698	90176	90149	2024-10-27	2024-12-07	\N	5233855.73	Таможенное оформление	f
90699	90442	90762	2025-03-07	2025-05-06	\N	6405361.09	В пути	t
90700	90458	90873	2025-04-11	2025-05-15	\N	7669295.41	Таможенное оформление	t
90701	90557	90361	2025-08-08	2025-09-26	2025-09-26	6351077.62	В пути	t
90702	90593	89907	2025-08-24	2025-09-28	2025-09-28	7972870.41	В обработке	t
90703	90050	90834	2024-12-11	2025-01-21	\N	1706707.30	Таможенное оформление	f
90704	90585	90121	2025-01-16	2025-03-02	\N	6676199.13	Таможенное оформление	t
90705	90728	89905	2025-03-24	2025-05-18	\N	4517471.02	В обработке	t
90706	90757	90218	2024-10-08	2024-11-11	2024-11-11	5770333.11	Ожидает оплаты	f
90707	90583	90474	2024-10-21	2024-11-24	\N	1858195.95	Ожидает оплаты	t
90708	90024	90677	2025-05-20	2025-07-19	2025-07-19	4548055.39	Доставлен	t
90709	90486	90659	2025-06-02	2025-07-18	2025-07-18	5553653.55	В пути	t
90710	90159	90238	2025-01-02	2025-02-17	2025-02-17	7628530.95	Таможенное оформление	t
90711	89912	90086	2025-06-27	2025-07-28	\N	4177216.52	В обработке	t
90712	90607	89890	2024-12-19	2025-02-05	2025-02-05	2191894.03	Ожидает оплаты	f
90713	90709	90107	2025-07-10	2025-08-14	\N	4489763.06	Доставлен	t
90714	90354	89986	2025-03-15	2025-05-08	2025-05-08	7165863.02	В пути	t
90715	90806	90546	2025-05-16	2025-06-18	\N	4704144.34	В обработке	t
90716	89861	90005	2025-07-20	2025-08-27	\N	5481194.06	Доставлен	f
90717	90644	90142	2025-03-24	2025-05-16	\N	4927938.19	В обработке	f
90718	90361	90737	2025-06-20	2025-08-17	2025-08-17	3719878.75	Таможенное оформление	t
90719	89988	90855	2025-05-30	2025-07-21	\N	4469625.19	В пути	t
90720	89912	90181	2025-08-15	2025-09-15	2025-09-15	3075211.00	Таможенное оформление	t
90721	90418	90296	2024-12-10	2025-01-24	2025-01-24	2483452.61	В пути	t
90722	90745	90438	2024-11-05	2024-12-29	\N	4867927.97	Ожидает оплаты	f
90723	90359	90742	2025-06-27	2025-08-05	2025-08-05	5182635.87	Таможенное оформление	t
90724	90807	90326	2025-08-26	2025-09-25	2025-09-25	3564756.35	Ожидает оплаты	f
90725	90523	90161	2025-03-06	2025-04-09	2025-04-09	3308099.48	В пути	f
90726	89837	90059	2025-02-28	2025-04-09	\N	6268612.36	В обработке	f
90727	90084	90034	2024-11-05	2025-01-04	2025-01-04	2579280.21	Таможенное оформление	t
90728	90687	90051	2025-04-14	2025-06-10	2025-06-10	7729338.46	Доставлен	t
90729	90626	90169	2025-05-13	2025-07-12	\N	2739261.09	В пути	t
90730	89928	90583	2025-02-20	2025-04-07	\N	2571513.95	Доставлен	t
90731	89847	89918	2024-11-22	2025-01-18	2025-01-18	2806539.99	В пути	t
90732	90338	90384	2025-06-07	2025-07-16	\N	2098093.90	В обработке	t
90733	90211	90336	2025-02-02	2025-03-09	\N	1647532.07	Доставлен	f
90734	90334	90176	2025-04-30	2025-06-21	2025-06-21	3202030.44	Таможенное оформление	t
90735	90195	90256	2024-11-07	2024-12-29	\N	6280178.31	Ожидает оплаты	t
90736	89924	90123	2025-02-23	2025-04-04	2025-04-04	2633697.85	В пути	f
90737	90428	90656	2025-09-14	2025-11-12	\N	6443698.33	Доставлен	f
90738	89974	89883	2025-08-20	2025-10-12	2025-10-12	7179839.41	Доставлен	t
90739	89846	90449	2025-03-11	2025-04-20	\N	6206675.65	Ожидает оплаты	f
90740	90124	89997	2025-04-02	2025-05-05	2025-05-05	7231640.64	В обработке	t
90741	90488	90521	2025-01-06	2025-02-13	2025-02-13	6608193.93	Доставлен	f
90742	89919	89884	2025-07-31	2025-09-19	\N	3259439.56	Таможенное оформление	t
90743	90117	90700	2025-03-30	2025-05-22	2025-05-22	4917920.24	Таможенное оформление	f
90744	90486	90129	2024-12-02	2025-01-17	2025-01-17	3740114.84	Ожидает оплаты	t
90745	90143	90752	2025-03-09	2025-05-06	\N	7154844.09	Ожидает оплаты	t
90746	90465	90544	2025-06-15	2025-07-25	2025-07-25	6899698.77	Доставлен	t
90747	90559	90688	2024-11-27	2025-01-16	\N	3775235.95	Ожидает оплаты	t
90748	90252	90444	2024-10-15	2024-11-26	2024-11-26	3409721.57	Доставлен	f
90749	89851	89908	2024-12-26	2025-01-28	2025-01-28	3175340.11	Ожидает оплаты	f
90750	90555	90149	2025-08-20	2025-10-05	2025-10-05	2296381.51	Таможенное оформление	t
90751	90725	90478	2024-12-22	2025-02-04	\N	5207037.70	Таможенное оформление	f
90752	90299	90383	2025-01-28	2025-03-22	2025-03-22	7163075.29	В обработке	f
90753	90682	90315	2025-01-28	2025-03-24	\N	2999284.57	Таможенное оформление	t
90754	90748	90408	2024-11-27	2024-12-27	\N	5518469.58	В пути	f
90755	89883	89931	2024-10-09	2024-12-08	\N	6917109.34	В пути	t
90756	90100	90656	2024-11-04	2024-12-11	\N	7427931.01	Доставлен	f
90757	90805	90686	2024-12-22	2025-02-08	\N	6941898.33	Ожидает оплаты	t
90758	90650	89876	2025-05-08	2025-07-05	\N	6323875.20	В обработке	t
90759	90758	90102	2025-07-02	2025-08-15	2025-08-15	7349752.71	Ожидает оплаты	f
90760	90034	90213	2024-09-19	2024-10-27	\N	1522543.03	Таможенное оформление	f
90761	90656	90833	2025-02-17	2025-03-25	\N	7181775.21	Доставлен	t
90762	90613	90687	2025-07-30	2025-09-19	\N	6408374.16	Таможенное оформление	t
90763	90618	89992	2024-11-26	2025-01-25	\N	6407726.26	В пути	f
90764	89941	90347	2025-05-26	2025-07-22	2025-07-22	6826170.46	В обработке	t
90765	90078	90128	2025-08-22	2025-09-23	2025-09-23	4175911.13	В пути	f
90766	90002	90591	2025-06-17	2025-08-13	\N	3313804.99	В обработке	t
90767	89826	90352	2025-03-16	2025-05-14	2025-05-14	2828463.67	В обработке	t
90768	90486	90239	2025-03-16	2025-05-09	\N	6641320.14	В пути	t
90769	90164	89962	2025-08-11	2025-09-27	2025-09-27	3488652.47	В пути	t
90770	90057	90688	2025-02-07	2025-03-19	\N	2960863.71	Таможенное оформление	t
90771	90374	90732	2025-03-21	2025-04-26	\N	5097062.00	Доставлен	t
90772	90464	90251	2024-10-17	2024-12-13	\N	3032283.00	В пути	f
90773	89886	90270	2025-02-07	2025-03-10	2025-03-10	6010930.92	Таможенное оформление	t
90774	90792	90316	2024-11-27	2025-01-22	2025-01-22	5429626.41	Ожидает оплаты	t
90775	90059	90229	2025-08-20	2025-09-19	2025-09-19	7662798.47	Доставлен	t
90776	90151	90255	2025-01-09	2025-03-04	\N	5737393.66	Таможенное оформление	t
90777	90013	90257	2025-04-18	2025-06-07	\N	7976683.85	Таможенное оформление	f
90778	90762	90797	2025-07-25	2025-09-12	\N	5758401.75	Доставлен	f
90779	89974	90085	2025-06-15	2025-08-09	2025-08-09	2189482.00	Ожидает оплаты	f
90780	90817	90329	2025-04-20	2025-06-12	\N	4746023.41	В обработке	t
90781	90761	90117	2025-04-11	2025-06-08	2025-06-08	1879576.31	В пути	t
90782	90416	90733	2024-09-18	2024-10-21	2024-10-21	5707153.44	В обработке	f
90783	90291	90682	2024-12-10	2025-01-21	\N	2141368.91	Таможенное оформление	t
90784	90416	90037	2025-01-03	2025-02-18	\N	1600609.31	В пути	t
90785	90353	90287	2024-10-17	2024-11-24	\N	3673175.06	Доставлен	t
90786	90633	90228	2024-12-06	2025-01-13	\N	1583266.48	Ожидает оплаты	t
90787	90701	90326	2025-08-31	2025-10-05	\N	6773420.06	В пути	t
90788	90504	90865	2025-04-04	2025-05-25	2025-05-25	5047538.86	В обработке	f
90789	90446	90240	2025-09-09	2025-10-20	\N	2812801.25	Ожидает оплаты	f
90790	90039	89958	2025-09-05	2025-10-12	2025-10-12	2822842.16	Доставлен	f
90791	90222	90543	2025-02-23	2025-04-07	\N	6849916.20	Доставлен	t
90792	90190	89905	2025-08-16	2025-09-28	2025-09-28	2673850.98	В пути	f
90793	90304	90586	2025-01-30	2025-03-15	2025-03-15	3405923.44	В обработке	t
90794	90467	90488	2025-06-20	2025-07-26	2025-07-26	7277036.67	Таможенное оформление	t
90795	89880	90448	2025-04-28	2025-06-25	2025-06-25	3816787.15	В пути	f
90796	90643	90635	2025-05-30	2025-07-27	2025-07-27	2352623.90	В пути	t
90797	89865	89977	2025-07-08	2025-09-05	\N	5773699.19	В пути	t
90798	89990	90476	2025-01-31	2025-03-03	2025-03-03	6414034.30	Ожидает оплаты	f
90799	90344	89920	2024-11-12	2024-12-26	\N	1746086.52	В обработке	t
90800	90753	90236	2025-04-26	2025-06-03	2025-06-03	5887917.54	В пути	t
90801	90070	90795	2025-03-26	2025-05-23	\N	3727739.63	Ожидает оплаты	t
90802	90703	90822	2025-08-08	2025-09-30	2025-09-30	3976944.42	Ожидает оплаты	t
90803	89917	90774	2025-01-17	2025-03-03	\N	4055514.59	Ожидает оплаты	t
90804	89984	90553	2025-02-26	2025-04-23	\N	2849431.98	Ожидает оплаты	t
90805	90057	90429	2025-01-11	2025-03-04	\N	4024935.42	Таможенное оформление	f
90806	89939	90408	2025-01-21	2025-02-24	2025-02-24	4867375.10	Ожидает оплаты	t
90807	90083	90385	2025-08-28	2025-10-19	2025-10-19	7209924.25	Ожидает оплаты	t
90808	90809	90513	2025-01-10	2025-03-05	\N	2477019.50	Ожидает оплаты	f
90809	90695	90060	2025-04-10	2025-05-26	2025-05-26	1946846.00	Ожидает оплаты	f
90810	90220	90818	2025-01-29	2025-03-14	2025-03-14	2019896.73	В обработке	f
90811	89836	90811	2024-11-30	2025-01-09	\N	3948787.10	Ожидает оплаты	t
90812	89946	90116	2025-01-23	2025-03-06	\N	7878473.66	В пути	t
90813	90124	90326	2024-12-17	2025-01-20	\N	3830708.58	Ожидает оплаты	f
90814	89963	90405	2025-04-24	2025-06-10	\N	3949542.40	Ожидает оплаты	f
90815	89851	89957	2025-09-14	2025-10-18	\N	4964309.17	В обработке	t
90816	90041	90078	2024-10-07	2024-11-19	2024-11-19	2453610.49	Таможенное оформление	f
90817	90810	89898	2024-11-25	2025-01-22	2025-01-22	7991730.51	В пути	f
90818	90531	89920	2025-02-24	2025-04-25	\N	5571857.46	Доставлен	t
90819	89829	90145	2024-10-05	2024-11-18	\N	2043272.76	В обработке	t
90820	90684	90267	2025-02-03	2025-03-20	\N	7422722.57	В пути	t
90821	90648	90499	2025-09-15	2025-10-27	\N	5856052.52	Таможенное оформление	t
90822	90674	90871	2025-07-07	2025-08-29	\N	4874953.77	Таможенное оформление	t
90823	90311	90545	2025-07-15	2025-09-07	2025-09-07	5468669.27	В пути	t
90824	90082	89957	2024-12-19	2025-02-12	\N	3021154.99	Доставлен	f
90825	90449	90763	2025-06-22	2025-08-06	\N	3196410.22	Ожидает оплаты	f
90826	89887	90818	2025-01-19	2025-03-05	\N	5955459.03	Доставлен	f
90827	90579	90247	2025-06-09	2025-07-09	\N	6191618.64	В обработке	f
90828	90620	90043	2025-01-12	2025-02-18	2025-02-18	4006770.27	Ожидает оплаты	t
90829	89961	90590	2025-05-25	2025-07-20	\N	5270346.00	В пути	t
90830	90552	90301	2025-08-06	2025-09-17	2025-09-17	3878268.41	В обработке	f
90831	90709	90251	2025-09-03	2025-10-24	2025-10-24	6629260.06	Доставлен	t
90832	89898	90120	2024-10-10	2024-11-19	2024-11-19	3098866.75	В пути	f
90833	90425	90647	2025-08-12	2025-10-09	\N	2587949.29	В пути	t
90834	89832	90581	2025-04-02	2025-05-24	2025-05-24	2393744.47	Таможенное оформление	f
90835	89892	90592	2025-03-13	2025-04-29	\N	2504769.47	Таможенное оформление	t
90836	90515	90483	2025-01-20	2025-02-26	2025-02-26	7004094.69	Таможенное оформление	f
90837	89872	90058	2025-04-28	2025-06-07	2025-06-07	6193738.07	В пути	f
90838	90401	90591	2024-09-21	2024-10-28	\N	6840097.31	В пути	f
90839	90217	90008	2025-04-08	2025-05-30	2025-05-30	4881068.60	Ожидает оплаты	f
90840	90804	90044	2024-12-27	2025-02-09	2025-02-09	3559461.11	В пути	t
90841	90754	90759	2025-07-01	2025-08-30	\N	7563946.71	Доставлен	f
90842	90596	90731	2025-01-04	2025-02-14	\N	2930769.21	Таможенное оформление	t
90843	90488	90319	2025-01-13	2025-02-12	\N	6914817.83	В пути	f
90844	90198	89889	2025-08-07	2025-09-12	2025-09-12	6163828.09	В обработке	f
90845	90227	90602	2025-08-02	2025-09-07	2025-09-07	3242055.77	В пути	t
90846	90280	90213	2024-12-01	2025-01-18	\N	3416912.94	В обработке	f
90847	89857	90304	2024-11-18	2025-01-12	2025-01-12	1668032.97	В обработке	f
90848	90353	90571	2025-07-29	2025-09-27	\N	6417498.67	В пути	t
90849	90748	90006	2025-03-23	2025-05-13	2025-05-13	7815374.11	В обработке	t
90850	90218	90670	2025-02-27	2025-04-06	\N	1906602.62	Ожидает оплаты	f
90851	90023	90529	2024-12-23	2025-02-13	\N	5581372.04	Доставлен	f
90852	90757	90062	2025-04-26	2025-06-05	\N	1676743.10	Доставлен	t
90853	90486	90148	2025-06-24	2025-07-28	2025-07-28	2697928.37	В обработке	t
90854	90729	90115	2024-11-25	2025-01-01	2025-01-01	6403290.15	Доставлен	t
90855	90277	89907	2025-03-24	2025-05-08	2025-05-08	7472244.82	Ожидает оплаты	f
90856	90800	90811	2025-02-17	2025-03-26	\N	1884579.02	В пути	t
90857	90379	90068	2025-06-25	2025-08-03	\N	7140278.69	Ожидает оплаты	f
90858	90743	90851	2025-03-01	2025-04-30	2025-04-30	3615799.79	Доставлен	t
90859	90353	90647	2025-08-12	2025-09-19	\N	6226355.51	Доставлен	t
90860	90330	90756	2024-11-06	2024-12-20	\N	3093911.06	Доставлен	t
90861	90777	90565	2024-10-16	2024-12-08	\N	6606611.54	В обработке	t
90862	90515	90711	2025-04-17	2025-05-19	2025-05-19	7621514.72	Ожидает оплаты	f
90863	90687	90558	2025-01-23	2025-03-22	2025-03-22	7481536.54	В пути	f
90864	90340	89992	2025-01-11	2025-03-12	\N	4729477.30	Доставлен	t
90865	90129	90808	2025-05-12	2025-06-11	2025-06-11	5221849.64	В обработке	t
90866	89992	90699	2025-03-09	2025-04-08	\N	2467377.69	Доставлен	f
90867	90170	89969	2025-05-24	2025-07-06	\N	2050627.52	Таможенное оформление	f
90868	89845	90229	2025-08-23	2025-09-25	\N	6964699.29	В пути	t
90869	90637	90189	2025-04-27	2025-06-16	2025-06-16	2753566.96	Ожидает оплаты	f
90870	90148	90302	2025-04-14	2025-05-17	\N	1946309.24	В пути	t
90871	90232	90242	2024-12-27	2025-01-31	2025-01-31	6850957.55	В обработке	t
90872	90717	90360	2025-07-11	2025-08-25	\N	3724004.84	Ожидает оплаты	t
90873	90122	90689	2024-12-31	2025-02-20	2025-02-20	5169638.24	В пути	t
90874	90414	90407	2025-02-17	2025-03-30	\N	1979316.69	В обработке	t
90875	89900	90192	2025-02-28	2025-04-14	2025-04-14	5699847.02	Таможенное оформление	t
90876	89999	89927	2024-10-28	2024-12-05	2024-12-05	7466318.37	Ожидает оплаты	t
90877	90764	90802	2024-10-23	2024-11-25	2024-11-25	4734604.15	В пути	t
90878	90399	90153	2024-09-30	2024-11-15	2024-11-15	3983793.71	В обработке	f
90879	90057	90392	2025-08-26	2025-10-03	2025-10-03	1984065.14	Доставлен	t
90880	90352	89991	2025-05-21	2025-06-21	\N	5928425.19	Ожидает оплаты	t
90881	90232	90010	2025-07-06	2025-08-31	2025-08-31	1691537.59	Ожидает оплаты	t
90882	89912	89911	2025-09-11	2025-10-18	2025-10-18	3448271.34	В пути	t
90883	89839	89936	2025-04-17	2025-06-03	2025-06-03	4934576.79	Таможенное оформление	f
90884	90821	90407	2024-11-24	2024-12-24	2024-12-24	6113873.72	Таможенное оформление	t
90885	90180	90475	2025-03-12	2025-05-02	2025-05-02	4619379.57	В обработке	f
90886	90625	90667	2025-05-31	2025-07-11	2025-07-11	4193838.12	В пути	t
90887	90172	90301	2024-12-09	2025-01-11	\N	4298760.17	В обработке	t
90888	90275	90871	2024-12-14	2025-02-05	2025-02-05	1976144.40	Доставлен	f
90889	90152	90705	2025-02-20	2025-03-22	\N	4543558.14	Доставлен	t
90890	90276	89954	2025-04-16	2025-05-27	2025-05-27	2880998.93	Таможенное оформление	t
90891	90584	90414	2025-04-26	2025-06-05	\N	7739458.29	В обработке	t
90892	90398	90058	2025-08-25	2025-10-16	2025-10-16	5999696.13	В пути	f
90893	90210	90390	2025-04-04	2025-05-10	\N	1823870.70	Ожидает оплаты	t
90894	90153	90192	2025-01-13	2025-02-20	2025-02-20	2508031.36	В обработке	f
90895	90252	90116	2025-01-23	2025-02-24	2025-02-24	6605405.68	Доставлен	f
90896	90814	90301	2025-04-28	2025-06-03	\N	6049208.78	Ожидает оплаты	f
90897	90567	90772	2024-10-20	2024-12-11	\N	6213474.45	Ожидает оплаты	t
90898	90618	90379	2024-10-12	2024-12-11	\N	5671678.10	Доставлен	f
90899	90371	90445	2025-09-09	2025-10-31	2025-10-31	6024948.03	Ожидает оплаты	f
90900	90594	90434	2025-03-23	2025-05-08	2025-05-08	3771328.14	Таможенное оформление	t
90901	90304	90140	2025-05-11	2025-06-27	\N	7349034.95	Доставлен	t
90902	90726	90368	2025-08-10	2025-09-24	\N	6173481.21	Ожидает оплаты	f
90903	90158	90509	2025-05-23	2025-07-01	\N	6806643.37	Ожидает оплаты	f
90904	90499	90105	2024-11-01	2024-12-21	\N	5097085.96	В пути	f
90905	90618	90840	2025-05-24	2025-06-28	\N	4176203.97	Таможенное оформление	f
90906	90319	90145	2025-01-30	2025-03-30	\N	5804982.10	Ожидает оплаты	f
90907	90305	90001	2025-01-09	2025-02-10	\N	1795753.10	В обработке	t
90908	89831	90154	2025-09-09	2025-10-27	\N	1929479.88	В пути	t
90909	90210	90566	2025-09-01	2025-10-12	2025-10-12	1941426.75	В обработке	f
90910	90282	89945	2025-08-26	2025-10-19	2025-10-19	5327063.08	Доставлен	t
90911	90293	90201	2025-04-20	2025-06-16	2025-06-16	2647598.24	Таможенное оформление	f
90912	90071	90820	2024-11-08	2024-12-10	2024-12-10	4038735.71	Таможенное оформление	t
90913	90159	90682	2024-09-23	2024-11-08	2024-11-08	3420184.83	В пути	f
90914	90301	90293	2025-07-17	2025-09-06	\N	3560625.34	Ожидает оплаты	f
90915	90664	89979	2025-02-26	2025-04-18	2025-04-18	5086407.16	В пути	f
90916	90453	89990	2024-09-26	2024-11-13	2024-11-13	5379066.58	Ожидает оплаты	t
90917	90622	89992	2025-06-07	2025-07-21	\N	5105942.23	В обработке	f
90918	90648	89961	2024-10-19	2024-12-17	\N	1519223.15	В пути	f
90919	90708	90368	2025-08-15	2025-09-24	\N	5747475.89	В пути	f
90920	89878	89913	2025-01-24	2025-03-10	\N	4359422.22	Ожидает оплаты	f
90921	90050	90103	2025-05-16	2025-06-22	2025-06-22	2141013.36	Таможенное оформление	t
90922	90638	90442	2025-04-10	2025-05-23	\N	5881825.95	Таможенное оформление	t
90923	90526	90057	2024-12-19	2025-02-10	2025-02-10	1854875.86	Ожидает оплаты	t
90924	90609	90220	2025-08-18	2025-10-09	\N	4716318.99	Ожидает оплаты	f
90925	90710	90867	2025-04-28	2025-06-27	\N	5573878.65	В обработке	t
90926	89825	89935	2025-04-18	2025-06-04	\N	2476864.17	Доставлен	f
90927	89833	90696	2025-05-14	2025-07-09	\N	3774308.88	Ожидает оплаты	t
\.


--
-- TOC entry 3679 (class 0 OID 18348)
-- Dependencies: 228
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.services (service_id, service_name, description, base_price_rub) FROM stdin;
1	Транспортировка	Доставка автомобиля из Европы	80000.00
2	Таможенное оформление	Оформление документов на таможне	25000.00
3	Техосмотр	Проведение технического осмотра	5000.00
4	Страхование	Страхование автомобиля при транспортировке	15000.00
5	Постановка на учет	Регистрация в ГИБДД	8000.00
6	Транспортировка	Доставка автомобиля из Европы	80000.00
7	Таможенное оформление	Оформление документов на таможне	25000.00
8	Техосмотр	Проведение технического осмотра	5000.00
9	Страхование	Страхование автомобиля при транспортировке	15000.00
10	Постановка на учет	Регистрация в ГИБДД	8000.00
11	Транспортировка	Доставка автомобиля из Европы	80000.00
12	Таможенное оформление	Оформление документов на таможне	25000.00
13	Техосмотр	Проведение технического осмотра	5000.00
14	Страхование	Страхование автомобиля при транспортировке	15000.00
15	Постановка на учет	Регистрация в ГИБДД	8000.00
16	Транспортировка	Доставка автомобиля из Европы	80000.00
17	Таможенное оформление	Оформление документов на таможне	25000.00
18	Техосмотр	Проведение технического осмотра	5000.00
19	Страхование	Страхование автомобиля при транспортировке	15000.00
20	Постановка на учет	Регистрация в ГИБДД	8000.00
21	Транспортировка	Доставка автомобиля из Европы	80000.00
22	Таможенное оформление	Оформление документов на таможне	25000.00
23	Техосмотр	Проведение технического осмотра	5000.00
24	Страхование	Страхование автомобиля при транспортировке	15000.00
25	Постановка на учет	Регистрация в ГИБДД	8000.00
26	Транспортировка	Доставка автомобиля из Европы	80000.00
27	Таможенное оформление	Оформление документов на таможне	25000.00
28	Техосмотр	Проведение технического осмотра	5000.00
29	Страхование	Страхование автомобиля при транспортировке	15000.00
30	Постановка на учет	Регистрация в ГИБДД	8000.00
31	Транспортировка	Доставка автомобиля из Европы	80000.00
32	Таможенное оформление	Оформление документов на таможне	25000.00
33	Техосмотр	Проведение технического осмотра	5000.00
34	Страхование	Страхование автомобиля при транспортировке	15000.00
35	Постановка на учет	Регистрация в ГИБДД	8000.00
36	Транспортировка	Доставка автомобиля из Европы	80000.00
37	Таможенное оформление	Оформление документов на таможне	25000.00
38	Техосмотр	Проведение технического осмотра	5000.00
39	Страхование	Страхование автомобиля при транспортировке	15000.00
40	Постановка на учет	Регистрация в ГИБДД	8000.00
41	Транспортировка	Доставка автомобиля из Европы	80000.00
42	Таможенное оформление	Оформление документов на таможне	25000.00
43	Техосмотр	Проведение технического осмотра	5000.00
44	Страхование	Страхование автомобиля при транспортировке	15000.00
45	Постановка на учет	Регистрация в ГИБДД	8000.00
46	Транспортировка	Доставка автомобиля из Европы	80000.00
47	Таможенное оформление	Оформление документов на таможне	25000.00
48	Техосмотр	Проведение технического осмотра	5000.00
49	Страхование	Страхование автомобиля при транспортировке	15000.00
50	Постановка на учет	Регистрация в ГИБДД	8000.00
51	Транспортировка	Доставка автомобиля из Европы	80000.00
52	Таможенное оформление	Оформление документов на таможне	25000.00
53	Техосмотр	Проведение технического осмотра	5000.00
54	Страхование	Страхование автомобиля при транспортировке	15000.00
55	Постановка на учет	Регистрация в ГИБДД	8000.00
56	Транспортировка	Доставка автомобиля из Европы	80000.00
57	Таможенное оформление	Оформление документов на таможне	25000.00
58	Техосмотр	Проведение технического осмотра	5000.00
59	Страхование	Страхование автомобиля при транспортировке	15000.00
60	Постановка на учет	Регистрация в ГИБДД	8000.00
61	Транспортировка	Доставка автомобиля из Европы	80000.00
62	Таможенное оформление	Оформление документов на таможне	25000.00
63	Техосмотр	Проведение технического осмотра	5000.00
64	Страхование	Страхование автомобиля при транспортировке	15000.00
65	Постановка на учет	Регистрация в ГИБДД	8000.00
66	Транспортировка	Доставка автомобиля из Европы	80000.00
67	Таможенное оформление	Оформление документов на таможне	25000.00
68	Техосмотр	Проведение технического осмотра	5000.00
69	Страхование	Страхование автомобиля при транспортировке	15000.00
70	Постановка на учет	Регистрация в ГИБДД	8000.00
71	Транспортировка	Доставка автомобиля из Европы	80000.00
72	Таможенное оформление	Оформление документов на таможне	25000.00
73	Техосмотр	Проведение технического осмотра	5000.00
74	Страхование	Страхование автомобиля при транспортировке	15000.00
75	Постановка на учет	Регистрация в ГИБДД	8000.00
76	Транспортировка	Доставка автомобиля из Европы	80000.00
77	Таможенное оформление	Оформление документов на таможне	25000.00
78	Техосмотр	Проведение технического осмотра	5000.00
79	Страхование	Страхование автомобиля при транспортировке	15000.00
80	Постановка на учет	Регистрация в ГИБДД	8000.00
81	Транспортировка	Доставка автомобиля из Европы	80000.00
82	Таможенное оформление	Оформление документов на таможне	25000.00
83	Техосмотр	Проведение технического осмотра	5000.00
84	Страхование	Страхование автомобиля при транспортировке	15000.00
85	Постановка на учет	Регистрация в ГИБДД	8000.00
86	Транспортировка	Доставка автомобиля из Европы	80000.00
87	Таможенное оформление	Оформление документов на таможне	25000.00
88	Техосмотр	Проведение технического осмотра	5000.00
89	Страхование	Страхование автомобиля при транспортировке	15000.00
90	Постановка на учет	Регистрация в ГИБДД	8000.00
91	Транспортировка	Доставка автомобиля из Европы	80000.00
92	Таможенное оформление	Оформление документов на таможне	25000.00
93	Техосмотр	Проведение технического осмотра	5000.00
94	Страхование	Страхование автомобиля при транспортировке	15000.00
95	Постановка на учет	Регистрация в ГИБДД	8000.00
96	Транспортировка	Доставка автомобиля из Европы	80000.00
97	Таможенное оформление	Оформление документов на таможне	25000.00
98	Техосмотр	Проведение технического осмотра	5000.00
99	Страхование	Страхование автомобиля при транспортировке	15000.00
100	Постановка на учет	Регистрация в ГИБДД	8000.00
101	Транспортировка	Доставка автомобиля из Европы	80000.00
102	Таможенное оформление	Оформление документов на таможне	25000.00
103	Техосмотр	Проведение технического осмотра	5000.00
104	Страхование	Страхование автомобиля при транспортировке	15000.00
105	Постановка на учет	Регистрация в ГИБДД	8000.00
106	Транспортировка	Доставка автомобиля из Европы	80000.00
107	Таможенное оформление	Оформление документов на таможне	25000.00
108	Техосмотр	Проведение технического осмотра	5000.00
109	Страхование	Страхование автомобиля при транспортировке	15000.00
110	Постановка на учет	Регистрация в ГИБДД	8000.00
111	Транспортировка	Доставка автомобиля из Европы	80000.00
112	Таможенное оформление	Оформление документов на таможне	25000.00
113	Техосмотр	Проведение технического осмотра	5000.00
114	Страхование	Страхование автомобиля при транспортировке	15000.00
115	Постановка на учет	Регистрация в ГИБДД	8000.00
116	Транспортировка	Доставка автомобиля из Европы	80000.00
117	Таможенное оформление	Оформление документов на таможне	25000.00
118	Техосмотр	Проведение технического осмотра	5000.00
119	Страхование	Страхование автомобиля при транспортировке	15000.00
120	Постановка на учет	Регистрация в ГИБДД	8000.00
121	Транспортировка	Доставка автомобиля из Европы	80000.00
122	Таможенное оформление	Оформление документов на таможне	25000.00
123	Техосмотр	Проведение технического осмотра	5000.00
124	Страхование	Страхование автомобиля при транспортировке	15000.00
125	Постановка на учет	Регистрация в ГИБДД	8000.00
126	Транспортировка	Доставка автомобиля из Европы	80000.00
127	Таможенное оформление	Оформление документов на таможне	25000.00
128	Техосмотр	Проведение технического осмотра	5000.00
129	Страхование	Страхование автомобиля при транспортировке	15000.00
130	Постановка на учет	Регистрация в ГИБДД	8000.00
131	Транспортировка	Доставка автомобиля из Европы	80000.00
132	Таможенное оформление	Оформление документов на таможне	25000.00
133	Техосмотр	Проведение технического осмотра	5000.00
134	Страхование	Страхование автомобиля при транспортировке	15000.00
135	Постановка на учет	Регистрация в ГИБДД	8000.00
136	Транспортировка	Доставка автомобиля из Европы	80000.00
137	Таможенное оформление	Оформление документов на таможне	25000.00
138	Техосмотр	Проведение технического осмотра	5000.00
139	Страхование	Страхование автомобиля при транспортировке	15000.00
140	Постановка на учет	Регистрация в ГИБДД	8000.00
141	Транспортировка	Доставка автомобиля из Европы	80000.00
142	Таможенное оформление	Оформление документов на таможне	25000.00
143	Техосмотр	Проведение технического осмотра	5000.00
144	Страхование	Страхование автомобиля при транспортировке	15000.00
145	Постановка на учет	Регистрация в ГИБДД	8000.00
146	Транспортировка	Доставка автомобиля из Европы	80000.00
147	Таможенное оформление	Оформление документов на таможне	25000.00
148	Техосмотр	Проведение технического осмотра	5000.00
149	Страхование	Страхование автомобиля при транспортировке	15000.00
150	Постановка на учет	Регистрация в ГИБДД	8000.00
151	Транспортировка	Доставка автомобиля из Европы	80000.00
152	Таможенное оформление	Оформление документов на таможне	25000.00
153	Техосмотр	Проведение технического осмотра	5000.00
154	Страхование	Страхование автомобиля при транспортировке	15000.00
155	Постановка на учет	Регистрация в ГИБДД	8000.00
156	Транспортировка	Доставка автомобиля из Европы	80000.00
157	Таможенное оформление	Оформление документов на таможне	25000.00
158	Техосмотр	Проведение технического осмотра	5000.00
159	Страхование	Страхование автомобиля при транспортировке	15000.00
160	Постановка на учет	Регистрация в ГИБДД	8000.00
161	Транспортировка	Доставка автомобиля из Европы	80000.00
162	Таможенное оформление	Оформление документов на таможне	25000.00
163	Техосмотр	Проведение технического осмотра	5000.00
164	Страхование	Страхование автомобиля при транспортировке	15000.00
165	Постановка на учет	Регистрация в ГИБДД	8000.00
166	Транспортировка	Доставка автомобиля из Европы	80000.00
167	Таможенное оформление	Оформление документов на таможне	25000.00
168	Техосмотр	Проведение технического осмотра	5000.00
169	Страхование	Страхование автомобиля при транспортировке	15000.00
170	Постановка на учет	Регистрация в ГИБДД	8000.00
171	Транспортировка	Доставка автомобиля из Европы	80000.00
172	Таможенное оформление	Оформление документов на таможне	25000.00
173	Техосмотр	Проведение технического осмотра	5000.00
174	Страхование	Страхование автомобиля при транспортировке	15000.00
175	Постановка на учет	Регистрация в ГИБДД	8000.00
176	Транспортировка	Доставка автомобиля из Европы	80000.00
177	Таможенное оформление	Оформление документов на таможне	25000.00
178	Техосмотр	Проведение технического осмотра	5000.00
179	Страхование	Страхование автомобиля при транспортировке	15000.00
180	Постановка на учет	Регистрация в ГИБДД	8000.00
181	Транспортировка	Доставка автомобиля из Европы	80000.00
182	Таможенное оформление	Оформление документов на таможне	25000.00
183	Техосмотр	Проведение технического осмотра	5000.00
184	Страхование	Страхование автомобиля при транспортировке	15000.00
185	Постановка на учет	Регистрация в ГИБДД	8000.00
186	Транспортировка	Доставка автомобиля из Европы	80000.00
187	Таможенное оформление	Оформление документов на таможне	25000.00
188	Техосмотр	Проведение технического осмотра	5000.00
189	Страхование	Страхование автомобиля при транспортировке	15000.00
190	Постановка на учет	Регистрация в ГИБДД	8000.00
191	Транспортировка	Доставка автомобиля из Европы	80000.00
192	Таможенное оформление	Оформление документов на таможне	25000.00
193	Техосмотр	Проведение технического осмотра	5000.00
194	Страхование	Страхование автомобиля при транспортировке	15000.00
195	Постановка на учет	Регистрация в ГИБДД	8000.00
196	Транспортировка	Доставка автомобиля из Европы	80000.00
197	Таможенное оформление	Оформление документов на таможне	25000.00
198	Техосмотр	Проведение технического осмотра	5000.00
199	Страхование	Страхование автомобиля при транспортировке	15000.00
200	Постановка на учет	Регистрация в ГИБДД	8000.00
201	Транспортировка	Доставка автомобиля из Европы	80000.00
202	Таможенное оформление	Оформление документов на таможне	25000.00
203	Техосмотр	Проведение технического осмотра	5000.00
204	Страхование	Страхование автомобиля при транспортировке	15000.00
205	Постановка на учет	Регистрация в ГИБДД	8000.00
206	Транспортировка	Доставка автомобиля из Европы	80000.00
207	Таможенное оформление	Оформление документов на таможне	25000.00
208	Техосмотр	Проведение технического осмотра	5000.00
209	Страхование	Страхование автомобиля при транспортировке	15000.00
210	Постановка на учет	Регистрация в ГИБДД	8000.00
211	Транспортировка	Доставка автомобиля из Европы	80000.00
212	Таможенное оформление	Оформление документов на таможне	25000.00
213	Техосмотр	Проведение технического осмотра	5000.00
214	Страхование	Страхование автомобиля при транспортировке	15000.00
215	Постановка на учет	Регистрация в ГИБДД	8000.00
216	Транспортировка	Доставка автомобиля из Европы	80000.00
217	Таможенное оформление	Оформление документов на таможне	25000.00
218	Техосмотр	Проведение технического осмотра	5000.00
219	Страхование	Страхование автомобиля при транспортировке	15000.00
220	Постановка на учет	Регистрация в ГИБДД	8000.00
221	Транспортировка	Доставка автомобиля из Европы	80000.00
222	Таможенное оформление	Оформление документов на таможне	25000.00
223	Техосмотр	Проведение технического осмотра	5000.00
224	Страхование	Страхование автомобиля при транспортировке	15000.00
225	Постановка на учет	Регистрация в ГИБДД	8000.00
226	Транспортировка	Доставка автомобиля из Европы	80000.00
227	Таможенное оформление	Оформление документов на таможне	25000.00
228	Техосмотр	Проведение технического осмотра	5000.00
229	Страхование	Страхование автомобиля при транспортировке	15000.00
230	Постановка на учет	Регистрация в ГИБДД	8000.00
231	Транспортировка	Доставка автомобиля из Европы	80000.00
232	Таможенное оформление	Оформление документов на таможне	25000.00
233	Техосмотр	Проведение технического осмотра	5000.00
234	Страхование	Страхование автомобиля при транспортировке	15000.00
235	Постановка на учет	Регистрация в ГИБДД	8000.00
236	Транспортировка	Доставка автомобиля из Европы	80000.00
237	Таможенное оформление	Оформление документов на таможне	25000.00
238	Техосмотр	Проведение технического осмотра	5000.00
239	Страхование	Страхование автомобиля при транспортировке	15000.00
240	Постановка на учет	Регистрация в ГИБДД	8000.00
241	Транспортировка	Доставка автомобиля из Европы	80000.00
242	Таможенное оформление	Оформление документов на таможне	25000.00
243	Техосмотр	Проведение технического осмотра	5000.00
244	Страхование	Страхование автомобиля при транспортировке	15000.00
245	Постановка на учет	Регистрация в ГИБДД	8000.00
246	Транспортировка	Доставка автомобиля из Европы	80000.00
247	Таможенное оформление	Оформление документов на таможне	25000.00
248	Техосмотр	Проведение технического осмотра	5000.00
249	Страхование	Страхование автомобиля при транспортировке	15000.00
250	Постановка на учет	Регистрация в ГИБДД	8000.00
251	Транспортировка	Доставка автомобиля из Европы	80000.00
252	Таможенное оформление	Оформление документов на таможне	25000.00
253	Техосмотр	Проведение технического осмотра	5000.00
254	Страхование	Страхование автомобиля при транспортировке	15000.00
255	Постановка на учет	Регистрация в ГИБДД	8000.00
256	Транспортировка	Доставка автомобиля из Европы	80000.00
257	Таможенное оформление	Оформление документов на таможне	25000.00
258	Техосмотр	Проведение технического осмотра	5000.00
259	Страхование	Страхование автомобиля при транспортировке	15000.00
260	Постановка на учет	Регистрация в ГИБДД	8000.00
261	Транспортировка	Доставка автомобиля из Европы	80000.00
262	Таможенное оформление	Оформление документов на таможне	25000.00
263	Техосмотр	Проведение технического осмотра	5000.00
264	Страхование	Страхование автомобиля при транспортировке	15000.00
265	Постановка на учет	Регистрация в ГИБДД	8000.00
266	Транспортировка	Доставка автомобиля из Европы	80000.00
267	Таможенное оформление	Оформление документов на таможне	25000.00
268	Техосмотр	Проведение технического осмотра	5000.00
269	Страхование	Страхование автомобиля при транспортировке	15000.00
270	Постановка на учет	Регистрация в ГИБДД	8000.00
271	Транспортировка	Доставка автомобиля из Европы	80000.00
272	Таможенное оформление	Оформление документов на таможне	25000.00
273	Техосмотр	Проведение технического осмотра	5000.00
274	Страхование	Страхование автомобиля при транспортировке	15000.00
275	Постановка на учет	Регистрация в ГИБДД	8000.00
276	Транспортировка	Доставка автомобиля из Европы	80000.00
277	Таможенное оформление	Оформление документов на таможне	25000.00
278	Техосмотр	Проведение технического осмотра	5000.00
279	Страхование	Страхование автомобиля при транспортировке	15000.00
280	Постановка на учет	Регистрация в ГИБДД	8000.00
281	Транспортировка	Доставка автомобиля из Европы	80000.00
282	Таможенное оформление	Оформление документов на таможне	25000.00
283	Техосмотр	Проведение технического осмотра	5000.00
284	Страхование	Страхование автомобиля при транспортировке	15000.00
285	Постановка на учет	Регистрация в ГИБДД	8000.00
286	Транспортировка	Доставка автомобиля из Европы	80000.00
287	Таможенное оформление	Оформление документов на таможне	25000.00
288	Техосмотр	Проведение технического осмотра	5000.00
289	Страхование	Страхование автомобиля при транспортировке	15000.00
290	Постановка на учет	Регистрация в ГИБДД	8000.00
291	Транспортировка	Доставка автомобиля из Европы	80000.00
292	Таможенное оформление	Оформление документов на таможне	25000.00
293	Техосмотр	Проведение технического осмотра	5000.00
294	Страхование	Страхование автомобиля при транспортировке	15000.00
295	Постановка на учет	Регистрация в ГИБДД	8000.00
296	Транспортировка	Доставка автомобиля из Европы	80000.00
297	Таможенное оформление	Оформление документов на таможне	25000.00
298	Техосмотр	Проведение технического осмотра	5000.00
299	Страхование	Страхование автомобиля при транспортировке	15000.00
300	Постановка на учет	Регистрация в ГИБДД	8000.00
301	Транспортировка	Доставка автомобиля из Европы	80000.00
302	Таможенное оформление	Оформление документов на таможне	25000.00
303	Техосмотр	Проведение технического осмотра	5000.00
304	Страхование	Страхование автомобиля при транспортировке	15000.00
305	Постановка на учет	Регистрация в ГИБДД	8000.00
306	Транспортировка	Доставка автомобиля из Европы	80000.00
307	Таможенное оформление	Оформление документов на таможне	25000.00
308	Техосмотр	Проведение технического осмотра	5000.00
309	Страхование	Страхование автомобиля при транспортировке	15000.00
310	Постановка на учет	Регистрация в ГИБДД	8000.00
311	Транспортировка	Доставка автомобиля из Европы	80000.00
312	Таможенное оформление	Оформление документов на таможне	25000.00
313	Техосмотр	Проведение технического осмотра	5000.00
314	Страхование	Страхование автомобиля при транспортировке	15000.00
315	Постановка на учет	Регистрация в ГИБДД	8000.00
316	Транспортировка	Доставка автомобиля из Европы	80000.00
317	Таможенное оформление	Оформление документов на таможне	25000.00
318	Техосмотр	Проведение технического осмотра	5000.00
319	Страхование	Страхование автомобиля при транспортировке	15000.00
320	Постановка на учет	Регистрация в ГИБДД	8000.00
321	Транспортировка	Доставка автомобиля из Европы	80000.00
322	Таможенное оформление	Оформление документов на таможне	25000.00
323	Техосмотр	Проведение технического осмотра	5000.00
324	Страхование	Страхование автомобиля при транспортировке	15000.00
325	Постановка на учет	Регистрация в ГИБДД	8000.00
326	Транспортировка	Доставка автомобиля из Европы	80000.00
327	Таможенное оформление	Оформление документов на таможне	25000.00
328	Техосмотр	Проведение технического осмотра	5000.00
329	Страхование	Страхование автомобиля при транспортировке	15000.00
330	Постановка на учет	Регистрация в ГИБДД	8000.00
331	Транспортировка	Доставка автомобиля из Европы	80000.00
332	Таможенное оформление	Оформление документов на таможне	25000.00
333	Техосмотр	Проведение технического осмотра	5000.00
334	Страхование	Страхование автомобиля при транспортировке	15000.00
335	Постановка на учет	Регистрация в ГИБДД	8000.00
336	Транспортировка	Доставка автомобиля из Европы	80000.00
337	Таможенное оформление	Оформление документов на таможне	25000.00
338	Техосмотр	Проведение технического осмотра	5000.00
339	Страхование	Страхование автомобиля при транспортировке	15000.00
340	Постановка на учет	Регистрация в ГИБДД	8000.00
341	Транспортировка	Доставка автомобиля из Европы	80000.00
342	Таможенное оформление	Оформление документов на таможне	25000.00
343	Техосмотр	Проведение технического осмотра	5000.00
344	Страхование	Страхование автомобиля при транспортировке	15000.00
345	Постановка на учет	Регистрация в ГИБДД	8000.00
346	Транспортировка	Доставка автомобиля из Европы	80000.00
347	Таможенное оформление	Оформление документов на таможне	25000.00
348	Техосмотр	Проведение технического осмотра	5000.00
349	Страхование	Страхование автомобиля при транспортировке	15000.00
350	Постановка на учет	Регистрация в ГИБДД	8000.00
351	Транспортировка	Доставка автомобиля из Европы	80000.00
352	Таможенное оформление	Оформление документов на таможне	25000.00
353	Техосмотр	Проведение технического осмотра	5000.00
354	Страхование	Страхование автомобиля при транспортировке	15000.00
355	Постановка на учет	Регистрация в ГИБДД	8000.00
356	Транспортировка	Доставка автомобиля из Европы	80000.00
357	Таможенное оформление	Оформление документов на таможне	25000.00
358	Техосмотр	Проведение технического осмотра	5000.00
359	Страхование	Страхование автомобиля при транспортировке	15000.00
360	Постановка на учет	Регистрация в ГИБДД	8000.00
361	Транспортировка	Доставка автомобиля из Европы	80000.00
362	Таможенное оформление	Оформление документов на таможне	25000.00
363	Техосмотр	Проведение технического осмотра	5000.00
364	Страхование	Страхование автомобиля при транспортировке	15000.00
365	Постановка на учет	Регистрация в ГИБДД	8000.00
366	Транспортировка	Доставка автомобиля из Европы	80000.00
367	Таможенное оформление	Оформление документов на таможне	25000.00
368	Техосмотр	Проведение технического осмотра	5000.00
369	Страхование	Страхование автомобиля при транспортировке	15000.00
370	Постановка на учет	Регистрация в ГИБДД	8000.00
371	Транспортировка	Доставка автомобиля из Европы	80000.00
372	Таможенное оформление	Оформление документов на таможне	25000.00
373	Техосмотр	Проведение технического осмотра	5000.00
374	Страхование	Страхование автомобиля при транспортировке	15000.00
375	Постановка на учет	Регистрация в ГИБДД	8000.00
376	Транспортировка	Доставка автомобиля из Европы	80000.00
377	Таможенное оформление	Оформление документов на таможне	25000.00
378	Техосмотр	Проведение технического осмотра	5000.00
379	Страхование	Страхование автомобиля при транспортировке	15000.00
380	Постановка на учет	Регистрация в ГИБДД	8000.00
381	Транспортировка	Доставка автомобиля из Европы	80000.00
382	Таможенное оформление	Оформление документов на таможне	25000.00
383	Техосмотр	Проведение технического осмотра	5000.00
384	Страхование	Страхование автомобиля при транспортировке	15000.00
385	Постановка на учет	Регистрация в ГИБДД	8000.00
386	Транспортировка	Доставка автомобиля из Европы	80000.00
387	Таможенное оформление	Оформление документов на таможне	25000.00
388	Техосмотр	Проведение технического осмотра	5000.00
389	Страхование	Страхование автомобиля при транспортировке	15000.00
390	Постановка на учет	Регистрация в ГИБДД	8000.00
391	Транспортировка	Доставка автомобиля из Европы	80000.00
392	Таможенное оформление	Оформление документов на таможне	25000.00
393	Техосмотр	Проведение технического осмотра	5000.00
394	Страхование	Страхование автомобиля при транспортировке	15000.00
395	Постановка на учет	Регистрация в ГИБДД	8000.00
396	Транспортировка	Доставка автомобиля из Европы	80000.00
397	Таможенное оформление	Оформление документов на таможне	25000.00
398	Техосмотр	Проведение технического осмотра	5000.00
399	Страхование	Страхование автомобиля при транспортировке	15000.00
400	Постановка на учет	Регистрация в ГИБДД	8000.00
401	Транспортировка	Доставка автомобиля из Европы	80000.00
402	Таможенное оформление	Оформление документов на таможне	25000.00
403	Техосмотр	Проведение технического осмотра	5000.00
404	Страхование	Страхование автомобиля при транспортировке	15000.00
405	Постановка на учет	Регистрация в ГИБДД	8000.00
406	Транспортировка	Доставка автомобиля из Европы	80000.00
407	Таможенное оформление	Оформление документов на таможне	25000.00
408	Техосмотр	Проведение технического осмотра	5000.00
409	Страхование	Страхование автомобиля при транспортировке	15000.00
410	Постановка на учет	Регистрация в ГИБДД	8000.00
411	Транспортировка	Доставка автомобиля из Европы	80000.00
412	Таможенное оформление	Оформление документов на таможне	25000.00
413	Техосмотр	Проведение технического осмотра	5000.00
414	Страхование	Страхование автомобиля при транспортировке	15000.00
415	Постановка на учет	Регистрация в ГИБДД	8000.00
416	Транспортировка	Доставка автомобиля из Европы	80000.00
417	Таможенное оформление	Оформление документов на таможне	25000.00
418	Техосмотр	Проведение технического осмотра	5000.00
419	Страхование	Страхование автомобиля при транспортировке	15000.00
420	Постановка на учет	Регистрация в ГИБДД	8000.00
421	Транспортировка	Доставка автомобиля из Европы	80000.00
422	Таможенное оформление	Оформление документов на таможне	25000.00
423	Техосмотр	Проведение технического осмотра	5000.00
424	Страхование	Страхование автомобиля при транспортировке	15000.00
425	Постановка на учет	Регистрация в ГИБДД	8000.00
426	Транспортировка	Доставка автомобиля из Европы	80000.00
427	Таможенное оформление	Оформление документов на таможне	25000.00
428	Техосмотр	Проведение технического осмотра	5000.00
429	Страхование	Страхование автомобиля при транспортировке	15000.00
430	Постановка на учет	Регистрация в ГИБДД	8000.00
431	Транспортировка	Доставка автомобиля из Европы	80000.00
432	Таможенное оформление	Оформление документов на таможне	25000.00
433	Техосмотр	Проведение технического осмотра	5000.00
434	Страхование	Страхование автомобиля при транспортировке	15000.00
435	Постановка на учет	Регистрация в ГИБДД	8000.00
436	Транспортировка	Доставка автомобиля из Европы	80000.00
437	Таможенное оформление	Оформление документов на таможне	25000.00
438	Техосмотр	Проведение технического осмотра	5000.00
439	Страхование	Страхование автомобиля при транспортировке	15000.00
440	Постановка на учет	Регистрация в ГИБДД	8000.00
441	Транспортировка	Доставка автомобиля из Европы	80000.00
442	Таможенное оформление	Оформление документов на таможне	25000.00
443	Техосмотр	Проведение технического осмотра	5000.00
444	Страхование	Страхование автомобиля при транспортировке	15000.00
445	Постановка на учет	Регистрация в ГИБДД	8000.00
446	Транспортировка	Доставка автомобиля из Европы	80000.00
447	Таможенное оформление	Оформление документов на таможне	25000.00
448	Техосмотр	Проведение технического осмотра	5000.00
449	Страхование	Страхование автомобиля при транспортировке	15000.00
450	Постановка на учет	Регистрация в ГИБДД	8000.00
451	Транспортировка	Доставка автомобиля из Европы	80000.00
452	Таможенное оформление	Оформление документов на таможне	25000.00
453	Техосмотр	Проведение технического осмотра	5000.00
454	Страхование	Страхование автомобиля при транспортировке	15000.00
455	Постановка на учет	Регистрация в ГИБДД	8000.00
456	Транспортировка	Доставка автомобиля из Европы	80000.00
457	Таможенное оформление	Оформление документов на таможне	25000.00
458	Техосмотр	Проведение технического осмотра	5000.00
459	Страхование	Страхование автомобиля при транспортировке	15000.00
460	Постановка на учет	Регистрация в ГИБДД	8000.00
461	Транспортировка	Доставка автомобиля из Европы	80000.00
462	Таможенное оформление	Оформление документов на таможне	25000.00
463	Техосмотр	Проведение технического осмотра	5000.00
464	Страхование	Страхование автомобиля при транспортировке	15000.00
465	Постановка на учет	Регистрация в ГИБДД	8000.00
466	Транспортировка	Доставка автомобиля из Европы	80000.00
467	Таможенное оформление	Оформление документов на таможне	25000.00
468	Техосмотр	Проведение технического осмотра	5000.00
469	Страхование	Страхование автомобиля при транспортировке	15000.00
470	Постановка на учет	Регистрация в ГИБДД	8000.00
471	Транспортировка	Доставка автомобиля из Европы	80000.00
472	Таможенное оформление	Оформление документов на таможне	25000.00
473	Техосмотр	Проведение технического осмотра	5000.00
474	Страхование	Страхование автомобиля при транспортировке	15000.00
475	Постановка на учет	Регистрация в ГИБДД	8000.00
476	Транспортировка	Доставка автомобиля из Европы	80000.00
477	Таможенное оформление	Оформление документов на таможне	25000.00
478	Техосмотр	Проведение технического осмотра	5000.00
479	Страхование	Страхование автомобиля при транспортировке	15000.00
480	Постановка на учет	Регистрация в ГИБДД	8000.00
481	Транспортировка	Доставка автомобиля из Европы	80000.00
482	Таможенное оформление	Оформление документов на таможне	25000.00
483	Техосмотр	Проведение технического осмотра	5000.00
484	Страхование	Страхование автомобиля при транспортировке	15000.00
485	Постановка на учет	Регистрация в ГИБДД	8000.00
486	Транспортировка	Доставка автомобиля из Европы	80000.00
487	Таможенное оформление	Оформление документов на таможне	25000.00
488	Техосмотр	Проведение технического осмотра	5000.00
489	Страхование	Страхование автомобиля при транспортировке	15000.00
490	Постановка на учет	Регистрация в ГИБДД	8000.00
491	Транспортировка	Доставка автомобиля из Европы	80000.00
492	Таможенное оформление	Оформление документов на таможне	25000.00
493	Техосмотр	Проведение технического осмотра	5000.00
494	Страхование	Страхование автомобиля при транспортировке	15000.00
495	Постановка на учет	Регистрация в ГИБДД	8000.00
496	Транспортировка	Доставка автомобиля из Европы	80000.00
497	Таможенное оформление	Оформление документов на таможне	25000.00
498	Техосмотр	Проведение технического осмотра	5000.00
499	Страхование	Страхование автомобиля при транспортировке	15000.00
500	Постановка на учет	Регистрация в ГИБДД	8000.00
501	Транспортировка	Доставка автомобиля из Европы	80000.00
502	Таможенное оформление	Оформление документов на таможне	25000.00
503	Техосмотр	Проведение технического осмотра	5000.00
504	Страхование	Страхование автомобиля при транспортировке	15000.00
505	Постановка на учет	Регистрация в ГИБДД	8000.00
506	Транспортировка	Доставка автомобиля из Европы	80000.00
507	Таможенное оформление	Оформление документов на таможне	25000.00
508	Техосмотр	Проведение технического осмотра	5000.00
509	Страхование	Страхование автомобиля при транспортировке	15000.00
510	Постановка на учет	Регистрация в ГИБДД	8000.00
511	Транспортировка	Доставка автомобиля из Европы	80000.00
512	Таможенное оформление	Оформление документов на таможне	25000.00
513	Техосмотр	Проведение технического осмотра	5000.00
514	Страхование	Страхование автомобиля при транспортировке	15000.00
515	Постановка на учет	Регистрация в ГИБДД	8000.00
516	Транспортировка	Доставка автомобиля из Европы	80000.00
517	Таможенное оформление	Оформление документов на таможне	25000.00
518	Техосмотр	Проведение технического осмотра	5000.00
519	Страхование	Страхование автомобиля при транспортировке	15000.00
520	Постановка на учет	Регистрация в ГИБДД	8000.00
521	Транспортировка	Доставка автомобиля из Европы	80000.00
522	Таможенное оформление	Оформление документов на таможне	25000.00
523	Техосмотр	Проведение технического осмотра	5000.00
524	Страхование	Страхование автомобиля при транспортировке	15000.00
525	Постановка на учет	Регистрация в ГИБДД	8000.00
526	Транспортировка	Доставка автомобиля из Европы	80000.00
527	Таможенное оформление	Оформление документов на таможне	25000.00
528	Техосмотр	Проведение технического осмотра	5000.00
529	Страхование	Страхование автомобиля при транспортировке	15000.00
530	Постановка на учет	Регистрация в ГИБДД	8000.00
531	Транспортировка	Доставка автомобиля из Европы	80000.00
532	Таможенное оформление	Оформление документов на таможне	25000.00
533	Техосмотр	Проведение технического осмотра	5000.00
534	Страхование	Страхование автомобиля при транспортировке	15000.00
535	Постановка на учет	Регистрация в ГИБДД	8000.00
536	Транспортировка	Доставка автомобиля из Европы	80000.00
537	Таможенное оформление	Оформление документов на таможне	25000.00
538	Техосмотр	Проведение технического осмотра	5000.00
539	Страхование	Страхование автомобиля при транспортировке	15000.00
540	Постановка на учет	Регистрация в ГИБДД	8000.00
\.


--
-- TOC entry 3671 (class 0 OID 18286)
-- Dependencies: 220
-- Data for Name: suppliers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.suppliers (supplier_id, company_name, country, city, address, contact_person, phone, email) FROM stdin;
25261	Ford Франкфурт GmbH	Германия	Франкфурт	Street 63, 47463 Франкфурт	Ольга Фёдоров	+32-477-4782661	sales@франкфурт-auto1.com
25262	Renault Ницца GmbH	Франция	Ницца	Street 181, 68595 Ницца	Михаил Морозов	+39-567-3448895	sales@ницца-auto2.com
25263	Volkswagen Гамбург GmbH	Германия	Гамбург	Street 189, 26706 Гамбург	Марина Волков	+37-969-6099882	sales@гамбург-auto3.com
25264	Porsche Мюнхен GmbH	Германия	Мюнхен	Street 53, 39057 Мюнхен	Марина Козлов	+45-929-3818546	sales@мюнхен-auto4.com
25265	BMW Штутгарт GmbH	Германия	Штутгарт	Street 41, 62398 Штутгарт	Алексей Соколов	+32-985-2807969	sales@штутгарт-auto5.com
25266	BMW Рим GmbH	Италия	Рим	Street 72, 98483 Рим	Дмитрий Морозов	+40-679-5262156	sales@рим-auto6.com
25267	Porsche Ницца GmbH	Франция	Ницца	Street 188, 71131 Ницца	Ирина Лебедев	+34-856-4542893	sales@ницца-auto7.com
25268	Mercedes-Benz Гамбург GmbH	Германия	Гамбург	Street 35, 10153 Гамбург	Марина Попов	+49-484-2252375	sales@гамбург-auto8.com
25269	Renault Валенсия GmbH	Испания	Валенсия	Street 129, 84505 Валенсия	Ольга Иванов	+47-566-7696905	sales@валенсия-auto9.com
25270	Mercedes-Benz Ницца GmbH	Франция	Ницца	Street 77, 94473 Ницца	Алексей Попов	+49-969-4544207	sales@ницца-auto10.com
25271	Ford Барселона GmbH	Испания	Барселона	Street 114, 10069 Барселона	Сергей Михайлов	+38-413-8011434	sales@барселона-auto11.com
25272	Porsche Берлин GmbH	Германия	Берлин	Street 139, 26673 Берлин	Михаил Волков	+41-727-9090942	sales@берлин-auto12.com
25273	Renault Ницца GmbH	Франция	Ницца	Street 147, 67735 Ницца	Михаил Соколов	+39-223-8090652	sales@ницца-auto13.com
25274	Porsche Флоренция GmbH	Италия	Флоренция	Street 138, 35293 Флоренция	Елена Волков	+41-840-9466646	sales@флоренция-auto14.com
25275	Mercedes-Benz Ницца GmbH	Франция	Ницца	Street 170, 90835 Ницца	Владимир Петров	+41-997-3822362	sales@ницца-auto15.com
25276	Opel Мюнхен GmbH	Германия	Мюнхен	Street 185, 40975 Мюнхен	Михаил Новиков	+42-675-9131389	sales@мюнхен-auto16.com
25277	Ford Рим GmbH	Италия	Рим	Street 141, 26383 Рим	Алексей Сидоров	+40-727-6238740	sales@рим-auto17.com
25278	Ford Ницца GmbH	Франция	Ницца	Street 73, 85635 Ницца	Дмитрий Смирнов	+30-303-6600705	sales@ницца-auto18.com
25279	Volkswagen Рим GmbH	Италия	Рим	Street 3, 66503 Рим	Марина Петров	+42-542-5730198	sales@рим-auto19.com
25280	Renault Бильбао GmbH	Испания	Бильбао	Street 32, 13274 Бильбао	Марина Фёдоров	+45-335-6912729	sales@бильбао-auto20.com
25281	Ford Лион GmbH	Франция	Лион	Street 118, 71392 Лион	Сергей Иванов	+38-714-3327846	sales@лион-auto21.com
25282	Volkswagen Милан GmbH	Италия	Милан	Street 189, 93339 Милан	Игорь Кузнецов	+43-200-6525162	sales@милан-auto22.com
25283	Opel Валенсия GmbH	Испания	Валенсия	Street 95, 26880 Валенсия	Алексей Козлов	+45-822-5571489	sales@валенсия-auto23.com
25284	Audi Штутгарт GmbH	Германия	Штутгарт	Street 147, 81852 Штутгарт	Татьяна Козлов	+41-652-5017088	sales@штутгарт-auto24.com
25285	Porsche Лион GmbH	Франция	Лион	Street 100, 44748 Лион	Александр Петров	+37-854-1366442	sales@лион-auto25.com
25286	BMW Севилья GmbH	Испания	Севилья	Street 129, 25611 Севилья	Татьяна Попов	+39-160-1574332	sales@севилья-auto26.com
25287	BMW Берлин GmbH	Германия	Берлин	Street 30, 86711 Берлин	Ольга Морозов	+43-657-9340402	sales@берлин-auto27.com
25288	BMW Турин GmbH	Италия	Турин	Street 164, 48272 Турин	Елена Волков	+46-989-4408040	sales@турин-auto28.com
25289	Ford Мадрид GmbH	Испания	Мадрид	Street 101, 70315 Мадрид	Ирина Петров	+45-406-4765441	sales@мадрид-auto29.com
25290	Volkswagen Лион GmbH	Франция	Лион	Street 164, 78819 Лион	Марина Попов	+44-608-5268095	sales@лион-auto30.com
25291	Audi Мюнхен GmbH	Германия	Мюнхен	Street 9, 20453 Мюнхен	Сергей Волков	+49-737-2512428	sales@мюнхен-auto31.com
25292	BMW Милан GmbH	Италия	Милан	Street 187, 69204 Милан	Марина Смирнов	+40-207-3755725	sales@милан-auto32.com
25293	Renault Франкфурт GmbH	Германия	Франкфурт	Street 116, 19598 Франкфурт	Михаил Волков	+41-716-8395095	sales@франкфурт-auto33.com
25294	Porsche Лион GmbH	Франция	Лион	Street 126, 73650 Лион	Владимир Михайлов	+48-263-9610548	sales@лион-auto34.com
25295	Audi Берлин GmbH	Германия	Берлин	Street 79, 19851 Берлин	Алексей Фёдоров	+35-511-3720451	sales@берлин-auto35.com
25296	Opel Штутгарт GmbH	Германия	Штутгарт	Street 184, 42174 Штутгарт	Алексей Козлов	+39-345-7866995	sales@штутгарт-auto36.com
25297	Ford Тулуза GmbH	Франция	Тулуза	Street 16, 83649 Тулуза	Игорь Волков	+46-644-4246600	sales@тулуза-auto37.com
25298	BMW Франкфурт GmbH	Германия	Франкфурт	Street 94, 61066 Франкфурт	Алексей Михайлов	+38-449-4297678	sales@франкфурт-auto38.com
25299	Ford Милан GmbH	Италия	Милан	Street 31, 23027 Милан	Анна Козлов	+41-179-4307010	sales@милан-auto39.com
25300	Audi Париж GmbH	Франция	Париж	Street 103, 78822 Париж	Наталья Петров	+31-155-4568570	sales@париж-auto40.com
25301	Porsche Рим GmbH	Италия	Рим	Street 43, 79587 Рим	Наталья Лебедев	+43-650-1200615	sales@рим-auto41.com
25302	Ford Тулуза GmbH	Франция	Тулуза	Street 178, 26380 Тулуза	Анна Кузнецов	+35-230-5141904	sales@тулуза-auto42.com
25303	Renault Флоренция GmbH	Италия	Флоренция	Street 138, 54978 Флоренция	Александр Морозов	+33-474-4163822	sales@флоренция-auto43.com
25304	Volkswagen Мадрид GmbH	Испания	Мадрид	Street 89, 22788 Мадрид	Алексей Соколов	+31-310-5752436	sales@мадрид-auto44.com
25305	Audi Турин GmbH	Италия	Турин	Street 34, 82080 Турин	Елена Смирнов	+47-888-2531452	sales@турин-auto45.com
25306	BMW Бильбао GmbH	Испания	Бильбао	Street 114, 68512 Бильбао	Владимир Смирнов	+46-205-5022460	sales@бильбао-auto46.com
25307	Audi Лион GmbH	Франция	Лион	Street 169, 26594 Лион	Наталья Козлов	+42-479-5836186	sales@лион-auto47.com
25308	Volkswagen Лион GmbH	Франция	Лион	Street 119, 64864 Лион	Дмитрий Волков	+37-116-2881079	sales@лион-auto48.com
25309	Mercedes-Benz Флоренция GmbH	Италия	Флоренция	Street 170, 54218 Флоренция	Игорь Морозов	+35-220-9488098	sales@флоренция-auto49.com
25310	Opel Мадрид GmbH	Испания	Мадрид	Street 90, 23641 Мадрид	Сергей Соколов	+42-729-2906576	sales@мадрид-auto50.com
25311	Opel Лион GmbH	Франция	Лион	Street 9, 96143 Лион	Ирина Попов	+45-186-2130781	sales@лион-auto51.com
25312	Mercedes-Benz Штутгарт GmbH	Германия	Штутгарт	Street 124, 51330 Штутгарт	Ирина Кузнецов	+36-472-5999698	sales@штутгарт-auto52.com
25313	Ford Милан GmbH	Италия	Милан	Street 4, 46495 Милан	Алексей Михайлов	+42-688-1313595	sales@милан-auto53.com
25314	Volkswagen Мадрид GmbH	Испания	Мадрид	Street 106, 88074 Мадрид	Елена Иванов	+39-974-6146495	sales@мадрид-auto54.com
25315	Audi Севилья GmbH	Испания	Севилья	Street 163, 55566 Севилья	Александр Петров	+48-475-9810775	sales@севилья-auto55.com
25316	Ford Севилья GmbH	Испания	Севилья	Street 104, 71597 Севилья	Марина Михайлов	+33-309-6258235	sales@севилья-auto56.com
25317	Ford Турин GmbH	Италия	Турин	Street 118, 61198 Турин	Марина Михайлов	+34-297-2751076	sales@турин-auto57.com
25318	Porsche Париж GmbH	Франция	Париж	Street 56, 21409 Париж	Алексей Лебедев	+48-361-7846145	sales@париж-auto58.com
25319	Ford Рим GmbH	Италия	Рим	Street 71, 68447 Рим	Татьяна Морозов	+35-956-6333644	sales@рим-auto59.com
25320	Ford Франкфурт GmbH	Германия	Франкфурт	Street 22, 55102 Франкфурт	Ольга Попов	+37-839-9565925	sales@франкфурт-auto60.com
25321	Ford Марсель GmbH	Франция	Марсель	Street 101, 64687 Марсель	Алексей Петров	+34-142-3162723	sales@марсель-auto61.com
25322	Volkswagen Марсель GmbH	Франция	Марсель	Street 180, 70007 Марсель	Анна Морозов	+42-936-9864349	sales@марсель-auto62.com
25323	BMW Рим GmbH	Италия	Рим	Street 9, 10421 Рим	Дмитрий Морозов	+32-396-4714346	sales@рим-auto63.com
25324	BMW Франкфурт GmbH	Германия	Франкфурт	Street 29, 52381 Франкфурт	Игорь Козлов	+47-284-5917329	sales@франкфурт-auto64.com
25325	Renault Севилья GmbH	Испания	Севилья	Street 139, 46761 Севилья	Алексей Сидоров	+30-440-7848464	sales@севилья-auto65.com
25326	Mercedes-Benz Барселона GmbH	Испания	Барселона	Street 14, 77811 Барселона	Марина Козлов	+36-290-1546137	sales@барселона-auto66.com
25327	Renault Париж GmbH	Франция	Париж	Street 144, 37043 Париж	Татьяна Михайлов	+48-832-2908936	sales@париж-auto67.com
25328	BMW Барселона GmbH	Испания	Барселона	Street 32, 64709 Барселона	Наталья Смирнов	+44-463-4163032	sales@барселона-auto68.com
25329	BMW Мюнхен GmbH	Германия	Мюнхен	Street 182, 99386 Мюнхен	Татьяна Сидоров	+35-784-7971064	sales@мюнхен-auto69.com
25330	Mercedes-Benz Севилья GmbH	Испания	Севилья	Street 50, 23507 Севилья	Ирина Соколов	+32-546-7259569	sales@севилья-auto70.com
25331	Renault Гамбург GmbH	Германия	Гамбург	Street 39, 46007 Гамбург	Елена Михайлов	+43-543-2763117	sales@гамбург-auto71.com
25332	Ford Берлин GmbH	Германия	Берлин	Street 147, 82978 Берлин	Ирина Иванов	+43-394-3867689	sales@берлин-auto72.com
25333	Ford Париж GmbH	Франция	Париж	Street 144, 31338 Париж	Александр Фёдоров	+33-504-5837605	sales@париж-auto73.com
25334	Audi Турин GmbH	Италия	Турин	Street 24, 67709 Турин	Анна Соколов	+33-784-4017946	sales@турин-auto74.com
25335	Renault Париж GmbH	Франция	Париж	Street 69, 66642 Париж	Александр Морозов	+31-200-5057700	sales@париж-auto75.com
25336	Volkswagen Турин GmbH	Италия	Турин	Street 77, 97236 Турин	Игорь Петров	+46-810-8509313	sales@турин-auto76.com
25337	BMW Турин GmbH	Италия	Турин	Street 39, 89106 Турин	Алексей Кузнецов	+47-571-2862468	sales@турин-auto77.com
25338	Porsche Лион GmbH	Франция	Лион	Street 24, 17429 Лион	Ольга Новиков	+33-921-7913845	sales@лион-auto78.com
25339	Opel Тулуза GmbH	Франция	Тулуза	Street 69, 73891 Тулуза	Ирина Сидоров	+48-493-2966138	sales@тулуза-auto79.com
25340	Volkswagen Тулуза GmbH	Франция	Тулуза	Street 15, 24266 Тулуза	Ольга Кузнецов	+45-703-7263493	sales@тулуза-auto80.com
25341	Opel Гамбург GmbH	Германия	Гамбург	Street 49, 72122 Гамбург	Сергей Фёдоров	+39-707-1556839	sales@гамбург-auto81.com
25342	Audi Берлин GmbH	Германия	Берлин	Street 196, 83142 Берлин	Татьяна Новиков	+43-321-8128938	sales@берлин-auto82.com
25343	Volkswagen Бильбао GmbH	Испания	Бильбао	Street 72, 44594 Бильбао	Александр Иванов	+41-267-1012833	sales@бильбао-auto83.com
25344	Opel Валенсия GmbH	Испания	Валенсия	Street 113, 99050 Валенсия	Дмитрий Лебедев	+38-584-9462128	sales@валенсия-auto84.com
25345	Opel Гамбург GmbH	Германия	Гамбург	Street 159, 34885 Гамбург	Марина Кузнецов	+36-305-9452428	sales@гамбург-auto85.com
25346	Volkswagen Турин GmbH	Италия	Турин	Street 139, 17831 Турин	Сергей Попов	+32-591-6092093	sales@турин-auto86.com
25347	Volkswagen Тулуза GmbH	Франция	Тулуза	Street 150, 29395 Тулуза	Дмитрий Сидоров	+40-741-8242536	sales@тулуза-auto87.com
25348	Opel Бильбао GmbH	Испания	Бильбао	Street 61, 82658 Бильбао	Александр Иванов	+45-598-9433065	sales@бильбао-auto88.com
25349	BMW Марсель GmbH	Франция	Марсель	Street 182, 79425 Марсель	Игорь Соколов	+36-210-5794012	sales@марсель-auto89.com
25350	BMW Барселона GmbH	Испания	Барселона	Street 170, 23362 Барселона	Александр Петров	+49-193-7281529	sales@барселона-auto90.com
25351	Opel Валенсия GmbH	Испания	Валенсия	Street 51, 29714 Валенсия	Ирина Петров	+42-782-9947494	sales@валенсия-auto91.com
25352	BMW Валенсия GmbH	Испания	Валенсия	Street 165, 48977 Валенсия	Татьяна Смирнов	+38-567-6603671	sales@валенсия-auto92.com
25353	Renault Париж GmbH	Франция	Париж	Street 41, 80804 Париж	Игорь Лебедев	+45-973-1612735	sales@париж-auto93.com
25354	Audi Мюнхен GmbH	Германия	Мюнхен	Street 80, 21364 Мюнхен	Александр Новиков	+43-755-2134770	sales@мюнхен-auto94.com
25355	BMW Валенсия GmbH	Испания	Валенсия	Street 2, 78673 Валенсия	Дмитрий Лебедев	+31-596-8435830	sales@валенсия-auto95.com
25356	BMW Севилья GmbH	Испания	Севилья	Street 88, 20015 Севилья	Наталья Морозов	+33-123-4985085	sales@севилья-auto96.com
25357	Opel Ницца GmbH	Франция	Ницца	Street 131, 21114 Ницца	Анна Петров	+37-111-5190142	sales@ницца-auto97.com
25358	Audi Лион GmbH	Франция	Лион	Street 118, 29258 Лион	Елена Козлов	+39-312-2317761	sales@лион-auto98.com
25359	Opel Гамбург GmbH	Германия	Гамбург	Street 38, 74629 Гамбург	Ольга Попов	+35-238-6272364	sales@гамбург-auto99.com
25360	Volkswagen Барселона GmbH	Испания	Барселона	Street 136, 30957 Барселона	Ирина Соколов	+38-952-7767943	sales@барселона-auto100.com
25361	Volkswagen Рим GmbH	Италия	Рим	Street 61, 40873 Рим	Игорь Сидоров	+33-363-9293573	sales@рим-auto101.com
25362	Mercedes-Benz Рим GmbH	Италия	Рим	Street 199, 50185 Рим	Дмитрий Фёдоров	+38-954-4940992	sales@рим-auto102.com
25363	Porsche Франкфурт GmbH	Германия	Франкфурт	Street 75, 60054 Франкфурт	Алексей Козлов	+39-746-7540485	sales@франкфурт-auto103.com
25364	Porsche Неаполь GmbH	Италия	Неаполь	Street 29, 50869 Неаполь	Татьяна Иванов	+43-654-3655984	sales@неаполь-auto104.com
25365	Renault Флоренция GmbH	Италия	Флоренция	Street 120, 55031 Флоренция	Марина Петров	+38-728-1200413	sales@флоренция-auto105.com
25366	Volkswagen Барселона GmbH	Испания	Барселона	Street 34, 21174 Барселона	Михаил Иванов	+40-699-5220161	sales@барселона-auto106.com
25367	BMW Милан GmbH	Италия	Милан	Street 21, 77775 Милан	Игорь Соколов	+49-812-5054765	sales@милан-auto107.com
25368	BMW Мадрид GmbH	Испания	Мадрид	Street 111, 21970 Мадрид	Марина Иванов	+46-727-9803325	sales@мадрид-auto108.com
25369	Renault Севилья GmbH	Испания	Севилья	Street 125, 39467 Севилья	Алексей Соколов	+34-932-1903733	sales@севилья-auto109.com
25370	BMW Тулуза GmbH	Франция	Тулуза	Street 145, 34402 Тулуза	Дмитрий Петров	+46-191-2782929	sales@тулуза-auto110.com
25371	BMW Турин GmbH	Италия	Турин	Street 59, 37853 Турин	Ольга Михайлов	+33-183-4815987	sales@турин-auto111.com
25372	Mercedes-Benz Париж GmbH	Франция	Париж	Street 13, 60878 Париж	Ирина Попов	+32-265-5927174	sales@париж-auto112.com
25373	Audi Барселона GmbH	Испания	Барселона	Street 83, 47551 Барселона	Татьяна Кузнецов	+44-647-2026428	sales@барселона-auto113.com
25374	Porsche Мадрид GmbH	Испания	Мадрид	Street 123, 55129 Мадрид	Игорь Петров	+45-104-5313529	sales@мадрид-auto114.com
25375	BMW Рим GmbH	Италия	Рим	Street 28, 90799 Рим	Анна Новиков	+32-828-3207489	sales@рим-auto115.com
25376	Ford Валенсия GmbH	Испания	Валенсия	Street 176, 15391 Валенсия	Александр Смирнов	+35-804-8134852	sales@валенсия-auto116.com
25377	Renault Рим GmbH	Италия	Рим	Street 22, 27205 Рим	Анна Козлов	+43-523-8243435	sales@рим-auto117.com
25378	Renault Штутгарт GmbH	Германия	Штутгарт	Street 113, 70978 Штутгарт	Владимир Козлов	+48-212-1947400	sales@штутгарт-auto118.com
25379	Audi Барселона GmbH	Испания	Барселона	Street 38, 99747 Барселона	Наталья Иванов	+43-755-1007536	sales@барселона-auto119.com
25380	Mercedes-Benz Турин GmbH	Италия	Турин	Street 68, 18249 Турин	Алексей Лебедев	+46-315-3719697	sales@турин-auto120.com
25381	Ford Флоренция GmbH	Италия	Флоренция	Street 25, 95345 Флоренция	Ирина Волков	+35-617-8297246	sales@флоренция-auto121.com
25382	Ford Мадрид GmbH	Испания	Мадрид	Street 149, 92260 Мадрид	Александр Волков	+39-843-4475806	sales@мадрид-auto122.com
25383	Volkswagen Тулуза GmbH	Франция	Тулуза	Street 53, 35101 Тулуза	Александр Иванов	+30-326-9385532	sales@тулуза-auto123.com
25384	Mercedes-Benz Штутгарт GmbH	Германия	Штутгарт	Street 66, 43123 Штутгарт	Александр Морозов	+42-126-1789190	sales@штутгарт-auto124.com
25385	Renault Турин GmbH	Италия	Турин	Street 198, 49315 Турин	Татьяна Смирнов	+32-312-6533247	sales@турин-auto125.com
25386	Ford Тулуза GmbH	Франция	Тулуза	Street 37, 63414 Тулуза	Елена Петров	+35-145-7427478	sales@тулуза-auto126.com
25387	Opel Неаполь GmbH	Италия	Неаполь	Street 56, 85851 Неаполь	Татьяна Новиков	+32-606-9778855	sales@неаполь-auto127.com
25388	Ford Севилья GmbH	Испания	Севилья	Street 71, 29778 Севилья	Александр Новиков	+43-551-7377307	sales@севилья-auto128.com
25389	BMW Тулуза GmbH	Франция	Тулуза	Street 194, 73820 Тулуза	Владимир Фёдоров	+48-288-2976288	sales@тулуза-auto129.com
25390	Renault Марсель GmbH	Франция	Марсель	Street 84, 26074 Марсель	Анна Михайлов	+46-643-6198284	sales@марсель-auto130.com
25391	Ford Франкфурт GmbH	Германия	Франкфурт	Street 33, 92113 Франкфурт	Александр Сидоров	+39-447-2647848	sales@франкфурт-auto131.com
25392	Opel Берлин GmbH	Германия	Берлин	Street 127, 40458 Берлин	Михаил Фёдоров	+40-584-6088197	sales@берлин-auto132.com
25393	Renault Гамбург GmbH	Германия	Гамбург	Street 132, 70069 Гамбург	Александр Козлов	+46-497-7087865	sales@гамбург-auto133.com
25394	Mercedes-Benz Флоренция GmbH	Италия	Флоренция	Street 195, 68068 Флоренция	Михаил Фёдоров	+32-690-2308471	sales@флоренция-auto134.com
25395	Volkswagen Рим GmbH	Италия	Рим	Street 89, 50390 Рим	Татьяна Михайлов	+48-958-5100716	sales@рим-auto135.com
25396	Audi Турин GmbH	Италия	Турин	Street 18, 20326 Турин	Александр Козлов	+39-889-3073981	sales@турин-auto136.com
25397	Renault Бильбао GmbH	Испания	Бильбао	Street 182, 81389 Бильбао	Александр Михайлов	+35-386-7273969	sales@бильбао-auto137.com
25398	Opel Берлин GmbH	Германия	Берлин	Street 27, 95644 Берлин	Елена Волков	+43-432-5816167	sales@берлин-auto138.com
25399	Opel Гамбург GmbH	Германия	Гамбург	Street 71, 18050 Гамбург	Ольга Соколов	+31-816-2744624	sales@гамбург-auto139.com
25400	Audi Берлин GmbH	Германия	Берлин	Street 46, 82864 Берлин	Анна Соколов	+30-126-2127311	sales@берлин-auto140.com
25401	Volkswagen Барселона GmbH	Испания	Барселона	Street 84, 76211 Барселона	Марина Попов	+43-473-7845058	sales@барселона-auto141.com
25402	Mercedes-Benz Рим GmbH	Италия	Рим	Street 200, 38149 Рим	Ольга Сидоров	+37-150-7714788	sales@рим-auto142.com
25403	Ford Бильбао GmbH	Испания	Бильбао	Street 73, 73137 Бильбао	Дмитрий Михайлов	+42-710-8296971	sales@бильбао-auto143.com
25404	Mercedes-Benz Тулуза GmbH	Франция	Тулуза	Street 149, 60203 Тулуза	Марина Лебедев	+49-152-8899427	sales@тулуза-auto144.com
25405	BMW Лион GmbH	Франция	Лион	Street 35, 90032 Лион	Марина Лебедев	+45-923-5380041	sales@лион-auto145.com
25406	Audi Милан GmbH	Италия	Милан	Street 21, 15939 Милан	Анна Морозов	+49-798-9403107	sales@милан-auto146.com
25407	Mercedes-Benz Флоренция GmbH	Италия	Флоренция	Street 84, 24712 Флоренция	Игорь Михайлов	+47-366-6317263	sales@флоренция-auto147.com
25408	Renault Милан GmbH	Италия	Милан	Street 10, 73779 Милан	Наталья Иванов	+46-427-7074107	sales@милан-auto148.com
25409	Porsche Милан GmbH	Италия	Милан	Street 166, 79312 Милан	Дмитрий Морозов	+42-748-2606594	sales@милан-auto149.com
25410	Mercedes-Benz Милан GmbH	Италия	Милан	Street 189, 52930 Милан	Александр Петров	+44-471-5179301	sales@милан-auto150.com
25411	BMW Неаполь GmbH	Италия	Неаполь	Street 133, 11303 Неаполь	Елена Лебедев	+40-410-7575158	sales@неаполь-auto151.com
25412	Porsche Берлин GmbH	Германия	Берлин	Street 90, 46807 Берлин	Наталья Фёдоров	+31-824-8730875	sales@берлин-auto152.com
25413	Audi Неаполь GmbH	Италия	Неаполь	Street 149, 13535 Неаполь	Ольга Новиков	+31-710-4509151	sales@неаполь-auto153.com
25414	Mercedes-Benz Севилья GmbH	Испания	Севилья	Street 108, 77923 Севилья	Анна Новиков	+33-120-7678761	sales@севилья-auto154.com
25415	Ford Барселона GmbH	Испания	Барселона	Street 120, 19584 Барселона	Александр Морозов	+41-166-5211234	sales@барселона-auto155.com
25416	Renault Флоренция GmbH	Италия	Флоренция	Street 176, 47718 Флоренция	Дмитрий Сидоров	+34-960-2282476	sales@флоренция-auto156.com
25417	Mercedes-Benz Барселона GmbH	Испания	Барселона	Street 87, 97010 Барселона	Михаил Петров	+37-129-1812147	sales@барселона-auto157.com
25418	BMW Тулуза GmbH	Франция	Тулуза	Street 196, 67889 Тулуза	Михаил Иванов	+40-650-1235385	sales@тулуза-auto158.com
25419	Ford Марсель GmbH	Франция	Марсель	Street 48, 40964 Марсель	Михаил Кузнецов	+43-981-2111480	sales@марсель-auto159.com
25420	Renault Милан GmbH	Италия	Милан	Street 47, 90505 Милан	Алексей Смирнов	+45-454-7725264	sales@милан-auto160.com
25421	Audi Бильбао GmbH	Испания	Бильбао	Street 31, 40362 Бильбао	Дмитрий Морозов	+36-939-1056932	sales@бильбао-auto161.com
25422	Mercedes-Benz Париж GmbH	Франция	Париж	Street 98, 22568 Париж	Анна Сидоров	+45-479-6584071	sales@париж-auto162.com
25423	Volkswagen Ницца GmbH	Франция	Ницца	Street 68, 97172 Ницца	Татьяна Волков	+48-164-6286245	sales@ницца-auto163.com
25424	Mercedes-Benz Франкфурт GmbH	Германия	Франкфурт	Street 20, 35885 Франкфурт	Ольга Петров	+33-261-2202248	sales@франкфурт-auto164.com
25425	Renault Рим GmbH	Италия	Рим	Street 18, 81749 Рим	Дмитрий Смирнов	+30-536-5071766	sales@рим-auto165.com
25426	Opel Штутгарт GmbH	Германия	Штутгарт	Street 73, 13445 Штутгарт	Игорь Петров	+39-408-4430171	sales@штутгарт-auto166.com
25427	BMW Тулуза GmbH	Франция	Тулуза	Street 124, 90299 Тулуза	Сергей Кузнецов	+44-612-4668785	sales@тулуза-auto167.com
25428	Volkswagen Тулуза GmbH	Франция	Тулуза	Street 110, 30905 Тулуза	Ольга Соколов	+46-195-8398262	sales@тулуза-auto168.com
25429	Opel Рим GmbH	Италия	Рим	Street 3, 14299 Рим	Елена Лебедев	+48-543-1097618	sales@рим-auto169.com
25430	Porsche Флоренция GmbH	Италия	Флоренция	Street 155, 39572 Флоренция	Алексей Иванов	+42-730-8882303	sales@флоренция-auto170.com
25431	Mercedes-Benz Берлин GmbH	Германия	Берлин	Street 30, 44078 Берлин	Михаил Михайлов	+34-531-7839843	sales@берлин-auto171.com
25432	Ford Севилья GmbH	Испания	Севилья	Street 28, 52308 Севилья	Игорь Иванов	+42-412-1126897	sales@севилья-auto172.com
25433	Audi Марсель GmbH	Франция	Марсель	Street 57, 49446 Марсель	Наталья Волков	+40-428-8906126	sales@марсель-auto173.com
25434	Volkswagen Валенсия GmbH	Испания	Валенсия	Street 20, 58637 Валенсия	Ольга Иванов	+48-557-1640272	sales@валенсия-auto174.com
25435	Renault Лион GmbH	Франция	Лион	Street 31, 71890 Лион	Марина Морозов	+45-211-8177088	sales@лион-auto175.com
25436	Audi Валенсия GmbH	Испания	Валенсия	Street 87, 88280 Валенсия	Владимир Сидоров	+38-521-2178830	sales@валенсия-auto176.com
25437	Porsche Мюнхен GmbH	Германия	Мюнхен	Street 67, 48019 Мюнхен	Дмитрий Попов	+38-268-5337221	sales@мюнхен-auto177.com
25438	Mercedes-Benz Севилья GmbH	Испания	Севилья	Street 150, 35413 Севилья	Елена Михайлов	+39-641-4626305	sales@севилья-auto178.com
25439	Porsche Мадрид GmbH	Испания	Мадрид	Street 13, 62925 Мадрид	Александр Козлов	+46-901-4062440	sales@мадрид-auto179.com
25440	Volkswagen Гамбург GmbH	Германия	Гамбург	Street 63, 47448 Гамбург	Игорь Волков	+43-181-9940888	sales@гамбург-auto180.com
25441	Mercedes-Benz Париж GmbH	Франция	Париж	Street 129, 63593 Париж	Владимир Попов	+36-933-9925229	sales@париж-auto181.com
25442	Mercedes-Benz Турин GmbH	Италия	Турин	Street 125, 33888 Турин	Ольга Лебедев	+36-189-5448884	sales@турин-auto182.com
25443	Renault Флоренция GmbH	Италия	Флоренция	Street 127, 91513 Флоренция	Михаил Иванов	+45-899-2324194	sales@флоренция-auto183.com
25444	Audi Рим GmbH	Италия	Рим	Street 49, 81573 Рим	Дмитрий Сидоров	+42-560-9959036	sales@рим-auto184.com
25445	Renault Рим GmbH	Италия	Рим	Street 50, 46086 Рим	Анна Сидоров	+39-575-9479767	sales@рим-auto185.com
25446	Porsche Неаполь GmbH	Италия	Неаполь	Street 110, 45380 Неаполь	Ирина Морозов	+30-172-7489011	sales@неаполь-auto186.com
25447	Audi Лион GmbH	Франция	Лион	Street 150, 83439 Лион	Ирина Волков	+41-193-7272544	sales@лион-auto187.com
25448	Renault Лион GmbH	Франция	Лион	Street 173, 99156 Лион	Игорь Петров	+31-650-2546347	sales@лион-auto188.com
25449	Renault Милан GmbH	Италия	Милан	Street 107, 19897 Милан	Марина Лебедев	+48-361-1696429	sales@милан-auto189.com
25450	Volkswagen Франкфурт GmbH	Германия	Франкфурт	Street 47, 89062 Франкфурт	Михаил Михайлов	+37-550-1118376	sales@франкфурт-auto190.com
25451	Audi Мадрид GmbH	Испания	Мадрид	Street 45, 40970 Мадрид	Владимир Сидоров	+39-788-4081898	sales@мадрид-auto191.com
25452	Mercedes-Benz Париж GmbH	Франция	Париж	Street 25, 22885 Париж	Игорь Иванов	+47-877-7580150	sales@париж-auto192.com
25453	BMW Валенсия GmbH	Испания	Валенсия	Street 198, 45180 Валенсия	Владимир Петров	+49-353-5627865	sales@валенсия-auto193.com
25454	Ford Мадрид GmbH	Испания	Мадрид	Street 96, 69158 Мадрид	Елена Морозов	+37-120-3717448	sales@мадрид-auto194.com
25455	Mercedes-Benz Париж GmbH	Франция	Париж	Street 67, 36371 Париж	Сергей Лебедев	+42-458-5504688	sales@париж-auto195.com
25456	BMW Марсель GmbH	Франция	Марсель	Street 130, 22442 Марсель	Ирина Петров	+31-710-9062071	sales@марсель-auto196.com
25457	BMW Севилья GmbH	Испания	Севилья	Street 182, 16684 Севилья	Татьяна Козлов	+44-123-2842157	sales@севилья-auto197.com
25458	Renault Рим GmbH	Италия	Рим	Street 174, 18613 Рим	Игорь Соколов	+47-638-3881939	sales@рим-auto198.com
25459	Volkswagen Штутгарт GmbH	Германия	Штутгарт	Street 105, 51419 Штутгарт	Елена Смирнов	+44-687-1285895	sales@штутгарт-auto199.com
25460	Opel Турин GmbH	Италия	Турин	Street 13, 30339 Турин	Анна Михайлов	+32-791-4112672	sales@турин-auto200.com
25461	BMW Милан GmbH	Италия	Милан	Street 115, 51257 Милан	Игорь Сидоров	+36-789-3653385	sales@милан-auto201.com
25462	Mercedes-Benz Франкфурт GmbH	Германия	Франкфурт	Street 68, 22327 Франкфурт	Дмитрий Морозов	+34-359-8547150	sales@франкфурт-auto202.com
25463	Mercedes-Benz Севилья GmbH	Испания	Севилья	Street 118, 38077 Севилья	Александр Фёдоров	+38-523-5185318	sales@севилья-auto203.com
25464	Audi Гамбург GmbH	Германия	Гамбург	Street 67, 20208 Гамбург	Алексей Сидоров	+45-813-9442917	sales@гамбург-auto204.com
25465	Mercedes-Benz Франкфурт GmbH	Германия	Франкфурт	Street 188, 48612 Франкфурт	Ольга Иванов	+46-506-5252853	sales@франкфурт-auto205.com
25466	Opel Лион GmbH	Франция	Лион	Street 36, 49335 Лион	Ирина Новиков	+37-879-5612867	sales@лион-auto206.com
25467	Renault Марсель GmbH	Франция	Марсель	Street 68, 53708 Марсель	Владимир Козлов	+34-750-4426690	sales@марсель-auto207.com
25468	BMW Париж GmbH	Франция	Париж	Street 156, 11849 Париж	Владимир Козлов	+40-195-3091872	sales@париж-auto208.com
25469	Volkswagen Флоренция GmbH	Италия	Флоренция	Street 137, 50065 Флоренция	Марина Сидоров	+45-767-7906481	sales@флоренция-auto209.com
25470	Audi Гамбург GmbH	Германия	Гамбург	Street 199, 99825 Гамбург	Ольга Иванов	+46-707-4648863	sales@гамбург-auto210.com
25471	Volkswagen Лион GmbH	Франция	Лион	Street 187, 72283 Лион	Ольга Петров	+33-426-5956985	sales@лион-auto211.com
25472	Volkswagen Неаполь GmbH	Италия	Неаполь	Street 140, 59795 Неаполь	Татьяна Соколов	+39-294-4102905	sales@неаполь-auto212.com
25473	Mercedes-Benz Лион GmbH	Франция	Лион	Street 93, 42957 Лион	Ольга Сидоров	+48-315-2561225	sales@лион-auto213.com
25474	BMW Севилья GmbH	Испания	Севилья	Street 67, 35961 Севилья	Марина Иванов	+31-590-5418713	sales@севилья-auto214.com
25475	Renault Штутгарт GmbH	Германия	Штутгарт	Street 93, 22960 Штутгарт	Наталья Лебедев	+43-721-8274176	sales@штутгарт-auto215.com
25476	Mercedes-Benz Мадрид GmbH	Испания	Мадрид	Street 67, 28015 Мадрид	Ирина Волков	+43-902-5821061	sales@мадрид-auto216.com
25477	Opel Франкфурт GmbH	Германия	Франкфурт	Street 13, 56407 Франкфурт	Елена Соколов	+39-942-2403498	sales@франкфурт-auto217.com
25478	Renault Франкфурт GmbH	Германия	Франкфурт	Street 67, 58108 Франкфурт	Ольга Морозов	+48-154-9384269	sales@франкфурт-auto218.com
25479	Volkswagen Штутгарт GmbH	Германия	Штутгарт	Street 43, 25626 Штутгарт	Александр Волков	+35-731-2231391	sales@штутгарт-auto219.com
25480	BMW Турин GmbH	Италия	Турин	Street 54, 15958 Турин	Алексей Иванов	+43-998-9698742	sales@турин-auto220.com
25481	Renault Берлин GmbH	Германия	Берлин	Street 136, 39159 Берлин	Марина Козлов	+43-509-4939823	sales@берлин-auto221.com
25482	Audi Мюнхен GmbH	Германия	Мюнхен	Street 94, 20110 Мюнхен	Михаил Смирнов	+38-473-2204007	sales@мюнхен-auto222.com
25483	Audi Тулуза GmbH	Франция	Тулуза	Street 48, 24585 Тулуза	Елена Кузнецов	+40-238-5657492	sales@тулуза-auto223.com
25484	Volkswagen Мадрид GmbH	Испания	Мадрид	Street 33, 52705 Мадрид	Дмитрий Смирнов	+43-990-9358485	sales@мадрид-auto224.com
25485	Porsche Валенсия GmbH	Испания	Валенсия	Street 103, 30729 Валенсия	Игорь Михайлов	+36-951-4226904	sales@валенсия-auto225.com
25486	Volkswagen Флоренция GmbH	Италия	Флоренция	Street 179, 27470 Флоренция	Анна Новиков	+38-712-1012091	sales@флоренция-auto226.com
25487	Volkswagen Турин GmbH	Италия	Турин	Street 63, 98216 Турин	Михаил Соколов	+30-985-7586674	sales@турин-auto227.com
25488	BMW Мадрид GmbH	Испания	Мадрид	Street 62, 68946 Мадрид	Татьяна Лебедев	+39-650-4116022	sales@мадрид-auto228.com
25489	Mercedes-Benz Мадрид GmbH	Испания	Мадрид	Street 61, 29049 Мадрид	Михаил Козлов	+44-712-4290922	sales@мадрид-auto229.com
25490	Renault Турин GmbH	Италия	Турин	Street 140, 12369 Турин	Владимир Михайлов	+49-756-4900272	sales@турин-auto230.com
25491	Renault Лион GmbH	Франция	Лион	Street 178, 23422 Лион	Дмитрий Морозов	+32-671-3696434	sales@лион-auto231.com
25492	Opel Штутгарт GmbH	Германия	Штутгарт	Street 141, 61189 Штутгарт	Михаил Волков	+38-551-4991266	sales@штутгарт-auto232.com
25493	BMW Париж GmbH	Франция	Париж	Street 22, 67493 Париж	Игорь Петров	+33-426-2003222	sales@париж-auto233.com
25494	Renault Валенсия GmbH	Испания	Валенсия	Street 88, 83538 Валенсия	Дмитрий Волков	+35-117-2065295	sales@валенсия-auto234.com
25495	Ford Марсель GmbH	Франция	Марсель	Street 27, 54487 Марсель	Владимир Новиков	+39-539-3913877	sales@марсель-auto235.com
25496	Opel Барселона GmbH	Испания	Барселона	Street 184, 99527 Барселона	Елена Михайлов	+48-794-4842856	sales@барселона-auto236.com
25497	Opel Рим GmbH	Италия	Рим	Street 179, 70700 Рим	Владимир Козлов	+44-147-9052395	sales@рим-auto237.com
25498	Opel Франкфурт GmbH	Германия	Франкфурт	Street 45, 89334 Франкфурт	Анна Сидоров	+33-511-7125953	sales@франкфурт-auto238.com
25499	Ford Франкфурт GmbH	Германия	Франкфурт	Street 123, 92553 Франкфурт	Александр Кузнецов	+47-259-2963541	sales@франкфурт-auto239.com
25500	Porsche Неаполь GmbH	Италия	Неаполь	Street 6, 29885 Неаполь	Ирина Новиков	+39-735-1648058	sales@неаполь-auto240.com
25501	Mercedes-Benz Штутгарт GmbH	Германия	Штутгарт	Street 72, 31357 Штутгарт	Татьяна Морозов	+44-281-5822124	sales@штутгарт-auto241.com
25502	BMW Франкфурт GmbH	Германия	Франкфурт	Street 48, 71663 Франкфурт	Марина Козлов	+48-979-4388124	sales@франкфурт-auto242.com
25503	Renault Неаполь GmbH	Италия	Неаполь	Street 177, 19995 Неаполь	Елена Лебедев	+47-823-3253421	sales@неаполь-auto243.com
25504	Audi Франкфурт GmbH	Германия	Франкфурт	Street 129, 78432 Франкфурт	Анна Новиков	+37-104-7984232	sales@франкфурт-auto244.com
25505	Volkswagen Ницца GmbH	Франция	Ницца	Street 170, 77028 Ницца	Сергей Сидоров	+45-199-6685745	sales@ницца-auto245.com
25506	Porsche Гамбург GmbH	Германия	Гамбург	Street 98, 94924 Гамбург	Ирина Соколов	+47-276-3461194	sales@гамбург-auto246.com
25507	Volkswagen Валенсия GmbH	Испания	Валенсия	Street 80, 12919 Валенсия	Татьяна Лебедев	+49-928-9649829	sales@валенсия-auto247.com
25508	Volkswagen Берлин GmbH	Германия	Берлин	Street 148, 78469 Берлин	Анна Волков	+30-433-9275312	sales@берлин-auto248.com
25509	Opel Гамбург GmbH	Германия	Гамбург	Street 193, 72381 Гамбург	Марина Морозов	+37-836-3500769	sales@гамбург-auto249.com
25510	Volkswagen Штутгарт GmbH	Германия	Штутгарт	Street 7, 65596 Штутгарт	Михаил Попов	+34-909-6446972	sales@штутгарт-auto250.com
\.


--
-- TOC entry 3692 (class 0 OID 0)
-- Dependencies: 221
-- Name: cars_car_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cars_car_id_seq', 90873, true);


--
-- TOC entry 3693 (class 0 OID 0)
-- Dependencies: 225
-- Name: client_documents_document_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.client_documents_document_id_seq', 30526, true);


--
-- TOC entry 3694 (class 0 OID 0)
-- Dependencies: 217
-- Name: clients_client_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.clients_client_id_seq', 90824, true);


--
-- TOC entry 3695 (class 0 OID 0)
-- Dependencies: 223
-- Name: orders_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.orders_order_id_seq', 90927, true);


--
-- TOC entry 3696 (class 0 OID 0)
-- Dependencies: 227
-- Name: services_service_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.services_service_id_seq', 540, true);


--
-- TOC entry 3697 (class 0 OID 0)
-- Dependencies: 219
-- Name: suppliers_supplier_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.suppliers_supplier_id_seq', 25510, true);


--
-- TOC entry 3500 (class 2606 OID 18302)
-- Name: cars cars_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cars
    ADD CONSTRAINT cars_pkey PRIMARY KEY (car_id);


--
-- TOC entry 3502 (class 2606 OID 18304)
-- Name: cars cars_vin_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cars
    ADD CONSTRAINT cars_vin_key UNIQUE (vin);


--
-- TOC entry 3510 (class 2606 OID 18341)
-- Name: client_documents client_documents_client_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_documents
    ADD CONSTRAINT client_documents_client_id_key UNIQUE (client_id);


--
-- TOC entry 3512 (class 2606 OID 18339)
-- Name: client_documents client_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_documents
    ADD CONSTRAINT client_documents_pkey PRIMARY KEY (document_id);


--
-- TOC entry 3494 (class 2606 OID 18284)
-- Name: clients clients_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_email_key UNIQUE (email);


--
-- TOC entry 3496 (class 2606 OID 18282)
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (client_id);


--
-- TOC entry 3516 (class 2606 OID 18361)
-- Name: order_services order_services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_services
    ADD CONSTRAINT order_services_pkey PRIMARY KEY (order_id, service_id);


--
-- TOC entry 3508 (class 2606 OID 18319)
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- TOC entry 3514 (class 2606 OID 18355)
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (service_id);


--
-- TOC entry 3498 (class 2606 OID 18293)
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (supplier_id);


--
-- TOC entry 3503 (class 1259 OID 18374)
-- Name: idx_cars_supplier_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cars_supplier_id ON public.cars USING btree (supplier_id);


--
-- TOC entry 3504 (class 1259 OID 18373)
-- Name: idx_orders_car_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_car_id ON public.orders USING btree (car_id);


--
-- TOC entry 3505 (class 1259 OID 18372)
-- Name: idx_orders_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_client_id ON public.orders USING btree (client_id);


--
-- TOC entry 3506 (class 1259 OID 18375)
-- Name: idx_orders_order_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_order_date ON public.orders USING btree (order_date);


--
-- TOC entry 3517 (class 2606 OID 18305)
-- Name: cars cars_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cars
    ADD CONSTRAINT cars_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(supplier_id);


--
-- TOC entry 3520 (class 2606 OID 18342)
-- Name: client_documents client_documents_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_documents
    ADD CONSTRAINT client_documents_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(client_id);


--
-- TOC entry 3521 (class 2606 OID 18362)
-- Name: order_services order_services_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_services
    ADD CONSTRAINT order_services_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id);


--
-- TOC entry 3522 (class 2606 OID 18367)
-- Name: order_services order_services_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_services
    ADD CONSTRAINT order_services_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(service_id);


--
-- TOC entry 3518 (class 2606 OID 18325)
-- Name: orders orders_car_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_car_id_fkey FOREIGN KEY (car_id) REFERENCES public.cars(car_id);


--
-- TOC entry 3519 (class 2606 OID 18320)
-- Name: orders orders_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(client_id);


-- Completed on 2025-10-01 03:57:31 MSK

--
-- PostgreSQL database dump complete
--

