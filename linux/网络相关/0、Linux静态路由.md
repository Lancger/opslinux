# 一、linux下增加和删除路由

```
root># route add -net 10.22.0.0/16 gw 10.120.64.91   命令行增加

配置文件中添加  就不会重启之后 丢失路由
root># vim /etc/sysconfig/static-routes
any net 10.22.0.0/16 gw 10.120.64.91
any net 10.0.0.0/8 gw 10.118.166.1 dev eth0

添加路由
route add -net 192.168.20.0 netmask 255.255.255.0 gw 192.168.10.1

查看路由状态
route -n

删除路由
route del -net 192.168.20.0 netmask 255.255.255.0
```

# 二、windows 下增加路由

```
查看路由
C:\Users\Administrator>route print|more

增加路由
route -p add 10.30.98.0 mask 255.255.255.0 192.168.80.82

删除路由（只需要接目的地址即可）
route delete 10.30.98.0
```

# 三、查看路由信息

```
1、# 查看默认路由

[root@node1 ~]# route -n
 
[root@node1 ~]# netstat -nr
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
123.110.215.0   0.0.0.0         255.255.255.0   U     0      0        0 eth1
10.13.99.0      0.0.0.0         255.255.255.0   U     0      0        0 eth0
143.35.134.0    0.0.0.0         255.255.255.0   U     0      0        0 eth1
170.101.140.0   0.0.0.0         255.255.255.0   U     0      0        0 eth1
179.254.0.0     0.0.0.0         255.255.0.0     U     1002   0        0 eth0
10.0.0.0        10.13.99.254    255.0.0.0       UG    0      0        0 eth0
0.0.0.0         170.101.140.1   0.0.0.0         UG    0      0        0 eth1

2、查看全部路由

ip route list

ip r

ip ru ls         (不同网络运营商的IP地址段规划)

32766:  from all lookup main 
32767:  from all lookup default 
20001:  from all to 19.97.179.128/26 lookup mob  --移动
10000:  from 23.111.215.0/24 lookup mob  
20001:  from all to 27.45.96.0/22 lookup cnc --电信
20001:  from all to 27.219.18.0/22 lookup cnc 
10000:  from 10.11.141.0/24 lookup tel  --联通

这些路由规则，只有在3线机器主动去请求外面的地址的时候才会去匹配起作用（例如，请求联通的地址，那么匹配到走联通网关出去）
```
