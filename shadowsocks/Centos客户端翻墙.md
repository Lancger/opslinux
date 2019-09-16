## 一、前言
(需要一个已经能翻墙的 shadowsocks 服务端)

本文介绍的是在 CentOS 上安装 shadowsocks 客户端的过程，最终实现的也就是当前 CentOS 通过其他服务器的 Shadowsocks 服务联网，非在 CentOS 上安装 shadowsocks 服务端的过程，因此你需要一个已经能翻墙的 shadowsocks 服务端。

## 二、安装 pip
```
yum install epel-release python-pip -y
pip install --upgrade pip
pip install shadowsocks
```
## 三、配置 shadowsocks
```
vim /etc/shadowsocks.json
```
```
{
    "server":"13.229.223.57",
    "server_port":8388,
    "local_address": "127.0.0.1",
    "local_port":1080,
    "password":"your_server_passwd",
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open": false,
    "workers": 3
}
```
## 四、启动shadowsocks服务
```
sslocal -c /etc/shadowsocks.json
```
## 五、设置shadowsocks开机自启
```
配置开机自启
sudo vim /etc/systemd/system/shadowsocks.service

[Unit]
Description=Shadowsocks Client Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/sslocal -c /etc/shadowsocks.json

[Install]
WantedBy=multi-user.target

配置生效
systemctl enable /etc/systemd/system/shadowsocks.service

重启服务
systemctl restart shadowsocks
```
## 六、测试验证
```
curl --socks5 127.0.0.1:1080 http://httpbin.org/ip

如果返回你的 ss 服务器 ip 则测试成功：
{
  "origin": "13.229.223.57, 13.229.223.57"
}

```
## 七、安装 Privoxy
Shadowsocks 是一个 socket5 服务，因此我们需要使用 Privoxy 把流量转到 http/https 上。

```
直接使用yum安装即可：
yum install privoxy -y

安装好后，修改一下配置：
vim /etc/privoxy/config
搜索forward-socks5t将
forward-socks5t / 127.0.0.1:9050 .
取消注释并修改为：
forward-socks5t / 127.0.0.1:1080 .

启动 privoxy
privoxy /etc/privoxy/config

或以指定用户如www运行privoxy：
privoxy --user www /etc/privoxy/config
```
## 八、设置privoxy开机自启
```
配置开机自启
sudo vim /lib/systemd/system/privoxy.service

[[Unit]
Description=Privoxy Web Proxy With Advanced Filtering Capabilities
Wants=network-online.target
After=network-online.target

[Service]
Type=forking
PIDFile=/run/privoxy.pid
ExecStart=/usr/sbin/privoxy --pidfile /run/privoxy.pid /etc/privoxy/config

[Install]
WantedBy=multi-user.target

配置生效
systemctl enable /lib/systemd/system/privoxy.service

重启服务
systemctl restart privoxy
```

## 九、配置/etc/profile

这里8118为privoxy的服务端口
```
执行vim /etc/profile,添加如下代码：

export http_proxy=http://127.0.0.1:8118
export https_proxy=http://127.0.0.1:8118

source /etc/profile

curl www.google.com
```

## 十、便捷开关
```
vim ~/.bash_profile

function proxy_off(){
    unset http_proxy
    unset https_proxy
    echo -e "已关闭代理"
}

function proxy_on() {
    export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
    export http_proxy="http://127.0.0.1:8118"
    export https_proxy=$http_proxy
    echo -e "已开启代理"
}

source ~/.bash_profile

开启代理
proxy_on
关闭代理
proxy_off
```
