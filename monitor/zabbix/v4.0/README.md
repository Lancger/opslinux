# ZABBIX 4.0 LTS+Grafana5.3部署

## 一、概述
### 1、Zabbix 4.0 LTS
    2018年10月1日，Zabbix官方正式发布Zabbix 4.0 LTS版本，作为长期支持版本，意味着可以获得官方5年的支持。其中完全支持到2021年10月31日，以及有限支持到2023年10月31日，同时官方4.0文档已经更新。
    最直观的感受就是重新设计了图形展示，新增了Kiosk模式实现真正意义上的全屏，可以直接做大屏展示，时间选择器做的和Kibana类似；
    Zabbix 4.0 LTS对分布式监控Proxy方式也做了优化，引入了与Proxy通信的压缩，大大减少了传输数据的大小。从而提高了性能。

    Zabbix 4.0 LTS 详细了解优化及新增功能参考如下:
    新增功能:https://www.zabbix.com/whats_new
    官方文档:https://www.zabbix.com/documentation/4.0/manual

### 2、Grafana5.3

    Grafana v5.3带来了新功能，许多增强功能和错误修复。
    Google Stackdriver作为核心数据源;
    电视模式得到改善，更易于访问
    提醒通知提醒;
    Postgres获得了一个新的查询构建器;
    改进了对Gitlab的OAuth支持;
    带模板变量过滤的注释;
    具有自由文本支持的变量。

    Grafana5.3 详细了解优化及新增功能参考如下:
    新增功能:http://docs.grafana.org/guides/whats-new-in-v5-3/
    
### 3、部署环境准备
    操作系统: CentOS Linux release 7.5.1804 (Core) 
    软件版本: zabbix-release-4.0-1.el7.noarch.rpm
    数据库: mysql 5.6.41
    grafana版本: grafana-5.3.0-1.x86_64.rpm

## 二、安装及配置 Zabbix server

### 1. Install Repository with MySQL database
    cd /tmp
    version="4.2-1"
    wget https://repo.zabbix.com/zabbix/4.2/rhel/7/x86_64/zabbix-release-${version}.el7.noarch.rpm
    yum -y install zabbix-release-${version}.el7.noarch.rpm

### 2. 安装Zabbix server, frontend, agent
    yum -y install zabbix-server-mysql zabbix-web-mysql zabbix-agent

### 3. mysql5.6安装及配置数据库

    centos自带的repo是不会自动更新每个软件的最新版本，所以无法通过yum方式安装MySQL的高级版本。
    安装mysql5姿势是要先安装带有可用的mysql5系列社区版资源的rpm包
    cd /tmp
    wget http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
    yum -y install mysql-community-release-el7-5.noarch.rpm

    查看当前可用的mysql安装资源
    yum list
    yum repolist enabled | grep "mysql.*-community.*"

    mysql-connectors-community/x86_64 MySQL Connectors Community                  65
    mysql-tools-community/x86_64      MySQL Tools Community                       69
    mysql56-community/x86_64          MySQL 5.6 Community Server                 412

    使用yum的方式安装MySQL
    yum -y install mysql-community-server

    启动mysql并设置开机启动
    systemctl enable mysqld
    systemctl start mysqld

    mysql -uroot -p
    password
    mysql> create database zabbix character set utf8 collate utf8_bin;
    mysql> grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';
    mysql> quit;

    将zabbix数据表导入数据库中
    zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p zabbix

### 4.配置数据库zabbix server
    vim /etc/zabbix/zabbix_server.conf 
    DBPassword=zabbix
    
    Timeout=30
    
    如果修改了mysql默认的socket文件需要做以下操作
    ln -s /data0/mysql_data/mysql.sock /var/lib/mysql/mysql.sock

### 5.编辑Zabbix前端PHP配置,更改时区
    vim /etc/httpd/conf.d/zabbix.conf
    php_value date.timezone Asia/Shanghai

