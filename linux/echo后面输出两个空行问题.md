# 为什么`echo -e "\n"`命令只有一个换行符却会输出两行空行？

```
root@localhost:~# echo -e "\n"


root@localhost:~# 

```

因为echo命令本身默认会在输出字符串后面追加一个换行符，可以通过增加一个选项-n来阻止此默认行为：
```
echo -ne "\n"
```

参考资料：


https://segmentfault.com/q/1010000009696097
