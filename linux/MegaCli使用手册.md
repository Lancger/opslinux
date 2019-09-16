## 一、下载MegaCli
```
wget ftp://download2.boulder.ibm.com/ecc/sar/CMA/XSA/ibm_utl_sraidmr_megacli-8.00.48_linux_32-64.zip
```
## 二、安装
```
#解压zip安装包
unzip ibm_utl_sraidmr_megacli-8.00.48_linux_32-64.zip

#切换到安装包目录
cd linux/

#使用rpm安装
rpm -ivh Lib_Utils-1.00-09.noarch.rpm MegaCli-8.00.48-1.i386.rpm

#查看文件安装在哪
rpm -ql MegaCli-8.00.48-1.i386

#做软链接
ln -s /opt/MegaRAID/MegaCli/MegaCli64 /bin/MegaCli64
ln -s /opt/MegaRAID/MegaCli/MegaCli64 /sbin/MegaCli64
```

## 三、使用命令及参数
```
#查看帮助：
MegaCli64 -h

#查看RAID控制器的数量
[root@tw06a1671 ~]# MegaCli64 -adpCount   //下面可以看出RAID控制器的数量为1                                    

Controller Count: 1.

Exit Code: 0x01

#查看所有raid卡详细信息
[root@tw06a1671 ~]# MegaCli64 -AdpAllInfo -aALL
                                     
Adapter #0                   ---表示第一个raid卡

==============================================================================
                    Versions
                ================
Product Name    : PERC H330 Mini  ---raid卡的型号
Serial No       : 5BP01R2
FW Package Build: 25.3.0.0016

                    Mfg. Data
                ================
Mfg. Date       : 11/28/15
Rework Date     : 11/28/15
Revision No     : A03
Battery FRU     : N/A

                Image Versions in Flash:
                ================
BIOS Version       : 6.23.03.0_4.16.07.00_0x060C0200
Ctrl-R Version     : 5.04-0012
FW Version         : 4.250.01-4405
NVDATA Version     : 3.1411.01-0015
Boot Block Version : 3.02.00.00-0001
```

参考文档： https://blog.csdn.net/xinqidian_xiao/article/details/80940306
