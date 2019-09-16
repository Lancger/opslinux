#!/usr/bin/python
# -*- coding: UTF-8 -*-
"""
@author: Bryan
@file: send_mails.py
@time: 2019/03/13 12:55
@desc: 发送邮件模块
"""
import smtplib
from email.header import Header
from email.mime.text import MIMEText

mail_receivers=["11580610@qq.com","1231313@qq.com"]

class SendMail(object):
    def __init__(self):
        """ 初始化邮箱模块 """
        try:
            self.mail_host = "smtp.qq.com"        # 邮箱服务器
            self.mail_port = "25"                 # 邮箱服务端端口
            self.mail_user = "88888880@qq.com"    # 邮箱用户名
            self.mail_pwd = "daadadad"            # 邮箱授权码
            self.mail_receivers = mail_receivers  # 收件人,以逗号分隔成列表
            smtp = smtplib.SMTP()
            smtp.connect(self.mail_host, self.mail_port)
            smtp.login(self.mail_user, self.mail_pwd)
            self.smtp = smtp
        except:
            print('发邮件---->初始化失败!请检查用户名和密码是否正确!')

    def send_mails(self, content):
        """ 发送邮件 """
        try:
            message = MIMEText(content, 'plain', 'utf-8')
            message['From'] = Header("登录检测机器人小咪", 'utf-8')
            message['To'] = Header("用户登录系统通知", 'utf-8')
            subject = '用户登录通知信息'
            message['Subject'] = Header(subject, 'utf-8')
            self.smtp.sendmail(self.mail_user, self.mail_receivers, message.as_string())
            print('发送邮件成功!')
        except Exception as e:
            print('发邮件---->失败!原因:', e)

    def mail_close(self):
        """ 关闭邮箱资源 """
        self.smtp.close()

if __name__ == "__main__":
    sendMail = SendMail()          #实例化
    sendMail.send_mails("测试邮件") #调用send_mails发送邮件函数
    sendMail.mail_close()          #关闭连接
