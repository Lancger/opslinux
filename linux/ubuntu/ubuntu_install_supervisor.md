# 一、安装
```
sudo apt-get install supervisor -y
systemctl enable supervisor
systemctl restart supervisor

systemctl status supervisor
ps -ef|grep supervisor

#完整配置
sudo tee /etc/supervisor/supervisord.conf << 'EOF'
; supervisor config file

[unix_http_server]
file=/var/run/supervisor.sock   ; (the path to the socket file)
chmod=0700                       ; sockef file mode (default 0700)

[supervisord]
logfile=/var/log/supervisor/supervisord.log ; (main log file;default $CWD/supervisord.log)
pidfile=/var/run/supervisord.pid ; (supervisord pidfile;default supervisord.pid)
childlogdir=/var/log/supervisor            ; ('AUTO' child log dir, default $TEMP)

; the below section must remain in the config file for RPC
; (supervisorctl/web interface) to work, additional interfaces may be
; added by defining them in separate rpcinterface: sections
[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///var/run/supervisor.sock ; use a unix:// URL  for a unix socket

; The [include] section can just contain the "files" setting.  This
; setting can list multiple files (separated by whitespace or
; newlines).  It can also contain wildcards.  The filenames are
; interpreted as relative to this file.  Included files *cannot*
; include files themselves.

[include]
files = /etc/supervisor/conf.d/*.conf
EOF
```


# 二、配置supervisord开机启动

```
sudo tee /lib/systemd/system/supervisor.service << 'EOF'
[Unit]
Description=Supervisor process control system for UNIX
Documentation=http://supervisord.org
After=network.target

[Service]
ExecStart=/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
ExecStop=/usr/bin/supervisorctl $OPTIONS shutdown
ExecReload=/usr/bin/supervisorctl -c /etc/supervisor/supervisord.conf $OPTIONS reload
KillMode=process
Restart=on-failure
RestartSec=50s

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl restart supervisor
systemctl enable supervisor
systemctl is-enabled supervisor
systemctl status supervisor
```

# 三、测试
```
# 管理salt-master 
tee /etc/supervisor/conf.d/salt-master.conf << 'EOF'
[program:salt-master]
command=/usr/bin/salt-master
autostart=true
autorestart=true
EOF

# 管理salt-minion
tee /etc/supervisor/conf.d/salt-minion.conf << 'EOF'
[program:salt-minion]
command=/usr/bin/salt-minion
autostart=true
autorestart=true
EOF

#查看管理的服务
supervisorctl status

supervisorctl start salt-master

supervisorctl start salt-minion

```

参考资料：

https://www.jianshu.com/p/68605ac9d06a
