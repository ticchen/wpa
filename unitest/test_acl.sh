#!/bin/sh

timeout="${timeout:-60}"


restart_wpa()
{
	wpa restart
}

toggle_count=0

ap_set_acl()
{
	#ap: 0~n
	local ap=$1
	#policy: disabled,allow,deny
	local policy=$2
	
	telnetcmd 192.168.1.1 "cmscfg -n wifi_iface${ap}_macfilter_list -s -v c8:3a:35:cb:8e:5b -r;" > /dev/null
	telnetcmd 192.168.1.1 "cmscfg -n wifi_iface${ap}_macfilter -s -v ${policy};" > /dev/null
}


test_connect_loop()
{
	local count=0
	

	
	echo "pre-start: try to connect DUT anyway"
	wpa disconnect
	(wpa connect psk "WLAN11_761121" "00761121" && wpa wait_connected ${timeout} ) || \
		(wpa connect psk "WLAN21_761122" "00761122" && wpa wait_connected ${timeout} )
	
	set -e
	while true; do
		echo "==== count: $count ===="


		###################################
		echo "AP0: allow ACL, AP1: deny ACL"
		###################################
		ap_set_acl 0 "allow"
		ap_set_acl 1 "deny"
		sleep 3

		## connect AP1
		echo "try to connect AP1 (should fail)"
		wpa disconnect
		wpa connect psk "WLAN21_761122" "00761122"
		if [ "$(wpa wait_connected ${timeout} 2>/dev/null)" = "connect" ]; then
			echo "Error: ACL function is broken" 1>&2
			exit 1
		fi		
		
		## connect AP0
		echo "try to connect AP0"
		wpa disconnect
		wpa connect psk "WLAN11_761121" "00761121"		
		if [ "$(wpa wait_connected ${timeout} 2>/dev/null)" = "timeout" ]; then
			echo "Error: fail to connect" 1>&2
			exit 1
		fi
		ping -c 5 -W 1 192.168.1.1 -w 10 -q | grep packets


		###################################
		echo "AP0: deny ACL, AP1: allow ACL"
		###################################
		ap_set_acl 1 "allow"
		ap_set_acl 0 "deny"
		sleep 3

		## connect AP0
		echo "try to connect AP0 (should fail)"
		wpa disconnect
		wpa connect psk "WLAN11_761121" "00761121"		
		if [ "$(wpa wait_connected ${timeout} 2>/dev/null)" = "connect" ]; then
			echo "Error: ACL function is broken" 1>&2
			exit 1
		fi

		## connect AP1
		echo "try to connect AP1"
		wpa disconnect
		wpa connect psk "WLAN21_761122" "00761122"
		if [ "$(wpa wait_connected ${timeout} 2>/dev/null)" = "timeout" ]; then
			echo "Error: fail to connect" 1>&2
			exit 1
		fi
		ping -c 5 -W 1 192.168.1.1 -w 10 -q | grep packets



		###################################
		echo "AP0: disable ACL, AP1: disable ACL"
		###################################
		ap_set_acl 0 "disabled"
		ap_set_acl 1 "disabled"
		sleep 3

		## connect AP0
		echo "try to connect AP0"
		wpa disconnect
		wpa connect psk "WLAN11_761121" "00761121"		
		if [ "$(wpa wait_connected ${timeout} 2>/dev/null)" = "timeout" ]; then
			echo "Error: fail to connect" 1>&2
			exit 1
		fi
		ping -c 5 -W 1 192.168.1.1 -w 10 -q | grep packets
		
		## connect AP1
		echo "try to connect AP1"
		wpa disconnect
		wpa connect psk "WLAN21_761122" "00761122"
		if [ "$(wpa wait_connected ${timeout} 2>/dev/null)" = "timeout" ]; then
			echo "Error: fail to connect" 1>&2
			exit 1
		fi
		ping -c 5 -W 1 192.168.1.1 -w 10 -q | grep packets

		count=$((count+1))
	done
	set +e

}

restart_wpa
test_connect_loop
