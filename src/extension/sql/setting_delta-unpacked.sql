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