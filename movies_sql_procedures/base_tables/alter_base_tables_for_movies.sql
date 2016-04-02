-- Modifications de tables de base pour CreaCB
-- Romain VINDERS - 2322

-- AJOUT DE CLE ETRANGERE POUR LES FILMS ---------------------------------------

ALTER TABLE USER_REVIEWS ADD CONSTRAINT USER_REVIEWS_IDMOVIE_FK
    FOREIGN KEY (IdMovie)
    REFERENCES MOVIES(IdMovie) ON DELETE CASCADE;
