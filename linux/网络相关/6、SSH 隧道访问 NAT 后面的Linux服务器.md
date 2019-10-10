```
#Nat机器上执行
sshpass -p **2019** ssh -fNR 60021:localhost:22 root@47.10.*.8 -o ExitOnForwardFailure=YES -o ServerAliveInterval=60

#代理
ssh -fNL *:60022:localhost:60021 localhost

#本地电脑
ssh -p 60022 root@47.10.*.8
```
参考资料：

https://linux.cn/article-5975-1.html  如何通过反向 SSH 隧道访问 NAT 后面的 Linux 服务器

https://serverfault.com/questions/595323/ssh-remote-port-forwarding-failed    SSH remote port forwarding failed
