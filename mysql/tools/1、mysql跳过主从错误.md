# 一、跳过主从
```
stop slave;
set global sql_slave_skip_counter =1;
start slave;
show slave status\G;
```

# 二、从库设置只读
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


参考资料：

https://blog.csdn.net/hardworking0323/article/details/81046408
