# Gitea

## Create PhpMyAdmin DB and user

```shell
mariadb --password=${MARIADB_ROOT_PASSWORD}
```

```sql
CREATE DATABASE phpmyadmin;
GRANT ALL PRIVILEGES ON phpmyadmin.* TO 'pma'@'%' IDENTIFIED BY '${DB_PMA_PASSWORD}';
```

Then create tables from UI (In container /var/www/html/sql/create_tables.sql)

## Secret keys for Gitea (DO NOT LOSE THEM AFTER SETUP)

```shell
docker run -it --rm gitea/gitea:1 gitea generate secret SECRET_KEY
docker run -it --rm gitea/gitea:1 gitea generate secret INTERNAL_TOKEN
```

and save in env for `GITEA__security__SECRET_KEY` and `GITEA__security__INTERNAL_TOKEN`

## Setup in UI

`Seitentitel`: `Gitea: D3strukt0r`
`Aktualisierungsprüfung aktivieren`: Enable
`Versteckte E-Mail-Domain`: `noreply.d3st.dev`

Create Admin User

Administrator-Benutzername: `D3strukt0r`
E-Mail-Adresse: `gitea-contact@d3st.dev`
Passwort: x
Passwort bestätigen: x

## Setup `git` user on host for `git clone` command

See https://docs.gitea.com/installation/install-with-docker#sshing-shim-with-authorized_keys
but should be already be done by running `setup.sh`
