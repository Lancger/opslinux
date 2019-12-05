```bash
filter {
###替换@timestamp时间为日志真实时间######
    grok {
        match => {  "message" => "(?<timestamp>%{TIMESTAMP_ISO8601})"  }
    }
    date {
        match => [ "timestamp", "ISO8601" ]
    }
    mutate {
         remove_field => [ "timestamp" ]
    }
}

只需要在logstash中增加一个filter，提取日志中的时间，并替换@timestamp，重启logstash就可以轻松解决。如果不需要timestamp field，可以remove。
```
参考资料：

https://mp.weixin.qq.com/s/LQtrWcPwxl4Py3ZaTWg-gQ   如何使Kibana中TimeStamp和日志时间一致'

https://mp.weixin.qq.com/s/I4Jj2-UN_aF-iX_vc1fiCg  运维神器 -- ELK
