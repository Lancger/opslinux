# 一、查看当前防火墙状态
 由于LInux原始的防火墙工具iptables过于繁琐，所以ubuntu默认提供了一个基于iptable之上的防火墙工具ufw。
```
安装
sudo apt-get install -y ufw
 
查看当前防火墙状态
sudo ufw status

inactive状态是防火墙关闭状态 
active是开启状态。
```

# 二、开启防火墙
```
开启防火墙 
sudo ufw enable

查看开启防火墙后的状态
sudo ufw status

active 说明防火墙开启成功。

重置所有规则
sudo ufw reset

防火墙重启
sudo ufw reload
```

# 三、关闭防火墙
```
sudo ufw disable

sudo ufw status
如果是inactive 说明我们的防火墙已经关闭掉
```

# 四、常用指令
```
UFW 使用范例：

允许 53 端口

$ sudo ufw allow 53

禁用 53 端口

$ sudo ufw delete allow 53

允许 80 端口

$ sudo ufw allow 80/tcp

禁用 80 端口

$ sudo ufw delete allow 80/tcp

允许 smtp 端口

$ sudo ufw allow smtp

删除 smtp 端口的许可

$ sudo ufw delete allow smtp

允许某特定 IP

$ sudo ufw allow from 192.168.254.254

删除上面的规则

$ sudo ufw delete allow from 192.168.254.254

根据端口删除规则

先查询规则号：

sudo ufw status numbered

然后再根据号来删除

sudo ufw delete 2

```

# 五、脚本
```
sudo apt-get install -y ufw
sudo ufw reset

sudo ufw allow 22/tcp
sudo ufw allow 33389/tcp
sudo ufw allow 9100/tcp
sudo ufw allow from 192.168.52.0/24
sudo ufw allow from 23.244.63.0/24 to any port 8900
sudo ufw allow from 23.244.63.0/24 to any port 8331
sudo ufw allow from 23.244.63.0/24 to any port 8336
sudo ufw allow from 23.244.63.0/24 to any port 12170
sudo ufw default deny
sudo ufw enable
sudo ufw reload

sudo ufw status
```
