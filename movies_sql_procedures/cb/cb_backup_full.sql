-- BackupCB
-- Romain VINDERS - 2322

-- effacer package si existant
--DROP TRIGGER BACKUP_INSERTED_REVIEWS;
--DROP PACKAGE BACKUP_PACKAGE;

-- spécification du package ----------------------------------------------------
CREATE OR REPLACE PACKAGE BACKUP_PACKAGE AS
    PROCEDURE InsertReviewBackup -- insertion avis (appelé par déclencheur)
	(
        p_reviewRow   USER_REVIEWS%ROWTYPE
	);
    PROCEDURE UpdateReviewBackup -- modification avis (appelé par déclencheur)
	(
        p_reviewRow   USER_REVIEWS%ROWTYPE
	);
    PROCEDURE ScheduledBackup; -- planifié (appelé par job)
END BACKUP_PACKAGE;
/

-- corps du package ------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY BACKUP_PACKAGE AS
    
    -- insertion avis (appelé par déclencheur)
    PROCEDURE InsertReviewBackup 
	(
        p_reviewRow     USER_REVIEWS%ROWTYPE
	) AS
        v_syncCheck     USERS.SyncToken%TYPE;
        
        BEGIN
            LOG_PACKAGE.WriteLog('BACKUP_PACKAGE.InsertReviewBackup', 'Exécution de copie de sauvegarde d''avis (déclencheur)');
    
            -- vérifier l'existence de l'utilisateur et du film dans l'autre schéma
            SELECT CASE
                WHEN EXISTS(SELECT IdUser FROM CBB_USERS 
                            WHERE IdUser = p_reviewRow.IdUser AND SyncToken = 1)
                     AND EXISTS(SELECT IdMovie FROM CBB_MOVIES 
                            WHERE IdMovie = p_reviewRow.IdMovie)
                    THEN 1
                    ELSE 0
                END
            INTO v_syncCheck FROM dual;
    
            -- copie des données de sauvegarde
            IF v_syncCheck = 1 THEN
                INSERT INTO CBB_USER_REVIEWS (IdUser, IdMovie, Rating, Review, SyncToken)
                    VALUES (p_reviewRow.IdUser, p_reviewRow.IdMovie, p_reviewRow.Rating, p_reviewRow.Review, 1);
            END IF;

        EXCEPTION
            WHEN OTHERS THEN 
                LOG_PACKAGE.WriteErrorLog('BACKUP_PACKAGE.InsertReviewBackup');
                RAISE_APPLICATION_ERROR
				('-20010', 'Erreur d''enregistrement de la copie de sauvegarde.');
    END InsertReviewBackup;
    
    -- modification avis (appelé par déclencheur)
    PROCEDURE UpdateReviewBackup 
	(
        p_reviewRow     USER_REVIEWS%ROWTYPE
	) AS
        v_syncCheck     USERS.SyncToken%TYPE;
        
        BEGIN
            LOG_PACKAGE.WriteLog('BACKUP_PACKAGE.InsertReviewBackup', 'Exécution de copie de sauvegarde d''avis (déclencheur)');
    
            -- vérifier l'existence de l'utilisateur et du film dans l'autre schéma
            SELECT CASE
                WHEN EXISTS(SELECT IdUser FROM CBB_USERS 
                            WHERE IdUser = p_reviewRow.IdUser AND SyncToken = 1)
                     AND EXISTS(SELECT IdMovie FROM CBB_MOVIES 
                            WHERE IdMovie = p_reviewRow.IdMovie)
                    THEN 1
                    ELSE 0
                END
            into v_syncCheck from dual;
    
            -- copie des données de sauvegarde
            IF v_syncCheck = 1 THEN
                -- copie
                DELETE FROM CBB_USER_REVIEWS 
                    WHERE IdUser = p_reviewRow.IdUser AND IdMovie = p_reviewRow.IdMovie;
                INSERT INTO CBB_USER_REVIEWS (IdUser, IdMovie, ReviewDate, Rating, Review, SyncToken)
                    VALUES (p_reviewRow.IdUser, p_reviewRow.IdMovie, p_reviewRow.ReviewDate, p_reviewRow.Rating, p_reviewRow.Review, 1);
            END IF;

        EXCEPTION
            WHEN OTHERS THEN 
                LOG_PACKAGE.WriteErrorLog('BACKUP_PACKAGE.UpdateReviewBackup');
                RAISE_APPLICATION_ERROR
				('-20011', 'Erreur d''enregistrement de la copie de sauvegarde.');
    END UpdateReviewBackup;
    
    -- planifié (appelé par job)
    PROCEDURE ScheduledBackup 
	AS
        v_number INTEGER;
        v_syncCheck INTEGER;
        CURSOR c_user_reviews IS
            SELECT * FROM USER_REVIEWS
            WHERE SyncToken=0
            FOR UPDATE;
        PRAGMA AUTONOMOUS_TRANSACTION;
        
        BEGIN
            LOG_PACKAGE.WriteLog('BACKUP_PACKAGE.ScheduledBackup', 'Lancement du backup planifié (job)');
            
            -- compter nouveaux films
            SELECT COUNT(IdMovie) INTO v_number
                FROM MOVIES
                WHERE SyncToken = 0;
            
            -- nouveaux films
            IF v_number > 0 THEN 
                -- nouveaux statuts
                SELECT COUNT(IdStatus) INTO v_number 
                    FROM MOVIES_STATUS MS 
                    WHERE EXISTS(SELECT * FROM MOVIES MV WHERE SyncToken=0 AND MV.IdStatus=MS.IdStatus) 
                    AND NOT EXISTS(SELECT * FROM CBB_MOVIES_STATUS MS2 WHERE MS2.IdStatus=MS.IdStatus);
                IF v_number > 0 THEN 
                    INSERT INTO CBB_MOVIES_STATUS 
                        (SELECT * FROM MOVIES_STATUS MS 
                         WHERE EXISTS(SELECT * FROM MOVIES MV WHERE SyncToken=0 AND MV.IdStatus=MS.IdStatus) 
                         AND NOT EXISTS(SELECT * FROM CBB_MOVIES_STATUS MS2 WHERE MS2.IdStatus=MS.IdStatus));
                END IF;
                -- nouvelles certifications
                SELECT COUNT(IdCertif) INTO v_number 
                    FROM CERTIFICATIONS CT 
                    WHERE EXISTS(SELECT * FROM MOVIES MV WHERE SyncToken=0 AND COALESCE(MV.IdCertif,0)=CT.IdCertif) 
                    AND NOT EXISTS(SELECT * FROM CBB_CERTIFICATIONS CT2 WHERE CT2.IdCertif=CT.IdCertif);
                IF v_number > 0 THEN 
                    INSERT INTO CBB_CERTIFICATIONS 
                       (SELECT * FROM CERTIFICATIONS CT 
                        WHERE EXISTS(SELECT * FROM MOVIES MV WHERE SyncToken=0 AND COALESCE(MV.IdCertif,0)=CT.IdCertif) 
                        AND NOT EXISTS(SELECT * FROM CBB_CERTIFICATIONS CT2 WHERE CT2.IdCertif=CT.IdCertif));
                END IF;
                
                -- nouveaux genres
                SELECT COUNT(*) INTO v_number 
                    FROM GENRES RF 
                    WHERE EXISTS(SELECT * FROM MOVIE_GENRES MV INNER JOIN MOVIES ON MV.IdMovie=MOVIES.IdMovie 
                                 WHERE SyncToken=0 AND MV.IdGenre=RF.IdGenre)
                    AND NOT EXISTS(SELECT * FROM CBB_GENRES RF2 WHERE RF2.IdGenre=RF.IdGenre);
                IF v_number > 0 THEN
                    INSERT INTO CBB_GENRES
                       (SELECT * FROM GENRES RF 
                        WHERE EXISTS(SELECT * FROM MOVIE_GENRES MV INNER JOIN MOVIES ON MV.IdMovie=MOVIES.IdMovie 
                                     WHERE SyncToken=0 AND MV.IdGenre=RF.IdGenre)
                        AND NOT EXISTS(SELECT * FROM CBB_GENRES RF2 WHERE RF2.IdGenre=RF.IdGenre));
                END IF;
                -- nouveaux pays
                SELECT COUNT(*) INTO v_number 
                    FROM COUNTRIES RF 
                    WHERE EXISTS(SELECT * FROM MOVIE_COUNTRIES MV INNER JOIN MOVIES ON MV.IdMovie=MOVIES.IdMovie 
                                 WHERE SyncToken=0 AND MV.IsoCountry=RF.IsoCountry)
                    AND NOT EXISTS(SELECT * FROM CBB_COUNTRIES RF2 WHERE RF2.IsoCountry=RF.IsoCountry);
                IF v_number > 0 THEN
                    INSERT INTO CBB_COUNTRIES
                       (SELECT * FROM COUNTRIES RF 
                        WHERE EXISTS(SELECT * FROM MOVIE_COUNTRIES MV INNER JOIN MOVIES ON MV.IdMovie=MOVIES.IdMovie 
                                     WHERE SyncToken=0 AND MV.IsoCountry=RF.IsoCountry)
                        AND NOT EXISTS(SELECT * FROM CBB_COUNTRIES RF2 WHERE RF2.IsoCountry=RF.IsoCountry));
                END IF;
                -- nouvelles langues
                SELECT COUNT(*) INTO v_number 
                    FROM LANGUAGES RF 
                    WHERE EXISTS(SELECT * FROM MOVIE_LANGUAGES MV INNER JOIN MOVIES ON MV.IdMovie=MOVIES.IdMovie 
                                 WHERE SyncToken=0 AND MV.IsoLang=RF.IsoLang)
                    AND NOT EXISTS(SELECT * FROM CBB_LANGUAGES RF2 WHERE RF2.IsoLang=RF.IsoLang);
                IF v_number > 0 THEN
                    INSERT INTO CBB_LANGUAGES
                       (SELECT * FROM LANGUAGES RF 
                        WHERE EXISTS(SELECT * FROM MOVIE_LANGUAGES MV INNER JOIN MOVIES ON MV.IdMovie=MOVIES.IdMovie 
                                     WHERE SyncToken=0 AND MV.IsoLang=RF.IsoLang)
                        AND NOT EXISTS(SELECT * FROM CBB_LANGUAGES RF2 WHERE RF2.IsoLang=RF.IsoLang));
                END IF;
                -- nouveaux acteurs
                SELECT COUNT(*) INTO v_number 
                    FROM ACTORS RF 
                    WHERE EXISTS(SELECT * FROM MOVIE_ACTORS MV INNER JOIN MOVIES ON MV.IdMovie=MOVIES.IdMovie 
                                 WHERE SyncToken=0 AND MV.IdActor=RF.IdActor)
                    AND NOT EXISTS(SELECT * FROM CBB_ACTORS RF2 WHERE RF2.IdActor=RF.IdActor);
                IF v_number > 0 THEN
                    INSERT INTO CBB_ACTORS
                       (SELECT * FROM ACTORS RF 
                        WHERE EXISTS(SELECT * FROM MOVIE_ACTORS MV INNER JOIN MOVIES ON MV.IdMovie=MOVIES.IdMovie 
                                     WHERE SyncToken=0 AND MV.IdActor=RF.IdActor)
                        AND NOT EXISTS(SELECT * FROM CBB_ACTORS RF2 WHERE RF2.IdActor=RF.IdActor));
                END IF;
                -- nouveaux directeurs
                SELECT COUNT(*) INTO v_number 
                    FROM DIRECTORS RF 
                    WHERE EXISTS(SELECT * FROM MOVIE_DIRECTORS MV INNER JOIN MOVIES ON MV.IdMovie=MOVIES.IdMovie 
                                 WHERE SyncToken=0 AND MV.IdDirector=RF.IdDirector)
                    AND NOT EXISTS(SELECT * FROM CBB_DIRECTORS RF2 WHERE RF2.IdDirector=RF.IdDirector);
                IF v_number > 0 THEN
                    INSERT INTO CBB_DIRECTORS
                       (SELECT * FROM DIRECTORS RF 
                        WHERE EXISTS(SELECT * FROM MOVIE_DIRECTORS MV INNER JOIN MOVIES ON MV.IdMovie=MOVIES.IdMovie 
                                     WHERE SyncToken=0 AND MV.IdDirector=RF.IdDirector)
                        AND NOT EXISTS(SELECT * FROM CBB_DIRECTORS RF2 WHERE RF2.IdDirector=RF.IdDirector));
                END IF;
                -- nouveaux producteurs
                SELECT COUNT(*) INTO v_number 
                    FROM PROD_COMPS RF 
                    WHERE EXISTS(SELECT * FROM MOVIE_PROD_COMPS MV INNER JOIN MOVIES ON MV.IdMovie=MOVIES.IdMovie 
                                 WHERE SyncToken=0 AND MV.IdComp=RF.IdComp)
                    AND NOT EXISTS(SELECT * FROM CBB_PROD_COMPS RF2 WHERE RF2.IdComp=RF.IdComp);
                IF v_number > 0 THEN
                    INSERT INTO CBB_PROD_COMPS
                       (SELECT * FROM PROD_COMPS RF 
                        WHERE EXISTS(SELECT * FROM MOVIE_PROD_COMPS MV INNER JOIN MOVIES ON MV.IdMovie=MOVIES.IdMovie 
                                     WHERE SyncToken=0 AND MV.IdComp=RF.IdComp)
                        AND NOT EXISTS(SELECT * FROM CBB_PROD_COMPS RF2 WHERE RF2.IdComp=RF.IdComp));
                END IF;
                
                -- insérer films
                INSERT INTO CBB_MOVIES
                    (SELECT IdMovie, Title, TitleOrig, ReleaseDate, 
                            IdStatus, VoteAverage, VoteCount, 
                            Runtime, IdCertif, PosterPath, Budget, Revenue, 
                            Homepage, Tagline, Overview, 1
                     FROM MOVIES
                     WHERE SyncToken = 0);
                
                -- associations
                INSERT INTO CBB_MOVIE_GENRES
                   (SELECT * FROM MOVIE_GENRES RF 
                    WHERE EXISTS(SELECT * FROM MOVIE_GENRES MV INNER JOIN MOVIES ON MV.IdMovie=MOVIES.IdMovie 
                                 WHERE SyncToken=0 AND MV.IdGenre=RF.IdGenre AND MV.IdMovie=RF.IdMovie));
                INSERT INTO CBB_MOVIE_COUNTRIES
                   (SELECT * FROM MOVIE_COUNTRIES RF 
                    WHERE EXISTS(SELECT * FROM MOVIE_COUNTRIES MV INNER JOIN MOVIES ON MV.IdMovie=MOVIES.IdMovie 
                                 WHERE SyncToken=0 AND MV.IsoCountry=RF.IsoCountry AND MV.IdMovie=RF.IdMovie));
                INSERT INTO CBB_MOVIE_LANGUAGES
                   (SELECT * FROM MOVIE_LANGUAGES RF 
                    WHERE EXISTS(SELECT * FROM MOVIE_LANGUAGES MV INNER JOIN MOVIES ON MV.IdMovie=MOVIES.IdMovie 
                                 WHERE SyncToken=0 AND MV.IsoLang=RF.IsoLang AND MV.IdMovie=RF.IdMovie));
                INSERT INTO CBB_MOVIE_ACTORS
                   (SELECT * FROM MOVIE_ACTORS RF 
                    WHERE EXISTS(SELECT * FROM MOVIE_ACTORS MV INNER JOIN MOVIES ON MV.IdMovie=MOVIES.IdMovie 
                                 WHERE SyncToken=0 AND MV.IdActor=RF.IdActor AND MV.IdMovie=RF.IdMovie AND MV.CharacterName=RF.CharacterName));
                INSERT INTO CBB_MOVIE_DIRECTORS
                   (SELECT * FROM MOVIE_DIRECTORS RF 
                    WHERE EXISTS(SELECT * FROM MOVIE_DIRECTORS MV INNER JOIN MOVIES ON MV.IdMovie=MOVIES.IdMovie 
                                 WHERE SyncToken=0 AND MV.IdDirector=RF.IdDirector AND MV.IdMovie=RF.IdMovie));
                INSERT INTO CBB_MOVIE_PROD_COMPS
                   (SELECT * FROM MOVIE_PROD_COMPS RF 
                    WHERE EXISTS(SELECT * FROM MOVIE_PROD_COMPS MV INNER JOIN MOVIES ON MV.IdMovie=MOVIES.IdMovie 
                                 WHERE SyncToken=0 AND MV.IdComp=RF.IdComp AND MV.IdMovie=RF.IdMovie));
                
                -- mise à jour des flags
                UPDATE MOVIES
                    SET SyncToken = 1
                    WHERE SyncToken = 0;
                COMMIT;
            END IF;
            
            
            -- compter nouveaux utilisateurs
            SELECT COUNT(IdUser) INTO v_number
                FROM USERS
                WHERE SyncToken = 0;
                
            IF v_number > 0 THEN
                -- nouveaux utilisateurs
                INSERT INTO CBB_USERS
                    (SELECT IdUser, Login, 1 
                     FROM USERS
                     WHERE SyncToken = 0);
                -- mise à jour des flags
                UPDATE USERS 
                    SET SyncToken = 1
                    WHERE SyncToken = 0;
                COMMIT;
            END IF;
            
            
            -- nouveaux avis
            FOR new_review IN c_user_reviews
            LOOP
                -- effacer avis modifiés
                DELETE FROM CBB_USER_REVIEWS
                    WHERE IdUser=new_review.IdUser AND IdMovie=new_review.IdMovie;
                -- insérer avis ajoutés/modifiés
                INSERT INTO CBB_USER_REVIEWS (IdUser, IdMovie, ReviewDate, Rating, Review, SyncToken)
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
                LOG_PACKAGE.WriteErrorLog('BACKUP_PACKAGE.ScheduledBackup');
    END ScheduledBackup;
    
