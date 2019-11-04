# 修改前
```
mysql> show variables like 'character%';
+--------------------------+----------------------------+
| Variable_name            | Value                      |
+--------------------------+----------------------------+
| character_set_client     | utf8                       |
| character_set_connection | utf8                       |
| character_set_database   | latin1                     |
| character_set_filesystem | binary                     |
| character_set_results    | utf8                       |
| character_set_server     | latin1                     |
| character_set_system     | utf8                       |
| character_sets_dir       | /usr/share/mysql/charsets/ |
+--------------------------+----------------------------+
8 rows in set (0.00 sec)
```

# 修改后
```
set character_set_database=utf8;
set character_set_server=utf8;  #默认数据库使用的字符集
set names utf8;  #设定数据库编码格式

mysql> set character_set_database=utf8;
Query OK, 0 rows affected (0.00 sec)

mysql> set character_set_server=utf8;
Query OK, 0 rows affected (0.00 sec)

mysql> set names utf8;
Query OK, 0 rows affected (0.00 sec)

mysql> show variables like 'character%';
+--------------------------+----------------------------+
| Variable_name            | Value                      |
+--------------------------+----------------------------+
| character_set_client     | utf8                       |
| character_set_connection | utf8                       |
| character_set_database   | utf8                       |
| character_set_filesystem | binary                     |
| character_set_results    | utf8                       |
| character_set_server     | utf8                       |
| character_set_system     | utf8                       |
| character_sets_dir       | /usr/share/mysql/charsets/ |
+--------------------------+----------------------------+
8 rows in set (0.00 sec)
```
# 配置文件修改
```
[client]
default-character-set=utf8

[mysqld]
character-set-server=utf8

```

# 修改已有表的字符集
```
ALTER TABLE 表名 DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

ALTER TABLE test DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
```
