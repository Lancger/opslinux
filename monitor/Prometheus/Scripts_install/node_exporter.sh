#!/bin/bash
#
# /etc/rc.d/init.d/node_exporter
#
# chkconfig: 2345 80 80
#
# config: /etc/sysconfig/node_exporter.conf
# pidfile: /var/run/node_exporter.pid

# Source function library.
. /etc/init.d/functions

RETVAL=0
PROG="node_exporter"
DAEMON_SYSCONFIG=/etc/sysconfig/${PROG}.conf
DAEMON=/usr/local/prometheus/node_exporter/${PROG}
PID_FILE=/var/run/${PROG}.pid
LOCK_FILE=/var/lock/subsys/${PROG}
LOG_FILE=/var/log/node_exporter.log
DAEMON_USER="prometheus"
GOMAXPROCS=$(grep -c ^processor /proc/cpuinfo)

. ${DAEMON_SYSCONFIG}

start() {
  if check_status > /dev/null; then
    echo "node_exporter is already running"
    exit 0
  fi

  echo -n $"Starting node_exporter: "
  daemonize -u ${DAEMON_USER} -p ${PID_FILE} -l ${LOCK_FILE} -a -e ${LOG_FILE} -o ${LOG_FILE} ${DAEMON} ${ARGS} && success || failure

  RETVAL=$?
  echo ""
  return $RETVAL
}

stop() {
    echo -n $"Stopping node_exporter: "
    killproc -p ${PID_FILE} -d 10 ${DAEMON}
    RETVAL=$?
    echo
    [ $RETVAL = 0 ] && rm -f ${LOCK_FILE} ${PID_FILE}
    return $RETVAL
}

check_status() {
    status -p ${PID_FILE} ${DAEMON}
    RETVAL=$?
    return $RETVAL
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
    check_status
        ;;
    reload|force-reload)
        reload
        ;;
    restart)
        stop
        start
        ;;
    *)
        N=/etc/init.d/${NAME}
        echo "Usage: $N {start|stop|status|restart|force-reload}" >&2
        RETVAL=2
        ;;
esac

exit ${RETVAL}
