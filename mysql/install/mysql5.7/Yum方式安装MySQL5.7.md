在CentOS中默认安装有MariaDB，这个是MySQL的分支，但为了需要，还是要在系统中安装MySQL，而且安装完成之后可以直接覆盖掉MariaDB。

## 1、下载并安装MySQL官方的 Yum Repository
```
chattr -i /etc/passwd* && chattr -i /etc/group* && chattr -i /etc/shadow* && chattr -i /etc/gshadow*

yum list installed | grep mysql
yum -y remove mysql-libs.x86_64

wget -i -c http://dev.mysql.com/get/mysql57-community-release-el7-10.noarch.rpm
yum -y install mysql57-community-release-el7-10.noarch.rpm

yum -y install mysql-community-server

#关闭selinux
[root@master ~]# sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
[root@master ~]# setenforce 0
[root@master ~]# getenforce
Permissive

chattr +i /etc/passwd* && chattr +i /etc/group* && chattr +i /etc/shadow* && chattr +i /etc/gshadow*
```
## 2、my.cnf配置文件
```
cat >/etc/my.cnf << \EOF
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/5.7/en/server-configuration-defaults.html
[client]
port=3306
socket=/var/lib/mysql/mysql.sock
default-character-set=utf8

[mysqld]
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M
basedir=/usr/
datadir=/data0/mysql_data/
socket=/var/lib/mysql/mysql.sock

character_set_server=utf8
init_connect='SET NAMES utf8;set autocommit=1;'

#跳过密码验证登录
#skip-grant-tables

#跳过域名检测
skip-name-resolve

## 开启binlog日志记录
server-id=1
log-bin=/data0/mysql_data/mysql-bin

## 开启慢查询日志记录
slow_query_log=on
slow-query-log-file=/data0/mysql_data/mysqld-slow.log
long_query_time=3

## 主从复制的格式（mixed,statement,row，默认格式是statement）
binlog_format=ROW
max_connections=10000

## 二进制日志自动删除/过期的天数。默认值为0，表示不自动删除。
expire_logs_days=7

## 复制过滤：也就是指定哪个数据库不用同步（mysql、information_schema库一般不同步）
binlog-ignore-db=mysql
binlog-ignore-db=information_schema
default-storage-engine=INNODB

#log_bin_trust_function_creator控制是否可以信任存储函数创建
log_bin_trust_function_creators=1

#设置数据库跟系统时区保持一致
log_timestamps = SYSTEM

lower_case_table_names=1
default-time_zone = '+8:00'
max_allowed_packet=64M
event_scheduler=ON
sql_mode ='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'
## 指定需要同步的数据库
#binlog-do-db=memberdb

## 禁用密码检测插件
#validate_password=OFF

# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
innodb_buffer_pool_size=4G
innodb_flush_log_at_trx_commit=2
wait_timeout=1800

log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
EOF
```

## 3、MySQL目录配置

```
mkdir -p /data0/mysql_data/

#赋权限
chown mysql:mysql /data0/mysql_data/
chown mysql:mysql /var/lib/mysql/

#初始化mysql
默认为
yum安装的mysql默认  --basedir=/usr/

--initialize-insecure    初始化为空密码

#指定配置文件初始化
mysqld --defaults-file=/etc/my.cnf --initialize-insecure --user=mysql

#指定参数初始化
mysql_install_db --user=mysql --basedir=/usr/ --datadir=/data0/mysql_data/
```
    

