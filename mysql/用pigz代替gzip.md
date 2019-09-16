# 一、安装
pigz简单的说，就是支持并行的gzip。废话不多说，开始测试。
```
#1、yum安装
yum -y install pigz

#2、编译安装
yum -y install zlib-devel
cd /usr/local/src/
wget http://zlib.net/pigz/pigz-2.4.tar.gz
tar zxvf pigz-2.4.tar.gz
cd pigz-2.4
make
cp pigz unpigz /usr/bin/
```

# 二、压缩
```
### 使用gzip进行压缩（单线程）
time tar -zcvf index.tar.gz hg19_index/

real    5m28.824s
user    5m3.866s
sys 0m35.314s

### 使用4线程的pigz进行压缩
time tar -cvf - hg19_index/ | pigz -p 4 > index_p4.tat.gz 


real    1m18.236s
user    5m22.578s
sys 0m35.933s

### 使用16线程的pigz进行压缩
time tar -cvf - hg19_index/ | pigz -p 16 > index_p16.tar.gz 

real    0m23.643s
user    6m24.054s
sys 0m24.923s
```

# 三、解压
```
### 解压文件
time pigz -p 8 -d index_p8.tar.gz 

real    0m27.717s
user    0m30.070s
sys 0m22.515s
```


参考文档：

https://www.jianshu.com/p/455ffef0a3c8  多线程压缩工具pigz使用
