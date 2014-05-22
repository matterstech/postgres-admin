/* extension/admin_utils--1.0.sql */

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION admin_utils" to load this file. \quit

-- Test if an argument is an integer
CREATE FUNCTION is_int(data_to_test text) RETURNS boolean AS $$ 
	SELECT data_to_test ~ '^[0-9]+$'
$$
LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION is_int(data_to_test text) IS 'Test if a value is in fact an integer';


-- Test if an argument is a float
CREATE FUNCTION is_float(data_to_test text, separator text DEFAULT '.'::text)
  RETURNS boolean AS $$
  SELECT data_to_test ~ ('^[+-]?\d+(\'|| separator || '\d+)?$')
$$
LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION is_float(data_to_test text, separator text) IS 'Test if a value is in fact a float';


-- Compute the average of a double or int array
CREATE FUNCTION array_avg(anyarray) RETURNS double precision AS $$ 
	SELECT avg(v) FROM unnest($1) g(v);
$$
LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION array_avg(anyarray) IS 'Compute the average of an array';
 




CREATE VIEW table_size AS 
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
COMMENT ON VIEW table_size IS 'List all table sizes, index sizes and various size-related metrics';



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
        pg_size_pretty(total_index_size) as total_index_size_pretty,
        pg_size_pretty(index_size) as index_size_pretty
    FROM
        index_duplicate
    WHERE
        duplicate_count > 1
    ORDER BY
        duplicate_id
;
COMMENT ON VIEW index_duplicate IS 'List all indexes similar to each other, you should keep an eye on those indexes';




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
           

-- based on query from http://wiki.postgresql.org/wiki/Disk_Usage
CREATE VIEW database_size AS 
    SELECT 
        d.datname AS db_name,
        pg_catalog.pg_get_userbyid(d.datdba) AS db_owner,
        CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT')
            THEN pg_catalog.pg_size_pretty(pg_catalog.pg_database_size(d.datname))
            ELSE 'No Access'
        END AS db_size
    FROM 
        pg_catalog.pg_database d
    ORDER BY 
        db_size DESC
;
COMMENT ON VIEW database_size IS 'List all databases and their disk usage';
 


-- based on query from https://wiki.postgresql.org/wiki/Server_Configuration
CREATE VIEW setting_delta AS 
    SELECT 
		name, 
		current_setting(name), 
		reset_val as reset_value, 
		source, 
		short_desc as short_description
    FROM 
    	pg_settings
    WHERE 
    	source NOT IN ('default', 'override')
    	AND current_setting(name) IS DISTINCT FROM reset_val
;
COMMENT ON VIEW setting_delta IS 'List of settings that have been changed from the default by any source';
 


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



