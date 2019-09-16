## ps、grep和kill联合使用杀掉进程

```
ps -ef |grep hello |awk '{print $2}'|xargs kill -9

这里是输出ps -ef |grep hello 结果的第二列的内容然后通过xargs传递给kill -9,其实第二列内容就是hello的进程号！
```


## exec
```
在删除之前可以打印出来看看：
find . -name .svn -type d -exec ls -l {} \;

find . -name .svn -type d -exec rm -rf {} \;

```
## xargs
```
find . -name .svn -type d | xargs rm -rf

find /data0/log -mtime +1 |grep -E "[0-9]{4}_[0-9]{1,2}_[0-9]{1,2}"|xargs rm -f
```
