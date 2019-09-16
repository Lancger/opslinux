# 一、服务器已使用内存统计（在基础模版中）

```
#Template OS Linx 模板中

参数vm.memory.size

    total – 总物理内存.
    free – 可用内存.
    active – 内存当前使用或最近使用，所以它在RAM中。
    inactive – 未使用内存.
    wired – 被标记为始终驻留在RAM中的内存，不会移动到磁盘。
    pinned – 和’wired’一样。
    anon – 与文件无关的内存(不能重新读取)。
    exec – 可执行代码，通常来自于一个(程序)文件。
    file – 缓存最近访问文件的目录。
    buffers – 缓存文件系统元数据。
    cached – 缓存为不同事情。
    shared – 可以同时被多个进程访问的内存。
    used – active + wired 内存。
    pused – active + wired 总内存的百分比。
    available – inactive + cached + free 内存。
    pavailable – inactive + cached + free memory 占’total’的百分比。
    

#已使用内存
Pused memory in %   ---  custom.memory.pused

100-last("vm.memory.size[pavailable]",0)
```

  ![zabbix-mem-04](https://github.com/Lancger/opslinux/blob/master/images/zabbix-mem-04.png)

  ![zabbix-mem-01](https://github.com/Lancger/opslinux/blob/master/images/zabbix-mem-01.png)
  
# 二、创建MEM容量管理模板

  ![zabbix-mem-02](https://github.com/Lancger/opslinux/blob/master/images/zabbix-mem-02.png)
  
# 三、创建MEM容量管理应用集

  ![zabbix-mem-03](https://github.com/Lancger/opslinux/blob/master/images/zabbix-mem-03.png)

# 四、创建MEM容量管理监控项
  
  1、集群平均内存使用率
  ```
  $1 Cluster Avg Memory Usage
  
  grpavg["{$HOSTGROUP}","custom.memory.pused","last","0"]
  ```
  
  ![zabbix-mem-05](https://github.com/Lancger/opslinux/blob/master/images/zabbix-mem-05.png)
  
  
  2、集群可用内存
  ```
  $1 Cluster Available Memory in bytes
  
  grpsum["{$HOSTGROUP}","custom.memory.free.size","last","0"]
  ```
  
  ![zabbix-mem-06](https://github.com/Lancger/opslinux/blob/master/images/zabbix-mem-06.png)
  
  
  3、集群总内存数
  ```
  $1 Cluster Total Memory in bytes
  
  grpsum["{$HOSTGROUP}","vm.memory.size[total]","last","0"]
  ```
  
  ![zabbix-mem-07](https://github.com/Lancger/opslinux/blob/master/images/zabbix-mem-07.png)
  
 
# 五、创建一个新主机专门放聚合监控项
  
  1、创建一个主机
  
  ![zabbix-mem-08](https://github.com/Lancger/opslinux/blob/master/images/zabbix-mem-08.png)
  
  2、给新建主机添加一个宏变量，是聚合哪个分组的数据
  
  ![zabbix-mem-09](https://github.com/Lancger/opslinux/blob/master/images/zabbix-mem-09.png)
  
  3、给新建主机关联聚合内存计算的模板
  
  ![zabbix-mem-10](https://github.com/Lancger/opslinux/blob/master/images/zabbix-mem-10.png)
  
  4、查看聚合的数据
  
  ![zabbix-mem-11](https://github.com/Lancger/opslinux/blob/master/images/zabbix-mem-11.png)

  
参考文档：

https://www.jianshu.com/p/bcfa2c8d07ef    zabbix 项目组 | 合并检测

