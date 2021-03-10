```
3) 确保可用dns解析 

# grep hosts /etc/nsswitch.conf   -- 注意这个文件，不然会出现解析不了域名的现象
------------------------------------------------------------------- 
hosts:      files dns 
------------------------------------------------------------------- 

ping -c 3 www.baidu.com 
```
参考文档：

https://www.cnblogs.com/happyhotty/articles/2539951.html  解决linux ping: unknown host www.baidu.com

https://www.cloudflare.com/zh-cn/learning/dns/what-is-dns/  什么是 DNS？ | DNS 的工作方式

https://reaff.com/6109.html   使用Censys 查询CDN|如Cloudflare后面的真实服务器IP地址 与对应防范
