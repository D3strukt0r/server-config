# Bitwarden

## First-Time Install

Guide can be found here: https://bitwarden.com/help/install-on-premise-manual/

Current version can be checked here: https://github.com/bitwarden/server/releases

```shell
curl -L https://github.com/bitwarden/server/releases/download/v<version_number>/docker-stub-EU.zip -o docker-stub.zip
# e.g.
curl -L https://github.com/bitwarden/server/releases/download/v2024.4.2/docker-stub-EU.zip -o docker-stub.zip
unzip docker-stub.zip -d .
rm docker-stub.zip
```

Set `globalSettings__baseServiceUri__cloudRegion` to `EU`

## Setup

https://bitwarden.com/help/install-on-premise-manual/

Copy the `env/global.override.env.dist` and `env/mssql.override.env.dist`

3. In `./env/global.override.env`, edit the following environment variables:

* `globalSettings__baseServiceUri__vault`: Enter the domain of your Bitwarden instance.
* `globalSettings__sqlServer__ConnectionString`: Replace the `RANDOM_DATABASE_PASSWORD` with a secure * password for use in a later step.
* `globalSettings__identityServer__certificatePassword`:Set a secure certificate password for use in a * later step.
* `globalSettings__internalIdentityKey`: Replace `RANDOM_IDENTITY_KEY` with a random key string.
* `globalSettings__oidcIdentityClientKey`: Replace `RANDOM_IDENTITY_KEY` with a random key string.
* `globalSettings__duo__aKey`: Replace `RANDOM_DUO_AKEY` with a random key string.
* `globalSettings__installation__id`: Enter an installation id retrieved from https://bitwarden.com/host.
* `globalSettings__installation__key`: Enter an installation key retrieved from https://bitwarden.com/host.

4. From service dir, generate a `.pfx` certificate file for the identity container and move it to the mapped volume directory (by default, `./identity/`). For example, run the following commands:

```shell
openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout identity.key -out identity.crt -subj "/CN=Bitwarden IdentityServer" -days 10950
```

and

```shell
openssl pkcs12 -export -out ./identity/identity.pfx -inkey identity.key -in identity.crt -passout pass:IDENTITY_CERT_PASSWORD
```

In the above command, replace `IDENTITY_CERT_PASSWORD` with the certificate password created and used in Step 3.

5. Create a subdirectory in `./ssl` named for your domain, for example:

```shell
mkdir ./ssl/bitwarden.d3strukt0r.dev
```

6. Provide a trusted SSL certificate and private key in the newly created `./ssl/bitwarden.d3strukt0r.dev` subdirectory.

7. In `./nginx/default.conf`:

  2. Set the `ssl_certificate` and `ssl_certificate_key` variables to the paths of the certificate and private key provided in Step 6.
  3. Take one of the following actions, depending on your certificate setup:

    * If using a trusted SSL certificate, set the `ssl_trusted_certificate` variable to the path to your certificate.
    * If using a self-signed certificate, comment out the `ssl_trusted_certificate` variable.

8. In `./env/mssql.override.env`, replace `RANDOM_DATABASE_PASSWORD` with the password created in Step 3.

10. In `./env/uid.env`, set the UID and GID of the `bitwarden` users and group you created earlier so the containers run under them, for example:

```
LOCAL_UID=1001
LOCAL_GID=1001
```
