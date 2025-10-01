--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

-- Started on 2025-09-16 16:12:11 MSK

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
159	EKE8Y3S08E6H9821J	Audi	Q5	2021	2.6	Электро	Робот	Серый	120188	67990.04	59
160	PEH0RH5HJPWEVY1TV	Opel	Model	2016	1.1	Дизель	Робот	Синий	105751	56771.15	56
161	CYWBFAD74ERGCBD4T	Ford	Model	2015	3.3	Дизель	Механика	Белый	59923	86977.12	57
162	0Y9EXPXB6Y0Y3CMT6	Volkswagen	Passat	2021	3.4	Электро	Механика	Красный	119479	83230.75	58
163	JGHV2DBMCXJ97WM0H	Opel	Model	2017	2.8	Гибрид	Робот	Коричневый	64604	41578.50	59
164	RPTKSE1W3AYWU9FD5	Mercedes-Benz	A-Class	2018	3.9	Электро	Автомат	Зеленый	59010	66955.69	57
165	20ZLH9JUBLRUKM6TD	Opel	Model	2016	1.3	Гибрид	Автомат	Красный	139051	67242.47	60
166	CU6TJZCAWFPF2WNSA	Opel	Model	2024	3.4	Электро	Механика	Черный	132012	17408.66	60
167	CPLHNHB0EXZRWCUGJ	Volkswagen	Passat	2021	3.6	Электро	Вариатор	Красный	36782	26286.39	59
168	3EHZJWJ8N7J9CBLS1	BMW	X5	2017	3.6	Дизель	Механика	Коричневый	86399	19660.95	60
169	1TT6NPTF5E9CMZJ1R	Ford	Model	2022	2.7	Гибрид	Робот	Коричневый	71455	40945.04	59
170	WZYTSFB8T59W70842	Porsche	Cayenne	2021	3.5	Бензин	Вариатор	Красный	51580	91244.65	56
171	GUKHGCL9U6PA3RKWS	Audi	A6	2017	2.0	Электро	Механика	Серебристый	88450	57946.53	60
172	LGELSTHCCRYHTED7W	Renault	Model	2024	3.2	Дизель	Механика	Красный	112251	43567.07	56
173	10PNTLR9H9NZ1VFG1	Audi	A4	2023	3.7	Бензин	Автомат	Синий	65254	61017.89	60
\.


--
-- TOC entry 3677 (class 0 OID 18331)
-- Dependencies: 226
-- Data for Name: client_documents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.client_documents (document_id, client_id, passport_scan_path, driver_license_path, additional_docs_path, upload_date) FROM stdin;
70	108	/docs/passports/client_108_passport.pdf	/docs/licenses/client_108_license.pdf	\N	2025-09-16
71	116	/docs/passports/client_116_passport.pdf	/docs/licenses/client_116_license.pdf	\N	2025-09-16
72	109	/docs/passports/client_109_passport.pdf	/docs/licenses/client_109_license.pdf	/docs/additional/client_109_additional.pdf	2025-09-16
73	112	/docs/passports/client_112_passport.pdf	/docs/licenses/client_112_license.pdf	\N	2025-09-16
74	113	/docs/passports/client_113_passport.pdf	/docs/licenses/client_113_license.pdf	/docs/additional/client_113_additional.pdf	2025-09-16
75	117	/docs/passports/client_117_passport.pdf	/docs/licenses/client_117_license.pdf	/docs/additional/client_117_additional.pdf	2025-09-16
76	115	/docs/passports/client_115_passport.pdf	/docs/licenses/client_115_license.pdf	/docs/additional/client_115_additional.pdf	2025-09-16
\.


