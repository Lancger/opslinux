## Mac命令行终端下使用shadowsocks翻墙

配置好shadowsocks服务器端后，安装对应系统的客户端，浏览器安装相应插件就可以翻墙上网了，这都很简单。

问题是对于经常在命令行终端下工作的码农们，SS无法正常工作。因为在终端下不支持socks5代理，只支持http代理，这就很尴尬了。wget、curl、git、brew等命令行工具都会变得很慢。

Linux系统就简单一些，安装proxychains-NG等软件就可以解决了，但是在Mac下有点麻烦。OS X 10.11之前的系统海好说，都还比较顺利，但是OS X 10.11之后较新的系统默认设置下不会安装成功。

因为苹果在新系统中加入了SIP安全机制，他会阻止第三方程序向系统目录内（/System，/bin，/sbin，/usr(除了/usr/local)）进行写操作，sudo也不行。办法是先把SIP关了，等装好软件配置好后再打开SIP。或者改用其他软件。

我懒得去把SIP关了开开了关了，找了另外一个软件privoxy，它刚好就是安装在/usr/local内，不需要关闭SIP也可以正常使用。

## 1. privoxy安装
安装很简单用brew安装：
```
brew install privoxy
```
## 2. privoxy配置
```
打开配置文件 /usr/local/etc/privoxy/config
vim /usr/local/etc/privoxy/config

加入下面这两项配置项
listen-address 0.0.0.0:8118
forward-socks5 / localhost:1080 .

第一行设置privoxy监听任意IP地址的8118端口。第二行设置本地socks5代理客户端端口，注意不要忘了最后有一个空格和点号。
```
## 3. 启动privoxy
因为没有安装在系统目录内，所以启动的时候需要打全路径。
```
sudo /usr/local/opt/privoxy/sbin/privoxy /usr/local/etc/privoxy/config
```

## 4. 查看是否启动成功
```
netstat -na | grep 8118

看到有类似如下信息就表示启动成功了
tcp4 0 0 *.8118 *.* LISTEN

```

## 5. privoxy使用
```
在命令行终端中输入如下命令后，该终端即可翻墙了。

export http_proxy='http://localhost:8118'
export https_proxy='http://localhost:8118'

他的原理是讲socks5代理转化成http代理给命令行终端使用。
如果不想用了取消即可

unset http_proxy
unset https_proxy


```

## 6.便捷开关

还可以在 ~/.bash_profile 里加入开关函数，使用起来更方便

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

使用开关
➜  ~ proxy_off
已关闭代理
➜  ~ proxy_on
已开启代理

验证
➜  ~ curl ip.gs

Current IP / 当前 IP: 13.229.223.57
ISP / 运营商:  amazon.com
City / 城市:  Singapore
Country / 国家: Singapore
IP.GS is now IP.SB, please visit https://ip.sb/ for more information. / IP.GS 已更改为 IP.SB ，请访问 https://ip.sb/ 获取更详细 IP 


$ curl ip.cn -L
{"ip": "10.179.160.221", "country": "广东省深圳市", "city": "阿里云"}
```

参考文档：

https://segmentfault.com/a/1190000016126554  Mac命令行终端下使用shadowsocks翻墙
