<Connector port="" protocol="HTTP/1.1" minSpareThreads="100" maxSpareThreads="500" maxThreads="2000"   acceptCount="1500" 

               connectionTimeout="20000"

               redirectPort="8443" />
               
               
               
               
               启动时预留100个，最大空闲维护500个  暴增时排队队列最大1500个  端口http协议最大访问并发数2000
