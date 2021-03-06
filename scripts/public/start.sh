#!/bin/bash

# ensure run
# this script checks, that RecordingMonitor is running
# if no - run it
#
# Intended to use with cron
#

APP_ROOT=/home/redhen/recordingmonitor
APP_EXE=$APP_ROOT/recordingmonitor/recordingmonitor
APP_ENV_PATH=/home/redhen/software:$PATH

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# IMPORTANT LOCAL VARIABLES
_monitor_api_root="http://0.0.0.0:5000"
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# other local variables
_monitor_api_ping="$_monitor_api_root/api/v0/about/ping"


function ping_monitor
{
	_resp=`curl --silent --fail --show-error "$_monitor_api_ping"`
	_rc=$?;
	if [[ $_rc != 0 ]]; then
		echo "curl error: $_rc"
		return 2;
	fi

	if [[ $_resp == *"\"data\""* ]]; then
		echo "SERVICE ONLINE";
		return 0;
	else
		echo "SERVICE OFFLINE";
		return 1;
	fi

	return 0;
}

function start_recordingmonitor
{
	export PATH=$APP_ENV_PATH

	cd $APP_ROOT
	# exec $APP_EXE >> /dev/null 2>&1 &
	exec $APP_EXE &
}

function ensure_online
{
	ping_monitor
	_offline=$?;

	if [[ $_offline != 0 ]]; then
		echo "APP IS DEAD, restarting"

		start_recordingmonitor
	fi
}

ensure_online
