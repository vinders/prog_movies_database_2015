-- Création des tables pour les films
-- Romain VINDERS - 2322

-- effacer clés étrangères
ALTER TABLE USER_REVIEWS DROP CONSTRAINT USER_REVIEWS_IDMOVIE_FK;

-- effacer tables si existantes
DROP SEQUENCE CERTIFICATIONS_SEQ;
DROP SEQUENCE MOVIES_STATUS_SEQ;
DROP TABLE MOVIE_COUNTRIES CASCADE CONSTRAINTS;
DROP TABLE MOVIE_LANGUAGES CASCADE CONSTRAINTS;
DROP TABLE MOVIE_GENRES CASCADE CONSTRAINTS;
DROP TABLE MOVIE_ACTORS CASCADE CONSTRAINTS;
DROP TABLE MOVIE_DIRECTORS CASCADE CONSTRAINTS;
DROP TABLE MOVIE_PROD_COMPS CASCADE CONSTRAINTS;
DROP TABLE MOVIES CASCADE CONSTRAINTS;
DROP TABLE ACTORS CASCADE CONSTRAINTS;
DROP TABLE DIRECTORS CASCADE CONSTRAINTS;
DROP TABLE PROD_COMPS CASCADE CONSTRAINTS;
DROP TABLE MOVIES_STATUS CASCADE CONSTRAINTS;
DROP TABLE LANGUAGES CASCADE CONSTRAINTS;
DROP TABLE COUNTRIES CASCADE CONSTRAINTS;
DROP TABLE GENRES CASCADE CONSTRAINTS;
DROP TABLE CERTIFICATIONS CASCADE CONSTRAINTS;

-- CREATION DES TABLES ---------------------------------------------------------

-- pays
CREATE TABLE COUNTRIES
(
    IsoCountry  VARCHAR2(2)     CONSTRAINT COUNTRIES_PK      PRIMARY KEY,
    Name        VARCHAR2(24)    CONSTRAINT COUNTRIES_NAME_NN NOT NULL
                                CONSTRAINT COUNTRIES_NAME_U  UNIQUE
);

-- langues
CREATE TABLE LANGUAGES
(
    IsoLang     VARCHAR2(2)     CONSTRAINT LANGUAGES_PK      PRIMARY KEY,
    Name        VARCHAR2(11)    CONSTRAINT LANGUAGES_NAME_NN NOT NULL
                                CONSTRAINT LANGUAGES_NAME_U  UNIQUE
);

-- genres
CREATE TABLE GENRES
(
    IdGenre     NUMBER(5)       CONSTRAINT GENRES_PK      PRIMARY KEY,
    Name        VARCHAR2(16)    CONSTRAINT GENRES_NAME_NN NOT NULL -- nombre réduit -> pas de troncature -> longueur max
                                CONSTRAINT GENRES_NAME_U  UNIQUE
);

-- certifications
CREATE TABLE CERTIFICATIONS
(
    IdCertif    NUMBER(3)       CONSTRAINT CERTIFICATIONS_PK PRIMARY KEY, -- 3 carac. = lettre + 2 chiffres
    Name        VARCHAR2(12)    CONSTRAINT CERTIFICATIONS_NAME_NN NOT NULL -- nombre réduit -> pas de troncature -> longueur max
                                CONSTRAINT CERTIFICATIONS_NAME_U  UNIQUE
);
CREATE SEQUENCE CERTIFICATIONS_SEQ; -- séquence d'autoincrémentation d'ID

-- statuts
CREATE TABLE MOVIES_STATUS
(
    IdStatus    NUMBER(2)       CONSTRAINT MOVIES_STATUS_PK  PRIMARY KEY, -- 3 carac. = lettre + 2 chiffres
    Name        VARCHAR2(15)    CONSTRAINT MOVIES_STATUS_NAME_NN NOT NULL -- nombre réduit -> pas de troncature -> longueur max
                                CONSTRAINT MOVIES_STATUS_NAME_U  UNIQUE
);
CREATE SEQUENCE MOVIES_STATUS_SEQ; -- séquence d'autoincrémentation d'ID

