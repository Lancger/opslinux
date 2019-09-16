# 一、未修改之前(忘记登录密码)
```
[root@abcdocker ~]# mysql -uroot -p -e "select * from zabbix.users\G"
Enter password: 
*************************** 1. row ***************************
            userid: 1
             alias: Admin
              name: Zabbix
           surname: Administrator
            passwd: ab66b6e18854fa4d45499d0a04a47b64
               url: 
         autologin: 1
        autologout: 0
              lang: en_GB
           refresh: 30
              type: 3
             theme: default
    attempt_failed: 0
        attempt_ip: 14.130.112.2
     attempt_clock: 1501141026
     rows_per_page: 50

```

# 二、修改登录密码
```
[root@abcdocker ~]# mysql -uroot -p
由于密码是md5加密的，我们可以查看默认的zabbix密码的md5
mysql> use zabbix;
mysql> update users set passwd='5fce1b3e34b520afeffb37ce08c7cd66' where userid='1';
Query OK, 1 row affected (0.01 sec)
Rows matched: 1  Changed: 1  Warnings: 0
解释：5fce1b3e34b520afeffb37ce08c7cd66  = zabbix
因为zabbix默认密码就是zabbix
```


参考资料：

https://www.centos.bz/2017/08/zabbix-forget-password-reset/  ZABBIX忘记登录密码重置方法

https://www.cnblogs.com/sky-k/p/9367186.html  Zabbix编译安装(全)
