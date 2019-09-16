# 一、创建函数报错
```
1、在MySql中创建自定义函数报错信息如下：

ERROR 1418 (HY000): This function has none of DETERMINISTIC, NO SQL, or READS SQL DATA in its declaration and binary logging is enabled (you *might* want to use the less safe log_bin_trust_function_creators variable)


原因：

这是我们开启了bin-log, 我们就必须指定我们的函数是否是

1 DETERMINISTIC 不确定的

2 NO SQL 没有SQl语句，当然也不会修改数据

3 READS SQL DATA 只是读取数据，当然也不会修改数据

4 MODIFIES SQL DATA 要修改数据

5 CONTAINS SQL 包含了SQL语句

 

其中在function里面，只有 DETERMINISTIC, NO SQL 和 READS SQL DATA 被支持。如果我们开启了 bin-log, 我们就必须为我们的function指定一个参数。

 

在MySQL中创建函数时出现这种错误的解决方法：

set global log_bin_trust_function_creators=TRUE;

```

# 二、测试简单函数
```
mysql> create function hello(s char(20))
    -> returns char(50)
    -> return concat('Hello',s,'!');
Query OK, 0 rows affected (0.00 sec)

mysql> select hello('world');
+----------------+
| hello('world') |
+----------------+
| Helloworld!    |
+----------------+
1 row in set (0.00 sec)



SQL code

mysql> show variables like '%func%';

+---------------------------------+-------+

| Variable_name                   | Value |

+---------------------------------+-------+

| log_bin_trust_function_creators | OFF   |

+---------------------------------+-------+

1 row in set (0.00 sec)

 

mysql> set global log_bin_trust_function_creators=1;

Query OK, 0 rows affected (0.00 sec)

 

mysql> show variables like '%func%';

+---------------------------------+-------+

| Variable_name                   | Value |

+---------------------------------+-------+

| log_bin_trust_function_creators | ON    |

+---------------------------------+-------+

1 row in set (0.00 sec)


#mysql的exchange不能执行存储过程解决办法
GRANT EXECUTE ON ichson_lore_source.* TO 'exchange'@'%'; GRANT SELECT ON `mysql`.`proc` TO 'exchange'@'%';
```





参考资料：

https://blog.csdn.net/CiWei007/article/details/15635151    Mysql自定义函数报错解决方法