### 6.启动zabbix-server zabbix-agent httpd 并设置开机启动
    systemctl restart zabbix-server zabbix-agent httpd
    systemctl enable zabbix-server zabbix-agent httpd

    http://192.168.56.100/zabbix/setup.php

  ![zabbux4.0-1.png](https://github.com/Lancger/opslinux/blob/master/images/mysql-ab.png)

# 三、zabbix_agentd配置

Centos7系统
```
cd /tmp
version="4.2-1"
wget https://repo.zabbix.com/zabbix/4.2/rhel/7/x86_64/zabbix-release-${version}.el7.noarch.rpm
yum -y install zabbix-release-${version}.el7.noarch.rpm

yum -y install zabbix-agent

cat > /etc/zabbix/zabbix_agentd.conf << \EOF
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
DebugLevel=2
Server=192.168.52.103
ServerActive=192.168.52.103
Timeout=30
EnableRemoteCommands=1
UnsafeUserParameters=1
HostnameItem=system.run[echo $(hostname)]
HostMetadataItem=system.uname
Include=/etc/zabbix/zabbix_agentd.d/*.conf
EOF


systemctl restart zabbix-agent
systemctl enable zabbix-agent
```
Ubuntu系统
```
cd /tmp
wget https://repo.zabbix.com/zabbix/4.0/debian/pool/main/z/zabbix-release/zabbix-release_4.0-2%2Bstretch_all.deb
dpkg -i zabbix-release_4.0-2+stretch_all.deb

apt-get install -y zabbix-agent

cat > /etc/zabbix/zabbix_agentd.conf << \EOF
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix-agent/zabbix_agentd.log
LogFileSize=0
DebugLevel=2
Server=192.168.52.103
ServerActive=192.168.52.103
Timeout=30
EnableRemoteCommands=1
UnsafeUserParameters=1
HostnameItem=system.run[echo $(hostname)]
HostMetadataItem=system.uname
Include=/etc/zabbix/zabbix_agentd.conf.d/*.conf
EOF

service zabbix-agent restart
update-rc.d zabbix-agent enable

ufw allow 10050/tcp
```

# 四、安装grafana-zabbix插件

https://grafana.com/plugins/alexanderzobnin-zabbix-app/installation
```
1、下载及安装

cd /usr/local/src/

export VER="6.2.4"
wget https://dl.grafana.com/oss/release/grafana-${VER}-1.x86_64.rpm
yum localinstall -y grafana-${VER}-1.x86_64.rpm

2、启动服务

systemctl daemon-reload
systemctl enable grafana-server.service
systemctl restart grafana-server.service

3、访问WEB界面

默认账号/密码：admin/admin http://192.168.56.11:3000

4、Grafana添加数据源

在登陆首页，点击"Configuration-Data Sources"按钮，跳转到添加数据源页面，配置如下：
Name: prometheus
Type: prometheus
URL: http://192.168.56.11:9090
Access: Server
取消Default的勾选，其余默认，点击"Add"，如下：


5、使用grafana-cli工具安装

获取可用插件列表
grafana-cli plugins list-remote
 
安装zabbix插件
grafana-cli plugins install alexanderzobnin-zabbix-app
 
安装插件完成之后重启garfana服务
service grafana-server restart

#使用grafana-zabbix-app源，其中包含最新版本的插件
 
cd /var/lib/grafana/plugins/
#克隆grafana-zabbix-app插件项目
 
git clone https://github.com/alexanderzobnin/grafana-zabbix-app
#注：如果没有git，请先安装git
 
yum –y install git
# 插件安装完成重启garfana服务
 
service grafana-server restart

#注：通过这种方式，可以很容易升级插件
 
cd /var/lib/grafana/plugins/grafana-zabbix-app
git pull
service grafana-server restart
```

```
修改图形为饼状，需要下载另一个grafana-piechart-panel
https://grafana.com/plugins/grafana-piechart-panel
--------------------------------------------------
grafana-cli plugins install grafana-piechart-panel
---------------------------------------------------
安装其他图形插件
grafana-cli plugins install grafana-clock-panel
#钟表形展示
grafana-cli plugins install briangann-gauge-panel
#字符型展示
grafana-cli plugins install natel-discrete-panel
#服务器状态
grafana-cli plugins install vonage-status-panel
```


参看文档：
https://blog.csdn.net/xiegh2014/article/details/83045412

https://www.cnblogs.com/kevingrace/p/7108060.html   分布式监控系统Zabbix--使用Grafana进行图形展示
