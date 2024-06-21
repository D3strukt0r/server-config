# Wedding Manager

## Create PhpMyAdmin DB and user

```shell
mariadb --password=${MARIADB_ROOT_PASSWORD}
```

```sql
CREATE DATABASE phpmyadmin;
GRANT ALL PRIVILEGES ON phpmyadmin.* TO 'pma'@'%' IDENTIFIED BY '${DB_PMA_PASSWORD}';
```

Then create tables from UI (In container /var/www/html/sql/create_tables.sql)

## Change prefix

It's not just table names, but sometimes columns too. Search and replace table 
names first with

```
`wp_ -> `new_
```

Then search and replace the remaining occurences with (check before replacing)

```
(?<![a-z])wp_ -> new_
```
