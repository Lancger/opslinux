## 一、什么是ELFK

1、ELK已经成为目前最流行的集中式日志解决方案，分别表示：Elasticsearch , Logstash, Kibana , 它们都是开源软件。新增了一个FileBeat，它是一个轻量级的日志收集处理工具(Agent)，Filebeat占用资源少，适合于在各个服务器上搜集日志后传输给Logstash，官方也推荐此工具。

2、Elasticsearch是个开源分布式搜索引擎，提供搜集、分析、存储数据三大功能。它的特点有：分布式，零配置，自动发现，索引自动分片，索引副本机制，restful风格接口，多数据源，自动搜索负载等。

3、Logstash 主要是用来日志的搜集、分析、过滤日志的工具，支持大量的数据获取方式。一般工作方式为c/s架构，client端安装在需要收集日志的主机上，server端负责将收到的各节点日志进行过滤、修改等操作在一并发往elasticsearch上去。

4、Kibana 也是一个开源和免费的工具，Kibana可以为 Logstash 和 ElasticSearch 提供的日志分析友好的 Web 界面，可以帮助汇总、分析和搜索重要数据日志。

5、Filebeat隶属于Beats。目前Beats包含四种工具：
```
1、Packetbeat（搜集网络流量数据）
2、Topbeat（搜集系统、进程和文件系统级别的 CPU 和内存使用情况等数据）
3、Filebeat（搜集文件数据）
4、Winlogbeat（搜集 Windows 事件日志数据）
```

## 二、为什么要用ELFK

1、一般我们需要进行日志分析场景：直接在日志文件中 grep、awk 就可以获得自己想要的信息。但在规模较大的场景中，此方法效率低下，面临问题包括日志量太大如何归档、文本搜索太慢怎么办、如何多维度查询。需要集中化的日志管理，所有服务器上的日志收集汇总。常见解决思路是建立集中式日志收集系统，将所有节点上的日志统一收集，管理，访问。

2、一般大型系统是一个分布式部署的架构，不同的服务模块部署在不同的服务器上，问题出现时，大部分情况需要根据问题暴露的关键信息，定位到具体的服务器和服务模块，构建一套集中式日志系统，可以提高定位问题的效率。

3、一个完整的集中式日志系统，需要包含以下几个主要特点：收集、传输、存储、分析、警告，而ELK提供了一整套解决方案，并且都是开源软件，之间互相配合使用，完美衔接，高效的满足了很多场合的应用。并且是目前主流的一种日志系统。

## 三、ELK常见部署架构

### 2.1 Logstash作为日志收集器

