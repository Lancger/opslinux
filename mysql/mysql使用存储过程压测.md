```
#创建数据表的结构
create table test_while (id int primary key) charset = utf8;


#查看数据表的结构
desc test_while;

#清理表数据
truncate table test_while;

#创建存储过程
delimiter #
create procedure test_sed1()
begin
    declare i int default 0;
    while i < 10000000 do
        insert into test_while(id) values(i);
        set i = i + 1;
    end while;
end #

delimiter ;
call test_sed1();
```

参考文档：

https://www.cnblogs.com/shootercheng/p/6103812.html
