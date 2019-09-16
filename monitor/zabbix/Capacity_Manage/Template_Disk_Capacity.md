# 一、服务器指定磁盘空间统计

  ![zabbix-disk-01](https://github.com/Lancger/opslinux/blob/master/images/zabbix-disk-01.png)
  
  http://www.bejson.com/convert/filesize/   字节转换网站
  
  ![zabbix-disk-byte](https://github.com/Lancger/opslinux/blob/master/images/zabbix-disk-byte.png)


```
df | grep -E "/dev/sd" | egrep "/data|/data1" | awk '{total=total+$4}END{print total}'
```

```
[root@node01 zabbix_agentd.conf.d]# pwd
/opt/zabbix/etc/zabbix_agentd.conf.d

[root@node01 zabbix_agentd.conf.d]# cat userparameter_linux.conf

###TCP connection
UserParameter=net.conn.tcp.total,netstat -nt | grep ^tcp | wc -l

###number of total open files
UserParameter=custom.lsof.total,lsof -n|wc -l

### Calculate the total incoming traffic in bytes
UserParameter=net.in.total,cat /proc/net/dev | egrep -v 'bond0|lo' | sed -e "s/\(.*\)\:\(.*\)/\2/g" | sed 1,2d | awk '{in_bytes+=$1}END{print in_bytes}'

### Calculate the total outgoing traffic in bytes
UserParameter=net.out.total,cat /proc/net/dev | egrep -v 'bond0|lo' | sed -e "s/\(.*\)\:\(.*\)/\2/g" | sed 1,2d | awk '{out_bytes+=$9}END{print out_bytes}'

###Monitor Processs
UserParameter=user.process[*],ps -ef|grep "$1" |grep -v grep| wc -l

###To get virtualCpu of the host
UserParameter=user.cpu.vCpus.count,grep "model name" /proc/cpuinfo | wc -l

###To view the CPU usage of special process,$1=user $2=processName
UserParameter=user.process.cpu.usage[*],ps aux | grep $1 | grep $2 | grep -v grep|awk '{total+=$$3}END{print total}'

###To view the Memory usage of special process,$1=user $2=processName
UserParameter=user.process.memory.usage[*],ps aux | grep $1 | grep $2 | grep -v grep|awk '{total+=$$4}END{print total}'

###To get total data sata used disk size
UserParameter=user.disk.data.totalUsed[*],df | grep -E "/dev/sd" | egrep "$1" | grep -v "$2$" | awk '{total=total+$$3}END{print total}'

###To get total data sata free disk size
UserParameter=user.disk.data.totalFree[*],df | grep -E "/dev/sd" | egrep "$$1|$$2" | awk '{total=total+$$4}END{print total}'

###For Top Cpu usage process
#UserParameter=user.process.topCpu[*],ps aux |sort -k3rn | head -20 | awk -v up="$1" '{sum[$$11]=sum[$$11]+$$3}END{for(s in sum){if(sum[s]>=up)print sum[s],s}}'

###For Top Mem usage process
#UserParameter=user.process.topMem[*],ps aux |sort -k4rn | head -20 | awk -v up="$1" '{sum[$$11]=sum[$$11]+$$3}END{for(s in sum){if(sum[s]>=up)print sum[s],s}}'
```

  ![zabbix-disk-02](https://github.com/Lancger/opslinux/blob/master/images/zabbix-disk-02.png)


# 二、创建Disk容量管理模板

  ![zabbix-disk-03](https://github.com/Lancger/opslinux/blob/master/images/zabbix-disk-03.png)
  
# 三、创建Disk容量管理应用集

  ![zabbix-disk-05](https://github.com/Lancger/opslinux/blob/master/images/zabbix-disk-05.png)

# 四、创建Disk容量管理监控项
  
  1、主机特定磁盘总空间
  ```
  $1* Total  disk in bytes
  
  user.disk.data.total[/data,/data1]
  
  last("user.disk.data.totalFree[/data,/data1]")+last("user.disk.data.totalUsed[/data,/data1]")
  ```
  
  ![zabbix-disk-06](https://github.com/Lancger/opslinux/blob/master/images/zabbix-disk-06.png)
  
  
  2、主机特定磁盘剩余空间
  ```
  $1* Total free disk in bytes
  
  user.disk.data.totalFree[data,data1]
  ```
  
  ![zabbix-disk-07](https://github.com/Lancger/opslinux/blob/master/images/zabbix-disk-07.png)
  
  
  3、主机特定磁盘已使用空间
  ```
  $1* Total used disk in bytes
  
  user.disk.data.totalUsed[/data,/data1]
  ```
  
  ![zabbix-disk-08](https://github.com/Lancger/opslinux/blob/master/images/zabbix-disk-08.png)
  
  
  # 五、查看数据
  
   ![zabbix-disk-09](https://github.com/Lancger/opslinux/blob/master/images/zabbix-disk-09.png)

  
