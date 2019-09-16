## 一、更新阿里云的yum源
```bash
#下载wget
yum install wget -y

#备份当前的yum源
mv /etc/yum.repos.d /etc/yum.repos.d_backup

#新建空的yum源设置目录
mkdir /etc/yum.repos.d

#centos7系统
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

#centos6系统
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS6-Base-163.repo
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
```
## 二、重建缓存
```bash
yum clean all
yum makecache
```

## 三、更新epel源
```bash
#通用
yum install epel-release -y

#centos7系统
wget https://mirrors.aliyun.com/repo/epel-7.repo
wget -O /etc/yum.repos.d/epel-7.repo https://mirrors.aliyun.com/repo/epel-7.repo

#centos6系统
wget -O /etc/yum.repos.d/epel-6.repo https://mirrors.aliyun.com/repo/epel-6.repo
```
