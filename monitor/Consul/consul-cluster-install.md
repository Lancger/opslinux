# 一、consul-a-install.sh

```
yum install -y epel-release
yum install -y bind-utils unzip jq
cd /usr/local/src/
wget https://releases.hashicorp.com/consul/1.4.4/consul_1.4.4_linux_amd64.zip
unzip consul_1.4.4_linux_amd64.zip
mv consul /usr/local/bin/
chattr -i /etc/passwd* && chattr -i /etc/group* && chattr -i /etc/shadow*
adduser consul -s /sbin/nologin
mkdir /etc/consul.d
chown -R consul:consul /etc/consul.d/
mkdir /var/consul
chown -R consul:consul /var/consul

# consul keygen # generate encryption key that will be used ad the "encrypt" entry of ALL CONSUL NODES---这里生产秘钥
# t7GKGbWdWOvyLA2kPaLVwQ==

# creeate bootstrap consul configuration   --- -bootstrap一般只在集群初始化时使用一次。
sudo tee /etc/consul.d/consul.json << 'EOF'
{
    "bootstrap": true,
    "server": true,
    "datacenter": "dc1",
    "data_dir": "/var/consul",
    "encrypt": "t7GKGbWdWOvyLA2kPaLVwQ=="
}
EOF

sudo tee /etc/systemd/system/consul.service << 'EOF'
[Unit]
Description=Consul service discovery agent
Requires=network-online.target
After=network.target

[Service]
User=consul
Group=consul
PIDFile=/run/consul.pid
Restart=on-failure
Environment=GOMAXPROCS=2
ExecStart=/usr/local/bin/consul agent $OPTIONS -config-dir=/etc/consul.d -node-id=$(uuidgen | awk '{print tolower($0)}')
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGINT
TimeoutStopSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl restart consul.service
systemctl status consul.service
systemctl enable consul.service

# create configuration used after bootstrapping. The assumption is that
# the IP addres of this server is 192.168.56.11 and the
# other consul nodes are 192.168.56.12 & 192.168.56.13
sudo tee /etc/consul.d/consul.json << 'EOF'
{
  "node_name": "consul-a",
  "bootstrap": false,
  "data_dir": "/var/consul",
  "server": true,
  "bind_addr": "192.168.56.11",
  "bootstrap_expect": 3,
  "ui": true,
  "client_addr": "0.0.0.0",
  "encrypt": "t7GKGbWdWOvyLA2kPaLVwQ==",
  "start_join": ["192.168.56.12","192.168.56.13"]
}
EOF
```

# 二、consul-b-install.sh

```
yum install -y epel-release
yum install -y bind-utils unzip jq
cd /usr/local/src/
wget https://releases.hashicorp.com/consul/1.4.4/consul_1.4.4_linux_amd64.zip
unzip consul_1.4.4_linux_amd64.zip
mv consul /usr/local/bin/
chattr -i /etc/passwd* && chattr -i /etc/group* && chattr -i /etc/shadow*
adduser consul -s /sbin/nologin
mkdir /etc/consul.d
chown -R consul:consul /etc/consul.d/
mkdir /var/consul
chown -R consul:consul /var/consul

# The assumption is that the IP addres of this server is 192.168.56.12
# and the other consul servers are 192.168.56.11 & 192.168.56.13
sudo tee /etc/consul.d/consul.json << 'EOF'
{
  "node_name": "consul-b",
  "bootstrap": false,
  "data_dir": "/var/consul",
  "server": true,
  "bind_addr": "192.168.56.12",
  "bootstrap_expect": 3,
  "ui": false,
  "client_addr": "0.0.0.0",
  "encrypt": "t7GKGbWdWOvyLA2kPaLVwQ==",
  "start_join": ["192.168.56.11","192.168.56.13"]
}
EOF

sudo tee /etc/systemd/system/consul.service << 'EOF'
[Unit]
Description=Consul service discovery agent
Requires=network-online.target
After=network.target

[Service]
User=consul
Group=consul
PIDFile=/run/consul.pid
Restart=on-failure
Environment=GOMAXPROCS=2
ExecStart=/usr/local/bin/consul agent $OPTIONS -config-dir=/etc/consul.d -node-id=$(uuidgen | awk '{print tolower($0)}')
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGINT
TimeoutStopSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl restart consul.service
systemctl status consul.service
systemctl enable consul.service
```

# 三、consul-c-install.sh

```
yum install -y epel-release
yum install -y bind-utils unzip jq
cd /usr/local/src/
wget https://releases.hashicorp.com/consul/1.4.4/consul_1.4.4_linux_amd64.zip
unzip consul_1.4.4_linux_amd64.zip
mv consul /usr/local/bin/
chattr -i /etc/passwd* && chattr -i /etc/group* && chattr -i /etc/shadow*
adduser consul -s /sbin/nologin
mkdir /etc/consul.d
chown -R consul:consul /etc/consul.d/
mkdir /var/consul
chown -R consul:consul /var/consul

# The assumption is that the IP addres of this server is 192.168.56.13
# and the other consul servers are 192.168.56.11 & 192.168.56.12
sudo tee /etc/consul.d/consul.json << 'EOF'
{
  "node_name": "consul-b",
  "bootstrap": false,
  "data_dir": "/var/consul",
  "server": true,
  "bind_addr": "192.168.56.13",
  "bootstrap_expect": 3,
  "ui": false,
  "client_addr": "0.0.0.0",
  "encrypt": "t7GKGbWdWOvyLA2kPaLVwQ==",
  "start_join": ["192.168.56.11","192.168.56.12"]
}
EOF

sudo tee /etc/systemd/system/consul.service << 'EOF'
[Unit]
Description=Consul service discovery agent
Requires=network-online.target
After=network.target

[Service]
User=consul
Group=consul
PIDFile=/run/consul.pid
Restart=on-failure
Environment=GOMAXPROCS=2
ExecStart=/usr/local/bin/consul agent $OPTIONS -config-dir=/etc/consul.d -node-id=$(uuidgen | awk '{print tolower($0)}')
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGINT
TimeoutStopSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl restart consul.service
systemctl status consul.service
systemctl enable consul.service
```


参考文档：

https://gist.github.com/sdorsett/5cf05bb5e02f1e4a20224bae62b375ea

https://blog.csdn.net/qq_38659629/article/details/82804449  Consul 踩坑日记，节点id冲突

https://computingforgeeks.com/how-to-setup-consul-cluster-on-centos-rhel/
