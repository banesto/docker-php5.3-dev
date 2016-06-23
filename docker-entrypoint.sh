#!/bin/bash
set -eo pipefail

/etc/init.d/mysqld start
/etc/init.d/httpd start

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

# service mysqld start
echo "User: ${DB_USER}"
echo "Database: ${DB_NAME}"
echo "Password: ${DB_PASS}"

exec "$@"
