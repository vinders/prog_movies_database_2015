-- RestoreCBLight
-- Romain VINDERS - 2322

-- effacer package si existant
--DROP PACKAGE RESTORE_PACKAGE;


-- spécification du package ----------------------------------------------------
CREATE OR REPLACE PACKAGE RESTORE_PACKAGE AS
    PROCEDURE RestoreDatabase; -- restaurer CB
END RESTORE_PACKAGE;
/

-- corps du package ------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY RESTORE_PACKAGE AS
    -- recopier nouveaux utilisateurs et modifications d'avis
    PROCEDURE RestoreDatabase
    AS
        CURSOR c_users IS
            SELECT * FROM USERS
            WHERE SyncToken=0;
        CURSOR c_user_reviews IS
            SELECT * FROM USER_REVIEWS
            WHERE SyncToken=0
            FOR UPDATE;
        PRAGMA AUTONOMOUS_TRANSACTION;

        BEGIN
            LOG_PACKAGE.WriteLog('RESTORE_PACKAGE.RestoreUsers', 'Restauration vers la base CB');
            
            -- copie nouveaux utilisateurs
            FOR new_user IN c_users
            LOOP
                INSERT INTO CB_USERS (IdUser, Login, SyncToken)
                    VALUES (new_user.IdUser, new_user.Login, 1);
            END LOOP;
            -- mise à jour flags
            UPDATE USERS
                SET SyncToken=1
                WHERE SyncToken=0;
            COMMIT;
            
            -- copie des avis
            FOR new_review IN c_user_reviews
            LOOP
                -- effacer avis modifiés
                DELETE FROM CB_USER_REVIEWS
                    WHERE IdUser=new_review.IdUser AND IdMovie=new_review.IdMovie;
                -- insérer avis ajoutés/modifiés
                INSERT INTO CB_USER_REVIEWS (IdUser, IdMovie, ReviewDate, Rating, Review, SyncToken)
                    VALUES (new_review.IdUser, new_review.IdMovie, new_review.ReviewDate, new_review.Rating, new_review.Review, 1);
            END LOOP;
            -- mise à jour flags
            UPDATE USER_REVIEWS
                SET SyncToken=1
                WHERE SyncToken=0;
            COMMIT;
            
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                LOG_PACKAGE.WriteErrorLog('RESTORE_PACKAGE.RestoreDatabase');
                RAISE_APPLICATION_ERROR
				('-20020', 'Erreur de récupération de base de données.');
    END RestoreDatabase;
END RESTORE_PACKAGE;
/

