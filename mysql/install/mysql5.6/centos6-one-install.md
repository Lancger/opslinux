## 一、设置主机host和关闭selinux
```
#设置主机名
[root@localhost ~]# vi /etc/hostname 
master.example.com

#绑定host
cat > /etc/hosts <<EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.56.10 master master.example.com
EOF

#关闭selinux
[root@master ~]# sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
[root@master ~]# setenforce 0
[root@master ~]# getenforce
Permissive
```

## 二、设置yum源
```
#Centos自带的repo是不会自动更新每个软件的最新版本，所以无法通过yum方式安装MySQL的高级版本。所以，即使使劲用yum -y install mysql mysql-server mysql-devel，也是没用的。 所以，正确的安装mysql5姿势是要先安装带有可用的mysql5系列社区版资源的rpm包

#如果是centos6.5的就是用下面的rpm
rpm -Uvh http://repo.mysql.com/mysql-community-release-el6-5.noarch.rpm

#如果是centos6.8的就是用下面的rpm
rpm -Uvh http://repo.mysql.com/mysql-community-release-el6-8.noarch.rpm

#这个时候查看当前可用的mysql安装资源：

yum repolist all | grep mysql

一般来说，只要安装mysql-server跟mysql-client 这个时候我们可以直接使用yum的方式安装MySQL了
```

## 三、通过 Yum 来安装 MySQL
```
1、检查系统是否安装其他版本的MYSQL数据

yum list installed | grep mysql
yum -y remove mysql-libs.x86_64

2、安装及配置
wget http://repo.mysql.com/mysql-community-release-el6-5.noarch.rpm
rpm -ivh mysql-community-release-el6-5.noarch.rpm

yum -y install mysql-community-server
```

## 三、错误提示
```
rpm -Uvh http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm  --使用这个源，会报下面的错误（建议直接使用centos6的源）

如果使用上面的mysql-community-release-el7-5.noarch.rpm包安装的，会报如下错误

#报错

错误：Package: mysql-community-client-5.6.39-2.el7.x86_64 (mysql56-community)
          Requires: libc.so.6(GLIBC_2.17)(64bit)
 You could try using --skip-broken to work around the problem

1、原因应该是centos6应该是el/6，centos应该是el/7的源
    
#解决办法
http://blog.csdn.net/lcyaiym/article/details/77282348

A、删除yum remove "mysql56-community-release-el7.*"

   yum remove "mysql56-community-release-el7.*"

B、清楚缓存yum clean all

   yum clean all   

C、修改mysql-community.repo中baseurl的值

    //修改之前
    vim /etc/yum.repos.d/mysql-community.repo
    
    # enable to use MySQL 5.6
    [mysql56-community]
    name=MySQL 5.6 Community Server
    baseurl=http://repo.mysql.com/yum/mysql-5.6-community/el/7/$basearch/
    enabled=1
    gpgcheck=1
    gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
        
    //修改之后
    # enable to use MySQL 5.6
    [mysql56-community]
    name=MySQL 5.6 Community Server
    baseurl=http://repo.mysql.com/yum/mysql-5.6-community/el/6/$basearch/
    enabled=1
    gpgcheck=1
    gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql     
```

## 四、配置my.cnf
```
[client]
port=3306
socket=/var/lib/mysql/mysql.sock
default-character-set=utf8

[mysql]
default-character-set=utf8

[mysqld]
datadir= /var/lib/mysql
port=3306
socket=/var/lib/mysql/mysql.sock
pid-file=/var/run/mysqld/mysqld.pid
collation-server=utf8_general_ci
max_connections=1000

character_set_server=utf8
character_set_client=utf8

#跳过密码验证登录
#skip-grant-tables

#slow_query_log=on
#slow-query-log-file=/var/log/mysqld-slow.log
#long_query_time=1

server-id=1
log-bin=/var/lib/mysql/mysql-bin

## 主从复制的格式（mixed,statement,row，默认格式是statement）
binlog_format=MIXED

## 二进制日志自动删除/过期的天数。默认值为0，表示不自动删除。
expire_logs_days=7

## 复制过滤：也就是指定哪个数据库不用同步（mysql、information_schema库一般不同步）
binlog-ignore-db=mysql
binlog-ignore-db=information_schema

## 指定需要同步的数据库
#binlog-do-db=memberdb

## 为每个session 分配的内存，在事务过程中用来存储二进制日志的缓存
binlog_cache_size=1M

## Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0

## Recommended in standard MySQL setup
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES

## (注意linux下mysql安装完后是默认：表名区分大小写，列名不区分大小写； 0：区分大小写，1：不区分大小写)
lower_case_table_names=1

[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
```

## 五、启动mysql服务

```
#初始化
mysqld --defaults-file=/etc/my.cnf --initialize-insecure --user=mysql

mysql_install_db --user=mysql --datadir=/usr/local/mysql

/etc/init.d/mysqld start
/etc/init.d/mysqld stop
/etc/init.d/mysqld restart

#设置为开机启动
chkconfig --list | grep mysqld
chkconfig mysqld on
```

## 五、mysql修改密码

### 方法一：
```
/usr/bin/mysqladmin -u root password '123456'

#Mysql赋权限和修改密码
mysql> use mysql;
mysql> grant all privileges on *.* to root@"%" identified by '123456';
Query OK, 0 rows affected, 1 warning (0.01 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)

mysql> show grants for root@"%";
+-------------------------------------------------------------+
| Grants for root@%                                           |
+-------------------------------------------------------------+
| GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION |
+-------------------------------------------------------------+
1 row in set (0.00 sec)

#####################
mysql> update user set Password = password('123456') where User='root' and Host='localhost';
mysql> select Host,User,Password from user where User='root';
mysql> flush privileges;
#####################
```

### 方法二: 安全设置（设置密码）
```
[root@master ~]# mysql_secure_installation

NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MySQL
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MySQL to secure it, we'll need the current
password for the root user.  If you've just installed MySQL, and
you haven't set the root password yet, the password will be blank,
so you should just press enter here.

Enter current password for root (enter for none):   ----输入当前密码，当前为空，直接Enter
OK, successfully used password, moving on...

Setting the root password ensures that nobody can log into the MySQL
root user without the proper authorisation.

Set root password? [Y/n] y        ----设置root密码
New password:    ----123456
Re-enter new password:    ----123456
Password updated successfully!
Reloading privilege tables..
 ... Success!


By default, a MySQL installation has an anonymous user, allowing anyone
to log into MySQL without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] y    ----删除匿名用户
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] n   ----禁止root远程登录
 ... skipping.

By default, MySQL comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] y    ----移除test数据库
 - Dropping test database...
ERROR 1008 (HY000) at line 1: Can't drop database 'test'; database doesn't exist
 ... Failed!  Not critical, keep moving...
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] y    ----重新加载权限
 ... Success!

All done!  If you've completed all of the above steps, your MySQL
installation should now be secure.

Thanks for using MySQL!


Cleaning up...
[root@master ~]#
```

## 六、设置字符集
```
修改 /etc/my.cnf 文件，添加字符集的设置

[mysqld]
character_set_server = utf8

[mysql]
default-character-set = utf8

重启 MySQL ,可以看到字符集已经修改了
```
