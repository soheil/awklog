#!/bin/bash

echo ""
echo "AwkLog service started. Please visit https://awklog.com to see the logs on your dashboard."
echo ""
cd /var/log
tail -n0 -F apache2/*.log httpd/*.log nginx/*.log 2> /dev/null | \
  grep --line-buffered -v ingest | \
  while read LINE; do
    curl -H 'apikey: API_KEY' -X POST -s \
      --data-urlencode "log=$LINE" \
      --data-urlencode "top=$(top -bcn1 -w512|head -5)" \
      --data-urlencode "host_ip=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')" \
      --data-urlencode "hostname=$(hostname)" \
      https://awklog.com/ingest
  done
