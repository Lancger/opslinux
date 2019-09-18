# 一、使用ssh -q -W代理连接

```
(demo3) ➜  .ssh pwd
/Users/User01/.ssh

(demo3) ➜  .ssh cat config
Host 139.180.*
  User root
  Port 33389
  ProxyCommand ssh -q -W %h:%p gateway
  IdentityFile /Users/User01/OpenVpn/shadowsock/id_salt_rsa

Host gateway
  HostName 47.11.120.190
  User root
  Port 22
  IdentityFile /Users/User01/UserFull/keys/ss_coin_1.pem
```

# 二、前提条件

1、本地机器与代理机器网络连通

```
#代理机器信息
Host gateway
  HostName 47.11.120.190
  User root
  Port 22
  IdentityFile /Users/User01/UserFull/keys/ss_coin_1.pem
  
#测试本机与代理机器的连通性
(demo3) ➜  .ssh ssh -i /Users/User01/UserFull/keys/ss_coin_1.pem root@47.11.120.190
Last login: Wed Sep 18 11:23:19 2019 from 290.170.11.129

Welcome to Alibaba Cloud Elastic Compute Service
```

2、代理机器与目标机器
```
#连接目标机器的信息

Host 139.180.*    #这里可以使用通配符
  User root
  Port 33389
  ProxyCommand ssh -q -W %h:%p gateway
  IdentityFile /Users/User01/OpenVpn/shadowsock/id_salt_rsa
 
```

# 三、测试连接
```
(demo3) ➜  .ssh ssh -p33389 root@139.180.22.30
Last login: Wed Sep 18 11:25:23 2019 from 47.11.120.190

salt-master<2019-09-18 11:39:24> ~
root>#
```

