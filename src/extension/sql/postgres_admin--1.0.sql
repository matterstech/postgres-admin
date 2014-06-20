CREATE OR REPLACE FUNCTION get_duplicates_from_functional_key(IN target_table text, IN target_columns text[], IN identifier_column text DEFAULT 'ctid'::text, OUT duplicated text[], OUT lines text[])
  RETURNS SETOF record AS
$BODY$
DECLARE
        query     TEXT;
        rec   RECORD;
BEGIN

        select format('SELECT name AS duplicated,
        array_agg(' || quote_ident(identifier_column) || ' ORDER BY ' || quote_ident(identifier_column) || ')::text[] AS lines
        FROM ' || quote_ident(target_table) || '
        GROUP BY name, spss_id
        HAVING COUNT(name) > 1;',
        string_agg('name', ', ')) into query ;

        --query := 'SELECT array_agg(name ORDER BY name)::text[] AS duplicated,
        --array_agg(' || quote_ident(identifier_column) || ' ORDER BY ' || quote_ident(identifier_column) || ')::text[] AS lines
        --FROM ' || quote_ident(target_table) || '
        --GROUP BY name, spss_id
        --HAVING COUNT(name) > 1;';

        FOR rec IN EXECUTE query LOOP
                duplicated = rec.duplicated;
                lines = rec.lines;
                RETURN NEXT;
        END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;



