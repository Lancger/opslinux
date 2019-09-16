# 一、权限测试
```
sudo -u zabbix  cat /opt/tomcat-8081-taskjob/logs/catalina.2019-05-21.out
```

```
表达式：{zabbix:log[/etc/zabbix/a.log,"ERROR|error",,,skip,,].iregexp(ERROR|error)}=1 and  {zabbix:log[/etc/zabbix/a.log,"ERROR|error",,,skip,,].nodata(60)}=0

拆开解析：{zabbix:log[/etc/zabbix/a.log,"ERROR|error",,,skip,,].iregexp(ERROR|error)}=1 ，iregexp(ERROR|error)}=1 意味着如果匹配到ERROR和error关键字其中一个就告警，iregexp意味着正则表达式匹配。

        {zabbix:log[/etc/zabbix/a.log,"ERROR|error",,,skip,,].nodata(60)}=0，nodata(60)}=0 意味着如果60秒内有数据产生则表达式为真，即60秒内如果没有新数据了，则表达式为假，以防一直采集原有的关键字，不是采集新生成的关键字（重要）

　　　　　 and表示同时满足两个条件，触发器才会触发。
```

参考资料:

https://www.cnblogs.com/ultranms/p/9523721.html  zabbix3.4.7主动模式监控日志(多关键字)


https://blog.csdn.net/achenyuan/article/details/87687236  zabbix4.0学习六：Zabbix监控日志
