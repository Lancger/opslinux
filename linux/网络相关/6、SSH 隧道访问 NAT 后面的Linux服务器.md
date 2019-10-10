# 一、ssh反向代理
```
#Nat机器上执行
sshpass -p **2019** ssh -fNR 60021:localhost:22 root@47.10.*.8 -o ExitOnForwardFailure=YES -o ServerAliveInterval=60

将47.10.*.8代理服务器的60021端口转发到Nat机器的本地22端口

#代理
ssh -fNL *:60022:localhost:60021 localhost

代理机器的60022端口转发到代理本身的60021端口，这样我们访问(代理)60022-->>(代理本身)60021--->>Nat(22)

#本地电脑
ssh -p 60022 root@47.10.*.8
```


```
第二步代理服务操作，使用定时任务预置代替
0 1 * * * /bin/sh /opt/scripts/startproxy.sh >> /tmp/run.log

root># cat /opt/scripts/startproxy.sh
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
参考资料：

https://linux.cn/article-5975-1.html  如何通过反向 SSH 隧道访问 NAT 后面的 Linux 服务器

https://serverfault.com/questions/595323/ssh-remote-port-forwarding-failed    SSH remote port forwarding failed
