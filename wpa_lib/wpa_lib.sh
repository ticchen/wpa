## try to find wpa_work_dir
if [ -d "${PWD}/wpa_lib" ];then
	wpa_work_dir="$(readlink -f ${PWD} 2>/dev/null)"
elif [ "$(basename ${PWD})" = "wpa_lib" ];then
	wpa_work_dir="$(readlink -f ${PWD}/../ 2>/dev/null)"
elif [ "$(basename $(dirname $0))" = "wpa_lib" ];then
	wpa_work_dir="$(readlink -f $(dirname $0)/../ 2>/dev/null)"
fi

if [ -z "$wpa_work_dir" ]; then
	echo "Error: no valid wpa_work_dir" 1>&2
	return 1
fi

## wpa_work_dir
PATH="$wpa_work_dir:$PATH"

## wpa_lib_dir
wpa_lib_dir="${wpa_work_dir}/wpa_lib"
[ -d "${wpa_lib_dir}" ]


## include wpa config file
wpa_config="${wpa_lib_dir}/wpa.conf"
if [ -f "${wpa_config}" ]; then
	. "${wpa_config}"
else
	echo "Error: missing ${wpa_config}" 1>&2
	return 1
fi

wpa_tmp_dir="/tmp/wpa/${wpa_iface}"
[ -d "${wpa_tmp_dir}" ] || mkdir -p "${wpa_tmp_dir}"

wpa_supplicant_controlfile()
{
	local file="${wpa_tmp_dir}/wpa_supplicant.ctrl"
	echo "$file"
}

wpa_supplicant_pidfile()
{
	local file="${wpa_tmp_dir}/wpa_supplicant.pid"
	echo "$file"
}

wpa_supplicant_pid()
{
	local file="$(wpa_supplicant_pidfile)"

	if [ -f "$file" ]; then
		cat "$file"
	fi
}


wpa_supplicant_is_running()
{
	if [ -f "$(wpa_supplicant_pidfile)" ] && [ -d "/proc/$(wpa_supplicant_pid)" ]; then
		echo "1"
		return 0
	else
		echo "0"
		return 1
	fi
}


wpa_cli_pidfile()
{
	local file="${wpa_tmp_dir}/wpa_cli.pid"
	echo "$file"
}


wpa_cli_pid()
{
	local file="$(wpa_cli_pidfile)"

	if [ -f "$file" ]; then
		cat "$file"
	fi
}


wpa_cli_is_running()
{
	if [ -f "$(wpa_cli_pidfile)" ] && [ -d "/proc/$(wpa_cli_pid)" ]; then
		echo "1"
		return 0
	else
		echo "0"
		return 1
	fi
}


udhcpc_pidfile()
{
	local file="${wpa_tmp_dir}/udhcpc.pid"
	echo "$file"
}


udhcpc_pid()
{
	local file="$(udhcpc_pidfile)"

	if [ -f "$file" ]; then
		cat "$file"
	fi
}


udhcpc_is_running()
{
	if [ -f "$(udhcpc_pidfile)" ] && [ -d "/proc/$(udhcpc_pid)" ]; then
		echo "1"
		return 0
	else
		echo "0"
		return -1
	fi
}


udhcpc_renew()
{
	#SIGUSR1 = 10
	(kill -SIGUSR1 $(udhcpc_pid) || kill -10 $(udhcpc_pid)) 2>/dev/null
}


udhcpc_release()
{
	#SIGUSR1 = 12
	(kill -SIGUSR2 $(udhcpc_pid) || kill -12 $(udhcpc_pid)) 2>/dev/null
}
