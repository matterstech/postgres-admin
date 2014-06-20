-- Test if an argument is a float
CREATE FUNCTION is_float(data_to_test text, separator text DEFAULT '.'::text)
  RETURNS boolean AS $$
  SELECT data_to_test ~ ('^[+-]?\d+(\'|| separator || '\d+)?$')
$$
LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION is_float(data_to_test text, separator text) IS 'Test if a value is in fact a float';