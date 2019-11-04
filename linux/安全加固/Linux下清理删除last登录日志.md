```
> /var/log/wtmp
> /var/log/btmp
> /var/log/lastlog
> /var/log/message
> /root/.bash_history
> $HOME/.bash_history

cat /dev/null > ~/.bash_history && history -c && exit

cat > /etc/skel/.bash_logout << \EOF
rm -f $HOME/.bash_history
EOF

#root用户在/etc/skel/.bash_logout中添加代码,将对所有用户生效。
```

```
salt "*" cmd.run "> /var/log/wtmp"
salt "*" cmd.run "> /var/log/btmp"
salt "*" cmd.run "> /var/log/lastlog"
salt "*" cmd.run "> /var/log/message"
salt "*" cmd.run "> /root/.bash_history"
salt "*" cmd.run "> /home/www/.bash_history"
salt "*" cmd.run "rm -rf /var/log/*"
salt "*" cmd.run "cat /dev/null > ~/.bash_history && history -c && exit"
```

# 重置记录
```bash
find /var/log -name "audit*" |xargs ls -l
find /var/log -name "audit*" |xargs chattr -i
find /var/log -name "audit*" |xargs chattr -a
find /var/log -name "audit*" |xargs rm -f

#取消日志审计操作
sed -ri 's/.*history_conf.*/#&/' /etc/profile

find /var/log -name "secure*" |xargs ls -l

find /var/log -name "messages*" -exec bash -c "echo '' > {}" \;
find /var/log -name "cron*" -exec bash -c "echo '' > {}" \;
find /var/log -name "secure*" -exec bash -c "echo '' > {}" \;

echo > /var/log/syslog
echo > /var/log/messages
echo > /var/log/httpd/access_log
echo > /var/log/httpd/error_log
echo > /var/log/xferlog
echo > /var/log/secure
echo > /var/log/auth.log
echo > /var/log/user.log
echo > /var/log/wtmp
echo > /var/log/lastlog
echo > /var/log/btmp
echo > /var/run/utmp
echo > /root/.bash_history
echo > /home/www/.bash_history
history -c
```
# salt下发
```bash
salt "*" cmd.run 'find /var/log -name "audit*" |xargs ls -l'
salt "*" cmd.run 'find /var/log -name "audit*" |xargs chattr -i'
salt "*" cmd.run 'find /var/log -name "audit*" |xargs chattr -a'
salt "*" cmd.run 'find /var/log -name "audit*" |xargs rm -f'

#取消日志审计操作
salt "*" cmd.run 'sed -ri "s/.*history_conf.*/#&/" /etc/profile'

salt "*" cmd.run 'find /var/log -name "secure*" |xargs ls -l'

salt "*" cmd.run 'find /var/log -name "messages*" -exec bash -c "echo '' > {}" \;'
salt "*" cmd.run 'find /var/log -name "cron*" -exec bash -c "echo '' > {}" \;'
salt "*" cmd.run 'find /var/log -name "secure*" -exec bash -c "echo '' > {}" \;'

salt "*" cmd.run 'echo > /var/log/syslog'
salt "*" cmd.run 'echo > /var/log/messages'
salt "*" cmd.run 'echo > /var/log/httpd/access_log'
salt "*" cmd.run 'echo > /var/log/httpd/error_log'
salt "*" cmd.run 'echo > /var/log/xferlog'
salt "*" cmd.run 'echo > /var/log/secure'
salt "*" cmd.run 'echo > /var/log/auth.log'
salt "*" cmd.run 'echo > /var/log/user.log'
salt "*" cmd.run 'echo > /var/log/wtmp'
salt "*" cmd.run 'echo > /var/log/lastlog'
salt "*" cmd.run 'echo > /var/log/btmp'
salt "*" cmd.run 'echo > /var/run/utmp'
salt "*" cmd.run '> /root/.bash_history'
salt "*" cmd.run '> /home/www/.bash_history'
salt "*" cmd.run 'cat /dev/null > ~/.bash_history && history -c && exit'
```
参考资料：

https://segmentfault.com/q/1010000006497740  如何使用find + exec命令向指定的文件追加相同内容？

https://blog.csdn.net/counsellor/article/details/87082207    Linux下清理删除last登录日志

https://blog.csdn.net/q871063970/article/details/46894005    linux清空历史命令方法
