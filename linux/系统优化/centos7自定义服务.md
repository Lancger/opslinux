```
vim /usr/lib/systemd/system/zdy.service
 
[Unit]
Description=描述
Environment=环境变量或参数(系统环境变量此时无法使用)
After=network.target
 
[Service]
Type=forking
EnvironmentFile=所需环境变量文件或参数文件
ExecStart=启动命令(需指定全路径)
ExecStop=停止命令(需指定全路径)
User=以什么用户执行命令
 
[Install]
WantedBy=multi-user.target
```

```
# 添加或修改配置文件后，需要重新加载
systemctl daemon-reload
 
# 设置自启动，实质就是在 /etc/systemd/system/multi-user.target.wants/ 添加服务文件的链接
systemctl enable zdy
```
参考文档：

https://blog.csdn.net/z1026544682/article/details/93473876  Systemd 添加自定义服务(开机自启动)
