# 使用ssh -q -W代理连接

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
