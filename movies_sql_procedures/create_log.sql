-- Utilitaire de log (table + package)
-- Romain VINDERS - 2322

-- effacer package si existant
--DROP PACKAGE LOG_PACKAGE;
--DROP SEQUENCE LOG_MESSAGES_SEQ;
--DROP TABLE LOG_MESSAGES CASCADE CONSTRAINTS;


-- créer table de log (informations/erreurs) -----------------------------------
CREATE TABLE LOG_MESSAGES
(
    IdLog       INTEGER        CONSTRAINT ERROR_LOGS_PK           PRIMARY KEY,
    Username    VARCHAR2(5)   DEFAULT USER
                              CONSTRAINT ERROR_LOGS_USERNAME_NN  NOT NULL,
    Origin      VARCHAR2(48)  CONSTRAINT ERROR_LOGS_ORIGIN_NN    NOT NULL,
    ReviewDate  TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
                              CONSTRAINT ERROR_LOGS_DATEERROR_NN NOT NULL,
    Code        INTEGER        CONSTRAINT ERROR_LOGS_CODE_NN      NOT NULL,
    Message     VARCHAR2(120)
);
CREATE SEQUENCE LOG_MESSAGES_SEQ; -- séquence d'autoincrémentation d'ID


-- spécification du package ----------------------------------------------------
CREATE OR REPLACE PACKAGE LOG_PACKAGE AS
    PROCEDURE WriteLog -- message informatif
	(
        p_origin    LOG_MESSAGES.Origin%TYPE,
        p_message   LOG_MESSAGES.Message%TYPE
	);
    PROCEDURE WriteErrorLog -- message d'erreur
	(
        p_origin    LOG_MESSAGES.Origin%TYPE
	);
END LOG_PACKAGE;
/


-- corps du package ------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY LOG_PACKAGE AS

    -- écrire message informatif
    PROCEDURE WriteLog
	(
        p_origin    LOG_MESSAGES.Origin%TYPE,
        p_message   LOG_MESSAGES.Message%TYPE
	) AS
        PRAGMA AUTONOMOUS_TRANSACTION;
        
        BEGIN
            INSERT INTO LOG_MESSAGES (IdLog, Origin, Code, Message)
            VALUES (LOG_MESSAGES_SEQ.NEXTVAL, COALESCE(p_origin,'unknown'), 0, p_message);
            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN RAISE;
    END WriteLog;
    
    -- écrire message d'erreur
    PROCEDURE WriteErrorLog
	(
        p_origin LOG_MESSAGES.Origin%TYPE
	) AS
        v_code      LOG_MESSAGES.Code%TYPE;
        v_message   LOG_MESSAGES.Message%TYPE;
        PRAGMA AUTONOMOUS_TRANSACTION;
        
        BEGIN
            v_code    := SQLCODE;
            v_message := SUBSTR(SQLERRM, 1, 120);
            INSERT INTO LOG_MESSAGES (IdLog, Origin, Code, Message)
            VALUES (LOG_MESSAGES_SEQ.NEXTVAL, COALESCE(p_origin,'unknown'), v_code, v_message);
            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN RAISE;
    END WriteErrorLog;
    
END LOG_PACKAGE;
/
