
#!/bin/ash

## refer to: 
## https://openwrt.org/docs/guide-user/services/dns/dnscrypt_dnsmasq_dnscrypt-proxy2
## https://github.com/dnscrypt/dnscrypt-proxy/wiki/Installation-on-OpenWRT
## https://dnscrypt.info/public-servers/


source ./.env_target

# Enable DNS encryption
/etc/init.d/dnsmasq stop
uci set dhcp.@dnsmasq[0].noresolv="1"
uci set dhcp.@dnsmasq[0].localuse="1"
uci set dhcp.@dnsmasq[0].cachesize='0'
uci -q delete dhcp.@dnsmasq[0].server
uci add_list dhcp.@dnsmasq[0].server="127.0.0.53"

#sed -i "32 s/.*/server_names = ['cloudflare', 'google', 'scaleway-fr', 'yandex', 'dnscrypt.ca-1', 'dnscrypt.ca-2', 'dnscry.pt-chicago-ipv4', 'plan9dns-nj', 'dnscry.pt-sydney-ipv4', 'ibksturm', 'v.dnscrypt.uk-ipv4', 'dnscry.pt-london-ipv4', 'plan9dns-fl', 'faelix-uk-ipv4', 'scaleway-ams', 'sth-dnscrypt-se', 'dnscry.pt-newyork-ipv4', 'saldns02-conoha-ipv4']/" /etc/dnscrypt-proxy2/dnscrypt-proxy.toml

sed -i "32 s/.*/server_names = ['cloudflare', 'dnscry.pt-chicago-ipv4', 'google', 'dnscrypt.ca-1', 'dnscrypt.ca-2', 'yandex', 'plan9dns-nj', 'dnscry.pt-sydney-ipv4', 'ibksturm', 'v.dnscrypt.uk-ipv4', 'dnscry.pt-london-ipv4', 'plan9dns-fl', 'faelix-uk-ipv4', 'scaleway-fr', 'scaleway-ams', 'sth-dnscrypt-se', 'dnscry.pt-newyork-ipv4', 'saldns02-conoha-ipv4']/" /etc/dnscrypt-proxy2/dnscrypt-proxy.toml

sed -i "264 s/.*/bootstrap_resolvers = ['1.1.1.1:53', '114.114.114.114:53', '9.9.9.11:53', '8.8.8.8:53']/" /etc/dnscrypt-proxy2/dnscrypt-proxy.toml

uci commit dhcp
/etc/init.d/dnsmasq start
/etc/init.d/dnscrypt-proxy restart
#logread -l 100 | grep dnsmasq

# Completely disable ISP's DNS servers
uci set network.${USB_INTERFACE_WAN_NAME}.peerdns='0'
uci changes network
uci commit network

# Force LAN clients to send DNS queries to dnscrypt-proxy
#cat ./firewall_dnscrypt_proxy >> /etc/config/firewall
#uci changes firewall
#uci commit firewall

# Test
#nslookup openwrt.org localhost

# Check that you are not using your ISP resolver any more:
# dnscrypt-proxy -resolve google.com
dnscrypt-proxy -config /etc/dnscrypt-proxy2/dnscrypt-proxy.toml  -resolve google.com

# Check that processes on the router use dnsmasq:
cat /etc/resolv.conf


