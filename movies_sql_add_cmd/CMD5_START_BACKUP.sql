-- Backup comprenant les films
-- PART 5 - BackupCB
-- Romain VINDERS - 2322

-- SCRIPT DE CREATION ET INITIALISATION ----------------------------------------
CONNECT CB/dummy

BEGIN
    -- effacer ancien job
    DBMS_SCHEDULER.drop_job
    (
        job_name => 'BACKUP_SCHEDULE',
        force    => true
    );
EXCEPTION
    WHEN OTHERS THEN RAISE;
END;
/
-- effacer anciens triggers/package/DBlinks
DROP TRIGGER BACKUP_INSERTED_REVIEWS;
DROP TRIGGER BACKUP_UPDATED_REVIEWS;
DROP PACKAGE BACKUP_PACKAGE;

-- création des DB-links
@cb/cb_dblink

-- BackupCB + RestoreCBLight
@cb/cb_backup_full
DISCONNECT;
