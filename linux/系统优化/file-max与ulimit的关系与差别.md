```
file-max与ulimit的关系与差别

两者查看命令:

sysctl -a | grep file

cat /etc/security/limits.conf

ulimit -a #查看当前用户当前shell的ulimit参数

 

file-max与file-nr

/proc/sys/fs/file-max 决定了当前内核可以打开的最大的文件句柄数，系统所有进程一共可以打开的文件数量。

/proc/sys/fs/file-nr 当前kernel的句柄

file-max解释:

The value in file-max denotes the maximum number of file handles that the

Linux kernel will allocate. When you get a lot of error messages about running

out of file handles, you might want to raise this limit. The default value is

10% of RAM in kilobytes. To change it, just write the new number into the

file:

file-nr解释

Historically, the three values in file-nr denoted the number of allocated file

handles, the number of allocated but unused file handles, and the maximum

number of file handles. Linux 2.6 always reports 0 as the number of free file

handles -- this is not an error, it just means that the number of allocated

file handles exactly matches the number of used file handles.

修改：

vim /proc/sys/fs/file-max修改即可生效

ulimit

说一下open files这个值

ulimit -n : 用户当前shell以及该shell启动的进程打开的文件数量,

所以ulimit -n限制用户单个进程的问价打开最大数量这句话是错误的

这个值默认: 1024

修改

ulimit -n 65535 只能修改当前shell会话。

永久修改需要设置：/etc/security/limits.conf

root soft nofile 65535

root hard nofile 65535

 

#其他用户可以使用*

修改后重启

说一下Ubuntu系统修改。需要检查/etc/pam.d/su /etc/pam.d/session /etc/pam.d/login 等模块是否开启了

session    required   pam_limits.so

这个还不够，对于root用户，Ubuntu系统/etc/security/limits.conf中的*是不能代表root用户的。所以必须写root用户名

root soft nofile 65535

root hard nofile 65535
--------------------- 
```
```
 linux系统默认open files数目为1024, 有时应用程序会报Too many open files的错误，是因为open files 数目不够。这就需要修改ulimit和file-max。特别是提供大量静态文件访问的web服务器，缓存服务器（如squid）, 更要注意这个问题。
网上的教程，都只是简单说明要如何设置ulimit和file-max, 但这两者之间的关系差别，并没有仔细说明。

说明：
1. file-max的含义。man proc，可得到file-max的描述：
/proc/sys/fs/file-max
This file defines a system-wide limit on the number of open files for all processes. (See
also setrlimit(2), which can be used by a process to set the per-process limit,
RLIMIT_NOFILE, on the number of files it may open.) If you get lots of error messages
about running out of file handles, try increasing this value:
即file-max是设置 系统所有进程一共可以打开的文件数量 。同时一些程序可以通过setrlimit调用，设置每个进程的限制。如果得到大量使用完文件句柄的错误信息，是应该增加这个值。
也就是说，这项参数是系统级别的。

2. ulimit
Provides control over the resources available to the shell and to processes started by it, on systems that allow such control.
即设置当前shell以及由它启动的进程的资源限制。
显然，对服务器来说，file-max, ulimit都需要设置，否则就可能出现文件描述符用尽的问题

1.修改file-max

    # echo  6553560 > /proc/sys/fs/file-max  //sysctl -w "fs.file-max=34166"，前面2种重启机器后会恢复为默认值
    vim /etc/sysctl.conf, 加入以下内容，重启生效
     
    fs.file-max = 6553560

2.修改ulimit的open file，系统默认的ulimit对文件打开数量的限制是1024

    # ulimit -HSn 102400  //这只是在当前终端有效，退出之后，open files又变为默认值。当然也可以写到/etc/profile中，因为每次登录终端时，都会自动执行/etc/profile
    或
    # vim /etc/security/limits.conf  //加入以下配置，重启即可生效
    * soft nofile 65535 
    * hard nofile 65535
```
版权声明：本文为CSDN博主「菜呀菜」的原创文章，遵循CC 4.0 by-sa版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/tryItnow/article/details/82563583

https://blog.csdn.net/tryItnow/article/details/82563583


https://blog.csdn.net/qq_26614295/article/details/81502338  Linux修改open files数及ulimit和file-max的区别
