-- CreaCBLight
-- Romain VINDERS - 2322

-- déclencheur (ajout) ---------------------------------------------------------
CREATE OR REPLACE TRIGGER SEQ_INSERT_USER BEFORE INSERT ON USERS 
FOR EACH ROW
    DECLARE
        v_existCheck INTEGER;
    BEGIN
        IF :new.IdUser IS NULL THEN
            LOOP
            -- nouvel ID
                :new.IdUser := USERS_SEQ.NEXTVAL;
                -- vérifier existence
                SELECT CASE
                    WHEN EXISTS(SELECT IdUser FROM USERS 
                                WHERE IdUser = :new.IdUser)
                        THEN 1
                        ELSE 0
                    END
                INTO v_existCheck FROM dual;
                IF v_existCheck = 0 THEN
                    EXIT;
                END IF;
            END LOOP;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN 
            LOG_PACKAGE.WriteErrorLog('SEQ_INSERT_USER');
            RAISE;
END INSERT_SEQ;
/

-- déclencheur (avant mise à jour) ---------------------------------------------
CREATE OR REPLACE TRIGGER MARK_UPDATED_REVIEW BEFORE UPDATE OF Rating,Review ON USER_REVIEWS 
FOR EACH ROW
    DECLARE
    BEGIN
        :new.SyncToken := 0;
        :new.ReviewDate := CURRENT_TIMESTAMP;
    EXCEPTION
        WHEN OTHERS THEN 
            LOG_PACKAGE.WriteErrorLog('MARK_UPDATED_REVIEW');
            RAISE;
END MARK_UPDATED_REVIEWS;
/
