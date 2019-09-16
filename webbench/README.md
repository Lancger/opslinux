# 一、下载
```
cd /usr/local/src/

wget http://home.tiscali.cz/~cz210552/distfiles/webbench-1.5.tar.gz
```

# 二、安装
```
yum install gcc -y

tar -xzvf webbench-1.5.tar.gz
cd webbench-1.5
mkdir /usr/local/man
chmod 644 /usr/local/man
make install clean
```

# 三、参数
```
只支持get请求，可设定head参数
常用参数：
-c 并发用户数
-t 压测时长

webbench [option]... URL
  -f|--force               Don't wait for reply from server.
  -r|--reload              Send reload request - Pragma: no-cache.
  -t|--time <sec>          Run benchmark for <sec> seconds. Default 30.
  -p|--proxy <server:port> Use proxy server for request.
  -c|--clients <n>         Run <n> HTTP clients at once. Default one.
  -9|--http09              Use HTTP/0.9 style requests.
  -1|--http10              Use HTTP/1.0 protocol.
  -2|--http11              Use HTTP/1.1 protocol.
  --get                    Use GET request method.
  --head                   Use HEAD request method.
  --options                Use OPTIONS request method.
  --trace                  Use TRACE request method.
  -?|-h|--help             This information.
  -V|--version             Display program version.
```

# 四、结果分析
```
webbench -t 60 -c 100 http://www.baidu.com/

Speed 为每分钟多个个请求
Requests 成功多少个请求，失败多少个请求

Webbench - Simple Web Benchmark 1.5
Copyright (c) Radim Kolar 1997-2004, GPL Open Source Software.

Benchmarking: GET http://www.baidu.com/
100 clients, running 60 sec.

Speed=2643 pages/min, 5045450 bytes/sec.
Requests: 2641 susceed, 2 failed.
```
参考文档：

https://blog.csdn.net/u013545439/article/details/91853173
