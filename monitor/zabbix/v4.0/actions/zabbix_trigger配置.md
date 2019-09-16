# 一、触发器设置

  ![触发器01](https://github.com/Lancger/opslinux/blob/master/images/zabbix_trigger_01.png)
  
  
  ![触发器02](https://github.com/Lancger/opslinux/blob/master/images/zabbix_trigger_02.png)


  ![触发器03](https://github.com/Lancger/opslinux/blob/master/images/zabbix_trigger_03.png)

```
#默认操作步骤持续时间
1h

#默认标题
服务器:{HOST.NAME}发生: {TRIGGER.NAME}故障!

#消息内容
当前状态:{TRIGGER.STATUS}
告警主机:{HOST.NAME}
告警地址:{HOST.IP}
监控项目:{ITEM.NAME}
监控取值:{ITEM.LASTVALUE}
告警等级:{TRIGGER.SEVERITY}
告警信息:{TRIGGER.NAME}
告警时间:{EVENT.DATE} {EVENT.TIME}
事件ID:{EVENT.ID}
```

  ![触发器04](https://github.com/Lancger/opslinux/blob/master/images/zabbix_trigger_04.png)

```
#默认标题
服务器:{HOST.NAME}: {TRIGGER.NAME}已恢复!

#消息内容
当前状态:{TRIGGER.STATUS}
告警主机:{HOST.NAME}
告警地址:{HOST.IP}
监控项目:{ITEM.NAME}
监控取值:{ITEM.LASTVALUE}
告警等级:{TRIGGER.SEVERITY}
告警信息:{TRIGGER.NAME}
告警时间:{EVENT.DATE} {EVENT.TIME}
恢复时间:{EVENT.RECOVERY.DATE} {EVENT.RECOVERY.TIME}
持续时间:{EVENT.AGE}
事件ID:{EVENT.ID}
```

  ![触发器05](https://github.com/Lancger/opslinux/blob/master/images/zabbix_trigger_05.png)
  
  
```
#默认标题
服务器:{HOST.NAME}: 报警确认

#消息内容
确认人:{USER.FULLNAME} 
时间:{ACK.DATE} {ACK.TIME} 
确认信息如下:
"{ACK.MESSAGE}"
问题服务器IP:{HOSTNAME1}
问题ID:{EVENT.ID}
当前的问题是: {TRIGGER.NAME}
```
  
