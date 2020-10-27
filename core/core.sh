#!/bin/bash

function d_start ()
{
	echo "Les Sagas MP3 Core: starting service"
	BASEDIR=$(dirname "$0")
	cd "$BASEDIR" &&
	nohup java -Dconfig.location=application.properties -jar core.jar & echo $! > /var/run/les-sagas-mp3-core.pid & sleep 5
}

function d_stop ()
{
	echo "Les Sagas MP3 Core: stopping service"
	cat /var/run/les-sagas-mp3-core.pid | xargs kill -9
 }

function d_status ( )
{
	ps -ef | grep node | grep -v grep
}

case "$1" in
	start)
		d_start
		;;
	stop)
		d_stop
		;;
	reload)
		d_stop
		sleep 2
		d_start
		;;
	status)
		d_status
		;;
	* )
	echo "Usage: $0 {start | stop | reload | status}"
	exit 1
	;;
esac

exit 0