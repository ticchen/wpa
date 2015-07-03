#!/bin/bash

###############
# debug
###############
#exec 6>&1           # Saves stdout.
#exec 1>/tmp/debug	# Redirect strout to debug file
#exec 2>&1

## include wpa lib
. "$(dirname $0)/wpa_lib.sh" || . "$(dirname $0)/wpa_lib/wpa_lib.sh"

# network interface
wpa_iface="$1"
# wpa_action = CONNECTED|DISCONNECTED
wpa_action="$2"

case "$wpa_action" in
	## used as wpa_cli action script
	"CONNECTED")
		#get ip
		udhcpc_renew
		;;
	"DISCONNECTED")
		#release ip
		udhcpc_release
		;;
	## user space command
	*)
		echo "Unknown action: \"$wpa_action\""
		exit 1
		;;
esac

exit 0
