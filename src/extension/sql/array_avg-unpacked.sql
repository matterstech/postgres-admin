-- Compute the average of a double or int array
CREATE FUNCTION array_avg(anyarray) RETURNS double precision AS $$
	SELECT avg(v) FROM unnest($1) g(v);
$$
LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION array_avg(anyarray) IS 'Compute the average of an array';