# 一、下载jmx_prometheus_javaagent和zookeeper.yaml

```bash
#下载jmx程序包
cd /usr/local/src/
wget https://raw.githubusercontent.com/prometheus/jmx_exporter/master/example_configs/zookeeper.yaml
wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.6/jmx_prometheus_javaagent-0.6.jar

#移动到zookeeper程序目录
mkdir /usr/local/zookeeper/prometheus/
mv zookeeper.yaml /usr/local/zookeeper/prometheus/
mv jmx_prometheus_javaagent-0.6.jar /usr/local/zookeeper/prometheus/
```

# 二、配置jmx_prometheus
```bash
cat > /usr/local/zookeeper/conf/java.env <<\EOF
export JMX_DIR="/usr/local/zookeeper/prometheus"
export SERVER_JVMFLAGS="-javaagent:$JMX_DIR/jmx_prometheus_javaagent-0.6.jar=9505:$JMX_DIR/zookeeper.yaml $SERVER_JVMFLAGS"
EOF
```

# 三、然后重启zookeeper
```bash
#服务停止
/usr/local/zookeeper/bin/zkServer.sh stop

#服务启动
/usr/local/zookeeper/bin/zkServer.sh start /usr/local/zookeeper/conf/zoo.cfg

#查看指标了
curl localhost:9505/metrics
```

# 四、修改prometheus配置
```bash
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
```bash
https://grafana.com/grafana/dashboards/9236

#注意使用在使用rate或者irate的时候，范围需要大于注意上报的最小时间间隔
rate(process_cpu_seconds_total{job="zookeeper"}[5m])  
```

参考资料：

https://blog.csdn.net/qq_25934401/article/details/84345905

https://www.cnblogs.com/bigberg/p/10118555.html  Prometheus jvm_exporter监控zookeeper

https://blog.csdn.net/qq_25934401/article/details/84345905  Prometheus 监控之 zookeeper
