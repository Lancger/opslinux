# 一、安装zabbix_server

```
cd /tmp && wget -O /tmp/install_zabbix_server_v4.0.sh https://raw.githubusercontent.com/Lancger/opslinux/master/monitor/zabbix/v4.0/%E6%BA%90%E7%A0%81%E5%AE%89%E8%A3%85/install_zabbix_server_v4.0.sh && chmod +x /tmp/install_zabbix_server_v4.0.sh && sh /tmp/install_zabbix_server_v4.0.sh
```

# 二、安装zabbix_proxy
```
cd /tmp && wget -O /tmp/install_zabbix_proxy_v4.0.sh https://raw.githubusercontent.com/Lancger/opslinux/master/monitor/zabbix/v4.0/%E6%BA%90%E7%A0%81%E5%AE%89%E8%A3%85/install_zabbix_proxy_v4.0.sh && chmod +x /tmp/install_zabbix_proxy_v4.0.sh && sh /tmp/install_zabbix_proxy_v4.0.sh

*特别提醒注意的一点是，新版的mysql数据库下的user表中已经没有Password字段了

而是将加密后的用户密码存储于authentication_string字段

skip-grant-tables

alter user 'root'@'localhost' identified by '123456';

SET PASSWORD = PASSWORD('123456');
```

```
cat > /usr/lib/systemd/system/zabbix_proxy.service << \EOF
[Unit]
Description=Zabbix Proxy
After=syslog.target
After=network.target

[Service]
User=zabbix
Group=zabbix
Environment="CONFFILE=/usr/local/zabbix_proxy/etc/zabbix_proxy.conf"
Type=forking
Restart=on-failure
PIDFile=/tmp/zabbix_proxy.pid
KillMode=control-group
ExecStart=/usr/local/zabbix_proxy/sbin/zabbix_proxy -c $CONFFILE
ExecStop=/bin/kill -SIGTERM $MAINPID
RestartSec=10s
TimeoutSec=0

[Install]
WantedBy=multi-user.target
EOF
systemctl restart zabbix_proxy
systemctl enable zabbix_proxy
```

