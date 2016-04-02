-- Importation d'informations de films (AlimCB)
-- Romain VINDERS - 2322

DROP PACKAGE IMPORT_PACKAGE;

-- spécification du package ----------------------------------------------------
CREATE OR REPLACE PACKAGE IMPORT_PACKAGE AS 
    PROCEDURE ImportMovies -- importer nombre de films spécifié
	(
        p_number    IN INTEGER
	);
    FUNCTION TruncateInteger -- tronquer nombre entier
    (
        p_val     IN INTEGER, 
        p_min     IN INTEGER, 
        p_trunc   IN INTEGER, 
        p_max     IN INTEGER, 
        p_colName IN VARCHAR2, 
        p_movie   IN INTEGER
    ) RETURN INTEGER;
    FUNCTION TruncateString -- tronquer chaine de caractères
    (
        p_val     IN VARCHAR2, 
        p_min     IN INTEGER, 
        p_trunc   IN INTEGER, 
        p_max     IN INTEGER, 
        p_colName IN VARCHAR2, 
        p_movie   IN INTEGER
    ) RETURN VARCHAR2;
    FUNCTION DecomposeDualBlock -- récupérer données (id, nom) groupées
    (
        p_block      IN VARCHAR2, 
        p_destTable  IN VARCHAR2, 
        p_assocIdName IN VARCHAR2,
        p_idIsString IN CHAR,
        p_idMin   IN INTEGER, p_idTrunc   IN INTEGER, p_idMax   IN INTEGER,
        p_nameMin IN INTEGER, p_nameTrunc IN INTEGER, p_nameMax IN INTEGER,
        p_movie   IN VARCHAR2
    ) RETURN INTEGER;
    FUNCTION DecomposeTripleBlock -- récupérer données (id, nom, autre) groupées
    (
        p_block        IN VARCHAR2, 
        p_thirdCol     IN INTEGER, 
        p_thirdColName IN VARCHAR2, 
        p_destTable    IN VARCHAR2, 
        p_assocIdName IN VARCHAR2,
        p_idMin    IN INTEGER, p_idTrunc    IN INTEGER, p_idMax    IN INTEGER,
        p_nameMin  IN INTEGER, p_nameTrunc  IN INTEGER, p_nameMax  IN INTEGER,
        p_thirdMin IN INTEGER, p_thirdTrunc IN INTEGER, p_thirdMax IN INTEGER,
        p_movie    IN VARCHAR2
    ) RETURN INTEGER;
END IMPORT_PACKAGE;
/

