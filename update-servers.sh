#!/bin/bash
TPL="template"
SERVERS="$TPL/servers.json"

echo
echo "WARNING: Certs must be updated manually!"
echo

mkdir -p $TPL
if ! curl -L http://privateinternetaccess.com/vpninfo/servers?version=80 >$SERVERS.tmp; then
    exit
fi
head -n 1 <$SERVERS.tmp >$SERVERS
rm $SERVERS.tmp
