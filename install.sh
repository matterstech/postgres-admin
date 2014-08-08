#!/bin/bash
schema="public"
database="mydatabase"
host="127.0.0.1"
user="postgres"
port=5432
i=1

function usage(){
	echo -e "options : \n"
	echo -e "-h : Database's host\n"
	echo -e "-U : Database's user\n"
	echo -e "-p : Database's port\n"
	echo -e "-db: Database's name\n"
	echo -e "-schema: Schema where the extension will be install\n"
	echo -e "Example\n"
	echo -e "./install.sh -U user -db db -schema postgres_admin"
	exit 1
}

if [ "$1" = "--help" ]; then
	usage
else
	for word in $@
	do

		if [[ "$word" =~ ^-h ]] ;then
		    let i=i+1
			host=$(echo ${!i})
			let i=i+1
		elif [[ "$word" =~ ^-U  ]] ;then
		    let i=i+1
			user=$(echo ${!i})
			let i=i+1
		elif [[ "$word" =~ ^-p  ]] ;then
            let i=i+1
            port=$(echo ${!i})
            let i=i+1
		elif [[ "$word" =~ ^-db  ]] ;then
            let i=i+1
            database=$(echo ${!i})
            let i=i+1
		elif [[ "$word" =~ ^-schema  ]] ;then
            let i=i+1
            schema=$(echo ${!i})
            let i=i+1
        elif [[ "$word" =~ ^--help ]] ;then
            usage
            exit 1
		fi
	done
fi

cd src/extension
sudo make install
cd -

psql -h $host -U $user -p $port $database -c "drop extension if exists postgres_admin; create extension if not exists postgres_admin with schema $schema; alter extension postgres_admin update;"
exit 0
