#!/bin/bash
set -eo pipefail

echo "hello there ${1}"
# echo "exited $0"

/etc/init.d/mysqld start
# service mysqld start
/etc/init.d/httpd start

mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME} /*\!40100 DEFAULT CHARACTER SET utf8 */" && \
mysql -u root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}'" && \
mysql -u root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}'" && \
mysql -u root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO 'root'@'%'" && \
mysql -u root -e "FLUSH PRIVILEGES"
#
# service mysqld stop
#
# /etc/init.d/mysqld start

# service mysqld start
echo "${DB_USER}"
echo "${DB_NAME}"

# WP_PREFIX="wp30_dzeni_new"

# SQL_FILE=$(ls -dt /sql/*.sql | head -1)

# mysql -u root <<-EOF
#   SHOW GRANTS;
#   SHOW GRANTS FOR 'root'@'172.17.0.1';
# EOF

# mysql -u root ${DB_NAME} < /${SQL_FILE}

# mysql -u root -e "USECREATE DATABASE ${DB_NAME} /*\!40100 DEFAULT CHARACTER SET utf8 */" && \

# mysql -u root <<-EOF
#   # UPDATE ${DB_NAME}.${WP_PREFIX}options SET option_value = 'http://localhost:8080' WHERE option_name = 'siteurl';
#   # DELETE FROM mysql.user WHERE User='';
#   # DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
#   # CREATE DATABASE ${DB_NAME} /*\!40100 DEFAULT CHARACTER SET utf8 */;
#   # CREATE USER ${DB_NAME}@localhost IDENTIFIED BY '';
#   # GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
# EOF
#

# UPDATE `wp_zs_postmeta` SET meta_value = REPLACE (meta_value, '/web10/web/lv/', '/web10/web/lv_old/');


# UPDATE `wp_zs_options` SET option_value = REPLACE (option_value, 'http://www.zemniekusaeima.lv/lv', 'http://www.zemniekusaeima.lv/lv_old');
# UPDATE `wp_zs_options` SET option_value = 'http://localhost:8080' WHERE option_name = 'siteurl';
#
#
# UPDATE `wp_zs_posts` SET post_content = REPLACE (post_content, 'http://www.zemniekusaeima.lv/lv', 'http://www.zemniekusaeima.lv/lv_old');
#
#
# UPDATE `wp_zs_posts` SET guid = REPLACE (guid, 'http://www.zemniekusaeima.lv/lv', 'http://www.zemniekusaeima.lv/lv_old');

/bin/bash
exec "$@"
