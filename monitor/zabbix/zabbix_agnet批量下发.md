# 一、salt分组配置
```
[root@ip-172-31-30-95 /etc/salt]# cat master
 nodegroups:
   centos7-1rd: 'L@test-two-05,test-two-06,test-two-07,test-two-08,test-two-09,test-two-10'
   ubuntu-1rd: 'L@test-two-01,test-two-02,test-two-03,test-two-04'
   centos7-2rd: 'L@cgs001,cgs002,cgs003,cgs004,cgs005'
   ubuntu-2rd: 'L@cgs005,cgs006'
   centos7-3rd: 'L@test-two-com-3rd-01,test-two-com-3rd-02,test-two-com-3rd-03,test-two-com-3rd-04,test-two-com-3rd-05,test-two-com-3rd-06'
   centos-all: 'G@os:Centos'
   ubuntu-all: 'G@os:Ubuntu'
 file_recv: True
 file_recv_max_size: 100000
 file_roots:
   base:
     - /srv/salt/
 pillar_roots:
  base:
    - /srv/pillar
    
    
#salt分组测试
salt -N centos-all test.ping

salt -N ubuntu-all test.ping

salt -N centos7-1rd test.ping

salt -N ubuntu-1rd test.ping

salt "*" cmd.run "chmod +s /bin/netstat"
salt "*" cmd.run "chmod 644 /etc/sysconfig/iptables"

```
# 二、zabbix_agent安装包和脚本批量下发
```
cd /tmp
wget https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm
yum -y install zabbix-release-4.0-1.el7.noarch.rpm
yum -y install zabbix-agent

第一套（Centos7）（注意zabbix_server在test-two-10机器）
cd /srv/salt/
salt -E "test-two-0[5-9]" cmd.run "systemctl stop zabbix-agent"
salt -E "test-two-0[5-9]" cmd.run "cp -rf /etc/zabbix/ /tmp/zabbix_bak"
salt -E "test-two-0[5-9]" cmd.run "rm -rf /etc/zabbix/"
salt-cp -E "test-two-0[5-9]" zabbix_agent_v4.0.tar.gz /tmp/
salt -E "test-two-0[5-9]" cmd.run "tar -zxvf /tmp/zabbix_agent_v4.0.tar.gz -C /etc/"
salt -E "test-two-0[5-9]" cmd.run "systemctl restart zabbix-agent"


第二套（Centos7）
cd /srv/salt/
salt -N centos7-2rd cmd.run "systemctl stop zabbix-agent"
salt -N centos7-2rd cmd.run "cp -rf /etc/zabbix/ /tmp/zabbix_bak"
salt -N centos7-2rd cmd.run "rm -rf /etc/zabbix/"
salt-cp -N centos7-2rd zabbix_agent_v4.0.tar.gz /tmp/
salt -N centos7-2rd cmd.run "tar -zxvf /tmp/zabbix_agent_v4.0.tar.gz -C /etc/"
salt -N centos7-2rd cmd.run "systemctl restart zabbix-agent"


第三套（Centos7）
cd /srv/salt/
salt "test-two-com-3rd-0*" cmd.run "systemctl stop zabbix-agent"
salt "test-two-com-3rd-0*" cmd.run "rm -rf /etc/zabbix/"
salt-cp "test-two-com-3rd-0*" zabbix_agent_v4.0.tar.gz /tmp/
salt "test-two-com-3rd-0*" cmd.run "tar -zxvf /tmp/zabbix_agent_v4.0.tar.gz -C /etc/"
salt "test-two-com-3rd-0*" cmd.run "systemctl restart zabbix-agent"


Ubunut系统下发
cd /srv/salt/
salt -N ubuntu-all cmd.run "systemctl stop zabbix-agent"
salt -N ubuntu-all cmd.run "cp -rf /etc/zabbix/ /tmp/zabbix_bak"
salt -N ubuntu-all cmd.run "rm -rf /etc/zabbix/"
salt-cp -N ubuntu-all zabbix_agent_ubuntu_v4.0.tar.gz /tmp/
salt -N ubuntu-all cmd.run "tar -zxvf /tmp/zabbix_agent_ubuntu_v4.0.tar.gz -C /etc/"
salt -N ubuntu-all cmd.run "systemctl restart zabbix-agent"
```

# 三、zabbix_agent安装包和脚本单台主机下发

```
cd /srv/salt/
salt "cgs006" cmd.run "systemctl stop zabbix-agent"
salt "cgs006" cmd.run "rm -rf /etc/zabbix/"
salt-cp "cgs006" zabbix_agent_v4.0.tar.gz /tmp/
salt "cgs006" cmd.run "tar -zxvf /tmp/zabbix_agent_v4.0.tar.gz -C /etc/"
salt "cgs006" cmd.run "systemctl restart zabbix-agent"
```

# 四、批量重启
```
salt "*" cmd.run "systemctl restart zabbix-agent"

```

参考资料

https://www.cnblogs.com/snailshadow/p/8214294.html 
