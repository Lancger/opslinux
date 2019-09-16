## 一、zabbix-agentd配置文件
```
[root@web01 zabbix_agentd.d]# cat count_sn.conf 
################
#Author: Lancger
################
UserParameter=user.auto.login.count,ps -ef|grep -w ssh|grep -v grep|awk '{print $NF}'|wc -l


# 运行示例
[root@web01 zabbix_agentd.d]# ps -ef|grep -w ssh|grep -v grep|awk '{print $NF}'|wc -l
1
```

## 二、zabbix监控页面配置

  ![zabbix监控自定义连接数01](https://github.com/Lancger/opslinux/blob/master/images/zabbix-monitors-01.png)

## 三、zabbix日志检查数据是否上报ok
这里发现数据上报ok
```
[root@web01 zabbix_agentd.d]# tail -100f zabbix_agentd.log|grep auto

  8206:20181224:142309.131 for key [user.auto.login.count] received value [1]
  8206:20181224:142309.131 In process_value() key:'web01:user.auto.login.count' value:'1'
                        "key":"user.auto.login.count",
                        "key":"user.auto.login.count",
  8206:20181224:142334.149 In add_check() key:'user.auto.login.count' refresh:60 lastlogsize:0 mtime:0
```

## 四、页面检查数据

  ![zabbix监控自定义连接数02](https://github.com/Lancger/opslinux/blob/master/images/zabbix-monitors-02.png)
