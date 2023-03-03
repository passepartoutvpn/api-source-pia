#!/bin/bash
URL="https://serverlist.piaservers.net/vpninfo/servers/v6"
TPL="template"
SERVERS="$TPL/servers.json"

echo
echo "WARNING: Certs must be updated manually!"
echo

mkdir -p $TPL
if ! curl -L $URL >$SERVERS.tmp; then
    exit
fi
head -n 1 <$SERVERS.tmp >$SERVERS
rm $SERVERS.tmp
