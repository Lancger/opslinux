# 第一种
```
1.查询是否锁表
mysql> show OPEN TABLES where In_use > 0;
+-------------+-----------------------+--------+-------------+
| Database    | Table                 | In_use | Name_locked |
+-------------+-----------------------+--------+-------------+
| iaas_center | i_miner_app_bandwidth |      2 |           0 |
| iaas_center | i_miner_basic_info    |      2 |           0 |
+-------------+-----------------------+--------+-------------+
2 rows in set (0.00 sec)

2.查询进程（如果您有SUPER权限，您可以看到所有线程。否则，您只能看到您自己的线程）
show processlist;

3.杀死进程id（就是上面命令的id列）
kill id
```

# 第二种
```
1.查看下在锁的事务 
SELECT * FROM INFORMATION_SCHEMA.INNODB_TRX;

2.杀死进程id（就是上面命令的trx_mysql_thread_id列）
kill 线程ID

例子：
查出死锁进程：SHOW PROCESSLIST  

杀掉进程          KILL 420821;

其它关于查看死锁的命令：
1：查看当前的事务
SELECT * FROM INFORMATION_SCHEMA.INNODB_TRX;

2：查看当前锁定的事务
SELECT * FROM INFORMATION_SCHEMA.INNODB_LOCKS;

3：查看当前等锁的事务 SELECT * FROM INFORMATION_SCHEMA.INNODB_LOCK_WAITS;

mysql> show variables like 'innodb_lock_wait_timeout';
+--------------------------+-------+
| Variable_name            | Value |
+--------------------------+-------+
| innodb_lock_wait_timeout | 50    |
+--------------------------+-------+


set global innodb_lock_wait_timeout=200;
```
参考资料：

https://www.cnblogs.com/chancy/p/10701739.html   mysql查看死锁和解除锁
