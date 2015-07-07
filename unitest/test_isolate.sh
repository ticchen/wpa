#!/bin/sh


restart_wpa()
{
	wpa restart
}

toggle_count=0
toggle_ap_isolation()
{
	echo "toggle_ap_isolation: toggle_count = $toggle_count"

	if [ "$((toggle_count%2))" = "1" ];then
		telnetcmd 192.168.1.1 'cmscfg -n wifi_iface0_isolate_sta -s -v 1;' > /dev/null
		telnetcmd 192.168.1.1 'cmscfg -n wifi_iface1_isolate_sta -s -v 1;' > /dev/null
	else
		telnetcmd 192.168.1.1 'cmscfg -n wifi_iface0_isolate_sta -s -v 0;' > /dev/null
		telnetcmd 192.168.1.1 'cmscfg -n wifi_iface1_isolate_sta -s -v 0;' > /dev/null
	fi

	toggle_count=$((toggle_count+1))
}




test_connect_loop()
{
	
	
	set -e
	
	local count=0
	while true; do
		echo "==== count: $count ===="
		## connect ssid1
		echo "try to connect ssid1"
		wpa disconnect
		wpa connect psk "WLAN11_761121" "00761121"
		wpa wait_connected 60
		ping -c 5 -W 1 192.168.1.1 -w 10 -q | grep packets
		
		## connect ssid2
		echo "try to connect ssid2"
		wpa disconnect
		wpa connect psk "WLAN21_761122" "00761122"
		wpa wait_connected 60
		ping -c 5 -W 1 192.168.1.1 -w 10 -q | grep packets
				
		toggle_ap_isolation
		count=$((count+1))
	done

	set +e
}

restart_wpa
test_connect_loop

