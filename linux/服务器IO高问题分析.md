## 一、告警现象

  ![iotop抓取图](https://github.com/Lancger/opslinux/blob/master/images/iotop.jpg)
  ![iostat抓取图](https://github.com/Lancger/opslinux/blob/master/images/iostat.jpg)
  
yum -q install /usr/bin/iostat  
  
## 二、现场抓取
```
########################
[root@localhost ~]# iotop
Total DISK READ: 0.00 B/s | Total DISK WRITE: 0.00 B/s
  TID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN     IO>    COMMAND
 1024 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % -bash
    1 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % init
    2 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [kthreadd]
    3 rt/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [migration/0]
    4 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [ksoftirqd/0]
    5 rt/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [stopper/0]
    6 rt/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [watchdog/0]

########################
#iostat -x -k -d 2 5。每隔2s输出磁盘IO的详细详细，总共采样5次。

-c：只显示系统CPU统计信息，即单独输出avg-cpu结果，不包括device结果
-d：单独输出Device结果，不包括cpu结果
-k/-m：输出结果以kB/mB为单位，而不是以扇区数为单位
-x:输出更详细的io设备统计信息
interval/count：每次输出间隔时间，count表示输出次数，不带count表示循环输出

[root@localhost ~]# iostat -x -k -d 2 5
Linux 2.6.32-504.el6.x86_64 (localhost.localdomain) 	10/11/2018 	_x86_64_	(1 CPU)

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
scd0              0.00     0.00    0.00    0.00     0.02     0.00     8.00     0.00    0.97    0.97    0.00   0.97   0.00
sda               0.18     0.42    0.54    0.18    10.98     2.38    37.31     0.00    0.62    0.38    1.34   0.33   0.02
dm-0              0.00     0.00    0.57    0.59    10.47     2.38    22.09     0.00    1.87    0.67    3.03   0.19   0.02
dm-1              0.00     0.00    0.04    0.00     0.14     0.00     8.00     0.00    0.22    0.22    0.00   0.12   0.00

rrqm/s: 每秒对该设备的读请求被合并次数，文件系统会对读取同块(block)的请求进行合并
wrqm/s: 每秒对该设备的写请求被合并次数
r/s: 每秒完成的读次数
w/s: 每秒完成的写次数
rkB/s: 每秒读数据量(kB为单位)
wkB/s: 每秒写数据量(kB为单位)
avgrq-sz:平均每次IO操作的数据量(扇区数为单位)
avgqu-sz: 平均等待处理的IO请求队列长度
await: 平均每次IO请求等待时间(包括等待时间和处理时间，毫秒为单位)
svctm: 平均每次IO请求的处理时间(毫秒为单位)
%util: 采用周期内用于IO操作的时间比率，即IO队列非空的时间比率


重点关注参数

1、iowait% 表示CPU等待IO时间占整个CPU周期的百分比，如果iowait值超过50%，或者明显大于%system、%user以及%idle，表示IO可能存在问题。

2、avgqu-sz 表示磁盘IO队列长度，即IO等待个数。

3、await 表示每次IO请求等待时间，包括等待时间和处理时间

4、svctm 表示每次IO请求处理的时间

5、%util 表示磁盘忙碌情况，一般该值超过80%表示该磁盘可能处于繁忙状态。
```

## 三、分析
```
从截图中可以发现
iotop观察到命令[flush-8:16]和[jbd2/sdb2-8]交替使用99.99％的IO。
然后，也没有看到任何异常dmesg或/var/log/syslog。

它们是文件系统的一部分 - flush将RAM缓冲区/缓存写入磁盘，jbd2处理ext4日志

猜测
我冒险猜测：
/dev/sdb1 也许交换空间？

free -m 使用了多少交换空间：
[root@localhost ~]# free -m
             total       used       free     shared    buffers     cached
Mem:         31868      31509        359          0         20      23647
-/+ buffers/cache:       7840      24027
Swap:        20479       1130      19349

如果这是问题，您可以将swap移至sda或禁用sdb的spindowns。
```

参考文档： https://askubuntu.com/questions/30191/how-can-i-prevent-flush-816-and-jbd2-sdb2-8-from-causing-gui-unresponsivene
