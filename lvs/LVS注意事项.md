# 一、防火墙
```
查看防火墙配置
root@localhost ~]# iptables -S
-P INPUT ACCEPT
-P FORWARD ACCEPT
-P OUTPUT ACCEPT
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 
-A INPUT -p icmp -j ACCEPT 
-A INPUT -i lo -j ACCEPT 
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT 
-A INPUT -j REJECT --reject-with icmp-host-prohibited 
-A FORWARD -j REJECT --reject-with icmp-host-prohibited


发现系统不接收VRRP协议，于是修改iptables 
iptables -I INPUT 4 -p vrrp -j ACCEPT

-A INPUT -p vrrp -j ACCEPT

-A RH-Firewall-1-INPUT -p vrrp -j ACCEPT 

```
# 二、注意事项
```
1、DR模式，real_server收到包后，直接通过real_server直接响应client请求，不再经过LVS-DR
a、keepalived配置转发的端口要和后端端口保持一致，因为DR模式只会改写mac，不会改其他的信息
b、后端real_server上VIP地址必须绑定在环回口，并且设置参数，开启ARP欺骗并关闭源地址校验
c、如果是使用公网地址做VIP,那么后端real_server的服务器的公网IP,需要跟VIP的公网地址在同一个VLAN,内网地址只要2层能通就行(arping -I bond0 10.198.2.43)
d、防火墙要放开vrrp协议，不然会脑裂
e、注意如果是多线机房，不同线路打了不同的vlan-tag，那么keepalived配置vip的时候，需要注意一定要指定不同的网口去发送arp请求，不然交换机不能刷新mac地址，会造成vip切换网络不通
f、注意keepalived的配置文件权限，不然会报is not a regular non-executable file - skipping错误，配置文件不生效，调整权限

chmod 644 /etc/keepalived/keepalived.conf
cd /etc/keepalived/virtual_server/
chmod 644 *

g、内核开启IP转发和允许非本地IP绑定功能，如果是使用LVS的DR模式还需设置两个arp相关的参数

#开启IP转发功能
sysctl -w net.ipv4.ip_forward=1

#开启允许绑定非本机的IP
sysctl -w net.ipv4.ip_nonlocal_bind = 1

https://blog.csdn.net/li66934791/article/details/85248357

h、后端服务启动成功了，访问vip，抓包后端不响应
tcpdump -i any -n host 28.17.161.129  #抓取办公区访问的包

15:39:27.919950 IP 28.117.161.129.53761 > 16.21.206.159.http: Flags [S], seq 781213085, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 130630673 ecr 0,sackOK,eol], length 0
15:39:27.921157 ethertype IPv4, IP 28.117.161.129.53760 > 16.21.206.159.http: Flags [S], seq 1817390795, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 130630673 ecr 0,sackOK,eol], length 0
15:39:27.921159 ethertype IPv4, IP 28.117.161.129.53760 > 16.21.206.159.http: Flags [S], seq 1817390795, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 130630673 ecr 0,sackOK,eol], length 0
15:39:27.921159 IP 28.117.161.129.53760 > 16.21.206.159.http: Flags [S], seq 1817390795, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 130630673 ecr 0,sackOK,eol], length 0
15:39:27.921750 IP 28.117.161.129.53760 > 16.21.206.159.http: Flags [S], seq 1817390795, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 130630673 ecr 0,sackOK,eol], length 0
15:39:27.921752 IP 28.117.161.129.53760 > 16.21.206.159.http: Flags [S], seq 1817390795, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 130630673 ecr 0,sackOK,eol], length 0
15:39:28.171940 ethertype IPv4, IP 28.117.161.129.53762 > 16.21.206.159.http: Flags [S], seq 2548617820, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 130630923 ecr 0,sackOK,eol], length 0
15:39:28.171942 ethertype IPv4, IP 28.117.161.129.53762 > 16.21.206.159.http: Flags [S], seq 2548617820, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 130630923 ecr 0,sackOK,eol], length 0
15:39:28.171943 IP 28.117.161.129.53762 > 16.21.206.159.http: Flags [S], seq 2548617820, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 130630923 ecr 0,sackOK,eol], length 0
15:39:28.172538 IP 28.117.161.129.53762 > 16.21.206.159.http: Flags [S], seq 2548617820, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 130630923 ecr 0,sackOK,eol], length 0
15:39:28.172540 IP 28.117.161.129.53762 > 16.21.206.159.http: Flags [S], seq 2548617820, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 130630923 ecr 0,sackOK,eol], length 0

从上面的抓包看到，后端没有响应，是因为后端服务也是多线路的，需要刷对对应线路的回包路由策略，电信走电信路由，联通走联通路由，移动走移动路由


可以通过arping观察下切换的时候mac地址的变换
(arping -I bond0 10.198.2.43)

i、内核参数添加不开启源地址校验（https://www.jianshu.com/p/717e6cd9d2bb）
vim /etc/sysctl.conf
net.ipv4.ip_forward=1
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0

或者
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv4.conf.all.rp_filter=0
sysctl -w net.ipv4.conf.default.rp_filter=0

检查
sysctl -a | grep rp_filter
```

参考文档：
https://www.jianshu.com/p/717e6cd9d2bb  Linux内核参数之rp_filter

https://www.jianshu.com/p/88589646aae8  LVS+Keepalived+Nginx实现HA

https://www.jianshu.com/p/e146a7a14b4b lvs+keepalived群集配置

https://www.centos.bz/2017/07/lvs-keepalived-ha-loadbalace/  LVS Keepalived双机高可用负载均衡搭建

https://blog.csdn.net/u013694670/article/details/60580175   记一次keepalived脑裂问题查找

https://bugzilla.redhat.com/show_bug.cgi?id=1047693   lvs vip运行半年时好时坏的bug问题
