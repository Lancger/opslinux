# 一、下载zookeeper_exporter

```bash
#下载jmx程序包
cd /usr/local/src/
wget https://github.com/carlpett/zookeeper_exporter/releases/download/v1.0.2/zookeeper_exporter

#移动到zookeeper程序目录
mkdir /usr/local/zookeeper/prometheus/
mv zookeeper_exporter /usr/local/zookeeper/prometheus/
```

# 二、启动zookeeper_exporter
```bash
/usr/local/zookeeper/prometheus/zookeeper_exporter

curl localhost:9141/metrics 
```

# 四、修改prometheus配置
```bash
cat > /home/prometheus/prometheus.yml <<\EOF
scrape_configs:
# The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
   - job_name: 'zk'   #注意这里的job名称需要为zk
     static_configs:
      - targets: ['192.168.56.11:9141']
        labels:
          instance: 192.168.56.11_9141
EOF

#重启prometheus
docker restart prometheus
```

# 五、grafna导入视图
```bash
#https://github.com/jiankunking/grafana-dashboards/blob/master/Prometheus_Zookeeper_Overview.json

https://github.com/Lancger/opslinux/blob/master/kafka/zookeeper_dashboard.json
```

参考资料：

https://blog.csdn.net/qq_25934401/article/details/84345905  

https://github.com/jiankunking/grafana-dashboards   Prometheus_Zookeeper_Overview.json