--
-- TOC entry 3669 (class 0 OID 18276)
-- Dependencies: 218
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.clients (client_id, first_name, last_name, phone, email, passport_series, passport_number, registration_date, birth_date) FROM stdin;
108	Наталья	Соколов	+7-996-393-14-36	наталья.соколов1@email.ru	4527	413511	2025-09-16	1997-01-06
109	Наталья	Смирнов	+7-975-623-58-96	наталья.смирнов2@email.ru	4555	541110	2025-09-16	1976-03-14
110	Владимир	Михайлов	+7-913-954-12-58	владимир.михайлов3@email.ru	4520	202559	2025-09-16	1978-12-05
111	Ирина	Иванов	+7-940-537-90-97	ирина.иванов4@email.ru	4562	708683	2025-09-16	1974-03-21
112	Дмитрий	Соколов	+7-917-342-59-30	дмитрий.соколов5@email.ru	4538	121238	2025-09-16	1962-02-23
113	Сергей	Смирнов	+7-986-598-92-59	сергей.смирнов6@email.ru	4576	637519	2025-09-16	1975-04-27
114	Анна	Морозов	+7-998-406-57-50	анна.морозов7@email.ru	4577	605077	2025-09-16	2003-02-21
115	Михаил	Михайлов	+7-925-412-52-30	михаил.михайлов8@email.ru	4593	960249	2025-09-16	1955-10-05
116	Владимир	Кузнецов	+7-991-845-46-69	владимир.кузнецов9@email.ru	4557	394745	2025-09-16	1972-06-08
117	Наталья	Соколов	+7-969-616-43-66	наталья.соколов10@email.ru	4544	731594	2025-09-16	1958-08-26
\.


--
-- TOC entry 3680 (class 0 OID 18356)
-- Dependencies: 229
-- Data for Name: order_services; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_services (order_id, service_id, quantity, price_rub) FROM stdin;
208	25	1	37912.57
208	63	1	49840.62
208	1	1	16418.09
208	59	2	83488.09
209	56	2	26518.54
209	18	1	21668.18
209	37	2	57523.56
209	94	1	47796.52
209	74	1	8059.68
210	108	1	80379.80
210	96	2	103377.40
210	49	1	29932.21
211	72	1	98079.46
211	47	1	107327.28
212	53	1	40051.90
212	69	2	47185.03
212	109	2	86706.12
213	48	1	40623.39
213	36	2	38979.67
213	81	1	31001.01
213	77	2	8766.22
214	90	1	90162.85
214	14	1	18092.92
214	34	1	114943.57
215	95	1	86778.77
215	109	1	84142.37
216	15	1	10746.58
216	23	2	105478.00
216	13	1	56742.44
217	15	2	70558.63
217	33	1	59780.94
218	69	1	43586.35
218	84	1	104919.16
218	71	1	29576.63
219	83	2	38810.40
219	6	1	96349.52
219	80	1	108790.33
219	77	2	11030.78
220	13	1	69823.31
220	34	2	95071.43
220	14	2	107823.96
220	60	1	108994.17
221	76	2	103252.30
221	58	1	103405.27
222	95	1	81510.32
222	77	2	30190.88
222	22	2	5774.19
222	58	1	16414.54
223	48	1	56200.44
223	89	1	37125.57
223	88	2	46923.56
223	95	1	24652.79
224	96	1	34436.18
224	83	2	119440.97
224	2	1	58365.23
225	61	1	110260.58
225	90	2	82554.79
225	102	2	14199.36
226	77	2	16758.60
226	37	2	58130.20
227	52	1	41529.76
227	28	1	11488.04
227	14	1	53212.61
227	22	2	43350.86
227	95	2	84691.28
\.


