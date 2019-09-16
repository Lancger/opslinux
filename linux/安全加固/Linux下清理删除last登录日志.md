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
参考资料：

https://blog.csdn.net/counsellor/article/details/87082207    Linux下清理删除last登录日志

https://blog.csdn.net/q871063970/article/details/46894005    linux清空历史命令方法
