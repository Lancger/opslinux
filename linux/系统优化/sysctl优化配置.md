# 一、内核参数优化介绍
```
1）timewait的数量，默认是180000。(Deven:因此如果想把timewait降下了就要把tcp_max_tw_buckets值减小)
net.ipv4.tcp_max_tw_buckets = 6000

2）允许系统打开的端口范围。
net.ipv4.ip_local_port_range = 1024 65000

3）启用TIME-WAIT状态sockets快速回收功能;用于快速减少在TIME-WAIT状态TCP连接数。1表示启用;0表示关闭。但是要特别留意的是：这个选项一般不推荐启用，因为在NAT(Network Address Translation)网络下，会导致大量的TCP连接建立错误，从而引起网站访问故障。
net.ipv4.tcp_tw_recycle = 0
----------------------------------------------------------------------------------------------------------------------------------
实际上，net.ipv4.tcp_tw_recycle功能的开启，要需要net.ipv4.tcp_timestamps（一般系统默认是开启这个功能的）这个开关开启后才有效果；
当tcp_tw_recycle 开启时（tcp_timestamps 同时开启，快速回收 socket 的效果达到），对于位于NAT设备后面的 Client来说，是一场灾难！
会导致到NAT设备后面的Client连接Server不稳定（有的 Client 能连接 server，有的 Client 不能连接 server）。
也就是说，tcp_tw_recycle这个功能，是为内部网络（网络环境自己可控 ” ——不存在NAT 的情况）设计的，对于公网环境下，不宜使用。
通常来说，回收TIME_WAIT状态的socket是因为“无法主动连接远端”，因为无可用的端口，而不应该是要回收内存（没有必要）。
即：需求是Client的需求，Server会有“端口不够用”的问题吗？
除非是前端机，需要大量的连接后端服务，也就是充当着Client的角色。

正确的解决这个总是办法应该是：
net.ipv4.ip_local_port_range = 9000 6553 #默认值范围较小
net.ipv4.tcp_max_tw_buckets = 10000 #默认值较小，还可适当调小
net.ipv4.tcp_tw_reuse = 1 
net.ipv4.tcp_fin_timeout = 10 
----------------------------------------------------------------------------------------------------------------------------------

4）时间戳可以避免序列号的卷绕。一个1Gbps的链路肯定会遇到以前用过的序列号。时间戳能够让内核接受这种“异常”的数据包。
net.ipv4.tcp_timestamps = 1
-------------------------------------------------------------------------------------------------------------------------------------------------------
有不少服务器为了提高性能，开启net.ipv4.tcp_tw_recycle选项，在NAT网络环境下，容易导致网站访问出现了一些connect失败的问题
个人建议：
关闭net.ipv4.tcp_tw_recycle选项，而不是net.ipv4.tcp_timestamps；
因为在net.ipv4.tcp_timestamps关闭的条件下，开启net.ipv4.tcp_tw_recycle是不起作用的；而net.ipv4.tcp_timestamps可以独立开启并起作用。
-------------------------------------------------------------------------------------------------------------------------------------------------------

5）开启SYN Cookies，当出现SYN等待队列溢出时，启用cookies来处理。
net.ipv4.tcp_syncookies = 1

6）web应用中listen函数的backlog默认会给我们内核参数的net.core.somaxconn限制到128，而nginx定义的NGX_LISTEN_BACKLOG默认为511，所以有必要调整这个值。
net.core.somaxconn = 262144

7）每个网络接口接收数据包的速率比内核处理这些包的速率快时，允许送到队列的数据包的最大数目。
net.core.netdev_max_backlog = 262144

8）系统中最多有多少个TCP套接字不被关联到任何一个用户文件句柄上。如果超过这个数字，孤儿连接将即刻被复位并打印出警告信息。这个限制仅仅是为了防止简单的DoS攻击，不能过分依靠它或者人为地减小这个值，更应该增加这个值(如果增加了内存之后)。
net.ipv4.tcp_max_orphans = 262144

9）记录的那些尚未收到客户端确认信息的连接请求的最大值。对于有128M内存的系统而言，缺省值是1024，小内存的系统则是128。
net.ipv4.tcp_max_syn_backlog = 262144

10）开启重用功能，允许将TIME-WAIT状态的sockets重新用于新的TCP连接。这个功能启用是安全的，一般不要去改动！
net.ipv4.tcp_tw_reuse = 1

11）为了打开对端的连接，内核需要发送一个SYN并附带一个回应前面一个SYN的ACK。也就是所谓三次握手中的第二次握手。这个设置决定了内核放弃连接之前发送SYN+ACK包的数量。
net.ipv4.tcp_synack_retries = 1

12）在内核放弃建立连接之前发送SYN包的数量。
net.ipv4.tcp_syn_retries = 1

13）如果套接字由本端要求关闭，这个参数 决定了它保持在FIN-WAIT-2状态的时间。对端可以出错并永远不关闭连接，甚至意外当机。缺省值是60秒。2.2 内核的通常值是180秒，你可以按这个设置，但要记住的是，即使你的机器是一个轻载的WEB服务器，也有因为大量的死套接字而内存溢出的风险，FIN- WAIT-2的危险性比FIN-WAIT-1要小，因为它最多只能吃掉1.5K内存，但是它们的生存期长些。
net.ipv4.tcp_fin_timeout = 30

14）当keepalive起用的时候，TCP发送keepalive消息的频度。缺省是2小时。
net.ipv4.tcp_keepalive_time = 30
```