-- corps du package ----------------------------------------------------
CREATE OR REPLACE PACKAGE BODY IMPORT_PACKAGE AS 
    -- importer nombre de films spécifié
    PROCEDURE ImportMovies
    (
        p_number    IN INTEGER
	) AS
        v_i         INTEGER;
        v_movieRow  MOVIES%ROWTYPE;
        v_tmpString VARCHAR2(2000);
        v_tmpCount  INTEGER;
        
        -- curseur de sélection de films valides
        CURSOR c_movies IS
            SELECT * FROM
                (SELECT id, 
                    TRIM(REPLACE(title, CHR(9), ' '))          AS title, -- enlever tabulations et vérifier début/fin
                    TRIM(REPLACE(original_title, CHR(9), ' ')) AS original_title, 
                    release_date, 
                    TRIM(REPLACE(status, CHR(9), ' '))         AS status, 
                    vote_average, 
                    vote_count, 
                    runtime, 
                    TRIM(REPLACE(certification, CHR(9), ' ')) AS certification, 
                    TRIM(REPLACE(poster_path, CHR(9), ' '))   AS poster_path, 
                    budget, 
                    revenue, 
                    TRIM(REPLACE(homepage, CHR(9), ' ')) AS homepage, 
                    TRIM(REPLACE(tagline, CHR(9), ' '))  AS tagline, 
                    TRIM(REPLACE(overview, CHR(9), ' ')) AS overview, 
                    genres, 
                    directors, 
                    actors, 
                    production_companies, 
                    production_countries, 
                    spoken_languages
                FROM movies_ext
                -- validité des données et 9999e 10000-quantile sur valeurs non nulles directes
                WHERE   id             IS NOT NULL AND id NOT IN (SELECT IdMovie FROM MOVIES) -- pas nul et pas déjà ajouté
                    AND title          IS NOT NULL 
                        AND (LENGTH(TRIM(REPLACE(title,CHR(9),' '))) BETWEEN 1 AND 112)         -- pas nul et pas vide
                    AND original_title IS NOT NULL 
                        AND (LENGTH(TRIM(REPLACE(original_title,CHR(9),' '))) BETWEEN 1 AND 113) -- pas nul et pas vide
                    AND (release_date  IS NULL     OR CAST(release_date AS TIMESTAMP) <= CURRENT_TIMESTAMP)  -- pas date future
                    AND status         IS NOT NULL AND LENGTH(TRIM(REPLACE(status,CHR(9),' '))) > 1  -- pas nul, pas vide, pas invalide (ex : '-')
                    AND vote_average   IS NOT NULL AND (vote_average BETWEEN 0 AND 10)
                    AND vote_count     IS NOT NULL AND (vote_count BETWEEN 0 AND 9999)
                    AND genres         IS NOT NULL AND LENGTH(genres) > 7     -- pas nul et pas vide (ex : [[,,]] ou [[-,,]] )
                    AND directors      IS NOT NULL AND LENGTH(directors) > 7                   -- idem
                    AND actors         IS NOT NULL AND (LENGTH(actors) BETWEEN 14 AND 4000) -- idem + longueur max supportée
                    AND production_companies IS NOT NULL AND LENGTH(production_companies) > 7  -- idem
                    AND production_countries IS NOT NULL AND LENGTH(production_countries) > 7  -- idem
                    AND spoken_languages IS NOT NULL AND LENGTH(spoken_languages) > 7          -- idem
                ORDER BY DBMS_RANDOM.VALUE)   -- ordre au hasard
            -- limiter nombre
            WHERE ROWNUM <= 1.25*p_number;   -- prévoir plus que demandé (pour valeurs non valides)
        
        BEGIN
            v_i := 0;
            v_movieRow.SyncToken := '0';
            
            -- parcourir films, vérifier et insérer
            FOR curMovie IN c_movies
            LOOP
                EXIT WHEN v_i >= p_number; -- limiter au nombre demandé
                
                BEGIN
                    -- copier statut
                    v_tmpString := TruncateString(curMovie.status, 2, 15, 15, 'status', curMovie.id);
                    SELECT COUNT(*) INTO v_tmpCount
                        FROM MOVIES_STATUS
                        WHERE UPPER(v_tmpString) = UPPER(Name);
                    IF v_tmpCount > 0 THEN
                        SELECT IdStatus INTO v_movieRow.IdStatus
                            FROM MOVIES_STATUS
                            WHERE UPPER(v_tmpString) = UPPER(Name);
                    ELSE
                        v_movieRow.IdStatus := MOVIES_STATUS_SEQ.NEXTVAL;
                        INSERT INTO MOVIES_STATUS (IdStatus, Name)
                            VALUES (v_movieRow.IdStatus, v_tmpString);
                        LOG_PACKAGE.WriteLog('IMPORT_PACKAGE.ImportMovies', 'Nouveau statut créé ('||v_movieRow.IdStatus||')');
                    END IF;
                    -- copier certification
                    v_tmpString := TruncateString(curMovie.certification, 1, 12, 12, 'certification', curMovie.id);
                    IF v_tmpString IS NULL THEN
                        v_movieRow.IdCertif := NULL;
                    ELSE
                        SELECT COUNT(*) INTO v_tmpCount
                            FROM CERTIFICATIONS
                            WHERE UPPER(v_tmpString) = UPPER(Name);
                        IF v_tmpCount > 0 THEN
                            SELECT IdCertif INTO v_movieRow.IdCertif
                                FROM CERTIFICATIONS
                                WHERE UPPER(v_tmpString) = UPPER(Name);
                        ELSE
                            v_movieRow.IdCertif := CERTIFICATIONS_SEQ.NEXTVAL;
                            INSERT INTO CERTIFICATIONS (IdCertif, Name)
                                VALUES (v_movieRow.IdCertif, v_tmpString);
                            LOG_PACKAGE.WriteLog('IMPORT_PACKAGE.ImportMovies', 'Nouvelle certification ('||v_movieRow.IdCertif||')');
                        END IF;
                    END IF;
                    
                    -- copier données directes du film
                    v_movieRow.IdMovie     := curMovie.id;
                    v_movieRow.Title       := TruncateString(curMovie.title, 1, 58, 112, 'title', curMovie.id);
                    v_movieRow.TitleOrig   := TruncateString(curMovie.original_title, 1, 59, 113, 'original_title', curMovie.id);
                    v_movieRow.ReleaseDate := curMovie.release_date;
                    v_movieRow.VoteAverage := curMovie.vote_average;
                    v_movieRow.VoteCount   := curMovie.vote_count;
                    v_movieRow.Runtime     := TruncateInteger(curMovie.runtime, 1, 999, 1772, 'runtime', curMovie.id);
                    v_movieRow.PosterPath  := TruncateString(curMovie.poster_path, 1, 32, 32, 'poster_path', curMovie.id);
                    v_movieRow.Budget      := TruncateInteger(curMovie.budget, 1, 99999999, 225000000, 'budget', curMovie.id);
                    v_movieRow.Revenue     := TruncateInteger(curMovie.revenue, 1, 99999999, 934012791, 'revenue', curMovie.id);
                    v_movieRow.Homepage    := TruncateString(curMovie.homepage, 1, 122, 359, 'homepage', curMovie.id);
                    v_movieRow.Tagline     := TruncateString(curMovie.tagline, 1, 172, 872, 'tagline', curMovie.id);
                    v_movieRow.Overview    := TruncateString(curMovie.overview, 1, 949, 1000, 'overview', curMovie.id);
                    -- insérer film
                    INSERT INTO MOVIES VALUES v_movieRow;
                    LOG_PACKAGE.WriteLog('IMPORT_PACKAGE.ImportMovies', 'Film ajouté ('||v_movieRow.IdMovie||')');
                    
                    -- vérifier données composites
                    v_tmpCount := DecomposeDualBlock(curMovie.genres, 'GENRES', 'IdGenre', 
                                                    '0',1,99999,99999, 3,16,16, v_movieRow.IdMovie);
                    IF v_tmpCount = 0 THEN
                        ROLLBACK;
                        LOG_PACKAGE.WriteLog('IMPORT_PACKAGE.ImportMovies', 'Retrait de film '
                                            ||v_movieRow.IdMovie||' : aucun genre valide');
                        CONTINUE;
                    END IF;
                    v_tmpCount := DecomposeDualBlock(curMovie.directors, 'DIRECTORS', 'IdDirector',
                                                    '0',1,9999999,9999999, 2,23,35, v_movieRow.IdMovie);
                    IF v_tmpCount = 0 THEN
                        ROLLBACK;
                        LOG_PACKAGE.WriteLog('IMPORT_PACKAGE.ImportMovies', 'Retrait de film '
                                            ||v_movieRow.IdMovie||' : aucun directeur valide');
                        CONTINUE;
                    END IF;
                    v_tmpCount := DecomposeTripleBlock(curMovie.actors, 4, 'CharacterName', 'ACTORS', 'IdActor',
                                                    1,9999999,9999999, 1,22,41, 1,36,117, v_movieRow.IdMovie);
                    IF v_tmpCount = 0 THEN
                        ROLLBACK;
                        LOG_PACKAGE.WriteLog('IMPORT_PACKAGE.ImportMovies', 'Retrait de film '
                                            ||v_movieRow.IdMovie||' : aucun acteur/personnage valide');
                        CONTINUE;
                    END IF;
                    v_tmpCount := DecomposeDualBlock(curMovie.production_companies, 'PROD_COMPS', 'IdComp',
                                                    '0',1,99999,99999, 1,44,84, v_movieRow.IdMovie);
                    IF v_tmpCount = 0 THEN
                        ROLLBACK;
                        LOG_PACKAGE.WriteLog('IMPORT_PACKAGE.ImportMovies', 'Retrait de film '
                                            ||v_movieRow.IdMovie||' : aucun producteur valide');
                        CONTINUE;
                    END IF;
                    v_tmpCount := DecomposeDualBlock(curMovie.production_countries, 'COUNTRIES', 'IsoCountry',
                                                    '1',2,2,2, 2,24,38, v_movieRow.IdMovie);
                    IF v_tmpCount = 0 THEN
                        ROLLBACK;
                        LOG_PACKAGE.WriteLog('IMPORT_PACKAGE.ImportMovies', 'Retrait de film '
                                            ||v_movieRow.IdMovie||' : aucun pays valide');
                        CONTINUE;
                    END IF;
                    v_tmpCount := DecomposeDualBlock(curMovie.spoken_languages, 'LANGUAGES', 'IsoLang',
                                                    '1',2,2,2, 2,11,16, v_movieRow.IdMovie);
                    IF v_tmpCount = 0 THEN
                        ROLLBACK;
                        LOG_PACKAGE.WriteLog('IMPORT_PACKAGE.ImportMovies', 'Retrait de film '
                                            ||v_movieRow.IdMovie||' : aucune langue valide');
                        CONTINUE;
                    END IF;

                    COMMIT;
                    v_i := v_i + 1; -- incrémenter indice
                
                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                        LOG_PACKAGE.WriteErrorLog('IMPORT_PACKAGE.ImportMovies');
                END;
                
            END LOOP;
            LOG_PACKAGE.WriteLog('IMPORT_PACKAGE.ImportMovies', v_i||' films valides ajoutés.');
            
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                LOG_PACKAGE.WriteErrorLog('IMPORT_PACKAGE.ImportMovies');
                RAISE;
    END ImportMovies;
    
    
    -- tronquer nombre entier
    FUNCTION TruncateInteger
    (
        p_val     IN INTEGER, 
        p_min     IN INTEGER, 
        p_trunc   IN INTEGER, 
        p_max     IN INTEGER, 
        p_colName IN VARCHAR2, 
        p_movie   IN INTEGER
    )
    RETURN INTEGER AS
        r_val INTEGER;
        
        BEGIN
            IF (p_val IS NOT NULL) THEN
                IF (p_val < p_min OR p_val > p_max) THEN
                    r_val := NULL;
                    LOG_PACKAGE.WriteLog('IMPORT_PACKAGE.TruncateInteger', 'Film '||p_movie
                                            ||' : champ '||p_colName||' rejeté, transformé en NULL');
                ELSE
                    IF p_val > p_trunc THEN
                        r_val := p_trunc;
                        LOG_PACKAGE.WriteLog('IMPORT_PACKAGE.TruncateInteger', 'Film '||p_movie
                                            ||' : champ '||p_colName||' tronqué');
                    ELSE
                        r_val := p_val;
                    END IF;
                END IF;
            ELSE
                r_val := NULL;
            END IF;
            RETURN r_val;
            
        EXCEPTION
            WHEN OTHERS THEN
                LOG_PACKAGE.WriteErrorLog('IMPORT_PACKAGE.TruncateInteger');
                RAISE;
    END TruncateInteger;
    
    
    -- tronquer chaine de caractères
    FUNCTION TruncateString 
    (
        p_val     IN VARCHAR2, 
        p_min     IN INTEGER, 
        p_trunc   IN INTEGER, 
        p_max     IN INTEGER, 
        p_colName IN VARCHAR2, 
        p_movie   IN INTEGER
    )
    RETURN VARCHAR2 AS
        r_val VARCHAR2(2000);
        
        BEGIN
            IF (p_val IS NOT NULL) THEN
                IF (LENGTH(p_val) < p_min OR LENGTH(p_val) > p_max) THEN
                    r_val := NULL;
                    LOG_PACKAGE.WriteLog('IMPORT_PACKAGE.TruncateString', 'Film '||p_movie
                                        ||' : champ '||p_colName||' rejeté, transformé en NULL');
                ELSE
                    IF LENGTH(p_val) > p_trunc THEN
                        r_val := SUBSTR(p_val, 1, p_trunc);
                        LOG_PACKAGE.WriteLog('IMPORT_PACKAGE.TruncateString', 'Film '||p_movie
                                        ||' : champ '||p_colName||' tronqué');
                    ELSE
                        r_val := p_val;
                    END IF;
                END IF;
            ELSE
                r_val := NULL;
            END IF;
            RETURN r_val;
            
        EXCEPTION
            WHEN OTHERS THEN
                LOG_PACKAGE.WriteErrorLog('IMPORT_PACKAGE.TruncateString');
                RAISE;
    END TruncateString;
    
    
    -- récupérer données (id, nom) groupées
    FUNCTION DecomposeDualBlock 
    (
        p_block      IN VARCHAR2, 
        p_destTable  IN VARCHAR2, 
        p_assocIdName IN VARCHAR2, 
        p_idIsString IN CHAR,
        p_idMin   IN INTEGER, p_idTrunc   IN INTEGER, p_idMax   IN INTEGER,
        p_nameMin IN INTEGER, p_nameTrunc IN INTEGER, p_nameMax IN INTEGER,
        p_movie   IN VARCHAR2
    )
    RETURN INTEGER AS
        v_curLengthTotal INTEGER;
        v_curSubpart     VARCHAR2(4000);
        v_curIdVal       VARCHAR2(4000);
        v_curIdInteger   INTEGER;
        v_curNameVal     VARCHAR2(4000);
        v_tmpCount       INTEGER;
        r_count          INTEGER;
        
        BEGIN
            -- parcourir sous-parties
            v_curLengthTotal := 0;
            r_count := 0;
            v_curSubPart := '';
            LOOP
                -- récupérer partie (mode lazy)
                v_curSubPart := regexp_substr(p_block, '(.*?)(\|\||\]\]$)', 3 + v_curLengthTotal, 1, '', 1); 
                EXIT WHEN v_curSubPart IS NULL;
                v_curLengthTotal := v_curLengthTotal + LENGTH(v_curSubPart) + 2;
                
                -- récupérer valeurs (mode lazy) + remplacer tabulations + vérifier début/fin
                v_curIdVal   := TRIM(REPLACE(regexp_substr(v_curSubPart, '(.*?)(,,|$)', 1, 1, '', 1), CHR(9), ' '));
                v_curNameVal := TRIM(REPLACE(regexp_substr(v_curSubPart, '(.*?)(,,|$)', 1, 2, '', 1), CHR(9), ' '));
                
                -- vérifier validité valeurs
                BEGIN
                    v_curNameVal := TruncateString(v_curNameVal, p_nameMin,p_nameTrunc,p_nameMax, p_destTable||'.Name', p_movie);
                    IF p_idIsString = '1' THEN
                        -- id chaine de caractères
                        v_curIdVal := TruncateString(v_curIdVal, p_idMin,p_idTrunc,p_idMax, p_destTable||'.Id', p_movie);
                    ELSE
                        -- id numérique
                        v_curIdInteger := TruncateInteger(TO_NUMBER(v_curIdVal), p_idMin,p_idTrunc,p_idMax, p_destTable||'.Id', p_movie);
                        IF v_curIdInteger IS NULL THEN
                            v_curIdVal := NULL;
                        ELSE
                            v_curIdVal := TO_CHAR(v_curIdInteger);
                        END IF;
                    END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                        LOG_PACKAGE.WriteErrorLog('IMPORT_PACKAGE.DecomposeDualBlock');
                        v_curIdVal := NULL;
                END;
                
                -- ajout des valeurs
                IF (v_curIdVal IS NULL OR v_curNameVal IS NULL) THEN -- erreur
                    LOG_PACKAGE.WriteLog('IMPORT_PACKAGE.DecomposeDualBlock', p_destTable||' (film '||p_movie||') : item rejeté car invalide');
                ELSE -- valide
                    -- vérifier existence de valeur
                    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||p_destTable||' WHERE UPPER(Name) = UPPER(:name)' INTO v_tmpCount
                        USING v_curNameVal;
                    IF v_tmpCount > 0 THEN
                        -- récupérer ID existant
                        EXECUTE IMMEDIATE 'SELECT '||p_assocIdName||' FROM '||p_destTable||' WHERE UPPER(Name) = UPPER(:name)' INTO v_curIdVal
                            USING v_curNameVal;
                    ELSE
                        -- vérifier si l'ID est disponible
                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||p_destTable||' WHERE '||p_assocIdName||' = :id' INTO v_tmpCount
                            USING v_curIdVal;
                        IF v_tmpCount > 0 THEN
                            -- ID déjà utilisé
                            LOG_PACKAGE.WriteLog('IMPORT_PACKAGE.DecomposeDualBlock', p_destTable||' (film '||p_movie||') : ID '||v_curIdVal||' déjà utilisé');
                            CONTINUE;
                        ELSE
                            -- insertion valeur
                            LOG_PACKAGE.WriteLog('IMPORT_PACKAGE.DecomposeDualBlock', 'id='||v_curIdVal||' name='||v_curNameVal);
                            EXECUTE IMMEDIATE 'INSERT INTO '||p_destTable||' ('||p_assocIdName||',Name) VALUES (:id,:name)'
                                USING v_curIdVal, v_curNameVal;
                            LOG_PACKAGE.WriteLog('IMPORT_PACKAGE.DecomposeDualBlock', p_destTable||' (film '||p_movie||') : nouveau tuple ajouté ('||v_curIdVal||')');
                        END IF;
                    END IF;
                    
                    BEGIN
                        -- insertion références dans table d'association
                        EXECUTE IMMEDIATE 'INSERT INTO MOVIE_'||p_destTable||' (IdMovie,'||p_assocIdName
                                            ||') VALUES (:movie,:id)'
                                            USING p_movie, v_curIdVal;
                        r_count := r_count + 1; -- incrémenter compteur d'insertions
                    EXCEPTION 
                        WHEN DUP_VAL_ON_INDEX THEN --vérifier existence d'association (si 2x même valeur dans le bloc)
                            LOG_PACKAGE.WriteErrorLog('IMPORT_PACKAGE.DecomposeTripleBlock');
                    END;
                END IF;
            END LOOP;
            
            RETURN r_count;
            
        EXCEPTION
            WHEN OTHERS THEN
                LOG_PACKAGE.WriteErrorLog('IMPORT_PACKAGE.DecomposeDualBlock');
                RAISE;
    END DecomposeDualBlock;
    
    
    -- récupérer données (id, nom, autre) groupées
    FUNCTION DecomposeTripleBlock 
    (
        p_block        IN VARCHAR2, 
        p_thirdCol     IN INTEGER, 
        p_thirdColName IN VARCHAR2, 
        p_destTable    IN VARCHAR2, 
        p_assocIdName IN VARCHAR2,
        p_idMin    IN INTEGER, p_idTrunc    IN INTEGER, p_idMax    IN INTEGER,
        p_nameMin  IN INTEGER, p_nameTrunc  IN INTEGER, p_nameMax  IN INTEGER,
        p_thirdMin IN INTEGER, p_thirdTrunc IN INTEGER, p_thirdMax IN INTEGER,
        p_movie    IN VARCHAR2
    )
    RETURN INTEGER AS
        v_curLengthTotal INTEGER;
        v_curSubpart     VARCHAR2(4000);
        v_curIdVal       VARCHAR2(4000);
        v_curIdInteger   INTEGER;
        v_curNameVal     VARCHAR2(4000);
        v_curThirdVal    VARCHAR2(4000);
        v_tmpCount       INTEGER;
        r_count          INTEGER;
        
        BEGIN
            -- parcourir sous-parties
            v_curLengthTotal := 0;
            r_count := 0;
            v_curSubPart := '';
            LOOP
                -- récupérer partie (mode lazy)
                v_curSubPart := regexp_substr(p_block, '(.*?)(\|\||\]\]$)', 3 + v_curLengthTotal, 1, '', 1); 
                EXIT WHEN v_curSubPart IS NULL;
                v_curLengthTotal := v_curLengthTotal + LENGTH(v_curSubPart) + 2;
                
                -- récupérer valeurs (mode lazy) + remplacer tabulations + vérifier début/fin
                v_curIdVal   := TRIM(REPLACE(regexp_substr(v_curSubPart, '(.*?)(,,|$)', 1, 1, '', 1), CHR(9), ' '));
                v_curNameVal := TRIM(REPLACE(regexp_substr(v_curSubPart, '(.*?)(,,|$)', 1, 2, '', 1), CHR(9), ' '));
                v_curThirdVal := TRIM(REPLACE(regexp_substr(v_curSubPart, '(.*?)(,,|$)', 1, p_thirdCol, '', 1), CHR(9), ' '));
                
                BEGIN
                    -- vérifier validité valeurs
                    v_curNameVal := TruncateString(v_curNameVal, p_nameMin,p_nameTrunc,p_nameMax, p_destTable||'.Name', p_movie);
                    v_curThirdVal := TruncateString(v_curThirdVal, p_thirdMin,p_thirdTrunc,p_thirdMax, 'MOVIE_'||p_destTable||'.'||p_thirdColName, p_movie);
                    -- id numérique
                    v_curIdInteger := TruncateInteger(TO_NUMBER(v_curIdVal), p_idMin,p_idTrunc,p_idMax, p_destTable||'.Id', p_movie);
                    IF v_curIdInteger IS NULL THEN
                        v_curIdVal := NULL;
                    ELSE
                        v_curIdVal := TO_CHAR(v_curIdInteger);
                    END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                        LOG_PACKAGE.WriteErrorLog('IMPORT_PACKAGE.DecomposeTripleBlock');
                        v_curIdVal := NULL;
                END;
                
                -- ajout des valeurs
                IF (v_curIdVal IS NULL OR v_curNameVal IS NULL OR v_curThirdVal IS NULL) THEN -- erreur
                    LOG_PACKAGE.WriteLog('IMPORT_PACKAGE.DecomposeTripleBlock', p_destTable||' (film '||p_movie||') : item rejeté car invalide');
                ELSE -- valide
                    -- vérifier existence de valeur
                    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||p_destTable||' WHERE UPPER(Name) = UPPER(:name)' INTO v_tmpCount
                        USING v_curNameVal;
                    IF v_tmpCount > 0 THEN
                        -- récupérer ID existant
                        EXECUTE IMMEDIATE 'SELECT '||p_assocIdName||' FROM '||p_destTable||' WHERE UPPER(Name) = UPPER(:name)' INTO v_curIdVal
                            USING v_curNameVal;
                    ELSE
                        -- vérifier si l'ID est disponible
                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||p_destTable||' WHERE '||p_assocIdName||' = :id' INTO v_tmpCount
                            USING v_curIdVal;
                        IF v_tmpCount > 0 THEN
                            -- ID déjà utilisé
                            LOG_PACKAGE.WriteLog('IMPORT_PACKAGE.DecomposeTripleBlock', p_destTable||' (film '||p_movie||') : ID '||v_curIdVal||' déjà utilisé');
                            CONTINUE;
                        ELSE
                            -- insertion valeur
                            EXECUTE IMMEDIATE 'INSERT INTO '||p_destTable||' ('||p_assocIdName||',Name) VALUES (:id,:name)'
                                USING v_curIdVal, v_curNameVal;
                            LOG_PACKAGE.WriteLog('IMPORT_PACKAGE.DecomposeTripleBlock', p_destTable||' (film '||p_movie||') : nouveau tuple ajouté ('||v_curIdVal||')');
                        END IF;
                    END IF;
                    
                    BEGIN
                        -- insertion références dans table d'association
                        EXECUTE IMMEDIATE 'INSERT INTO MOVIE_'||p_destTable||' (IdMovie,'||p_assocIdName||','||p_thirdColName
                                            ||') VALUES (:movie,:id,:third)' 
                                            USING p_movie, v_curIdVal, v_curThirdVal;
                        r_count := r_count + 1; -- incrémenter compteur d'insertions
                    EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN --vérifier existence d'association (si 2x même valeur dans le bloc)
                            LOG_PACKAGE.WriteErrorLog('IMPORT_PACKAGE.DecomposeTripleBlock');
                    END;
                END IF;
            END LOOP;
            
            RETURN r_count;
            
        EXCEPTION
            WHEN OTHERS THEN
                LOG_PACKAGE.WriteErrorLog('IMPORT_PACKAGE.DecomposeTripleBlock');
                RAISE;
    END DecomposeTripleBlock;
    
END IMPORT_PACKAGE;
/

