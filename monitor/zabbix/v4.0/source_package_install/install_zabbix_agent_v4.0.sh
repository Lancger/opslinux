#!/bin/bash

#安装zabbix4.0_agent脚本

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

function install_zabbix(){

    info_echo "开始安装zabbix-${zabbix_server_version}-agent"
    groupadd zabbix &&  useradd -g zabbix zabbix
    sleep 2s
    yum install OpenIPMI-devel libevent-devel net-snmp-devel -y
    cd /usr/local/src/ && tar xvf zabbix-${zabbix_server_version}.tar.gz
    cd /usr/local/src/zabbix-${zabbix_server_version}
    ./configure \
    --prefix=/usr/local/zabbix \
    --sysconfdir=/etc/zabbix/ \
    --enable-agent
    check_exit "configure zabbix-${zabbix_server_version}-agent失败"
    make && make install
    check_exit "make zabbix-${zabbix_server_version}-agent失败"
    info_echo "开始配置zabbix-${zabbix_server_version}-agent"
    cp /usr/local/src/zabbix-${zabbix_server_version}/misc/init.d/fedora/core5/zabbix_agentd /etc/init.d/
    sed -i "s#/usr/local/sbin/zabbix_agentd#/usr/local/zabbix/sbin/zabbix_agentd#g" /etc/init.d/zabbix_agentd
    touch /var/log/zabbix_agentd.log
    chown zabbix:zabbix /var/log/zabbix_agentd.log

cat <<"EOF" > /etc/zabbix/zabbix_agentd.conf
PidFile=/tmp/zabbix_agentd.pid
LogFile=/var/log/zabbix_agentd.log
LogFileSize=0
DebugLevel=2
Server=192.168.56.12
ServerActive=192.168.56.12
Timeout=30
EnableRemoteCommands=1
UnsafeUserParameters=1
HostnameItem=system.run[echo $(hostname)]
HostMetadataItem=system.uname
Include=/etc/zabbix/zabbix_agentd.conf.d/*.conf
EOF

    chmod +x /etc/init.d/zabbix_agentd
    /etc/init.d/zabbix_agentd restart
    STAT=`echo $?`
    PORT=`netstat -lntup|grep zabbix_agentd|wc -l`
    if [ $STAT -eq 0 ] && [ $PORT -eq 1 ];then
        info_echo "zabbix_agentd启动成功"
    else
        err_echo "zabbix_agentd,请检查"
    fi
}

function main(){

    init_servers
    install_package
    download_install_package
    install_zabbix
    
}

main
