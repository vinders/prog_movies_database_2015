-- Recherche de films (RechFilm)
-- Romain VINDERS - 2322

-- spécification du package ----------------------------------------------------
CREATE OR REPLACE PACKAGE EVAL_PACKAGE AS 
    PROCEDURE AddUserReview -- ajouter/modifier un avis
    (
        p_login     IN VARCHAR2,
        p_idMovie   IN INTEGER,
        p_rating    IN INTEGER,
        p_review    IN VARCHAR2
    );
END EVAL_PACKAGE;
/

-- corps du package ----------------------------------------------------
CREATE OR REPLACE PACKAGE BODY EVAL_PACKAGE AS 
    -- ajouter/modifier un avis
    PROCEDURE AddUserReview 
    (
        p_login     IN VARCHAR2,
        p_idMovie   IN INTEGER,
        p_rating    IN INTEGER,
        p_review    IN VARCHAR2
    ) AS
        v_userId    INTEGER;
        v_text      VARCHAR2(200);
        
        BEGIN
            -- récupérer ID utilisateur (ou ajouter utilisateur)
            BEGIN
                SELECT IdUser INTO v_userId
                    FROM USERS
                    WHERE UPPER(Login) = UPPER(p_login);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN -- ajouter nouvel utilisateur
                    BEGIN
                        INSERT INTO USERS (IdUser, Login)
                            VALUES (NULL, p_login);
                        SELECT IdUser INTO v_userId
                            FROM USERS
                            WHERE Login = p_login;
                    END;
            END;
            
            -- vérifier le texte
            IF LENGTH(p_review) > 0 THEN
                v_text := SUBSTR(p_review, 1, 200);
            ELSE
                v_text := NULL;
            END IF;
            -- ajouter/remplacer l'avis de l'utilisateur pour le film
            MERGE INTO USER_REVIEWS r
                USING dual ON (r.IdUser=v_userId AND r.IdMovie=p_idMovie)
            WHEN MATCHED THEN
                UPDATE SET r.Rating=p_rating, r.Review=p_review
            WHEN NOT MATCHED THEN
                INSERT (IdUser,IdMovie,Rating,Review)
                VALUES (v_userId, p_idMovie, p_rating, v_text);
            COMMIT;
            
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                LOG_PACKAGE.WriteErrorLog('EVAL_PACKAGE.AddUserReview');
                RAISE;
    END AddUserReview;

END EVAL_PACKAGE;
/