这种架构是比较原始的部署架构，在各应用服务器端分别部署一个Logstash组件，作为日志收集器，然后将Logstash收集到的数据过滤、分析、格式化处理后发送至Elasticsearch存储，最后使用Kibana进行可视化展示，这种架构不足的是：Logstash比较耗服务器资源，所以会增加应用服务器端的负载压力。

  ![Logstash作为日志收集器](https://github.com/Lancger/opslinux/blob/master/images/logstash.png)


### 2.2 Filebeat作为日志收集器

该架构与第一种架构唯一不同的是：应用端日志收集器换成了Filebeat，Filebeat轻量，占用服务器资源少，所以使用Filebeat作为应用服务器端的日志收集器，一般Filebeat会配合Logstash一起使用，这种部署方式也是目前最常用的架构。

  ![Filebeat作为日志收集器](https://github.com/Lancger/opslinux/blob/master/images/filebeat.png)

### 2.3 引入缓存队列的部署架构

该架构在第二种架构的基础上引入了Kafka消息队列（还可以是其他消息队列），将Filebeat收集到的数据发送至Kafka，然后在通过Logstasth读取Kafka中的数据，这种架构主要是解决大数据量下的日志收集方案，使用缓存队列主要是解决数据安全与均衡Logstash与Elasticsearch负载压力。

  ![kafka缓存](https://github.com/Lancger/opslinux/blob/master/images/kafka.png)
  
### 2.4、以上三种架构的总结

第一种部署架构由于资源占用问题，现已很少使用，目前使用最多的是第二种部署架构，至于第三种部署架构个人觉得没有必要引入消息队列，除非有其他需求，因为在数据量较大的情况下，Filebeat 使用压力敏感协议向 Logstash 或 Elasticsearch 发送数据。如果 Logstash 正在繁忙地处理数据，它会告知 Filebeat 减慢读取速度。拥塞解决后，Filebeat 将恢复初始速度并继续发送数据。


## 四、问题及解决方案

### 问题一：如何实现日志的多行合并功能？

系统应用中的日志一般都是以特定格式进行打印的，属于同一条日志的数据可能分多行进行打印，那么在使用ELK收集日志的时候就需要将属于同一条日志的多行数据进行合并。

### 解决方案：使用Filebeat或Logstash中的multiline多行合并插件来实现

在使用multiline多行合并插件的时候需要注意，不同的ELK部署架构可能multiline的使用方式也不同，如果是本文的第一种部署架构，那么multiline需要在Logstash中配置使用，如果是第二种部署架构，那么multiline需要在Filebeat中配置使用，无需再在Logstash中配置multiline。

1、multiline在Filebeat中的配置方式：
```
filebeat.prospectors:
    -
       paths:
          - /home/project/elk/logs/test.log
       input_type: log 
       multiline:
            pattern: '^\['
            negate: true
            match: after
output:
   logstash:
      hosts: ["localhost:5044"]


#pattern：正则表达式
#negate：默认为false，表示匹配pattern的行合并到上一行；true表示不匹配pattern的行合并到上一行
#match：after表示合并到上一行的末尾，before表示合并到上一行的行首

如：

pattern: '\['
negate: true
match: after

该配置表示将不匹配pattern模式的行合并到上一行的末尾
```

2、multiline在Logstash中的配置方式
```
input {
  beats {
    port => 5044
  }
}

filter {
  multiline {
    pattern => "%{LOGLEVEL}\s*\]"
    negate => true
    what => "previous"
  }
}

output {
  elasticsearch {
    hosts => "localhost:9200"
  }
}

(1）Logstash中配置的what属性值为previous，相当于Filebeat中的after，Logstash中配置的what属性值为next，相当于Filebeat中的before。
(2）pattern => "%{LOGLEVEL}\s*\]" 中的LOGLEVEL是Logstash预制的正则匹配模式，预制的还有好多常用的正则匹配模式，详细请看：https://github.com/logstash-plugins/logstash-patterns-core/tree/master/patterns
```

### 问题二：如何将Kibana中显示日志的时间字段替换为日志信息中的时间？

默认情况下，我们在Kibana中查看的时间字段与日志信息中的时间不一致，因为默认的时间字段值是日志收集时的当前时间，所以需要将该字段的时间替换为日志信息中的时间。

### 解决方案：使用grok分词插件与date时间格式化插件来实现

在Logstash的配置文件的过滤器中配置grok分词插件与date时间格式化插件，如：
```
input {
  beats {
    port => 5044
  }
}

filter {
  multiline {
    pattern => "%{LOGLEVEL}\s*\]\[%{YEAR}%{MONTHNUM}%{MONTHDAY}\s+%{TIME}\]"
    negate => true
    what => "previous"
  }

  grok {
    match => [ "message" , "(?<customer_time>%{YEAR}%{MONTHNUM}%{MONTHDAY}\s+%{TIME})" ]
  }

  date {
        match => ["customer_time", "yyyyMMdd HH:mm:ss,SSS"] //格式化时间
        target => "@timestamp" //替换默认的时间字段
  }
}

output {
  elasticsearch {
    hosts => "localhost:9200"
  }
}

如要匹配的日志格式为：“[DEBUG][20170811 10:07:31,359][DefaultBeanDefinitionDocumentReader:106] Loading bean definitions”，解析出该日志的时间字段的方式有：

① 通过引入写好的表达式文件，如表达式文件为customer_patterns，内容为：
CUSTOMER_TIME %{YEAR}%{MONTHNUM}%{MONTHDAY}\s+%{TIME}

注：内容格式为：[自定义表达式名称] [正则表达式]

然后logstash中就可以这样引用：

filter {
  grok {
      patterns_dir => ["./customer-patterms/mypatterns"] //引用表达式文件路径
      match => [ "message" , "%{CUSTOMER_TIME:customer_time}" ] //使用自定义的grok表达式
  }
}

② 以配置项的方式，规则为：(?<自定义表达式名称>正则匹配规则)，如：

filter {
  grok {
    match => [ "message" , "(?<customer_time>%{YEAR}%{MONTHNUM}%{MONTHDAY}\s+%{TIME})" ]
  }
}
```

### 问题三：如何在Kibana中通过选择不同的系统日志模块来查看数据

一般在Kibana中显示的日志数据混合了来自不同系统模块的数据，那么如何来选择或者过滤只查看指定的系统模块的日志数据？

### 解决方案：新增标识不同系统模块的字段或根据不同系统模块建ES索引

1、新增标识不同系统模块的字段，然后在Kibana中可以根据该字段来过滤查询不同模块的数据
这里以第二种部署架构讲解，在Filebeat中的配置内容为：
```
filebeat.prospectors:
    -
       paths:
          - /home/project/elk/logs/account.log
       input_type: log 
       multiline:
            pattern: '^\['
            negate: true
            match: after
       fields: //新增log_from字段
         log_from: account

    -
       paths:
          - /home/project/elk/logs/customer.log
       input_type: log 
       multiline:
            pattern: '^\['
            negate: true
            match: after
       fields:
         log_from: customer
output:
   logstash:
      hosts: ["localhost:5044"]

通过新增：log_from字段来标识不同的系统模块日志
```
2、根据不同的系统模块配置对应的ES索引，然后在Kibana中创建对应的索引模式匹配，即可在页面通过索引模式下拉框选择不同的系统模块数据。
这里以第二种部署架构讲解，分为两步：
```

① 在Filebeat中的配置内容为：
filebeat.prospectors:
    -
       paths:
          - /home/project/elk/logs/account.log
       input_type: log 
       multiline:
            pattern: '^\['
            negate: true
            match: after
       document_type: account

    -
       paths:
          - /home/project/elk/logs/customer.log
       input_type: log 
       multiline:
            pattern: '^\['
            negate: true
            match: after
       document_type: customer
output:
   logstash:
      hosts: ["localhost:5044"]

通过document_type来标识不同系统模块

② 修改Logstash中output的配置内容为：

output {
  elasticsearch {
    hosts => "localhost:9200"
    index => "%{type}"
  }
}

在output中增加index属性，%{type}表示按不同的document_type值建ES索引
```

## 五、总结

本文主要介绍了ELK实时日志分析的三种部署架构，以及不同架构所能解决的问题，这三种架构中第二种部署方式是时下最流行也是最常用的部署方式，最后介绍了ELK作在日志分析中的一些问题与解决方案，说在最后，ELK不仅仅可以用来作为分布式日志数据集中式查询和管理，还可以用来作为项目应用以及服务器资源监控等场景，更多内容请看官网。

参考文档：

https://my.oschina.net/feinik/blog/1580625

https://www.kemin-cloud.com/?p=130  ELK日志分析平台部署

https://www.kemin-cloud.com/?p=172  Logstash收集日志


https://blog.51cto.com/jesus110/2358954?source=dra  记一次从elk到elfk的升级
