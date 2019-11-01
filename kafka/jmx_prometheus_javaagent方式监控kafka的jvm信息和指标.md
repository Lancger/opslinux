# 一、下载jmx_prometheus_javaagent和kafka.yml

```
cd /usr/local/src/
wget https://raw.githubusercontent.com/prometheus/jmx_exporter/master/example_configs/kafka-0-8-2.yml
wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.6/jmx_prometheus_javaagent-0.6.jar
```

# 二、打开
```bash
#打开 kafka-server-start.sh 文件

export JMX_PORT="9999"
export KAFKA_OPTS="-javaagent:/path/jmx_prometheus_javaagent-0.6.jar=9991:/path/kafka-0-8-2.yml"
```

# 三、然后重启kafka。
```
访问 http://localhost:9991/metrics 可以看到各种指标了。
```

参考资料：

https://blog.csdn.net/qq_25934401/article/details/84840740  Prometheus 监控之 kafka
