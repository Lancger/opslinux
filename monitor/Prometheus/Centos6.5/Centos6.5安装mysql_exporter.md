# 一、安装
```
yum install -y daemonize
chattr -i /etc/passwd* && chattr -i /etc/group* && chattr -i /etc/shadow*
groupadd prometheus
useradd -g prometheus prometheus -s /sbin/nologin -c "prometheus Daemons"
chattr +i /etc/passwd* && chattr +i /etc/group* && chattr +i /etc/shadow*
mkdir -p /usr/local/prometheus/mysqld_exporter/
cd /usr/local/src/
wget -O /usr/local/src/mysqld_exporter-0.11.0.linux-amd64.tar.gz https://github.com/prometheus/mysqld_exporter/releases/download/v0.11.0/mysqld_exporter-0.11.0.linux-amd64.tar.gz
tar -xvf mysqld_exporter-0.11.0.linux-amd64.tar.gz
mv -f mysqld_exporter-0.11.0.linux-amd64/* /usr/local/prometheus/mysqld_exporter/
chown -R prometheus:prometheus /usr/local/prometheus/
mkdir -p /var/run/prometheus/
mkdir -p /var/log/prometheus/
chown prometheus:prometheus /var/run/prometheus/
chown prometheus:prometheus /var/log/prometheus/
touch /var/log/prometheus/mysqld_exporter.log
chmod 777 /var/log/prometheus/mysqld_exporter.log
chown prometheus:prometheus /var/log/prometheus/mysqld_exporter.log
touch /etc/sysconfig/mysqld_exporter.conf
cat > /etc/sysconfig/mysqld_exporter.conf <<\EOF
ARGS="--config.my-cnf=/usr/local/prometheus/mysqld_exporter/my.cnf"
EOF
chmod +x /etc/init.d/mysqld_exporter
cat << EOF > /usr/local/prometheus/mysqld_exporter/my.cnf
[client]
user=exporter
password=exporter
EOF
/etc/init.d/mysqld_exporter start
chkconfig mysqld_exporter on
tail -100f /var/log/prometheus/mysqld_exporter.log
```

# 二、启动脚本
```
cat > /etc/init.d/mysqld_exporter <<\EOF
#!/bin/bash
#
# /etc/rc.d/init.d/mysqld_exporter
#
# chkconfig: 2345 80 80
#
# config: /etc/prometheus/mysqld_exporter.conf
# pidfile: /var/run/prometheus/mysqld_exporter.pid

# Source function library.
. /etc/init.d/functions

RETVAL=0
PROG="mysqld_exporter"
DAEMON_SYSCONFIG=/etc/sysconfig/${PROG}.conf
DAEMON=/usr/local/prometheus/mysqld_exporter/${PROG}
PID_FILE=/var/run/prometheus/${PROG}.pid
LOCK_FILE=/var/lock/subsys/${PROG}
LOG_FILE=/var/log/prometheus/mysqld_exporter.log
DAEMON_USER="prometheus"
GOMAXPROCS=$(grep -c ^processor /proc/cpuinfo)

. ${DAEMON_SYSCONFIG}

start() {
  if check_status > /dev/null; then
    echo "mysqld_exporter is already running"
    exit 0
  fi

  echo -n $"Starting mysqld_exporter: "
  daemonize -u ${DAEMON_USER} -p ${PID_FILE} -l ${LOCK_FILE} -a -e ${LOG_FILE} -o ${LOG_FILE} ${DAEMON} ${ARGS} && success || failure

  RETVAL=$?
  echo ""
  return $RETVAL
}

stop() {
    echo -n $"Stopping mysqld_exporter: "
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
EOF
```

# 三、设置开机启动
```
chmod +x /etc/init.d/mysqld_exporter

chkconfig mysqld_exporter on
```
参考文档：

https://www.veryarm.com/19670.html  
