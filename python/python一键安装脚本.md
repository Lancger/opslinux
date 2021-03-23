```bash
#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to initialization OS."
    exit 1
fi

version="3.6.9"
name="Python"
pyfile="$name-$version.tgz"
check_ver=`echo $version|awk '{printf ("%3.1f\n",$1)}'`
dir="/usr/local/python3"

rpm=`rpm -qa libffi-devel|awk -F "-" '{print $1}'`
if [ -z $rpm ];then
 yum  -y install  wget gcc gcc-c++ make openssl-devel bzip2-devel libffi-devel
else
  echo -e "\033[40;31m libffi [found]\033[40;37m"
fi

if [ -e $dir ];then
 rm -fr /usr/local/python3
 rm -rf /usr/bin/python3
 rm -rf /usr/bin/pip3
else
 echo -e "\033[40;31m python [no found]\033[40;37m"
fi

if [ -s $pyfile ];then
 echo -e "\033[40;31m $pyfile [found]\033[40;37m"
else
 #wget https://www.python.org/ftp/python/$version/$pyfile
 #tar zxf $pyfile
 #使用淘宝源加速下载
 wget https://npm.taobao.org/mirrors/python/$version/$pyfile
 tar zxf $pyfile
fi

yum group install -y "Development Tools"
cd $name-$version
./configure --prefix=/usr/local/python3 --enable-optimizations
make altinstall

if [ "$check_ver" = "3.6" ];then
 ln -s /usr/local/python3/bin/python3.6 /usr/bin/python3
 ln -s /usr/local/python3/bin/pip3.6 /usr/bin/pip3
elif [ "$check_ver" = "3.7" ];then
 ln -s /usr/local/python3/bin/python3.7 /usr/bin/python3
 ln -s /usr/local/python3/bin/pip3.7 /usr/bin/pip3
elif [ "$check_ver" = "3.8" ];then
 ln -s /usr/local/python3/bin/python3.8 /usr/bin/python3
 ln -s /usr/local/python3/bin/pip3.8 /usr/bin/pip3
fi

if [ -d /root/.pip ];then
 echo -e "\033[40;31m file is [found]\033[40;37m"
else
 mkdir ~/.pip

cat > ~/.pip/pip.conf <<EOF
[global]
index-url = https://pypi.doubanio.com/simple/
[install]
trusted-host=pypi.doubanio.com
disable-pip-version-check = true
timeout = 6000
EOF
fi

pip3 install --upgrade pip

echo -e "\nInstalled Python and pip version is ... "
python3 -V && pip3 -V

echo -e "\033[32m \nInstall Successfully! \033[0m"
```
