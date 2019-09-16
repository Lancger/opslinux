```
#!/bin/bash
#安装zabbix4.0脚本
err_echo(){
    echo -e "\033[41;37m[Error]: $1 \033[0m"
    exit 1
}

info_echo(){
    echo -e "\033[42;37m[Info]: $1 \033[0m"
}

check_file_is_exists(){
    if [ ! -f "/usr/local/src/$1" ];then
        info_echo "$1开始下载"
    fi
}

check_exit(){
    if [ $? -ne 0 ]; then
        err_echo "$1"
        exit 1
    fi
}

check_success(){
    if [ $? -eq 0 ];then
        info_echo "$1"
    fi
}

[ $(id -u) != "0" ] && err_echo "please run this script as root user." && exit 1

function init_servers(){

    info_echo "开始初始化服务器"
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    setenforce 0
    systemctl stop firewalld.service
    systemctl disable firewalld.service
    
    info_echo "更换阿里源"
    yum install wget -y
    cp /etc/yum.repos.d/* /tmp
    rm -f /etc/yum.repos.d/*
    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
    yum clean all
    yum makecache

}

function install_package(){

    info_echo "开始安装系统必备依赖包"
    yum install ntpdate gcc gcc-c++ wget lsof lrzsz -y

    info_echo "开始安装php所需依赖包"
    yum install -y libxml2 libxml2-devel openssl openssl-devel bzip2 bzip2-devel libcurl libcurl-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel gmp gmp-devel readline readline-devel libxslt libxslt-devel
    yum install -y systemd-devel mysql-devel
    yum install -y openjpeg-devel

    info_echo "开始安装nginx所需依赖包"

    yum install -y pcre pcre-devel zlib zlib-devel
}

function download_install_package(){

    if [ ! -f "/usr/local/src/nginx-1.14.2.tar.gz" ];then
        info_echo "开始下载nginx-1.14.2.tar.gz"
        wget -P /usr/local/src https://nginx.org/download/nginx-1.14.2.tar.gz
        check_success "nginx-1.14.2.tar.gz已下载至/usr/local/src目录"
    else
        info_echo "nginx-1.14.2.tar.gz已存在,不需要下载"
    fi
    if [ ! -f "/usr/local/src/php-7.2.13.tar.gz" ];then
        info_echo "开始下载php-7.2.13.tar.gz"
        wget -P /usr/local/src http://cn2.php.net/distributions/php-7.2.13.tar.gz
        check_success "php-7.2.13.tar.gz已下载至/usr/local/src目录"
    else
        info_echo "php-7.2.13.tar.gz已存在,不需要下载"
    fi
    
    
    if [ ! -f "/usr/local/src/zabbix-4.0.2.tar.gz" ];then
        info_echo "开始下载zabbix-4.0.2.tar.gz"
        wget -P /usr/local/src https://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/4.0.2/zabbix-4.0.2.tar.gz
        check_success "zabbix-4.0.2.tar.gz已下载至/usr/local/src目录"
    else
        info_echo "zabbix-4.0.2.tar.gz已存在,不需要下载"
    fi
    
    if [ ! -f "/usr/local/src/jdk-8u131-linux-x64.tar.gz" ];then
        info_echo "开始下载jdk-8u131-linux-x64.tar.gz"
        wget -P /usr/local/src -c --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz
        check_success "jdk-8u131-linux-x64.tar.gz已下载至/usr/local/src目录"
    else
        info_echo "jdk-8u131-linux-x64.tar.gz已存在,不需要下载"
    fi

}

function install_php(){

    info_echo "开始安装php-7.2.13"
    sleep 2s
    groupadd php-fpm && useradd -s /sbin/nologin -g php-fpm -M php-fpm
    groupadd zabbix &&  useradd -g zabbix zabbix
    cd /usr/local/src
    tar xvf /usr/local/src/php-7.2.13.tar.gz
    cd /usr/local/src/php-7.2.13
    ./configure \
    --prefix=/usr/local/php \
    --with-config-file-path=/usr/local/php/etc \
    --with-zlib-dir \
    --with-freetype-dir \
    --enable-mbstring \
    --with-libxml-dir=/usr \
    --enable-xmlreader \
    --enable-xmlwriter \
    --enable-soap \
    --enable-calendar \
    --with-curl \
    --with-zlib \
    --with-gd \
    --with-pdo-sqlite \
    --with-pdo-mysql \
    --with-mysqli \
    --with-mysql-sock \
    --enable-mysqlnd \
    --disable-rpath \
    --enable-inline-optimization \
    --with-bz2 \
    --with-zlib \
    --enable-sockets \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-pcntl \
    --enable-mbregex \
    --enable-exif \
    --enable-bcmath \
    --with-mhash \
    --enable-zip \
    --with-pcre-regex \
    --with-jpeg-dir=/usr \
    --with-png-dir=/usr \
    --with-openssl \
    --enable-ftp \
    --with-kerberos \
    --with-gettext \
    --with-xmlrpc \
    --with-xsl \
    --enable-fpm \
    --with-fpm-user=php-fpm \
    --with-fpm-group=php-fpm \
    --with-fpm-systemd \
    --disable-fileinfo
    check_exit "configure php-7.2.13失败"
    make && make install
    check_exit "make php-7.2.13失败"

    info_echo "开始配置php-7.2.13"

    cp /usr/local/src/php-7.2.13/php.ini-production /usr/local/php/etc/php.ini && cd /usr/local/php/etc && cp php-fpm.conf.default php-fpm.conf
    cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf
    cp /usr/local/src/php-7.2.13/sapi/fpm/php-fpm.service /usr/lib/systemd/system

    sed -i "s/;date.timezone =/date.timezone = Asia\/Shanghai/g" /usr/local/php/etc/php.ini
    sed -i "s#`grep max_execution_time /usr/local/php/etc/php.ini`#max_execution_time = 300#g" /usr/local/php/etc/php.ini
    sed -i "s#`grep post_max_size /usr/local/php/etc/php.ini`#post_max_size = 32M#g" /usr/local/php/etc/php.ini
    sed -i "s#`grep max_input_time\ = /usr/local/php/etc/php.ini`#max_input_time = 300#g" /usr/local/php/etc/php.ini
    sed -i "s#`grep memory_limit /usr/local/php/etc/php.ini`#memory_limit = 128M#g" /usr/local/php/etc/php.ini
    sed -i "s#`grep post_max_size /usr/local/php/etc/php.ini`#post_max_size = 32M#g" /usr/local/php/etc/php.ini
    sed -i "s#`grep mysqli.default_socket /usr/local/php/etc/php.ini`#mysqli.default_socket = /var/lib/mysql/mysql.sock#g" /usr/local/php/etc/php.ini

    sed -i "s/user = php-fpm/user = zabbix/g" /usr/local/php/etc/php-fpm.d/www.conf
    sed -i "s/group = php-fpm/group = zabbix/g" /usr/local/php/etc/php-fpm.d/www.conf

    systemctl start php-fpm
    systemctl enable php-fpm
    STAT=`echo $?`
    PORT=`netstat -lntup|grep php-fpm|wc -l`
    if [ $STAT -eq 0 ] && [ $PORT -eq 1 ];then
        info_echo "php-fpm启动成功"
    else
        err_echo "php-fpm未启动成功,请检查"
        exit 1
    fi

}
function install_nginx(){

    info_echo "开始安装nginx-1.14.2"
    sleep 2s
    useradd nginx -s /sbin/nologin -M
    cd /usr/local/src && tar xvf nginx-1.14.2.tar.gz
    cd nginx-1.14.2 && ./configure --user=nginx --group=nginx --prefix=/usr/local/nginx --with-http_realip_module --with-http_stub_status_module --with-http_ssl_module --with-http_flv_module --with-http_gzip_static_module --with-cc-opt=-O3 --with-stream
    check_exit "configure nginx-1.14.2失败"
    make && make install
    check_exit "make nginx-1.14.2失败"
    info_echo "开始配置nginx-1.14.2"
    cp /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.bak
    echo "" >/usr/local/nginx/conf/nginx.conf
    mkdir -p /usr/local/nginx/conf/servers && mkdir -p /data/logs/nginx-zabbix && mkdir -p /data/home/www/zabbix
cat <<"EOF" > /usr/local/nginx/conf/nginx.conf
user nginx;
worker_processes auto;
error_log  logs/error.log  crit;
pid        logs/nginx.pid;
worker_rlimit_nofile 65535;
events {
    use epoll;
    multi_accept on;
    accept_mutex_delay 50ms;
    worker_connections 40960;
}
http {
    include       mime.types;
    #default_type  application/octet-stream;
    default_type  text/html;
    client_max_body_size 50m;
    server_tokens off;

    server_names_hash_bucket_size 512;

    sendfile    on;
    keepalive_timeout 600;

    gzip on;
    gzip_min_length   1k;
    gzip_buffers      4 8k;
    gzip_http_version 1.1;
    gzip_types        text/plain application/x-javascript text/css text/shtml application/xml applicaton/javascript text/javascript;
    charset utf-8;
    log_format  main '$http_x_forwarded_for $remote_addr $remote_user [$time_local] "$request" $http_host $status $upstream_status $body_bytes_sent "$http_referer" "$http_user_agent" $upstream_addr $request_time $upstream_response_time';
    log_format mine   '$http_x_forwarded_for" - $upstream_addr - $upstream_cache_status - $upstream_status - $upstream_http_host - $request_time - [$time_local] - $request';
    include servers/*;
    }
EOF

cat <<"EOF" > /usr/local/nginx/conf/servers/zabbix.conf
server {
        listen       80;
        server_name  zabbix;

        location / {
            root /data/home/www/zabbix;
            index index.php;

        }
        location ~ \.php$ {
           
            root /data/home/www/zabbix;
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
            include fastcgi_params;
        }
        
        access_log      /data/logs/nginx-zabbix/zabbix-access.log  main;
        access_log      /data/logs/nginx-zabbix/zabbix_mine.log mine;

} 
EOF
 
    info_echo "开启启动nginx"
    /usr/local/nginx/sbin/nginx -t
    /usr/local/nginx/sbin/nginx
    STAT=`echo $?`
    PORT=`netstat -lntup|grep nginx|wc -l`
    if [ $STAT -eq 0 ] && [ $PORT -eq 1 ];then
        info_echo "nginx启动成功"
    else
        err_echo "nginx未启动成功,请检查"
    fi
    
}

function install_mysql(){
     
    info_echo "开始安装mysql"
    sleep 2s
    yum install mariadb-server -y
    check_exit "安装mysql失败"
    systemctl start mariadb
    STAT=`echo $?`
    PORT=`netstat -lntup|grep mysql|wc -l`
    if [ $STAT -eq 0 ] && [ $PORT -eq 1 ];then
        info_echo "mysql启动成功"
    else
        err_echo "mysql未启动成功,请检查"
    fi
    
    info_echo "开始创建zabbix账号和授权"
    sleep 2s
    mysql -uroot -e "create database zabbix character set utf8;" 
    mysql -uroot -e "grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';"
    mysql -uroot -e "flush privileges;"
    mysql -uroot -e "show databases;"
    
}


function install_jdk(){

    info_echo "开始安装jdk-8u131-linux-x64.tar.gz"
    sleep 2s
    mkdir -p /usr/local/java
    tar xvf /usr/local/src/jdk-8u131-linux-x64.tar.gz -C /usr/local/java
    cp /etc/profiel /etc/profile.bak
    
cat <<"EOF" >> /etc/profile
JAVA_HOME=/usr/local/java/jdk1.8.0_131
CLASSPATH=.:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar
PATH=$PATH:$JAVA_HOME/bin
export JAVA_HOME CLASSPATH PATH
EOF

    info_echo "验证jdk是否安装成功"
    source /etc/profile
    java -version
}



function install_zabbix(){

    info_echo "开始安装zabbix-4.0.2"
    sleep 2s
    yum install OpenIPMI-devel libevent-devel net-snmp-devel -y
    cd /usr/local/src/ && tar xvf zabbix-4.0.2.tar.gz
        cd /usr/local/src/zabbix-4.0.2
    ./configure \
    --prefix=/usr/local/zabbix \
    --enable-server --enable-agent \
    --enable-proxy --enable-java \
    --with-mysql --with-net-snmp \
    --with-libcurl --with-libxml2 \
    --with-openipmi \
    --enable-proxy
    check_exit "configure zabbix-4.0.2失败"
    make && make install
    check_exit "make zabbix-4.0.2失败"
    info_echo "开始配置zabbix-4.0.2"
    cp -R /usr/local/src/zabbix-4.0.2/frontends/php/* /data/home/www/zabbix
    chown -R zabbix.zabbix /data/home/www/zabbix
    chown -R zabbix.zabbix /usr/local/zabbix
    cp /usr/local/src/zabbix-4.0.2/misc/init.d/fedora/core5/* /etc/init.d/
    sed -i "s#/usr/local/sbin/zabbix_server#/usr/local/zabbix/sbin/zabbix_server#g" /etc/init.d/zabbix_server
    sed -i "s#/usr/local/sbin/zabbix_agentd#/usr/local/zabbix/sbin/zabbix_agentd#g" /etc/init.d/zabbix_agentd
    cp /usr/local/zabbix/etc/zabbix_server.conf /usr/local/zabbix/etc/zabbix_server.conf.bak
    echo "" >/usr/local/zabbix/etc/zabbix_server.conf

cat <<"EOF" > /usr/local/zabbix/etc/zabbix_server.conf
LogFile=/tmp/zabbix_server.log
DBHost=127.0.0.1
DBName=zabbix
DBUser=zabbix
DBPassword=zabbix
DBPort=3306
Timeout=30
EOF

    info_echo "开始导入mysql数据"
    mysql -uzabbix -pzabbix zabbix < /usr/local/src/zabbix-4.0.2/database/mysql/schema.sql 
    mysql -uzabbix -pzabbix zabbix < /usr/local/src/zabbix-4.0.2/database/mysql/images.sql
    mysql -uzabbix -pzabbix zabbix < /usr/local/src/zabbix-4.0.2/database/mysql/data.sql 

    info_echo "开始启动zabbix_server"
    sleep 2s
    /etc/init.d/zabbix_server start 
    STAT=`echo $?`
    PORT=`netstat -lntup|grep zabbix_server|wc -l`
    if [ $STAT -eq 0 ] && [ $PORT -eq 1 ];then
        info_echo "zabbix_server启动成功"
    else
        err_echo "zabbix_server,请检查"
    fi
}


function main(){

    init_servers
    install_package
    download_install_package
    install_php
    install_nginx
    install_mysql
    install_jdk
    install_zabbix
    
}

main

```

参考资料：

https://www.cnblogs.com/biaopei/p/9877747.html  zabbix4.0离线快速编译安装（编译安装方法）

https://www.cnblogs.com/uglyliu/p/10143914.html   Centos7一键编译安装zabbix-4.0.2 

https://www.cnblogs.com/sky-k/p/9367186.html  Zabbix编译安装(全)
