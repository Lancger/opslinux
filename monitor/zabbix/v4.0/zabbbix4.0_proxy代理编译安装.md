# 一、搭建环境介绍

```
centos 7 ：8核16G 100G固态硬盘

内网地址：192.168.30.38

```

# 二、部署方法
```
1、创建用户

groupadd zabbix

useradd -g zabbix -M -s /sbin/nologin zabbix

2、更新依赖包

yum -y install mysql-devel curl curl-devel net-snmp net-snmp-devel

3、更改主机名

hostnamectl set-hostname zabbix_proxy

192.168.30.38 zabbix_proxy
127.0.0.1 zabbix_proxy

4、下载安装包

wget https://jaist.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/3.2.11/zabbix-3.2.11.tar.gz


5、源码安装proxy服务

tar -zxf zabbix-3.2.11.tar.gz

cd zabbix-3.2.11

./configure --prefix=/usr/local/zabbix-proxy --enable-proxy --enable-agent --with-mysql --with-net-snmp --with-libcurl && make && make install && ll

cd /usr/local/zabbix-proxy/etc/ && mv zabbix_proxy.conf zabbix_proxy.conf.bak && vi zabbix_proxy.conf
```

参考资料

https://blog.csdn.net/saga_gallon/article/details/83215037  zabbix_proxy代理服务器搭建教程
