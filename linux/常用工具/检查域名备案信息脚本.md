```
# -*- coding = 'utf-8 -*-

import requests
import re
import sys


def isIP(ip):
    """
    判断是否是IP
    """
    return len([i for i in ip.split('.') if (0 <= int(i) <= 255)]) == 4

def IP(ip):
    """
    输入是IP处理函数
    """
    s = requests.session()
    ipContent = s.get('http://wap.ip138.com/ip.asp?ip=%s' % ip).content.decode('utf-8')
    rexIp = re.compile(r'<br/><b>查询结果：(.*)</b><br/>') 
    result = rexIp.findall(ipContent)
    print("查询IP：%s \t %s" % (ip, result[0]))

def Domain(dm):
    """
    输入是domain处理函数
    """
    s = requests.session()
    dmContent = s.get('http://wap.ip138.com/ip.asp?ip=%s'% dm).content.decode('utf-8')
    #print(dmContent)
    rexDm = re.compile(r'&gt; (.*)\t\r\n<br/><b>查询结果：(.*)</b><br/>') 
    result = rexDm.findall(dmContent)
    print('查询域名：%s \t IP地址：%s\t%s' % (dm, result[0][0],result[0][1]))

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("请输入域名或IP地址 (例如:192.168.1.1 / www.baidu.com)")
        sys.exit()
    input = sys.argv[1]
    if not re.findall('(\d{1,3}\.){3}\d{1,3}',input):
        if re.findall(r'(\w+\.)?(\w+)(\.\D+){1,2}',input):
            Domain(input)
        else:
            print("输入的域名格式不正确，请重新输入")
    else:
        if isIP(input):
            IP(input)
        else:
            print("IP地址不合法，请重新输入")
```


checkip

检查域名或IP解析地址及备案信息脚本

python3+ 脚本

使用方法

python3 checkip.py www.baidu.com

结果：查询域名：www.baidu.com IP地址：14.215.177.38 广东省广州市 北京百度网讯科技有限公司电信节点


参考资料：

https://github.com/luckman666/checkip
