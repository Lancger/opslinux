# 一、安全加固
```
1、禁用root 远程登
PermitRootLogin no #禁用root 登录，创建一个普通用户用作远程登录，然后通过su - 转为root 用户

2、改ssh端口
#Port 22
Port 33389
ListenAddress 172.16.16.118:22
ListenAddress 0.0.0.0:33389
Port 33389 #改到一般扫描器扫到累死才能找到的端口（从20 扫到 36301 … 哈哈）

3、使用密钥认证登录服务器：
vim /etc/ssh/sshd_config

# 通过RSA认证
RSAAuthentication yes

# 允许pubKey（id_rsa.pub）登录
PubkeyAuthentication yes
AuthorizedKeysFile      %h/.ssh/authorized_keys

4、禁止密码方式验证
PasswordAuthentication no #禁止密码方式验证
```

# 二、sshd_config配置
```
Port 33389
ListenAddress 0.0.0.0:22
ListenAddress 0.0.0.0:33389
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
SyslogFacility AUTHPRIV
#PermitRootLogin no    #禁用root 登录
#RSAAuthentication yes #通过RSA认证
PubkeyAuthentication yes
AuthorizedKeysFile      %h/.ssh/authorized_keys
#PasswordAuthentication no #禁止密码方式验证
ChallengeResponseAuthentication no
GSSAPIAuthentication no
GSSAPICleanupCredentials no
UsePAM yes
X11Forwarding yes
UseDNS no
AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
AcceptEnv LC_IDENTIFICATION LC_ALL LANGUAGE
AcceptEnv XMODIFIERS
Subsystem       sftp    /usr/libexec/openssh/sftp-server
```

# 三、测试验证
```
[www@linux-node1 .ssh]# ssh-keygen

Generating public/private rsa key pair.
Enter file in which to save the key (/home/www/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/www/.ssh/id_rsa.
Your public key has been saved in /home/www/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:O+lLbCn0p2wfD5j9GEyMUv3RqbsCMAmUXVmRzdT6GCg root@linux-node1
The key's randomart image is:
+---[RSA 2048]----+
|   ..o ..oo*..   |
|    o . ... o... |
|     . .. ....o  |
|      +.Eo..oo   |
|      ooS.o o+   |
|     . +.X  ...  |
|      . %.B .    |
|       *.+.B .   |
|       .=oo.+    |
+----[SHA256]-----+
[www@linux-node1 .ssh]# ssh-copy-id -p33389 www@192.168.56.11


[www@linux-node1 .ssh]# ssh -i id_rsa -p33389 root@192.168.56.11
Last login: Sun Apr 21 17:26:42 2019 from 192.168.56.12
```
参考文档：

https://www.cnblogs.com/lcword/p/5917321.html
