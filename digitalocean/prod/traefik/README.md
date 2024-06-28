
# Traefik

* Add Docker network for Traefik

```shell
docker network create traefik_proxy
```

* Add acme store for Let's Encrypt with Traefik (Requires 600 permission)

```shell
touch ./traefik/acme.json
chmod 600 ./traefik/acme.json
```

* Copy `.env.dist` to `.env` (`cp .env.dist .env`) and fill with info from 1Password Backup (Traefik | Prod | Config)

* After starting, login to Grafana with default admin/admin credentials and change the password.

## Setup grafana

Login first with `admin` and `admin` credentials and change the password.

Then restart the service.
