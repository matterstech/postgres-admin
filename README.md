postgres-admin-utils
====================

Compilation of function to administrate, migrate, postgres.


## Postgresql

### Views

* index_duplicate - List all indexes similar to each other, you should keep an eye on those indexes
* table_size - List all table sizes, index sizes and various size-related metrics
* index_usage - List all indexes and index usage statistics, easily find unused indexes
* database_size - List all databases and their disk usage

### Functions

* is_int(data_to_test text):boolean - Test if a value is in fact an integer
* is_float(data_to_test text, separator text DEFAULT '.'::text):boolean - Test if a value is in fact a float
* array_avg(anyarray):double precision - Compute the average of an array