# 一、快速找出占用根分区的文件
```yaml
[root@master /]# cd /;file=`ls |grep -v proc`;for i in $file;do du -sh /$i;done
0       /bin
126M    /boot
0       /data
0       /data1
0       /data10
0       /data2
0       /data3
0       /data4
0       /data5
0       /data6
0       /data7
0       /data8
0       /data9
0       /dev
51G     /etc
84K     /home
0       /lib
0       /lib64
0       /media
0       /mnt
9.2M    /opt
16M     /root
34M     /run
0       /sbin
0       /srv
0       /sys
1.6G    /tmp
3.9G    /usr
5.1G    /var
```

参考文档：

https://blog.51cto.com/12643266/2352355  "No space left on device" 磁盘空间提示不足解决办法
