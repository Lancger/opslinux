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

```bash
find /var/log -name "messages*" -exec bash -c "echo '' > {}" \;
```
参考资料：

https://segmentfault.com/q/1010000006497740  如何使用find + exec命令向指定的文件追加相同内容？

https://blog.csdn.net/counsellor/article/details/87082207    Linux下清理删除last登录日志

https://blog.csdn.net/q871063970/article/details/46894005    linux清空历史命令方法
