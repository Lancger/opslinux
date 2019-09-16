## 一、MySQL主从介绍

    1）MySQL主从又叫做Replication、AB复制。简单讲就是A和B两台机器做主从后，在A上写数据，另外一台B也会跟着写数据，两者数据实时同步的

    2）MySQL主从是基于binlog的，主上须开启binlog才能进行主从。
    
    简单来说就是保证主SQL（Master）和从SQL（Slave）的数据是一致性的，向Master插入数据后，Slave会自动从Master把修改的数据同步过来（有一定的延迟），通过这种方式来保证数据的一致性，就是主从复制
    
##### MySQL主从能解决什么问题
    
    一、高可用

    因为数据都是相同的，所以当Master挂掉后，可以指定一台Slave充当Master继续保证服务运行，因为数据是一致性的（如果当插入Master就挂掉，可能不一致，因为同步也需要时间），当然这种配置不是简单的把一台Slave充当Master，毕竟还要考虑后续的Salve同步Master，当然本文并不是将高可用的配置，所以这里就不多讲了

    二、负载均衡

    因为读写分离也算是负载均衡的一种，所以就不单独写了，因为一般都是有多台Slave的，所以可以将读操作指定到Slave服务器上（需要代码控制），然后再用负载均衡来选择那台Slave来提供服务，同时也可以吧一些大量计算的查询指定到某台Slave，这样就不会影响Master的写入以及其他查询
    
    三、数据备份

    一般我们都会做数据备份，可能是写定时任务，一些特殊行业可能还需要手动备份，有些行业要求备份和原数据不能在同一个地方，所以主从就能很好的解决这个问题，不仅备份及时，而且还可以多地备份，保证数据的安全

    四、业务模块化

    可以一个业务模块读取一个Slave，再针对不同的业务场景进行数据库的索引创建和根据业务选择MySQL存储引擎

    五、高扩展（硬件扩展）

    主从复制支持2种扩展方式

    1、scale-up

    向上扩展或者纵向扩展，主要是提供比现在服务器更好性能的服务器，比如增加CPU和内存以及磁盘阵列等，因为有多台服务器，所以可扩展性比单台更大

    2、scale-out

    向外扩展或者横向扩展，是指增加服务器数量的扩展，这样主要能分散各个服务器的压力

##### 主从复制的缺点
    
    一、成本增加

    无可厚非的是搭建主从肯定会增加成本，毕竟一台服务器和两台服务器的成本完全不同，另外由于主从必须要开启二进制日志，所以也会造成额外的性能消耗

    二、数据延迟

    Slave从Master复制过来肯定是会有一定的数据延迟的，所以当刚插入就出现查询的情况，可能查询不出来，当然如果是插入者自己查询，那么可以直接从Master中查询出来，当然这个也是需要用代码来控制的

    三、写入更慢

    主从复制主要是针对读远大于写或者对数据备份实时性要求较高的系统中，因为Master在写中需要更多操作，而且只有一台写入的Master（因为我目前只会配置一台写入Master，最多就是有从Master的Slave，用来在Master挂掉后替换成Master，平时不对外进行服务），所以写入的压力并不能被分散，当然如果直接怎么解决这个问题的话，欢迎留言指教

