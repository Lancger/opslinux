# 一、软件包下载
```
cd /usr/local/src/

export version="7.2.0"
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${version}-linux-x86_64.tar.gz
wget https://artifacts.elastic.co/downloads/kibana/kibana-${version}-linux-x86_64.tar.gz
wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${version}-linux-x86_64.tar.gz
wget https://artifacts.elastic.co/downloads/logstash/logstash-${version}.tar.gz
```
# 二、配置Elasticsearch实现冷热数据分离

为了不浪费服务器资源（每台机器上均配置有SSD和大存储,且内存配置较高），提高ES读写性能，我们尝试进行了ES集群冷热分离的配置。四台机器，均配置有SSD和SATA盘。每台机器上运行两个ES实例，其中一个实例为配置data目录为SSD

1、默认情况下，每个节点都有成为主节点的资格，也会存储数据，还会处理客户端的请求。    

2、在一个生产集群中我们可以对这些节点的职责进行划分。建议集群中设置3台以上的节点作为master节点【node.master: true node.data: false】，这些节点只负责成为主节点，维护整个集群的状态。           

3、再根据数据量设置一批data节点【node.master: false node.data: true】，这些节点只负责存储数据，后期提供建立索引和查询索引的服务，这样的话如果用户请求比较频繁，这些节点的压力也会比较大。     

4、在集群中建议再设置一批client节点【node.master: false node.data: true】，这些节点只负责处理用户请求，实现请求转发，负载均衡等功能。          

5、master节点：普通服务器即可(CPU 内存 消耗一般)。         

data节点：主要消耗磁盘，内存。            

