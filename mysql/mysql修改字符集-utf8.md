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

ALTER TABLE tay_info DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;


mysql> show create table tay_info\G
*************************** 1. row ***************************
       Table: tay_info
Create Table: CREATE TABLE `i_plugin_gray_info` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `plugin` varchar(255) NOT NULL DEFAULT '',
  `config` varchar(255) NOT NULL DEFAULT '',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1    ---  修改前为latin1
1 row in set (0.00 sec)

mysql> ALTER TABLE tay_info DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
Query OK, 0 rows affected (0.00 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> show create table tay_info\G
*************************** 1. row ***************************
       Table: tay_info
Create Table: CREATE TABLE `i_plugin_gray_info` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `plugin` varchar(255) CHARACTER SET latin1 NOT NULL DEFAULT '',
  `config` varchar(255) CHARACTER SET latin1 NOT NULL DEFAULT '',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8     ---  修改后为utf8
1 row in set (0.00 sec)
```
