SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 3314 (class 1262 OID 60082)
-- Name: ylgdev; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE ylg_new WITH OWNER ylg ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';

\connect ylg_new

CREATE TABLE users (
    id serial NOT NULL,
    email character varying(50),
    passwd character varying(32),
    name character varying(50),
    surname character varying(50),
    constraint users_pkey primary key (id)
);

ALTER TABLE users OWNER TO ylg;

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE reasons (
    id serial NOT NULL,
    name integer,
    constraint reasons_pkey primary key (id)
);

ALTER TABLE reasons OWNER TO ylg;

CREATE SEQUENCE reasons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


CREATE TABLE looks (
    id serial NOT NULL,
    user_id integer,
    reason_id integer,
    clothes character varying(1000),
    photo character varying(100),
    constraint looks_pkey primary key (id),
    constraint looks_fkey foreign key (reason_id)
               references reasons(id) match simple
               on update no action on delete set null
);

ALTER TABLE looks OWNER TO ylg;

CREATE SEQUENCE looks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
