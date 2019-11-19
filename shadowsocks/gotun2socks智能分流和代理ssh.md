Table of Contents
=================

   * [一、前言](#一前言)
   * [二、服务端](#二服务端)
      * [1、ss-server服务端安装](#1ss-server服务端安装)
   * [三、客户端](#三客户端)
      * [1、mac下使用](#1mac下使用)
         * [1、安装软件](#1安装软件)
         * [2、shadowsock配置](#2shadowsock配置)
         * [3、验证ssh登录](#3验证ssh登录)
         * [4、查看日志tun2socks](#4查看日志tun2socks)
      * [2、Linux下使用](#2linux下使用)
         * [1、安装shadowsocks-libev](#1安装shadowsocks-libev)
         * [2、配置shadowsocks-libev](#2配置shadowsocks-libev)
         * [3、配置ss-local](#3配置ss-local)
         * [4、安装配置tun2socks](#4安装配置tun2socks)
         * [5、测试验证](#5测试验证)
         
# 一、前言

本文采用Shadowsocks实现与外网通讯，如有需要，你也可以换成其他的软件，例如Gost/ShadowsocksR/V2Ray等。

本教程基于Centos7 x86_64环境建立，其他环境大同小异。

# 二、服务端

## 1、ss-server服务端安装
```bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/ss-go.sh && chmod +x ss-go.sh && bash ss-go.sh
 
#Shadowsocks 用户配置：
————————————————
地址   : 202.182.106.129
端口   : 11451
密码   : 62903bcf7df17c6b
加密   : aes-128-cfb
链接  [ipv4] : ss://YWVzLTEyOC1jZmI6NjI5MDNiY2Y3ZGYxN2M2YkAyMDIuMTgyLjEwNi4xMjk6MTE0NTE 
二维码[ipv4] : http://doub.pw/qr/qr.php?text=ss://YWVzLTEyOC1jZmI6NjI5MDNiY2Y3ZGYxN2M2YkAyMDIuMTgyLjEwNi4xMjk6MTE0NTE

详细日志模式   : NO

#验证端口
nc -zv 202.182.106.129 11451
```

# 三、客户端

## 1、mac下使用

### 1、安装软件

```bash
#下载软件包
brew install iproute2mac
wget -N https://github.com/eycorsican/go-tun2socks/releases/download/v1.16.7/tun2socks-darwin-10.6-amd64
chmod +x tun2socks-darwin-10.6-amd64

#查看启动参数
./tun2socks-darwin-10.6-amd64 -h

Usage of ./tun2socks-linux-amd64:
  -loglevel string
    	Logging level. (debug, info, warn, error, none) (default "info")
  -proxyServer string
    	Proxy server address (default "1.2.3.4:1087")
  -proxyType string
    	Proxy handler type (default "socks")
  -tunAddr string
    	TUN interface address (default "10.255.0.2")
  -tunDns string
    	DNS resolvers for TUN interface (only need on Windows) (default "8.8.8.8,8.8.4.4")
  -tunGw string
    	TUN interface gateway (default "10.255.0.1")
  -tunMask string
    	TUN interface netmask, it should be a prefixlen (a number) for IPv6 address (default "255.255.255.0")
  -tunName string
    	TUN interface name (default "tun1")
  -tunPersist
    	Persist TUN interface after the program exits or the last open file descriptor is closed (Linux only)
  -udpTimeout duration
    	UDP session timeout (default 1m0s)
  -version
    	Print version

#mac下使用
sudo su -
kill `ps -ef|grep tun2socks-darwin|grep -v grep|awk '{print $2}'`
nohup ./tun2socks-darwin-10.6-amd64 -tunAddr 172.16.0.2 -tunGw 172.16.0.1 -proxyServer 127.0.0.1:1086 -tunDns 8.8.8.8,8.8.4.4 -tunName tun2 -loglevel info > /tmp/proxy.log 2>&1 &

#检查服务
ps -ef|grep tun2socks-darwin

#启动网卡
ip link set utun2 up

#新增路由
ip route add 10.10.0.1/24 dev utun2

#查看路由
$ ip route show
default via 10.9.128.5 dev en0
10.9.128.0/21 dev en0  scope link
10.9.128.5/32 dev en0  scope link
10.9.134.2/32 dev en0  scope link
10.10.0.0/24 via utun2 dev utun2   --- 有这条路由
127.0.0.0/8 via 127.0.0.1 dev lo0
127.0.0.1/32 via 127.0.0.1 dev lo0
169.254.0.0/16 dev en0  scope link
172.16.0.1/32 via 172.16.0.2 dev utun2
172.16.101.0/24 dev vmnet8  scope link
192.168.56.0/24 dev vmnet2  scope link
192.168.171.0/24 dev vmnet1  scope link
224.0.0.0/4 dev en0  scope link
255.255.255.255/32 dev en0  scope link

#验证socks服务是否OK
curl -4vLx socks5h://127.0.0.1:1086 https://www.google.com
curl -s --socks5 127.0.0.1:1086 google.com
ssh -o ProxyCommand='nc -x 127.0.0.1:1086 %h %p' root@10.0.0.18
```

### 2、shadowsock配置

  ![shadowsock-ng](https://github.com/Lancger/opslinux/blob/master/images/shadowsock-ng1.png)

### 3、验证ssh登录
```bash
ssh root@10.10.0.18
```

### 4、查看日志tun2socks
```bash
tail -100f /tmp/proxy.log
2019/11/19 12:17:42 Running tun2socks
2019/11/19 12:19:15 new proxy connection to 10.10.0.18:22
2019/11/19 12:19:33 new proxy connection to 10.10.0.9:22
```

## 2、Linux下使用

### 1、安装shadowsocks-libev

```bash
#安装报错
Error: Package: shadowsocks-libev-3.1.3-1.el7.centos.x86_64 (librehat-shadowsocks)
           Requires: libsodium >= 1.0.4
Error: Package: shadowsocks-libev-3.1.3-1.el7.centos.x86_64 (librehat-shadowsocks)
           Requires: mbedtls
```

```bash
#需要首先启用 EPEL，再安装 shadowsocks-libev
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

wget https://copr.fedorainfracloud.org/coprs/librehat/shadowsocks/repo/epel-7/librehat-shadowsocks-epel-7.repo -O /etc/yum.repos.d/shadowsocks-epel-7.repo
yum clean all
yum install -y shadowsocks-libev ipset
```

### 2、配置shadowsocks-libev
```bash
cd /etc/shadowsocks-libev

cat >/etc/shadowsocks-libev/config.json<<\EOF
{
    "server":"202.182.106.129",
    "mode":"tcp_and_udp",
    "server_port":11451,
    "local_port":1086,
    "password":"62903bcf7df17c6b",
    "timeout":300,
    "fast_open":true,
    "method":"aes-128-cfb"
}
EOF
```

### 3、配置ss-local
```bash
cat >/etc/systemd/system/ss-local.service<<\EOF
[Unit]
Description=Shadowsocks-Libev Client Service
After=network.target

[Service]
User=root
LimitNOFILE=1048576
CapabilityBoundingSet=~CAP_SYS_ADMIN
ExecStart=/usr/bin/ss-local -u -c /etc/shadowsocks-libev/config.json

[Install]
WantedBy=multi-user.target
EOF

#重启服务
systemctl enable ss-local
systemctl restart ss-local
systemctl status ss-local
```

### 4、安装配置tun2socks
```bash
#下载软件包
cd /usr/local/src/
wget -N https://github.com/eycorsican/go-tun2socks/releases/download/v1.16.7/tun2socks-linux-amd64
chmod +x tun2socks-linux-amd64
cp tun2socks-linux-amd64 /usr/bin/

#centos7下使用
nohup tun2socks-linux-amd64 -tunAddr 172.16.0.2 -tunGw 172.16.0.1 -proxyServer 127.0.0.1:1086 -tunDns 8.8.8.8,8.8.4.4 -tunName tun2 -loglevel info > /tmp/proxy.log 2>&1 &

#启动网卡
ip link set tun2 up

root># ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:30:e7:42 brd ff:ff:ff:ff:ff:ff
    inet 192.168.56.11/24 brd 192.168.56.255 scope global eth0
       valid_lft forever preferred_lft forever
6: tun2: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 500
    link/none

#新增路由
ip addr add 10.10.0.1/24 dev tun2

root># ip route show
default via 192.168.56.2 dev eth0
10.10.0.0/24 dev tun2 proto kernel scope link src 10.10.0.1
192.168.56.0/24 dev eth0 proto kernel scope link src 192.168.56.11
```

### 5、测试验证
```bash
curl -s --socks5 127.0.0.1:1086 google.com

<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>
如一切无误，此时ss-local已经开始正常工作。

curl -s ip.sb

curl -s members.3322.org/dyndns/getip

ssh root@10.10.0.18
```

参考资料：

https://blog.csdn.net/u012758088/article/details/76255543  Linux系列—策略路由、ip rule、ip route

https://luxing.im/socks5-as-a-vpn/  

https://medium.com/@TachyonDevel/%E6%95%99%E7%A8%8B-%E5%9C%A8-windows-%E4%B8%8A%E4%BD%BF%E7%94%A8-tun2socks-%E8%BF%9B%E8%A1%8C%E5%85%A8%E5%B1%80%E4%BB%A3%E7%90%86-aa51869dd0d  在 Windows 上使用 tun2socks 进行全局代理

https://xn--m80a.ml/crossgfw/5.html#mdui-dialog
