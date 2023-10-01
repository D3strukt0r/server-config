# https://docs.fluentd.org/container-deployment/docker-compose#step-1-create-fluentd-image-with-your-config-+-plugin
FROM fluent/fluentd:edge-debian
USER root
RUN set -e -u -x \
    && apt-get update \
    && apt-get install -y make gcc
RUN set -e -u -x \
    && gem install --no-document \
        fluent-plugin-mongo
        # fluent-plugin-rewrite-tag-filter
        # fluent-plugin-multi-format-parser
        # fluent-plugin-route
        # fluent-plugin-elasticsearch
USER fluent
