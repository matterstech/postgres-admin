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

