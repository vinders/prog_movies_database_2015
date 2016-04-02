-- Importation des tuples
-- PART 3 - AlimCB
-- Romain VINDERS - 2322

-- SCRIPT DE CREATION ET INITIALISATION ----------------------------------------

-- ...
CONNECT CB/dummy
CREATE OR REPLACE DIRECTORY TMDB AS 'C:\Users\Romain\Desktop\SGBD\res';
@movies_tables/movies_external_table
@movies_tables/import_movies
EXEC IMPORT_PACKAGE.ImportMovies(10);
DISCONNECT;
