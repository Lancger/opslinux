 # Shell脚本监控服务器pts登录情况记录为日志并电报通知
 
## 一、Ubuntu下用nali查询IP地址归属地：
安装nali
```
apt-get update
apt-get install unzip make gcc gawk -y


cd /usr/local/src/
wget https://github.com/dzxx36gyy/nali-ipip/archive/master.zip
unzip master.zip
cd nali-ipip-master/
./configure && make && make install
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
url="https://api.telegram.org/bot856996817:AAH-J5Cz6EcOaGA4FWjrRkqBrMy38fjjROo/sendMessage"
res=`curl -X POST -s -L \
 -H "Content-Type: application/json" \
 -d "{ 
    \"chat_id\": \"-368394046\", 
    \"text\": \"=====服务器上线通知=====\n用户名 : $UserName\n主机名 : $Hostname\n来源IP : $LoginIP\n归属地 : $LoginPlace\n登录时间 : $LoginTime\",
    \"disable_notification\": true
    }" \
 $url`
```
## 或者下面方式
```
touch /var/log/login_access.log
chmod  666  /var/log/login_access.log

vim /etc/bash.bashrc

CHAT_ID="-359015262"
API_TOKEN="1037033953:AAEUhw1GwLSWJCXA_9gXYUubE3SFSY4nVfA"

CommonlyIP=("192.168.56.10" "139.180.210.37" "120.237.124.116")             #  常用ssh登陆服务器的IP地址,即IP白名单

function SendMessageToTelegram(){
    url="https://api.telegram.org/bot${API_TOKEN}/sendMessage"

    res=`curl -X POST -s -L \
     -H "Content-Type: application/json" \
     -d "{ 
        \"chat_id\": \"${CHAT_ID}\", 
        \"text\": \"=====服务器上线通知=====\n用户名 : $UserName\n主机名 : $Hostname\n来源IP : $LoginIP\n归属地 : $LoginPlace\n登录时间 : $LoginTime\",
        \"disable_notification\": true
        }" \
     $url`
}
    
LoginInfo=`last | grep "still logged in" | head -n1`
UserName=`echo $LoginInfo | gawk '{print $1}'`
Hostname=`hostname`
LoginIP=`echo $LoginInfo | gawk '{print $3}'`
LoginTime=`date +'%Y-%m-%d %H:%M:%S'`
LoginPlace=`/usr/local/bin/nali $LoginIP | gawk -F'[][]' '{print $2}'`
SSHLoginLog="/var/log/login_access.log"

for ip in ${CommonlyIP[*]}  # 判断登录的客户端地址是否在白名单中
do
    if [ "$LoginIP" == $ip ];then
        COOL="YES"
    fi
done

if [ "$COOL" == "YES" ];then
    #echo "用户 $UserName 于北京时间 $LoginTime 登陆了服务器,其IP地址为 ${LoginIP} 安全IP,归属地 ${LoginPlace}" >> $SSHLoginLog
    subject="用户 ${UserName} 于北京时间 ${LoginTime} 登陆了服务器,其IP地址为 ${LoginIP} 安全IP,归属地 ${LoginPlace}"
    #SendMessageToTelegram
elif [ $LoginIP ];then
    #echo "用户 $UserName 于北京时间 $LoginTime 登陆了服务器,其IP地址为 $LoginIP ,归属地 $LoginPlace " >> $SSHLoginLog
    SendMessageToTelegram
fi
```


参考文档：

https://cloud.tencent.com/developer/article/1362614  利用Nali-ipip在线工具查看域名解析/IP位置/MTR追踪路由

https://my.oschina.net/jamieliu/blog/718863   Shell脚本监控服务器pts登录情况记录为日志并邮件通知
