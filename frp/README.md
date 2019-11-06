```bash
#服务端配置
[root@VM_0_10_centos frp]# cat frps.ini 
[common]
bind_port = 7000
dashboard_port = 7500
token = 123456
dashboard_user = admin
dashboard_pwd = admin
vhost_http_port = 80
vhost_https_port = 443

#客户端配置
root># cat frpc.ini
[common]
server_addr = 120.x.x.x  #公网服务器IP
server_port = 7000
token = 123456

[ssh]
type = tcp
local_ip = 192.168.56.11  #内网服务器IP
local_port = 22
remote_port = 6000

[web]
type = http
local_port = 80
custom_domains = www.test.club

#访问测试，绑定host
120.x.x.x  www.test.club
http://www.test.club/
```
参考文档：

https://sspai.com/post/52523   为什么需要内网穿透功能

https://www.jianshu.com/p/00c79df1aaf0   一款很好用的内网穿透工具--FRP
