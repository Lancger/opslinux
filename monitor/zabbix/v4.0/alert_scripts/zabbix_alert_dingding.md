# 一、钉钉告警脚本dingding.py 
```
#!/usr/bin/env python
#coding:utf-8
#zabbix钉钉报警
import requests,json,sys,os,datetime
webhook="https://oapi.dingtalk.com/robot/send?access_token=cb45835cbcfdb378d3bc2b82f172a47e8e9cd08c1f439192af19e96e936a1338"
user=sys.argv[1]
text=sys.argv[3]

data={
    "msgtype": "text",
    "text": {
        "content": text.replace('\r\n','\n')
    },
    "at": {
        "atMobiles": [
            user
        ],
        "isAtAll": False
    }
}

headers = {'Content-Type': 'application/json;charset=utf-8'}
x=requests.post(url=webhook,data=json.dumps(data),headers=headers)

if os.path.exists("/tmp/zabbix_dingding.log"):
    f=open("/tmp/zabbix_dingding.log","a+")
else:
    f=open("/tmp/zabbix_dingding.log","w+")
f.write("\n"+"--"*30)
if x.json()["errcode"] == 0:
    f.write("\n"+str(datetime.datetime.now())+"    "+str(user)+"    "+"发送成功"+"\n"+str(text))
    f.close()
else:
    f.write("\n"+str(datetime.datetime.now()) + "    " + str(user) + "    " + "发送失败" + "\n" + str(text))
    f.close()
```

# 二、测试
```
python dingding.py 1831313122 test "报警类容"

pip install requests urllib3 pyOpenSSL --force --upgrade
pip install --upgrade --force-reinstall 'requests==2.6.0'
```

参考资料：

https://www.cnblogs.com/kevingrace/p/9579282.html  分布式监控系统Zabbix3.4-钉钉告警配置记录 
