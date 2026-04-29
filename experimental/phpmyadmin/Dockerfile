FROM phpmyadmin

# https://forums.docker.com/t/using-docker-in-a-dockerized-jenkins-container/322/10
# https://docs.docker.com/engine/install/binaries/
# https://download.docker.com/linux/static/stable/x86_64/
# https://www.lvh.io/posts/dont-expose-the-docker-socket-not-even-to-a-container/
# https://stackoverflow.com/questions/22135897/access-docker-socket-within-container/33183227#33183227
# https://docs.docker.com/engine/api/v1.45/

RUN apt-get update \
    && apt-get install --no-install-recommends --yes \
        jq \
        supervisor

# Get list of all images using mysql or mariadb image from docker.sock
# https://docs.docker.com/engine/api/v1.45/#tag/Container/operation/ContainerList
# curl --unix-socket /var/run/docker.sock --get --data-urlencode "filters={\"ancestor\": [\"mysql\", \"mariadb\"]}" http://localhost/containers/json | jq '.[].Names'
