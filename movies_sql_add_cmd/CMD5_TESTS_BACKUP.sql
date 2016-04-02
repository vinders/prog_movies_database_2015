CONNECT CB/dummy

-- test job (copier users films, et reviews)
EXEC BACKUP_PACKAGE.ScheduledBackup;

DISCONNECT;