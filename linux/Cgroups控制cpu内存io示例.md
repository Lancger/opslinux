```
yum -y install libcgroup gcc libcap-devel 

yum -y install hdparm

#首先用 hdparm测试磁盘读取的最大带宽:

hdparm --direct -t /dev/sda

```
## 一、测试
```
chkconfig cgred on
chkconfig cgconfig on

service cgred restart
service cgconfig restart

dd if=/dev/sda of=/dev/null


cpu.cfs_period_us：cpu分配的周期(微秒），默认为100000。

cpu.cfs_quota_us：表示该control group限制占用的时间（微秒），默认为-1，表示不限制。如果设为50000，表示占用50000/10000=50%的CPU。

这里，我们设置占用30%的CPU，即把cpu.cfs_quota_us设置为30000。

```

## 二、配置文件/etc/cgconfig.conf

```
[root@localhost ~]# cat /etc/cgconfig.conf
#
#  Copyright IBM Corporation. 2007
#
#  Authors:	Balbir Singh <balbir@linux.vnet.ibm.com>
#  This program is free software; you can redistribute it and/or modify it
#  under the terms of version 2.1 of the GNU Lesser General Public License
#  as published by the Free Software Foundation.
#
#  This program is distributed in the hope that it would be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# See man cgconfig.conf for further details.
#
# By default, mount all controllers to /cgroup/<controller>

mount {
	cpuset	= /cgroup/cpuset;
	cpu	= /cgroup/cpu;
	cpuacct	= /cgroup/cpuacct;
	memory	= /cgroup/memory;
	devices	= /cgroup/devices;
	freezer	= /cgroup/freezer;
	net_cls	= /cgroup/net_cls;
	blkio	= /cgroup/blkio;
}

group io-test {
    perm {
          task{
              uid=www;
              gid=www;
          }

          admin{
             uid=root;
             gid=root;
          }

    } blkio {
        blkio.throttle.write_iops_device="";
        blkio.throttle.read_iops_device="";
        blkio.throttle.write_bps_device="8:0 1048576";    --限速的1M/s的速率
        blkio.throttle.read_bps_device="8:0 1048576";     --限速的1M/s的速率
        blkio.reset_stats="";
        blkio.weight="500";
        blkio.weight_device="";
    }
}
```
## 三、配置文件/etc/cgrules.conf
```
[root@localhost ~]# cat /etc/cgrules.conf
# /etc/cgrules.conf
#The format of this file is described in cgrules.conf(5)
#manual page.
#
# Example:
#<user>		<controllers>	<destination>
#@student	cpu,memory	usergroup/student/
#peter		cpu		test1/
#%		memory		test2/
*:       blkio            io-test
# End of file
```

## 四、配置解释

  ![CGROUP](https://github.com/Lancger/opslinux/blob/master/images/cgroup.jpg)


参考文档：

https://stackoverflow.com/questions/24959846/cgroup-blkio-files-cannot-be-written     限制IO的参考

https://www.howtoing.com/how-to-limit-resources-using-cgroups-on-centos-6   如何限制资源使用在CentOS 6的cgroup

https://www.cnblogs.com/yanghuahui/p/3751826.html

https://www.jianshu.com/p/dc3140699e79

https://blog.csdn.net/lanyang123456/article/details/82319911

