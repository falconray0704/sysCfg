#!/bin/sh

source ./.env_target

disable_all_dns_servers()
{
	local name='dns_servers'
	local option=enabled
	local value=1
	local rname=""
	local enabled='0'

	local i=0
	while [[ true ]]
	do
		rname=$( uci get "openclash.@dns_servers[$i]" 2> /dev/null )

		if [[ $? != 0 ]]
		then
			# no more rules
			#echo "no more servers..."
			break
		fi

		if [[ "${rname}" = "${name}" ]]
		then
			#echo "found ${name}[$i]"
			enabled=$( uci get "openclash.@dns_servers[$i].enabled" 2> /dev/null )
			if [ ${enabled} = '1' ]
			then
				uci set openclash.@dns_servers[$i].enabled=0

				#enabled=$( uci get "openclash.@dns_servers[$i].enabled" 2> /dev/null )
				#echo "${name}[$i].enabled=${enabled}"
			fi
		else
			echo "rname: ${rname}"
		fi

		let i++
	done
	uci commit openclash
}

delete_all_default_dns_servers()
{
	local name='dns_servers'
	local group='default'
	local rname=""
	local gname=""

	local i=0

	while [[ true ]]
	do
		rname=$( uci get "openclash.@dns_servers[$i]" 2> /dev/null )

		if [[ $? != 0 ]]
		then
			echo "no more servers..."
			break
		fi

		gname=$( uci get "openclash.@dns_servers[$i].group" 2> /dev/null )

		if [[ "${gname}" = "${group}" ]]
		then
			#echo "found ${name}[$i]"
			uci del openclash.@dns_servers[-1]
		else
			echo "gname: ${gname}"
		fi
		let i++
	done
	uci commit openclash
}


config_default_dns_servers()
{

	## now loop through the above array
	for srvIP in ${OPENCLASH_DEFAULT_DNS_SERVERS}
	do
		#echo "$srvIP"

		uci add openclash dns_servers
		uci set openclash.@dns_servers[-1].enable='1'
		uci set openclash.@dns_servers[-1].group='default'
		uci set openclash.@dns_servers[-1].type='udp'
		uci set openclash.@dns_servers[-1].ip="${srvIP}"
		uci set openclash.@dns_servers[-1].interface='Disable'
		uci set openclash.@dns_servers[-1].node_resolve='0'
	done
	uci commit openclash
}

config_name_servers()
{

	## config dnscrypt
	uci add openclash dns_servers
	uci set openclash.@dns_servers[-1].enable='1'
	uci set openclash.@dns_servers[-1].group='nameserver'
	uci set openclash.@dns_servers[-1].type='udp'
	uci set openclash.@dns_servers[-1].ip='127.0.0.53'
	uci set openclash.@dns_servers[-1].interface='Disable'
	uci set openclash.@dns_servers[-1].node_resolve='0'
	uci set openclash.@dns_servers[-1].specific_group='Disable'

	## config https dns
	for srvIP in ${OPENCLASH_NAME_SERVERS}
	do
		#echo "$srvIP"
		uci add openclash dns_servers
		uci set openclash.@dns_servers[-1].enable='1'
		uci set openclash.@dns_servers[-1].group='nameserver'
		uci set openclash.@dns_servers[-1].type='https'
		uci set openclash.@dns_servers[-1].ip="${srvIP}"
		uci set openclash.@dns_servers[-1].interface='Disable'
		uci set openclash.@dns_servers[-1].node_resolve='0'
		uci set openclash.@dns_servers[-1].http3='0'
		uci set openclash.@dns_servers[-1].specific_group='Disable'
	done

	uci commit openclash
}

config_plugin_settings()
{
	uci set openclash.config.enable_custom_dns='1'

	uci set openclash.config.proxy_mode='global'
	uci commit openclash
}


disable_all_dns_servers

delete_all_default_dns_servers

config_default_dns_servers

config_name_servers

config_plugin_settings