# 三、安装zabbix_agent
```
cd /tmp && wget -O /tmp/install_zabbix_agent_v4.0.sh https://raw.githubusercontent.com/Lancger/opslinux/master/monitor/zabbix/v4.0/%E6%BA%90%E7%A0%81%E5%AE%89%E8%A3%85/install_zabbix_agent_v4.0.sh && chmod +x /tmp/install_zabbix_agent_v4.0.sh && sh /tmp/install_zabbix_agent_v4.0.sh


#一步一步安装

zabbix_server_version="4.2.1"
yum install -y OpenIPMI-devel libevent-devel net-snmp-devel psmisc gcc pcre*
rm -rf /var/spool/mail/zabbix
groupadd zabbix && useradd -M -g zabbix -s /sbin/nologin zabbix
cd /usr/local/src/
wget https://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/${zabbix_server_version}/zabbix-${zabbix_server_version}.tar.gz
tar -zxvf zabbix-${zabbix_server_version}.tar.gz
cd zabbix-${zabbix_server_version}
./configure \
--prefix=/opt/zabbix \
--sysconfdir=/opt/zabbix/etc/ \
--enable-agent
make -j 4 && make install

mkdir -p /opt/zabbix/var/run/log/
mkdir -p /opt/zabbix/var/run/tmp/
mkdir -p /opt/zabbix/var/run/lock/subsys/
mkdir -p /opt/zabbix/init/
touch /opt/zabbix/var/run/log/zabbix_agentd.log
touch /opt/zabbix/var/run/tmp/netstat.tmp


cat > /opt/zabbix/init/zabbix_agentd << \EOF
#!/bin/bash
#
#       /etc/rc.d/init.d/zabbix_agentd
#
# Starts the zabbix_agentd daemon
#
# chkconfig: - 95 5
# description: Zabbix Monitoring Agent
# processname: zabbix_agentd
# pidfile: /tmp/zabbix_agentd.pid

# Modified for Zabbix 2.0.0
# May 2012, Zabbix SIA

# Source function library.

. /etc/init.d/functions

RETVAL=0
prog="Zabbix Agent"
conf="/opt/zabbix/etc/zabbix_agentd.conf"
ZABBIX_BIN="/opt/zabbix/sbin/zabbix_agentd"
lockfile="/opt/zabbix/var/run/lock/subsys/zabbix_agentd"

if [ ! -x ${ZABBIX_BIN} ] ; then
        echo -n "${ZABBIX_BIN} not installed! "
        # Tell the user this has skipped
        exit 5
fi

start() {
        echo -n $"Starting $prog: "
        daemon --user=zabbix $ZABBIX_BIN -c $conf
        RETVAL=$?
        [ $RETVAL -eq 0 ] && touch $lockfile
        echo
}

stop() {
        echo -n $"Stopping $prog: "
        killproc $ZABBIX_BIN
        RETVAL=$?
        [ $RETVAL -eq 0 ] && rm -f $lockfile
        echo
}

case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  reload|restart)
        stop
        sleep 10
        start
        RETVAL=$?
        ;;
  condrestart)
        if [ -f $lockfile ]; then
            stop
            start
        fi
        ;;
  status)
        status $ZABBIX_BIN
        RETVAL=$?
        ;;
  *)
        echo $"Usage: $0 {condrestart|start|stop|restart|reload|status}"
        exit 1
esac

exit $RETVAL
EOF

chmod +x /opt/zabbix/init/zabbix_agentd

cat > /opt/zabbix/etc/zabbix_agentd.conf << \EOF
PidFile=/opt/zabbix/var/run/zabbix_agentd.pid
LogFile=/opt/zabbix/var/run/log/zabbix_agentd.log
LogFileSize=0
DebugLevel=4
Server=192.168.56.12
ServerActive=192.168.56.12
Timeout=30
EnableRemoteCommands=1
UnsafeUserParameters=1
HostnameItem=system.run[echo $(hostname)]
HostMetadataItem=system.uname
Include=/opt/zabbix/etc/zabbix_agentd.conf.d/*.conf
EOF

cat > /opt/zabbix/init/check_zabbix_agentd.sh << \EOF
#!/bin/bash
ps -ef | grep -v grep | grep '/opt/zabbix/sbin/zabbix_agentd -c /opt/zabbix/etc/zabbix_agentd.conf' > /dev/null 2>&1

check_ps_zabbix_agent=$?

#确定zabbix_agentd是否存在，若返回0，zabbix_agentd正常，若返回1,则zabbix_agentd服务已停止
killall -0 /opt/zabbix/sbin/zabbix_agentd

check_respond=$?

if [ ${check_ps_zabbix_agent} -ne 0 -o ${check_respond} -ne 0 ]
then
    killall -9 /opt/zabbix/sbin/zabbix_agentd
    /opt/zabbix/init/zabbix_agentd restart
fi
EOF

chmod +x /opt/zabbix/init/check_zabbix_agentd.sh
chown -R zabbix:zabbix /opt/zabbix/

crontab_tmp="/tmp/crontab_tmp"
crontab -l | grep -v "zabbix" | grep -v "# check zabbix_agentd" > $crontab_tmp
newcron="*/5 * * * * /bin/bash /opt/zabbix/init/check_zabbix_agentd.sh >/dev/null 2>&1"
echo "# check zabbix_agentd" >> $crontab_tmp
echo "$newcron" >> $crontab_tmp
chattr -i /var/spool/cron/root 
crontab $crontab_tmp
chattr +i /var/spool/cron/root

/opt/zabbix/init/zabbix_agentd restart
tail -100f /opt/zabbix/var/run/log/zabbix_agentd.log
```

参考资料：

https://www.cnblogs.com/biaopei/p/9877747.html zabbix4.0离线快速编译安装（编译安装方法）

https://www.cnblogs.com/uglyliu/p/10143914.html Centos7一键编译安装zabbix-4.0.2
