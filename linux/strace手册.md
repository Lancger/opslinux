```
strace用来看某个进程的系统调用以及所接收到的信号

#打印进程读写文件的次数
strace -f -p 9037  -s 0  -e trace=write,read   -T  -y


追踪某个命令


会输出很多系统调用命令， 如下面，  =左边是系统调用，右边是系统调用结果
$strace ls -l      能看到ls -l命令整个的系统调用情况
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=388, ...}) = 0


-p 追踪某个进程，需要带上-f来追踪所有子进程

$strace -f -p 5926 -o /home/***/5926.strace.log



-c 参数，输出统计结果

-c  可以输出系统调用的统计结果，也就是每个命令的占比
$strace -c -f -p 5926 -o /home/***/5926.strace.log

#less  /home/***/5926.strace.log
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
 60.47   19.181735        7429      2582      1258 futex
 23.42    7.429387      212268        35        35 restart_syscall
 11.14    3.533856         983      3596           epoll_wait
  1.50    0.475396          51      9368           setsockopt
  0.79    0.250978          54      4684           fcntl
  0.72    0.227007          48      4684      2342 epoll_ctl
  0.42    0.132211          56      2342      2342 connect
  0.40    0.127517          54      2342           getsockopt
  0.39    0.123448          53      2342           close
  0.38    0.119249          51      2342           dup2
  0.37    0.117744          50      2342           socket
  0.00    0.000432          15        29           recvfrom
  0.00    0.000210           7        29           poll
  0.00    0.000000           0        10           write
  0.00    0.000000           0        29           sendto
------ ----------- ----------- --------- --------- ----------------
100.00   31.719170                 36756      5977 total



-T 输出系统调用花费时间

-T  表示记录各个系统调用花费的时间，精确到微妙，结果中的 <0.000020> 为时间
$strace -T -f -e trace=network  -p 9618 -o /home/A/desc.trace.9618
$cat /home/A/desc.trace.9618
9700  getsockopt(76, SOL_SOCKET, SO_ERROR, [111], [4]) = 0 <0.000020>



-t 打印系统调用的发生时间

$strace -f -t   -p 9618 -o /home/A/9618.strace
$cat /home/A/9618.strace
9705  21:57:09 getsockopt(54, SOL_SOCKET, SO_ERROR, [111], [4]) = 0



-e expr, 可以指定某个系统调用

下面为追踪read的系统调用
$strace -f -e read -p 9618   -o 9618.read.log



-e trace=network  追踪网络调用情况

$strace -f -t  -e trace=network  -p 9618 -o /home/A/desc.trace.9618.withouti
$cat /home/A/desc.trace.9618.withouti
9705  21:57:09 getsockopt(54, SOL_SOCKET, SO_ERROR, [111], [4]) = 0
...

﻿

-e trace=open 追踪open系统调用

也可以trace=open,close,read,write
$strace -e trace=open  -o a.txt.log

$less a.txt.log
open("/etc/ld.so.cache", O_RDONLY)      = 3
open("/lib64/libtinfo.so.5", O_RDONLY)  = 3
open("/lib64/libpcre.so.0", O_RDONLY)   = 3
...



-e trace=file, 记录文件操作

把5926对文件的操作记录下来，相当于trace=open.stat,chmod,unlink...
$strace -f -e trace=file -p 5926 -o 5926.file.trace.log



-e trace=process, 把关于进程的系统调用记录下来

把6259对process系统调用的操作记录下来，相当于trace=
$strace -f -e trace=process -p 6259 -o 6259.file.process.log



-e trace=network, 把关于进程的系统调用记录下来

把5926对网络的系统调用记录下来
$strace -f -e trace=network -p 5926  -o 5926.network.log



-e trace=ipc  把进程间通讯记录下来

把5926对进程间通讯的系统调用记录下来
$strace -f -e trace=ipc -p 5926  -o 5926.ipc.log
```

参考文档：

http://www.itshouce.com.cn/linux/linux-strace.html
