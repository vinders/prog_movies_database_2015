-- DB-Link de CB vers CBB
-- Romain VINDERS - 2322

DROP DATABASE LINK LINK_CBB;
DROP SYNONYM CBB_USERS;
DROP SYNONYM CBB_USER_REVIEWS;
DROP SYNONYM CBB_MOVIES_STATUS;
DROP SYNONYM CBB_CERTIFICATIONS;
DROP SYNONYM CBB_MOVIES;
DROP SYNONYM CBB_COUNTRIES;
DROP SYNONYM CBB_LANGUAGES;
DROP SYNONYM CBB_GENRES;
DROP SYNONYM CBB_ACTORS;
DROP SYNONYM CBB_DIRECTORS;
DROP SYNONYM CBB_PROD_COMPS;
DROP SYNONYM CBB_MOVIE_COUNTRIES;
DROP SYNONYM CBB_MOVIE_LANGUAGES;
DROP SYNONYM CBB_MOVIE_GENRES;
DROP SYNONYM CBB_MOVIE_ACTORS;
DROP SYNONYM CBB_MOVIE_DIRECTORS;
DROP SYNONYM CBB_MOVIE_PROD_COMPS;

-- CREATION DE DB-LINK ---------------------------------------------------------
CREATE DATABASE LINK LINK_CBB CONNECT TO CBB IDENTIFIED BY dummy USING 'xe';
-- cr�er synonymes des tables distantes
CREATE SYNONYM CBB_USERS          FOR USERS@LINK_CBB;
CREATE SYNONYM CBB_USER_REVIEWS   FOR USER_REVIEWS@LINK_CBB;
CREATE SYNONYM CBB_MOVIES_STATUS  FOR MOVIES_STATUS@LINK_CBB;
CREATE SYNONYM CBB_CERTIFICATIONS FOR CERTIFICATIONS@LINK_CBB;
CREATE SYNONYM CBB_MOVIES         FOR MOVIES@LINK_CBB;
CREATE SYNONYM CBB_COUNTRIES      FOR COUNTRIES@LINK_CBB;
CREATE SYNONYM CBB_LANGUAGES      FOR LANGUAGES@LINK_CBB;
CREATE SYNONYM CBB_GENRES         FOR GENRES@LINK_CBB;
CREATE SYNONYM CBB_ACTORS         FOR ACTORS@LINK_CBB;
CREATE SYNONYM CBB_DIRECTORS      FOR DIRECTORS@LINK_CBB;
CREATE SYNONYM CBB_PROD_COMPS     FOR PROD_COMPS@LINK_CBB;
CREATE SYNONYM CBB_MOVIE_COUNTRIES      FOR MOVIE_COUNTRIES@LINK_CBB;
CREATE SYNONYM CBB_MOVIE_LANGUAGES      FOR MOVIE_LANGUAGES@LINK_CBB;
CREATE SYNONYM CBB_MOVIE_GENRES         FOR MOVIE_GENRES@LINK_CBB;
CREATE SYNONYM CBB_MOVIE_ACTORS         FOR MOVIE_ACTORS@LINK_CBB;
CREATE SYNONYM CBB_MOVIE_DIRECTORS      FOR MOVIE_DIRECTORS@LINK_CBB;
CREATE SYNONYM CBB_MOVIE_PROD_COMPS     FOR MOVIE_PROD_COMPS@LINK_CBB;