## 二、MySQL主从原理图如下：

  ![Mysql主从原理图](https://github.com/Lancger/opslinux/blob/master/images/mysql-ab.png)
  
   ##### 复制方式

    MySQL5.6开始主从复制有两种方式：基于日志（binlog）、基于GTID（全局事务标示符）。 
    本文只涉及基于日志binlog的主从配置
    
    ##### 复制类型
    1、基于语句的复制(statement)
    在Master上执行的SQL语句，在Slave上执行同样的语句。MySQL默认采用基于语句的复制，效率比较高。一旦发现没法精确复制时，会自动选着基于行的复制
    2、基于行的复制(row)
    把改变的内容复制到Slave，而不是把命令在Slave上执行一遍。从MySQL5.0开始支持
    3、混合类型的复制(mixed)
    默认采用基于语句的复制，一旦发现基于语句的无法精确的复制时，就会采用基于行的复制
    
    ##### 复制原理,主从过程大致有3个步骤
    1、Master将数据改变记录到二进制日志(binary log)中，也就是配置文件log-bin指定的文件，这些记录叫做二进制日志事件(binary log events) 
    2、Slave通过I/O线程读取Master中的binary log events并写入到它的中继日志(relay log) 
    3、Slave重做中继日志中的事件，把中继日志中的事件信息按顺序一条一条的在本地执行一次，完成数据在本地的存储，从而实现将改变反映到它自己的数据(数据重放)
    
   ##### 主上有一个log dump线程，用来和从的I/O线程传递binlog

   ##### 从上有两个线程，其中I/O线程用来同步主的binlog并生成relaylog，另外一个SQL线程用来把relaylog里面的sql语句落地，其中
    
    binlog  二进制日志

    relaylog  中继日志
    
   ##### 要求

    1、主从服务器操作系统版本和位数一致 
    2、Master和Slave数据库的版本要一致 
    3、Master和Slave数据库中的数据要一致 
    4、Master开启二进制日志，Master和Slave的server_id在局域网内必须唯一

## 三、MySQL主从配置使用场景

    1、将从用于做数据备份

    2、从不仅用于数据备份，而且还用于web客户端读取从上的数据，减轻主读的压力
    
## 四、MySQL主从配置
   
   mysql安装详见：https://github.com/Lancger/opslinux/blob/master/mysql/mysql5.6/centos7-one-install.md
   
   ##### 配置master
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

slow_query_log=on
slow-query-log-file=/var/log/mysqld-slow.log
long_query_time=1

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

   ##### 配置slave
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

slow_query_log=on
slow-query-log-file=/var/log/mysqld-slow.log
long_query_time=1

server-id=2
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

## relay_log配置中继日志
relay_log=/var/lib/mysql/mysql-relay-bin

## 打开自动清除中继日志
relay_log_purge=1

## 防止改变数据(除了特殊的线程)
read_only=1

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
   ################   
   ```
   #主从不一致的地方
   server-id=2
   
   ## relay_log配置中继日志
   relay_log=/var/lib/mysql/mysql-relay-bin

   ## 打开自动清除中继日志
   relay_log_purge=1

   ## 防止改变数据(除了特殊的线程)
   read_only=1 
   ```
   ################

## 五、MySQL主从操作
```
systemctl restart mysqld
systemctl stop mysqld
systemctl status mysqld

#SSH登录到主数据库

mysql -uroot -p123456 -e "show databases"

1、在主数据库上创建用于主从复制的账户(192.168.56.20换成你的从数据库IP,这里有多个从,所以写成%):
mysql> GRANT REPLICATION SLAVE ON *.* TO 'repl'@'192.168.56.%' IDENTIFIED BY 'repl';
mysql> GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' IDENTIFIED BY 'repl';

2、主数据库锁表(禁止再插入数据以获取主数据库的的二进制日志坐标):
mysql> FLUSH TABLES WITH READ LOCK;

3、然后克隆一个SSH会话窗口，在这个窗口打开MySQL命令行:
mysql> SHOW MASTER STATUS;
+------------------+----------+--------------+--------------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB         | Executed_Gtid_Set |
+------------------+----------+--------------+--------------------------+-------------------+
| mysql-bin.000027 |      538 |              | mysql,information_schema |                   |
+------------------+----------+--------------+--------------------------+-------------------+
1 row in set (0.01 sec)

在这个例子中，二进制日志文件是mysql-bin.000027，位置是538，记录下这两个值，稍后要用到。 

4、在主数据库上使用mysqldump命令创建一个数据快照:
mysqldump -uroot -p -h127.0.0.1 -P3306 --all-databases --triggers --routines --events >/tmp/all.sql

--routines, -R   //导出存储过程以及自定义函数。

5、解锁第（2）步主数据的锁表操作:
mysql> UNLOCK TABLES;

6、将备份库同步到从库:
scp /tmp/all.sql 192.168.56.20:/tmp/

#SSH登录到从数据库
1、将备份的数据库导入到slave节点
mysql -uroot -p -h127.0.0.1 -P3306 < /tmp/all.sql   //恢复数据到从库

2、给从数据库设置复制的主数据库信息（注意修改MASTER_LOG_FILE和MASTER_LOG_POS的值

mysql> 
CHANGE MASTER TO MASTER_HOST='192.168.56.10',MASTER_USER='repl',MASTER_PASSWORD='repl',MASTER_LOG_FILE='mysql-bin.000027',MASTER_LOG_POS=538,MASTER_CONNECT_RETRY=5;

3、然后启动从数据库的复制线程
mysql> START SLAVE;

4、接着查询数据库的slave状态
mysql> SHOW SLAVE STATUS \G 
如果下面两个参数都是Yes，则说明主从配置成功！
Slave_IO_Running: Yes
Slave_SQL_Running: Yes 

5、接下来你可以在主数据库上创建数据库、表、插入数据，然后看从数据库是否同步了这些操作。
```

## 六、快速查询主库上有多少个从库
```
root># mysql -uroot -p123456 -e "show slave hosts;"
Warning: Using a password on the command line interface can be insecure.
+-----------+------+------+-----------+--------------------------------------+
| Server_id | Host | Port | Master_id | Slave_UUID                           |
+-----------+------+------+-----------+--------------------------------------+
|         3 |      | 3306 |         1 | 7cf984fe-cc6d-11e8-9290-000c2969912f |
|         2 |      | 3306 |         1 | 7bffa9a7-cc6d-11e8-9290-000c291a36c4 |
+-----------+------+------+-----------+--------------------------------------+
```

参考文档： 

https://my.oschina.net/runforfuture/blog/1627996

https://my.oschina.net/u/3746774/blog/1788963

https://my.oschina.net/ailingling/blog/354277
