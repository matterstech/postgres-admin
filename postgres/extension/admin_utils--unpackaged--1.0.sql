/* extension/admin_utils--1.0.sql */

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION admin_utils" to load this file. \quit

ALTER EXTENSION earthdistance ADD function is_int(text);
ALTER EXTENSION earthdistance ADD function is_float(text, text);
ALTER EXTENSION earthdistance ADD function array_avg(double precision[]);
ALTER EXTENSION earthdistance ADD function array_avg(integer[]);

