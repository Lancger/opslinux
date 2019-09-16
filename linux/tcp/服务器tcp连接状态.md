# 一、服务器连接状态统计
```
#方式一
[root@linux-node2 ~]# ss -ant | awk 'NR>=2 {++State[$1]} END {for (key in State) print key,State[key]}'
LISTEN 5
ESTAB 7
TIME-WAIT 2

#方式二
[root@linux-node2 ~]# netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
ESTABLISHED 7
TIME_WAIT 3

#各种状态详解
TCP连接状态详解
LISTEN： 侦听来自远方的TCP端口的连接请求
SYN-SENT： 再发送连接请求后等待匹配的连接请求
SYN-RECEIVED：再收到和发送一个连接请求后等待对方对连接请求的确认
ESTABLISHED： 代表一个打开的连接
FIN-WAIT-1： 等待远程TCP连接中断请求，或先前的连接中断请求的确认
FIN-WAIT-2： 从远程TCP等待连接中断请求
CLOSE-WAIT： 等待从本地用户发来的连接中断请求
CLOSING： 等待远程TCP对连接中断的确认
LAST-ACK： 等待原来的发向远程TCP的连接中断请求的确认
TIME-WAIT： 等待足够的时间以确保远程TCP接收到连接中断请求的确认
CLOSED： 没有任何连接状态
```

# 二、查出哪个IP地址连接最多,将其封了

```
[root@linux-node2 ~]# netstat -na|grep ESTABLISHED|awk {'print $5'}|awk -F: {'print $1'}|sort|uniq -c|sort -nr|head -10
    181 192.168.52.112
    164 192.168.52.114
     99 203.90.247.93
     90 203.90.247.79
     86 192.168.52.113
     64 110.87.15.245
     63 27.186.130.18
     59 58.34.9.219
     57 183.52.138.180
     55 223.74.220.205
```
