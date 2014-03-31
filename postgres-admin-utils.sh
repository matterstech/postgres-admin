#!/bin/bash
schema="admin"
database="mydatabase"
host="127.0.0.1"
user="postgres"
sgbd="postgres"
port=5432

function usage(){
	echo -e "options : \n"
	echo -e "	 arg 1 schema\n"
	echo -e "	 arg 2 database\n"
	echo -e "	 arg 3 host\n"
	echo -e "	 arg 4 user\n"
	echo -e "	 arg 5 package\n"
	exit 1
}

if [ "$1" = "--help" ]; then
	usage
fi


psql -h $host -U $user -p $port $database -c "drop extension if exists admin_utils"

cd postgres/extension
sudo make install
cd -

psql -h $host -U $user -p $port $database -c "drop extension if exists admin_utils"
psql -h $host -U $user -p $port $database -c "create extension if not exists admin_utils with schema $schema"
psql -h $host -U $user -p $port $database -c "alter extension admin_utils update"

exit 0
