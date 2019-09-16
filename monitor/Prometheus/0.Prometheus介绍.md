# 一、什么是TSDB？

TSDB(Time Series Database)时序列数据库，我们可以简单的理解为一个优化后用来处理时间序列数据的软件，并且数据中的数组是由时间进行索引的。

1、时间序列数据库的特点

    大部分时间都是写入操作。

    写入操作几乎是顺序添加，大多数时候数据到达后都以时间排序。

    写操作很少写入很久之前的数据，也很少更新数据。大多数情况在数据被采集到数秒或者数分钟后就会被写入数据库。

    删除操作一般为区块删除，选定开始的历史时间并指定后续的区块。很少单独删除某个时间或者分开的随机时间的数据。

    基本数据大，一般超过内存大小。一般选取的只是其一小部分且没有规律，缓存几乎不起任何作用。

    读操作是十分典型的升序或者降序的顺序读。

    高并发的读操作十分常见。

2、常见的时间序列数据库
```
TSDB项目    官网
influxDB    https://influxdata.com/
RRDtool    http://oss.oetiker.ch/rrdtool/
Graphite    http://graphiteapp.org/
OpenTSDB    http://opentsdb.net/
Kdb+    http://kx.com/
Druid    http://druid.io/
KairosDB    http://kairosdb.github.io/
Prometheus    https://prometheus.io/
```

# 二、Prometheus概述
1.1 介绍

Prometheus是由SoundCloud开发的开源监控报警系统和时序列数据库(TSDB)，它使用Go语言开发，是一个开源的系统监视和警报工具包，自2012成立以来，许多公司和组织采用了Prometheus。它现在是一个独立的开源项目，并独立于任何公司维护。Prometheus和Heapster(Heapster是K8S的一个子项目，用于获取集群的性能数据。)相比功能更完善、更全面。Prometheus性能也足够支撑上万台规模的集群。

特点：

    多维数据模型（有metric名称和键值对确定的时间序列）
    灵活的查询语言
    不依赖分布式存储
    通过pull方式采集时间序列，通过http协议传输
    支持通过中介网关的push时间序列的方式
    监控数据通过服务或者静态配置来发现
    支持图表和dashboard等多种方式

组件：

    1. prometheus server： 定期从静态配置的 targets 或者服务发现（主要是DNS、consul、k8s、mesos等）的 targets 拉取数据。
    
    2. exporters：负责向prometheus server做数据汇报的程序统。而不同的数据汇报由不同的exporters实现，比如监控主机有node-exporters，mysql有MySQL server exporter
    
    3. pushgateway：主要使用场景为：
       Prometheus 采用 pull 模式，可能由于不在一个子网或者防火墙原因，导致 Prometheus 无法直接拉取各个 target 数据。在监控业务数据的时候，需要将不同数据汇总, 由 Prometheus 统一收集。总结：实现类似于zabbix-proxy功能；
    
    4. Alertmanager：实现prometheus的告警功能。
     
    5. webui：主要通过grafana来实现webui展示。

1.2 核心架构

  架构图

  ![prometheus架构图](https://github.com/Lancger/opslinux/blob/master/images/prometheus.png)

Prometheus的基本原理是通过HTTP协议周期性抓取被监控组件的状态，任意组件只要提供对应的HTTP接口就可以接入监控。不需要任何SDK或者其他的集成过程。这样做非常适合做虚拟化环境监控系统，比如VM、Docker、Kubernetes等。输出被监控组件信息的HTTP接口被叫做exporter 。目前互联网公司常用的组件大部分都有exporter可以直接使用，比如Varnish、Haproxy、Nginx、MySQL、Linux系统信息(包括磁盘、内存、CPU、网络等等)。

1.3 适用场景

  Prometheus在记录纯数字时间序列方面表现非常好。它既适用于面向服务器等硬件指标的监控，也适用于高动态的面向服务架构的监控。对于现在流行的微服务，Prometheus的多维度数据收集和数据筛选查询语言也是非常的强大。Prometheus是为服务的可靠性而设计的，当服务出现故障时，它可以使你快速定位和诊断问题。它的搭建过程对硬件和服务没有很强的依赖关系。

  Prometheus，它的价值在于可靠性，甚至在很恶劣的环境下，你都可以随时访问它和查看系统服务各种指标的统计信息。 如果你对统计数据需要100%的精确，它并不适用，例如：它不适用于实时计费系统。


# 三、基础概念

1.1 数据模型

Prometheus 存储的是时序数据, 即按照相同时序(相同的名字和标签)，以时间维度存储连续的数据的集合。时序(time series) 是由名字(Metric)，以及一组 key/value 标签定义的，具有相同的名字以及标签属于相同时序。时序的名字由 ASCII 字符，数字，下划线，以及冒号组成，它必须满足正则表达式 [a-zA-Z_:][a-zA-Z0-9_:]*, 其名字应该具有语义化，一般表示一个可以度量的指标，例如 http_requests_total, 可以表示 http 请求的总数。

时序的标签可以使 Prometheus 的数据更加丰富，能够区分具体不同的实例，例如 http_requests_total{method="POST"} 可以表示所有 http 中的 POST 请求。标签名称由 ASCII 字符，数字，以及下划线组成， 其中 __ 开头属于 Prometheus 保留，标签的值可以是任何 Unicode 字符，支持中文。

1.2 时序4种类型

Prometheus 时序数据分为 Counter, Gauge, Histogram, Summary 四种类型。

    Counter：表示收集的数据是按照某个趋势（增加／减少）一直变化的，我们往往用它记录服务请求总量，错误总数等。例如 Prometheus server 中 http_requests_total, 表示 Prometheus 处理的 http 请求总数，我们可以使用data, 很容易得到任意区间数据的增量。
    
    Gauge：表示搜集的数据是一个瞬时的，与时间没有关系，可以任意变高变低，往往可以用来记录内存使用率、磁盘使用率等。
    
    Histogram：Histogram 由 <basename>_bucket{le="<upper inclusive bound>"}，<basename>_bucket{le="+Inf"}, <basename>_sum，<basename>_count 组成，主要用于表示一段时间范围内对数据进行采样，（通常是请求持续时间或响应大小），并能够对其指定区间以及总数进行统计，通常我们用它计算分位数的直方图。
    
    Summary：Summary 和 Histogram 类似，由 <basename>{quantile="<φ>"}，<basename>_sum，<basename>_count组成，主要用于表示一段时间内数据采样结果，（通常是请求持续时间或响应大小），它直接存储了 quantile 数据，而不是根据统计区间计算出来的。区别在于：
    
    a. 都包含 <basename>_sum，<basename>_count。
    
    b. Histogram 需要通过 <basename>_bucket 计算 quantile, 而 Summary 直接存储了 quantile 的值。

1.3 总结

prometheus是属于下一代监控，现在企业中大部分通过使用zabbix来实现主机、服务、设备的监控。与zabbix相比，zabbix还是存在一定的优势，比如丰富的插件、webui能完成大部分工作，而prometheus更多的配置是通过配置文件还实现，并且prometheus相当消耗资源。建议在使用的过程中，认真对比慎重选择，如果使用prometheus，就要配置更好的服务器资源，因为它的监控粒度更细，需要计算相关数值，最好使用SSD硬盘来提高性能。


参考文档：

https://blog.csdn.net/xiegh2014/article/details/84936174   CentOS7.5 Prometheus2.5+Grafana5.4监控部署

https://www.cnblogs.com/yanyouqiang/p/7240696.html   Prometheus入门 
