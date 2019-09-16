# 一、mount报错信息

  ![mount报错示意图1](https://github.com/Lancger/opslinux/blob/master/images/mount_error.png)

# 二、解决办法

lvm inactive问题定位及解决

http://ju.outofmemory.cn/entry/105644

安装pvs等命令包

yum install -y lvm2

1、lvscan 查看
```
[root@iadad1 ~]# lvscan
  inactive          '/dev/vg_coin/lv_coin' [<200.00 GiB] inherit    --这里发现状态为 inactive
```
2、通过vgchange激活卷组并重启挂载
```
[root@iZuf62w1juq9pm5jar66slZ ~]# vgchange -ay vg_coin     (注意这里要写vg组名，为中间那串字符)
  1 logical volume(s) in volume group "vg_coin" now active       
```
3、重新挂载
```
[root@iZuf62w1juq9pm5jar66slZ ~]# mount /dev/vg_coin/lv_coin /data0/
[root@iZuf62w1juq9pm5jar66slZ ~]# df -h
Filesystem                   Size  Used Avail Use% Mounted on
/dev/vda1                     50G  1.6G   46G   4% /
devtmpfs                     7.8G     0  7.8G   0% /dev
tmpfs                        7.8G     0  7.8G   0% /dev/shm
tmpfs                        7.8G  340K  7.8G   1% /run
tmpfs                        7.8G     0  7.8G   0% /sys/fs/cgroup
tmpfs                        1.6G     0  1.6G   0% /run/user/0
/dev/mapper/vg_coin-lv_coin  200G   78G  123G  39% /data0
```
4、写到fstab开机自动挂载
```
vim /etc/fstab     (注意这里是xfs格式的)

/dev/mapper/vg_coin-lv_coin           /data0                      xfs    defaults        0 1
```
5、挂载验证
```
mount -a

[root@iZuf62w1juq9pm5jar66slZ ~]# df -hT
Filesystem                  Type      Size  Used Avail Use% Mounted on
/dev/vda1                   ext4       50G  1.6G   46G   4% /
devtmpfs                    devtmpfs  7.8G     0  7.8G   0% /dev
tmpfs                       tmpfs     7.8G     0  7.8G   0% /dev/shm
tmpfs                       tmpfs     7.8G  316K  7.8G   1% /run
tmpfs                       tmpfs     7.8G     0  7.8G   0% /sys/fs/cgroup
tmpfs                       tmpfs     1.6G     0  1.6G   0% /run/user/0
/dev/mapper/vg_coin-lv_coin xfs       200G   78G  123G  39% /data0
```


参考资料：


https://yq.aliyun.com/articles/52222?spm=5176.11065265.1996646101.searchclickresult.1546247dUlgfe4   阿里云文档
