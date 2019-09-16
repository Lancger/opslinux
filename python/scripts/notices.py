#!/usr/bin/env python
#-*- coding:utf-8 -*-

# Author: Bryan Xu

import requests,urllib2
import time
import datetime 
import os,json

class Business_info(object):
    def __init__(self, uid, bgtime, edtime):
        self.uid = uid
        self.bgtime = int(bgtime)
        self.edtime = int(edtime)
        self.arry = []

    def query_network(self):
        sqtime = (datetime.datetime.now()+datetime.timedelta(minutes=-self.bgtime)).strftime("%Y-%m-%d %H:%M:%S")
        eqtime = (datetime.datetime.now()+datetime.timedelta(minutes=-self.edtime)).strftime("%Y-%m-%d %H:%M:%S")
        param = "[[\"stime\",\">=\",\"%s\"],[\"stime\",\"<\",\"%s\"]]&limits=[0,100]" %(sqtime,eqtime)
        url = "http://l1.api.data.p2cdn.com/data/json?id=cb44d3b2c163500&filter=%s" %(param)
        print url
        headers = {'Content-Type': 'application/form-data'}
        request = urllib2.Request(url,headers = headers)
        response = urllib2.urlopen(request)
        result = response.read()
        json_res=json.loads(result)
        return json_res

    def get_uid_data(self):
        try:
            obj_loads = self.query_network()
            for dt in obj_loads['data']:
                if self.uid in dt:
                    print dt
                    res1 = int(dt[5])/1024
                    res2 = int(dt[6])/1024
                    res3 = int(dt[7])/1024
                    res4 = int(dt[8])/1024
                    print "上行带宽平均值:%s GB"%(res1)
                    print "上行带宽平均值:%s GB"%(res2)
                    print "下行带宽平均值:%s GB"%(res3)
                    print "下行带宽最大值:%s GB"%(res4)
                    self.arry=[res1,res2,res3,res4]  
                    return res1,res2,res3,res4           
        except Exception, e:
            print "Exception:%s" %(e) 


class Dingtalk(object):
    def __init__(self,webhook):
        self.webhook = webhook

    def _send(self,data):
        headers = {'Content-Type':'application/json;charset=UTF-8'}
        send_data = json.dumps(data).encode('utf-8')
        requests.post(url=webhook,data=send_data,headers=headers)
    
    # 发送markdown内容
    def send_markdown(self, uid, par):
        print "现在发送 %s 客户的数据信息"%(uid)
        data = {
        "msgtype": "markdown",
        "markdown": {
                "title": "xxxx带宽通知信息",
                "text": "## xxxx带宽信息通知 (基准2.5T) \n\n" +
                        "> #### xxxx上行带宽：%s \n\n" %(par.arry[0]) +
                        "> #### xxxx下行带宽：%s \n\n" %(par.arry[1]) +
                        "> #### xxxx目前运行节点数：%s \n\n" %(par.arry[2]) +
                        "> #### xxxx历史运行节点数：%s \n\n" %(par.arry[3]) +
                        "> #### 通知时间: %s \n" % time.strftime("%Y-%m-%d %X")
            }
        }
        #发送消息
        self._send(data)

if __name__ == '__main__':
    webhook = 'https://oapi.dingtalk.com/robot/send?acd3ac8b0a0bf33986b87d625917af2'
    #获取当前时间的数据
    con1=Business_info('16913','21','15')
    con1.get_uid_data()

    print con1.arry
    #获取昨天同一时间的数据
    print "打印昨天的数据"
    con2=Business_info('16913','1461','1455')
    con2.get_uid_data()
    print con2.arry

    #发送消息
    con2=Dingtalk(webhook)
    con2.send_markdown('16913',con1)
