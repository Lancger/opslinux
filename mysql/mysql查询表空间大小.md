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

