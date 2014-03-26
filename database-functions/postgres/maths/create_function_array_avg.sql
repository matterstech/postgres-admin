CREATE OR REPLACE FUNCTION inovia.array_avg(double precision[])
  RETURNS double precision AS
$BODY$
SELECT avg(v)
FROM unnest($1) g(v);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION inovia.array_avg(double precision[])
