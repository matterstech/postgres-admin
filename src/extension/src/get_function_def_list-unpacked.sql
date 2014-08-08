CREATE OR REPLACE FUNCTION get_function_def_list(IN schema_search TEXT DEFAULT 'public', OUT definition TEXT) RETURNS SETOF TEXT
AS
$BODY$
DECLARE
  query TEXT;
  rec   RECORD;

BEGIN

query := 'SELECT def || ''COMMENT ON FUNCTION '' || func_name || ''('' || param_types || '') IS ''|| quote_literal(func_comment) || '';'' AS def
  FROM
(
  SELECT pg_get_functiondef(f.oid) AS def, f.proname AS func_name, obj_description(f.oid) AS func_comment, pg_catalog.pg_get_function_identity_arguments(f.oid) AS param_types
  FROM pg_catalog.pg_proc f
    LEFT JOIN pg_catalog.pg_type t ON t.oid = ANY(f.proallargtypes)
    INNER JOIN pg_catalog.pg_namespace n ON (f.pronamespace = n.oid)
  WHERE n.nspname = ' || quote_literal(schema_search) || '
        AND obj_description(f.oid) != ''''
  GROUP BY f.oid, f.proname) function_data
;'
;
  RAISE NOTICE 'query : %', query;
  FOR rec IN EXECUTE query
  LOOP
    definition = rec.def;
    RETURN NEXT;
  END LOOP;
END;
$BODY$
LANGUAGE plpgsql VOLATILE;
COMMENT ON FUNCTION get_function_def_list(TEXT) IS 'Get the list of functions for a specif schema including their comments. If a function does not have a comment it will not be pull out';