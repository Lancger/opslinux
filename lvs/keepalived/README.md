# 一、Keepalived介绍

    keepalived介绍： 是集群管理中保证集群高可用的一个服务软件，其功能类似于heartbeat，用来防止单点故障

    Keepalived作用： 为haproxy提供vip（192.168.2.10）在三个haproxy实例之间提供主备，降低当其中一个haproxy失效的时对服务的影响。
    
## 1、yum安装Keepalived
```bash
# 安装keepalived
yum install -y keepalived
```

## 2、配置Keepalived
```bash
cat <<EOF > /etc/keepalived/keepalived.conf
! Configuration File for keepalived

# 主要是配置故障发生时的通知对象以及机器标识。
global_defs {
   # 标识本节点的字条串，通常为 hostname，但不一定非得是 hostname。故障发生时，邮件通知会用到。
   router_id LVS_K8S
}

# 用来做健康检查的，当时检查失败时会将 vrrp_instance 的 priority 减少相应的值。
vrrp_script check_haproxy {
    script "killall -0 haproxy"   #根据进程名称检测进程是否存活
    interval 3
    weight -2
    fall 10
    rise 2
}

# rp_instance用来定义对外提供服务的 VIP 区域及其相关属性。
vrrp_instance VI_1 {
    state MASTER   #当前节点为MASTER，其他两个节点设置为BACKUP
    interface eth0 #改为自己的网卡
    virtual_router_id 51
    priority 200
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 35f18af7190d51c9f7f78f37300a0cbd
    }
    virtual_ipaddress {
        192.168.2.10   #虚拟ip，即VIP
    }
    track_script {
        check_haproxy
    }
}
EOF
```
当前节点的配置中 state 配置为 MASTER，其它两个节点设置为 BACKUP
```
配置说明：

    virtual_ipaddress： vip

    track_script： 执行上面定义好的检测的script

    interface： 节点固有IP（非VIP）的网卡，用来发VRRP包。

    virtual_router_id： 取值在0-255之间，用来区分多个instance的VRRP组播

    advert_int： 发VRRP包的时间间隔，即多久进行一次master选举（可以认为是健康查检时间间隔）。

    authentication： 认证区域，认证类型有PASS和HA（IPSEC），推荐使用PASS（密码只识别前8位）。

    state：
    可以是MASTER或BACKUP，不过当其他节点keepalived启动时会将priority比较大的节点选举为MASTER，因此该项其实没有实质用途。

    priority： 用来选举master的，要成为master，那么这个选项的值最好高于其他机器50个点，该项取值范围是1-255（在此范围之外会被识别成默认值100）。
```

## 3、启动Keepalived

```bash
# 设置开机启动
systemctl enable keepalived

# 启动keepalived
systemctl start keepalived

# 查看启动状态
systemctl status keepalived
```

## 4、查看网络状态

kepplived 配置中 state 为 MASTER 的节点启动后，查看网络状态，可以看到虚拟IP已经加入到绑定的网卡中
```
[root@tw19410s1 sysconfig]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:50:56:be:86:af brd ff:ff:ff:ff:ff:ff
    inet 192.168.2.20/22 brd 192.168.2.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet 192.168.2.10/32 scope global eth0
```

当关掉当前节点的keeplived服务后将进行虚拟IP转移，将会推选state 为 BACKUP 的节点的某一节点为新的MASTER，可以在那台节点上查看网卡，将会查看到虚拟IP

## 5、修改日志
```bash
1、修改vim /etc/sysconfig/keepalived
把KEEPALIVED_OPTIONS="-D" 修改为：KEEPALIVED_OPTIONS="-D -d -S 0"

2、在vim /etc/rsyslog.conf 末尾添加
local0.*                                                /var/log/keepalived.log

3、重启日志记录服务
systemctl restart rsyslog
systemctl restart keepalived
tail -f /var/log/keepalived.log 
```

# 二、防火墙配置

```
1、防火墙要放开vrrp协议，不然会脑裂 （把防火墙的vrrp给禁掉，就会出现脑裂现象）

#默认链的开放规则
-A INPUT -p vrrp -j ACCEPT

#自定义链的开放规则
-A RH-Firewall-1-INPUT -p vrrp -j ACCEPT 
```


参考文档:

https://mp.weixin.qq.com/s?__biz=MzAwNTM5Njk3Mw==&mid=2247487183&idx=1&sn=1dfddfd2d1f883cc568f311a4d77ced7&chksm=9b1c0e4dac6b875ba7f388f8f383d3c99dd10ea01f022d9bab8b929edb858d06433c5f2d30a9&mpshare=1&scene=23&srcid=&sharer_sharetime=1569483288434&sharer_shareid=73f6a617f7f81d90d08fd8ee497b58ac#rd  
