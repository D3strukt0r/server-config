# Verdaccio

## Setup

To add user to htpasswd run

```shell
touch config/htpasswd
chown 10001:root config/htpasswd

# if storage folder is not writable, "pnpm publish" will throw "no such package available"
if [ ! -d storage ]; then mkdir storage; fi
chown 10001:root storage
```

## Setup on Developer Machine

```shell
npmrc -c d3strukt0r
npm config set registry https://verdaccio.d3strukt0r.dev

# Comment out "max_users: -1"
pnpm adduser
# Uncomment "max_users: -1"

pnpm login --auth-type=legacy

pnpm publish
```
