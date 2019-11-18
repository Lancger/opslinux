# 一、前言

本文采用Shadowsocks实现与外网通讯，如有需要，你也可以换成其他的软件，例如Gost/ShadowsocksR/V2Ray等。

本教程基于Debian10 x86_64环境建立，其他环境大同小异。

# 二、环境准备

## 1、更新系统环境&校对时间
```bash
apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y
apt-get install -y ca-certificates wget curl vim nano ntpdate git golang haveged proxychains
cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && ntpdate time.nist.gov
```
## 2、安装shadowsocks-libev
```bash
apt-get install shadowsocks-libev -y
systemctl stop shadowsocks-libev && systemctl disable shadowsocks-libev
rm -f /lib/systemd/system/shadowsocks-libev.service
systemctl daemon-reload
```

## 3、配置shadowsocks-libev
```bash
cd /etc/shadowsocks-libev

cat >/etc/shadowsocks-libev/config.json<<\EOF
{
    "server":"202.182.106.129",
    "mode":"tcp_and_udp",
    "server_port":11451,
    "local_port":1080,
    "password":"62903bcf7df17c6b",
    "timeout":300,
    "fast_open":true,
    "method":"aes-128-cfb"
}
EOF
```


参考资料：

https://luxing.im/socks5-as-a-vpn/  

https://xn--m80a.ml/crossgfw/5.html#mdui-dialog
