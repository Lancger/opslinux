# 一、管理工具安装
```bash
yum install -y gcc make openssl openssl-devel httpd
yum install -y keepalived
yum install -y ipvsadm

systemctl start keepalived
systemctl enable keepalived
systemctl status keepalived
```

# 二、Real_server.sh脚本

注意是在 Real_server 机器需要执行这操作，绑定在 lo 环回口

```bash
#1、lvs_realserver服务脚本
cat >/usr/local/bin/lvs_realserver.sh<< \EOF
#!/bin/sh
# chkconfig: 34 87 13
# description: Config realserver lo:100 port and apply arp patch
 
VIP1=10.xx.xx.xx #电信
VIP2=61.xx.xx.xx #联通
VIP3=11.xx.xx.xx #移动
 
. /etc/rc.d/init.d/functions
 
case "$1" in
    start)
        # Start LVS-DR real server on this machine.
        echo "lo:100 port starting"
        echo "lo:101 port starting"
        echo "lo:102 port starting"
 
        ifconfig lo:100 $VIP1 netmask 255.255.255.255 broadcast $VIP1 up
        ifconfig lo:101 $VIP2 netmask 255.255.255.255 broadcast $VIP2 up
        ifconfig lo:102 $VIP3 netmask 255.255.255.255 broadcast $VIP3 up
        
        /sbin/route add -host $VIP1 dev lo:100
        /sbin/route add -host $VIP2 dev lo:101
        /sbin/route add -host $VIP3 dev lo:102
        
        echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
        echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
        echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
        echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce
        ;;
    stop)
        # Stop LVS-DR real server loopback device(s).
        echo "lo:100 port closing"
        echo "lo:101 port closing"
        echo "lo:102 port closing"
 
        ifconfig lo:100 down
        ifconfig lo:101 down
        ifconfig lo:102 down
        
        echo 0 > /proc/sys/net/ipv4/conf/lo/arp_ignore
        echo 0 > /proc/sys/net/ipv4/conf/lo/arp_announce
        echo 0 > /proc/sys/net/ipv4/conf/all/arp_ignore
        echo 0 > /proc/sys/net/ipv4/conf/all/arp_announce
        ;;
    status)
        # Status of LVS-DR real server.
        islothere=`/sbin/ifconfig lo:100 | grep $VIP1`
        isrothere=`netstat -rn | grep "lo:100" | grep $VIP1`
        if [ ! "$islothere" -o ! "isrothere" ];then
            # Either the route or the lo:253 device not found.
            echo "LVS-DR real server Stopped."
        else
            echo "LVS-DR real server Running."
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
esac
EOF

#在realserver机器上面执行脚本绑定vip到lo口
chmod +x /usr/local/bin/lvs_realserver.sh
sh /usr/local/bin/lvs_realserver.sh stop
sh /usr/local/bin/lvs_realserver.sh start


#2、monitor_lvs_realserver监控保活脚本
cat > /usr/local/bin/monitor_lvs_realserver.sh <<\EOF
#!/bin/bash
# function: automatic pull up process
# auth: Lancger
# version: 1.0
# date: 2019-10-25

export PATH=$PATH:'/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
cd `dirname $0`

VIP1=10.xx.xx.xx #电信
VIP2=61.xx.xx.xx #联通
VIP3=11.xx.xx.xx #移动

server_tag='lvs_dr_realserver'
script_name="monitor_lvs_realserver.sh"

log=/tmp/${server_tag}_run.log
datetime=`date +'%Y%m%d %H:%M:%S'`

function check_all()
{

    num=`/sbin/ifconfig  |grep -iE "${VIP1}|${VIP2}|${VIP3}" |wc -l`

    if [ $num -lt 2 ];then
        echo "${server_tag} $datetime 服务异常,请检查"
        /usr/local/bin/lvs_realserver.sh stop
        /usr/local/bin/lvs_realserver.sh start
    else
        echo "${server_tag} $datetime 服务正常。"
    fi
}
check_all>>$log
EOF
chmod +x /usr/local/bin/monitor_lvs_realserver.sh


#3、设置lvs_realserver定时任务
crontab_tmp="/tmp/crontab_tmp"
crontab -l | grep -v "lvs_realserver" | grep -v "# monitor lvs_realserver service" > $crontab_tmp
newcron="*/1 * * * * /bin/bash /usr/local/bin/monitor_lvs_realserver.sh >/dev/null 2>&1"
echo "# monitor lvs_realserver service" >> $crontab_tmp
echo "$newcron" >> $crontab_tmp
chattr -i /var/spool/cron/root 
crontab $crontab_tmp
chattr +i /var/spool/cron/root
```
