CREATE OR REPLACE FUNCTION inovia.is_float(data_to_test text, separator text DEFAULT '.'::text)
  RETURNS boolean AS
$BODY$
	DECLARE
		query TEXT;
		return_val BOOLEAN;
	BEGIN
		query := '^[+-]?\d+(\'|| separator || '\d+)?$';
		SELECT data_to_test ~ query INTO return_val;
		RETURN return_val;
	END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 1000;
