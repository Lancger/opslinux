公司之前用的是http，但是出于苹果app审核和服务器安全性问题，要改为https，架构上使用了 Nginx +tomcat 集群, 且nginx下配置了SSL,tomcat 没有配置SSL,项目使用https协议。

参考资料：

http://webapp.org.ua/sysadmin/setting-up-nginx-ssl-reverse-proxy-for-tomcat/  Setting up NGINX SSL reverse proxy for Tomcat

https://blog.csdn.net/tjcyjd/article/details/70185224  Nginx SSL+tomcat集群,request.getScheme() 取到https正确的协议详解
