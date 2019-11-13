`使用XtraBackup，默认情况下，会对io有影响，不会对线上正在运行的主库有影响，最好配合管道把数据直接送到从库的server`

# 一、从库操作

1、清理主从失败从库的数据

```bash
/etc/init.d/mysqld stop
rm -rf /data/mysql/
```

# 二、主库操作

1、同步到失败的从库服务器对应的mysql存储目录
```bash
#先在主库创建一个同步账号
GRANT REPLICATION SLAVE ON *.* TO 'repluser'@'192.168.56.%’ IDENTIFIED BY 'repluser';
FLUSH PRIVILEGES;
SHOW GRANTS for repluser@"192.168.56.%";

#主库远程同步数据到从库(这里有2个失败的从库)
innobackupex --default-file=/etc/my.cnf --user=root --password=123456 --stream=tar /usr/local/mysql_bk/ |pigz -p 20 |ssh root@192.168.56.121 "pigz -d | tar -xf - -C /data/mysql"
innobackupex --default-file=/etc/my.cnf --user=root --password=123456 --stream=tar /usr/local/mysql_bk/ |pigz -p 20 |ssh root@192.168.56.153 "pigz -d | tar -xf - -C /data/mysql"
```
# 三、从库操作

```bash
#恢复数据
innobackupex --default-file=/etc/my.cnf --apply-log /data/mysql
chown -R mysql:mysql  /data/mysql/
/etc/init.d/mysqld start

#查看binlog
cat xtrabackup_binlog_info
mysql-bin.000804        723895860

#重装主从
mysql -h127.0.0.1 -uroot -psd-9898w

stop slave;
reset slave;
change master to master_host='192.168.56.120', master_user='repluser', master_password='repluser', master_port=3306, master_log_file='mysql-bin.000804', master_log_pos=723895860, master_connect_retry=5;
start slave;
show slave status\G;

#设置从库只读
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
