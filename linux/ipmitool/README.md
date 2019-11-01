```
#安装
yum install ipmitool -y

#手动加载模块
modprobe ipmi_watchdog
modprobe ipmi_poweroff
modprobe ipmi_devintf
modprobe ipmi_si
modprobe ipmi_msghandler

#查看远控卡IP
ipmitool lan print

#重置远控卡
ipmitool mc reset cold
```
