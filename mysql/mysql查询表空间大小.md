# 一、mysql查询表空间大小

```
mysql> SELECT table_name AS "Tables", round(((data_length + index_length) / 1024 / 1024), 2) "Size in MB" FROM information_schema.TABLES WHERE table_schema = 'mc_data' ORDER BY (data_length + index_length) DESC;
+-------------------------------+------------+
| Tables                        | Size in MB |
+-------------------------------+------------+
| t_event_log_07     |  280794.92 |
| t_event_log_05     |  173382.89 |
| t_event_log_06     |   64007.89 |
| t_event_log_03     |   38144.98 |
| t_event_log_04     |   28231.97 |
| t_event_log        |    6147.95 |


清理数据
TRUNCATE TABLE  t_event_log_07; 
```

# 二、

```bash
SELECT
  TABLE_NAME,
  DATA_LENGTH,
  INDEX_LENGTH,
  (DATA_LENGTH + INDEX_LENGTH) AS LENGTH,
  TABLE_ROWS,
  CONCAT (ROUND ((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 3), 'MB') AS total_size
FROM
  information_schema.TABLES
WHERE TABLE_SCHEMA = 'db_name' -- 库名
  AND table_name = 'table_name' -- 表名
ORDER BY LENGTH DESC;

+--------------------------+-------------+--------------+-------------+------------+-------------+
| TABLE_NAME               | DATA_LENGTH | INDEX_LENGTH | LENGTH      | TABLE_ROWS | total_size  |
+--------------------------+-------------+--------------+-------------+------------+-------------+
| xxl_job_qrtz_trigger_log | 11020533760 |            0 | 11020533760 |   20251746 | 10510.000MB |
+--------------------------+-------------+--------------+-------------+------------+-------------+
1 row in set (0.00 sec)

查出来的结果如下，可以看到这张表占用的空间大小为：10510 MB
```

https://codeantenna.com/a/LDEfzyehZM  MySQL——查询某个表占用的空间大小以及表的数据量

https://blog.csdn.net/sageyin/article/details/115702013  Mysql：查看Mysql表占用的空间大小
