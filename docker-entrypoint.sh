#!/bin/bash

function before_exit {
  TABLE_COUNT=$(mysql --raw --batch -e "SELECT COUNT(*) FROM information_schema.tables WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_SCHEMA = '${DB_NAME}'" -s)
  if [ $TABLE_COUNT -gt 0 ]; then
    TODAY=`date '+%Y-%m-%d_%H.%M.%S'`;
    SQL_DUMP_FILE="/sql/${DB_NAME}_docker_dump_${TODAY}.sql"
    mysqldump $DB_NAME > $SQL_DUMP_FILE
  fi
}
trap before_exit EXIT

set -eo pipefail

/etc/init.d/mysqld start
/etc/init.d/httpd start
echo ""

# -----------------------------------------------------------------------------
# Initialize given database or default one
# -----------------------------------------------------------------------------

: "${DB_NAME:=wordpress}"
: "${DB_USER:=wordpress}"
: "${DB_PASS:=wordpress}"

mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME} /*\!40100 DEFAULT CHARACTER SET utf8 */" && \
mysql -u root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}'" && \
mysql -u root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}'" && \
mysql -u root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO 'root'@'%'" && \
mysql -u root -e "FLUSH PRIVILEGES"

# if empty database & file /sql/*.sql files exist import latest sql file
TABLE_COUNT=$(mysql --raw --batch -e "SELECT COUNT(*) FROM information_schema.tables WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_SCHEMA = '${DB_NAME}'" -s)
echo "Table count in '${DB_NAME}': ${TABLE_COUNT}"

if [ $TABLE_COUNT -eq 0 ]; then
  if ls /sql/*.sql 1> /dev/null 2>&1; then
    SQL_FILE=$(ls -dt /sql/*.sql | head -1)
    mysql -u root $DB_NAME < /$SQL_FILE
    echo "Importing DB tables from ${SQL_FILE}"
  else
    echo "Nothing to import - sql files not found!"
  fi
else
  echo "Using existing DB"
fi

echo ""
echo "User:      $DB_USER"
echo "Database:  $DB_NAME"
echo "Password:  $DB_PASS"

bin/bash

exec "$@"