# 二、sysctl.conf
```
cat > /etc/sysctl.conf << \EOF
net.ipv4.ip_forward = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096 87380 4194304
net.ipv4.tcp_wmem = 4096 16384 4194304
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 262144
net.core.somaxconn = 262144
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_timestamps = 1            //在net.ipv4.tcp_tw_recycle设置为1的时候，这个选择最好加上
############################
net.ipv4.tcp_syncookies = 1            //这四行标红内容，一般是发现大量TIME_WAIT时的解决办法
net.ipv4.tcp_tw_recycle = 1           //开启此功能可以减少TIME-WAIT状态，但是NAT网络模式下打开有可能会导致tcp连接错误，慎重。
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
############################
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_keepalive_time = 30
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.ip_conntrack_max = 6553500
file-max = 655350
EOF
```

# 三、故障记录
```
-------------------------------------记一次小事故----------------------------------------------------
net.ipv4.tcp_tw_recycle = 1 这个功能打开后，确实能减少TIME-WAIT状态，习惯上我都会将这个参数打开。
但是也因为这个参数踩过一次坑：
公司的一个发布新闻的CMS后台系统，采用haproxy+keepalived代理架构，后端的real server服务器外网ip全部拿掉。
现象：在某一天早上发文高峰期，CMS后台出现访问故障，重启php服务后会立刻见效，但持续一段时间后，访问就又出现故障。
排查nginx和php日志也没有发现什么，后来google了一下，发现就是net.ipv4.tcp_tw_recycle这个参数捣的鬼！
这种网络架构对于后端的realserver来说是NAT模式，打开这个参数后，会导致大量的TCP连接建立错误，从而引起网站访问故障。
最后将net.ipv4.tcp_tw_recycle设置为0，关闭这个功能后，后台访问即刻恢复正常
-----------------------------------------------------------------------------------------------------
```

# 四、线上使用
```
cat > /etc/sysctl.conf << \EOF
net.ipv4.ip_forward = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096 87380 4194304
net.ipv4.tcp_wmem = 4096 16384 4194304
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 262144
net.core.somaxconn = 262144
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_keepalive_time = 30
net.ipv4.ip_local_port_range = 1024 65000
EOF
sysctl -p
```

参看文档：

https://blog.csdn.net/tiantiandjava/article/details/79969909  	nginx应用总结--突破高并发的性能优化

https://www.jianshu.com/p/87ec508be2c5  sysctl.conf 配置

https://help.aliyun.com/knowledge_detail/41334.html  Linux实例常用内核网络参数介绍与常见问题处理
