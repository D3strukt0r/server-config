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

## Create JWT keys

To generate new keys first update the compose.yml so that the volume is not
`:ro` anymore, then run the following command after having a password for the
private key (`JWT_PASSPHRASE`) and then set `:ro` on the volume again:

```shell
bin/console lexik:jwt:generate-keypair
```
