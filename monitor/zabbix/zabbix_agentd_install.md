```
#!/bin/bash
#Date: 2019-06-04
#Author: Bryan
#Mai: 1151980610@qq.com
#Function:  This script is used for system Centos6 or Centos7 install  zabbix-agentd
#Version:  V1.0
#Update:  2019-06-04
 
. /etc/init.d/functions
 
#check zabbix_agentd
check_zabbix_agentd(){
  check=`ps -ef|grep zabbix_agentd`
  if [ "$check" = ""  ]; then
      echo "zabbix_agentd 服务未正在运行"
  else
      echo "zabbix_agentd 服务已经正在运行"
      [ -f /etc/init.d/zabbix_agentd ] && /etc/init.d/zabbix_agentd stop && echo "zabbix_agentd 旧服务停止成功"
      if [ -d "/usr/local/zabbix/" ]; then
          echo "备份旧的zabbix服务"
          mv /usr/local/zabbix/ /usr/local/zabbix_bak
      fi
  fi
}
 
#check zabbix user
check_zabbix_user(){
   res=`cat /etc/passwd|grep zabbix`
   if [ "$res" = "" ]; then
       echo "zabbix user 用户不存在"
       chattr -i /etc/passwd* && chattr -i /etc/group* && chattr -i /etc/shadow* && chattr -i /etc/gshadow*
       groupadd zabbix
       useradd -g zabbix zabbix -s /sbin/nologin
       chattr +i /etc/passwd* && chattr +i /etc/group* && chattr +i /etc/shadow* && chattr +i /etc/gshadow*
   else
       echo "zabbix user 用户已经存在"
   fi
}
 
#install_zabbix_agentd
install_zabbix_agentd(){
    cd /tmp/
    if [ -f "/tmp/zabbix_agentd_v2.2.20/zabbix_agentd.tar.gz" ];then
        echo "zabbix_agentd_v2.2.20.tar.gz 安装包已经存在"
    else
        echo "正在下载zabbix_agentd_v2.2.20.tar.gz 安装包...."
        wget -O /tmp/zabbix_agentd_v2.2.20.tar.gz http://www.down.net/zabbix_agentd_v2.2.20.tar.gz
    fi
    tar -xf /tmp/zabbix_agentd_v2.2.20.tar.gz
    if [ ! -d "/opt/zabbix" ]; then
        echo "zabbix 目录不存在"
        cp -rp /tmp/zabbix_agentd_v2.2.20/zabbix /opt/
        chown -R zabbix:zabbix /opt/zabbix
    else
        echo "zabbix 目录已经存在"
    fi
}
 
#start_zabbix_agentd
start_zabbix_agentd(){
    /opt/zabbix/init/zabbix-agent restart
    check=`ps -ef|grep zabbix_agentd`
    if [ "$check" = ""  ]; then
        echo "zabbix_agentd 服务未运行"
    else
        echo "zabbix_agentd 服务成功运行"
    fi
}
 
#crontab_zabbix_agentd
crontab_zabbix_agentd(){
   res=`crontab -l|grep zabbix`
   if [ "$res" = "" ]; then
       chattr -i /var/spool/cron/root
       echo "# zabbix_agentd" >> /var/spool/cron/root
       echo "* * * * * sh /opt/zabbix/zabbix_agent_check.sh > /dev/null 2>&1 &" >> /var/spool/cron/root
       chattr +i /var/spool/cron/root
   else
       echo "zabbix_agentd 定时任务已经存在"
   fi
}
 
main(){
   check_zabbix_agentd
   check_zabbix_user
   install_zabbix_agentd
   start_zabbix_agentd
   crontab_zabbix_agentd
}
 
main
```
