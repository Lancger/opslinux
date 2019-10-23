# 一、管理工具安装
```bash
yum install -y gcc make openssl openssl-devel httpd
 
yum install keepalived
 
yum -y install ipvsadm
```

# 二、Real_server.sh脚本(注意是在 Real_server 机器需要执行这操作，绑定在 lo 环回口)
```bash
root># cat lvs_realserver.sh
#!/bin/sh
# chkconfig: 34 87 13
# description: Config realserver lo:100 port and apply arp patch
 
VIP1=192.168.56.100
VIP2=192.168.56.101
VIP3=192.168.56.102
 
. /etc/rc.d/init.d/functions
 
case "$1" in
    start)
        # Start LVS-DR real server on this machine.
        echo "lo:100 port starting"
        echo "lo:101 port starting"
        echo "lo:102 port starting"
 
        ifconfig lo:100 $VIP1 netmask 255.255.255.255 broadcast $VIP up
        ifconfig lo:101 $VIP2 netmask 255.255.255.255 broadcast $VIP up
        ifconfig lo:102 $VIP3 netmask 255.255.255.255 broadcast $VIP up

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
        islothere=`/sbin/ifconfig lo:100 | grep $VIP`
        isrothere=`netstat -rn | grep "lo:100" | grep $VIP`

        if [ ! "$islothere" -o ! "isrothere" ];then
            # Either the route or the lo:100 device not found.
            echo "LVS-DR real server Stopped."
        else
            echo "LVS-DR real server Running."
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
esac
```
