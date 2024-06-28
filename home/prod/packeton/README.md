# Packeton

https://docs.packeton.org/installation-docker.html

## Setup

Create the admin user

```shell
docker compose exec php-fpm bin/console packagist:user:manager admin --admin --password=<password>
```

## Setup Projects

Add following to your projects `composer.json`

```json
{
  "repositories": [
    { "type": "composer", "url": "https://packeton.d3strukt0r.dev/mirror/packagist"},
    { "packagist": false }
  ]
}
```

And authenticate and save it globally

```shell
composer config --global --auth http-basic.example.org username api_token
```
