# -*- coding:utf-8 -*-
## CDN异常检查脚本,主要进行以下选项的异常检测
## 1.管理域带宽波动告警
## 2.前端频道带宽波动告警
## 3.频道错误码波动告警
## 4.cdn实时监控带宽告警

import re
import sys
import requests
import time
import datetime
import logging
import json,base64,copy
reload(sys)
sys.setdefaultencoding('utf-8')


logging.basicConfig(level=logging.INFO,
#logging.basicConfig(level=logging.ERROR,
#logging.basicConfig(level=logging.DEBUG,
#logging.basicConfig(level=logging.WARNING,
                    stream=sys.stdout,
                    datefmt='%Y-%m-%d %H:%M:%S',
                    #format='[%(asctime)s] - %(filename)s[line:%(lineno)d] - %(levelname)s - %(message)s')
                    format='[%(asctime)s] - %(levelname)-7s - %(message)s')

class Syncer(object):

    """class alert，use to process cdn info and send alert"""
    #初始化函数，用来初始化mysql以及一些必要的信息
    def __init__(self):
        super(Syncer, self).__init__()
        logging.info('初始化对象完毕')

    #从cmdb同步消息到consul kv中
    def cmdb_sync_consul(self,cmdb_api,consul_api,consul_token):
        global monitor_config,origin_monitor_config
        ## 1.从cmdb请求指定模块的信息并且解析
        ## 2.将解析的信息添加监控信息
        ## 3.将处理完毕的信息导到consul kv中
        r = requests.get(cmdb_api)
        if r.status_code != 200:
            logging.fatal("请求cmdb_api失败,状态码非200：%s,%s"%(cmdb_api,r.status_code))
        else:
            logging.info("请求cmdb_api成功,继续下一步")
        for server in r.json()['data']['list']:
            server_dns = server['hostname'] + '.sandai.net'
            server_name = server['hostname']
            server_level = server['level']
            consul_path = server['mod_detail'][0]['mod1'] + '/' + server['mod_detail'][0]['mod2'] + '/' + server['mod_detail'][0]['mod3'] + '/'

            # 判断是否有针对改模块设置特殊的监控
            if server_level in monitor_config:
                # 遍历添加所有的exporter信息
                consul_content = monitor_config[server_level]
                for k in consul_content:
                    consul_content[k]['name'] = server_name
                    consul_content[k]['address'] = server_dns
                    service_tags = consul_content[k]['tags']
                    service_tags.append('hostname=%s'%service_name)
                    service_tags.append('mod1=%s'%server['mod_detail'][0]['mod1'])
                    service_tags.append('mod2=%s'%server['mod_detail'][0]['mod2'])
                    service_tags.append('mod3=%s'%server['mod_detail'][0]['mod3'])
                    consul_content[k]['tags'] = service_tags
                    print "in",consul_content
            else:
                consul_content = monitor_config['default']
                # 遍历添加所有的exporter信息
                for k in consul_content:
                    print k
                    consul_content[k]['name'] = server_name
                    consul_content[k]['address'] = server_dns
                    service_tags = consul_content[k]['tags']
                    service_tags.append('hostname=%s'%server_name)
                    service_tags.append('mod1=%s'%server['mod_detail'][0]['mod1'])
                    service_tags.append('mod2=%s'%server['mod_detail'][0]['mod2'])
                    service_tags.append('mod3=%s'%server['mod_detail'][0]['mod3'])
                    consul_content[k]['tags'] = service_tags
                print "notin",consul_content
            # 提交到consul kv中
            headers = {'x-consul-token': consul_token}
            consul_full_url = consul_api + consul_path + server_name
            r = requests.put(consul_full_url, headers=headers, data=json.dumps(consul_content))
            if r.status_code != 200:
                logging.fatal("数据写入到consul kv中失败：%s,%s,%s"%(consul_full_url,r.status_code,json.dumps(consul_content)))
            else:
                logging.info("数据写入到consul kv中成功:%s"%consul_full_url)
            #
            monitor_config = copy.deepcopy(origin_monitor_config)    


    #将consul中的kv，转换为consul service
    def convert_to_service(self,consul_api,consul_token,consul_register_api):
        # curl -v -H 'x-consul-token: 77e387a9-d3e1-b591-9b91-6647f56817d2' http://localhost:8500/v1/kv/IAAS/cmdb_config?recurse |jq .
        # 遍历所有的kv节点，然后转换成service提交到consul中
        consul_kv_url = '%s?recurse'%consul_api
        headers = {'x-consul-token': consul_token}
        r = requests.get(consul_kv_url,headers=headers)
        if r.status_code != 200:
            logging.fatal("遍历consul kv,状态码非200：%s,%s"%(consul_kv_url,r.status_code))
        else:
            logging.info("遍历consul kv成功,继续下一步")
        for kv in r.json():
            kv_key = kv['Key']
            try:
                kv_value = json.loads(base64.b64decode(kv['Value']))
                for k,v in kv_value.items():
                    v['name'] = k + '_' + v['name']
                    # 提交到consul service中
                    headers = {'x-consul-token': consul_token}
                    r = requests.put(consul_register_api, headers=headers, data=json.dumps(v))
                    if r.status_code != 200:
                        logging.fatal("数据写入到consul service中失败：%s,%s,%s"%(consul_register_api,r.status_code,json.dumps(v)))
                    else:
                        logging.info("数据写入到consul service中成功:%s：%s"%(consul_register_api,json.dumps(v)))
            except Exception as e:
                logging.info("key对应的内容有误,无法base64解密或者json化,%s:%s"%(kv['Key'],kv['Value']))  

    

if __name__ == '__main__':

    # 监控配置
    monitor_config  = {
        "default": {
            "node_exporter": {
                "port": 9100,
                "tags": ["env=prod", "scrape_interval=1min"]
            }
        }
    }

    origin_monitor_config = copy.deepcopy(monitor_config)

    # cmdb 接口api，鉴权采用ip鉴权
    cmdb_api = "https://cmdb.test.net/api/get/cmdb/machine?limit=0&mod1=运营系统"

    # consul接口api和鉴权token
    consul_api = "http://192.168.52.100:8500/v1/kv/IAAS/cmdb_config/"
    consul_register_api = "http://192.168.52.100:8500/v1/agent/service/register"
    consul_token = "ada1d1--d1-27f56817d2"

    # 创建同步对象
    syncer = Syncer()

    # 从cmdb中获取对象，并且添加监控，同步到consul kv中
    syncer.cmdb_sync_consul(cmdb_api,consul_api,consul_token)

    # 从consul kv中获取配置，转换格式添加到consul service
    # syncer.convert_to_service(consul_api,consul_token,consul_register_api)
