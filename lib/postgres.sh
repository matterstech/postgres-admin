#!/bin/bash

function get_postgres_scripts()
{
	local list_files
	
	list_files=$(ls -l database-functions/postgres/*/*|awk '{print $9}')
	
	return $list_files
}

function import_postgres_scripts()
{
	local package
	
	if [ "$#" -lt 2 ]; then
		for entry in database-functions/postgres/*/*
		do
			psql -d "$1" -U postgres -f  "$entry"
		done
	else
		echo $1
	fi
}
