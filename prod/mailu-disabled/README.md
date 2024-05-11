# Mailu

https://mailu.io/2.0/compose/setup.html

https://setup.mailu.io/2.0/

https://setup.mailu.io/2.0/setup/2906f94e-5ce7-4bff-b780-0e0d2defb3f1

## Setup

Before you can use Mailu, you must create the primary administrator user account. This should be admin@d3strukt0r.dev. Use the following command, changing PASSWORD to your liking:

```shell
docker compose -p mailu exec admin flask mailu admin admin d3strukt0r.dev PASSWORD
```

Login to the admin interface to change the password for a safe one, at one of the hostnames mail.d3strukt0r.dev. Also, choose the "Update password" option in the left menu.
