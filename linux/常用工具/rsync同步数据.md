```
rsync -avzP --exclude="log" --exclude="logs" --exclude="2019-05*" /data0/opt/tomcat8_8085_openapi root@192.168.52.110:/data0/opt/

rsync -avzP /usr/local/apache-activemq-5.15.8 root@23.244.63.94:/usr/local/


rsync -av /opt/ root@192.168.52.130:/opt/
rsync -avzP --exclude="log" --exclude="logs" --exclude="2019-05*" /data0/opt/ root@192.168.52.130:/data0/opt/



nohup java -jar -Dlogging.path=/opt/logs/exchange-config /opt/jars/kedou-boot-server-config-0.0.1.jar 1>/dev/null 2>&1 &

nohup java -jar -Dfastjson.parser.autoTypeSupport=true -Dspring.profiles.active=test -Dlogging.path=/opt/logs/exchange-api /opt/jars/exchange-api-1.0.0.jar 1>/dev/null 2>&1 &
```
