# 一、检测方式一
```
命令：
cat /sys/block/sda/queue/rotational
0

cat /sys/block/sdb/queue/rotational
1

注意：
命令中的sba是你的磁盘名称，可以通过df命令查看磁盘，然后修改成你要的


结果：
返回0：SSD盘
返回1：SATA盘
```

# 二、检测方式二
```
lsblk -d -o name,rota

NAME ROTA
sda     0
sdb     1
```

# 三、检测方式三
```
lsscsi 

[0:0:0:0]    disk    ATA      Samsung SSD 850  3B6Q  /dev/sda  ---三星SSD
[1:0:0:0]    disk    ATA      ST91000640NS     AA09  /dev/sdb  ---希捷SATA
```

参考文档：

https://blog.csdn.net/daiyudong2020/article/details/51454831   linux查看磁盘是否SSD盘
