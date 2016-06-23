#!/bin/bash
echo "hello there ${1}"
# echo "exited $0"

# /etc/init.d/mysqld start
# service mysqld start
# /etc/init.d/httpd start

TERM=dumb php -- "$WORDPRESS_DB_HOST" "$WORDPRESS_DB_USER" "$WORDPRESS_DB_PASSWORD" "$WORDPRESS_DB_NAME" <<'EOPHP'
<?php
// database might not exist, so let's try creating it (just to be safe)
$stderr = fopen('php://stderr', 'w');
list($host, $port) = explode(':', $argv[1], 2);
$maxTries = 10;
do {
	$mysql = new mysqli($host, $argv[2], $argv[3], '', (int)$port);
	if ($mysql->connect_error) {
		fwrite($stderr, "\n" . 'MySQL Connection Error: (' . $mysql->connect_errno . ') ' . $mysql->connect_error . "\n");
		--$maxTries;
		if ($maxTries <= 0) {
			exit(1);
		}
		sleep(3);
	}
} while ($mysql->connect_error);
if (!$mysql->query('CREATE DATABASE IF NOT EXISTS `' . $mysql->real_escape_string($argv[4]) . '`')) {
	fwrite($stderr, "\n" . 'MySQL "CREATE DATABASE" Error: ' . $mysql->error . "\n");
	$mysql->close();
	exit(1);
}
$mysql->close();
EOPHP

# service mysqld start
# echo "${DB_USER}"
# echo "${DB_NAME}"

mysql -u root <<-EOF
  SHOW GRANTS;
  # SHOW GRANTS FOR 'root'@'172.17.0.1';
EOF

# mysql -u root -e "GRANT ALL PRIVILEGES ON ${WORDPRESS_DB_NAME}.* TO '${WORDPRESS_DB_USER}'@'localhost'" && \
# mysql -u root -e "GRANT ALL PRIVILEGES ON ${WORDPRESS_DB_NAME}.* TO '${WORDPRESS_DB_USER}'@'172.19.0.39'" && \
# mysql -u root -e "GRANT ALL PRIVILEGES ON ${WORDPRESS_DB_NAME}.* TO 'root'@'172.19.0.3'" && \
# mysql -u root -e "FLUSH PRIVILEGES"

/bin/bash
