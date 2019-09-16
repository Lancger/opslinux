```
cd /tmp/
wget http://repo.zabbix.com/zabbix/4.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_4.2-1%2Btrusty_all.deb
dpkg -i zabbix-release_4.2-1+trusty_all.deb
sudo apt-get update
sudo apt-get install zabbix-agent


cat > /etc/zabbix/zabbix_agentd.conf << \EOF
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix-agent/zabbix_agentd.log
LogFileSize=0
DebugLevel=2
Server=192.168.52.133
ServerActive=192.168.52.133
EnableRemoteCommands=1
UnsafeUserParameters=1
HostnameItem=system.run[echo $(hostname)]
HostMetadataItem=system.uname
Include=/etc/zabbix/zabbix_agentd.conf.d/*.conf
EOF

service zabbix-agent restart
```
