/* extension/admin_utils--1.0.sql */

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION admin_utils" to load this file. \quit

-- Test if an argument is an integer
CREATE FUNCTION is_int(data_to_test text) RETURNS boolean AS $$ 
	SELECT data_to_test ~ '^[0-9]+$'
$$
LANGUAGE SQL IMMUTABLE;

-- Test if an argument is a float
CREATE FUNCTION is_float(data_to_test text, separator text DEFAULT '.'::text)
  RETURNS boolean AS $$
  SELECT data_to_test ~ ('^[+-]?\d+(\'|| separator || '\d+)?$')
$$
LANGUAGE SQL IMMUTABLE;

-- Compute the average of a double or int array
CREATE FUNCTION array_avg(anyarray) RETURNS double precision AS $$ 
	SELECT avg(v) FROM unnest($1) g(v);
$$
LANGUAGE SQL IMMUTABLE;




CREATE VIEW table_sizes AS 
select 
        table_schema as table_schema,
        table_name as table_name, 
        pg_size_pretty(pg_total_relation_size(table_schema||'.'||table_name)) as total_size_pretty, 
        pg_size_pretty(pg_relation_size(table_schema||'.'||table_name)) as table_size_pretty, 
        pg_size_pretty(pg_total_relation_size(table_schema||'.'||table_name) - pg_relation_size(table_schema||'.'||table_name)) as index_size_pretty,
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



CREATE VIEW index_duplicates AS 
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
        pg_size_pretty(total_index_size) as total_index_size_pretty,
        pg_size_pretty(index_size) as index_size_pretty
    FROM
        index_duplicate
    WHERE
        duplicate_count > 1
    ORDER BY
        duplicate_id
;
