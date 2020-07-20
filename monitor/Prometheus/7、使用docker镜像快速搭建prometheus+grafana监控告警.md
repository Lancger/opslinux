# 一、prometheus.yml配置文件如下
```bash
mkdir -p /data0/{prometheus,grafana}
mkdir -p /data0/prometheus/conf/

cat >/data0/prometheus/prometheus.yml<<\EOF
# my global config
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.

- job_name: 'promethus'
  static_configs:
     - targets: ['172.34.0.2:9090']
       labels:
        instance: 'Bite-Service-Monitor'
        platform: 'master'

- job_name: 'system'
  static_configs:
     - targets: ['172.34.0.2:9100']
       labels:
        instance: 'Monitor Service-01'
        platform: 'worker'

- job_name: 'pushgateway'
  honor_labels: true
  static_configs:
    - targets: ['103.106.208.136:9091']
      labels:
        instance: 'cfd-pushgateway'
        env: 'pro'

- job_name: 'DMC_HOST'
  file_sd_configs:
     - files: ['/etc/prometheus/conf/hosts.json']
EOF

#file_sd_configs参数形式配置主机列表
cat > /data0/prometheus/conf/hosts.json << \EOF
[
{
"targets": [
  "172.34.0.11:9100",
  "172.34.0.12:9100",
  "172.34.0.13:9100",
  "172.34.0.14:9100",
  "172.34.0.15:9100"
],
"labels": {
    "service": "bb-001",
    "env": "pro"
    }
},
{
"targets": [
  "172.34.0.21:9100",
  "172.34.0.22:9100",
  "172.34.0.23:9100",
  "172.34.0.24:9100",
  "172.34.0.25:9100"
],
"labels": {
    "service": "bb-002",
    "env": "pro"
    }
}
]
EOF
```

# 二、直接docker run运行
```bash
#1、Prometheus：
docker run -d --net=host \
    --restart=always \
    --privileged \
    --user=root \
    -p 9090:9090 \
    -v /data0/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
    -v /data0/prometheus/prometheus-data:/prometheus \
    -v /data0/prometheus/conf:/etc/prometheus/conf \
    -v /etc/localtime:/etc/localtime \
    --name prometheus \
    prom/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/prometheus

docker logs -f prometheus

docker exec -it $(docker ps -a|grep prometheus|awk '{print $1}') /bin/sh

date -R

#2、node-exporter
docker run -d --net=host \
    --restart=always \
    --privileged \
    --user=root \
    -v /etc/localtime:/etc/localtime \
    -p 9100:9100 \
    --name node-exporter \
    quay.io/prometheus/node-exporter

docker logs -f node-exporter

#3、Grafana:
docker run -d --net=host \
    --restart=always \
    --privileged \
    --user=root \
    -p 3000:3000 \
    -v /data0/grafana/grafana_data:/var/lib/grafana \
    -v /etc/localtime:/etc/localtime \
    --name grafana \
    grafana/grafana

docker logs -f grafana

docker exec -it $(docker ps -a|grep grafana|awk '{print $1}') /bin/sh

date -R

其中，/data/prometheus/prometheus.yml为prometheus的主要配置文件，/data/prometheus/conf为各种target的子配置文件

prometheus和grafana的镜像为官方镜像即可

#3、资源清理
docker rm -f prometheus
docker rm -f grafana

rm -rf /data0/{prometheus,grafana}
```

# 三、使用docker-compose运行
```bash
cat >/data0/prometheus/docker-compose-prometheus.yml<<\EOF
version: "3"

networks:
    monitor:
        driver: bridge

services:
  prometheus:
    image: prom/prometheus
    user: root
    networks:
     - monitor
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - /data0/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml    #prometheus主配置文件
      - /data0/prometheus/prometheus-data:/prometheus    #数据存储映射
      - /data0/prometheus/conf:/etc/prometheus/conf    #prometheus子配置文件路径
      - /etc/localtime:/etc/localtime    #设置容器时区
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'    #加载主配置文件
      - '--storage.tsdb.path=/prometheus'    #启动数据持久存储
      - '--web.enable-lifecycle'    # 支持热更新
    #environment:
    #  - TZ=Asia/Shanghai    #这个参数似乎在这里未生效
    restart: always

  node-exporter:
    image: quay.io/prometheus/node-exporter
    networks:
      - monitor
    container_name: node-exporter
    hostname: node-exporter
    volumes:
      - /etc/localtime:/etc/localtime    #设置容器时区
    ports:
      - "9100:9100"
    restart: always

  grafana:
    image: grafana/grafana
    user: root
    networks:
     - monitor
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - /data0/grafana/grafana_data:/var/lib/grafana    #数据存储映射
      - /etc/localtime:/etc/localtime    #设置容器时区
    restart: always
EOF

cd /data0/prometheus/

#启动容器：
docker-compose -f /data0/prometheus/docker-compose-prometheus.yml up -d

#删除容器：
docker-compose -f /data0/prometheus/docker-compose-prometheus.yml down

rm -rf /data0/{prometheus,grafana}

#重启容器：
docker-compose start/restart prometheus
docker-compose start/restart grafana
```

# 四、验证测试
```bash
# prometheus验证
http://103.106.208.13:9090/targets

# grafana验证
http://103.106.208.13:3000
账号密码：
admin/admin

# 添加prometheus和consul数据源需要写内网IP
Promethues设置Access选项选项Server(default)
```

# 五、安装consul数据库插件
```bash
# 安装consul数据源插件
docker exec -it $(docker ps -a|grep grafana|awk '{print $1}') /bin/sh

grafana-cli plugins install sbueringer-consul-datasource

docker restart $(docker ps -a|grep grafana|awk '{print $1}')

# 需要安装饼图的插件
docker exec -it $(docker ps -a|grep grafana|awk '{print $1}') /bin/sh

grafana-cli plugins install grafana-piechart-panel

docker restart $(docker ps -a|grep grafana|awk '{print $1}')
```

# 六、consul添加数据
```bash
cmdb/machines/bb-001/172.34.0.11:9100

cmdb/machines/bb-002/172.34.0.21:9100

```

参考资料：

https://github.com/prometheus/prometheus/issues/5976  err="open /prometheus/queries.active: permission denied"
