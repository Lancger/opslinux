```
#!/bin/bash
BAKDIR="/data0/DBbackup"
DBUSER=root
DBPWD=$(/usr/bin/perl -e 'use MIME::Base64; print decode_base64("jTQ==")')
HOST="127.0.0.1"
mkdir -p ${BAKDIR}
dbs=`/usr/bin/mysql -h${HOST} -u${DBUSER} -p${DBPWD} -e "show databases;" |grep -v \+ |grep -v Database |grep -v mysql | grep -v test |grep -v sys |grep -v information_schema |grep -v performance_schema`
for db in ${dbs}
do
  /usr/bin/mysqldump -u${DBUSER} -p${DBPWD} -h${HOST} --opt --single-transaction --master-data=2 -R ${db} |gzip >"${BAKDIR}"/${db}_`date +%F-%H:%M`.sql.gz
  if [ $? -eq 0 ]
  then
    count=`ls -lrt ${BAKDIR} |grep "${db}_.*\.sql.gz" |wc -l`
    if [ ${count} -gt 3 ]
    then
       del_count=$[ count - 3 ]
       ls -lrt  ${BAKDIR} |grep "${db}_.*\.sql.gz" |awk '{print $9}'|sed -n "1,${del_count}p" >/tmp/del_sql.log       
       cd ${BAKDIR} 
       for i in `cat /tmp/del_sql.log`
       do
           echo $i
          #rm -rf ${i}
       done   
      cd -
    fi
  fi
done
```

```
chattr -i /var/spool/cron/root

echo "# DB_BACKUP" >> /var/spool/cron/root
echo "0 0 * * * /data1/backdb.sh >/dev/null 2>&1" >> /var/spool/cron/root

chattr +i /var/spool/cron/root

# DB_BACKUP
0 0 * * * /data1/backdb.sh >/dev/null 2>&1
```

参考文档；

https://blog.csdn.net/demonson/article/details/87936096   使用 mysqldump 备份数据库时避免锁表
