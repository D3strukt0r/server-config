#!/bin/bash
set -e -u -o pipefail

# https://github.com/tiredofit/docker-db-backup/issues/253
# restore <s3-path> <db_type> <db_hostname> <db_name> <db_user> <db_pass> <db_port>

export AWS_ACCESS_KEY_ID=${DB01_S3_KEY_ID:-${DEFAULT_S3_KEY_ID}} # $(cat ${DEFAULT_S3_KEY_ID_FILE})
export AWS_SECRET_ACCESS_KEY=${DB01_S3_KEY_SECRET:-${DEFAULT_S3_KEY_SECRET}} # $(cat ${DEFAULT_S3_KEY_SECRET_FILE})
export AWS_DEFAULT_REGION=${DB01_S3_REGION:-${DEFAULT_S3_REGION}}
export DEFAULT_PARAMS_AWS_ENDPOINT_URL=" --endpoint-url ${DB01_S3_PROTOCOL:-${DEFAULT_S3_PROTOCOL:-https}}://${DB01_S3_HOST:-${DEFAULT_S3_HOST}}"
export DEFAULT_FILESYSTEM_PATH=${DEFAULT_FILESYSTEM_PATH:-/backup}

export SOURCE_FILE="mariadb_.*\.gz$"
# ex. mariadb_db_mariadb_20241111-075454.sql.gz -> HOST_DB_TYPE_DATE_TIME.sql.gz
export LATEST_FILE=$(aws s3 ls "s3://${DEFAULT_S3_BUCKET}/${DEFAULT_S3_PATH}/" ${DEFAULT_PARAMS_AWS_ENDPOINT_URL} --recursive | grep -E "${SOURCE_FILE}" | sort -r | head -n 1 | awk '{print $4}')
export TARGET_FILE=$(basename "$LATEST_FILE")
aws s3 cp s3://${DEFAULT_S3_BUCKET}/${LATEST_FILE} ${DEFAULT_FILESYSTEM_PATH}/${TARGET_FILE} ${DEFAULT_PARAMS_AWS_ENDPOINT_URL}
aws s3 cp s3://${DEFAULT_S3_BUCKET}/${LATEST_FILE}.sha1 ${DEFAULT_FILESYSTEM_PATH}/${TARGET_FILE}.sha1 ${DEFAULT_PARAMS_AWS_ENDPOINT_URL}

# restore <filename> <db_type> <db_hostname> <db_name> <db_user> <db_pass> <db_port>
restore ${DEFAULT_FILESYSTEM_PATH}/${TARGET_FILE} ${DB01_TYPE} ${DB01_HOST} ${DB01_NAME} ${DB01_USER} ${DB01_PASS} ${DB01_PORT:-${DEFAULT_PORT:-3306}}
