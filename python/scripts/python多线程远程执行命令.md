# 一、安装pip
```
wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py
python get-pip.py
pip install paramiko
```

# 二、配置信息集成
```
###vim pssh.py

#!/usr/bin/python
# -*- coding: UTF-8 -*-

import sys,time,os
import paramiko
import threading
 
class SSHThread(threading.Thread):
    def __init__(self, ip, port,user,pwd,timeout,cmd):
        threading.Thread.__init__(self)
        self.ip = ip
        self.port = port
        self.user = user
        self.pwd = pwd
        self.timeout = timeout
        self.cmd = cmd
        self.LogFile = "/tmp/test.log"
    def run(self):
        print("Start try ssh => %s" % self.ip)
        try:
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh.connect(self.ip, self.port, username=self.user, password=self.pwd, timeout=self.timeout)
            print("[%s] Login %s => %s " % (self.ip, self.user, self.pwd))
            open(self.LogFile, "a").write("[ %s ] IP => %s, port => %d, %s => %s" % (time.asctime( time.localtime(time.time()) ), self.ip, self.port, self.user, self.pwd))
            print("[%s] exec : %s" % (self.ip,self.cmd))
            open(self.LogFile,"a").write("[%s] exec : %s" % (self.ip,self.cmd))
            stdin,stdout,stderr = ssh.exec_command(self.cmd)
            print("[%s] exec result : %s" % (self.ip,stdout.read()))
            return True
        except:
            print("[%s] Error %s => %s" % (self.ip, self.user, self.pwd))
            open(self.LogFile, "a").write("[%s] Error %s => %s" % (self.ip, self.user, self.pwd))
            return False
def ViolenceSSH(ip, port,user,pwd,timeout,cmd):
    ssh_scan = SSHThread(ip, port, user, pwd, timeout,cmd)
    ssh_scan.start()
 
 
if __name__ == '__main__':
    ipList = ['192.168.56.11','192.168.56.12']
    for ip in ipList:
        threading.Thread(target = ViolenceSSH, args = (ip, 22,'root','1234',3,'uptime' )).start()
```

# 三、配置分离

1、主机信息
```
[root@linux-node1 ~]# cat user.txt 
192.168.56.11 root 123456
192.168.56.12 root 123456
```
2、脚本
```
###vim pssh.py

#!/usr/bin/python
# -*- coding: UTF-8 -*-

import sys,time,os
import paramiko
import threading
 

class SSHThread(threading.Thread):
    def __init__(self, ip, port,user,pwd,timeout,cmd):
        threading.Thread.__init__(self)
        self.ip = ip
        self.port = port
        self.user = user
        self.pwd = pwd
        self.timeout = timeout
        self.cmd = cmd
        self.LogFile = "/tmp/test.log"
    def run(self):
        print("Start try ssh => %s" % self.ip)
        try:
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh.connect(self.ip, self.port, username=self.user, password=self.pwd, timeout=self.timeout)
            print("[%s] Login %s => %s " % (self.ip, self.user, self.pwd))
            open(self.LogFile, "a").write("[ %s ] IP => %s, port => %d, %s => %s" % (time.asctime( time.localtime(time.time()) ), self.ip, self.port, self.user, self.pwd))
            print("[%s] exec : %s" % (self.ip,self.cmd))
            open(self.LogFile,"a").write("[%s] exec : %s" % (self.ip,self.cmd))
            stdin,stdout,stderr = ssh.exec_command(self.cmd)
            print("[%s] exec result : %s" % (self.ip,stdout.read()))
            return True
        except:
            print("[%s] Error %s => %s" % (self.ip, self.user, self.pwd))
            open(self.LogFile, "a").write("[%s] Error %s => %s" % (self.ip, self.user, self.pwd))
            return False


def ViolenceSSH(ip, port,user,pwd,timeout,cmd):
    ssh_scan = SSHThread(ip, port, user, pwd, timeout,cmd)
    ssh_scan.start()


def read_txt(filename):
    f = open(filename, 'r')
    rows = []
    for line in f:
        row = line.split()
        row[0] = str(row[0])
        row[1] = str(row[1])
        row[2] = str(row[2])
        rows.append(row)
    return rows


if __name__ == '__main__':
    res = read_txt('user.txt')
    for i in res:
        threading.Thread(target = ViolenceSSH, args = (i[0],22,i[1],i[2],3,'uptime' )).start()
```
参考文档：

https://blog.csdn.net/u011085172/article/details/72965392  python 多线程远程执行命令

https://xbuba.com/questions/25013792  如何从Python中的txt文件中读取数据集？
