postgres-admin-utils
====================

Compilation of function to administrate, migrate, postgres.


## Postgresql

### Views

* index_duplicates - List all index similar to each other, you should keep an eye on those indexes
* table_sizes - List all table sizes, index sizes and various size-related metrics

### Functions

* is_int(data_to_test text):boolean - Test if a value is in fact an integer
* is_float(data_to_test text, separator text DEFAULT '.'::text):boolean - Test if a value is in fact a float
* array_avg(anyarray):double precision - Compute the average of an array