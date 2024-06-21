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
