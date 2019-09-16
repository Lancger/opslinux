 ## 一、安装pip
    
    wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py
    python get-pip.py

    pip install --trusted-host mirrors.aliyun.com -i https://mirrors.aliyun.com/pypi/simple/  -r requirements.txt

    pip install -i https://pypi.mirrors.ustc.edu.cn/simple/  -r requirements.txt       可用的

    pip install -i https://pypi.douban.com/simple/  -r requirements.txt       可用的

    遇到SSL错误可使用下面方式
    pip install -r requirements.txt -i http://pypi.douban.com/simple --trusted-host pypi.douban.com 
    
    
    ##pip版本升级
    pip install --upgrade pip


##  二、安装mysql-python

    yum install -y python-devel mysql-devel gcc

    pip install MySQL-python --trusted-host mirrors.aliyun.com -i https://mirrors.aliyun.com/pypi/simple/ 
    
    
## 三、centos6.5安装pip

报错 _blocking_errnos = {errno.EAGAIN, errno.EWOULDBLOCK} pip

```
wget -O /tmp/get-pip.py https://raw.githubusercontent.com/pypa/get-pip/master/2.6/get-pip.py

python2.6 /tmp/get-pip.py -i https://pypi.mirrors.ustc.edu.cn/simple/

https://www.qingtingip.com/h_114834.html
```
