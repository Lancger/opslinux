#!/bin/bash

#安装zabbix4.0_proxy脚本

err_echo(){
    echo -e "\033[41;37m[Error]: $1 \033[0m"
    exit 1
}

info_echo(){
    echo -e "\033[42;37m[Info]: $1 \033[0m"
}

check_file_is_exists(){
    if [ ! -f "/usr/local/src/$1" ];then
        info_echo "$1开始下载"
    fi
}

check_exit(){
    if [ $? -ne 0 ]; then
        err_echo "$1"
        exit 1
    fi
}

check_success(){
    if [ $? -eq 0 ];then
        info_echo "$1"
    fi
}

zabbix_server_version="4.0.9"

[ $(id -u) != "0" ] && err_echo "please run this script as root user." && exit 1

function init_servers(){

    info_echo "开始初始化服务器"
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    setenforce 0
    systemctl stop firewalld.service
    systemctl disable firewalld.service
    
    info_echo "更换阿里源"
    yum install wget -y
    cp /etc/yum.repos.d/* /tmp
    #rm -f /etc/yum.repos.d/*
    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
    #yum clean all
    #yum makecache

}

function install_package(){

    info_echo "开始安装系统必备依赖包"
    yum install -y ntpdate gcc gcc-c++ wget lsof lrzsz mysql-devel curl-devel psmisc

}

function download_install_package(){
    
    if [ ! -f "/usr/local/src/zabbix-${zabbix_server_version}.tar.gz" ];then
        info_echo "开始下载zabbix-${zabbix_server_version}.tar.gz"
        wget -O /usr/local/src/zabbix-${zabbix_server_version}.tar.gz https://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/${zabbix_server_version}/zabbix-${zabbix_server_version}.tar.gz
        check_success "zabbix-${zabbix_server_version}.tar.gz已下载至/usr/local/src目录"
    else
        info_echo "zabbix-${zabbix_server_version}.tar.gz已存在,不需要下载"
    fi

}

function install_mysql(){
     
    info_echo "开始安装mysql"
    sleep 2s

    yum -y remove mysql-libs.x86_64

    wget -i -c http://dev.mysql.com/get/mysql57-community-release-el7-10.noarch.rpm
    yum -y install mysql57-community-release-el7-10.noarch.rpm
    yum -y install mysql-community-server

    check_exit "安装mysql失败"
    systemctl start mysqld.service
    
    STAT=`echo $?`
    PORT=`netstat -lntup|grep mysql|wc -l`
    if [ $STAT -eq 0 ] && [ $PORT -eq 1 ];then
        info_echo "mysql启动成功"
    else
        err_echo "mysql未启动成功,请检查"
    fi
    
    info_echo "开始创建zabbix账号和授权"
    sleep 2s
    mysql -uroot -e "create database zabbix_proxy character set utf8;" 
    mysql -uroot -e "grant all privileges on zabbix_proxy.* to zabbix@localhost identified by 'zabbix';"
    mysql -uroot -e "flush privileges;"
    mysql -uroot -e "show databases;"
    mysql -uroot -e "alter user 'root'@'localhost' identified by '123456';" 

}

function install_zabbix(){

    info_echo "开始安装zabbix-${zabbix_server_version}-proxy"
    groupadd zabbix &&  useradd -g zabbix zabbix
    sleep 2s
    yum install OpenIPMI-devel libevent-devel net-snmp-devel -y
    cd /usr/local/src/ && tar xvf zabbix-${zabbix_server_version}.tar.gz
    cd /usr/local/src/zabbix-${zabbix_server_version}
    ./configure \
    --prefix=/usr/local/zabbix_proxy \
    --enable-proxy --enable-agent \
    --with-mysql --with-net-snmp \
    --with-libcurl 
    check_exit "configure zabbix-${zabbix_server_version}-proxy失败"
    make && make install
    check_exit "make zabbix-${zabbix_server_version}-proxy失败"
    info_echo "开始配置zabbix-${zabbix_server_version}-proxy"
    touch /var/log/zabbix_proxy.log
    chown zabbix:zabbix /var/log/zabbix_proxy.log

cat <<"EOF" > /usr/local/zabbix_proxy/etc/zabbix_proxy.conf
ProxyMode=0
Server=192.168.56.12
ServerPort=10051
Hostname=zabbix_proxy_01
LogFile=/var/log/zabbix_proxy.log
DBHost=localhost
DBName=zabbix_proxy
DBUser=zabbix
DBPassword=Zabbix
ConfigFrequency=600
StartPollers=500
StartTrappers=50
StartPollersUnreachable=20
Timeout=30
CacheSize=2048M
HistoryCacheSize=512M
HistoryIndexCacheSize=512M
LogSlowQueries=3000
ConfigFrequency=60
DataSenderFrequency=60
PidFile=/tmp/zabbix_proxy.pid
EOF

cat <<"EOF" > /etc/init.d/zabbix_proxy
#!/bin/bash
#
#       /etc/rc.d/init.d/zabbix_proxy
#
# Starts the zabbix_proxy daemon
#
# chkconfig: - 95 5
# description: Zabbix Monitoring Proxy
# processname: zabbix_proxy
# pidfile: /tmp/zabbix_proxy.pid

# Modified for Zabbix 2.0.0
# May 2012, Zabbix SIA

# Source function library.

. /etc/init.d/functions

RETVAL=0
prog="Zabbix Proxy"
ZABBIX_BIN="/usr/local/zabbix_proxy/sbin/zabbix_proxy"

if [ ! -x ${ZABBIX_BIN} ] ; then
        echo -n "${ZABBIX_BIN} not installed! "
        # Tell the user this has skipped
        exit 5
fi

start() {
        echo -n $"Starting $prog: "
        daemon $ZABBIX_BIN
        RETVAL=$?
        [ $RETVAL -eq 0 ] && touch /var/lock/subsys/zabbix_proxy
        echo
}

stop() {
        echo -n $"Stopping $prog: "
        killproc $ZABBIX_BIN
        RETVAL=$?
        [ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/zabbix_proxy
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
        if [ -f /var/lock/subsys/zabbix_proxy ]; then
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

    info_echo "开始导入mysql数据"
    mysql -uzabbix -pzabbix zabbix_proxy < /usr/local/src/zabbix-${zabbix_server_version}/database/mysql/schema.sql 

    info_echo "开始启动zabbix_proxy"
    sleep 2s
    chmod +x /etc/init.d/zabbix_proxy
    /etc/init.d/zabbix_proxy restart
    STAT=`echo $?`
    PORT=`netstat -lntup|grep zabbix_proxy|wc -l`
    if [ $STAT -eq 0 ] && [ $PORT -eq 1 ];then
        info_echo "zabbix_proxy启动成功"
    else
        err_echo "zabbix_proxy,请检查"
    fi
}

function main(){

    init_servers
    install_package
    download_install_package
    install_mysql
    install_zabbix
    
}

main
