# 项目概述
```
git项目地址：https://github.com/danielqsj/kafka_exporter

下载地址： https://github.com/danielqsj/kafka_exporter/releases/download/v1.2.0/kafka_exporter-1.2.0.linux-amd64.tar.gz

```

# grafana安装

```bash
docker rm -f grafana
docker run -d --name=grafana -v /etc/localtime:/etc/localtime:ro --restart=always -p 3000:3000 grafana/grafana
```

# prometheus启动

```
注：提前将需要挂载的目录创建好
mkdir -p /home/prometheus/
touch /home/prometheus/prometheus.yml
docker rm -f prometheus

docker run -d --name=prometheus -p 9090:9090 --restart=always -v /etc/localtime:/etc/localtime:ro  -v /home/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml  prom/prometheus
```

# 登陆到kafka服务器下载kafka_exporter

```
wget https://github.com/danielqsj/kafka_exporter/releases/download/v1.2.0/kafka_exporter-1.2.0.linux-amd64.tar.gz
tar -zxvf kafka_exporter-1.2.0.linux-amd64.tar.gz 
cd kafka_exporter-1.2.0.linux-amd64
./kafka_exporter --kafka.server=kafkaIP或者域名:9092 &
ss -tunl

注：9308是kafka_exporter的端口
```

# 登陆到prometheus服务器

编写/home/prometheus/prometheus.yml文件

```
cat > /home/prometheus/prometheus.yml <<\EOF
scrape_configs:
# The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
   - job_name: 'prometheus'
     static_configs:
      - targets: ['localhost:9090']
   - job_name: 'kafka'
     static_configs:
      - targets: ['192.168.56.11:9308']
        labels:
          #instance: kafka@kafkaIP或者域名
          instance: 192.168.56.11
EOF

重启prometheus

docker restart prometheus
```

`通过浏览器访问：http://prometheus服务器IP:9090,  所添加的kafka_exporter状态为UP，就可以去配置grafana`


参考链接：

https://blog.csdn.net/weixin_33911824/article/details/91529872

https://blog.csdn.net/qq_25934401/article/details/84840740   Prometheus监控之kafka（2种方式监控）


