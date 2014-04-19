postgres-admin
====================

This extension contains a list of functions describe below to manage your PostgreSQL database easily.


## Postgresql

Install manually
-----------------

```
mydatabase=# create extension if not exists postgres_admin with schema myschema;
mydatabase=# select * from admin.extension_object where extension_name = 'postgres_utils' order by object_kind, object_name;
```

Install automatically
----------------------
```
me:/dir$ ./install -db=mydb -U=me
```

Install options
----------------
All options must be follow by =value. For example -h=localhost

**-h** : Database host

**-p** : Database port

**-U** : Database user

**-schema** : Schema name

**-db** : Database name

Uninstall
----------
```
mydatabase=# drop extension if exists postgres_admin [CASCADE];
```

```sql

 extension_name | object_kind |   object_name    |                                   description
----------------+-------------+------------------+---------------------------------------------------------------------------------
 admin_utils    | FUNCTION    | array_avg        | Compute the average of an array
 admin_utils    | FUNCTION    | is_float         | Test if a value is in fact a float
 admin_utils    | FUNCTION    | is_int           | Test if a value is in fact an integer
 admin_utils    | VIEW        | database_size    | List all databases and their disk usage
 admin_utils    | VIEW        | extension_object | List of all object packed in an extension with associated comment
 admin_utils    | VIEW        | index_duplicate  | List all indexes similar to each other, you should keep an eye on those indexes
 admin_utils    | VIEW        | index_operator   | List of all valid operators for an index
 admin_utils    | VIEW        | index_usage      | List all indexes and index usage statistics, easily find unused indexes
 admin_utils    | VIEW        | setting_delta    | List of settings that have been changed from the default by any source
 admin_utils    | VIEW        | table_size       | List all table sizes, index sizes and various size-related metrics
```
