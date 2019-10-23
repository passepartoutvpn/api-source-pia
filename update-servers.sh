#!/bin/bash
URL="http://privateinternetaccess.com/vpninfo/servers?version=80"
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
