#!/bin/sh

set -o nounset
set -o errexit

which frps
ls -al /etc/frp/frpc.ini
cat /etc/frp/frpc.ini
/usr/bin/frpc -c /etc/frp/frpc.ini

