# Centos7 yum install redis

## 直接yum 安装的redis 不是最新版本

    yum install redis

## 如果要安装最新的redis，需要安装Remi的软件源，官网地址：http://rpms.famillecollet.com/

    yum install -y http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

## 然后可以使用下面的命令安装最新版本的redis：

    yum --enablerepo=remi install redis

## 安装完毕后，即可使用下面的命令启动redis服务

    service redis start
    或者
    systemctl start redis

 ## redis安装完毕后，我们来查看下redis安装时创建的相关文件，如下：

    rpm -qa |grep redis

    rpm -ql redis

    查看redis版本：

    redis-cli --version

 

## 设置为开机自动启动：

    chkconfig redis on
    或者
    systemctl enable redis.service

## Redis开启远程登录连接，redis默认只能localhost访问，所以需要开启远程登录。解决方法如下：

    在redis的配置文件/etc/redis.conf中

    将bind 127.0.0.1 改成了 bind 0.0.0.0

    然后要配置防火墙 开放端口6379

    连接redis

    redis-cli


https://www.cnblogs.com/autohome7390/p/6433956.html

https://www.cnblogs.com/qianxiaoruofeng/p/8046570.html

