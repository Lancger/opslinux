在配置SSH免密码登录的时候，发现配置完成后仍然需要输入密码，查看网络资源，意识到是文件权限问题，但是按照网上的很多博客都不成功。后来发现了问题所在：不止authorized_keys需要修改文件权限，.ssh文件夹的权限也需要修改。而且，如果配置已经完成了，再回头修改文件权限似乎也不能成功。下面介绍可以成功实现免密码登录的操作步骤：

（注：操作系统为CentOS）

1. 首先安装SSH
```
sudo apt-get install openssh-server
```
2. 在根目录下创建.ssh文件，并将文件权限改为700.
```
cd ~

sudo mkdir .ssh

chmod 700 .ssh
```
3. 生成密钥文件（一路回车即可）；生成的密钥文件就保存在.ssh文件夹下。
```
ssh-keygen -t rsa
```
4. 配置单机回环SSH免密码登录：将公钥id_rsa.pub复制一份，重命名为authorized_keys，并将authorized_keys文件权限改为600.
```
sudo cp id_rsa.pub authorized_keys

sudo chmod 600 authorized_keys
```
5. 使用ssh localhost命令检查是否可以免密登录本机。
```
ssh localhost
```

第一次登录的时候需要确认是否连接，输入yes，以后将不再需要输入。 现在我们并不需要输入密码就已经登录成功了。

本博客演示的是本机的免密登录，免密登录其他机器过程类似，可以参考网上的其他教程。唯一需要注意的是权限问题，尤其是.ssh的权限设置。


参考文档：

https://blog.csdn.net/xiaoyi357/article/details/60470593    SSH配置免密码登录后，仍需要输入密码——解决方案
