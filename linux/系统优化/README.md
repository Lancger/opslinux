# 一、系统初始化

```
cd /etc && wget -O /etc/history_conf https://raw.githubusercontent.com/Lancger/opslinux/master/linux/%E7%B3%BB%E7%BB%9F%E4%BC%98%E5%8C%96/history_conf

cd /tmp && wget -O /tmp/initialization.sh https://raw.githubusercontent.com/Lancger/opslinux/master/linux/%E7%B3%BB%E7%BB%9F%E4%BC%98%E5%8C%96/Centos_initialization.sh && chmod +x /tmp/initialization.sh && sh /tmp/initialization.sh

#tomcat日志切割工具
cd /tmp/
wget -O /tmp/cronolog-1.6.2.tar.gz https://raw.githubusercontent.com/Lancger/opslinux/master/linux/%E7%B3%BB%E7%BB%9F%E4%BC%98%E5%8C%96/cronolog-1.6.2.tar.gz
tar -zxvf /tmp/cronolog-1.6.2.tar.gz
cd cronolog-1.6.2
./configure
make && make install
which cronolog
```

# 二、验证日志审计切割

```
logrotate -vf /etc/logrotate.d/shell_audit 

tail -100f /var/log/shell_audit/audit.log 
```

# 三、磁盘挂载

```
cat > /tmp/disk.sh << \EOF
#!/bin/bash
echo "n
p
1


w
" | fdisk /dev/vdb && mkfs.ext4 /dev/vdb1
echo '/dev/vdb1 /data0                  ext4    defaults        0 0' >> /etc/fstab
mkdir /data0
mount /dev/vdb1 /data0
df -h
EOF

chmod +x /tmp/disk.sh && sh /tmp/disk.sh
mkdir -p /data0/{opt,logs}
ln -s /data0/logs/ /opt/logs
chown -R www:www /data0/
chown -R www:www /opt/logs
mv /home/ /data0/
ln -s /data0/home/ /home
ls -l /data0/
ls -l /opt/
ls -l /home/

#ln -s /data /data0  (前面为目标，后面为软链)
```

# 四、java环境

```
echo -e "\n139.180.210.37 download.devops.com" >> /etc/hosts
cat /etc/hosts|grep download.devops.com
cd /usr/local/src/
mkdir -p /opt/java
wget -N http://download.devops.com/jdk-8u211-linux-x64.tar.gz
tar -zxvf jdk-8u211-linux-x64.tar.gz
mv jdk1.8.0_211 /opt/java/
ls -l /opt/java/

vim /etc/profile
#在最后一行添加
#java environment
export JAVA_HOME=/opt/java/jdk1.8.0_211
export CLASSPATH=.:${JAVA_HOME}/jre/lib/rt.jar:${JAVA_HOME}/lib/dt.jar:${JAVA_HOME}/lib/tools.jar
export PATH=$PATH:${JAVA_HOME}/bin

source /etc/profile  #(生效环境变量)

java -version        #(检查安装 是否成功)
```

# 五、主机名修改
```
#修改主机名
hostnamectl set-hostname test-001

#安装salt-minion
yum install -y epel-release
yum install -y salt-minion

cat >/etc/hosts<<\EOF
127.0.0.1 localhost
139.180.210.37 download.devops.com
EOF

>/etc/salt/minion_id
rm -f /etc/salt/pki/minion/minion_master.pub
rm -f /etc/salt/pki/minion/minion_master.pem
sudo tee /etc/salt/minion << 'EOF'   # 默认使用主机名作为salt_minion_id
master: 192.168.56.11
EOF
sed -i 's/master.*/master: 139.180.210.37/g' /etc/salt/minion

systemctl enable salt-minion
systemctl restart salt-minion

#minion更换主机名重新认证
rm -rf /etc/salt/pki/
rm -rf /etc/salt/minion_id
systemctl restart salt-minion
cat /etc/salt/minion_id

#master端
salt-key -d test_minion
```

# 六、Ansible批量下发监控优化
```bash
ansible all -S -R root -m shell -a "cd /tmp/ && wget -N --no-check-certificate https://bootstrap.pypa.io/get-pip.py && python get-pip.py && pip install --upgrade pip --trusted-host mirrors.aliyun.com -i https://mirrors.aliyun.com/pypi/simple/ && pip install --upgrade setuptools==30.1.0 && pip install simplejson --trusted-host mirrors.aliyun.com -i https://mirrors.aliyun.com/pypi/simple/"


```

参考文档

https://jaminzhang.github.io/shell/Automated-Disk-Partion-Via-Shell-Script/  Shell 脚本自动化分区
