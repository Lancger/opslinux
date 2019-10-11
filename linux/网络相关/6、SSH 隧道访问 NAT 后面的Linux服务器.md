# 一、ssh反向代理(Nat机器上执行)
```bash
yum install -y epel-release sshpass autossh

[root@nat_x86 ~]# sshpass -p **passwd** ssh -fNR 60025:localhost:22 root@47.*.90.8 -o ExitOnForwardFailure=YES -o ServerAliveInterval=60 -o StrictHostKeyChecking=no

-R 60025:localhost:22 选项定义了一个反向隧道, 它转发代理服务器 60025 端口的流量到Nat服务器的 22 号端口

用 "-fN" 选项，当你成功通过 SSH 服务器验证时 SSH 会进入后台运行。当你不想在远程 SSH 服务器执行任何命令，就像我们的例子中只想转发端口的时候非常有用。

-o: ssh或scp的一个选项, StrictHostKeyChecking=no表示在第一次主机认证的时候, 自动接收远端主机密钥.
```
# 二、确认隧道是否建立成功(Proxy机器上执行)
```bash
1、#登录到代理服务器，确认其 127.0.0.1:60025 绑定到了 sshd。如果是的话就表示已经正确设置了反向隧道。

[root@proxy_x86 ~]# sudo netstat -nap | grep 60025
tcp        0      0 127.0.0.1:60025             0.0.0.0:*                   LISTEN      22026/sshd  

2、执行本地端口转发
[root@proxy_x86 ~]# ssh -fCNL *:60026:localhost:60025 localhost

代理机器的60026端口为本地转发端口，负责和外网进行通信，并将数据转发到60025这个端口，实现了可以从其他机器访问的功能。同时，*号表示可以接受任何IP的访问。

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
[root@root ~]# ssh -p 60026 root@47.10.*.8
root@47.10.*.8's password:
Last login: Thu Oct 10 20:48:27 2019 from localhost
[root@nat_x86 ~]#
```

# 四、用autossh建立稳定隧道（保证稳定的ssh反向代理隧道，第一步扩展）

不幸的是这种ssh反向链接会因为超时而关闭，如果关闭了那从外网连通内网的通道就无法维持了，为此我们需要另外的方法来提供稳定的ssh反向代理隧道。

```
sshpass -p **passwd** autossh -M 7281 -CNR 60025:localhost:22 root@47.*.90.8

注：使用sshpass，那么autossh不能加-f参数，因为sshpass需要autossh在前台请求密码才能实现输入(这点和expect差不多)，而加上-f参数放后台后会无效，所以若要使用sshpass请务必不要加-f参数，建议使用autossh然后配合-i参数使用用key认证登陆。 最后可以把命令加入开机启动项实现开机启动。

# autossh的参数与ssh的参数是一致的，但是不同的是，在隧道断开的时候，autossh会自动重新连接而ssh不会。另外不同的是我们需要指出的-M参数，这个参数指定一个端口，这个端口是外网的B机器用来接收内网A机器的信息，如果隧道不正常而返回给A机器让他实现重新连接。
```
# 五、一条命令搞定
```
事实上，有一种方法可以只需要登录到中继服务器就能直接访问NAT之后的家庭服务器。要做到这点，你需要让中继服务器上的 sshd 不仅转发回环地址上的端口，还要转发外部主机的端口。这通过指定中继服务器上运行的 sshd 的 GatewayPorts 实现。

打开代理服务器的 /etc/ssh/sshd_config 并添加下面的行。

vim /etc/ssh/sshd_config
#添加
GatewayPorts clientspecified

#最终sshd配置
[root@proxy ~]# cat /etc/ssh/sshd_config |grep -Ev "^#|^$"
Protocol 2
MaxAuthTries 100
MaxSessions 500
ChallengeResponseAuthentication no
GSSAPIAuthentication yes
GSSAPICleanupCredentials yes
UsePAM yes
AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
AcceptEnv LC_IDENTIFICATION LC_ALL LANGUAGE
AcceptEnv XMODIFIERS
X11Forwarding yes
Subsystem       sftp    /usr/libexec/openssh/sftp-server
UseDNS no
AddressFamily inet
PermitRootLogin yes
SyslogFacility AUTHPRIV
PasswordAuthentication yes
GatewayPorts clientspecified

systemctl restart sshd

接下来就可以使用下面命令建立隧道

#nat机器
killall ssh
sshpass -p "**passwd**" ssh -fNR *:10022:localhost:22 root@47.*.90.8 -o ExitOnForwardFailure=YES -o ServerAliveInterval=60 -o StrictHostKeyChecking=no

#本地机器
ssh -p 10022 root@47.*.90.8

#使用autossh
sshpass -p "**passwd**" autossh -M 60025 -CNR *:60026:localhost:22 root@47.*.90.8

ssh -p 60026 root@47.*.90.8
```


参考资料：

https://www.jianshu.com/p/3682e07a2ea3  SSH反向隧道实现内网穿透

https://www.cnblogs.com/kwongtai/p/6903420.html  利用ssh反向代理以及autossh实现从外网连接内网服务器

https://linux.cn/article-5975-1.html  如何通过反向 SSH 隧道访问 NAT 后面的 Linux 服务器

https://serverfault.com/questions/595323/ssh-remote-port-forwarding-failed    SSH remote port forwarding failed

http://www.liutianfeng.com/?p=527  sshpass以及ssh远程交互时候取消输入yes的选项
