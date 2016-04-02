-- Statistiques des tables pour les films
-- Romain VINDERS - 2322

DROP PACKAGE STATS_PACKAGE;
-- types personnalisés
DROP TYPE NumberArray;
DROP TYPE StringArray;
CREATE OR REPLACE TYPE NumberArray IS TABLE OF NUMBER;
/
CREATE OR REPLACE TYPE StringArray IS TABLE OF VARCHAR2(8000);
/

-- spécification du package ----------------------------------------------------
CREATE OR REPLACE PACKAGE STATS_PACKAGE AS 
    -- procédures
    PROCEDURE WriteStats -- écriture de résultats dans fichier
	(
        p_col       IN VARCHAR2,
        p_alt       IN VARCHAR2,
        p_filename  IN VARCHAR2,
        p_title     IN VARCHAR2
	);
    PROCEDURE WriteStatsArray -- écriture de tableau de résultats dans fichier
	(
        p_values    IN NumberArray,
        p_alt       IN StringArray,
        p_filename  IN VARCHAR2,
        p_title     IN VARCHAR2
	);
    PROCEDURE GetValues -- longueurs valeurs numériques directes
	(
        p_col       IN VARCHAR2
	);
    PROCEDURE GetValuesLengths -- longueurs chaines de caractères directes
    (
        p_col       IN VARCHAR2
    );
    PROCEDURE GetSubvalues -- sous-valeurs (longueurs caractères/nombres)
    (
        p_col       IN VARCHAR2,
        p_subName   IN VARCHAR2,
        p_subIndex  IN INTEGER
    );
    PROCEDURE GetSubvaluesLengths -- sous-valeurs (longueurs caractères/nombres)
    (
        p_col       IN VARCHAR2,
        p_subName   IN VARCHAR2,
        p_subIndex  IN INTEGER
    );
END STATS_PACKAGE;
/

