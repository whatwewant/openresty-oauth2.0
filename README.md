# Docker image of openresty with Oauth 2.0

[![Docker Stars](https://img.shields.io/docker/stars/whatwewant/openresty-oauth2.0.svg)](https://hub.docker.com/r/whatwewant/openresty-oauth2.0)
[![Docker Pulls](https://img.shields.io/docker/pulls/whatwewant/openresty-oauth2.0.svg)](https://hub.docker.com/r/whatwewant/openresty-oauth2.0)
[![Docker Automated](https://img.shields.io/docker/automated/whatwewant/openresty-oauth2.0.svg)](https://hub.docker.com/r/whatwewant/openresty-oauth2.0)
[![Docker Build](https://img.shields.io/docker/build/whatwewant/openresty-oauth2.0.svg)](https://hub.docker.com/r/whatwewant/openresty-oauth2.0)

Simple HTTP Proxy with Basic Authentication

```
                      +------------------------+      +-------------+
User ---------------> | openresty-oauth2.0     | ---> | HTTP Server |
                      +------------------------+      +-------------+
```

## Run

```bash
$ docker run \
    --rm \
    --name openresty-oauth2.0 \
    -p 8080:80 \
    -p 8090:8090 \
    -e BASIC_AUTH_USERNAME=username \
    -e BASIC_AUTH_PASSWORD=password \
    -e PROXY_PASS=https://www.google.com \
    -e SERVER_NAME=whatwewant.com \
    -e PORT=80 \
    whatwewant/openresty-oauth2.0
```

Access to http://localhost:8080 , then browser will shoud unauthorized if no authorization provided.

You can also try complete HTTP-proxy example using Docker Compose.
hello-world web application cannot be accessed without authentication.

```bash
$ docker-compose up
# curl http://localhost:8080 -H "Authorization: Bearer zero"
```

### Endpoint for monitoring

`:8090/nginx_status` returns the metrics of Nginx.

```sh-session
$ curl localhost:8090/nginx_status
Active connections: 1
server accepts handled requests
 8 8 8
Reading: 0 Writing: 1 Waiting: 0
```

## Environment variables

### Required

|Key|Description|
|---|---|
|`BEARER_TOKEN`|Bearer Token|
|`PROXY_PASS_UPSTREAM`|Proxy destination URL|

### Optional

|Key|Description|Default|
|---|---|---|
|`SERVER_NAME`|Value for `server_name` directive|`example.com`|
|`PORT`|Value for `listen` directive|`80`|
|`CLIENT_MAX_BODY_SIZE`|Value for `client_max_body_size` directive|`1m`|
|`PROXY_READ_TIMEOUT`|Value for `proxy_read_timeout` directive|`60s`|
|`WORKER_PROCESSES`|Value for `worker_processes` directive|`auto`|

## Thanks

Inpired by Daisuke Fujita ([@dtan4](https://github.com/dtan4))

## License

[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)