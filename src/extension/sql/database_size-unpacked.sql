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