## docker-compose.yml example:

```
version: '2'
services:
  app:
    build: .
    container_name: web
    volumes:
      - .:/var/www/html
      - ./.database:/var/lib/mysql
    ports:
      - "80:80"
      - "33066:3306"
    stdin_open: true
    environment:
      DB_NAME: jurasdzeni
      DB_USER: wordpress
      DB_PASS: wordpress
```