-- acteurs
CREATE TABLE ACTORS
(
    IdActor     NUMBER(7)       CONSTRAINT ACTORS_PK        PRIMARY KEY,
    Name        VARCHAR2(36)    CONSTRAINT ACTORS_NAME_NN   NOT NULL
                                CONSTRAINT ACTORS_NAME_U  UNIQUE
);
-- directeurs
CREATE TABLE DIRECTORS
(
    IdDirector  NUMBER(7)       CONSTRAINT DIRECTORS_PK      PRIMARY KEY,
    Name        VARCHAR2(23)    CONSTRAINT DIRECTORS_NAME_NN NOT NULL
                                CONSTRAINT DIRECTORS_NAME_U  UNIQUE
);
-- producteurs
CREATE TABLE PROD_COMPS
(
    IdComp      NUMBER(5)       CONSTRAINT PROD_COMPS_PK      PRIMARY KEY,
    Name        VARCHAR2(44)    CONSTRAINT PROD_COMPS_NAME_NN NOT NULL
                                CONSTRAINT PROD_COMPS_NAME_U  UNIQUE
);

-- films
CREATE TABLE MOVIES
(
    IdMovie     NUMBER(6)       CONSTRAINT MOVIES_PK        PRIMARY KEY,
    Title       VARCHAR2(58)    CONSTRAINT MOVIES_TITLE_NN  NOT NULL,
    -- titre pas unique (il existe films de même nom, par ex. certains remakes)
    TitleOrig   VARCHAR2(59)    CONSTRAINT MOVIES_TITLEORIG_NN NOT NULL,
    ReleaseDate DATE,           -- plus d'un dixième des films du fichier n'ont pas de date -> null accepté
    IdStatus    NUMBER(2)       CONSTRAINT MOVIES_IDSTATUS_NN NOT NULL
                                CONSTRAINT MOVIES_IDSTATUS_FK 
                                REFERENCES MOVIES_STATUS(IdStatus) ON DELETE CASCADE,
    VoteAverage NUMBER(2,1)     CONSTRAINT MOVIES_VOTEAVG_NN NOT NULL
                                CONSTRAINT MOVIES_VOTEAVG_CH CHECK(VoteAverage >= 0 AND VoteAverage <= 10),
    VoteCount   NUMBER(4)       CONSTRAINT MOVIES_VOTECOUNT_NN NOT NULL, 
    -- nombre de votes ne fera qu'augmenter -> on prend exceptionnellement le max plutôt que 99 percentile
    Runtime     NUMBER(3),      -- plus d'un dixième des films du fichier n'ont pas de runtime -> null accepté
    IdCertif    NUMBER(3)       -- 9 films sur 10 du fichier n'ont pas de certification -> null accepté
                                CONSTRAINT MOVIES_IDCERTIF_FK   
                                REFERENCES CERTIFICATIONS(IdCertif) ON DELETE CASCADE,
    PosterPath  VARCHAR2(32),   -- un tiers des films du fichier n'ont pas de posterpath -> null accepté
    Budget      NUMBER(8),      -- nombreuses valeurs à zéro -> considérées comme nulles
    Revenue     NUMBER(8),      -- nombreuses valeurs à zéro -> considérées comme nulles
    Homepage    VARCHAR2(122),  -- 9 films sur 10 du fichier n'ont pas de homepage -> null accepté
    Tagline     VARCHAR2(172),  -- 9 films sur 10 du fichier n'ont pas de tagline -> null accepté
    Overview    VARCHAR2(949),  -- un huitième des films du fichier n'ont pas d'overview -> null accepté
    
    SyncToken   CHAR(1) DEFAULT '0' CONSTRAINT MOVIES_SYNCTOKEN_NN NOT NULL
);

-- CREATION DES TABLES D'ASSOCIATION -------------------------------------------

