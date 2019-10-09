# 一、需求与问题
```
访问新项目网站发现有静态资源获取failed，图片经常无法显示，刷新偶尔图片能显示出来。
查看nginx日志，有error.log报错：

    【2017/07/21 22:53:12 [warn] 22402#0: *484 an upstream response is buffered to a temporary file /var/tmp/nginx/proxy//6/01/0000000016 while reading upstream, client: 106.121.13.193, server: wap.example.com, request: “GET /source/images/applyfristbg.jpg HTTP/1.1”, upstream: “http://127.0.0.1:8081/source/images/applyfristbg.jpg", host: “wap.example.com”, referrer: “http://wap.example.com/source/css/apply-first-7ae1ca00a910468d350b293787c7e95dfbebd675.css”】

```

# 二、问题原因
```
    1、是因为nginx默认的buffer太小，请求头header太大时会出现缓存不足，写入到了磁盘中，造成访问中断。
    2、进而联系前端得知前端为了SEO，在header中加入和不少的中文词汇，header体积那叫一个大。

```

# 三、解决办法

因为nginx+tomcat中，nginx做的proxy，就是反向代理，所以在nginx+tomcat模式中，修改fastcgi_buffer_* 是无效的，需要修改proxy对应的buffer大小。

对于php+nginx的可以设置为：
```
fastcgi_buffer_size 512k;
fastcgi_buffers 6 512k;
fastcgi_busy_buffers_size 512k;
fastcgi_temp_file_write_size 512k;
```
对于tomcat+nginx的可以设置为：
```
proxy_buffering    off;
proxy_buffer_size  128k;
proxy_buffers 100  128k;
client_max_body_size 100m;
```

参考资料：

http://madblog.cn/posts/3a67d943aecf0d77.html
