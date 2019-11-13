```
3) 确保可用dns解析 

# grep hosts /etc/nsswitch.conf   -- 注意这个文件，不然会出现解析不了域名的现象
------------------------------------------------------------------- 
hosts:      files dns 
------------------------------------------------------------------- 

ping -c 3 www.baidu.com 
```
参考文档：

https://www.cnblogs.com/happyhotty/articles/2539951.html  
