    yum install mysql-devel
    yum install mysql-python
    
    
    wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py
    python get-pip.py

    pip install -i https://pypi.douban.com/simple/ mysql-python

    #删库
    mysql -uroot -p1Qaz2Wsx3Edc -e 'drop database sa;'

    #建库
    mysql -uroot -p1Qaz2Wsx3Edc -e 'create database sa;'


    #建表
    use sa;
    create table password (ip varchar(15) primary key not null, muser varchar(15), mpass varchar(30));

    #删记录
    mysql -uroot -p1Qaz2Wsx3Edc -e 'delete from sa.password where ip="120.79.210.87";'

    #测试
    root># python one_jump.py 120.79.210.87


    Tempzgb@

### 参考文档：

https://blog.csdn.net/u012974916/article/details/53316976
