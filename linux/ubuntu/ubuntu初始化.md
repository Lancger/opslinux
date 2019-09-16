# 一、软件更新
```
1、升级系统补丁，注意顺序不可颠倒，也不可省略update

#更新整个仓库的版本信息

sudo apt update -y

#升级软件包
sudo apt upgrade -y

#自动清理旧版本的安装包

sudo apt autoclean -y

#删除包缓存中的所有包,多数情况下这些包没有用了,网络条件好的话，可以使用。

sudo apt clean -y


2、安装和配置SSH，防火墙配置

#安装install openssh-server
sudo apt install openssh-server -y

#允许root用户登录
sudo sed -i 's/prohibit-password/yes/' /etc/ssh/sshd_config

#刚才修改配置了，重启一下服务
sudo systemctl restart sshd

#防火墙允许ssh协议通过，不然远程没法连接SSH服务，当然你也不想直接关闭防火墙吧！用这个就安全点。
sudo ufw allow ssh

#启动防火墙

sudo ufw enable
```

3、Linux系统，切换用户后只显示$问题
```
useradd www -m -d /home/www
```

4、Linux系统，切换用户后只显示$问题
```
将sh改成bash就可以了

www:x:1001:1001::/home/www:/bin/bash
```


# 二、修改主机名

```
https://www.cnblogs.com/zeusmyth/p/6231350.html

vim /etc/hostname
```


# 三、脚本
```
sudo apt update -y
sudo apt upgrade -y
sudo apt install openssh-server ssh -y
sudo ufw allow ssh
sudo ufw enable
sudo ufw status
cat > /etc/hostname << EOF
hk-ubuntu-188
EOF
hostname hk-ubuntu-188


useradd www -m -d /home/www

vim /root/.bashrc

vim /etc/profile

export PS1="\[\e]0;\a\]\n\[\e[1;32m\]\[\e[1;33m\]\H\[\e[1;35m\]<\$(date +\"%Y-%m-%d %T\")> \[\e[32m\]\w\[\e[0m\]\n\u>\\$ "

```

# 四、sshd配置
```
cat > /etc/ssh/sshd_config << \EOF
Port 33389
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_dsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
UsePrivilegeSeparation yes
KeyRegenerationInterval 3600
ServerKeyBits 1024
SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 120
PermitRootLogin yes
StrictModes yes
RSAAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile      %h/.ssh/authorized_keys
IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
UsePAM yes
EOF


systemctl restart sshd
```

# 五、防火墙配置
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

参考文档：

https://blog.csdn.net/longhr/article/details/51669449

https://blog.csdn.net/qq_25844137/article/details/80841451  Linux系统，切换用户后只显示$问题
