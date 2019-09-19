```
show variables like '%relay_log_purge%';


你的是io线程没有断开，一直把主库的日志拉过来了，sql线程应用完，你开了自动清理的后面就会删除掉的，要sql线程把那些日志先应用完


10几天累计的日志，全放relaylog了，所以这么大，等你实时同步了，就没那么多了

```

  ![Mysql relaylog](https://github.com/Lancger/opslinux/blob/master/images/relaylog.png)
