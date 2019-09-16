
PREROUTING是目的地址转换（DNAT），要把别人的公网IP换成你们内部的IP，才让访问到你们内部受防火墙保护的服务器。

POSTROUTING是源地址转换（SNAT），要把你内部网络上受防火墙保护的ip地址转换成你本地的公网地址才能让它们上网。

```
pre还是post是根据数据包的流向来确定的。

通常内网到外网是post，外望到内网是pre，但是外还是内只是个相对概念，在一定条件下是可以转换的。落实到网卡上，对于每个网卡数据流入的时候必然经过pre，数量流出必然经过post。
```

一个简单的例子说明"PREROUTING"和"POSTROUTING"的不同应用环境：
```
1.1 POSTROUTING的应用，
一般情况下，PREROUTING应用在普通的NAT中（也就是SNAT），如：你用ADSL上网，这样你的网络中只有一个公网IP地址（如：61.129.66.5），但你的局域网中的用户还要上网（局域网IP地址为：192.168.1.0/24），这时你可以使用PREROUTING(SNAT)来将局域网中用户的IP地址转换成61.129.66.5，使他们也可以上网：
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o eth0 -j SNAT --to 61.129.66.5


1.2 PREROUTING的应用，
POSTROUTING用于将你的服务器放在防火墙之后，作为保护服务器使用，例如：
A.你的服务器IP地址为：192.168.1.2；
B.你的防火墙（Linux & iptables）地址为192.168.1.1和202.96.129.5

Internet上的用户可以正常的访问202.96.129.5,但他们无法访问192.168.1.2，这时在Linux防火墙里可以做这样的设置：
iptables -t nat -A PREROUTING -p tcp -m tcp --dport 20002 -j DNAT --to-destination 10.33.35.41:22

结：最要紧的是我们要记住PREROUTING是“路由规则”之前的动作，POSTROUTING是“路由规则”之后的动作！
```
参考文档：

https://www.cnblogs.com/wspblog/p/4297160.html  Linux prerouting和postrouting的区别

https://jingyan.baidu.com/article/aa6a2c143d84470d4c19c4cf.html  如何区分iptables的PREROUTING和POSTROUTING链
