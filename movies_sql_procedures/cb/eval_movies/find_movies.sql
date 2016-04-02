-- Recherche de films (RechFilm)
-- Romain VINDERS - 2322

DROP PACKAGE SEARCH_PACKAGE;
DROP TYPE MovieObj_t;
DROP TYPE VotesList_t;
-- types
CREATE OR REPLACE TYPE StringArray_t IS TABLE OF VARCHAR2(4000);
/
CREATE OR REPLACE TYPE VoteListItem_t AS OBJECT
(
    IdVote      INTEGER,
    Login       VARCHAR2(30),
    ReviewDate  TIMESTAMP,
    Rating      INTEGER,
    Review      VARCHAR2(200)
);
/
CREATE OR REPLACE TYPE VotesList_t IS TABLE OF VoteListItem_t;
/
CREATE OR REPLACE TYPE MovieObj_t AS OBJECT
(
    IdMovie       INTEGER,
    Title         VARCHAR2(58),
    TitleOrig     VARCHAR2(59),
    ReleaseDate   INTEGER, 
    VoteAverageTmdb NUMBER(2,1),
    VoteCountTmdb   NUMBER(4),
    VoteAverageApp  NUMBER(2,1),
    VoteCountApp    INTEGER,
    Runtime       NUMBER(3),
    PosterPath    VARCHAR2(32),
    Budget        NUMBER(8),
    Revenue       NUMBER(8),
    Overview      VARCHAR2(949),
    Status        VARCHAR2(15),
    Certification VARCHAR2(12),
    Genres        StringArray_t,
    Actors        StringArray_t,
    Characters    StringArray_t,
    Directors     StringArray_t,
    ProdComps     StringArray_t,
    Countries     StringArray_t,
    Languages     StringArray_t
);
/

-- spécification du package ----------------------------------------------------
CREATE OR REPLACE PACKAGE SEARCH_PACKAGE AS 
    PROCEDURE GetMovieById -- récupérer les informations d'un film selon son ID
    (
        p_movieId   IN INTEGER,
        r_val       OUT MovieObj_t
    );
    PROCEDURE FindMovies -- trouver des films selon des critères
    (
        p_title   IN VARCHAR2, 
        p_year    IN VARCHAR2,
        p_yearMin IN VARCHAR2,
        p_yearMax IN VARCHAR2,
        p_actorsNb IN INTEGER, 
        p_actors   IN StringArray_t, 
        p_directorsNb IN INTEGER, 
        p_directors   IN StringArray_t,
        r_cursor   OUT sys_refcursor
    );
    PROCEDURE GetVotes -- récupérer une page de votes pour un film
    (
        p_movie  IN INTEGER,
        p_page   IN INTEGER,
        r_array  OUT VotesList_t
    );
END SEARCH_PACKAGE;
/