-- pays par film
CREATE TABLE MOVIE_COUNTRIES
(
    IdMovie         NUMBER(6)       CONSTRAINT MOVIE_COUNTRIES_IDMOVIE_FK    
                                    REFERENCES MOVIES(IdMovie) ON DELETE CASCADE,
    IsoCountry      VARCHAR2(2)     CONSTRAINT MOVIE_COUNTRIES_ISOCOUNTRY_FK 
                                    REFERENCES COUNTRIES(IsoCountry) ON DELETE CASCADE,
    CONSTRAINT MOVIE_COUNTRIES_PK   PRIMARY KEY(IdMovie, IsoCountry)
);
-- langues par film
CREATE TABLE MOVIE_LANGUAGES
(
    IdMovie         NUMBER(6)       CONSTRAINT MOVIE_LANGUAGES_IDMOVIE_FK    
                                    REFERENCES MOVIES(IdMovie) ON DELETE CASCADE,
    IsoLang         VARCHAR2(2)     CONSTRAINT MOVIE_LANGUAGES_ISOLANG_FK    
                                    REFERENCES LANGUAGES(IsoLang) ON DELETE CASCADE,
    CONSTRAINT MOVIE_LANGUAGES_PK   PRIMARY KEY(IdMovie, IsoLang)
);
-- genres par film
CREATE TABLE MOVIE_GENRES
(
    IdMovie         NUMBER(6)       CONSTRAINT MOVIE_GENRES_IDMOVIE_FK    
                                    REFERENCES MOVIES(IdMovie) ON DELETE CASCADE,
    IdGenre         NUMBER(5)       CONSTRAINT MOVIE_GENRES_IDGENRE_FK    
                                    REFERENCES GENRES(IdGenre) ON DELETE CASCADE,
    CONSTRAINT MOVIE_GENRES_PK   PRIMARY KEY(IdMovie, IdGenre)
);
-- acteurs/personnages par film
CREATE TABLE MOVIE_ACTORS
(
    IdMovie         NUMBER(6)       CONSTRAINT MOVIE_ACTORS_IDMOVIE_NN NOT NULL
                                    CONSTRAINT MOVIE_ACTORS_IDMOVIE_FK    
                                    REFERENCES MOVIES(IdMovie) ON DELETE CASCADE,
    IdActor         NUMBER(7)       CONSTRAINT MOVIE_ACTORS_IDACTOR_NN NOT NULL
                                    CONSTRAINT MOVIE_ACTORS_IDACTOR_FK    
                                    REFERENCES ACTORS(IdActor) ON DELETE CASCADE,
    CharacterName   VARCHAR2(36)    CONSTRAINT MOVIE_ACTORS_NAME_NN NOT NULL,
    -- clé primaire triple, car un même acteur peut interpréter plusieurs rôles dans certains films (ex: Austin Powers)
    CONSTRAINT MOVIE_MOVIE_ACTORS_PK  PRIMARY KEY(IdMovie, IdActor, CharacterName)
);
-- directeurs par film
CREATE TABLE MOVIE_DIRECTORS
(
    IdMovie         NUMBER(6)       CONSTRAINT MOVIE_DIRECTORS_IDMOVIE_FK    
                                    REFERENCES MOVIES(IdMovie) ON DELETE CASCADE,
    IdDirector      NUMBER(7)       CONSTRAINT MOVIE_DIRECTORS_IDDIRECTOR_FK    
                                    REFERENCES DIRECTORS(IdDirector) ON DELETE CASCADE,
    CONSTRAINT MOVIE_DIRECTORS_PK   PRIMARY KEY(IdMovie, IdDirector)
);
-- producteurs par film
CREATE TABLE MOVIE_PROD_COMPS
(
    IdMovie         NUMBER(6)       CONSTRAINT MOVIE_PROD_COMPS_IDMOVIE_FK    
                                    REFERENCES MOVIES(IdMovie) ON DELETE CASCADE,
    IdComp          NUMBER(5)       CONSTRAINT MOVIE_PROD_COMPS_IDCOMP_FK    
                                    REFERENCES PROD_COMPS(IdComp) ON DELETE CASCADE,
    CONSTRAINT MOVIE_PROD_COMPS_PK  PRIMARY KEY(IdMovie, IdComp)
);

-- CONTRAINTES APPLICATIVES ----------------------------------------------------

-- MOVIE_COUNTRIES : au moins 1 pays par film
--      EXISTS(SELECT IsoCountry FROM MOVIE_COUNTRIES WHERE IdMovie = :new.IdMovie)

-- MOVIE_LANGUAGES : au moins 1 langue par film
--      EXISTS(SELECT IsoLang FROM MOVIE_LANGUAGES WHERE IdMovie = :new.IdMovie)

-- MOVIE_GENRES : au moins 1 genre par film
--      EXISTS(SELECT IdGenre FROM MOVIE_GENRES WHERE IdMovie = :new.IdMovie)

-- MOVIE_ACTORS : au moins 1 acteur par film
--      EXISTS(SELECT IdActor FROM MOVIE_ACTORS WHERE IdMovie = :new.IdMovie)

-- MOVIE_DIRECTORS : au moins 1 directeur par film
--      EXISTS(SELECT IdDirector FROM MOVIE_DIRECTORS WHERE IdMovie = :new.IdMovie)

-- MOVIE_PROD_COMPS : au moins 1 producteur par film
--      EXISTS(SELECT IdComp FROM MOVIE_PROD_COMPS WHERE IdMovie = :new.IdMovie)
