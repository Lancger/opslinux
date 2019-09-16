## 一、结构图

    #测试服务器环境均为Centos7，测试结构如下图：

  ![MHA测试架构](https://github.com/Lancger/opslinux/blob/master/images/MHA测试架构.png)
  
    其中master对外提供写服务，备选master-bak提供读服务，slave也提供相关的读服务，一旦master宕机，将会把备选master-bak提升为新的master，slave指向新的master
  
```
mysql-master：      192.168.56.10            ------> mha_node1 

mysql-master-bak：  192.168.56.20            ------> mha_node2

mysql-slave：       192.168.56.30            ------> mha_manager
```

## 二、环境初始化

    三台机器安装mysql5.6，并配置好主从

```
1、关闭防火墙以及selinx
systemctl disable firewalld 
systemctl disable NetworkManager

sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

setenforce 0 

2、集群主机时间同步
yum install -y wget lrzsz vim net-tools openssh-clients ntpdate unzip xz telnet

#加入crontab
1 * * * * /usr/sbin/ntpdate ntp1.aliyun.com >/dev/null 2>&1

#设置时区
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

3、更改主机名，添加hosts文件
hostnamectl set-hostname mha_node1
hostnamectl set-hostname mha_node2
hostnamectl set-hostname mha_manager

cat > /etc/hosts <<EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.56.10 mha_node1   mha_node1.example.com
192.168.56.20 mha_node2   mha_node1.example.com
192.168.56.30 mha_manager mha_manager.example.com
EOF

4、配置密钥ssh(所有主机各配置相同操作)
ssh-keygen -t rsa 

在所有主机都必须拷贝密钥于其他主机
for i in mha_node1 mha_node2 mha_manager; do ssh-copy-id $i; done

测试登录
for i in mha_node1 mha_node2 mha_manager; do ssh $i; done

```

## 三、环境初始化
```
1、安装epel源
yum install -y epel-release

wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh epel-release-latest-7.noarch.rpm

2、安装依赖包
yum clean all
yum -y install perl-DBD-MySQL perl-Config-Tiny perl-Log-Dispatch perl-Parallel-ForkManager perl-Config-IniFiles ncftp perl-Params-Validate perl-CPAN perl-Test-Mock-LWP.noarch perl-LWP-Authen-Negotiate.noarch perl-devel perl-ExtUtils-CBuilder perl-ExtUtils-MakeMaker

3、数据库授权
mysql> GRANT ALL PRIVILEGES ON *.* TO root@"192.168.56.%" IDENTIFIED BY "123456";
mysql> GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' IDENTIFIED BY 'repl';
mysql> flush privileges;
mysql> exit
````

## 四、Node节点(node需要先安装)

    1、在三个节点上都装mha的node软件
```
wget https://qiniu.wsfnk.com/mha4mysql-node-0.58-0.el7.centos.noarch.rpm
#wget https://github.com/yoshinorim/mha4mysql-node/releases/download/v0.58/mha4mysql-node-0.58-0.el7.centos.noarch.rpm

#安装	
#rpm -ivh mha4mysql-node-0.58-0.el7.centos.noarch.rpm
yum install mha4mysql-node-0.58-0.el7.centos.noarch.rpm

#卸载
rpm -e mha4mysql-manager-0.58-0.el7.centos.noarch.rpm

```

## 五、Master节点
    1、仅在manager节点上安装mha管理软件
```
wget https://qiniu.wsfnk.com/mha4mysql-manager-0.58-0.el7.centos.noarch.rpm
#wget https://github.com/yoshinorim/mha4mysql-manager/releases/download/v0.58/mha4mysql-manager-0.58-0.el7.centos.noarch.rpm

#安装
#rpm -ivh mha4mysql-manager-0.58-0.el7.centos.noarch.rpm
yum install mha4mysql-manager-0.58-0.el7.centos.noarch.rpm

#卸载
rpm -e mha4mysql-manager-0.58-0.el7.centos.noarch.rpm

```
    2、配置MHA（在manager节点上操作）
```
#创建目录
mkdir -p /etc/mha/{app1,scripts}

#配置全局配置文件/etc/masterha_default.cn #一定要是这个路径,不然后期masterha_check_ssh会提示未找到全局文件
cat > /etc/masterha_default.cnf <<EOF
[server default]
user=root
password=123456
ssh_user=root
repl_user=repl_user
repl_password=123456
ping_interval=3
ping_type=insert
#master_binlog_dir= /var/lib/mysql,/var/log/mysql
secondary_check_script=masterha_secondary_check -s 192.168.56.10 -s 192.168.56.20 -s 192.168.56.30 
master_ip_failover_script="/etc/mha/scripts/master_ip_failover"
master_ip_online_change_script="/etc/mha/scripts/master_ip_online_change"
report_script="/etc/mha/scripts/send_report"
EOF

参数介绍：
ping_interval：这个参数表示mha manager多久ping（执行select ping sql语句）一次master，连续三个丢失ping连接，mha master就判定mater死了，因此，通过4次ping间隔的最大时间的机制来发现故障，默认是3，表示间隔是3秒

ping_type:   从0.53版本开始支持，默认情况下，mha master基于一个到master的已经存在的连接执行select 1(ping_type=select)语句来检查master的可用性，但是在有些场景下，最好是每次通过新建/断开连接的方式来检测，因为这能够更严格以及更快速地发现TCP连接级别的故障，把ping_type设置为connect就可以实现。从0.56开始新增了ping_type=INSERT类型。

#配置主配置文件
cat > /etc/mha/app1.cnf <<EOF
[server default]
manager_workdir=/etc/mha/app1
manager_log=/etc/mha/app1/manager.log

[server1]
hostname=192.168.56.10
candidate_master=1
master_binlog_dir="/var/lib/mysql"
#查看方式　find / -name mysql-bin*

[server2]
hostname=192.168.56.20
candidate_master=1
master_binlog_dir="/var/lib/mysql"

[server3]
hostname=192.168.56.30
master_binlog_dir="/var/lib/mysql"
#表示没有机会成为master
no_master=1
EOF

#配置VIP
#为了防止脑裂发生,推荐生产环境采用脚本的方式来管理虚拟 ip,而不是使用 keepalived来完成。

#添加master_ip_failover脚本，实现failover时自动切换vip
cat >/etc/mha/scripts/master_ip_failover <<EOF
#!/usr/bin/env perl
use strict;
use warnings FATAL => 'all';

use Getopt::Long;
use MHA::DBHelper;


my (
    $command,          $ssh_user,        $orig_master_host, $orig_master_ip,
    $orig_master_port, $new_master_host, $new_master_ip,    $new_master_port
);

#定义VIP变量
my $vip = '192.168.56.200/24';
my $key = '1';
my $ssh_start_vip = "/sbin/ifconfig eth0:$key $vip";
my $ssh_stop_vip = "/sbin/ifconfig eth0:$key down";

GetOptions(
	'command=s'		=> \$command,
	'ssh_user=s'		=> \$ssh_user,
	'orig_master_host=s'	=> \$orig_master_host,
	'orig_master_ip=s'	=> \$orig_master_ip,
	'orig_master_port=i'	=> \$orig_master_port,
	'new_master_host=s'	=> \$new_master_host,
	'new_master_ip=s'	=> \$new_master_ip,
	'new_master_port=i'	=> \$new_master_port,
);

exit &main();

sub main {
	print "\n\nIN SCRIPT TEST====$ssh_stop_vip==$ssh_start_vip===\n\n";
	if ( $command eq "stop" || $command eq "stopssh" ) {
		my $exit_code = 1;
		eval {
			print "Disabling the VIP on old master: $orig_master_host \n";
			&stop_vip();
			$exit_code = 0;
		};
		if ($@) {
			warn "Got Error: $@\n";
			exit $exit_code;
		}
		exit $exit_code;
	}

	elsif ( $command eq "start" ) {
	my $exit_code = 10;
	eval {
		print "Enabling the VIP - $vip on the new master - $new_master_host \n";
		&start_vip();
		$exit_code = 0;
	};

	if ($@) {
		warn $@;
		exit $exit_code;
		}
	exit $exit_code;
	}

	elsif ( $command eq "status" ) {
		print "Checking the Status of the script.. OK \n";
		exit 0;
	}
	else {
		&usage();
		exit 1;
	}
}

sub start_vip() {
	`ssh $ssh_user\@$new_master_host \" $ssh_start_vip \"`;
}
sub stop_vip() {
	return 0 unless ($ssh_user);
	`ssh $ssh_user\@$orig_master_host \" $ssh_stop_vip \"`;
}
sub usage {
	print
	"Usage: master_ip_failover --command=start|stop|stopssh|status --orig_master_host=host --orig_master_ip=ip --orig_master_port=port --new_master_host=host --new_master_ip=ip --new_master_port=port\n";
}
EOF

#配置报警邮件脚本

```
    
 


### 六、查看软件包的安装位置

```
#查看包的安装位置
root># rpm -qa|grep mha
mha4mysql-node-0.58-0.el7.centos.noarch
mha4mysql-manager-0.58-0.el7.centos.noarch

root># rpm -ql mha4mysql-manager-0.58-0.el7.centos.noarch
/usr/bin/masterha_check_repl
/usr/bin/masterha_check_ssh
/usr/bin/masterha_check_status
/usr/bin/masterha_conf_host

root># rpm -ql mha4mysql-node-0.58-0.el7.centos.noarch
/usr/bin/apply_diff_relay_logs
/usr/bin/filter_mysqlbinlog
/usr/bin/purge_relay_logs

#卸载
yum remove -y mha4mysql-manager-0.58-0.el7.centos.noarch
yum remove -y mha4mysql-node-0.58-0.el7.centos.noarch
```

### 七、切换步骤记录
```
mysql -uroot -p -h127.0.0.1 -P3306 < /tmp/all.sql

GRANT REPLICATION SLAVE ON *.* TO 'repl'@'192.168.56.%' IDENTIFIED BY 'repl';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' IDENTIFIED BY 'repl';

FLUSH TABLES WITH READ LOCK;
mysql> SHOW MASTER STATUS;
+------------------+----------+--------------+--------------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB         | Executed_Gtid_Set |
+------------------+----------+--------------+--------------------------+-------------------+
| mysql-bin.000019 |      154 |              | mysql,information_schema |                   |
+------------------+----------+--------------+--------------------------+-------------------+
1 row in set (0.00 sec)


show grants for repl@"%";

mysqldump -uroot -p -h127.0.0.1 -P3306 --all-databases --triggers --routines --events >/tmp/all.sql

scp /tmp/all.sql 192.168.56.20:/tmp/

scp /tmp/all.sql 192.168.56.30:/tmp/


systemctl restart mysqld

tail -100f /var/log/mysqld.log

mysql -uroot -p123456
stop slave;
reset slave;
CHANGE MASTER TO MASTER_HOST='192.168.56.10',MASTER_USER='repl',MASTER_PASSWORD='repl',MASTER_LOG_FILE='mysql-bin.000019',MASTER_LOG_POS=154,MASTER_CONNECT_RETRY=5;
start slave;
exit


mysql -uroot -p123456 -e "show slave hosts;"


rm -rf /etc/masterha

scp -rp /etc/masterha 192.168.56.10:/etc/
scp -rp /etc/masterha 192.168.56.20:/etc/


mysql -uroot -p123456 -e "show grants for repl@'%';"

masterha_check_ssh --conf=/etc/masterha/vip_app_default.cnf

masterha_check_repl --conf=/etc/masterha/vip_app_default.cnf

masterha_check_status --conf=/etc/masterha/vip_app_default.cnf

#手动切换
masterha_master_switch --master_state=alive --conf=/etc/masterha/vip_app_default.cnf --orig_master_is_new_slave

tail -100f /var/log/mysqld.log
```

参看文档： https://boke.wsfnk.com/archives/537.html
