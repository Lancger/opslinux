# 一、报错
```
rpcinfo: can't contact portmapper: RPC: Authentication error; why = Client credential too weak

[root@node1 ~]# showmount -e 10.33.35.5
Export list for 10.33.35.5:
/nfsdata *

[root@node1 ~]# rpcinfo -p 10.33.35.5
   program vers proto   port  service
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    100000    3   udp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  28399  status
    100024    1   tcp  31679  status
    100005    1   udp  20048  mountd
    100005    1   tcp  20048  mountd
    100005    2   udp  20048  mountd
    100005    2   tcp  20048  mountd
    100005    3   udp  20048  mountd
    100005    3   tcp  20048  mountd
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100227    3   tcp   2049  nfs_acl
    100003    3   udp   2049  nfs
    100003    4   udp   2049  nfs
    100227    3   udp   2049  nfs_acl
    100021    1   udp  28172  nlockmgr
    100021    3   udp  28172  nlockmgr
    100021    4   udp  28172  nlockmgr
    100021    1   tcp  24874  nlockmgr
    100021    3   tcp  24874  nlockmgr
    100021    4   tcp  24874  nlockmgr
```

# 二、解决方案
```
1、# nfs有使用tcp和udp的端口
-A RH-Firewall-1-INPUT -s 10.33.35.5/32 -p tcp -m tcp -j ACCEPT
-A RH-Firewall-1-INPUT -s 10.33.35.6/32 -p tcp -m tcp -j ACCEPT
-A RH-Firewall-1-INPUT -s 10.33.35.7/32 -p tcp -m tcp -j ACCEPT
-A RH-Firewall-1-INPUT -s 10.33.35.8/32 -p tcp -m tcp -j ACCEPT
-A RH-Firewall-1-INPUT -s 10.33.35.5/32 -p udp -m udp -j ACCEPT
-A RH-Firewall-1-INPUT -s 10.33.35.6/32 -p udp -m udp -j ACCEPT
-A RH-Firewall-1-INPUT -s 10.33.35.7/32 -p udp -m udp -j ACCEPT
-A RH-Firewall-1-INPUT -s 10.33.35.8/32 -p udp -m udp -j ACCEPT

2、# vim /etc/hosts.allow
rpcbind : ALL : allow
mountd : ALL : allow
nfsd: ALL: allow
```
参考文档：

https://yq.aliyun.com/articles/694065  Kubernetes Store（pv、pvc）

https://stackoverflow.com/questions/13111910/rpc-authentication-error  
