# 一、问题现象

  阿里云的一块数据磁一开始购买的磁盘只有300G,后面通过阿里云控制台，将数据盘扩容到了500G，然后系统分区使用的LVM格式
  
  ```
  [root@coin-server-eth-b ~]# fdisk /dev/vdc    ---- 重新对该磁盘划分分区
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): p  --- 打印当前分区表

Disk /dev/vdc: 536.9 GB, 536870912000 bytes, 1048576000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0xb30a48c8

   Device Boot      Start         End      Blocks   Id  System
/dev/vdc1            2048   629145599   314571776   8e  Linux LVM     --- 这里发现该磁盘已经划分了一个vdc1的分区

Command (m for help): n   --- 新建一个主分区
Partition type:
   p   primary (1 primary, 0 extended, 3 free)
   e   extended
Select (default p): 
Using default response p
Partition number (2-4, default 2): 2     --- 因为已经有个分区，所以这里选择 2 
First sector (629145600-1048575999, default 629145600):   --- 注意这里的扇区的起始位置 
Using default value 629145600
Last sector, +sectors or +size{K,M,G} (629145600-1048575999, default 1048575999):  --- 扇区的结束位置
Using default value 1048575999
Partition 2 of type Linux and of size 200 GiB is set

Command (m for help): p

Disk /dev/vdc: 536.9 GB, 536870912000 bytes, 1048576000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0xb30a48c8

   Device Boot      Start         End      Blocks   Id  System
/dev/vdc1            2048   629145599   314571776   8e  Linux LVM
/dev/vdc2       629145600  1048575999   209715200   83  Linux           --- 这里发现已经新建了一个分区，但这里不是使用的 LVM 格式，还需对其进行修改操作

Command (m for help): t   ---  修改磁盘分区格式
Partition number (1,2, default 2): 2  --- 这里选择对第2块磁盘进行分区格式修改
Hex code (type L to list all codes): L  --- 列出所有的格式

 0  Empty           24  NEC DOS         81  Minix / old Lin bf  Solaris        
 1  FAT12           27  Hidden NTFS Win 82  Linux swap / So c1  DRDOS/sec (FAT-
 2  XENIX root      39  Plan 9          83  Linux           c4  DRDOS/sec (FAT-
 3  XENIX usr       3c  PartitionMagic  84  OS/2 hidden C:  c6  DRDOS/sec (FAT-
 4  FAT16 <32M      40  Venix 80286     85  Linux extended  c7  Syrinx         
 5  Extended        41  PPC PReP Boot   86  NTFS volume set da  Non-FS data    
 6  FAT16           42  SFS             87  NTFS volume set db  CP/M / CTOS / .
 7  HPFS/NTFS/exFAT 4d  QNX4.x          88  Linux plaintext de  Dell Utility   
 8  AIX             4e  QNX4.x 2nd part 8e  Linux LVM       df  BootIt         
 9  AIX bootable    4f  QNX4.x 3rd part 93  Amoeba          e1  DOS access     
 a  OS/2 Boot Manag 50  OnTrack DM      94  Amoeba BBT      e3  DOS R/O        
 b  W95 FAT32       51  OnTrack DM6 Aux 9f  BSD/OS          e4  SpeedStor      
 c  W95 FAT32 (LBA) 52  CP/M            a0  IBM Thinkpad hi eb  BeOS fs        
 e  W95 FAT16 (LBA) 53  OnTrack DM6 Aux a5  FreeBSD         ee  GPT            
 f  W95 Ext'd (LBA) 54  OnTrackDM6      a6  OpenBSD         ef  EFI (FAT-12/16/
10  OPUS            55  EZ-Drive        a7  NeXTSTEP        f0  Linux/PA-RISC b
11  Hidden FAT12    56  Golden Bow      a8  Darwin UFS      f1  SpeedStor      
12  Compaq diagnost 5c  Priam Edisk     a9  NetBSD          f4  SpeedStor      
14  Hidden FAT16 <3 61  SpeedStor       ab  Darwin boot     f2  DOS secondary  
16  Hidden FAT16    63  GNU HURD or Sys af  HFS / HFS+      fb  VMware VMFS    
17  Hidden HPFS/NTF 64  Novell Netware  b7  BSDI fs         fc  VMware VMKCORE 
18  AST SmartSleep  65  Novell Netware  b8  BSDI swap       fd  Linux raid auto
1b  Hidden W95 FAT3 70  DiskSecure Mult bb  Boot Wizard hid fe  LANstep        
1c  Hidden W95 FAT3 75  PC/IX           be  Solaris boot    ff  BBT            
1e  Hidden W95 FAT1 80  Old Minix      
Hex code (type L to list all codes): 8e  ---  这里修改为 LVM 格式的分区
Changed type of partition 'Linux' to 'Linux LVM'

Command (m for help): p

Disk /dev/vdc: 536.9 GB, 536870912000 bytes, 1048576000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0xb30a48c8

   Device Boot      Start         End      Blocks   Id  System
/dev/vdc1            2048   629145599   314571776   8e  Linux LVM
/dev/vdc2       629145600  1048575999   209715200   8e  Linux LVM

Command (m for help): w  --- 写入到分区表
The partition table has been altered!

Calling ioctl() to re-read partition table.

WARNING: Re-reading the partition table failed with error 16: Device or resource busy.
The kernel still uses the old table. The new table will be used at
the next reboot or after you run partprobe(8) or kpartx(8)
Syncing disks.
[root@coin-server-eth-b ~]# init 6     --- 重启才生效
  ```
# 二、查看当前VG大小
```
vgdisplay
```

  ![ECS LVM 扩容1](https://github.com/Lancger/opslinux/blob/master/images/ecs_lvm_01.png)

# 三、将新分区磁盘加入到VG组并扩容

```
vgextend vg_group2 /dev/vdc2

```
  ![ECS LVM 扩容1](https://github.com/Lancger/opslinux/blob/master/images/ecs_lvm_02.png)
  
```  
lvextend -L +199G /dev/vg_group2/vg_eth_data
```  

  ![ECS LVM 扩容1](https://github.com/Lancger/opslinux/blob/master/images/ecs_lvm_05.png)

```
lvdisplay
```

  ![ECS LVM 扩容1](https://github.com/Lancger/opslinux/blob/master/images/ecs_lvm_06.png)

  
# 四、 应用生效

```
xfs_growfs /dev/vg_group2/vg_eth_data      # xfs 格式文件使用该命令生效
```

  ![ECS LVM 扩容1](https://github.com/Lancger/opslinux/blob/master/images/ecs_lvm_04.png)

# 五、 查看磁盘分区

```
lsblk
```

  ![ECS LVM 扩容1](https://github.com/Lancger/opslinux/blob/master/images/ecs_lvm_03.png)


参考资料：

https://help.aliyun.com/knowledge_detail/38061.html?spm=5176.11065259.1996646101.searchclickresult.551521e8mN9JMW&aly_as=7_tCZbP-   Linux LVM磁盘原地扩容
