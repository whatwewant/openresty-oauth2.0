#!/bin/sh

set -e

if [ -z $PROXY_PASS ]; then
  echo >&2 "PROXY_PASS must be set"
  exit 1
fi

if [ -z $ROOT_URL ]; then
  echo >&2 "ROOT_URL must be set"
  exit 1
fi

if [ -z $PROVIDER ]; then
  echo >&2 "PROVIDER must be set"
  exit 1
fi

if [ -z $CLIENT_ID ]; then
  echo >&2 "CLIENT_ID must be set"
  exit 1
fi

if [ -z $CLIENT_SECRET ]; then
  echo >&2 "CLIENT_SECRET must be set"
  exit 1
fi

sed \
  -e "s/##CLIENT_MAX_BODY_SIZE##/$CLIENT_MAX_BODY_SIZE/g" \
  -e "s/##PROXY_READ_TIMEOUT##/$PROXY_READ_TIMEOUT/g" \
  -e "s/##WORKER_PROCESSES##/$WORKER_PROCESSES/g" \
  -e "s/##SERVER_NAME##/$SERVER_NAME/g" \
  -e "s/##PORT##/$PORT/g" \
  -e "s|##PROXY_PASS##|$PROXY_PASS|g" \
  /nginx.conf.tmpl > /usr/local/openresty/nginx/conf/nginx.conf

exec openresty  -g "daemon off;"
