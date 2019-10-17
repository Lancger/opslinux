```
git项目地址：https://github.com/danielqsj/kafka_exporter

下载地址： https://github.com/danielqsj/kafka_exporter/releases/download/v1.2.0/kafka_exporter-1.2.0.linux-amd64.tar.gz

```

# grafana安装

```bash
docker run -d --name=grafana -v /etc/localtime:/etc/localtime:ro --restart=always -p 3000:3000 grafana/grafana
```

# prometheus启动

```
docker run -d --name=prometheus -p 9090:9090 --restart=always -v /etc/localtime:/etc/localtime:ro  -v /home/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml  prom/prometheus

注：提前将需要挂载的目录创建好
mkdir -pv /home/prometheus/
touch /home/prometheus/prometheus.yml
```

# 登陆到kafka服务器下载kafka_exporter

```
wget https://github.com/danielqsj/kafka_exporter/releases/download/v1.2.0/kafka_exporter-1.2.0.linux-amd64.tar.gz
tar -zxvf kafka_exporter-1.2.0.linux-amd64.tar.gz 
cd kafka_exporter-1.2.0.linux-amd64
./kafka_exporter --kafka.server=kafkaIP或者域名:9092 &
ss -tunl
```


