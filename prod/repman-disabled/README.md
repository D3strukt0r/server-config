# Repman

https://repman.io/docs/standalone/#docker-installation

https://github.com/repman-io/repman

## Setup

Download docker, public and var folders from repo using following

https://stackoverflow.com/questions/33066582/how-to-download-a-folder-from-github

docker is marked as ignored in gitattributes, so we need to clone and copy from there

```shell
git clone https://github.com/repman-io/repman.git repman-master
for folder in docker public var; do
  cp -r repman-master/$folder .
done
rm -rf repman-master
```

in `docker/nginx/scripts/nginx.conf` set `client_max_body_size` to `100M`