-- corps du package ----------------------------------------------------
CREATE OR REPLACE PACKAGE BODY SEARCH_PACKAGE AS 
    -- récupérer les informations d'un film selon son ID
    PROCEDURE GetMovieById 
    (
        p_movieId   IN INTEGER,
        r_val       OUT MovieObj_t
    ) AS
        v_tmpNb    INTEGER;
        
        BEGIN
            r_val := MovieObj_t(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
        
            -- récupérer film
            SELECT IdMovie,Title,TitleOrig,EXTRACT(YEAR FROM ReleaseDate) AS ReleaseDate,MOVIES_STATUS.Name AS Status,CERTIFICATIONS.Name AS Certif,
                   VoteAverage,VoteCount,Runtime,PosterPath,Budget,Revenue,Overview
                INTO r_val.IdMovie,r_val.Title,r_val.TitleOrig,r_val.ReleaseDate,
                     r_val.Status,r_val.Certification,
                     r_val.VoteAverageTmdb,r_val.VoteCountTmdb,
                     r_val.Runtime,r_val.PosterPath,r_val.Budget,r_val.Revenue,r_val.Overview
                FROM MOVIES
                LEFT JOIN MOVIES_STATUS ON MOVIES.IdStatus = MOVIES_STATUS.IdStatus
                LEFT JOIN CERTIFICATIONS ON MOVIES.IdCertif = CERTIFICATIONS.IdCertif
                WHERE IdMovie = p_movieId;
            LOG_PACKAGE.WriteLog('SEARCH_PACKAGE.GetMovieById', 'Film '||p_movieId||' récupéré');
            
            -- votes
            SELECT COALESCE(AVG(Rating),0.0), COUNT(*) INTO r_val.VoteAverageApp, r_val.VoteCountApp
                FROM USER_REVIEWS
                WHERE IdMovie = p_movieId;
            -- genres
            SELECT Name BULK COLLECT INTO r_val.Genres
                FROM MOVIE_GENRES
                NATURAL JOIN GENRES
                WHERE IdMovie = p_movieId;
            -- acteurs
            SELECT Name, CharacterName BULK COLLECT INTO r_val.Actors, r_val.Characters
                FROM MOVIE_ACTORS
                NATURAL JOIN ACTORS
                WHERE IdMovie = p_movieId;
            -- directeurs
            SELECT Name BULK COLLECT INTO r_val.Directors
                FROM MOVIE_DIRECTORS
                NATURAL JOIN DIRECTORS
                WHERE IdMovie = p_movieId;
            -- producteurs
            SELECT Name BULK COLLECT INTO r_val.ProdComps
                FROM MOVIE_PROD_COMPS
                NATURAL JOIN PROD_COMPS
                WHERE IdMovie = p_movieId;
            -- pays
            SELECT Name BULK COLLECT INTO r_val.Countries
                FROM MOVIE_COUNTRIES
                NATURAL JOIN COUNTRIES
                WHERE IdMovie = p_movieId;
            -- langues
            SELECT Name BULK COLLECT INTO r_val.Languages
                FROM MOVIE_LANGUAGES
                NATURAL JOIN LANGUAGES
                WHERE IdMovie = p_movieId;
            
        EXCEPTION
            -- film non trouvé
            WHEN NO_DATA_FOUND THEN
                LOG_PACKAGE.WriteLog('SEARCH_PACKAGE.GetMovieById', 'Film '||p_movieId||' non trouvé');
                r_val := NULL;
            -- erreur
            WHEN OTHERS THEN
                LOG_PACKAGE.WriteErrorLog('SEARCH_PACKAGE.GetMovieById');
                RAISE;
    END GetMovieById;
    
    
    
    -- trouver des films selon des critères
    PROCEDURE FindMovies 
    (
        p_title   IN VARCHAR2, 
        p_year    IN VARCHAR2,
        p_yearMin IN VARCHAR2,
        p_yearMax IN VARCHAR2,
        p_actorsNb IN INTEGER, 
        p_actors   IN StringArray_t, 
        p_directorsNb IN INTEGER, 
        p_directors   IN StringArray_t,
        r_cursor    OUT sys_refcursor
    ) AS
        v_i       INTEGER;
        v_request VARCHAR(32000);
        v_yearMin INTEGER;
        v_yearMax INTEGER;
        
        BEGIN
            -- requête de base
            v_request := 'SELECT IdMovie, Title, EXTRACT(YEAR FROM ReleaseDate) AS Year FROM MOVIES BASEMOVIES WHERE 1=1';
            
            -- filtrer selon l'année
            IF p_year IS NOT NULL THEN
                v_request := v_request||' AND ReleaseDate IS NOT NULL'
                                      ||' AND EXTRACT(YEAR FROM ReleaseDate) = '||p_year;
            ELSE
                IF p_yearMin IS NOT NULL THEN
                    IF p_yearMax IS NOT NULL THEN
                        v_yearMin := TO_NUMBER(p_yearMin) + 1;
                        v_yearMax := TO_NUMBER(p_yearMax) - 1;
                        v_request := v_request||' AND ReleaseDate IS NOT NULL'
                                              ||' AND EXTRACT(YEAR FROM ReleaseDate) BETWEEN '
                                              ||v_yearMin||' AND '||v_yearMax;
                    ELSE
                        v_request := v_request||' AND ReleaseDate IS NOT NULL'
                                              ||' AND EXTRACT(YEAR FROM ReleaseDate) > '||p_yearMin;
                    END IF;
                ELSE
                    IF p_yearMax IS NOT NULL THEN
                        v_request := v_request||' AND ReleaseDate IS NOT NULL'
                                              ||' AND EXTRACT(YEAR FROM ReleaseDate) < '||p_yearMax;
                    END IF;
                END IF;
            END IF;
            
            -- filtrer selon le titre
            IF p_title IS NOT NULL AND LENGTH(p_title) > 0 THEN
                v_request := v_request||' AND UPPER(Title) LIKE ''%'||UPPER(REPLACE(p_title,'''','_'))||'%'' ';
                -- REPLACE = protection contre injections SQL
            END IF;
        
            -- filtrer selon les acteurs
            IF p_actorsNb > 0 THEN
                v_i := 1;
                LOOP
                    EXIT WHEN v_i > p_actorsNb;
                    
                    v_request := v_request||' AND EXISTS(SELECT * FROM ACTORS RIGHT JOIN MOVIE_ACTORS'
                                      ||' ON ACTORS.IdActor=MOVIE_ACTORS.IdActor'
                                      ||' WHERE MOVIE_ACTORS.IdMovie = BASEMOVIES.IdMovie'
                                      ||' AND UPPER(ACTORS.Name) LIKE ''%'||UPPER(REPLACE(p_actors(v_i),'''','_'))||'%'')';
                    v_i := v_i + 1;
                END LOOP;
            END IF;
            
            -- filtrer selon les directeurs
            IF p_directorsNb > 0 THEN
                v_i := 1;
                LOOP
                    EXIT WHEN v_i > p_directorsNb;
                    
                    v_request := v_request||' AND EXISTS(SELECT * FROM DIRECTORS RIGHT JOIN MOVIE_DIRECTORS'
                                      ||' ON DIRECTORS.IdDirector=MOVIE_DIRECTORS.IdDirector'
                                      ||' WHERE MOVIE_DIRECTORS.IdMovie = BASEMOVIES.IdMovie'
                                      ||' AND UPPER(DIRECTORS.Name) LIKE ''%'||UPPER(REPLACE(p_directors(v_i),'''','_'))||'%'')';
                    v_i := v_i + 1;
                END LOOP;
            END IF;
            
            -- exécuter la requête (curseur dynamique)
            OPEN r_cursor FOR v_request;
            
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                LOG_PACKAGE.WriteLog('SEARCH_PACKAGE.FindMovies', 'Aucun resultat trouvé');
            WHEN OTHERS THEN
                LOG_PACKAGE.WriteErrorLog('SEARCH_PACKAGE.FindMovies');
                RAISE;
    END FindMovies;
    
    
    -- récupérer une page de votes pour un film
    PROCEDURE GetVotes
    (
        p_movie  IN INTEGER,
        p_page   IN INTEGER,
        r_array  OUT VotesList_t
    ) AS
        v_start INTEGER;
        v_end   INTEGER;
        
        BEGIN
            r_array := VotesList_t();
        
            v_end := p_page*5;
            v_start := v_end - 4;
            SELECT VoteListItem_t(IdVote, Login, ReviewDate, Rating, Review)
                BULK COLLECT INTO r_array FROM
                    (SELECT ROWNUM AS IdVote, Login, ReviewDate, Rating, Review
                    FROM USER_REVIEWS
                    INNER JOIN USERS ON USER_REVIEWS.IdUser=USERS.IdUser
                    WHERE IdMovie=p_movie
                    ORDER BY ReviewDate)
                WHERE IdVote BETWEEN v_start AND v_end;
        
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                LOG_PACKAGE.WriteLog('SEARCH_PACKAGE.GetVotes', 'Aucun resultat trouvé');
                r_array := NULL;
            WHEN OTHERS THEN
                LOG_PACKAGE.WriteErrorLog('SEARCH_PACKAGE.GetVotes');
                RAISE;
    END GetVotes;
    
END SEARCH_PACKAGE;
/
