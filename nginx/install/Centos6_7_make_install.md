## 一、Tengine介绍

　Tengine是由淘宝网发起的Web服务器项目。它在Nginx的基础上，针对大访问量网站的需求，添加了很多高级功能和特性。Tengine的性能和稳定性已经在大型的网站如淘宝网，天猫商城等得到了很好的检验。官方主页 http://tengine.taobao.org/

### 二、Tengine部署

    ###关闭网络管理工具###
    chkconfig NetworkManager off

    ###关闭防火墙###
    /etc/init.d/iptables stop
    chkconfig iptables off

    ###关闭selinux###
    sed -i.bak "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
    sed -i "s/SELINUXTYPE=targeted/SELINUXTYPE=disabled/g" /etc/selinux/config
    setenforce 0

    ###安装ntpdate,保证各服务器间时间一致###
    yum install -y ntpdate wget lrzsz
    
    # 加入crontab
    1 * * * *  (/usr/sbin/ntpdate -s ntp1.aliyun.com;/usr/sbin/hwclock -w) > /dev/null 2>&1
    1 * * * * /usr/sbin/ntpdate -s ntp1.aliyun.com  > /dev/null 2>&1

    ###安装依赖包###
    yum install pcre-devel zlib zlib-devel git -y
    yum install -y gcc gcc-c++ make pcre-devel perl perl-devel git openssh-clients zlib-devel
    #yum install -y gcc gcc-c++ make pcre-devel perl perl-devel git tmux wget curl openssl openssl-devel openldap openldap-devel

    groupadd nginx -g 600                                #指定www组ID号为600
    useradd -M -s /sbin/nologin -u 600 -r -g nginx nginx #-u 指定用户ID号 -g 指定用户所属的起始群组 -G指定用户所属的附加群组

    cd /usr/local/src/
    wget https://www.openssl.org/source/old/1.0.2/openssl-1.0.2j.tar.gz
    tar -zxf  /usr/local/src/openssl-1.0.2j.tar.gz

    cd /usr/local/src/
    wget http://luajit.org/download/LuaJIT-2.0.5.tar.gz
    tar zxvf LuaJIT-2.0.5.tar.gz
    cd LuaJIT-2.0.5
    make   &&  make install

    cd /usr/local/src/
    git clone https://github.com/simpl/ngx_devel_kit.git

    cd /usr/local/src/
    git clone https://github.com/chaoslawful/lua-nginx-module.git

    cd /usr/local/src/
    wget http://www.kyne.com.au/~mark/software/download/lua-cjson-2.1.0.tar.gz
    tar zxf lua-cjson-2.1.0.tar.gz
    cd lua-cjson-2.1.0
    
    注：
    vim Makefile
    修改：LUA_INCLUDE_DIR =   $(PREFIX)/include/luajit-2.0
    make & make install

    #创建Nginx运行的普通用户
    useradd -s /sbin/nologin -M nginx

    #git clone git://github.com/alibaba/tengine.git;
    #cd  tengine
    cd /usr/local/src/
    wget http://tengine.taobao.org/download/tengine-2.2.2.tar.gz
    tar zxf tengine-2.2.2.tar.gz
    cd tengine-2.2.2

    export LUAJIT_INC=/usr/local/include/luajit-2.0/
    export LUAJIT_LIB=/usr/local/lib
    ./configure --user=nginx --group=nginx --prefix=/usr/local/nginx --with-http_ssl_module --with-openssl-opt="enable-tlsext"  \
                --with-openssl="/usr/local/src/openssl-1.0.2j/" --with-ld-opt="-Wl,-rpath,$LUAJIT_LIB" --add-module=/usr/local/src/ngx_devel_kit \
                --add-module=/usr/local/src/lua-nginx-module --without-http_upstream_check_module --with-http_concat_module --with-http_dav_module \
                --with-http_dyups_module --with-http_dyups_lua_api  --with-http_v2_module --with-http_sysguard_module

    #修改版本信息
    vi src/core/nginx.h
    
    #nginx隐藏server信息和版本信息
    进入解压出来的nginx 源码目录
    vi src/http/ngx_http_header_filter_module.c
    
    将
    static char ngx_http_server_string[] = "Server: " TENGINE CRLF;
    static char ngx_http_server_full_string[] = "Server: " TENGINE_VER CRLF;
    
    改为
    static char ngx_http_server_string[] = "Server: X-Web" CRLF;
    static char ngx_http_server_full_string[] = "Server:X-Web " CRLF;
    
    #编译安装
    make && make install

    安装完成，启动nginx服务
    注：如果有以下错误:
    root># service nginx test
    /usr/local/src/nginx/sbin/nginx: error while loading shared libraries: libluajit-5.1.so.2: cannot open shared object file: No such file or directory

    #报错处理
    ln -s /usr/local/lib/libluajit-5.1.so.2 /lib64/libluajit-5.1.so.2   

    解决：
    echo "/usr/local/src/lib" > /etc/ld.so.conf.d/usr_local_lib.conf
    ldconfig


