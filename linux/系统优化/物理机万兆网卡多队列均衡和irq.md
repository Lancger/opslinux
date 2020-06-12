# 一、编写脚本
```bash
cat >1.sh<<\EOF
#!/bin/bash
infs=(`ls /sys/class/net`)
>/tmp/speed.txt
>/tmp/network.txt
for i in ${infs[*]};
do  
    get_Speed=`ethtool ${i} 2>/dev/null|grep Speed`
    echo $i ${get_Speed}>>/tmp/speed.txt
done
#获取万兆网卡名称
networks=`cat /tmp/speed.txt|grep "10000Mb/s"|awk '{print $1}'`

#获取cpu核数
cpu_num=`cat /proc/cpuinfo| grep "processor"| wc -l`

#获取网卡当前配置
for net in ${networks};
do
    pre_set=`ethtool -l ${net}|grep Combined|sed -n '1p'|awk '{print $2}'`
    cur_set=`ethtool -l ${net}|grep Combined|sed -n '2p'|awk '{print $2}'`
    #网卡最大支持的队列大于CPU核数，并且当前队列小于网卡最大支持的队列
    if [ $pre_set -gt $cpu_num ] && [ $cur_set -lt $pre_set ];then
        echo "设置 $net 网卡队列为CPU核数:  $cpu_num"
        ethtool -L $net combined $cpu_num >/dev/null 2>&1
    else [ $pre_set -lt $cpu_num ] && [ $cur_set -lt $pre_set ]
        echo "设置 $net 网卡队列为支持的最大队列数:  $pre_set"
        ethtool -L $net combined $pre_set >/dev/null 2>&1
    fi
done
EOF
sh 1.sh
```

# 二、运行结果
```
[root@root ~]# sh 1.sh
设置 eth2 网卡队列为CPU核数:  24
设置 eth3 网卡队列为支持的最大队列数:  4
```

# 三、通过内核实现网卡多队列均衡

```bash
#!/usr/bin/env python

import socket
import fcntl
import struct
import array
import platform
import os
import sys

BYTES = 4096
buf = 4096

def get_cpu_core_num():
    try:
        import multiprocessing
        return multiprocessing.cpu_count()
    except (ImportError, NotImplementedError):
        pass

    res = open('/proc/cpuinfo').read().count('processor\t:')
    if res > 0:
        return res

    return 0

def get_iface_list():
    ifs = set()
    ifsdir = "/sys/class/net/"
    for i in os.listdir(ifsdir):
        path = os.path.join(ifsdir, i)
        if os.path.islink(path):
           ifs.add(i)

    return ifs



def write_proc(path, content):
    print "echo %s > %s" % (content, path)
    f = open(path, 'w+')
    f.write(str(content))
    f.close()

cpu_num = get_cpu_core_num()

mask1 = 'f' * (cpu_num / 4)
mask = [ hex(2 ** x).split('0x')[1] for x in range(cpu_num)]

ifs = get_iface_list()
if len(ifs) == 0:
    print "Can not get net interface!"
    sys.exit()

print ifs
i = 0
flag = 0
for iface in ifs:
    irqflag = 0
    if iface.find(':') == -1 and iface != 'lo' and iface.find('tun') == -1 and iface.find('pop') == -1 and iface.find('bond') == -1:
        fp = open('/proc/interrupts', 'r').read()
        for line in open('/proc/interrupts', 'r'):
            if i == cpu_num:
                i = 0
            s ="%s-" % iface
            if line.find(s) == -1:
                if line.find(iface) != -1:
                     irqflag = 1
                continue
            irqflag = 0
            key = line.split()[0].strip()[:-1]
            path = "/proc/irq/%s/smp_affinity" % key
            write_proc(path, mask[i])
            i += 1

        ifsq = "/sys/class/net/%s/queues" % iface
        if not os.path.exists(ifsq):
            continue
        for dir in os.listdir(ifsq):
            if i == cpu_num:
                i = 0
            if dir.startswith('rx-'):
                path = "%s/%s/rps_cpus" % (ifsq, dir)
                if irqflag == 1:
                    write_proc(path, mask1)
                else:
                    write_proc(path, mask[i])
                path = "%s/%s/rps_flow_cnt" % (ifsq, dir)
                write_proc(path, buf)
                flag = 1
            else:
                path = "%s/%s/xps_cpus" % (ifsq, dir)
                if irqflag == 1:
                    write_proc(path, mask1)
                else:
                    write_proc(path, mask[i])
            i += 1

if flag == 1:
    path = '/proc/sys/net/core/rps_sock_flow_entries'
    if os.path.exists(path):
        write_proc(path, buf)

#modify iptables hashsize to 1048576
#kernel version > 2.6.20
path = "/sys/module/nf_conntrack/parameters/hashsize"
if os.path.exists(path):
    write_proc(path, '1048576')
#kernel version > 2.6.16 and version <= 2.6.19
path = "/sys/module/ip_conntrack/parameters/hashsize"
if os.path.exists(path):
    write_proc(path, '1048576')
    
#wget http://everything123.yum.sandai.net/images/.config/irq.py -O /usr/local/irq.py  -o /dev/null
```
