# 一、监控应用启动时间
```
root>#  ps -eo pid,lstart | grep `ps -ef|grep -v grep|grep java|grep tomcat-trade|awk '{print $2}'`
24514 Wed Dec 19 22:51:22 2018
```