## 三、nginx启动脚本(详见github中的nginx文件)

    为启动脚本添加执行权限

    chmod 755 /etc/init.d/nginx

    开机自动启动

    chkconfig nginx on
    
    #centos7启动命令
    systemctl restart nginx.service
    systemctl enable nginx.service


## 四、部署waf

    cd /tmp
    git clone https://github.com/unixhot/waf.git
    cp -a ./waf/waf /usr/local/nginx/conf/

    #修改Nginx的配置文件，http段加入以下配置。注意路径，同时WAF日志默认存放在/tmp/日期_waf.log
        #WAF
        lua_shared_dict limit 50m;
        lua_package_path "/usr/local/nginx/conf/waf/?.lua";
        init_by_lua_file "/usr/local/nginx/conf/waf/init.lua";
        access_by_lua_file "/usr/local/nginx/conf/waf/access.lua";
        
    #还需注意/usr/local/nginx/conf/waf/config.lua里面配置的一个路径
    config_rule_dir = "/usr/local/nginx/conf/waf/rule-config"
    
    或者
    方式二：直接克隆这个项目
    git clone https://github.com/Lancger/waf.git
    cp -a ./waf/waf /usr/local/nginx/conf/

    

## 五、测试waf

    #测试安装 安装完毕后，下面可以测试安装了，修改nginx.conf server段添加如下配置

        location /hello {
                default_type 'text/plain';
                content_by_lua 'ngx.say("hello,lua")';
        }

    重新加载配置测试验证
    /usr/local/nginx/sbin/nginx -t
    /usr/local/nginx/sbin/nginx -s reload
    
    然后访问http://xxx.xxx.xxx.xxx/hello 如果出现hello,lua。表示安装完成,然后就可以。
    
    测试一：
    http://xxx.xxx.xxx.xxx/?id=../etc/password  会跳到网站防火墙页面
    
    测试二：
    白名单测试(将hello加到url黑名单，那么http://192.168.56.131/hello 就会被拦截，将其加到url白名单就可以正常
    [root@localhost rule-config]# cat url.rule
    hello
    
    拦截日志
    {"user_agent":"Mozilla\/5.0 (Macintosh; Intel Mac OS X 10.14; rv:62.0) Gecko\/20100101 Firefox\/62.0","rule_tag":"hello","req_url":"\/hello","client_ip":"192.168.56.1","local_time":"2018-10-31 12:05:39","attack_method":"Deny_URL","req_data":"-","server_name":"localhost"}--这里显示是被Deny_URL拦截了
    
    

## 六、编辑nginx配置文件(详见github中的nginx.conf文件)

    cd /usr/local/nginx/conf/
    cp -rf nginx.conf nginx.conf.bak
    touch upstream.conf
    mkdir vhost
    #mkdir -p /data0/upload    #nginx配置文件中定义了curl 上传文件的路径


## 七、Web host案例

    cd /usr/local/nginx/conf/vhost/
    root># cat daily.test.com.conf
    server
    {
          listen          80;
          server_name     daily.test.com;

          index index.jsp index.html index.htm ;
          access_log  /usr/local/nginx/logs/daily.test.com.com.log  main;
          error_log   /usr/local/nginx/logs/daily.test.com.com.error.log main;

          location ~* ^/webapi {
                 include /usr/local/nginx/conf/proxy_store_off.conf;
                 add_header  Cache-Control  no-cache;
                 expires -1;
                 proxy_pass http://quant-webapi;
              }

          location / {
                 include /usr/local/nginx/conf/proxy_store_off.conf;
                 add_header  Cache-Control  no-cache;
                 expires -1;
                 proxy_pass http://quant-webclient;
              }
    }


## 八、添加域名vhost配置文件
```
cd /usr/local/nginx/conf/vhost/
root># cat dbgw.test.com.conf
upstreamdbgw {
    server unix:///tmp/uwsgi_dbgw.sock;
}

server {
    listen          80;
    server_name     localhost dbgw.test.com;
    rewrite ^(.*)$  https://$host$1;
}

# server {
#     listen          80;
#     server_name     localhost dbgw.test.com;
#     set $purge_uri $request_uri;
#     index index.jsp index.html index.htm ;
#     root /data0/www/dbgw.test.com;
#
#     error_page 405 =200 @405;
#     access_log  /usr/local/nginx/logs/dbgw.test.com.log  zwccdn;
#     error_log   /usr/local/nginx/logs/dbgw.test.com.error.log info;
#
#     location / {
#         include /usr/local/nginx/conf/uwsgi_params;
#         uwsgi_pass dbgw;
#         uwsgi_param UWSGI_PYHOME /home/www/dbgw/venv/;
#         uwsgi_param UWSGI_CHDIR  /home/www/dbgw/;
#         uwsgi_param UWSGI_SCRIPT run:app;
#     }
#
#     dav_methods PUT;
# }

server {
    listen          443;
    server_name     localhost dbgw.test.com;
    set $purge_uri $request_uri;
    index index.jsp index.html index.htm ;
    root /data0/www/dbgw.inzwc.com;

    ssl on;
    ssl_certificate /home/www/dbgw/cert/ssl/dbgw.test.com.crt;
    ssl_certificate_key /home/www/dbgw/cert/ssl/dbgw.test.com.key;
    ssl_session_timeout 10m;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers  ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-RC4-SHA:ECDHE-RSA-RC4-SHA:ECDH-ECDSA-RC4-SHA:ECDH-RSA-RC4-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES256-SHA:RC4-SHA;
    ssl_prefer_server_ciphers on;

    error_page 405 =200 @405;
    access_log  /usr/local/nginx/logs/dbgw.test.com.log  zwccdn;
    error_log   /usr/local/nginx/logs/dbgw.test.com.error.log info;

    location / {
        include /usr/local/nginx/conf/uwsgi_params;
        uwsgi_pass zwcdbgw;
        uwsgi_param UWSGI_PYHOME /home/www/dbgw/venv/;
        uwsgi_param UWSGI_CHDIR  /home/www/dbgw/;
        uwsgi_param UWSGI_SCRIPT run:app;
        uwsgi_connect_timeout 10m;
        uwsgi_read_timeout 10m;
        uwsgi_send_timeout 10m;
    }

    dav_methods PUT;
}

```
###测试nginx是否能正常启动
```
root># service nginx test
the configuration file /usr/local/nginx/conf/nginx.conf syntax is ok
configuration file /usr/local/nginx/conf/nginx.conf test is successful

root># /etc/init.d/nginx test
the configuration file /usr/local/nginx/conf/nginx.conf syntax is ok
configuration file /usr/local/nginx/conf/nginx.conf test is successful
```


## 报错问题：

    1、Git版本导致的

    root># git clone https://github.com/simplresty/ngx_devel_kit.git
    Initialized empty Git repository in /usr/local/src/ngx_devel_kit/.git/
    error:  while accessing https://github.com/simplresty/ngx_devel_kit.git/info/refs

    fatal: HTTP request failed
    
    #问题原因是：是curl 版本问题，更新curl版本后问题解决（或者升级git版本）
    
    yum update -y nss curl libcurl

```


waf地址：

https://github.com/loveshell/ngx_lua_waf

http://blog.csdn.net/qq_25551295/article/details/51744815

