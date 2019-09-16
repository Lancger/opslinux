# 一、安装依赖
```
cd /tmp/
wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py
python get-pip.py
pip install --upgrade pip --trusted-host mirrors.aliyun.com -i https://mirrors.aliyun.com/pypi/simple/
pip install --upgrade setuptools==30.1.0
pip install simplejson --trusted-host mirrors.aliyun.com -i https://mirrors.aliyun.com/pypi/simple/  
```
# 二、编写自动发现脚本

1、配置jstack环境变量
```
#设置jstack环境变量
ln -s /opt/java/jdk1.8.0_211/bin/jstack /usr/local/sbin/jstack
chmod +s /bin/netstat

#注意项目路径的权限
chmod 755 /data0/opt/ -R

#修改客户端的sudoers文件
echo "zabbix ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/zabbix 
```

2、编写tomcat_name_discovery.py

```
#!/usr/bin/env python 
# -*- coding: UTF-8 -*-
import os
import subprocess
import simplejson as json

TOMCAT_HOME="/data0/opt"
# TOMCAT_NAME 自定义项目运行的tomcat的目录名称

TOMCAT_NAME="/bin/find %s -name 'server.xml' | sort -n | uniq -c | awk -F'/' '{print $4}'"%(TOMCAT_HOME)

#t=subprocess.Popen(args,shell=True,stdout=subprocess.PIPE).communicate()[0]
t=subprocess.Popen(TOMCAT_NAME,shell=True,stdout=subprocess.PIPE).communicate()[0]

tomcats=[]

for tomcat in t.split('\n'):
    if len(tomcat) != 0:
        tomcats.append({'{#TOMCAT_NAME}':tomcat})

# 打印出zabbix可识别的json格式
print json.dumps({'data':tomcats},sort_keys=True,indent=4,separators=(',',':'))
```

3、创建监控项脚本tomcat_status_monitor.sh
```
#!/bin/bash
######################################
# Usage: tomcat project status monitor
#
# Changelog:
# 2019-05-20 1151980610@qq.com create
######################################
# config zabbix sudo
# echo "zabbix ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/zabbix 

TOMCAT_NAME=$1
status=$2

TOMCAT_PID=`/usr/bin/ps -ef | grep "$TOMCAT_NAME" | grep "[o]rg.apache.catalina.startup.Bootstrap start" | grep -v grep | awk '{print $2}'`

jstack=`which jstack`

case $status in
     thread.num)

     # use jstack --help
     /usr/bin/sudo ${jstack} -l ${TOMCAT_PID} | grep http | grep -v grep | wc -l
     ;;

     *)
     echo "Usage: $0 {TOMCAT_NAME status[thread.num]}"
     exit 1
     ;;
esac
```

  ![tomcat-dis_01.png](https://github.com/Lancger/opslinux/blob/master/images/tomcat_dis_01.png)
  

# 三、测试运行结果
```
还需要注意项目权限zabbix有权限访问
chmod -R 755 /data0/opt

用zabbix用户测试
su - zabbix -c "/opt/zabbix/scripts/tomcat_name_discovery.py"

#测试自动发现
one-app-05<2019-05-21 08:35:32> /etc/zabbix/scripts
root># ./tomcat_name_discovery.py 
{
    "data":[
        {
            "{#TOMCAT_NAME}":"tomcat8_8080_job"
        },
        {
            "{#TOMCAT_NAME}":"tomcat8_8081_taskjob"
        },
        {
            "{#TOMCAT_NAME}":"tomcat8_8082_schedule"
        },
        {
            "{#TOMCAT_NAME}":"tomcat8_8083_inner"
        },
        {
            "{#TOMCAT_NAME}":"tomcat8_8084_match"
        },
        {
            "{#TOMCAT_NAME}":"tomcat8_8085_openapi"
        },
        {
            "{#TOMCAT_NAME}":"tomcat8_8086_console"
        }
    ]
}

#测试指标
root># zabbix_get -s 192.168.52.105 -p 10050 -k tomcat.status.thread_num[tomcat8_8080_job,thread.num]
14
```

# 四、客户端配置
在客户端配置文件中添加自定义的监控项key，示例如下：
```
cd /etc/zabbix/zabbix_agentd.d/

cat userparameter_tomcat.conf 
# 变量1的key定义为：tomcat.name.discovery, 是脚本自动发现的tomcat实例名称，获取途径是执行tomcat_name_discovery.py
UserParameter=tomcat.name.discovery, /etc/zabbix/scripts/tomcat_name_discovery.py
# 变量2的key自定义为：tomcat.status.thread_num, [*]表示需要变量支持，$1,$2(脚本中$2,即tomcat的监控项自定义，监控项可添加)，获取途径执行：tomcat_status_monitor.sh
UserParameter=tomcat.status.thread_num[*], /etc/zabbix/scripts/tomcat_status_monitor.sh $1 $2
```

# 五、zabbix界面添加自动发现模板


参考文档：

https://segmentfault.com/a/1190000014808036   zabbix监控tomcat多实例（自动发现，主动模式）
