# 一、使用全站加密，http自动跳转https（可选）

对于用户不知道网站可以进行https访问的情况下，让服务器自动把http的请求重定向到https。

在服务器这边的话配置的话，可以在页面里加js脚本，也可以在后端程序里写重定向，当然也可以在web服务器来实现跳转。

Nginx是支持rewrite的（只要在编译的时候没有去掉pcre）

在http的server里增加rewrite ^(.*) https://$host$1 permanent;

```
server {
    listen       80;
    server_name  xxx.com www.xxx.com;
    rewrite ^(.*) https://$host$1 permanent;
}


server {
  listen      80;
  server_name xxx.com www.xxx.com;
  return      301 https://$server_name$request_uri;  //这是 nginx 最新支持的写法
}

要新加一个server 不要写在listen 443里面，写在里面就一直是https重定向到https，进入死循环。
```

参考文档：

https://blog.csdn.net/benpaodelulu_guajian/article/details/78456971   服务器 nginx配置ssl并http重定向到https
