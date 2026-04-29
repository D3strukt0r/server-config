# Verdaccio

## Create PhpMyAdmin DB and user

```shell
mariadb --password=${MARIADB_ROOT_PASSWORD}
```

```sql
CREATE DATABASE phpmyadmin;
GRANT ALL PRIVILEGES ON phpmyadmin.* TO 'pma'@'%' IDENTIFIED BY '${DB_PMA_PASSWORD}';
```

Then create tables from UI (In container /var/www/html/sql/create_tables.sql)

## Setup

Go to minio dashboard and add a bucket called `default`

To add user to htpasswd run

```shell
touch config/htpasswd
chown 10001:root config/htpasswd

# if storage folder is not writable, "pnpm publish" will throw "no such package available"
if [ ! -d storage/data ]; then mkdir -p storage/data; fi
chown -R 10001:root storage
```

## Setup on Developer Machine

```shell
npmrc -c d3strukt0r
npm config set registry https://verdaccio.d3strukt0r.dev

# Comment out "max_users: -1" for htpasswd auth
# Set "add_user" to the required sql query for mysql auth
pnpm adduser
# Uncomment "max_users: -1"
# Set "add_user" to "" for mysql auth

pnpm login --auth-type=legacy

pnpm publish
```
