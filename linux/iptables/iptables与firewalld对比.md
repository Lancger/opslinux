```
Firewalld
从Cent7以后，iptables服务的启动脚本已被忽略。请使用firewalld来取代iptables服务。

在RHEL7里，默认是使用firewalld来管理netfilter子系统，不过底层调用的命令仍然是iptables。

firewalld是iptables的前端控制器，用于实现持久的网络流量规则。它提供命令行和图形界面。

firewalld 与 iptables的比较：

1，firewalld可以动态修改单条规则，动态管理规则集，允许更新规则而不破坏现有会话和连接。而iptables，在修改了规则后必须得全部刷新才可以生效；

2，firewalld使用区域和服务而不是链式规则；

3，firewalld默认是拒绝的，需要设置以后才能放行。而iptables默认是允许的，需要拒绝的才去限制；

4，firewalld自身并不具备防火墙的功能，而是和iptables一样需要通过内核的netfilter来实现。也就是说，firewalld和iptables一样，它们的作用都用于维护规则，而真正使用规则干活的是内核的netfilter。只不过firewalld和iptables的结果以及使用方法不一样！

firewalld是iptables的一个封装，可以让你更容易地管理iptables规则。它并不是iptables的替代品，虽然iptables命令仍可用于firewalld，但建议firewalld时仅使用firewalld命令。

一个重要规则：区域管理
通过将网络划分成不同的区域，制定出不同区域之间的访问控制策略来控制不同程序区域间传送数据流。

例如，互联网是不可信任的区域，而内部网络是高度信任的区域。

网络安全模型可以在安装，初次启动和首次建立网络连接时选择初始化。改模型描述了主机所连接的整个网络环境的可信级别，并定义了新连接的处理方式。

初始化区域：

阻塞区域（block）：任何传入的网络数据包都将被阻止；

工作区域（work）：相信网络上的其他计算机，不会损害你的计算机；

家庭区域（home）：相信网络上的其他计算机，不会损害你的计算机；

公共区域（public）：不相信网络上的任何计算机，只有选择接受传入的网络连接；

隔离区域（DMZ）：也称为非军事区域，内外网络之间增加的一层网络，起到缓冲作用。对于隔离区域，只有选择接受传入的网络连接；

信任区域（trueted）：所有网络连接都可以接受；

丢弃区域（drop）：任何传入的网络连接都被拒绝；

内部区域（internal）：信任网络上的其他计算机，不会损害你的计算机。只选择接受传入的网络连接；

外部区域（external）：不相信网络上的其他计算机，不会损害你的计算机。只选择接受传入的网络连接；

firewalld的默认区域是public。

firewalld使用XML进行配置。除非非常特殊的配置，你不必处理他们，而应该使用firewalld-cmd。

配置文件：

/usr/lib/firewalld    #保存默认配置，避免修改他们；

/etc/firewalld    #保存系统配置文件，这些文佳你将覆盖默认配置；

firewalld默认提供了九个zone配置文件：block.xml，dmz.xml，drop.xml，external.xml，home.xml，internal.xml，public.xml，trusted.xml，work.xml

/usr/lib/firewalld/zone/


firewalld配置方法
firewalld的配置方法主要有三种：firewall-config（图形化工具）、firewall-cmd（命令行工具） 和 直接编辑XML文件。

yum  install  firewalld  firewall-config

systemctl  start|stop|status|restart  firewalld

systemctl  enable|disable  firewalld

firewalld-cmd  --state    #检查防火墙状态；

systemctl status firewalls    #查看firewalld守护进程状态；

firewall-cmd --help

firewall-cmd --version

firewall-cmd --state

firewall-cmd --get-active-zones     #查看网络接口使用的区域

firewall-cmd --zone=public --list-all    #查看指定区域的所有配置

firewall-cmd --list-all-zones    #查看所有区域配置

firewall-cmd --get-default-zone    #查看默认区域

firewall-cmd --set-default-zone=internal    #设置默认区域

firewall-cmd --get-zone-of-interface=eth0    #查看指定接口所属区域

firewall-cmd --zone=public --add-interface=eth0    #将接口添加到区域，默认接口都在public，永久生效加上 --permanent，然后reload

#需要永久生效需加上 --permannent

firewall-cmd --panic-on|off    #拒绝|开启 所有包

firewall-cmd --query-panic    #查看是否拒绝

firewall-cmd --reload    #无需断开连接更新防火墙规则

firewall-cmd --complete-reload    #类似于重启更新规则

firewall-cmd --zone=dmz --list-ports    #查看所有打开的端口

firewall-cmd --zone=dmz --add-port=8080/tcp    #加入一个端口的区域

与服务一起使用
firewalld可以根据特定网络服务的预定义规则来允许相关流量。你可以创建自己的自定义系统规则，并将它们添加到任何区域。默认支持的服务的配置文件位于 /usr/lib/firewalld/services，用于创建的服务文件位于 /etc/firewalld/services 中。

/usr/lib/firewalld/services/
firewall-cmd --get-services    #查看默认可用服务

firewall-cmd --zone=区域 --(add|remove)-service=http --permanent    #永久启用或禁用HTTP服务

firewall-cmd --zone=public --add-port=123456/tcp --permanent    #添加123456端口的tcp流量；

firewall-cmd --zone=public --add-forward-port=port=80:proto=tcp:toport=123456    #将80端口的流量转发到123456端口

将端口转发到另外一台服务器上：

firewall-cmd --zone=区域 --add-masquerade    #在需要的区域中激活masquerade

firewall-cmd --zone=区域 --remove-masquerade    #删除

firewall-cmd --zone=区域 --add-forward--port=port=80:proto=tcp:toport=8080:toaddr=123.123.123.123    #将本地80端口的流量转发到指定IP的8080端口；







iptables
数据包进入流程：规则顺序的重要性
根据数据包的分析资料“比对”预先定义的规则内容，若数据包与规则内容相同则进行动作，否则就继续下一条规则的比对，重点在比对与分析顺序。

规则是有顺序的，规则的顺序很重要。

当规则顺序排列错误时，会产生很严重的错误。




iptables 的表格（table）和链（chain）
为什么称为 iptables 呢？因为这个防火墙软件里面由多个表格（table），每个表格定义出自己的默认策略和规则，且每个表格的用途都不相同。

默认情况下，Linux 的 iptables 至少有3个表格，包括管理本机进出的Filter、管理后端主机（防火墙内部的其他计算机）的NAT、管理特殊标志使用的Mangle（较少使用）。我们还可以自定义额外的链。

iptables 的表格与相关链示意图
Filter（过滤）

：主要跟进入Linux本机的数据包有关，是默认的table。

INPUT : 主要与想要进入 Linux 本机的数据包有关

OUTPUT ： 主要与 Linux 本机所要送出的数据包有关

FORWARD（发送）： 与 Linux 本机没有关系，它可以传递数据包到后端的计算机中，与 NAT table 相关性较高

NAT（地址转换）：这个 table 主要用来进行 源和目的IP或Port的转换，与Linux本机无关，主要与局域网内计算机相关。

PREROUTING : 在进行路由判断之前所要进行的规则（DNAT/REDIRECT）

POSTROUTING : 在进行路由判断之后所要进行的规则（SNAT/MASQUERADE）

OUTPUT： 与发送出去的数据包有关

Mangle（破坏者）：这个 table 主要是与特殊的数据包的路由标志有关。



iptables 内建表格与链的相关性

本机的 iptables 语法
切记谨慎使用 iptables 命令，特别是在远程连接的时候。

防火墙的设置主要是使用的 iptables 这个命令，而防火墙是系统管理员的主要任务之一，且对于系统的影响相当大，因此只能让 root 使用 iptables，不论是设置还是查看防火墙规则。

规则的查看与清除

#  iptables  -L  -n


target : 代表进行的操作，ACCEPT是放行，而 REJECT 则是拒绝，此外，尚有 DROP（丢弃）的项目；

prot : 代表使用的数据包协议；

opt : 额外的选项说明；

source ： 针对来源 IP；

destination ： 针对目的 IP

建议使用 iptables-save 这个命令来查看防火墙规则

iptables-save
清除防火墙规则 

iptables  [ -t  tables ]  [ -FXZ ]

iptables  -F    #清除所有已制定的规则

iptables  -X    #清除用户 "自定义"

iptables  -Z    #将所有的 chain 的计数与流量统计都归零

# 这三个命令会将本机防火墙的所有规则都清除，但却不会改变 "默认策略（policy )"

定义默认策略（policy）

当数据包不在我们设置的规则之内时，则该数据包的通过与否，是以Policy的设置为准。

如果对于局域网内的用户有信心，那么Filter内的INPUT就可以定义严格一点，而OUTPUT和FORWARD则可以制定的松一些。

iptables [ -t nat ] -P [ INPUT, OUTPUT, FORWARD ] [ ACCEPT, DROP ]

举例，修改默认策略，信任内部网络，严格对待 INPUT

iptables  -P  INPUT  DROP；    #丢弃

iptables  -P  OUTPUT  ACCEPT；

iptables  -P  FORWARD  ACCEPT；

最后使用  iptables-save  查看

数据包的基础比对 ： IP、网络及接口设备


举例，没有指定的项目则表示该项目完全接受

还要说一遍，规则顺序是很重要的，一定要重视和注意这个问题。

iptables  -A  INPUT  -i  lo  -j  ACCEPT    #只要是loopback这个接口，不管 Source 和 Destination，予以接受

iptables  -A  INPUT  -i  eth0  -s  192.168.2.0/24  -j  ACCEPT

iptables  -A  INPUT  -i  eth1  -s  111.111.111.111  -j  DROP    # 从 Source"111.111.111.111" 进来的数据包就丢弃

iptables  -A  OUTPUT  -i  eth1  -d  8.8.8.8  -j  LOG    #到Destination为"8.8.8.8"则进行日志记录

TCP、UDP的规则比对：针对端口设置

其实相较于IP，这个只不过增加了 tcp/udp 和 sport/dport，包括 tcp 连接数据包状态，最常见的 SYN等


几个小测试：

iptables  -A  INPUT  -i  eth0  -p  tcp  --dport  22 -j DROP

iptables  -A  INPUT  -i  eth1  -p  udp  --dport  555：666 -j  ACCEPT

iptables  -A  INPUT  -i  eht0  -s  192.168.2.0/24  -p  tcp  --sport  1024:65534  --dport  ssh  -j  DROP

iptables  -A  INPUT  -i  eth0  -p  tcp  --sport  1:1023  --syn  -j  DROP

# 切记要选择是  TCP 还是 UDP

iptables外挂模块：mac 与 state

通过一个状态模块来分析这个想要进入的数据包是否为刚刚发出去的响应。如果是，则予以放行。



举例：

iptables  -A  INPUT  -m  state  --state  ESTABLISHED,RELATED  -j  ACCEPT

iptables  -A  INPUT  -m  mac  --mac--source  aa:bb:cc:11:22:33  -j  DROP    #针对网卡执行的放行和防御

其实MAC也是可以伪装，此外，MAC是不能跨过Router的，因此针对网卡的方案只存在与局域网内

关闭主机的ICMP ping

iptables  -A  INPUT  -p  icmp  --icmp-type  8  -j  REJECT

ICMP字段类型
```
参考资料：

https://www.jianshu.com/p/70f7efe3a227   firewalld 与 iptables
