CREATE OR REPLACE FUNCTION inovia.is_int(data_to_test text)
  RETURNS boolean AS
$BODY$
	DECLARE
		return_val BOOLEAN;
	BEGIN
		SELECT data_to_test ~ '^[0-9]+$' INTO return_val;
		RETURN return_val;
	END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 1000;
