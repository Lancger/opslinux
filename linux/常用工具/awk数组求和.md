```
#原始文件
(demo1) ➜  ~ cat 1.txt
3.091GB 36090784 i-9jc054
3.120GB 31420142 i-net96r
3.121GB 14576889 i-nvvj5m
3.156GB 37482709 i-9jc054


(demo1) ➜  ~ cat 1.txt | awk '{S[$3]+=$2}END{for(a in S)print a,S[a]}'
i-nvvj5m 14576889
i-net96r 31420142
i-9jc054 73573493
```
参考资料：

https://blog.51cto.com/quguanhai/1811271  awk 用数组实现分组统计求和
