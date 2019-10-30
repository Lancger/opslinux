# 一、innobackupex
```
innobackupex --default-file=/etc/my.cnf --user=root --database="cloud_storage" --stream=tar --tmpdir=/usr/local/mysql_bk/   /usr/local/mysql_bk/  |gzip - > /usr/local/mysql_bk/mysql_20190514070000.tar.gz


innobackupex --default-file=/etc/my.cnf --user=root --password=xxxx --stream=tar --tmpdir=/usr/local/mysql_bk/ /usr/local/mysql_bk/  |pigz -p 16 |ssh root@192.168.99.52  "cat - > /usr/local/mysql_bk/mysql_20190514200000.tar.gz"


gh-ost --user="root" --password="xxxxxx" --host=127.0.0.1  --database="coredump_log" --table="coredump_log_1"  --alter="engine innodb" --allow-on-master --execute


#查看表数量
mysql> select count('id') from i_miner_basic_info;
+-------------+
| count('id') |
+-------------+
|     2020744 |
+-------------+
1 row in set (0.41 sec)

gh-ost --user="root" --password="***" --host=127.0.0.1  --database="pass_center" --table="i_miner_basic_info"  --alter="add device_type TINYINT(3) UNSIGNED NOT NULL DEFAULT '1' COMMENT '设备类型 1:cloud 2:qt 3:clud_cash 4:x86'" --allow-on-master --initially-drop-ghost-table --execute

```

# 二、备份脚本
```
#!/bin/bash

backup_dir=/usr/local/mysql_backup/
file=mysql_$(date +'%Y%m%d%H%M').tar.gz
log=backup_$(date +'%Y%m%d%H%M').log
log_expire_days=1
#####################################################################
echo "start purging " > $backup_dir$log

find $backup_dir -type f -name "mysql_*.tar.gz" -ctime +$log_expire_days -exec ls {} \; >> $backup_dir$log
find $backup_dir -type f -name "mysql_*.tar.gz" -ctime +$log_expire_days -exec rm -f {} \;

find $backup_dir -type f -name "backup_*.log" -ctime +$log_expire_days -exec ls {} \; >> $backup_dir$log
find $backup_dir -type f -name "backup_*.log" -ctime +$log_expire_days -exec rm -f {} \;

echo "purge done" >> $backup_dir$log

#####################################################################
echo "start mysql backup" >> $backup_dir$log

innobackupex --default-file=/etc/my.cnf --user=root --slave-info --stream=tar $backup_dir |pigz -p 16  > $backup_dir$file  

if [ $? = 0 ] 
then
  echo "succeed" >>$backup_dir$log
else
  echo "Error" >>$backup_dir$log
fi
```

# 三、定时任务
```
# mysql_bakcup
0 2 * * * /usr/local/mysql/mysql_backup.sh /dev/null 2>&1
```
参考文档：

https://www.cnblogs.com/zhoujinyi/p/9187421.html   MySQL在线DDL gh-ost 使用说明 
