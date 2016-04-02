-- Table externe
-- Romain VINDERS - 2322

DROP table movies_ext CASCADE CONSTRAINTS;

-- table externe
create table movies_ext (
  id integer,
  title varchar2(2000),
  original_title varchar2(2000),
  release_date date,
  status varchar2(30),
  vote_average number(3,1),
  vote_count integer,
  runtime integer,
  certification varchar2(30),
  poster_path varchar2(100),
  budget integer,
  revenue integer,
  homepage varchar2(1000),
  tagline varchar2(2000),
  overview varchar2(2000),
  genres varchar2(1000),
  directors varchar2(4000),
  actors clob,
  production_companies varchar2(1000),
  production_countries varchar2(1000),
  spoken_languages varchar2(1000)
)
organization external (
  type oracle_loader
  default directory TMDB
  access parameters (
    records delimited by "\n"
    characterset "AL32UTF8"
    string sizes are in characters
    fields terminated by '@|@'
    missing field values are null
    (
      id unsigned integer external,
      title char(2000),
      original_title char(2000),
      release_date char(10) date_format date mask "yyyy-mm-dd",
      status char(30),
      vote_average float external,
      vote_count unsigned integer external,
      runtime unsigned integer external,
      certification char(30),
      poster_path char(100),
      budget unsigned integer external,
      revenue unsigned integer external,
      homepage char(1000),
      tagline char(2000),
      overview char(2000),
      genres char(1000),
      directors char(4000),
      actors char(20000),
      production_companies char(1000),
      production_countries char(1000),
      spoken_languages char(1000)
    )
  )
  location('movies.txt')
)
reject limit unlimited
;
