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

# 四、查看磁盘状态
```
[root@node-1 ~]# /opt/MegaRAID/MegaCli/MegaCli64  -PDLIST -aALL -nolog|grep -iE "Enclosure Device ID:|slot|Media Error|Firmware state|Predictive Failure Count|PD Type:" |xargs --max-lines=6
Enclosure Device ID: 32 Slot Number: 0 Media Error Count: 22 Predictive Failure Count: 0 PD Type: SATA Firmware state: Failed
Enclosure Device ID: 32 Slot Number: 1 Media Error Count: 0 Predictive Failure Count: 0 PD Type: SATA Firmware state: Online, Spun Up
Enclosure Device ID: 32 Slot Number: 2 Media Error Count: 0 Predictive Failure Count: 0 PD Type: SATA Firmware state: Online, Spun Up
Enclosure Device ID: 32 Slot Number: 3 Media Error Count: 0 Predictive Failure Count: 0 PD Type: SATA Firmware state: Online, Spun Up
Enclosure Device ID: 32 Slot Number: 4 Media Error Count: 653 Predictive Failure Count: 0 PD Type: SATA Firmware state: Failed
Enclosure Device ID: 32 Slot Number: 5 Media Error Count: 0 Predictive Failure Count: 0 PD Type: SATA Firmware state: Online, Spun Up
Enclosure Device ID: 32 Slot Number: 6 Media Error Count: 0 Predictive Failure Count: 0 PD Type: SATA Firmware state: Online, Spun Up
Enclosure Device ID: 32 Slot Number: 7 Media Error Count: 0 Predictive Failure Count: 0 PD Type: SATA Firmware state: Online, Spun Up
Enclosure Device ID: 32 Slot Number: 8 Media Error Count: 0 Predictive Failure Count: 0 PD Type: SATA Firmware state: Online, Spun Up
Enclosure Device ID: 32 Slot Number: 9 Media Error Count: 2326 Predictive Failure Count: 1 PD Type: SATA Firmware state: Failed
Enclosure Device ID: 32 Slot Number: 10 Media Error Count: 0 Predictive Failure Count: 0 PD Type: SATA Firmware state: Online, Spun Up
Enclosure Device ID: 32 Slot Number: 11 Media Error Count: 0 Predictive Failure Count: 0 PD Type: SATA Firmware state: Online, Spun Up
Enclosure Device ID: 32 Slot Number: 12 Media Error Count: 0 Predictive Failure Count: 0 PD Type: SAS Firmware state: JBOD
Enclosure Device ID: 32 Slot Number: 13 Media Error Count: 0 Predictive Failure Count: 0 PD Type: SAS Firmware state: JBOD


[root@node-1 ~]# for dev in $(df -Th | grep "^/dev" | awk -F '[0-14]' '{print $1}' | sort -u); do echo $dev ; smartctl -H $dev |grep -i health ; done
/dev/sda
SMART Health Status: OK
/dev/sda3
ext
/dev/sdb
SMART Health Status: OK
```
参考文档： https://blog.csdn.net/xinqidian_xiao/article/details/80940306
