# 一、ssh代理连接
```
老规矩，先说结论：

ssh -o ProxyCommand="nc -X 5 -x proxy.net:1080 %h %p" user@server.net
```


参考资料：
 
https://www.jianshu.com/p/f6990f3a52eb
