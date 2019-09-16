#!/bin/bash
#Date: 2019-05-07
#Author: Bryan
#Mai: 1151980610@qq.com
#Function:  This script is used for system Centos6 or Centos7 install  node_exporter
#Version:  V1.0
#Update:  2019-05-07
. /etc/init.d/functions

if [[ "$(whoami)" != "root" ]]; then
    echo "please run this script as root ." >&2
    exit 1
fi

echo -e "\033[31m 这个是centos6/7系统安装 node_exporter 服务程序，Please continue to enter or ctrl+C to cancel \033[0m"
sleep 1

# get kernel version
RELEASEVER=$(rpm -q --qf "%{VERSION}" $(rpm -q --whatprovides redhat-release))


#configure 
config(){
	yum install -y daemonize
	chattr -i /etc/passwd* && chattr -i /etc/group* && chattr -i /etc/shadow* && chattr -i /etc/gshadow*
	groupadd prometheus
	useradd -g prometheus prometheus -s /sbin/nologin -c "prometheus Daemons"
	chattr +i /etc/passwd* && chattr +i /etc/group* && chattr +i /etc/shadow* && chattr -i /etc/gshadow*
	mkdir -pv /usr/local/prometheus/node_exporter/
}

#download
get_soft(){
	if [ -f "/tmp/node_exporter-0.17.0.linux-amd64.tar.gz" ];then
	    echo "安装包已经存在"
	else
	    echo "正在下载安装包...."
	    wget -O /tmp/node_exporter-0.17.0.linux-amd64.tar.gz https://github.com/prometheus/node_exporter/releases/download/v0.17.0/node_exporter-0.17.0.linux-amd64.tar.gz
	fi
	tar -xvf node_exporter-0.17.0.linux-amd64.tar.gz
	mv -f node_exporter-0.17.0.linux-amd64/* /usr/local/prometheus/node_exporter/
}

#change_permission
change_permission(){
	chmod +x /usr/local/prometheus/node_exporter/*
	chown -R prometheus:prometheus /usr/local/prometheus/
	mkdir -p /var/run/
	mkdir -p /var/log/
	touch /var/log/node_exporter.log
	chmod 777 /var/log/node_exporter.log
	chown prometheus:prometheus /var/log/node_exporter.log
	touch /etc/sysconfig/node_exporter.conf
}

#node_exporter.conf
node_config(){
	if [ $RELEASEVER == 6 ];then
		echo "Centos6 node_exporter服务 配置"
		echo 'ARGS=""' > /etc/sysconfig/node_exporter.conf
		cp node_exporter.sh /etc/init.d/node_exporter
		chmod +x /etc/init.d/node_exporter
		/etc/init.d/node_exporter start
		chkconfig node_exporter on
	fi
    if [ $RELEASEVER == 7 ];then
        echo "Centos7 node_exporter服务 配置"
        cp node_exporter.service.sh /usr/lib/systemd/system/node_exporter.service
        chmod +x /usr/lib/systemd/system/node_exporter.service
        systemctl daemon-reload
		systemctl enable node_exporter.service
		systemctl restart node_exporter.service
    fi
}

iptables_check(){
    echo "node_exporter 防火墙配置"
    echo "正在保存防火墙配置"
    cp /etc/sysconfig/iptables /etc/sysconfig/iptables.bak_$(date +%F-%H-%M-%S)
    service iptables save
    echo "检查是否开通了123.160.28.213/32的9100-9200策略"
    res=`iptables -S|grep 13.160.28.213|grep 9100`
    if [ "$res" = "" ]; then 
        echo "规则不存在"
        iptables -I RH-Firewall-1-INPUT -s 13.160.28.213/32 -p tcp -m tcp -m multiport --dports 9100:9200 -j ACCEPT
	service iptables save
    else
    	echo "规则已经存在"
    fi
}

crontab_config(){
    echo "node_exporter 定时任务配置"
    chattr -i /var/spool/cron/root
    res=`crontab -l|grep node_exporter`
    if [ "$res" = "" ]; then
    	echo "node_exporter定时任务不存在"
    	if [ $RELEASEVER == 6 ];then
	    	echo "#node_exporter service monitor" >> /var/spool/cron/root
	        echo "0 23 * * * /etc/init.d/node_exporter restart >/dev/null 2>&1" >> /var/spool/cron/root
	    fi
	    if [ $RELEASEVER == 7 ];then
	    	echo "#node_exporter service monitor" >> /var/spool/cron/root
	        echo "0 23 * * * systemctl restart node_exporter.service >/dev/null 2>&1" >> /var/spool/cron/root
	    fi
    fi
    chattr +i /var/spool/cron/root
}

main(){
	config
	get_soft
	change_permission
	node_config
	iptables_check
	crontab_config
}
main
