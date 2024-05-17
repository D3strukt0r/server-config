# https://verdaccio.org/docs/docker/#creating-your-own-dockerfile-using-verdaccioverdacciotag-as-base
# https://github.com/verdaccio/verdaccio/tree/master/docker-examples/v5/plugins/docker-build-install-plugin

ARG VERDACCIO_VERSION

FROM verdaccio/verdaccio:${VERDACCIO_VERSION:-latest}

# Install the plugins
# https://github.com/bchanudet/verdaccio-mysql
# https://github.com/verdaccio/monorepo/tree/main/plugins/aws-s3-storage
# https://github.com/barolab/verdaccio-minio
# https://github.com/youreadforme/verdaccio-gitea-auth
# https://github.com/n4bb12/verdaccio-npm-urls
USER root
RUN npm install --global \
        verdaccio-mysql \
        verdaccio-aws-s3-storage \
        verdaccio-minio \
        verdaccio-gitea-auth \
        verdaccio-npm-urls

RUN apk add --no-cache bash

USER $VERDACCIO_USER_UID