--
-- TOC entry 3675 (class 0 OID 18311)
-- Dependencies: 224
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.orders (order_id, client_id, car_id, order_date, expected_delivery_date, actual_delivery_date, total_cost_rub, status, customs_cleared) FROM stdin;
208	112	165	2024-09-30	2024-11-16	2024-11-16	6138382.25	Ожидает оплаты	t
209	116	165	2024-11-06	2024-12-23	\N	4461230.65	В пути	t
210	109	162	2025-03-27	2025-05-18	\N	6045983.47	Ожидает оплаты	t
211	114	166	2025-07-14	2025-08-16	2025-08-16	4750696.17	Таможенное оформление	t
212	110	173	2024-11-14	2025-01-01	\N	6581783.44	В обработке	t
213	115	169	2024-12-16	2025-01-26	2025-01-26	5065855.35	Таможенное оформление	t
214	114	162	2025-06-30	2025-07-30	2025-07-30	5779239.14	Таможенное оформление	t
215	109	164	2025-04-04	2025-06-02	\N	4319264.55	Доставлен	t
216	117	161	2025-01-25	2025-03-09	2025-03-09	4559585.34	Доставлен	f
217	114	160	2025-07-17	2025-09-12	\N	5411702.57	В обработке	t
218	113	161	2025-06-01	2025-07-28	2025-07-28	4497836.88	Таможенное оформление	f
219	111	170	2025-06-06	2025-07-16	\N	5677238.89	В обработке	t
220	111	161	2025-07-03	2025-08-20	2025-08-20	6709803.89	Доставлен	t
221	116	171	2024-10-01	2024-11-20	\N	7636894.78	Таможенное оформление	t
222	108	163	2025-03-31	2025-05-02	2025-05-02	5177893.08	Ожидает оплаты	f
223	112	169	2025-04-01	2025-05-29	\N	7837235.87	В пути	t
224	115	163	2024-10-26	2024-12-20	2024-12-20	5989371.55	Доставлен	t
225	113	160	2025-02-28	2025-04-11	\N	2119294.87	Ожидает оплаты	f
226	115	160	2025-05-17	2025-06-23	\N	3348363.51	Таможенное оформление	t
227	115	168	2025-06-23	2025-08-22	\N	5847958.42	В пути	f
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
\.


--
-- TOC entry 3671 (class 0 OID 18286)
-- Dependencies: 220
-- Data for Name: suppliers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.suppliers (supplier_id, company_name, country, city, address, contact_person, phone, email) FROM stdin;
56	Renault Бильбао GmbH	Испания	Бильбао	Street 61, 77403 Бильбао	Ирина Сидоров	+33-334-3164666	sales@бильбао-auto1.com
57	Mercedes-Benz Бильбао GmbH	Испания	Бильбао	Street 181, 45223 Бильбао	Алексей Соколов	+42-793-1864293	sales@бильбао-auto2.com
58	Audi Париж GmbH	Франция	Париж	Street 142, 17904 Париж	Ирина Попов	+32-111-4383452	sales@париж-auto3.com
59	Ford Неаполь GmbH	Италия	Неаполь	Street 22, 47291 Неаполь	Михаил Морозов	+41-673-9787756	sales@неаполь-auto4.com
60	BMW Валенсия GmbH	Испания	Валенсия	Street 73, 92782 Валенсия	Сергей Михайлов	+31-896-5034469	sales@валенсия-auto5.com
\.


--
-- TOC entry 3692 (class 0 OID 0)
-- Dependencies: 221
-- Name: cars_car_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cars_car_id_seq', 173, true);


--
-- TOC entry 3693 (class 0 OID 0)
-- Dependencies: 225
-- Name: client_documents_document_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.client_documents_document_id_seq', 76, true);


--
-- TOC entry 3694 (class 0 OID 0)
-- Dependencies: 217
-- Name: clients_client_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.clients_client_id_seq', 117, true);


--
-- TOC entry 3695 (class 0 OID 0)
-- Dependencies: 223
-- Name: orders_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.orders_order_id_seq', 227, true);


--
-- TOC entry 3696 (class 0 OID 0)
-- Dependencies: 227
-- Name: services_service_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.services_service_id_seq', 110, true);


--
-- TOC entry 3697 (class 0 OID 0)
-- Dependencies: 219
-- Name: suppliers_supplier_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.suppliers_supplier_id_seq', 60, true);


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


-- Completed on 2025-09-16 16:12:11 MSK

--
-- PostgreSQL database dump complete
--

