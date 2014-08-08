CREATE VIEW extension_object AS
    SELECT
        pg_extension.extname as extension_name,
        coalesce(
    	    CASE WHEN pg_proc.oid IS NOT NULL THEN 'FUNCTION'
    	    ELSE NULL END,
            CASE pg_class.relkind
                WHEN 'r' THEN 'TABLE'
                WHEN 'i' THEN 'INDEX'
                WHEN 'S' THEN 'SEQUENCE'
                WHEN 'v' THEN 'VIEW'
                WHEN 'm' THEN 'MATERIALIZED VIEW'
                WHEN 'c' THEN 'COMPOSITE TYPE'
                WHEN 't' THEN 'TOAST TABLE'
                WHEN 'f' THEN 'FOREIGN TABLE'
                ELSE NULL
            END,
            'unknown'
        ) as object_kind,
        coalesce(
            pg_class.relname::character varying,
            pg_proc.proname--||'('||
            --pg_get_function_arguments(pg_proc.oid)||') : '||
            --pg_get_function_result(pg_proc.oid)
        )::text as object_name,
        pg_description.description--, *
    FROM
        pg_depend
        LEFT JOIN pg_extension on pg_depend.refobjid = pg_extension.oid
        LEFT JOIN pg_class on pg_depend.objid = pg_class.oid
        LEFT JOIN pg_proc on pg_depend.objid = pg_proc.oid
        LEFT JOIN pg_description on pg_description.objoid = coalesce(pg_class.oid, pg_proc.oid)
    WHERE
        refclassid = 'pg_extension'::regclass
;
COMMENT ON VIEW extension_object IS 'List of all object packed in an extension with associated comment';