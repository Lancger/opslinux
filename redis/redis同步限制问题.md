```
[28741] 11 Sep 16:39:36.381 # Client id=3860001 addr=10.100.99.81:33562 fd=78 name= age=61 idle=61 flags=S db=0 sub=0 psub=0 multi=-1 qbuf=0 qbuf-free=0 obl=15052 oll=10203 omem=268442168 events=rw cmd=psync scheduled to be closed ASAP for overcoming of output buffer limits.


config set client-output-buffer-limit slave1024mb 256mb 0

config set client-output-buffer-limit 'slave 1024000000 256000000 60'

config set client-output-buffer-limit 'slave 0 0 0'

```

```
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag


#永久关闭
[root@localhost ~]# vim /etc/rc.d/rc.local

if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
echo never > /sys/kernel/mm/transparent_hugepage/enabled
fi

if test -f /sys/kernel/mm/transparent_hugepage/defrag; then
echo never > /sys/kernel/mm/transparent_hugepage/defrag
fi

授予执行权限
[root@localhost ~]# chmod +x /etc/rc.d/rc.local
```
参考资料：

https://www.cnblogs.com/gangdou/p/7991754.html  记一次redis主从同步失败

https://www.cndba.cn/zhasir/article/3438

