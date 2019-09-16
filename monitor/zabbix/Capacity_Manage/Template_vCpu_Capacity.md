# 一、创建CPU容量管理模板

  ![zabbix-cap-01](https://github.com/Lancger/opslinux/blob/master/images/zabbix-cap-01.png)
  
# 二、创建CPU容量管理应用集

  ![zabbix-cap-02](https://github.com/Lancger/opslinux/blob/master/images/zabbix-cap-02.png)

# 三、创建CPU容量管理监控项

  ![zabbix-cap-03](https://github.com/Lancger/opslinux/blob/master/images/zabbix-cap-03.png)
  
  ![zabbix-cap-04](https://github.com/Lancger/opslinux/blob/master/images/zabbix-cap-04.png)


## 1、zabbix_agentd对应的采集配置文件

```
[root@node-01 zabbix_agentd.conf.d]# cat userparameter_linux.conf
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
UserParameter=user.disk.data.totalFree[*],df | grep -E "/dev/sd" | egrep "$1" | grep -v "$2$" | awk '{total=total+$$4}END{print total}'

###For Top Cpu usage process
#UserParameter=user.process.topCpu[*],ps aux |sort -k3rn | head -20 | awk -v up="$1" '{sum[$$11]=sum[$$11]+$$3}END{for(s in sum){if(sum[s]>=up)print sum[s],s}}'

###For Top Mem usage process
#UserParameter=user.process.topMem[*],ps aux |sort -k4rn | head -20 | awk -v up="$1" '{sum[$$11]=sum[$$11]+$$3}END{for(s in sum){if(sum[s]>=up)print sum[s],s}}'
```

## 2、根据CPU使用率计算出当前使用CPU的个数

  ![zabbix-cap-05](https://github.com/Lancger/opslinux/blob/master/images/zabbix-cap-05.png)
  
  获取CPU使用率
  
  ```
  CPU Pused average 5 minutes     
  
  100-last("system.cpu.util[,idle,avg5]",0)   #system.cpu.util[,idle,avg5]表示5分钟的一个空闲率
  ```
  
  ![zabbix-cap-08](https://github.com/Lancger/opslinux/blob/master/images/zabbix-cap-08.png)

  
## 3、根据CPU使用率计算出当前空闲CPU的个数

  ![zabbix-cap-06](https://github.com/Lancger/opslinux/blob/master/images/zabbix-cap-06.png)
  
## 4、CPU容量管理总览

  ![zabbix-cap-07](https://github.com/Lancger/opslinux/blob/master/images/zabbix-cap-07.png)
