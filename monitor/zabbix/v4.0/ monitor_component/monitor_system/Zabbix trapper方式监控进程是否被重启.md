# 一、服务脚本

monitor_touch_process.sh

```
#!/bin/bash

cd `dirname $0`

check_all(){
schedule_ret=0
i=0
while [ $i -lt 5 ]
do
    i=$(($i+1))
    schedule_ret=`ps -ef | grep touch | grep -v grep > /dev/null 2>&1 && echo $?`
    if [ -z $schedule_ret ] ;then
           sleep 1
           continue
    fi
   /usr/bin/zabbix_sender -c /etc/zabbix/zabbix_agentd.conf -k scheduler.alive -o 1 -s node1
   break;
done

datetime=`date +'%Y%m%d %H:%M:%S'`
if [ -z $schedule_ret ] ;then
    echo "scheduler was started at $datetime..." >> /usr/local/touch/log/start.log
    /usr/bin/zabbix_sender -c /etc/zabbix/zabbix_agentd.conf -k scheduler.alive -o 0 -s node1
    cd /usr/local/touch/bin && ./start_touch.sh
    exit 0
fi
}

check_all
```

# 二、定时任务
```
* * * * * /usr/bin/monitor_touch_process.sh  > /dev/null 2>&1
```
