#!/bin/bash

set -e
set -u

function create_multiple_database() {
	local database=$1
	echo "  Creating multiple database '$database'"
	mysql -u root -p rootpassword <<MYSQL_SCRIPT
	    CREATE DATABASE $database;
        GRANT ALL PRIVILEGES ON $database.* TO 'dbuser'@'%' WITH GRANT OPTION;
        FLUSH PRIVILEGES;
MYSQL_SCRIPT
}

if [ -n "$MARIADB_MULTIPLE_DATABASES" ]; then
	echo "Multiple database creation requested: $MARIADB_MULTIPLE_DATABASES"
	for db in $(echo $MARIADB_MULTIPLE_DATABASES | tr ',' ' '); do
		create_multiple_database $db
	done
	echo "Multiple databases created"
fi
