#!/bin/sh

watch() {
  ### Set initial time of file
  LTIME=`stat -c %Z $1`

  while true    
  do
    ATIME=`stat -c %Z $1`

    if [[ "$ATIME" != "$LTIME" ]]
    then    
       echo "file $1 change, run command: $2"
       LTIME=$ATIME
       $2
    fi
    sleep 1
  done
}

# watch core.lua "nginx -s reload"
watch /usr/local/openresty/lualib/oauth/authorize.lua "nginx -s reload"