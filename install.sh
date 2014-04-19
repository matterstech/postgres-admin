#!/bin/bash
schema="public"
database="mydatabase"
host="127.0.0.1"
user="postgres"
port=5432

function usage(){
	echo -e "options : \n"
	echo -e "-h : Database's host\n"
	echo -e "-U : Database's user\n"
	echo -e "-p : Database's port\n"
	echo -e "-db: Database's name\n"
	echo -e "-schema: Schema where the extension will be install\n"
	echo -e "Example\n"
	echo -e "./install.sh -U=user -db=db -schema=postgres_admin"
	exit 1
}

if [ "$1" = "--help" ]; then
	usage
else
	for word in $@
	do
		if [[ "$word" =~ ^-h ]] ;then
			host=$(echo $word | cut -f2 -d=)
		elif [[ "$word" =~ ^-U  ]] ;then
			user=$(echo $word | cut -f2 -d=)
		elif [[ "$word" =~ ^-p  ]] ;then
                        port=$(echo $word | cut -f2 -d=)
		elif [[ "$word" =~ ^-db  ]] ;then
                        database=$(echo $word | cut -f2 -d=)
		elif [[ "$word" =~ ^-schema  ]] ;then
                        schema=$(echo $word | cut -f2 -d=)
		fi
	done
fi

cd src/extension
sudo make install
cd -

psql -h $host -U $user -p $port $database -c "drop extension if exists postgres_admin; create extension if not exists postgres_admin with schema $schema; alter extension postgres_admin update;"
exit 0