client节点：普通服务器即可(如果要进行分组聚合操作的话，建议这个节点内存也分配多一点)。

  ![elasticsearch冷热架构](https://github.com/Lancger/opslinux/blob/master/images/es-hot-cold.png)

```
SSD  热数据
SATA 冷数据
```
| 服务器名称         | 端口            | 节点名称     |  磁盘类型  |  存储数据  |                    角色                  |
| ---------------- |:---------------:| :---------:| :--------:| :--------:| ---------------------------------------:|
| server-01        | 9300            | es-master1  |   SATA   |  元数据    | filebeat+es_master+kafka+zookeeper      |
| server-02        | 9300            | es-master2  |   SATA   |  元数据    | filebeat+es_master+kafka+zookeeper      |
| server-03        | 9300            | es-master3  |   SATA   |  元数据    | filebeat+es_master+kafka+zookeeper      |
| server-01        | 9301            | es-hot1     |   SSD    |  HOT      | es_data_node                            |
| server-02        | 9301            | es-hot2     |   SSD    |  HOT      | es_data_node                            |
| server-03        | 9301            | es-hot3     |   SSD    |  HOT      | es_data_node                            |
| server-04        | 9300            | es-cold1    |   SATA   |  COLD     | filebeat+es_data_node+kibana            |
| server-04        | 9301            | es-cold2    |   SATA   |  COLD     | es_data_node                            |


# 三、准备Elasticsearch

1、安装Java环境
```
#yum安装
yum -y install java-1.8.0-openjdk

#源码安装
java   http://www.oracle.com/technetwork/java/javase/downloads/index.html 

tar -zxvf jdk-8u201-linux-x64.tar.gz -C /opt/

#Set JAVA_HOME
export JAVA_HOME=/opt/jdk1.8.0_201
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar

使环境变量生效
source /etc/profile

验证安装是否成功
java -version
```


2、新增用户和系统配置
```
0、主机hosts绑定
cat > /etc/hosts <<EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
10.1.5.112 server-01
10.1.5.116 server-02
10.1.5.117 server-03
10.1.5.120 server-04
EOF

1、新增用户和解压安装包
chattr -i /etc/passwd* && chattr -i /etc/group* && chattr -i /etc/shadow* && chattr -i /etc/gshadow*
groupadd elk
useradd -g elk elk
mkdir -p /usr/local/elk/

tar -zxvf elasticsearch-${version}-linux-x86_64.tar.gz -C /usr/local/elk
cd /usr/local/elk
mv elasticsearch-${version} elasticsearch        #master实例
cp -rf elasticsearch elasticsearch-hot      #热数据es实例
cp -rf elasticsearch elasticsearch-cold     #冷数据es实例
chown -R elk:elk /usr/local/elk/

2、增加vm.max_map_count项到sysctl.conf文件中
a、修改配置文件方式
vim /etc/sysctl.conf
vm.max_map_count = 655360
sysctl -p

b、命令行方式
sysctl -w vm.max_map_count=655360
sysctl -a | grep vm.max_map_count

3、修改用户文件最大数量
vim /etc/security/limits.conf 
elk        hard    nofile           262144
elk        soft    nofile           262144

4、修改内存限制
vim /etc/security/limits.conf
# allow user 'elk' mlockall
elk soft memlock unlimited
elk hard memlock unlimited
```

3、修改配置文件
```
#创建元数据存放目录
mkdir -p /data0/database/elasticsearch/ /data1/database/elasticsearch/

#创建热数据存放目录
mkdir -p /data0/database/elasticsearch-hot/ /data1/database/elasticsearch-hot/

#创建冷数据存放目录
mkdir -p /data0/database/elasticsearch-cold/ /data1/database/elasticsearch-cold/

chown -R elk:elk /data0/database/ /data1/database/
```
master节点配置
```
3个master节点只需要替换下面配置即可

node.name: es-master1    #配置节点名称
node.name: es-master2    #配置节点名称
node.name: es-master3    #配置节点名称
```
元数据节点配置
```
cat << EOF > /usr/local/elk/elasticsearch/config/elasticsearch.yml
#配置集群名称
cluster.name: Demo-Cloud
#配置节点名称 
node.name: es-master1
#允许每个机器启动两个es进程
node.max_local_storage_nodes: 2
#指定该节点是否有资格被选举成为node，默认是true，es是默认集群中的第一台机器为master，如果这台机挂了就会重新选举master。
node.master: true
#指定该节点是否存储索引数据，默认为true。
node.data: false
#配置data存放的路径，磁盘为ssd磁盘
path.data: /data0/database/elasticsearch/,/data1/database/elasticsearch/
#配置日志存放的路径
path.logs: /usr/local/elk/elasticsearch/logs
#配置是否使用内存交换分区
bootstrap.memory_lock: false 
#配置是否启用检测
bootstrap.system_call_filter: false
#设置内容的最大容量，默认100mb
http.max_content_length: 1000mb
# 开启安全防护
http.cors.enabled: true
http.cors.allow-origin: "*"
#http.cors.allow-headers: Authorization,X-Requested-With,Content-Length,Content-Type
#网关地址
network.host: 0.0.0.0
#配置监听端口
http.port: 9200  
#设置节点之间交互的tcp端口，默认是9300
transport.tcp.port: 9300
#时间放长，防止脑裂 
discovery.zen.ping_timeout: 120s 
client.transport.ping_timeout: 60s
#设置集群中N个节点启动时进行数据恢复，默认为3
gateway.recover_after_nodes: 3
#配置有机会参与选举为master的节点
discovery.seed_hosts: ["server-01:9300", "server-01:9301", "server-02:9300", "server-02:9301", "server-03:9300", "server-03:9301"]
cluster.initial_master_nodes: ["es-master1", "es-master2", "es-master3"]
EOF
```
热数据节点配置
```
cat << EOF > /usr/local/elk/elasticsearch-hot/config/elasticsearch.yml
#配置集群名称
cluster.name: Demo-Cloud
#配置节点名称 
node.name: es-hot1
node.attr.tag: hot
node.attr.box_type: hot
#允许每个机器启动两个es进程
node.max_local_storage_nodes: 2
#指定该节点是否有资格被选举成为node，默认是true，es是默认集群中的第一台机器为master，如果这台机挂了就会重新选举master。
node.master: false
#指定该节点是否存储索引数据，默认为true。
node.data: true
#配置data存放的路径，磁盘为ssd磁盘
path.data: /data0/database/elasticsearch-hot/,/data1/database/elasticsearch-hot/
#配置日志存放的路径
path.logs: /usr/local/elk/elasticsearch-hot/logs
#配置是否使用内存交换分区
bootstrap.memory_lock: false 
#配置是否启用检测
bootstrap.system_call_filter: false
#设置内容的最大容量，默认100mb
http.max_content_length: 1000mb
# 开启安全防护
http.cors.enabled: true
http.cors.allow-origin: "*"
#http.cors.allow-headers: Authorization,X-Requested-With,Content-Length,Content-Type
#网关地址
network.host: 0.0.0.0
#配置监听端口
http.port: 9201  
#设置节点之间交互的tcp端口，默认是9300
transport.tcp.port: 9301
#时间放长，防止脑裂 
discovery.zen.ping_timeout: 120s 
client.transport.ping_timeout: 60s
#设置集群中N个节点启动时进行数据恢复，默认为3
gateway.recover_after_nodes: 3
#配置有机会参与选举为master的节点
discovery.seed_hosts: ["server-01:9300", "server-01:9301", "server-02:9300", "server-02:9301", "server-03:9300", "server-03:9301"]
cluster.initial_master_nodes: ["es-master1", "es-master2", "es-master3"]
EOF
```
冷数据节点配置
```
cat << EOF > /usr/local/elk/elasticsearch-cold/config/elasticsearch.yml
#配置集群名称
cluster.name: Demo-Cloud
#配置节点名称 
node.name: es-cold1
node.attr.tag: cold
node.attr.box_type: cold
#允许每个机器启动两个es进程
node.max_local_storage_nodes: 2
#指定该节点是否有资格被选举成为node，默认是true，es是默认集群中的第一台机器为master，如果这台机挂了就会重新选举master。
node.master: false
#指定该节点是否存储索引数据，默认为true。
node.data: true
#配置data存放的路径，磁盘为ssd磁盘
path.data: /data0/database/elasticsearch-cold/,/data1/database/elasticsearch-cold/
#配置日志存放的路径
path.logs: /usr/local/elk/elasticsearch-cold/logs
#配置是否使用内存交换分区
bootstrap.memory_lock: false 
#配置是否启用检测
bootstrap.system_call_filter: false
#设置内容的最大容量，默认100mb
http.max_content_length: 1000mb
# 开启安全防护
http.cors.enabled: true
http.cors.allow-origin: "*"
#http.cors.allow-headers: Authorization,X-Requested-With,Content-Length,Content-Type
#网关地址
network.host: 0.0.0.0
#配置监听端口
http.port: 9200  
#设置节点之间交互的tcp端口，默认是9300
transport.tcp.port: 9300
#时间放长，防止脑裂 
discovery.zen.ping_timeout: 120s 
client.transport.ping_timeout: 60s
#设置集群中N个节点启动时进行数据恢复，默认为3
gateway.recover_after_nodes: 3
#配置有机会参与选举为master的节点
discovery.seed_hosts: ["server-01:9300", "server-01:9301", "server-02:9300", "server-02:9301", "server-03:9300", "server-03:9301"]
cluster.initial_master_nodes: ["es-master1", "es-master2", "es-master3"]
EOF
```
4、启动elasticsearch
```
su - elk

/usr/local/elk/elasticsearch/bin/elasticsearch -d

/usr/local/elk/elasticsearch-hot/bin/elasticsearch -d

/usr/local/elk/elasticsearch-cold/bin/elasticsearch -d

#停止服务,清理数据
ps -ef|grep elasticsearch|grep -v grep|awk '{print $2}'|xargs kill -9

rm -rf /data0/database/elasticsearch/*
rm -rf /data0/database/elasticsearch-hot/*
rm -rf /data0/database/elasticsearch-cold/*

rm -rf /data1/database/elasticsearch/*
rm -rf /data1/database/elasticsearch-hot/*
rm -rf /data1/database/elasticsearch-cold/*

rm -rf /usr/local/elk/elasticsearch/logs/*
rm -rf /usr/local/elk/elasticsearch-hot/logs/*
rm -rf /usr/local/elk/elasticsearch-cold/logs/*
```

# 三、集群健康检查
```
1、集群健康
##在一个没有索引的空集群中运行如上查询，将返回这些信息：
root># curl '127.0.0.1:9200/_cat/health?v'
epoch      timestamp cluster    status node.total node.data shards pri relo init unassign pending_tasks max_task_wait_time active_shards_percent
1563850517 02:55:17  Demo-Cloud green           6         3      0   0    0    0        0             0                  -                100.0%

2、节点列表
root># curl '127.0.0.1:9200/_cat/nodes?v'
ip         heap.percent ram.percent cpu load_1m load_5m load_15m node.role master name
10.10.0.18           28          29   0    0.00    0.04     0.09 di        -      es-hot1
10.10.0.5            28          23   0    0.00    0.02     0.06 di        -      es-hot2
10.10.0.9            27          22   0    0.00    0.02     0.05 di        -      es-hot3
10.10.0.18           20          29   0    0.00    0.04     0.09 mi        *      es-master1
10.10.0.9            22          22   0    0.00    0.02     0.05 mi        -      es-master3
10.10.0.5            22          23   0    0.00    0.02     0.06 mi        -      es-master2

3、调整分片和副本数（kibana里面的devtools）
PUT _template/default_template
{
  "index_patterns" : ["*"], 
  "settings": {
    "number_of_shards": 3,
    "number_of_replicas" : 1
  }
}
```

# 四、插件安装

## 1、Cerebro是一款Elasticsearch监控工具

```

tar -zxvf cerebro-0.8.3.tgz -C /usr/local/elk/

tee /usr/local/elk/cerebro-0.8.3/conf/application.conf << 'EOF'
secret="ki:s:[[@=Ag?QI`W2jMwkY:eqvrJ]JqoJyi2axj3ZvOv^/KavOT4ViJSv?6YY4[N"

basePath="/"

pidfile.path="/usr/local/elk/cerebro-0.8.3/cerebro.pid"
data.path="/usr/local/elk/cerebro-0.8.3/data/cerebro.db"

es={
    gzip=true
}

auth={
    type: basic
    settings: {
        username="admin"
        password="Admin_2019"
    }
}

hosts=[
  {
    host="http://localhost:9200"
    name="es_log"
  }
]
EOF

#添加cerebro配置到Supervisor
yum install -y epel-release supervisor
systemctl enable supervisord
systemctl restart supervisord

tee /etc/supervisord.d/cerebro.ini << 'EOF'
[program:cerebro-node]
command     = /usr/local/elk/cerebro-0.8.3/bin/cerebro -Dhttp.port=1234 -Dhttp.address=0.0.0.0
directory   = /usr/local/elk/cerebro-0.8.3/
user        = elk
startsecs   = 3
environment=JAVA_HOME="/opt/java/jdk1.8.0_221"

redirect_stderr         = true
stdout_logfile_maxbytes = 100MB
stdout_logfile_backups  = 10
stdout_logfile          = /usr/local/elk/cerebro-0.8.3/logs/supervisor_cerebro.log
EOF

#启动
supervisorctl restart  cerebro-node
supervisorctl status

tail -100f /usr/local/elk/cerebro-0.8.3/logs/supervisor_cerebro.log

#访问
http://10.10.0.18:1234/#/overview?host=es_log
```

## 2、Elasticsearch 安装 Head 插件
```
#方式一
cd /usr/local/elk/
git clone git://github.com/mobz/elasticsearch-head.git
cd elasticsearch-head
npm install --unsafe-perm
nohup npm run start &

http://localhost:9100/

#方式二
或者直接使用谷歌浏览器ElasticSearch Head插件
https://blog.csdn.net/qq_40990854/article/details/81315879
```

# 五、准备kibana
```
tar -zxvf kibana-7.2.0-linux-x86_64.tar.gz 
mv kibana-7.2.0-linux-x86_64 kibana
mv kibana /usr/local/elk/

tee /usr/local/elk/kibana/config/kibana.yml << 'EOF'
server.port: 5601
server.host: "0.0.0.0"
server.name: "kibana"
elasticsearch.hosts: ["http://localhost:9200"]
i18n.locale: "zh-CN"
EOF

cd /usr/local/elk/kibana/bin
nohup ./kibana --allow-root >/dev/null 2>&1 &

http://localhost:5601/status
```

# 六、Logstash配置
```
tar -zxvf logstash-7.2.0.tar.gz
mv logstash-7.2.0 logstash
mv logstash /usr/local/elk/

tee /usr/local/elk/logstash/config/logstash.yml << 'EOF'
path.data: /usr/local/elk/logstash/data
path.logs: /usr/local/elk/logstash/logs
EOF

#console控制台测试
/usr/local/elk/logstash/bin/logstash -e 'input {  stdin{} } output { stdout{  codec => rubydebug }}'

/usr/local/elk/logstash/vendor/bundle/jruby/2.5.0/gems/awesome_print-1.7.0/lib/awesome_print/formatters/base_formatter.rb:31: warning: constant ::Fixnum is deprecated
{
      "@version" => "1",
          "host" => "server-01",
       "message" => "",
    "@timestamp" => 2019-07-23T08:55:42.554Z
}
{
      "@version" => "1",
          "host" => "server-01",
       "message" => "",
    "@timestamp" => 2019-07-23T08:55:42.766Z
}

#测试写入es单机
 /usr/local/elk/logstash/bin/logstash -e 'input {stdin{}} output{ elasticsearch { hosts => ["127.0.0.1:9200"] index => "test"}}'

#测试写入es集群
/usr/local/elk/logstash/bin/logstash -e 'input {stdin{}} output{ elasticsearch { hosts => ["server-01:9200", "server-02:9200", "server-03:9200"] index => "test01"}}'

#采集nginx日志logstash配置
cat << EOF > /usr/local/elk/logstash/config/nginx.conf
input{
    file{
        path => "/var/log/nginx/access.log"
        start_position => "end"
        type => "nginx-access-log"
        codec => "json"
    }
}

output{
    stdout {
        codec => rubydebug
    }
    file{
        path => "/tmp/123.txt"
    }
}
EOF

#logstash配置文件测试
cd  /usr/local/elk/logstash/bin
./logstash -f /usr/local/elk/logstash/config/nginx.conf -t

#从logstash中读取日志输出到ES集群
cat << EOF > /usr/local/elk/logstash/config/logstash-es.conf
input {
    beats {
        host => "0.0.0.0"
        port => 9600
    }
}

filter {
   grok {
      match => { "message" => "%{IPORHOST:remote_ip} - %{DATA:user_name} \[%{HTTPDATE:access_time}\] \"%{WORD:http_method} %{DATA:url} HTTP/%{NUMBER:http_version}\" %{NUMBER:response_code} %{NUMBER:body_sent_bytes} \"%{DATA:referrer}\" \"%{DATA:agent}\"" }
        }
}

output {
    if [fields][file_tag] == "nginx-log-beat" {
        elasticsearch {
            hosts => ["server-01:9200", "server-02:9200", "server-03:9200"]
            index => "nginx-log-es-%{+YYYY.MM.dd}"
        }
    }
    if [fields][file_tag] == "secure-beat" {
        elasticsearch {
            hosts => ["server-01:9200", "server-02:9200", "server-03:9200"]
            index => "secure-es-%{+YYYY.MM.dd}"
        }
    }
    if [fields][file_tag] == "tomcat7_18081_home_web" {
        elasticsearch {
            hosts => ["server-01:9200", "server-02:9200", "server-03:9200"]
            index => "tomcat7_18081_home_web-%{+YYYY.MM.dd}"
        }
    }
    #stdout { 
    #    codec => rubydebug 
    #}
}
EOF

#模拟产生nginx日志
#第一个终端
while true ; do n=$(( RANDOM % 5 )) ; curl "10.10.0.18/?$n" ; sleep $n ; done

#第二个终端测试解析日志
cd /usr/local/elk/logstash/bin

nohup /usr/local/elk/logstash/bin/logstash -f /usr/local/elk/logstash/config/logstash-es.conf > /dev/null &

#--config.reload.automatic自动监听配置修改而无需重启，跟nginx -s reload一样，挺实用的
cd /usr/local/elk/logstash/bin
nohup ./logstash -f ../config/logstash-es.conf --config.reload.automatic >/dev/null 2>&1 &

#停止服务
ps -ef|grep logstash|grep -v grep|awk '{print $2}'|xargs kill
```

# 七、准备filebeat

filebeat必须属于root用户
```
Exiting: error loading config file: config file ("filebeat.yml") must be owned by the user identifier (uid=0) or root
```

```
tar -zxvf filebeat-7.2.0-linux-x86_64.tar.gz
mv filebeat-7.2.0-linux-x86_64 filebeat
mv filebeat /usr/local/elk/

#file采集的日志输出到logstash集群（9600 logstash端口）
tee /usr/local/elk/filebeat/filebeat.yml << 'EOF'
filebeat.inputs:
######nginx_log######
- type: log
  enabled: true
  paths:
    /var/log/nginx/*.log
  exclude_files: ['.gz$']
  tags: ["nginx-log"]
  fields:
    file_tag: nginx-log-beat
######nginx_log#######

######secure_log######
- type: log
  enabled: true
  paths:
    /var/log/secure
  exclude_files: ['.gz$']
  tags: ["secure"]
  fields:
    file_tag: secure-beat
######secure_log######

######tomcat_log######
- type: log
  enabled: true
  paths:
    /data0/opt/tomcat7_18081_home_web/logs/*.out
  exclude_files: ['.gz$']
  tags: ["secure"]
  fields:
    file_tag: tomcat7_18081_home_web
######tomcat_log######

filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false
output.logstash:
  hosts: ["server-01:9600", "server-02:9600", "server-03:9600"]
processors:
  - add_host_metadata: ~
  - add_cloud_metadata: ~
EOF

chown -R root:root /usr/local/elk/filebeat/

控制台启动，方便调试
cd /usr/local/elk/filebeat/
./filebeat -e -c filebeat.yml

调试完成，后台启动Filebeat
nohup ./filebeat -e -c filebeat.yml > /dev/null &
```

参考文档

https://segmentfault.com/a/1190000016112645  简单的通过源码安装 elk 平台 

http://www.mamicode.com/info-detail-2361555.html    elasticsearch实现冷热数据分离

https://blog.csdn.net/Miss_peng/article/details/89495496  Elasticsearch 安装 Head 插件

http://ju.outofmemory.cn/entry/367852  配置filebeat+logstash收集nginx系统日志(一)

