## 搭建ELFK日志采集系统

最近的工作涉及搭建一套日志采集系统，采用了业界成熟的ELFK方案，这里将搭建过程记录一下。
环境准备
操作系统信息

系统系统：centos7.2

三台服务器：10.211.55.11/12/13

安装包：

https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.3.2.rpm

https://artifacts.elastic.co/downloads/kibana/kibana-6.3.2-x86_64.rpm

https://artifacts.elastic.co/downloads/logstash/logstash-6.3.2.rpm

https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.3.2-x86_64.rpm


服务器规划

# 使用手册
<table border="0">
    <tr>
        <td><strong>服务器HOST1</strong></td>
        <td><strong><a >服务器host2</a></td>
        <td><strong><a >服务器host3</a></td>
    </tr>
    <tr>        
        <td><a >elasticsearch(master,data,client)</a></td>
        <td><a >elasticsearch(master,data,client)</a></td>
        <td><a >elasticsearch(master,data,client)</a></td>
    </tr>
    <tr>
        <td><a >kibana</a></td>
        <td><a ></a></td>
        <td><a ></a></td>
    </tr>
    <tr>
        <td><a >logstash</a></td>
        <td><a >logstash</a></td>
        <td><a >logstash</a></td>
    </tr>
    <tr>
        <td><a >filebeat</a></td>
        <td><a >filebeat</a></td>
        <td><a >filebeat</a></td>
    </tr>
</table>


## 整个ELFK的部署架构图大致如下图：

