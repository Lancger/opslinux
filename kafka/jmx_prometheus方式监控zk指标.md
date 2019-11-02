# 一、下载jmx_prometheus_javaagent和zookeeper.yaml

```
#下载jmx程序包
cd /usr/local/src/
wget https://raw.githubusercontent.com/prometheus/jmx_exporter/master/example_configs/zookeeper.yaml
wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.6/jmx_prometheus_javaagent-0.6.jar

#移动到zookeeper程序目录
mkdir /usr/local/zookeeper/prometheus/
mv zookeeper.yaml /usr/local/zookeeper/prometheus/
mv jmx_prometheus_javaagent-0.6.jar /usr/local/zookeeper/prometheus/
```

# 二、编辑启动脚本
```bash
#打开 zkServer.sh 文件，注意加在脚本前面
vim /usr/local/zookeeper/bin/zkServer.sh

if [ "x$SERVER_JVMFLAGS"  != "x" ]
then
    JVMFLAGS="$SERVER_JVMFLAGS $JVMFLAGS"
fi

## 新增javaagent
JMX_DIR="/usr/local/zookeeper/prometheus"
JVMFLAGS="$JVMFLAGS -javaagent:$JMX_DIR/jmx_prometheus_javaagent-0.6.jar=9505:$JMX_DIR/zookeeper.yml"

if [ "x$2" != "x" ]
then
    ZOOCFG="$ZOOCFGDIR/$2"
fi
```

# 三、然后重启zookeeper
```
#服务停止
/usr/local/zookeeper/bin/zkServer.sh stop

#服务启动
/usr/local/zookeeper/bin/zkServer.sh start /usr/local/zookeeper/conf/zoo.cfg

#查看指标了
curl localhost:9505/metrics
```

# 四、修改prometheus配置
```
cat > /home/prometheus/prometheus.yml <<\EOF
scrape_configs:
# The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
   - job_name: 'zookeeper'
     static_configs:
      - targets: ['192.168.56.11:9505']
        labels:
          instance: 192.168.56.11_9505
EOF

#重启prometheus
docker restart prometheus
```

# 五、grafna导入视图
```
https://github.com/Lancger/opslinux/blob/master/kafka/kafka_dashboard.json

#注意使用在使用rate或者irate的时候，范围需要大于注意上报的最小时间间隔
rate(process_cpu_seconds_total{job="kafka"}[5m])  
```

参考资料：

https://www.cnblogs.com/bigberg/p/10118555.html  Prometheus jvm_exporter监控zookeeper

https://blog.csdn.net/qq_25934401/article/details/84840740  Prometheus 监控之 kafka

