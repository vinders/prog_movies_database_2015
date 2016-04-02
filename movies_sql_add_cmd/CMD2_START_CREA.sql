-- Création des éléments
-- PART 2 - CreaCB
-- Romain VINDERS - 2322

-- SCRIPT DE CREATION ET INITIALISATION ----------------------------------------

-- créer tables films
CONNECT CB/dummy
@movies_tables/create_movies_tables
DISCONNECT;
CONNECT CBB/dummy
@movies_tables/create_movies_tables
DISCONNECT;

-- modification clé étrangère des avis
CONNECT CB/dummy
@base_tables/alter_base_tables_for_movies
DISCONNECT;
CONNECT CBB/dummy
@base_tables/alter_base_tables_for_movies
DISCONNECT;