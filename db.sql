SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

CREATE DATABASE ylg_new WITH OWNER ylg ENCODING = 'UTF8';

\connect ylg_new

CREATE TABLE reasons (
    id serial NOT NULL,
    name character varying,
    public smallint default 0,
    constraint reasons_pkey primary key (id)
);

ALTER TABLE reasons OWNER TO ylg;


--
