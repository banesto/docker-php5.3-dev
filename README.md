# Docker php5.3 for development

## Docker Hub

Here's the [link to Docker Hub build](https://hub.docker.com/r/banesto/docker-php5.3-dev/)

## Basic setup

Image is based on Centos 6, uses php 5.3 and mysql 5.1. It makes following configuration changes:

### Apache config (/etc/httpd/conf/httpd.conf)

```
Timeout 120                                         # for elaborate scripts to complete without timeout
ServerName 0.0.0.0:80                               # to supress apache warning about wrong server name
DirectoryIndex index.html index.html.var index.php  # for accepting index.php as index file
EnableSendfile Off                                  # for better file syncing between host and container
AllowOverride All                                   # for mod_rewrite to work
```

### PHP config (/etc/php.ini)

Increase values and enable some features

```
short_open_tag = On
max_execution_time = 300
memory_limit = 512M
post_max_size = 100M
enable_dl = On
upload_max_filesize = 200M
max_file_uploads = 200
```

### MySQL config (/etc/my.cnf)

Increase packet size for huge data loads

```
max_allowed_packet=1073741824
```

## Usage

This image is designed to work with [Docker v2](https://blog.docker.com/2016/03/docker-for-mac-windows-beta/).

Create docker-compose.yml file in the root of your application (like the one below). Specify volumes that will be attached to container.

The volume attached as `/sql` on container will act as a .sql file storage. In the initial container launch, docker will try to search for latest .sql file in that directory and import it into newly created database. Upon each container stop, sql backup file will be placed in that directory with timestamp & databasde name in the filename (e.g. `mydatabase_docker_dump_2016-06-24_15.16.17.sql`)

## docker-compose.yml example:

```
version: '2'
services:
  app:
    image: banesto/docker-php5.3-dev
    container_name: web
    volumes:
      - .:/var/www/html
      - ./.database:/var/lib/mysql
      - ./sql:/sql
    ports:
      - "80:80"
      - "33066:3306"
    stdin_open: true
    environment:
      DB_NAME: mydatabase
      DB_USER: database_user
      DB_PASS: Pa55wrD
```

### Volumes

* `.:/var/www/html` - sets up applications root directory as main project on container
* `./.database:/var/lib/mysql` - directory to store mysql database files in it in order to preserve data after container is destroyed
* `./sql:/sql` - directory for storing sql dumps - each time container stops, there will be created one sql dump with full

Of course you can change names of the directories on you application root directory (it could be `.data` instead of `.database` for example).

### Environment

Set up all the credentials for database to use in your app.
