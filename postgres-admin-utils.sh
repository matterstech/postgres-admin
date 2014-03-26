#!/bin/bash
source lib/postgres.sh

schema="public"
database="postgres"
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

import_postgres_scripts $database

exit 0
