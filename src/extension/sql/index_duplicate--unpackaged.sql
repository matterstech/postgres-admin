-- based on query from http://wiki.postgresql.org/wiki/Index_Maintenance
CREATE VIEW index_duplicate AS
    WITH index_duplicate AS (
        SELECT
            first_value(index_pg_class.oid) OVER (index_identity) duplicate_id,
            table_pg_namespace.nspname as schema_name,
            table_pg_class.relname as table_name,
            ARRAY(
               SELECT pg_get_indexdef(pg_index.indexrelid, k + 1, true)
               FROM generate_subscripts(pg_index.indkey, 1) as k
               ORDER BY k
            ) as indexed_columns,
            pg_index.indexrelid::regclass AS index_name,
            count(*) OVER (index_identity) AS duplicate_count,
            sum(pg_relation_size(pg_index.indexrelid)) OVER (index_identity) AS total_index_size,
            pg_relation_size(pg_index.indexrelid) AS index_size,
            pg_am.amname as index_type
        FROM
            pg_index
            LEFT JOIN pg_class as index_pg_class ON index_pg_class.oid = pg_index.indexrelid
            LEFT JOIN pg_am ON index_pg_class.relam = pg_am.oid
            LEFT JOIN pg_class as table_pg_class ON table_pg_class.oid = pg_index.indrelid
            LEFT JOIN pg_namespace table_pg_namespace ON table_pg_namespace.oid = table_pg_class.relnamespace
        WINDOW
            index_identity AS (
                PARTITION BY pg_index.indrelid::text ||E'\n'|| pg_index.indclass::text ||E'\n'||
                             pg_index.indkey::text ||E'\n'|| coalesce(pg_index.indexprs::text,'')||
                             E'\n' || coalesce(pg_index.indpred::text,'')
            )
    )
    SELECT
        *,
        pg_size_pretty(CAST(total_index_size AS bigint)) as total_index_size_pretty,
        pg_size_pretty(CAST(index_size  AS bigint)) as index_size_pretty
    FROM
        index_duplicate
    WHERE
        duplicate_count > 1
    ORDER BY
        duplicate_id
;
COMMENT ON VIEW index_duplicate IS 'List all indexes similar to each other, you should keep an eye on those indexes';