postgres-admin
====================

This extension contains a list of functions describe below to manage your PostgreSQL database easily.


## Postgresql

Requirements
------------

Debian
```
apt-get install postgresql-server-dev-<postgres-version>

apt-get install libpq-dev

```

Install manually
-----------------

```
mydatabase=# create extension if not exists postgres_admin with schema myschema;
mydatabase=# select * from admin.extension_object where extension_name = 'postgres_utils' order by object_kind, object_name;
```

Install automatically
----------------------
```
me:/dir$ ./install -db mydb -U me
```

Install options
----------------
**-h** : Database host

**-p** : Database port (Default: 5432)

**-U** : Database user

**-schema** : Schema name where the extension will be install

**-db** : Database name

Uninstall
----------
```
mydatabase=# drop extension if exists postgres_admin [CASCADE];
```

Functions
---------

```sql

 extension_name | object_kind |   object_name    |                                   description
----------------+-------------+------------------+---------------------------------------------------------------------------------
 postgres_admin    | FUNCTION    | array_avg        | Compute the average of an array
 postgres_admin    | FUNCTION    | is_float         | Test if a value is in fact a float
 postgres_admin    | FUNCTION    | is_int           | Test if a value is in fact an integer
 postgres_admin    | VIEW        | database_size    | List all databases and their disk usage
 postgres_admin    | VIEW        | extension_object | List of all object packed in an extension with associated comment
 postgres_admin    | VIEW        | index_duplicate  | List all indexes similar to each other, you should keep an eye on those indexes
 postgres_admin    | VIEW        | index_operator   | List of all valid operators for an index
 postgres_admin    | VIEW        | index_usage      | List all indexes and index usage statistics, easily find unused indexes
 postgres_admin    | VIEW        | setting_delta    | List of settings that have been changed from the default by any source
 postgres_admin    | VIEW        | table_size       | List all table sizes, index sizes and various size-related metrics
 postgres_admin    | VIEW        | get_function_def_list | List all functions including their comments
```

Contributing
-------------

### Pull request

Use the git feature branch workflow in order to contribute to this project.

Documentation can be found here <https://www.atlassian.com/git/workflows#!workflow-feature-branch>


### Add a function to the project


Add a file named my_function--unpackaged.sql into src/extension/sql/

The function must be well documented using the command "ADD COMMENT"
