# core/__init__.py
```
[root@node1 scripts]# cd core/
[root@nde1 core]# ls
__init__.py  __init__.pyc
[root@tw06a2717 core]# cat __init__.py
#!/bin/bin/env python
#coding:utf-8

import json 
import urllib2

class ZabbixAPI(object):

    def __init__(self,url,user,password,headers = {"Content-Type":"application/json"}):
        self.request_data = {
            "jsonrpc":"2.0",
            "method":"user.login",
            "params":"null",
            "id": 1,
        }
        self.url = url + "/api_jsonrpc.php"
        self.headers = headers
        self.login(user,password)

    def login(self,user,password):
        method = "user.login"
        params = {"user":user,"password":password}
        auth = self.deal_request(method=method,params=params)
        self.request_data["auth"] = auth

    def deal_request(self,method,params):
        self.request_data["method"] = method
        self.request_data["params"] = params
        request = urllib2.Request(url=self.url,data=json.dumps(self.request_data),headers=self.headers)
        try:
            response = urllib2.urlopen(request)
            #return json.loads(response.read())["result"]
            s = json.loads(response.read())
            return s["result"]
        except Exception as e:
            print "Error: ",e

    def __getattr__(self,name):
        return ZabbixObj(name,self)

class ZabbixObj(object):

    def __init__(self,method_fomer,ZabbixAPI):
        self.method_fomer = method_fomer
        self.ZabbixAPI = ZabbixAPI

    def __getattr__(self, name):
        def func(params):
            method = self.method_fomer+"."+name
            params = params
            return  self.ZabbixAPI.deal_request(method=method,params=params)
        return func
```


# cat zabbix_autoreg_group.daemon.py
```
#!/usr/bin/env python
#coding:utf-8

import optparse
import sys
import traceback
from getpass import getpass
from core import ZabbixAPI
import urllib2,json
import time

def errmsg(msg):
    sys.stderr.write(msg + "\n")
    sys.exit(-1)


def get_cmdb_hostinfo(hostname):
    cmdb_url = "https://cmdb.test.net/api/get/cmdb/api/find?hostname=%s" %(hostname)
    print cmdb_url
    req = urllib2.Request(cmdb_url)
    print req
    response = urllib2.urlopen(req)
    result = response.read()
    print result
    j_res = json.loads(result)
    print "===="
    print j_res
    print "===="
    if j_res:
        tmp_res = j_res[0]['level']
        print "aaaa"
        print tmp_res
        print "aaaa"
        if tmp_res:
            idx = tmp_res.rindex('')
            res = tmp_res[:idx]
            print "idx:%s"%idx
            print "res:%s"%res
            print "Group:%s" %(res)
            return res
        else:
            print "host: %s not assigned to a group" %(hostname)
            return ""
    else:
        req = urllib2.Request(cmdb_url)
        response = urllib2.urlopen(req)
        result = response.read()
        j_res = json.loads(result)
        if j_res:
            tmp_res = j_res[0]['level']
            idx = tmp_res.rindex('-')
            res = tmp_res[:idx]
            print "Group:%s" %(res)
            return res
        else:
            return ""
    

if __name__ == "__main__":

    zapi = ZabbixAPI("http://zabbix.test.com","Admin", "123456")
    
    ##get all host within Discovered hosts group
    hosts = zapi.host.get({"groupids":5,"output":["host"]})

    for host in hosts:
        hostname = host['host']
        print "hostname:%s" %(hostname)
        groups = get_cmdb_hostinfo(hostname)
        if not groups:
            pass
        groups_id = zapi.hostgroup.get({"output": "groupid","filter": {"name":groups.split(";")}})
        obj_host = zapi.host.get({"filter":{"host":hostname}})
        if obj_host:
            hostid = obj_host[0]["hostid"]
        else:
            print "host:%s not register to zabbix server" %(hostname)
            pass
        if not groups_id:
            for group_name in groups.split(";"):
                try:
                    if group_name:
                        print "create host group %s" %(group_name)
                        zapi.hostgroup.create({"name":group_name})
                        groups_id = zapi.hostgroup.get({"output": "groupid","filter": {"name":group_name}})
                        print zapi.hostgroup.massadd({"groups":groups_id,"hosts":hostid})
                        ##Remove host from Discovered hosts group
                        zapi.hostgroup.massremove({"groupids":5,"hostids":hostid})
                except Exception as e:
                    print str(e)
                    #time.sleep(2)
        else:
            for group_name in groups.split(";"):
                try:
                    print "+++"
                    print group_name
                    print "+++"
                    groups_id = zapi.hostgroup.get({"output": "groupid","filter": {"name":group_name}})
                    print "adding host %s to group %s" %(hostname,group_name)
                    zapi.hostgroup.massadd({"groups":groups_id,"hosts":hostid})
                    ##Remove host from Discovered hosts group
                    zapi.hostgroup.massremove({"groupids":5,"hostids":hostid})
                except Exception as e:
                    print str(e) 

```
# 接口

  ![cmdb_api](https://github.com/Lancger/opslinux/blob/master/images/cmdb_api.png)
