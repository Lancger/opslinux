# 一、提示无权限

```
ll /var/spool/

drwx------.  2 root  root  4096 May 20 11:33 cron
```

# 二、解决办法
```
chmod 755  /var/spool/cron

chmod 644  /var/spool/cron/root
```

# 三、批量处理
```
salt "*" cmd.run "touch /var/spool/cron/root && chmod 755  /var/spool/cron && chmod 644  /var/spool/cron/root"
```

# 四、测试验证
```
zabbix_get -s 192.168.52.188 -k "vfs.file.cksum[/var/spool/cron/root]"
```
