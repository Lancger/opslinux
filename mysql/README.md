## 一、mysql手册
- [Centos6安装mysql5.6](https://github.com/Lancger/opslinux/blob/master/mysql/install/mysql5.6/centos6-one-install.md)

- [Centos6安装mysql5.7](https://github.com/Lancger/opslinux/blob/master/mysql/install/mysql5.7/Yum方式安装MySQL5.7.md)

- [Centos7安装mysql5.6](https://github.com/Lancger/opslinux/blob/master/mysql/install/mysql5.6/centos7-one-install.md)

- [Centos7安装mysql5.7](https://github.com/Lancger/opslinux/blob/master/mysql/install/mysql5.7/Yum方式安装MySQL5.7.md)

- [Mysql主从架构](https://github.com/Lancger/opslinux/blob/master/mysql/framework/mysql%E4%B8%BB%E4%BB%8E%E6%9E%B6%E6%9E%84.md)

- [Mysql-MHA原理和部署](https://github.com/Lancger/opslinux/blob/master/mysql/framework/Mysql-MHA.md)

- [Mysql架构分享和调优](https://github.com/Lancger/opslinux/blob/master/mysql/framework/MYSQL%E4%BC%81%E4%B8%9A%E5%B8%B8%E7%94%A8%E6%9E%B6%E6%9E%84%E4%B8%8E%E8%B0%83%E4%BC%98%E7%BB%8F%E9%AA%8C%E5%88%86%E4%BA%AB.md)



## 二、修改密码
```
#方式一
/usr/bin/mysqladmin -u root password '123456'

#方式二
mysql> set password=password('123456');


#方式三
mysql> use mysql
mysql> GRANT ALL PRIVILEGES ON *.* TO root@"%" IDENTIFIED BY "root";
mysql> update user set Password = password('123456') where User='root';
mysql> update user set Password = password('123456') where User='root' and Host="127.0.0.1";
mysql> show grants for root@"%";
mysql> flush privileges;
mysql> select Host,User,Password from user where User='root';
mysql> exit

#增加‘127.0.0.1’的登录配置
mysql> select user,host from user;
+-----------------+--------------+
| user            | host         |
+-----------------+--------------+
| mysql.session   | localhost    |
| mysql.sys       | localhost    |
| root            | localhost    |
+-----------------+--------------+

#这里果然没有 ‘127.0.0.1’的登录设置

grant all privileges on *.* to 'root'@'127.0.0.1' identified by 'mysql密码';

flush privileges;
```

## 三、查看表结构和新建库
```
mysql> desc user;

mysql> show create table user\G;

mysql> describe user;

mysql -h 127.0.0.1 -u root -p123456 -e "create database cmdb default character set utf8mb4 collate utf8mb4_unicode_ci;"
```

## 四、查看参数变量
```
mysql> show variables like 'log_error';
+---------------+---------------------+
| Variable_name | Value               |
+---------------+---------------------+
| log_error     | /var/log/mysqld.log |
+---------------+---------------------+
1 row in set (0.01 sec)

mysql> show variables like '%slow%';
+---------------------------+--------------------------+
| Variable_name             | Value                    |
+---------------------------+--------------------------+
| log_slow_admin_statements | OFF                      |
| log_slow_slave_statements | OFF                      |
| slow_launch_time          | 2                        |
| slow_query_log            | ON                       |
| slow_query_log_file       | /var/log/mysqld-slow.log |
+---------------------------+--------------------------+
5 rows in set (0.00 sec)
```
## 五、模拟产生慢日志
```
mysql> show variables like '%quer%';
+----------------------------------------+--------------------------+
| Variable_name                          | Value                    |
+----------------------------------------+--------------------------+
| binlog_rows_query_log_events           | OFF                      |
| ft_query_expansion_limit               | 20                       |
| have_query_cache                       | YES                      |
| log_queries_not_using_indexes          | OFF                      |
| log_throttle_queries_not_using_indexes | 0                        |
| long_query_time                        | 3.000000                 |    --这里设置的超过3秒会记录到慢查询日志
| query_alloc_block_size                 | 8192                     |
| query_cache_limit                      | 1048576                  |
| query_cache_min_res_unit               | 4096                     |
| query_cache_size                       | 1048576                  |
| query_cache_type                       | OFF                      |
| query_cache_wlock_invalidate           | OFF                      |
| query_prealloc_size                    | 8192                     |
| slow_query_log                         | ON                       |    --开启了慢日志查询
| slow_query_log_file                    | /var/log/mysqld-slow.log |    --慢日志文件
+----------------------------------------+--------------------------+
15 rows in set (0.00 sec)

mysql> select sleep(3) as a, 1 as b;    --模拟产生慢日志
+---+---+
| a | b |
+---+---+
| 0 | 1 |
+---+---+
1 row in set (10.00 sec)

#查看慢日志
[root@master log]# cat mysqld-slow.log
/usr/sbin/mysqld, Version: 5.6.41-log (MySQL Community Server (GPL)). started with:
Tcp port: 3306  Unix socket: /var/lib/mysql/mysql.sock
Time                 Id Command    Argument
# Time: 181010 18:52:05
# User@Host: root[root] @ localhost []  Id:     2
# Query_time: 2.001668  Lock_time: 0.000000 Rows_sent: 1  Rows_examined: 0
SET timestamp=1539168725;
select sleep(2) as a, 1 as b;
```

## 六、只安装mysql-client
```
# centos6
rpm -ivh http://repo.mysql.com/mysql-community-release-el6-5.noarch.rpm
yum install -y mysql-client

# centos7
rpm -ivh https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
yum install -y mysql-community-client
```

## 七、修改mysql引擎
```
default-storage-engine = InnoDB

alter table password ENGINE = InnoDB;

alter table password modify column sn varchar(50);

mysql> show variables like "%default%";
+---------------------------------+--------+
| Variable_name                   | Value  |
+---------------------------------+--------+
| default_storage_engine          | InnoDB |
| default_tmp_storage_engine      | InnoDB |
| default_week_format             | 0      |
| explicit_defaults_for_timestamp | OFF    |
+---------------------------------+--------+
4 rows in set (0.00 sec)

```

## 八、查询和删除用户
```
mysql> use mysql;
mysql> select Host,User from user;
+--------------+---------------+
| Host         | User          |
+--------------+---------------+
| %            | root          |
| 192.168.52.% | exchange      |
| 192.168.52.% | root          |
| localhost    | mysql.session |
| localhost    | mysql.sys     |
| localhost    | root          |
+--------------+---------------+


show grants for exchange@"192.168.52.%";
show grants for exchange@"%";

delete from user where Host="localhost";

#msyql不能执行存储过程解决办法
GRANT ALL PRIVILEGES ON *.* TO exchange@"%" IDENTIFIED BY "qaA12!@$#$";
GRANT ALL PRIVILEGES ON *.* TO 'exchange'@'%';
GRANT EXECUTE ON `ichson_lore_source`.* TO 'exchange'@'%';
GRANT SELECT ON `mysql`.`proc` TO 'exchange'@'%';

```

## 九、mysql从库设置只读
```
mysql> set global read_only = 1;
Query OK, 0 rows affected (0.00 sec)

mysql> show variables like '%read_only%';
+------------------+-------+
| Variable_name    | Value |
+------------------+-------+
| innodb_read_only | OFF   |
| read_only        | ON    |
| tx_read_only     | OFF   |
+------------------+-------+
3 rows in set (0.00 sec)

```

## 十、mysql只导出表结构

```
mysqldump --opt -d db_config -u root -p > /tmp/job.sql

```

## 十一、开启binlog
```
show variables like 'log_bin';

# 开启log_bin
log-bin=/data0/mysql_data/mysql-bin
```

## 十二、批量导出部分数据
```
#!/bin/bash
BAKDIR="/tmp/DBbackup"
DBUSER=root
DBPWD=$(/usr/bin/perl -e 'use MIME::Base64; print decode_base64("aaaaaaa")')
HOST="172.18.8.9"
mkdir -p ${BAKDIR}
DS="test"
tbs=`mysql -h${HOST} -u${DBUSER} -p${DBPWD} -D${DS} -e "show tables;" 2>/dev/null |grep -v \+|grep -v Tables_in_change_center`
for ts in ${tbs}
do
  mysql -h${HOST} -u${DBUSER} -p${DBPWD} -A ${DS} -e "SELECT * FROM ${ts} LIMIT 1;" 2>/dev/null > $BAKDIR/${ts}.csv
done
```

## 十三、导出表结构和数据
```
mysqldump -uroot -p123456 change onelevel > onelevel.sql
```

## 十四、在线设置innodb_buffer_pool_size
```
SELECT @@innodb_buffer_pool_size;

SET GLOBAL innodb_buffer_pool_size=4*1024*1024*1024;
```

## 十五、Mysql修改表字段类型
```
mysql> desc orders ;
+-------------+-------------+------+-----+---------+-------+
| Field       | Type        | Null | Key | Default | Extra |
+-------------+-------------+------+-----+---------+-------+
| shipaddress | varchar(20) | YES  | MUL | NULL    |       |
| shipcity    | varchar(20) | YES  |     | NULL    |       |
+-------------+-------------+------+-----+---------+-------+
2 rows in set (0.13 sec)


mysql> alter table orders modify column shipaddress int(20) ;
Query OK, 0 rows affected (0.85 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc orders ;
+-------------+-------------+------+-----+---------+-------+
| Field       | Type        | Null | Key | Default | Extra |
+-------------+-------------+------+-----+---------+-------+
| shipaddress | int(20)     | YES  | MUL | NULL    |       |
| shipcity    | varchar(20) | YES  |     | NULL    |       |
+-------------+-------------+------+-----+---------+-------+
2 rows in set (0.00 sec)
————————————————
```

## 十六、索引

```bash
查看索引  
show index from 数据库表名

PRIMARY KEY（主键索引）
ALTER TABLE `table_name` ADD PRIMARY KEY ( `column` )

UNIQUE(唯一索引)
ALTER TABLE `table_name` ADD UNIQUE (`column`)

INDEX(普通索引)
ALTER TABLE `table_name` ADD INDEX index_name ( `column` )
```
推荐文章:

https://www.cnblogs.com/Dy1an/category/1492870.html mysql文章专题
