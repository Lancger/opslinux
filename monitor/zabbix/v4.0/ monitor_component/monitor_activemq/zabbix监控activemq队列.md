
公司业务使用activemq5.9.1消息队列，由于队列阻塞导致程序端口无响应，并且telnet无法连通。经过over 1 hour的排查，最终定位原因activemq导致。遂写了一个监控activemq队列信息的脚本。

    
# 一、脚本部分
```
[root@localhost ~]# cat activemqqueue.sh 
#!/bin/bash
#author：xkops
#define common info
HOST=10.44.144.92
PORT=8161
USER=admin
PASSWORD=admin

#obtain queue's Pending,Consumers,Enqueued,Dequeued
function Queue()
{
  Count=$(curl -u"$USER":"$PASSWORD" http://$HOST:$PORT/admin/queues.jsp 2> /dev/null |grep -A 5 "^$1"|grep -oP '\d+');
  #echo $Count
  Pending=$(echo $Count |awk '{print $1}');
  #echo $Count
  Consumers=$(echo $Count |awk '{print $2}');
  Enqueued=$(echo $Count |awk '{print $3}');
  Dequeued=$(echo $Count |awk '{print $4}');
  #EndeltaDn=$(($Enqueued - $Dequeued))
  #echo '-------------'
  #echo -e "$Pending\n$Consumers\n$Enqueued\n$Dequeued";
  #echo "$2"
  if [ "$2" = '' ];then
     exit
  fi
  if [ "$2" = 'Pending' ];then
    echo $Pending
  elif [ "$2" = 'Consumers' ];then
    echo $Consumers
  elif [ "$2" = 'Enqueued' ];then
    echo $Enqueued
  #elif [ "$2" = 'EndeltaDn' ];then
  #  echo $EndeltaDn
  else
    echo $Dequeued
  fi
}

#call function and input queue_name queue_type
Queue $1 $2
```

# 二、测试脚本

1、测试执行脚本，需要传入2个参数，其中一个是对列名称，一个是队列类型（如Pending,Consumers,Enqueued,Dnqueued）

```
[root@localhost ~]# bash activemqqueue.sh message.push Consumers
32
```

# 三、zabbix监控部分

1.编辑配置文件
```
[root@localhost ~]# cat /etc/zabbix/zabbix_agentd.d/userparameter_activemqqueue.conf
# monitor tomcat process and port
UserParameter=tomcatamqqueue[*],/etc/scripts/activemqqueue.sh $1 $2
```

2.创建zabbix模板，并传递相应的队列名称和队列类型。根据下图依次创建自己的item。

3.创建展示Pending,Consumers,Enqueued,Dequeued等图表。

4.触发报警，当Pending的值大于某一个值时报警，比如1000。

5.邮件发送。


参考文档：

https://www.cnblogs.com/xkops/p/5591983.html  zabbix监控activemq队列脚本

https://www.cnblogs.com/yexiaochong/p/6149700.html   Zabbix 监控rabbitmq
