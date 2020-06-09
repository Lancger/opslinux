# 一、awk计算(浮点型运算)

```
#!/bin/bash
cnt=1200
awk 'BEGIN{printf "%.0f\n",('$cnt'*'0.8')}'
```

# 二、整形运算
```
#!/bin/bash
cnt=1200
expr $cnt '*' 2
```

# 三、pstree
```
1、在 Mac OS上

      brew install pstree

2、在 Fedora/Red Hat/CentOS

      yum -y install psmisc

3、在 Ubuntu/Debian

     apt-get install psmisc
```

# 四、强制覆盖
```
#方式一
使用原生的cp命令
/bin/cp -rf /root/.bashrc /home/www/

#方式二
取消cp命令别名
unalias cp

复制完成后恢复别名
alias cp='cp -i'
```

# 五、快速找出占用根分区文件

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

参考资料


http://dsl000522.blog.sohu.com/200854305.html  
