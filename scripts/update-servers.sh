#!/bin/sh
JSON="../template/servers.json"
echo
echo "WARNING: Certs must be updated manually!"
echo
cd `dirname $0`
curl http://privateinternetaccess.com/vpninfo/servers?version=80 >$JSON.tmp && head -n 1 <$JSON.tmp $JSON
rm $JSON.tmp
