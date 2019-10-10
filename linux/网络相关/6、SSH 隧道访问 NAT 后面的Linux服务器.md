# 一、ssh反向代理(Nat机器上执行)
```bash
yum install -y epel-release sshpass autossh

[root@nat_x86 ~]# sshpass -p **passwd** ssh -fNR 60025:localhost:22 root@47.*.90.8 -o ExitOnForwardFailure=YES -o ServerAliveInterval=60

-R 60025:localhost:22 选项定义了一个反向隧道, 它转发代理服务器 60025 端口的流量到Nat服务器的 22 号端口

用 "-fN" 选项，当你成功通过 SSH 服务器验证时 SSH 会进入后台运行。当你不想在远程 SSH 服务器执行任何命令，就像我们的例子中只想转发端口的时候非常有用。
```
# 二、确认隧道是否建立成功(Proxy机器上执行)
```bash
1、#登录到代理服务器，确认其 127.0.0.1:60025 绑定到了 sshd。如果是的话就表示已经正确设置了反向隧道。

[root@proxy_x86 ~]# sudo netstat -nap | grep 60025
tcp        0      0 127.0.0.1:60025             0.0.0.0:*                   LISTEN      22026/sshd  

2、执行本地端口转发
[root@proxy_x86 ~]# ssh -fNL *:60026:localhost:60025 localhost

代理机器的60022端口转发到代理本身的60021端口，这样我们访问(代理)60026-->>(代理本身)60025--->>Nat(22)

3、第二步代理服务操作，使用定时任务预置代替

[root@proxy_x86 ~]# crontab -l
0 1 * * * /bin/sh /opt/scripts/startproxy.sh >> /tmp/run.log

[root@proxy_x86 ~]# cat /opt/scripts/startproxy.sh
#!/bin/bash

echo "停止ssh代理服务!!!!"
killall ssh
ps -ef|grep -w sshd|grep -v grep|grep -v "/usr/sbin/sshd"|grep -v "root@pts"|awk '{print $2}'|xargs kill -9

for ((i=60001; i<=60100; i ++))
do
    if test $((i%2)) -eq 0 ; then
        var=`expr $i - 1`
        echo $var
        ssh -fNL *:$i:localhost:$var localhost
    fi
done
```

# 三、本地电脑验证登录
```bash
ssh -p 60026 root@47.10.*.8
```

参考资料：

https://linux.cn/article-5975-1.html  如何通过反向 SSH 隧道访问 NAT 后面的 Linux 服务器

https://serverfault.com/questions/595323/ssh-remote-port-forwarding-failed    SSH remote port forwarding failed
