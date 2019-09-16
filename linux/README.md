## 一、手册
- [虚拟机初始化.md](https://github.com/Lancger/opslinux/blob/master/linux/%E8%99%9A%E6%8B%9F%E6%9C%BA%E5%88%9D%E5%A7%8B%E5%8C%96.md)
- [MegaCli使用手册.md](https://github.com/Lancger/opslinux/blob/master/linux/MegaCli%E4%BD%BF%E7%94%A8%E6%89%8B%E5%86%8C.md)
- [服务器IO高问题分析.md](https://github.com/Lancger/opslinux/blob/master/linux/%E6%9C%8D%E5%8A%A1%E5%99%A8IO%E9%AB%98%E9%97%AE%E9%A2%98%E5%88%86%E6%9E%90.md)
- [常用命令工具集.md](https://github.com/Lancger/opslinux/blob/master/linux/常用命令工具集.md)
- [TCP故障分析.md](https://github.com/Lancger/opslinux/blob/master/linux/常用命令工具集.md)
- [防止ssh暴力破解登录.md](https://github.com/Lancger/opslinux/blob/master/linux/防止ssh暴力破解登录.md)
- [Nginx拉黑处理.md](https://github.com/Lancger/opslinux/blob/master/linux/Nginx%E7%BD%91%E7%AB%99%E4%BD%BF%E7%94%A8CDN%E4%B9%8B%E5%90%8E%E7%A6%81%E6%AD%A2%E7%94%A8%E6%88%B7%E7%9C%9F%E5%AE%9EIP%E8%AE%BF%E9%97%AE%E7%9A%84%E6%96%B9%E6%B3%95.md)


## 二、出口IP
```
#!/bin/sh

ip=$(curl -s https://api.ip.sb/ip)
echo "My IP address is: $ip"
```

## 三、文件上锁
```
chattr -i /var/spool/cron/root
chmod 755  /var/spool/cron
chmod 644  /var/spool/cron/root
chattr +i /var/spool/cron/root
chmod 644 /etc/sysconfig/iptables
chattr +i /etc/sysconfig/iptables
```
