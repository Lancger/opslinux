```
mysql> SET GLOBAL innodb_buffer_pool_size = 8589934592;
Query OK, 0 rows affected (0.63 sec)

mysql> show variables like 'innodb_buffer_pool%';
+-------------------------------------+----------------+
| Variable_name                       | Value          |
+-------------------------------------+----------------+
| innodb_buffer_pool_chunk_size       | 134217728      |
| innodb_buffer_pool_dump_at_shutdown | ON             |
| innodb_buffer_pool_dump_now         | OFF            |
| innodb_buffer_pool_dump_pct         | 25             |
| innodb_buffer_pool_filename         | ib_buffer_pool |
| innodb_buffer_pool_instances        | 8              |
| innodb_buffer_pool_load_abort       | OFF            |
| innodb_buffer_pool_load_at_startup  | ON             |
| innodb_buffer_pool_load_now         | OFF            |
| innodb_buffer_pool_size             | 8589934592     |
+-------------------------------------+----------------+
10 rows in set (0.00 sec)


mysql> show variables like 'innodb_lru_scan_depth%';
+-----------------------+-------+
| Variable_name         | Value |
+-----------------------+-------+
| innodb_lru_scan_depth | 1024  |
+-----------------------+-------+
1 row in set (0.00 sec)

mysql> SET GLOBAL innodb_lru_scan_depth=256;
Query OK, 0 rows affected (0.00 sec)
```

# 二、修改默认超时时间
```
#在线修改
mysql> set  global wait_timeout=1800;
Query OK, 0 rows affected (0.00 sec)

mysql> show global variables like 'wait_timeout';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| wait_timeout  | 1800  |
+---------------+-------+
1 row in set (0.01 sec)

#配置文件修改
wait_timeout=1800
```

参考文档：

https://zeven0707.github.io/2018/08/21/InnoDB-page_cleaner-1000ms%20intended%20loop%20took%20xxxms/  [Mysql] InnoDB：page_cleaner：1000ms intended loop took xxxms