![ELFK架构](https://github.com/Lancger/opslinux/blob/master/images/ELFK.png)

## 一、日志采集系统搭建

### 安装elasticsearch集群

照手把手教你搭建一个 Elasticsearch 集群文章所述，elasticsearch集群中节点有多种类型：

```
主节点：即 Master 节点。主节点的主要职责是和集群操作相关的内容，如创建或删除索引，跟踪哪些节点是群集的一部分，并决定哪些分片分配给相关的节点。稳定的主节点对集群的健康是非常重要的。默认情况下任何一个集群中的节点都有可能被选为主节点。索引数据和搜索查询等操作会占用大量的cpu，内存，io资源，为了确保一个集群的稳定，分离主节点和数据节点是一个比较好的选择。虽然主节点也可以协调节点，路由搜索和从客户端新增数据到数据节点，但最好不要使用这些专用的主节点。一个重要的原则是，尽可能做尽量少的工作。

数据节点：即 Data 节点。数据节点主要是存储索引数据的节点，主要对文档进行增删改查操作，聚合操作等。数据节点对 CPU、内存、IO 要求较高，在优化的时候需要监控数据节点的状态，当资源不够的时候，需要在集群中添加新的节点。

负载均衡节点：也称作 Client 节点，也称作客户端节点。当一个节点既不配置为主节点，也不配置为数据节点时，该节点只能处理路由请求，处理搜索，分发索引操作等，从本质上来说该客户节点表现为智能负载平衡器。独立的客户端节点在一个比较大的集群中是非常有用的，他协调主节点和数据节点，客户端节点加入集群可以得到集群的状态，根据集群的状态可以直接路由请求。

预处理节点：也称作 Ingest 节点，在索引数据之前可以先对数据做预处理操作，所有节点其实默认都是支持 Ingest 操作的，也可以专门将某个节点配置为 Ingest 节点。

以上就是节点几种类型，一个节点其实可以对应不同的类型，如一个节点可以同时成为主节点和数据节点和预处理节点，但如果一个节点既不是主节点也不是数据节点，那么它就是负载均衡节点。具体的类型可以通过具体的配置文件来设置。
```

我部署的环境服务器较少，只有三台，因此部署在每个节点上的elasticsearch实例只好扮演master、data、client三种角色了。

在三台服务器上均执行以下命令关闭selinux：
```
setenforce 0
sed -i -e 's/^SELINUX=.*$/SELINUX=disabled/g' /etc/selinux/config
```

在三台服务器上均安装java：
```
yum install -y java
```

在三台服务器上均安装elasticsearch的rpm包：

```
yum install -y https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.3.2.rpm
```
在三台服务器上修改elasticsearch的配置文件：
```
cat << EOF > /etc/elasticsearch/elasticsearch.yml
cluster.name: DemoESCluster
# 注意不同节点的node.name要设置得不一样
node.name: demo-es-node-1
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
network.host: 0.0.0.0
http.port: 9200
discovery.zen.ping.unicast.hosts: ["10.211.55.11", "10.211.55.12", "10.211.55.13"]
discovery.zen.minimum_master_nodes: 2
gateway.recover_after_nodes: 2
EOF
```
### 在三台服务器上启动elasticsearch:

```
systemctl daemon-reload
systemctl enable elasticsearch
systemctl start elasticsearch
```
在任意服务器上检查集群中的节点列表：
```
yum install -y jq
curl --silent -XGET 'http://localhost:9200/_cluster/state?pretty'|jq '.nodes'
```
在上述命令的输出里可以看到集群的相关信息，同时 nodes 字段里面包含了每个节点的详细信息，这样一个基本的elasticsearch集群就部署好了。

### 安装 Kibana

接下来我们需要安装一个 Kibana 来帮助可视化管理 Elasticsearch，在host12上安装kibana:

```
yum install -y https://artifacts.elastic.co/downloads/kibana/kibana-6.3.2-x86_64.rpm
```
修改kibana的配置文件：
```
cat << EOF > /etc/kibana/kibana.yml
server.port: 5601
server.host: "0.0.0.0"
elasticsearch.url: "http://localhost:9200"
EOF
```
注意这里配置的elasticsearch.url为本机的es实例，这样其实还是存在单点故障的，官方建议在本机部署一个Elasticsearch 协调（Coordinating only node） 的节点，这里配置成协调节点的地址。

### 启动kibana:
```
systemctl daemon-reload
systemctl enable kibana
systemctl start kibana
```
配置认证需要升级License，我这里是在内网使用，就不进行这个配置了。如果须要配置访问认证可参考这里。

另外还可以启用SSL，可参考这里进行配置。

为了避免单点故障，kibana可部署多个，然后由nginx作反向代理，实现对kibana服务的负载均衡访问。
安装logstash

### 在每台服务器上安装logstash:

```
yum install -y https://artifacts.elastic.co/downloads/logstash/logstash-6.3.2.rpm
```
修改logstash的配置文件：
```
cat << EOF > /etc/logstash/logstash.yml
path.data: /var/lib/logstash
path.logs: /var/log/logstash
xpack.monitoring.enabled: true
xpack.monitoring.elasticsearch.url: ["http://10.211.55.11:9200", "http://10.211.55.12:9200", "http://10.211.55.13:9200"]
EOF
cat << EOF > /etc/logstash/conf.d/beat-elasticsearch.conf
input {
  beats {
    port => 5044
    ssl => false
  }
}
filter {
}
output {
  elasticsearch {
    hosts => ["10.211.55.11:9200","10.211.55.12:9200","10.211.55.13:9200"]
    index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
    document_type => "%{[@metadata][type]}"
  }
}
EOF
```
为了从原始日志中解析出一些有意义的field字段，可以启用一些filter，可用的filter列表在这里。

### 启动logstash:

```
systemctl daemon-reload
systemctl enable logstash
systemctl start logstash
```
### 安装filebeat

在每台服务器上安装filebeat:

```
yum install -y https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.3.2-x86_64.rpm

curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.5.0-x86_64.rpm
sudo rpm -vi filebeat-7.5.0-x86_64.rpm
```
修改每台服务器上的filebeat配置文件：

```
# 这里根据在采集的日志路径，编写合适的inputs规则
cat << EOF > /etc/filebeat/filebeat.yml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/*.log
filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false
output.logstash:
  hosts: ["10.211.55.11:5044", "10.211.55.12:5044", "10.211.55.13:5044"]
  ssl.enabled: false
  index: 'var_log'
EOF
```
filebeat配置文件选项比较多，完整的参考可查看这里。

### 在每台服务器上启动filebeat:

```
systemctl daemon-reload
systemctl enable filebeat
systemctl start filebeat
```
其它安全设置

为保证数据安全，filebeat与logstash、filebeat与elasticsearch、logstash与elasticsearch、kibana与elasticsearch之间的通讯及kibana自身均能启用SSL加密，具体启用办法就是在配置文件中配一配SSL证书就可以了，这个比较简单，不再赘述。

kibana登录认证需要升级License，这一点比较不爽，如果考虑成本，还是在前置机nginx上配个HTTP Basic认证处理好了。

部署测试

至此一个较完整的ELFK日志采集系统就搭建好了，用浏览器访问http://10.211.55.12:5601/，在kibana的界面上简单设置下就可以查看到抓取的日志了：

image-20181013223740706


## 总结

分布式日志采集，ELFK这一套比较成熟了，部署也很方便，不过部署起来还是稍显麻烦。好在还有自动化部署的ansible脚本：ansible-beats、ansible-elasticsearch、ansible-role-logstash、ansible-role-kibana，所以如果有经常部署这一套，还是拿这些ansible脚本组建自动化部署工具集吧。
参考

    https://mp.weixin.qq.com/s/eyfApIiDeg3qv-BD9hBNvw
    https://www.elastic.co/guide/cn/kibana/current/production.html
    https://www.ibm.com/developerworks/cn/opensource/os-cn-elk-filebeat/index.html
    
    
https://jeremy-xu.oschina.io/2018/10/%E6%90%AD%E5%BB%BAelfk%E6%97%A5%E5%BF%97%E9%87%87%E9%9B%86%E7%B3%BB%E7%BB%9F/#%E6%97%A5%E5%BF%97%E9%87%87%E9%9B%86%E7%B3%BB%E7%BB%9F%E6%90%AD%E5%BB%BA  搭建ELFK日志采集系统
