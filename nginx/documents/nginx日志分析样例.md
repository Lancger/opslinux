# 一、grep获取某个时间段的日志
```
#获取8月25号18:25-29时间段的日志

grep -n "25/Aug/2019:18:2[5-9]:00" www.test.co.log > /tmp/1.log

参考：https://blog.csdn.net/weixin_36691991/article/details/89456337
```

# 二、sed获取某个时间段的日志
```
日志原格式
47.56.116.73 - - [25/Aug/2019:21:54:53 +0800] "POST /api/v1/cancelEntrust HTTP/1.1" 200 46 "-" "Apache-HttpClient/4.5.6 (Java/1.8.0_161)" "-" "172.18.15.82:8080" "200" "0.035" "0.035"

sed -n '/25\/Aug\/2019:21:49:19/','/25\/Aug\/2019:21:50:19/p' www.test.co.log

参考：https://www.jianshu.com/p/6f019e182e52
```
