FROM openresty/openresty:1.19.9.1-alpine

# WORKDIR /usr/local/openresty/nginx/conf
WORKDIR /usr/local/openresty/lualib/oauth

RUN rm -f /etc/nginx/conf.d/*

ENV SERVER_NAME example.com
ENV PORT 80
ENV CLIENT_MAX_BODY_SIZE 1m
ENV PROXY_READ_TIMEOUT 60s
ENV WORKER_PROCESSES auto

COPY ./packages/core/config/watch.sh /usr/local/bin

COPY ./packages/core/config/endpoint.sh /
COPY ./packages/core/config/nginx.conf.tmpl /
COPY ./packages/lib /usr/local/openresty/lualib
COPY ./packages /usr/local/openresty/lualib/oauth
# COPY ./src /lua

CMD sh /endpoint.sh
