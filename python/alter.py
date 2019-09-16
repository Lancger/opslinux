#!/usr/bin/env python
#coding=utf-8 
#报警模块
#更改日志：2019-05-31
import requests
import json
import smtplib
from email.mime.text import MIMEText
from email.utils import formataddr

class DinTalk():
    """
     钉钉webhook消息发送
    """
    headers = {
        "Content-Type": "application/json"
    }
    req_message = {
        "errcode": 1,
        "errmessage": ""
    }
    def __init__(self, webhook):
        """
        :param webhook: webhook，只需要URL后面webhook=后面的值
        """
        self.webhook = webhook
    def sendmessage(self,user, message):
        """
        :param message: 发送的消息
        :return: errcode  1 正常，0失败
        """
        data = {
            "msgtype": "text",
            "text": {
                "content": str(message)
            },
            "at": {
                "atMobiles": [
                    user
                ],
                "isAtAll": False
            }
        }
        post_url = "https://oapi.dingtalk.com/robot/send?access_token={0}".format(self.webhook)
        try:
            req = requests.post(post_url, data=json.dumps(data), headers=self.headers,timeout=10)
            if req.status_code == 200 and req.json()["errcode"] == 0:
                return self.req_message  # 发送成功
            else:
                self.req_message["errcode"] = 0
                self.req_message["errmessage"] = str(req.json())
                return self.req_message # 发送失败
        except Exception as e:
            self.req_message["errcode"] = 0
            self.req_message["errmessage"] = "请求钉钉失败，监测你的网络是否正常"
            return self.req_message  # 请求失败

class WeiXin():
    """
      微信消息发送
     """
    req_message = {
        "errcode": 1,
        "errmessage": ""
    }
    headers = {
        "Content-Type": "application/json"
    }
    def __init__(self, corpid,corpsecret,agentid):
        """
        :param corpid:  企业id
        :param corpsecret:  自定义应用secret
        :param agentid: 自定义应用ID
        """
        self.corpid = corpid
        self.corpsecret = corpsecret
        self.agentid = agentid
    def __access_token(self):
        """
        :return: access_token
        """
        try:
            req = requests.get("https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid={0}&corpsecret={1}".format(self.corpid,self.corpsecret))
            if req.json()["errcode"] != 0:
                self.req_message["errcode"] = 0
                self.req_message["errmessage"] = "获取access_token失败:"+str(req.json())
            else:
                self.req_message["errmessage"] = req.json()["access_token"]
            return self.req_message
        except Exception as e:
            self.req_message["errcode"] = 0
            self.req_message["errmessage"] = "获取access_token失败，监测你的网络是否正常"
            return self.req_message  # 请求失败

    def sendmessage(self,touser,message):
        """
        :param touser: 发送给的用户，会@对应的人 支持多用户UserID1|UserID2|UserID3
        :param message:  发送的消息
        :return:  json
        """
        data = {
           "touser" : touser, #UserID1|UserID2|UserID3
#           "toparty" : "PartyID1|PartyID2",
#           "totag" : "TagID1 | TagID2",
           "msgtype" : "text",
           "agentid" : self.agentid,
           "text" : {
               "content" : message
           },
           "safe":0
        }
        access_token = self.__access_token()
        if access_token["errcode"]:
            try:
                req = requests.post("https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token={}".format(access_token["errmessage"]),
                                    data=json.dumps(data),headers=self.headers,timeout=10)

                if req.json()["errcode"] == 0:
                    self.req_message["errmessage"] = "发送成功"
                else:
                    self.req_message["errcode"] = 0
                    self.req_message["errmessage"] = str(req.json())
            except:
                self.req_message["errcode"] = 0
                self.req_message["errmessage"] = "发送失败，请求接口错误"
        else:
            return access_token
        return self.req_message

class Email():
    """
    邮件消息,默认QQ邮箱不用传递smtp参数
    """
    req_message = {
        "errcode": 1,
        "errmessage": ""
    }
    def __init__(self,from_sender,from_pass,smtp = "smtp.qq.com",smtp_port=465,smtp_ssl=True):
        """
        :param from_sender: 发件人
        :param from_pass: 发件人密码
        :param smtp: smtp地址，默认QQ邮箱
        :param smtp_port: smtp端口
        :param smtp_ssl: 是否启用ssl
        """
        self.from_sender = from_sender
        self.from_pass = from_pass
        self.smtp = smtp
        self.smtp_port = smtp_port
        self.smtp_ssl = smtp_ssl
    def sendmessage(self,to_mail, title ,message):
        """
        :param to_mail: 收件人
        :param message: 消息类容
        :return:
        """
        ret = True
        try:
            msg = MIMEText(message, 'plain', 'utf-8')
            msg['From'] = formataddr([str(self.from_sender), self.from_sender])  # 括号里的对应发件人邮箱昵称、发件人邮箱账号
            msg['To'] = formataddr([str(to_mail), to_mail])  # 括号里的对应收件人邮箱昵称、收件人邮箱账号
            msg['Subject'] = title  # 邮件的主题，也可以说是标题
            if not self.smtp_ssl:
                server = smtplib.SMTP(self.smtp,self.smtp_port)
            else:
                server = smtplib.SMTP_SSL(self.smtp,self.smtp_port)  # 发件人邮箱中的SMTP服务器，端口是25
            server.login(self.from_sender, self.from_pass)  # 括号中对应的是发件人邮箱账号、邮箱密码
            server.sendmail(self.from_sender, [to_mail, ], msg.as_string())  # 括号中对应的是发件人邮箱账号、收件人邮箱账号、发送邮件
            server.quit()  # 关闭连接
        except Exception as e:  # 如果 try 中的语句没有执行，则会执行下面的 ret=False
            self.req_message["errcode"] = 0
            self.req_message["errmessage"] = "发送失败{0}".format(e)
        return self.req_message
