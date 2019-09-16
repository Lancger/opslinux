 # 监控服务器pts登录情况记录为日志并微信通知
 
## 一、Linux下用nali查询IP地址归属地：
安装nali
```
yum install jq -y

cd /usr/local/src/
wget https://github.com/dzxx36gyy/nali-ipip/archive/master.zip
unzip master.zip
cd nali-ipip-master/
./configure && make && make install && nali-update
```

如果要使用nali的全部命令，需要安装一下依赖包
```
#CentOS/RedHat: 

yum install traceroute bind-utils bind-utils -y

#Debian/Ubuntu: 

apt-get update; apt-get install traceroute dnsutils bind-utils -y
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
[www@monitor-server ~]$ cat /etc/ssh/sshrc 
#!/bin/bash
###V1-2019-03-13###

CropID='wwd618cb53fdf20d94'
Secret='HeD64P1nPSTWaUhp_Yne_MY7IsA7lhF-EUZaCOmb_gY'
GURL="https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=$CropID&corpsecret=$Secret"
Gtoken=$(/usr/bin/curl -s -G $GURL | jq -r '.access_token')
PURL="https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=$Gtoken"

LoginInfo=`last | grep "still logged in" | head -n1`
UserName=`echo $LoginInfo | gawk '{print $1}'`
LoginIP=`echo $LoginInfo | gawk '{print $3}'`
LoginTime=`date +'%Y-%m-%d %H:%M:%S'`
LoginPlace=`/usr/local/bin/nali $LoginIP | gawk -F'[][]' '{print $2}'`

function body() {
        local int appId=1000003
        #local userId=$1
        local userId="LinYouYi"
        local partyId=2
        local msg='有用户上线请注意:\n主机名：'`hostname`'\n主机ip：'`curl ifconfig.me`'\n登录用户：'`whoami`'\n来源IP：'$LoginIP'\n归属地：'$LoginPlace'\n登录时间：'$LoginTime
        printf '{\n'
        printf '\t"touser":"'"$userId"\"",\n"
        printf '\t"toparty":"'"$partyId"\"",\n"
        printf '\t"msgtype": "text",'"\n"
        printf '\t"agentid":"'"$appId"\"",\n"
        printf '\t"text":{\n'
        printf '\t\t"content":"'"$msg"\"
        printf '\n\t},\n'
        printf '\t"safe":"0"\n'
        printf '}\n'
}
/usr/bin/curl -s -o /dev/null --data-ascii "$(body)" $PURL
```

参考文档：

https://cloud.tencent.com/developer/article/1362614  利用Nali-ipip在线工具查看域名解析/IP位置/MTR追踪路由

https://my.oschina.net/jamieliu/blog/718863   Shell脚本监控服务器pts登录情况记录为日志并邮件通知
