```
CentOS 7 dmesg信息，dmesg -T 可以显示时间戳

[root@centos6 ~]#echo 1 >/sys/module/printk/parameters/time
[root@centos6 ~]#cat  /sys/module/printk/parameters/time
Y

```


参考资料：

https://www.jianshu.com/p/1780360cfd2b
