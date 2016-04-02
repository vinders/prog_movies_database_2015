-- Recherche de films
-- PART 6 - RechFilm
-- Romain VINDERS - 2322

-- SCRIPT DE CREATION ET INITIALISATION ----------------------------------------

CONNECT CB/dummy
@cb/eval_movies/find_movies
DISCONNECT;
CONNECT CBB/dummy
@cbb/eval_movies/find_movies
DISCONNECT;
