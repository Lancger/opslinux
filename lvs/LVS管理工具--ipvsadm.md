LVS管理工具--ipvsadm
一、 ipvsadm工具介绍
　　从2.4版本开始，linux内核默认支持LVS。要使用LVS的能力，只需安装一个LVS的管理工具：ipvsadm。
LVS的结构主要分为两部分：

    工作在内核空间的IPVS模块。LVS的能力实际上都是由IVPS模块实现。
    工作在用户空间的ipvsadm管理工具。其作用是向用户提供一个命令接口，用于将配置的虚拟服务、真实服务等传给IPVS模块。

二、 ipvsadm工具安装
　　ipvsadm工具支持rpm安装，也可以编译源码安装。下载地址：
　　http://www.linuxvirtualserver.org/software/ipvs.html
三、 ipvsadm工具使用

　　ipvsadm工具常用的参数选项有：
-A   --add-service 	添加一条新的虚拟服务
-E   --edit-service 	编辑虚拟服务
-D   --delete-service 	删除虚拟服务
-C   --clear 	清除所有的虚拟服务规则
-R   --restore 	恢复虚拟服务规则
-a   --add-server 	在一个虚拟服务中添加一个新的真实服务器
-e   --edit-server 	编辑某个真实服务器
-d   --delete-server 	删除某个真实服务器
-L | -l   --list 	显示内核中的虚拟服务规则
-n  --numeric 	以数字形式显示IP端口
-c  --connection 	显示ipvs中目前存在的连接，也可以用于分析调度情况
-Z   --zero 	将转发消息的统计清零
-p  --persistent 	配置持久化时间
--set tcp tcpfin udp 	配置三个超时时间（tcp/tcpfin/udp）
-t | -u 	TCP/UDP协议的虚拟服务
-g | -m | -i 	LVS模式为：DR | NAT | TUN
-w 	配置真实服务器的权重
-s 	配置负载均衡算法，如:rr, wrr, lc等
--timeout 	显示配置的tcp/tcpfin/udp超时时间
--stats 	显示历史转发消息统计（累加值）
--rate 	显示转发速率信息（瞬时值）
　　示例：
　　1. 管理虚拟服务

    添加一个虚拟服务192.168.1.100:80，使用轮询算法

　　ipvsadm -A -t 192.168.1.100:80 -s rr

    修改虚拟服务的算法为加权轮询

　　ipvsadm -E -t 192.168.1.100:80 -s wrr

    删除虚拟服务

　　ipvsadm -D -t 192.168.1.100:80
　　2. 管理真实服务

    添加一个真实服务器192.168.1.123，使用DR模式，权重2

　　ipvsadm -a -t 192.168.1.100:80 -r 192.168.1.123 -g -w 2

    修改真实服务器的权重

　　ipvsadm -a -t 192.168.1.100:80 -r 192.168.1.123 -g -w 5

    删除真实服务器

　　ipvsadm -d -t 192.168.1.100:80 -r 192.168.1.123
　　3. 查看统计

    查看当前配置的虚拟服务和各个RS的权重

　　ipvsadm -Ln

    查看当前ipvs模块中记录的连接（可用于观察转发情况）

　　ipvsadm -lnc

    查看ipvs模块的转发情况统计

　　ipvsadm -Ln --stats | --rate
　　
另外，--stats和--rate统计在分析问题时经常用到，输出各项的含义：
--stat选项是统计自该条转发规则生效以来的包  
1. Conns    (connections scheduled)  已经转发过的连接数  
2. InPkts   (incoming packets)       入包个数  
3. OutPkts  (outgoing packets)       出包个数  
4. InBytes  (incoming bytes)         入流量（字节）    
5. OutBytes (outgoing bytes)         出流量（字节） 
-------------------------------------------------------------------
--rate选项是显示速率信息  
1. CPS      (current connection rate)   每秒连接数  
2. InPPS    (current in packet rate)    每秒的入包个数  
3. OutPPS   (current out packet rate)   每秒的出包个数  
4. InBPS    (current in byte rate)      每秒入流量（字节）  
5. OutBPS   (current out byte rate)     每秒入流量（字节） 



参考文档：

https://segmentfault.com/a/1190000002609473   ipvsadm 命令详解


https://www.cnblogs.com/lipengxiang2009/p/7353373.html  LVS管理工具--ipvsadm