END BACKUP_PACKAGE;
/


-- déclencheur (réplication synchrone) -----------------------------------------
CREATE OR REPLACE TRIGGER BACKUP_INSERTED_REVIEWS AFTER INSERT ON USER_REVIEWS 
FOR EACH ROW
    DECLARE
        v_row USER_REVIEWS%ROWTYPE;
    BEGIN
        IF :new.SyncToken = 0 THEN
            v_row.IdUser := :new.IdUser;
            v_row.IdMovie := :new.IdMovie;
            v_row.ReviewDate := :new.ReviewDate;
            v_row.Rating := :new.Rating;
            v_row.Review := :new.Review;
            BACKUP_PACKAGE.InsertReviewBackup(v_row);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN 
            LOG_PACKAGE.WriteErrorLog('BACKUP_INSERTED_REVIEWS');
            RAISE;
END BACKUP_INSERTED_REVIEWS;
/

-- déclencheur (mise à jour synchrone) -----------------------------------------
CREATE OR REPLACE TRIGGER BACKUP_UPDATED_REVIEWS AFTER UPDATE OF Rating,Review ON USER_REVIEWS 
FOR EACH ROW
    DECLARE
        v_row USER_REVIEWS%ROWTYPE;
    BEGIN
        IF :new.SyncToken = 0 THEN
            v_row.IdUser := :new.IdUser;
            v_row.IdMovie := :new.IdMovie;
            v_row.ReviewDate := CURRENT_TIMESTAMP;
            v_row.Rating := :new.Rating;
            v_row.Review := :new.Review;
            BACKUP_PACKAGE.UpdateReviewBackup(v_row);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN 
            LOG_PACKAGE.WriteErrorLog('BACKUP_UPDATED_REVIEWS');
            RAISE;
END BACKUP_UPDATED_REVIEWS;
/

-- job (réplication asynchrone) ------------------------------------------------
BEGIN
    -- créer job
    DBMS_SCHEDULER.create_job 
    (
        job_name    => 'BACKUP_SCHEDULE',
        job_type    => 'plsql_block',
        job_action  => 'BACKUP_PACKAGE.ScheduledBackup',
        start_date  => NULL,
        repeat_interval => 'FREQ=DAILY; BYHOUR=0',
        auto_drop       =>  FALSE,
        enabled     => TRUE,
        comments    => 'job asynchronous backup'
    );
    DBMS_SCHEDULER.enable('BACKUP_SCHEDULE');
    
EXCEPTION
    WHEN OTHERS THEN 
        LOG_PACKAGE.WriteErrorLog('Job scheduler (backup)');
        RAISE;
END;
/

