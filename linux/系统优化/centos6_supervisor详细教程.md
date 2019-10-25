# 一、安装
```
yum install -y epel-release supervisor

#完整配置
mkdir -p /etc/supervisord.d/

sudo tee /etc/supervisord.conf << 'EOF'
[supervisord]
http_port=/var/tmp/supervisor.sock ; (default is to run a UNIX domain socket server)
;http_port=127.0.0.1:9001  ; (alternately, ip_address:port specifies AF_INET)
;sockchmod=0700              ; AF_UNIX socketmode (AF_INET ignore, default 0700)
;sockchown=nobody.nogroup     ; AF_UNIX socket uid.gid owner (AF_INET ignores)
;umask=022                   ; (process file creation umask;default 022)
logfile=/var/log/supervisor/supervisord.log ; (main log file;default $CWD/supervisord.log)
logfile_maxbytes=50MB       ; (max main logfile bytes b4 rotation;default 50MB)
logfile_backups=10          ; (num of main logfile rotation backups;default 10)
loglevel=info               ; (logging level;default info; others: debug,warn)
pidfile=/var/run/supervisord.pid ; (supervisord pidfile;default supervisord.pid)
nodaemon=false              ; (start in foreground if true;default false)
minfds=1024                 ; (min. avail startup file descriptors;default 1024)
minprocs=200                ; (min. avail process descriptors;default 200)

;nocleanup=true              ; (don't clean up tempfiles at start;default false)
;http_username=user          ; (default is no username (open system))
;http_password=123           ; (default is no password (open system))
;childlogdir=/tmp            ; ('AUTO' child log dir, default $TEMP)
;user=chrism                 ; (default is current user, required if root)
;directory=/tmp              ; (default is not to cd during start)
;environment=KEY=value       ; (key value pairs to add to environment)

[supervisorctl]
serverurl=unix:///var/tmp/supervisor.sock ; use a unix:// URL  for a unix socket
;serverurl=http://127.0.0.1:9001 ; use an http:// url to specify an inet socket
;username=chris              ; should be same as http_username if set
;password=123                ; should be same as http_password if set
;prompt=mysupervisor         ; cmd line prompt (default "supervisor")

; The below sample program section shows all possible program subsection values,
; create one or more 'real' program: sections to be able to control them under
; supervisor.

;[program:theprogramname]
;command=/bin/cat            ; the program (relative uses PATH, can take args)
;priority=999                ; the relative start priority (default 999)
;autostart=true              ; start at supervisord start (default: true)
;autorestart=true            ; retstart at unexpected quit (default: true)
;startsecs=10                ; number of secs prog must stay running (def. 10)
;startretries=3              ; max # of serial start failures (default 3)
;exitcodes=0,2               ; 'expected' exit codes for process (default 0,2)
;stopsignal=QUIT             ; signal used to kill process (default TERM)
;stopwaitsecs=10             ; max num secs to wait before SIGKILL (default 10)
;user=chrism                 ; setuid to this UNIX account to run the program
;log_stdout=true             ; if true, log program stdout (default true)
;log_stderr=true             ; if true, log program stderr (def false)
;logfile=/var/log/cat.log    ; child log path, use NONE for none; default AUTO
;logfile_maxbytes=1MB        ; max # logfile bytes b4 rotation (default 50MB)
;logfile_backups=10          ; # of logfile backups (default 10)

[include]
files = /etc/supervisord.d/*.conf
EOF


/etc/init.d/supervisord reload
/etc/init.d/supervisord restart
/etc/init.d/supervisord status


ps -ef|grep supervisord          # 查看是否存在supervisord进程
```

# 二、配置supervisord开机启动

```
chkconfig supervisord on
chkconfig --list|grep supervisord

#supervisord     0:off   1:off   2:on    3:on    4:on    5:on    6:off
```

# 三、测试
```
修改
# vim /etc/supervisord.conf

[include]
files = /etc/supervisord.d/*.conf

新增测试配置
tee /etc/supervisord.d/hello.conf << 'EOF'
[program:hello]
directory=/root                      ; 运行程序时切换到指定目录
command=/bin/bash hello.sh           ; 执行程序 ( 程序不能时后台运行的方式 )
autostart=true                       ; 程序随 supervisord 启动而启动
startsecs=10                         ; 程序启动 10 后没有退出，认为程序启动成功 
redirect_stderr=true                 ; 标准错误输出重定向到标准输出
stdout_logfile=/tmp/hello.log      ; 指定日志文件路径，可以绝对路径 ( 相对路径 相对 directory= 指定的目录 )
stdout_logfile_maxbytes=50MB         ; 文件切割大小
stdout_logfile_backups=10            ; 保留的备份数
EOF


# 管理salt-master 
tee /etc/supervisord.d/salt-master.conf << 'EOF'
[program:salt-master]
command=/usr/bin/salt-master
autostart=true
autorestart=true
EOF

# 管理salt-minion
tee /etc/supervisord.d/salt-minion.conf << 'EOF'
[program:salt-minion]
command=/usr/bin/salt-minion
autostart=true
autorestart=true
EOF

#查看管理的服务
supervisorctl status

supervisorctl start salt-master
supervisorctl start salt-minion

systemctl stop salt-minion
systemctl daemon-reload
systemctl stop supervisord
systemctl restart supervisord
supervisorctl status
ps -ef|grep salt-minion
```

参考资料：

https://blog.csdn.net/DongGeGe214/article/details/80264811  
