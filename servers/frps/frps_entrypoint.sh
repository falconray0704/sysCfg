#!/bin/sh

set -o nounset
set -o errexit

which frps
ls -al /etc/frp/frps.ini
cat /etc/frp/frps.ini
/usr/bin/frps -c /etc/frp/frps.ini

