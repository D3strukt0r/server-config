# Wedding Manager

## Create PhpMyAdmin user

```shell
mariadb --password=${MARIADB_ROOT_PASSWORD}
```

```sql
CREATE DATABASE phpmyadmin;
GRANT ALL PRIVILEGES ON phpmyadmin.* TO 'pma'@'%' IDENTIFIED BY '${DB_PMA_PASSWORD}';
```

## Create JWT keys

Run following command after having a password for the private key (`JWT_PASSPHRASE`):

```shell
bin/console lexik:jwt:generate-keypair
```
