FROM centos:6

RUN \
  yum -y update && \
  yum -y install \
    git \
    httpd \
    mod_perl \
    nano \
    rsync \
    ruby \
    vsftpd \
    wget

RUN \
  yum -y install ntp && \
  rm -rf /etc/localtime && \
  ln -s /usr/share/zoneinfo/EET /etc/localtime

RUN rpm -Uvh http://repo.webtatic.com/yum/el6/latest.rpm
# RUN \
#   yum -y install \
#     php54w \
#     php54w-fpm \
#     php54w-mbstring \
#     php54w-cli \
#     php54w-gd \
#     php54w-mysql \
#     php54w-devel \
#     php54w-pecl-memcache \
#     php54w-pspell \
#     #php54w-snmp \
#     php54w-xmlrpc \
#     php54w-xml \
#     php54w-pear \
#     php54w-tidy

RUN \
  yum -y install \
  php \
  php-cli \
  php-gd \
  php-mysql \
  php-mbstring \
  php-devel \
  php-pecl-memcache \
  php-pspell \
  php-snmp \
  php-xmlrpc \
  php-xml \
  php-pear \
  php-tidy

RUN \
  yum -y install rubygems && \
  gem install sass --no-rdoc --no-ri && \
  gem install bundler --no-rdoc --no-ri

RUN \
  yum -y install \
    mysql-server \
    mysql && \
  chkconfig --levels 235 mysqld on

# RUN \
#   wget http://dev.mysql.com/get/mysql57-community-release-el6-7.noarch.rpm && \
#   md5sum mysql57-community-release-el6-7.noarch.rpm && \
#   rpm -ivh mysql57-community-release-el6-7.noarch.rpm && \
#   yum install -y mysql-community-client mysql-community-server && \
#   chkconfig --levels 235 mysqld on

ENV \
  LC_ALL=en_US.UTF-8 \
  LANG=en_US.UTF-8 \
  DB_NAME=jurasdzeni \
  DB_USER=wordpress \
  DB_PASS=wordpress

  # -----------------------------------------------------------------------------
  # Disable all Apache modules and enable the minimum
  # -----------------------------------------------------------------------------

# RUN sed -i -e 's~^Timeout \(.*\)$~Timeout 120~g' /etc/httpd/conf/httpd.conf

RUN sed -i \
  -e 's~^Timeout \(.*\)$~Timeout 120~g' \
  -e 's~^#ServerName \(.*\)$~ServerName 0.0.0.0:80~g' \
  -e 's~^DirectoryIndex \(.*\)$~DirectoryIndex index.html index.html.var index.php~g' \
  -e 's~^#EnableSendfile \(.*\)$~EnableSendfile On~g' \
  -e 's~AllowOverride \(.*\)$~AllowOverride All~g' \
  /etc/httpd/conf/httpd.conf

RUN sed -i \
  -e 's~^short_open_tag \(.*\)$~short_open_tag = On~g' \
  -e 's~^max_execution_time \(.*\)$~max_execution_time = 300~g' \
  -e 's~^memory_limit \(.*\)$~memory_limit = 512M~g' \
  -e 's~^post_max_size \(.*\)$~post_max_size = 100M~g' \
  -e 's~^enable_dl \(.*\)$~enable_dl = On~g' \
  -e 's~^upload_max_filesize \(.*\)$~upload_max_filesize = 200M~g' \
  -e "s~^upload_max_filesize = 200M$~upload_max_filesize = 200M\nmax_file_uploads = 200~g" \
	/etc/php.ini

RUN sed -i \
  -e "s~^user=mysql$~user=mysql\nmax_allowed_packet=1073741824~g" \
	/etc/my.cnf

# RUN \
#   service mysqld start && \
#   mysql -u root -e "CREATE DATABASE ${DB_NAME} /*\!40100 DEFAULT CHARACTER SET utf8 */" && \
#   mysql -u root -e "CREATE USER ${DB_NAME}@localhost IDENTIFIED BY '${DB_PASS}'" && \
#   mysql -u root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost'" && \
#   mysql -u root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%'" && \
#   mysql -u root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO 'root'@'%'" && \
#   mysql -u root -e "FLUSH PRIVILEGES"
#
  # mysql -u root <<-EOF
  #   DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
  #   DELETE FROM mysql.user WHERE User='';
  #   DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
  #   CREATE DATABASE ${DB_NAME} /*\!40100 DEFAULT CHARACTER SET utf8 */;
  #   CREATE USER ${DB_NAME}@localhost IDENTIFIED BY '';
  #   GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
  #   FLUSH PRIVILEGES;
  # EOF

# allow bigger packets for bigger db imports
# nano /etc/my.cnf
# [mysqld]
# max_allowed_packet = 1073741824

# nano /etc/php.ini # increase upload_max_filesize, (max file count), short_open_tag, post_max_size, memory_limit
# nano /etc/httpd/conf/httpd.conf # make following alteration for virtual hosts & php to work

# <Directory />
#    Options FollowSymLinks
#    AllowOverride All
# </Directory>

# DirectoryIndex index.html index.html.var index.php
# EnableSendfile off

EXPOSE 80
EXPOSE 3306

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY .database /database

# COPY httpd_merge.conf /etc/httpd/conf/httpd.conf
# COPY php_merge.ini /etc/php.ini

# ADD https://raw.githubusercontent.com/banesto/server-conf-dev/master/httpd.conf /etc/httpd/conf/httpd.conf
# ADD https://raw.githubusercontent.com/banesto/server-conf-dev/master/php.ini /etc/php.ini

# ENV SQL_FILE $(ls -dt .sql/*.sql | head -1)
# RUN SQL_FILE=$(ls -dt .sql/*.sql | head -1)
# COPY .sql/*.sql /sql/

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
