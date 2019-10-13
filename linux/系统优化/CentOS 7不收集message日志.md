```
前一直有日志生成，正常运行，日志突然不收集 ，最后一次轮替日志之后，/var/log/message, /var/log/secure等都不记录了，并且都是空文件。
背景
重启机器：reboot 无效
重启日志： systemctl start rsyslog 无效
怀疑空间不足，删除/var/log/messages，重新运行rsyslog 无效
重装下rsyslog,于是yum reinstall rsyslog，重新运行rsyslog 无效
Solution
找到配置文件 /etc/rsyslog.conf
修改如下：
解注释：#$ModLoad imklog # reads kernel messages (the same are read from journald)
修改为：$ModLoad imklog # reads kernel messages (the same are read from journald)

增加注释：$OmitLocalLogging on
修改为：#$OmitLocalLogging on

增加注释：$IMJournalStateFile imjournal.state
修改为：#$IMJournalStateFile imjournal.state

重启日志：systemctl restart rsyslog
tai日志：tail -f /var/log/messages 可以了
————————————————
版权声明：本文为CSDN博主「TianXieErYang」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/tianxieeryang/article/details/86220988
```
参考资料：

https://blog.csdn.net/tianxieeryang/article/details/86220988  CentOS 7不收集日志 /var/log/messages