## 4、MySQL数据库设置
   ```
    1、首先启动MySQL
   
    systemctl start mysqld.service
    systemctl restart mysqld.service
    systemctl enable mysqld.service

    2、查看MySQL运行状态，运行状态如图：
    
    systemctl status mysqld.service

    3、此时MySQL已经开始正常运行，不过要想进入MySQL还得先找出此时root用户的密码，通过如下命令可以在日志文件中找出密码：
    
    grep "password" /var/log/mysqld.log

    4、如下命令进入数据库
    
    mysql -uroot -p
      
    5、输入初始密码，此时不能做任何事情，因为MySQL默认必须修改密码之后才能操作数据库：
    
    mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY '1Qaz2Wsx3Edc!@#';
    mysql> ALTER USER 'root'@'%' IDENTIFIED BY '1Qaz2Wsx3Edc!@#';
    
    这里有个问题，新密码设置的时候如果设置的过于简单会报错：
    
    原因是因为MySQL有密码设置的规范，具体是与validate_password_policy的值有关：
    
    6、MySQL完整的初始密码规则可以通过如下命令查看：
    
      mysql> SHOW VARIABLES LIKE 'validate_password%';
      +--------------------------------------+-------+
      | Variable_name                        | Value |
      +--------------------------------------+-------+
      | validate_password_check_user_name    | OFF   |
      | validate_password_dictionary_file    |       |
      | validate_password_length             | 4     |
      | validate_password_mixed_case_count   | 1     |
      | validate_password_number_count       | 1     |
      | validate_password_policy             | LOW   |
      | validate_password_special_char_count | 1     |
      +--------------------------------------+-------+
      7 rows in set (0.01 sec)

    7、修改密码长度和策略限制
    
    mysql> set global validate_password_policy=0;
    mysql> set global validate_password_length=1;
    
    接下来就可以修改密码了
    
    #方式一
    mysql> set password=password('123456');

    #方式二
    mysql> use mysql
    mysql> GRANT ALL PRIVILEGES ON *.* TO root@"%" IDENTIFIED BY "1Qaz2Wsx3Edc!@#";
    mysql> update user set Password = password('123456') where User='1Qaz2Wsx3Edc!@#';
    mysql> show grants for root@"%";
    mysql> flush privileges;
    mysql> select Host,User,Password from user where User='root';
    mysql> exit
      
    8、但此时还有一个问题，就是因为安装了Yum Repository，以后每次yum操作都会自动更新，需要把这个卸载掉：
     
    yum -y remove mysql57-community-release-el7-10.noarch
     
    大功告成
 ```
 
 # 四、命令行安装
 ```
yum list installed | grep mysql
yum -y remove mysql-libs.x86_64
wget -i -c http://dev.mysql.com/get/mysql57-community-release-el7-10.noarch.rpm
yum -y install mysql57-community-release-el7-10.noarch.rpm
yum -y install mysql-community-server
mkdir -p /data0/mysql_data/
chown mysql:mysql /data0/mysql_data/
chown mysql:mysql /var/lib/mysql/
mysqld --defaults-file=/etc/my.cnf --initialize-insecure --user=mysql
systemctl start mysqld.service
systemctl restart mysqld.service
systemctl enable mysqld.service
 ```
 
# 五、Mysql忘记密码
```
#vim /etc/my.cnf

skip-grant-tables

use mysql;

update user set authentication_string = password("123456") where user="root";

flush privileges;

systemctl restart mysqld
```

# 六、查看事务自动提交

```yaml
set session autocommit=1;

set global autocommit=1;

mysql>  show global variables like 'autocommit';    
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| autocommit    | ON    |
+---------------+-------+
1 row in set (0.00 sec)

mysql>  show variables like 'autocommit';         
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| autocommit    | ON    |
+---------------+-------+
1 row in set (0.00 sec)


https://www.cnblogs.com/kerrycode/p/8649101.html 

注意，上述SQL修改会话系统变量或全局系统变量，只对当前实例有效，如果MySQL服务重启的话，这些设置就会丢失，如果要永久生效，就必须在配置文件中修改系统变量。


```

https://my.oschina.net/marhal/blog/2086091   mysql 开启日志记录并且解决日志时间错误问题 

https://blog.csdn.net/hyy_217/article/details/72781614  mysql5.7日志时间与系统时间不一致

https://blog.csdn.net/wx145/article/details/82740737  关于mysql的参数autocommit
