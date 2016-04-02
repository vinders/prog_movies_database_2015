-- Evaluation de films
-- PART 6 - EvalFilm
-- Romain VINDERS - 2322

-- SCRIPT DE CREATION ET INITIALISATION ----------------------------------------

CONNECT CB/dummy
@cb/eval_movies/eval_movies
DISCONNECT;

CONNECT CBB/dummy
@cbb/eval_movies/eval_movies
DISCONNECT;
