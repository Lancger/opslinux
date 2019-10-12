# 一、脚本文件
```
cat tun_cmd.py

#!/usr/bin/python
# -*- coding: utf-8 -*-

#环境依赖  pip install requests  &&  pip install pycrypto

import json
import time
import requests
import sys 
import uuid
import base64
import hashlib


def printHelp():
	print'''
	Usage: python go_cmd.py [sn_list_filename] [cmd_list_filename]
	'''

def get_token():
	time_now=str(int(time.time()))
	m2 = hashlib.md5()   
	m2.update(time_now+"a&dad&dadadYY4TY")   
	return time_now+"-"+m2.hexdigest()


def getFileContent(filename):
	contents = []
	for line in open(filename):
		content = line.strip()
		contents.append(content)
	return contents


def doExecCommand(snListFile, cmdListFile):
	snList =  getFileContent(snListFile)
	cmdList = getFileContent(cmdListFile)

	for sn in snList:
		for cmd in cmdList:
			resp = sendCommandToTunnel(sn, cmd)
			if resp is not None and resp.has_key("body"):
				print base64.b64decode(resp["body"])
			else:
				print resp


def sendCommandToTunnel(sn, cmd):
	cmdDataDict = {
		"cmd":cmd,
		# "Dir":""
		"timeout":10
	}
	return request_tunnel(json.dumps(cmdDataDict), sn)


def request_tunnel(route_body,sn):
	request_url="http://go-agent.test.com:3000/v1/go_access/route"
	json_data = {"to":sn,
				"to_module":"plugin_tunnel_cmd",
				"msg_id":str(uuid.uuid4()),
				"body":base64.b64encode(route_body),
	}
	
	headers = {
		"Content-Type": "application/json",
		"Grpc-Metadata-Tunnel-Token": get_token(),
		"Host": "go-agent.test.com",
	}
	r = requests.post(request_url, data=json.dumps(json_data),headers=headers)
	try:
		return r.json()
	except:
		return None

if __name__ == "__main__":
	if len(sys.argv) < 3:
		printHelp()
		exit()
	print sys.argv
	doExecCommand(sys.argv[1], sys.argv[2])
```

# 二、配置文件1
```
#cat sn_list.txt

tssssss
```
# 三、配置文件2
```
#cat cmd_list.txt

ls -al /tmp
head -10 /tmp/go-agent.log
```

# 四、使用方法

```
python tun_cmd.py sn_list.txt cmd_list.txt
```
