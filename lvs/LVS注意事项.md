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
1、DR模式
a、keepalived配置转发的端口要和后端端口保持一致，因为DR模式只会改写mac，不会改其他的信息
b、后端real_server上VIP地址必须绑定在环回口，并且设置参数，开启ARP欺骗
c、如果是使用公网地址做VIP,那么后端real_server的服务器的公网IP,需要跟VIP的公网地址在同一个VLAN,内网地址只要2层能通就行(arping -I bond0 10.198.2.43)
d、防火墙要放开vrrp协议，不然会脑裂

```

参考文档：

https://www.jianshu.com/p/e146a7a14b4b lvs+keepalived群集配置

https://www.centos.bz/2017/07/lvs-keepalived-ha-loadbalace/  LVS Keepalived双机高可用负载均衡搭建

https://blog.csdn.net/u013694670/article/details/60580175   记一次keepalived脑裂问题查找
