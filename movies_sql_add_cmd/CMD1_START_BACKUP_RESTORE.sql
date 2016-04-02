-- Cr�ation des �l�ments
-- PART 1 - CreaCBlight - BackupCBlight - RestoreCBlight
-- Romain VINDERS - 2322

-- SCRIPT DE CREATION ET INITIALISATION ----------------------------------------
-- cr�er sch�mas
-- CONNECT SYS/... AS sysdba
@create_role_user
DISCONNECT;

-- cr�er tables des utilisateurs
CONNECT CB/dummy
@base_tables/create_base_tables
@create_log
DISCONNECT;
CONNECT CBB/dummy
@base_tables/create_base_tables
@create_log
ALTER SEQUENCE USERS_SEQ INCREMENT BY 1000000000; -- pour CBB uniquement
DECLARE
    v_dummy INTEGER;
    BEGIN
        v_dummy := USERS_SEQ.NEXTVAL;
END;
/
ALTER SEQUENCE USERS_SEQ INCREMENT BY 1;
DISCONNECT;

-- cr�ation des DB-links
CONNECT CB/dummy
@cb/cb_dblink
DISCONNECT;
CONNECT CBB/dummy
@cbb/cbb_dblink
DISCONNECT;


-- BackupCBLight + RestoreCBLight
CONNECT CB/dummy
@cb/cb_backup
@base_tables/create_base_tables_triggers
DISCONNECT;
CONNECT CBB/dummy
@cbb/cbb_restore
@base_tables/create_base_tables_triggers
DISCONNECT;

