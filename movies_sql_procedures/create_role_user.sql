-- CreateRoleUser
-- Romain VINDERS - 2322

-- effacer (si existants)
DROP USER CB CASCADE;
DROP USER CBB CASCADE;
DROP ROLE CB_MAIN_ROLE;

-- CREATION DES SCHEMAS --------------------------------------------------------

CREATE ROLE CB_MAIN_ROLE NOT IDENTIFIED;

GRANT ALTER SESSION TO CB_MAIN_ROLE;
GRANT CREATE DATABASE LINK TO CB_MAIN_ROLE;
GRANT CREATE SESSION TO CB_MAIN_ROLE;
GRANT CREATE PROCEDURE TO CB_MAIN_ROLE;
GRANT CREATE SEQUENCE TO CB_MAIN_ROLE;
GRANT CREATE TABLE TO CB_MAIN_ROLE;
GRANT CREATE TRIGGER TO CB_MAIN_ROLE;
GRANT CREATE TYPE TO CB_MAIN_ROLE;
GRANT CREATE SYNONYM TO CB_MAIN_ROLE;
GRANT CREATE VIEW TO CB_MAIN_ROLE;
GRANT CREATE JOB TO CB_MAIN_ROLE;
GRANT CREATE ANY DIRECTORY TO CB_MAIN_ROLE;
GRANT CREATE MATERIALIZED VIEW TO CB_MAIN_ROLE;
GRANT EXECUTE ON SYS.DBMS_LOCK TO CB_MAIN_ROLE;
GRANT EXECUTE ON SYS.OWA_OPT_LOCK TO CB_MAIN_ROLE;
GRANT EXECUTE ON UTL_FILE TO CB_MAIN_ROLE;

CREATE USER CB IDENTIFIED BY dummy DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP PROFILE DEFAULT ACCOUNT UNLOCK;
ALTER USER CB QUOTA UNLIMITED ON USERS;
GRANT CB_MAIN_ROLE TO CB;

CREATE USER CBB IDENTIFIED BY dummy DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP PROFILE DEFAULT ACCOUNT UNLOCK;
ALTER USER CBB QUOTA UNLIMITED ON USERS;
GRANT CB_MAIN_ROLE TO CBB;