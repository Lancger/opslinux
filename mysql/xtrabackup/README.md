# 一、yum和rpm安装

使用XtraBackup，默认情况下，会对io有影响，不会对线上正在运行的主库有影响，最好配合管道把数据直接送到从库的server

```
yum install pigz -y

#1、Installing Percona XtraBackup from Percona yum repository

yum remove percona-xtrabackup

yum install -y https://repo.percona.com/yum/percona-release-latest.noarch.rpm

yum list | grep percona

yum install -y percona-xtrabackup-24

#2、Installing Percona XtraBackup using downloaded rpm packages

wget https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.4/\
binary/redhat/7/x86_64/percona-xtrabackup-24-2.4.4-1.el7.x86_64.rpm

yum localinstall -y percona-xtrabackup-24-2.4.4-1.el7.x86_64.rpm

```
# 二、主库导出数据
```
#本地导出
innobackupex --default-file=/etc/my.cnf --user=root --password="123456" --stream=tar  /tmp |gzip > /data0/back.tar.gz

#全库导出
innobackupex --default-file=/etc/my.cnf --user=root --password=***** --stream=tar  --tmpdir=/usr/local/mysql_bk/ /usr/local/mysql_bk/  |pigz -p 16 |ssh -i /root/.ssh/id_rsa_new root@192.168.56.100 "pigz -d | tar -xf - -C /data1/mysql"

#指定数据库导出
innobackupex --default-file=/etc/my.cnf --user=root --password=***** --databases=user_storage --stream=tar  --tmpdir=/usr/local/mysql_bk/ /usr/local/mysql_bk/  |pigz -p 16 |ssh -i /root/.ssh/id_rsa_new root@192.168.56.100 "pigz -d | tar -xf - -C /data1/mysql"
```

# 三、从库恢复

```
#查看binlog日志
[root@ mysql]# cat /data1/mysql/xtrabackup_binlog_info
mysql-bin.000002 499886662

#恢复数据
innobackupex --default-file=/etc/my.cnf --apply-log /data1/mysql/

#重新做主从
stop slave;
reset slave;
change master to master_host='172.98.98.182', master_user='repluser', master_password='repluser', master_port=3306, master_log_file='1.000002', master_log_pos=195025061, master_connect_retry=5;
start slave;
show slave status\G;
```


参考文档：

https://www.percona.com/doc/percona-xtrabackup/8.0/installation/yum_repo.html  Installing Percona XtraBackup on Red Hat Enterprise Linux and CentOS


https://www.cnblogs.com/hllnj2008/p/5207066.html  Xtrabackup流备份与恢复

