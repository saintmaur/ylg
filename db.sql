SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 3314 (class 1262 OID 60082)
-- Name: ylgdev; Type: DATABASE; Schema: -; Owner: postgres
--
CREATE DATABASE ylg_new WITH OWNER ylg ENCODING = 'UTF8';

\connect ylg_new


CREATE TABLE reasons (
    id serial NOT NULL,
    name integer,
    constraint reasons_pkey primary key (id)
);

ALTER TABLE reasons OWNER TO ylg;


--
