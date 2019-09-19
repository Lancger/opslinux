```
stop slave;
set global sql_slave_skip_counter =1;
start slave;
show slave status\G;
```



参考资料：

https://blog.csdn.net/hardworking0323/article/details/81046408
