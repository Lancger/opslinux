 # Shell脚本监控服务器pts登录情况记录为日志并钉钉通知
 
## 一、Ubuntu下用nali查询IP地址归属地：
安装nali
```
apt-get update
apt-get install unzip make gcc gawk -y


cd /usr/local/src/
wget https://github.com/dzxx36gyy/nali-ipip/archive/master.zip
unzip master.zip
cd nali-ipip-master/
./configure && make && make install && nali-update
```

查看一下环境变量nali在哪个目录下：
```sh
which nali
```

使用nali命令瞧一瞧:
```sh
nali  42.96.189.63

42.96.189.63 [中国 山东 青岛]
```

    如果nali命令得到的中文地名输入到log中或发送出去的邮件中为空或乱码，那可能是服务器、脚本的编码问题，请自行解决。下面说正事儿：

## 三、编写脚本

```
vim /etc/bash.bashrc

LoginInfo=`last | grep "still logged in" | head -n1`
UserName=`echo $LoginInfo | gawk '{print $1}'`
Hostname=`hostname`
LoginIP=`echo $LoginInfo | gawk '{print $3}'`
LoginTime=`date +'%Y-%m-%d %H:%M:%S'`
LoginPlace=`/usr/local/bin/nali $LoginIP | gawk -F'[][]' '{print $2}'`
url="https://oapi.dingtalk.com/robot/send?access_token=cb45835cbcfdb378d3bc2b82f172a47e8e9cd08c1f439192af19e96e936a1338"
UA="Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/535.24 (KHTML, like Gecko) Chrome/19.0.1055.1 Safari/535.24"
res=`curl -XPOST -s -L -H "Content-Type:application/json" -H "charset:utf-8" $url -d "
{
\"msgtype\": \"text\", 
\"text\": {
         \"content\": \"=====服务器上线通知=====\n用户名 : $UserName\n主机名 : $Hostname\n来源IP : $LoginIP\n归属地 : $LoginPlace\n登录时间 : $LoginTime\"
         },
\"at\": {
         \"atMobiles\": [""],
         \"isAtAll\": false
         }
}"`
```
  


参考文档：

https://cloud.tencent.com/developer/article/1362614  利用Nali-ipip在线工具查看域名解析/IP位置/MTR追踪路由

https://my.oschina.net/jamieliu/blog/718863   Shell脚本监控服务器pts登录情况记录为日志并邮件通知
