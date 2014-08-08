-- based on query from http://wiki.postgresql.org/wiki/Index_Maintenance
CREATE VIEW index_usage AS
    SELECT
        pg_tables.schemaname as schema_name,
        pg_tables.tablename as table_name,
        index_pg_class.relname as index_name,
        table_pg_class.reltuples AS num_rows,
        pg_size_pretty(pg_relation_size(pg_tables.schemaname||'.'||pg_tables.tablename)) AS table_size,
        pg_size_pretty(pg_relation_size(pg_tables.schemaname||'.'||index_pg_class.relname)) AS index_size,
        CASE WHEN pg_index.indisunique THEN 'Y' ELSE 'N' END AS unique,
        pg_stat_all_indexes.idx_scan AS number_of_scans,
        pg_stat_all_indexes.idx_tup_read AS tuples_read,
        pg_stat_all_indexes.idx_tup_fetch AS tuples_fetched
    FROM pg_tables
        LEFT JOIN pg_class table_pg_class ON pg_tables.tablename = table_pg_class.relname
        LEFT JOIN pg_index ON table_pg_class.oid = pg_index.indrelid
        LEFT JOIN pg_class as index_pg_class ON index_pg_class.oid = pg_index.indexrelid
        LEFT JOIN pg_stat_all_indexes ON pg_index.indexrelid = pg_stat_all_indexes.indexrelid
    WHERE
        pg_tables.schemaname not in ('pg_catalog', 'information_schema')
    ORDER BY
        schema_name,
        table_name
;
COMMENT ON VIEW index_usage IS 'List all indexes and index usage statistics, easily find unused indexes';