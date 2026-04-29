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

db.auth("root", "<current-password:.mongo.env:ROOT_PASSWORD>")

use fluentd

db.createUser({
  user: "fluentd",
  pwd: "<new-password:.env:DATABASE_PASSWORD>",
  roles: [
    { role: "readWrite", db: "fluentd" }
  ]
})
```

## Helper functions

```mongo
use admin
db.system.users.find()
```
