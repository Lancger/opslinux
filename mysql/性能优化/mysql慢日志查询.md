## 一、模拟产生慢日志
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

## 二、慢日志输出内容

  ![Mysql慢日志](https://github.com/Lancger/opslinux/blob/master/images/mysql-slow.png)
  
```
第一行：标记日志产生的时间，准确说是 SQL 执行完成的时间点，改行记录每一秒只打印一条。

第二行：客户端的账户信息，两个用户名（第一个是授权账户，第二个为登录账户），客户端 IP 地址，还有mysqld的线程 ID。

第三行：查询执行的信息，包括查询时长，锁持有时长，返回客户端的行数，扫描行数。通常我需要优化的就是最后一个内容，尽量减少 SQL 语句扫描的数据行数。

第四行：通过代码看，貌似和第一行的时间没有区别。

第五话：最后就是产生慢查询的 SQL 语句。

    --log-short-format=true：

如果mysqld启动时指定了--log-short-format参数，则不会输出第一、第二行。

    log-queries-not-using-indexes=on   
    log_throttle_queries_not_using_indexes > 0 :

如果启用了以上两个参数，每分钟超过log_throttle_queries_not_using_indexes配置的未使用索引的慢日志将会被抑制，被抑制的信息会被汇总，每分钟输出一次。

格式如下：
```

  ![Mysql慢日志2](https://github.com/Lancger/opslinux/blob/master/images/mysql-slow2.png)


## 三、mysqldumpslow分析慢日志
```
如何利用MySQL自带的慢查询日志分析工具mysqldumpslow分析日志？

mysqldumpslow –s c –t 10 slow-query.log

具体参数设置如下：
-s 表示按何种方式排序，c、t、l、r分别是按照记录次数、时间、查询时间、返回的记录数来排序，ac、at、al、ar，表示相应的倒叙；
-t 表示top的意思，后面跟着的数据表示返回前面多少条；
-g 后面可以写正则表达式匹配，大小写不敏感。
```

## 四、使用工具分析
```
(3)分析指定时间范围内的查询：

pt-query-digest mysql-slow.log --since '2019-08-07 09:30:00' --until '2019-08-07 12:00:00'


https://www.cnblogs.com/cmsd/p/4872258.html mysql慢查日志分析工具 percona-toolkit
```

参考文档：

https://blog.csdn.net/qq_37788558/article/details/83475005   mysql数据库慢日志基本知识


