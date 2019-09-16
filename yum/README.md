## 一、yum报错

### 报错一

```
root># yum install iftop
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.aliyun.com
 * epel: my.fedora.ipserverone.com
 * extras: mirrors.163.com
 * updates: mirrors.163.com
Resolving Dependencies
There are unfinished transactions remaining. You might consider running yum-complete-transaction, or "yum-complete-transaction --cleanup-only" and "yum history redo last", first to finish them. If those don't work you'll have to try removing/installing packages by hand (maybe package-cleanup can help).
```

### 解决办法：
```
yum install yum-utils  -y

yum-complete-transaction --cleanup-only
```
