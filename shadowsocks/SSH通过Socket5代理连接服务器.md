# 一、ssh代理连接
```
老规矩，先说结论：

ssh -o ProxyCommand="nc -X 5 -x proxy.net:1080 %h %p" user@server.net

ssh -o ProxyCommand="nc -X 5 -x localhost:1081 %h %p" root@13.106.208.193 -p 22
```


参考资料：
 
https://www.jianshu.com/p/f6990f3a52eb
