#!/bin/sh
set -e

### BEGIN INIT INFO
# Provides:           docker-services
# Required-Start:     $syslog $remote_fs
# Required-Stop:      $syslog $remote_fs
# Should-Start:       docker
# Should-Stop:        docker
# Default-Start:      2 3 4 5
# Default-Stop:       0 1 6
# Short-Description:  Automatically start/stop docker services
# Description:
#  Docker is an open-source project to easily create lightweight, portable,
#  self-sufficient containers from any application. This will start/stop the
#  docker services as needed.
### END INIT INFO

# https://wiki.debian.org/LSBInitScripts/DependencyBasedBoot
# https://unix.stackexchange.com/a/48974/483304
# To install, copy to "/etc/init.d/" and run "update-rc.d docker-services defaults"
# Use with "service docker-services {start|stop|restart|status}"

export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

BASE=docker-services

LOGFILE=/var/log/$BASE.log
DESC="Docker Services"

# Get lsb functions
. /lib/lsb/init-functions

if [ -f /etc/default/$BASE ]; then
    # shellcheck source=/etc/default/docker-services
    . /etc/default/$BASE
fi

fail_unless_root() {
    if [ "$(id -u)" != '0' ]; then
        log_failure_msg "$DESC must be run as root"
        exit 1
    fi
}

case "$1" in
    start)
        fail_unless_root
        touch "$LOGFILE"
        log_begin_msg "Starting $DESC: $BASE"
        docker-services-start >> "$LOGFILE" 2>&1
        log_end_msg $?
        ;;

    stop)
        log_begin_msg "Stopping $DESC: $BASE"
        docker-services-stop >> "$LOGFILE" 2>&1
        log_end_msg $?
        ;;

    restart)
        fail_unless_root
        $0 stop
        $0 start
        ;;

    force-reload)
        fail_unless_root
        $0 restart
        ;;

    status)
        ;;

    *)
        echo "Usage: service docker-services {start|stop|restart|status}"
        exit 1
        ;;
esac
