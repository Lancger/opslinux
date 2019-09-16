# 一、软件包下载
```
cd /usr/local/src/
export version="7.2.0"
wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${version}-x86_64.rpm
sudo rpm -vi filebeat-${version}-x86_64.rpm
```

# 二、配置filebeat
```
tee /etc/filebeat/filebeat.yml << 'EOF'
filebeat.inputs:

#linux系统登录日志
- type: log
  enabled: true
  paths:
    /var/log/secure
  exclude_files: ['.gz$']
  tags: ["secure"]
  fields:
    file_tag: secure_beat

#nginx访问日志
- type: log
  enabled: true
  paths:
    /var/log/nginx/*.log
  exclude_files: ['.gz$']
  tags: ["nginx_access"]
  fields:
    file_tag: nginx_access_beat

#tomcat8_8080_job日志
- type: log
  enabled: true
  paths:
    - /data0/opt/tomcat8_8080_job/logs/catalina.*.out

  multiline.pattern: '^\['
  multiline.negate: true
  multiline.match: after
  
  exclude_files: ['.gz$']
  tags: ["tomcat8_8080_job"]
  fields:
    file_tag: tomcat8_8080_job_beat

#tomcat8_8081_taskjob日志
- type: log
  enabled: true
  paths:
    - /data0/opt/tomcat8_8081_taskjob/logs/catalina.*.out

  multiline.pattern: '^\['
  multiline.negate: true
  multiline.match: after
  
  exclude_files: ['.gz$']
  tags: ["tomcat8_8081_taskjob"]
  fields:
    file_tag: tomcat8_8081_taskjob_beat

#tomcat8_8082_schedule日志
- type: log
  enabled: true
  paths:
    - /data0/opt/tomcat8_8082_schedule/logs/catalina.*.out

  multiline.pattern: '^\['
  multiline.negate: true
  multiline.match: after
  
  exclude_files: ['.gz$']
  tags: ["tomcat8_8082_schedule"]
  fields:
    file_tag: tomcat8_8082_schedule_beat

#tomcat8_8083_inner日志
- type: log
  enabled: true
  paths:
    - /data0/opt/tomcat8_8083_inner/logs/catalina.*.out

  multiline.pattern: '^\['
  multiline.negate: true
  multiline.match: after
  
  exclude_files: ['.gz$']
  tags: ["tomcat8_8083_inner"]
  fields:
    file_tag: tomcat8_8083_inner_beat


#tomcat8_8084_match日志
- type: log
  enabled: true
  paths:
    - /data0/opt/tomcat8_8084_match/logs/catalina.*.out

  multiline.pattern: '^\['
  multiline.negate: true
  multiline.match: after
  
  exclude_files: ['.gz$']
  tags: ["tomcat8_8084_match"]
  fields:
    file_tag: tomcat8_8084_match_beat

#tomcat8_8085_openapi日志
- type: log
  enabled: true
  paths:
    - /data0/opt/tomcat8_8085_openapi/logs/catalina.*.out

  multiline.pattern: '^\['
  multiline.negate: true
  multiline.match: after
  
  exclude_files: ['.gz$']
  tags: ["tomcat8_8085_openapi"]
  fields:
    file_tag: tomcat8_8085_openapi_beat

#tomcat8_8086_console日志
- type: log
  enabled: true
  paths:
    - /data0/opt/tomcat8_8086_console/logs/catalina.*.out

  multiline.pattern: '^\['
  multiline.negate: true
  multiline.match: after
  
  exclude_files: ['.gz$']
  tags: ["tomcat8_8086_console"]
  fields:
    file_tag: tomcat8_8086_console_beat

filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false

setup.template.settings:
  index.number_of_shards: 1

setup.kibana:

output.elasticsearch:
  hosts: ["server-01:9200", "server-02:9200", "server-03:9200"]
  indices:
    - index: "secure_%{+yyyy.MM.dd}"
      when.contains:
        fields:
          file_tag: "secure"

    - index: "nginx_access_%{+yyyy.MM.dd}"
      when.contains:
        fields:
          file_tag: "nginx_access"

    - index: "tomcat8_8080_job_%{+yyyy.MM.dd}"
      when.contains:
        fields:
          file_tag: "tomcat8_8080_job"

    - index: "tomcat8_8081_taskjob_%{+yyyy.MM.dd}"
      when.contains:
        fields:
          file_tag: "tomcat8_8081_taskjob"

    - index: "tomcat8_8082_schedule_%{+yyyy.MM.dd}"
      when.contains:
        fields:
          file_tag: "tomcat8_8082_schedule"

    - index: "tomcat8_8083_inner_%{+yyyy.MM.dd}"
      when.contains:
        fields:
          file_tag: "tomcat8_8083_inner"

    - index: "tomcat8_8084_match_%{+yyyy.MM.dd}"
      when.contains:
        fields:
          file_tag: "tomcat8_8084_match"

    - index: "tomcat8_8085_openapi_%{+yyyy.MM.dd}"
      when.contains:
        fields:
          file_tag: "tomcat8_8085_openapi"

    - index: "tomcat8_8086_console_%{+yyyy.MM.dd}"
      when.contains:
        fields:
          file_tag: "tomcat8_8086_console"

processors:
  - add_host_metadata: ~
  - add_cloud_metadata: ~
EOF
systemctl restart filebeat
```

# 三、启动filebeat并设为开机启动

```
systemctl start filebeat
systemctl enable filebeat
```
