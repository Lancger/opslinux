# 一、设置删除binlog日志
```
1.重启mysql,开启mysql主从，设置expire_logs_days

# vim /etc/my.cnf    //修改expire_logs_days,x是自动删除的天数，一般将x设置为短点，如10
expire_logs_days = 3 //二进制日志自动删除的天数。默认值为0,表示“没有自动删除”

此方法需要重启mysql，附录有关于expire_logs_days的英文说明
```

# 二、不重启mysql方法

```
当然也可以不重启mysql,开启mysql主从，直接在mysql里设置expire_logs_days
> show binary logs;
> show variables like '%log%';
> set global expire_logs_days = 3;
```

# 三、手动清理
```
mysql> show binary logs;
+-------------------+-----------+
| Log_name          | File_size |
+-------------------+-----------+
| master-bin.000730 | 536972901 |
| master-bin.000731 | 536940176 |
| master-bin.000732 | 536875818 |
| master-bin.000733 | 536871791 |
| master-bin.000734 | 536958316 |
| master-bin.000735 | 536887793 |
| master-bin.000736 | 537372016 |
| master-bin.000737 | 536963235 |
| master-bin.000738 | 536874615 |
| master-bin.000739 | 536928013 |
| master-bin.000740 | 409281369 |
+-------------------+-----------+
11 rows in set (0.00 sec)

mysql> purge binary logs to 'master-bin.000732';


```
参考文档：


https://www.cnblogs.com/love123/p/6898568.html

