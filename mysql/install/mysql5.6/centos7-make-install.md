## 一、安装依赖包
```bash
yum install -y gcc gcc-c++ ncurses-devel perl cmake autoconf 
```

## 二、设置MySQL组和用户
```bash
groupadd mysql
useradd -M -s /sbin/nologin -r -g mysql mysql

#useradd -r -g mysql mysql
#passwd mysql
```

## 三、创建所需要的目录
```bash
#新建mysql安装目录
mkdir -p /usr/local/mysql/

#新建mysql数据库数据文件目录
mkdir -p /data/mysql/
```

## 四、下载MySQL源码包并解压
```bash
wget https://cdn.mysql.com//Downloads/MySQL-5.6/mysql-5.6.39.tar.gz
```

## 五、编译安装
```bash
cmake \
-DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DMYSQL_UNIX_ADDR=/usr/local/mysql/mysql.sock \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DMYSQL_DATADIR=/data/mysql/ \
-DMYSQL_TCP_PORT=3306 \
-DENABLE_DOWNLOADS=0
```
    参数解释
 ![mysql5.6编译参数详解](https://github.com/Lancger/opslinux/blob/master/images/mysql5.6-make.png)
    
    注：重新运行配置，需要删除CMakeCache.txt文件

```bash
rm CMakeCache.txt
```
```bash
#编译源码
make

#安装
make install
```
## 六、初始化mysql数据库
```bash
touch /usr/local/mysql/mysqld.log

chown -R mysql.mysql /usr/local/mysql

cd /usr/local/mysql/scripts

./mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/data/mysql
```
    #复制mysql服务启动配置文件
    cp /usr/local/mysql/support-files/my-default.cnf /etc/my.cnf
    
    #复制mysql服务启动脚本及加入PATH路径
    cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld

    vim /etc/profile
    export PATH=/usr/local/mysql/bin:/usr/local/mysql/lib:$PATH

    source /etc/profile

## 七、配置my.cnf
```bash
[client]
port=3306
socket=/usr/local/mysql/mysql.sock
default-character-set=utf8

[mysql]
default-character-set=utf8

[mysqld]
basedir=/usr/local/mysql
datadir=/data/mysql
port=3306
socket=/usr/local/mysql/mysql.sock
pid-file=/usr/local/mysql/mysqld.pid
collation-server=utf8_general_ci
max_connections=1000

character_set_server=utf8
character_set_client=utf8

#跳过密码验证登录
#skip-grant-tables

#slow_query_log=on
#slow-query-log-file=/usr/local/mysql/mysqld-slow.log
#long_query_time=1

server-id=1
log-bin=/data/mysql/mysql-bin

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
log-error=/usr/local/mysql/mysqld.log
pid-file=/usr/local/mysql/mysqld.pid
```

## 八、启动mysql服务并加入开机自启动
```bash
service mysqld start
chkconfig mysqld on
```

## 九、修改密码
```bash
mysqladmin -u root password '123456'

#Mysql赋权限和修改密码
mysql> set password=password('123456');

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
```
