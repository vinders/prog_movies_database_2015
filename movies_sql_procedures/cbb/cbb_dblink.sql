-- DB-Link de CBB vers CB
-- Romain VINDERS - 2322

-- CREATION DE DB-LINK ---------------------------------------------------------
CREATE DATABASE LINK LINK_CB CONNECT TO CB IDENTIFIED BY dummy USING 'xe';
-- créer synonymes des tables distantes
CREATE SYNONYM CB_USERS        FOR USERS@LINK_CB;
CREATE SYNONYM CB_USER_REVIEWS FOR USER_REVIEWS@LINK_CB;

