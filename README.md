# Server configuration with Docker Compose

## Setup

Stop nginx

```shell
systemctl stop nginx
```

Add network

```shell
docker network create traefik_proxy
```

Add acme store

```
mkdir traefik
cd traefik
touch acme.json
chmod 600 acme.json
```

## Backup

## Restore
