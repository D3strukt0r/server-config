# fluentd logs

## Prepare data

```bash
mkdir logs
chown 999 logs
```

## Setup DB for fluentd login user

```shell
mongosh
```

```mongo
use admin

db.auth("adminUser", "adminPassword")

use fluentd

db.createUser({
  user: "dbUser",
  pwd: "dbPassword",
  roles: [
    { role: "readWrite", db: "fluentd" }
  ]
})
```