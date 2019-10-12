# 一、安装
```

wget http://download.joedog.org/siege/siege-latest.tar.gz
tar -zxvf siege-latest.tar.gz
cd siege-latest/
./configure
make && make install

```

# 二、相关命令
```
-V, --version             VERSION, prints the version number.
  -h, --help                HELP, prints this section.
  -C, --config              CONFIGURATION, show the current config.
  -v, --verbose             VERBOSE, prints notification to screen.
  -q, --quiet               QUIET turns verbose off and suppresses output.
  -g, --get                 GET, pull down HTTP headers and display the
                            transaction. Great for application debugging.
  -c, --concurrent=NUM      CONCURRENT users, default is 10
  -i, --internet            INTERNET user simulation, hits URLs randomly.
  -b, --benchmark           BENCHMARK: no delays between requests.
  -t, --time=NUMm           TIMED testing where "m" is modifier S, M, or H
                            ex: --time=1H, one hour test.
  -r, --reps=NUM            REPS, number of times to run the test.
  -f, --file=FILE           FILE, select a specific URLS FILE.
  -R, --rc=FILE             RC, specify an siegerc file
  -l, --log[=FILE]          LOG to FILE. If FILE is not specified, the
                            default is used: PREFIX/var/siege.log
  -m, --mark="text"         MARK, mark the log file with a string.
  -d, --delay=NUM           Time DELAY, random delay before each requst
                            between .001 and NUM. (NOT COUNTED IN STATS)
  -H, --header="text"       Add a header to request (can be many)
  -A, --user-agent="text"   Sets User-Agent in request
  -T, --content-type="text" Sets Content-Type in request

```

# 三、使用
```
100个并发访问 http://www.baidu.com，并重复20次

siege -c 100 -r 20 http://www.baidu.com

```

# 四、输出结果
```
Transactions	总共测试次数
Availability	成功次数百分比
Elapsed time	总共耗时多少秒
Data transferred	总共数据传输
Response time	等到响应耗时
Transaction rate	平均每秒处理请求数
Throughput	吞吐率
Concurrency	最高并发
Successful transactions	成功的请求数
Failed transactions	失败的请求数
```

参考资料：

https://www.vincents.cn/2017/03/28/web-pressure-test/   
