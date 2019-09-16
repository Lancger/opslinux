# 一、master操作
```
#安装软件包

yum install -y https://repo.percona.com/yum/percona-release-latest.noarch.rpm

yum install -y percona-xtrabackup-24 pigz

#备份数据远程输出到目标机器

ssh-copy-id root@192.168.52.132

innobackupex --default-file=/etc/my.cnf --user=root --password=123456 --stream=tar  --tmpdir=/usr/local/mysql_bk/ /usr/local/mysql_bk/  |pigz -p 16 |ssh root@192.168.52.132 "pigz -d | tar -xf - -C /data0/mysql_data"

#指定数据库
innobackupex --default-file=/etc/my.cnf --user=root --password=123456 --databases=change_center --stream=tar  --tmpdir=/usr/local/mysql_bk/ /usr/local/mysql_bk/  |pigz -p 4 |ssh root@192.168.52.132 "pigz -d | tar -xf - -C /data0/mysql"

# 创建从库账号

GRANT REPLICATION SLAVE ON *.* TO 'repluser'@'192.168.52.%' IDENTIFIED BY 'repluser';

FLUSH PRIVILEGES;

show grants for repluser@"192.168.52.%";

#备份到本地
innobackupex --default-file=/etc/my.cnf --user=root --password=123456 –no-timestamp --stream=tar /tmp |gzip > /data0/bak.tar

```

# 二、salve操作

```
#安装软件包

yum install -y https://repo.percona.com/yum/percona-release-latest.noarch.rpm

yum install -y percona-xtrabackup-24 pigz

#恢复数据到从库目录

innobackupex --default-file=/etc/my.cnf --apply-log /data0/mysql_data

GRANT REPLICATION SLAVE ON *.* TO 'repl'@'192.168.56.%' IDENTIFIED BY 'repl';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' IDENTIFIED BY 'repl';

#修改目录权限

chown -R mysql:mysql /data0/mysql_data

systemctl restart mysqld

mysql -uroot -p'123456'

use aud2;

select count('id') from test_while;

#重建主从
stop slave;

reset slave;

change master to master_host='192.168.52.88', master_user='repluser', master_password='repluser', master_port=3306, master_log_file='1.000002', master_log_pos=195025061, master_connect_retry=5;

start slave;

show slave status\G;
```

# 三、新机器操作
```
systemctl stop mysqld

cd /data0/mysql_data/

rm -rf /data0/mysql_data/*

```
