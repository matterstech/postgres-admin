CREATE VIEW table_size AS
select
        table_schema as table_schema,
        table_name as table_name,
        pg_size_pretty(CAST(pg_total_relation_size(table_schema||'.'||table_name) AS bigint)) as total_size_pretty,
        pg_size_pretty(CAST(pg_relation_size(table_schema||'.'||table_name) AS bigint)) as table_size_pretty,
        pg_size_pretty(CAST(pg_total_relation_size(table_schema||'.'||table_name) - pg_relation_size(table_schema||'.'||table_name) AS bigint)) as index_size_pretty,
        -- table size / index size
        case when pg_relation_size(table_schema||'.'||table_name) <> 0 then
                round(
                        (pg_total_relation_size(table_schema||'.'||table_name) - pg_relation_size(table_schema||'.'||table_name))::numeric
                        / pg_relation_size(table_schema||'.'||table_name)::numeric
                , 3)
        else null
        end as index_over_table_ratio,
        -- index size / table size
        case when (pg_total_relation_size(table_schema||'.'||table_name) - pg_relation_size(table_schema||'.'||table_name)) <> 0 then
                round(
                        pg_relation_size(table_schema||'.'||table_name)::numeric
                        / (pg_total_relation_size(table_schema||'.'||table_name) - pg_relation_size(table_schema||'.'||table_name))::numeric
                        , 3)
        else null
        end as table_over_index_ratio,
        pg_total_relation_size(table_schema||'.'||table_name) as total_size,
        pg_relation_size(table_schema||'.'||table_name) as table_size,
        (pg_total_relation_size(table_schema||'.'||table_name) - pg_relation_size(table_schema||'.'||table_name)) as index_size
from
        information_schema.tables
where
        table_schema <> 'pg_catalog'
        and table_schema <> 'information_schema'
        and table_type <> 'VIEW'
order by
        index_size desc
;
COMMENT ON VIEW table_size IS 'List all table sizes, index sizes and various size-related metrics';