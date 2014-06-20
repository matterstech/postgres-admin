CREATE VIEW index_operator AS
    WITH index_information AS (
        SELECT
            pg_index.indexrelid,
            table_pg_namespace.nspname as schema_name,
            table_pg_class.relname as table_name,
            ARRAY(
               SELECT pg_get_indexdef(pg_index.indexrelid, k + 1, true)
               FROM generate_subscripts(pg_index.indkey, 1) as k
               ORDER BY k
            ) as indexed_columns,
            pg_index.indexrelid::regclass AS index_name,
            pg_am.amname as index_type
        FROM
            pg_index
            LEFT JOIN pg_class as index_pg_class ON index_pg_class.oid = pg_index.indexrelid
            LEFT JOIN pg_am ON index_pg_class.relam = pg_am.oid
            LEFT JOIN pg_class as table_pg_class ON table_pg_class.oid = pg_index.indrelid
            LEFT JOIN pg_namespace table_pg_namespace ON table_pg_namespace.oid = table_pg_class.relnamespace
    ),
    index_with_operator_argument_expanded AS (
        SELECT
            indexrelid,
            (information_schema._pg_expandarray(indclass)).x AS operator_argument_type_oid,
            (information_schema._pg_expandarray(indclass)).n AS operator_argument_position
        FROM
            pg_index
    )
    SELECT
        index_information.schema_name,
        index_information.table_name,
        index_information.indexed_columns,
        index_information.index_name,
        index_information.index_type,
        pg_amop.amopopr::regoperator AS indexable_operator
    FROM
        pg_opclass
        JOIN pg_amop ON pg_amop.amopfamily = pg_opclass.opcfamily
        JOIN index_with_operator_argument_expanded ON pg_opclass.oid = operator_argument_type_oid
        JOIN index_information ON index_information.indexrelid = index_with_operator_argument_expanded.indexrelid
    WHERE
        schema_name NOT LIKE 'pg_%'
    ORDER BY
        schema_name,
        table_name,
        index_name
;
COMMENT ON VIEW index_operator IS 'List of all valid operators for an index';