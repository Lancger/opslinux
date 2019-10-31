# 一、JAVA环境部署

```bash
#1、yum安装
yum search java|grep openjdk 
yum -y install java-1.8.0-openjdk
yum -y install java-11-openjdk

#2、源码安装
#wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn/java/jdk/8u211-b12/478a62b7d4e34b78b671c754eaaf38ab/jdk-8u211-linux-x64.tar.gz

echo "47.106.90.8 download.devops.com" >> /etc/hosts
cd /usr/local/src/
mkdir -p /opt/java
wget http://download.devops.com/jdk-8u211-linux-x64.tar.gz
tar -zxvf jdk-8u211-linux-x64.tar.gz
mv jdk1.8.0_211 /opt/java/
ls -l /opt/java/

vim /etc/profile
#在最后一行添加
#java environment
export JAVA_HOME=/opt/java/jdk1.8.0_211
export CLASSPATH=.:${JAVA_HOME}/jre/lib/rt.jar:${JAVA_HOME}/lib/dt.jar:${JAVA_HOME}/lib/tools.jar
export PATH=$PATH:${JAVA_HOME}/bin

source /etc/profile  #(生效环境变量)

java -version        #(检查安装 是否成功)
```

# 二、Activemq安装部署
```bash
http://activemq.apache.org/download.html  

cd /usr/local/src/

wget http://archive.apache.org/dist/activemq/5.15.8/apache-activemq-5.15.8-bin.tar.gz

tar -zxvf apache-activemq-5.15.8-bin.tar.gz

vim  apache-activemq-5.15.8/conf/activemq.xml (开启jmx,默认为false)

cd /usr/local/apache-activemq-5.15.8/bin

./apache-activemq-5.15.8/bin/activemq start (启动MQ)

访问：
http://0.0.0.0:8161  admin/admin


修改密码
vim jetty-realm.properties

admin: admin, admin
```

# 三、tomcat8部署
```

wget http://cronolog.org/download/cronolog-1.6.2.tar.gz 
tar zxvf cronolog-1.6.2.tar.gz 
cd cronolog-1.6.2
./configure 
make && make install 


wget https://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-8/v8.5.40/bin/apache-tomcat-8.5.40.tar.gz



```

# 四、同步
```
yum install rsync -y
rsync -av --exclude "logs" --exclude "log" /data0/opt/tomcat8_8081_taskjob /tmp/test

```

参考文档：

https://www.cnblogs.com/happy-king/p/9193401.html      Tomcat的日志分割三种方法

https://www.cnblogs.com/kinome/p/8574873.html   wget和curl方式下载JDK