-- corps du package ------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY STATS_PACKAGE AS

    -- écriture de résultats dans fichier
    PROCEDURE WriteStats
    (
        p_col       IN VARCHAR2,
        p_alt       IN VARCHAR2,    
        p_filename  IN VARCHAR2,
        p_title     IN VARCHAR2
	) AS
        v_textFile  sys.utl_file.file_type;
        v_average   NUMBER; -- moyenne
        v_variance  NUMBER; -- variance
        v_stdDev    NUMBER; -- écart type
        v_median    NUMBER; -- médiane
        v_min       NUMBER;
        v_max       NUMBER;
        v_count     INTEGER;
        v_countNull INTEGER;
        v_countZero INTEGER;
        v_99quant   NUMBER;
        v_999quant  NUMBER;
        v_9999quant NUMBER;
        v_different NUMBER;
        
        BEGIN
            -- ouverture du fichier
            v_textFile := sys.utl_file.fopen('TMDB', p_filename, 'W');
            -- en-tête du fichier
            sys.utl_file.put_line(v_textFile, 'SGBD - Romain VINDERS - 2322');
            sys.utl_file.put_line(v_textFile, 'FICHIER DE STATISTIQUES : ' || p_title);
            sys.utl_file.put_line(v_textFile, '----------------------------------------------');
            
            -- calculs statistiques
            EXECUTE IMMEDIATE 'SELECT AVG('||p_col||'), VARIANCE('||p_col||'), STDDEV('||p_col
                                    ||'), MIN('||p_col||'), MAX('||p_col||'), COUNT('||p_col
                                    ||') FROM movies_ext'
                                    INTO v_average, v_variance, v_stdDev, v_min, v_max, v_count;
            EXECUTE IMMEDIATE 'SELECT percentile_cont(0.5) within group (order by '||p_col
                                ||') value, percentile_cont(0.99) within group (order by '||p_col
                                ||') value, percentile_cont(0.999) within group (order by '||p_col
                                ||') value, percentile_cont(0.9999) within group (order by '||p_col
                                ||') value FROM movies_ext'
                                INTO v_median, v_99quant, v_999quant, v_9999quant;
            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM movies_ext WHERE '||p_col
                                    ||' IS NULL' INTO v_countNull;
            EXECUTE IMMEDIATE 'SELECT COUNT('||p_col||') FROM movies_ext WHERE '||p_col
                                    ||' IS NOT NULL AND '||p_col||' = 0' INTO v_countZero;
            IF p_alt IS NOT NULL THEN
                EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM (SELECT DISTINCT '||p_alt||' FROM movies_ext)' INTO v_different;
            ELSE
                EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM (SELECT DISTINCT '||p_col||' FROM movies_ext)' INTO v_different;
            END IF;
                  
            -- écriture des résultats
            sys.utl_file.put_line(v_textFile, 'Moyenne       = ' || v_average);
            sys.utl_file.put_line(v_textFile, 'Variance      = ' || v_variance);
            sys.utl_file.put_line(v_textFile, 'Ecart-type    = ' || v_stdDev);
            sys.utl_file.put_line(v_textFile, 'Mediane       = ' || v_median);
            sys.utl_file.put_line(v_textFile, 'Minimum       = ' || v_min);
            sys.utl_file.put_line(v_textFile, 'Maximum       = ' || v_max);
            sys.utl_file.put_line(v_textFile, 'Nombre total  = ' || (v_count + v_countNull));
            sys.utl_file.put_line(v_textFile, 'Nombre nuls   = ' || v_countNull);
            sys.utl_file.put_line(v_textFile, 'Non nuls      = ' || v_count);
            sys.utl_file.put_line(v_textFile, 'Valeurs zero  = ' || v_countZero);
            sys.utl_file.put_line(v_textFile, 'Valeurs diff. = ' || v_different);
            sys.utl_file.put_line(v_textFile, '99e precent.  = ' || v_99quant);
            sys.utl_file.put_line(v_textFile, '999e 1000-qu. = ' || v_999quant);
            sys.utl_file.put_line(v_textFile, '9999e 10000-q = ' || v_9999quant);
            sys.utl_file.fclose(v_textFile);
        
        EXCEPTION
            WHEN OTHERS THEN RAISE;
    END WriteStats;

    -- écriture de résultats dans fichier
    PROCEDURE WriteStatsArray
    (
        p_values    IN NumberArray,
        p_alt       IN StringArray,
        p_filename  IN VARCHAR2,
        p_title     IN VARCHAR2
	) AS
        v_textFile  sys.utl_file.file_type;
        v_average   NUMBER; -- moyenne
        v_variance  NUMBER; -- variance
        v_stdDev    NUMBER; -- écart type
        v_median    NUMBER; -- médiane
        v_min       NUMBER;
        v_max       NUMBER;
        v_count     INTEGER;
        v_countNull INTEGER;
        v_countZero INTEGER;
        v_99quant   NUMBER;
        v_999quant  NUMBER;
        v_9999quant NUMBER;
        v_different NUMBER;
        
        BEGIN
            -- ouverture du fichier
            v_textFile := sys.utl_file.fopen('TMDB', p_filename, 'W');
            -- en-tête du fichier
            sys.utl_file.put_line(v_textFile, 'SGBD - Romain VINDERS - 2322');
            sys.utl_file.put_line(v_textFile, 'FICHIER DE STATISTIQUES : ' || p_title);
            sys.utl_file.put_line(v_textFile, '----------------------------------------------');
            
            -- calculs statistiques
            SELECT  AVG(column_value),
                    VARIANCE(column_value),
                    STDDEV(column_value),
                    MIN(column_value),
                    MAX(column_value),
                    COUNT(column_value),
                    percentile_cont(0.5) within group (order by column_value) value,
                    percentile_cont(0.99) within group (order by column_value) value,
                    percentile_cont(0.999) within group (order by column_value) value,
                    percentile_cont(0.9999) within group (order by column_value) value
                    INTO v_average, v_variance, v_stdDev, v_min, v_max, v_count, v_median, v_99quant, v_999quant, v_9999quant
                FROM TABLE(CAST(p_values AS NumberArray));
            SELECT COUNT(*) INTO v_countNull
                FROM TABLE(CAST(p_values AS NumberArray))
                WHERE column_value IS NULL;
            SELECT COUNT(column_value) INTO v_countZero
                FROM TABLE(CAST(p_values AS NumberArray))
                WHERE column_value IS NOT NULL
                  AND column_value = 0;
            IF p_alt IS NOT NULL THEN
                SELECT COUNT(*) INTO v_different
                FROM (SELECT DISTINCT column_value 
                      FROM TABLE(CAST(p_alt AS StringArray)));
            ELSE
                SELECT COUNT(*) INTO v_different
                FROM (SELECT DISTINCT column_value 
                      FROM TABLE(CAST(p_values AS NumberArray)));
            END IF;
                  
            -- écriture des résultats
            sys.utl_file.put_line(v_textFile, 'Moyenne       = ' || v_average);
            sys.utl_file.put_line(v_textFile, 'Variance      = ' || v_variance);
            sys.utl_file.put_line(v_textFile, 'Ecart-type    = ' || v_stdDev);
            sys.utl_file.put_line(v_textFile, 'Mediane       = ' || v_median);
            sys.utl_file.put_line(v_textFile, 'Minimum       = ' || v_min);
            sys.utl_file.put_line(v_textFile, 'Maximum       = ' || v_max);
            sys.utl_file.put_line(v_textFile, 'Nombre total  = ' || (v_count + v_countNull));
            sys.utl_file.put_line(v_textFile, 'Nombre nuls   = ' || v_countNull);
            sys.utl_file.put_line(v_textFile, 'Non nuls      = ' || v_count);
            sys.utl_file.put_line(v_textFile, 'Valeurs zero  = ' || v_countZero);
            sys.utl_file.put_line(v_textFile, 'Valeurs diff. = ' || v_different);
            sys.utl_file.put_line(v_textFile, '99e percent.  = ' || v_99quant);
            sys.utl_file.put_line(v_textFile, '999e 1000-qu. = ' || v_999quant);
            sys.utl_file.put_line(v_textFile, '9999e 10000-q = ' || v_9999quant);
            sys.utl_file.fclose(v_textFile);
        
        EXCEPTION
            WHEN OTHERS THEN RAISE;
    END WriteStatsArray;
    
    
    -- longueurs valeurs numériques directes
    PROCEDURE GetValues 
	(
        p_col       IN VARCHAR2
	) AS       
        BEGIN
            -- analyser valeurs
            WriteStats(p_col, NULL, p_col || '.txt', 'Valeurs numeriques de la colonne ' || p_col);

        EXCEPTION
            WHEN OTHERS THEN RAISE;
    END GetValues;
    
    
    -- longueurs chaines de caractères directes
    PROCEDURE GetValuesLengths 
    (
        p_col       IN VARCHAR2
    ) AS
        BEGIN
            -- analyser longueurs
            WriteStats('LENGTH('||p_col||')', p_col, p_col || '.txt', 'Longueurs de la colonne ' || p_col);
        
        EXCEPTION
            WHEN OTHERS THEN RAISE;
    END GetValuesLengths;
    
    
    -- sous-valeurs (longueurs caractères/nombres)
    PROCEDURE GetSubvalues 
    (
        p_col       IN VARCHAR2,
        p_subName   IN VARCHAR2,
        p_subIndex  IN INTEGER
    ) AS
        v_curLengthTotal INTEGER;
        v_lengths   NumberArray;
        v_i         INTEGER;
        v_curBlock  VARCHAR2(8000);
        v_curSubPart VARCHAR2(8000);
        v_curVal    VARCHAR2(8000);
        c_blocks    sys_refcursor;
        
        BEGIN
            -- curseur dynamique
            OPEN c_blocks FOR 'SELECT ' || p_col || ' FROM movies_ext WHERE LENGTH(' || p_col || ') < 8000';
        
            -- initialiser
            v_lengths := NumberArray();
            v_i := 1;
            -- parcourir et copier longueurs
            LOOP
                FETCH c_blocks INTO v_curBlock;
                EXIT WHEN c_blocks%NOTFOUND;
                
                -- parcourir sous-parties
                v_curLengthTotal := 0;
                LOOP
                    -- récupérer partie (mode lazy)
                    v_curSubPart := regexp_substr(v_curBlock, '(.*?)(\|\||\]\]$)', 3 + v_curLengthTotal, 1, '', 1); 
                    EXIT WHEN v_curSubPart IS NULL;
                    v_curLengthTotal := v_curLengthTotal + LENGTH(v_curSubPart) + 2;
                    
                    -- récupérer valeur (mode lazy)
                    v_curVal := regexp_substr(v_curSubPart, '(.*?)(,,|$)', 1, p_subIndex, '', 1);
                    v_lengths.extend;
                    IF v_curVal IS NOT NULL THEN
                        v_lengths(v_i) := TO_NUMBER(TRIM(v_curVal));
                    ELSE
                        v_lengths(v_i) := NULL;
                    END IF;
                    v_i := v_i + 1;
                
                END LOOP;
                
            END LOOP;
            
            -- analyser longueurs
            WriteStatsArray(v_lengths, NULL, p_col || '__' || p_subName || '.txt', 
                       'Valeurs de la colonne ' || p_col || '.' || p_subName);  
        
        EXCEPTION
            WHEN OTHERS THEN RAISE;
    END GetSubvalues;
    
    
    -- sous-valeurs (longueurs caractères/nombres)
    PROCEDURE GetSubvaluesLengths
    (
        p_col       IN VARCHAR2,
        p_subName   IN VARCHAR2,
        p_subIndex  IN INTEGER
    ) AS
        v_lengths   NumberArray;
        v_values    StringArray;
        v_curLengthTotal INTEGER;
        v_i         INTEGER;
        v_curBlock  VARCHAR2(8000);
        v_curSubPart VARCHAR2(8000);
        v_curVal    VARCHAR2(8000);
        c_blocks    sys_refcursor;
        
        BEGIN
            -- curseur dynamique
            OPEN c_blocks FOR 'SELECT ' || p_col || ' FROM movies_ext WHERE LENGTH(' || p_col || ') < 8000';
        
            -- initialiser
            v_lengths := NumberArray();
            v_values := StringArray();
            v_i := 1;
            -- parcourir et copier longueurs
            LOOP
                FETCH c_blocks INTO v_curBlock;
                EXIT WHEN c_blocks%NOTFOUND;
                
                -- parcourir sous-parties
                v_curLengthTotal := 0;
                LOOP
                    -- récupérer partie (mode lazy)
                    v_curSubPart := regexp_substr(v_curBlock, '(.*?)(\|\||\]\]$)', 3 + v_curLengthTotal, 1, '', 1); 
                    EXIT WHEN v_curSubPart IS NULL;
                    v_curLengthTotal := v_curLengthTotal + LENGTH(v_curSubPart) + 2;
                    
                    -- récupérer valeur (mode lazy)
                    v_curVal := regexp_substr(v_curSubPart, '(.*?)(,,|$)', 1, p_subIndex, '', 1);
                    v_lengths.extend;
                    v_values.extend;
                    IF v_curVal IS NOT NULL THEN
                        v_lengths(v_i) := LENGTH(TRIM(v_curVal));
                        v_values(v_i) := TRIM(v_curVal);
                    ELSE
                        v_lengths(v_i) := NULL;
                        v_values(v_i) := NULL;
                    END IF;
                    v_i := v_i + 1;
                
                END LOOP;
                
            END LOOP;
            
            -- analyser longueurs
            WriteStatsArray(v_lengths, v_values, p_col || '__' || p_subName || '.txt', 
                       'Longueurs de la colonne ' || p_col || '.' || p_subName);  
        
        EXCEPTION
            WHEN OTHERS THEN RAISE;
    END GetSubvaluesLengths;
    
END STATS_PACKAGE;
/
    