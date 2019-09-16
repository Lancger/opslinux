# 一、安装zabbix-get测试
```
wget http://repo.zabbix.com/zabbix/2.4/rhel/6/x86_64/zabbix-get-2.4.8-1.el6.x86_64.rpm

rpm -Uvh zabbix-get-2.4.8-1.el6.x86_64.rpm 

zabbix_get -s 10.33.99.21 -p 10050 -k "vfs.file.cksum[/var/spool/cron/root]"

2281612052
```
# 二、注意事项

```
#测试zabbix用户是否有权限执行file
#root文件zabbix用户需要能读

/usr/bin/sudo -u zabbix /usr/bin/file /var/spool/cron/root
 
chattr -i /var/spool/cron/root
 
chmod u+s /usr/bin/file
 
chmod 755 -R /var/spool/

/var/spool/cron/ 目录的权限要为755
```

参看资料：

http://www.ttlsa.com/zabbix/zabbix-key-not-supported/  
