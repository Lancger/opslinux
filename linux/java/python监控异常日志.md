# 一、脚本
```
#!/usr/bin/python 
#-*- coding:utf-8 -*-
#
from os.path import getsize
from sys import exit
from re import compile, IGNORECASE
import sys, getpass
import smtplib, time
from email.mime.text import MIMEText
log_date = time.strftime("%Y-%m-%d", time.localtime()) 

tomcat_log = '/opt/tomcat-test/logs/catalina.%s.out'%(log_date)
print tomcat_log
# 该文件是用于记录上次读取日志文件的位置
last_position_logfile = '/opt/tomcat-test/logs/last_position.txt'
# 匹配的错误信息关键字的正则表达式
pattern = compile('第三方短信发送失败', IGNORECASE)

#定义发送邮件函数
def mail(content):
  email_host = 'www.test.io'
  maillist =['888888@qq.com','9999999@qq.com']
  me = email_host

  msg = MIMEText(content,'plain', 'utf-8')
  msg['Subject'] = 'taskjob 第三方短信发送失败'
  msg['From'] = me
  #msg['To'] = maillist
  msg['To'] = ','.join(maillist)

  try:
    smtp = smtplib.SMTP('localhost')
    smtp.sendmail(me, maillist, msg.as_string())
    smtp.quit()
    print ('email send success.')
  except smtplib.SMTPException:
    print "Error: 无法发送邮件"

#读取上一次日志文件的读取位置
def get_last_position(file):
  try:
    data = open(file, 'r')
    last_position = data.readline()
    if last_position:
      last_position = int(last_position)
    else:
      last_position = 0
  except:
      last_position = 0
  return last_position

#写入本次日志文件的读取到的本次位置
def write_this_position(file, last_position):
  try:
    data = open(file, 'w')
    data.write(str(last_position))
    data.write('\n' + "Don't Delete This File,It is Very important for Looking Tomcat Error Log !! \n")
    data.close()
  except:
    print "Can't Create File !" + file
    exit()

#分析文件找出Outofmemory
def analysis_log(file):
  error_list = []
  try:
    data = open(file, 'r')
  except:
    exit()
  last_position = get_last_position(last_position_logfile)
  this_position = getsize(tomcat_log)
  if this_position < last_position:
    data.seek(0)
  elif this_position == last_position:
    exit()
  elif this_position > last_position:
    data.seek(last_position)
  for line in data:
    if pattern.search(line):
      error_list.append(line)
  write_this_position(last_position_logfile, data.tell())
  data.close()
  return ''.join(error_list)

if __name__ == '__main__':
  error_info = analysis_log(tomcat_log)
  if  error_info != "":
    mail(error_info)
```

# 二、配置定时任务
```
* * * * * /opt/tomcat-test/bin/log_monitor.py >> /tmp/run.log
```


参考文档：

https://www.cnblogs.com/cornerxin/p/8807799.html
