 Linux命令行上传文件到百度网盘 
 
 ```
 最近在学习 MySQL 的 bin-log 时候考虑到数据备份的问题，突然想到如果能将数据通过 Linux 命令行方式备份到百度网盘，那是一件多么牛逼的事情。百度网盘有免费的 2TB 存储空间，而且有百度做靠山，不怕数据丢失，安全可靠。说干就干，通过百度 and 谷歌找到了几种方式，比较喜欢 bypy 的方式，使用简单，方便。下边简单的总结一下如何使用 bypy 实现百度网盘数据的同步。

这是一个百度云的 Python 客户端，其主要目的和功能，就是为 Linux 使用者提供一种在命令行下，使用百度云盘中2T存储空间的方法。它提供文件列表、下载、上传、比较、向上同步、向下同步，等操作。

系统环境：

Linux 系统 + Python 2.7

安装软件工具：

pip install requests
pip install bypy

授权登陆：

执行 bypy info，显示下边信息，根据提示，通过浏览器访问下边灰色的https链接，如果此时百度网盘账号正在登陆，会出现长串授权码，复制。
复制代码
复制代码

[root@ineedle ~]# bypy info
Please visit:   # 访问下边这个连接，复制授权码
https://openapi.baidu.com/oauth/2.0/authorize?scope=basic+netdisk&redirect_uri=oob&response_type=code&client_id=q8WE4EpCsau1oS0MplgMKNBn
And authorize this app
Paste the Authorization Code here within 10 minutes.
Press [Enter] when you are done    # 提示在下边粘贴授权码

复制代码
复制代码

在下边图示红色位置粘贴授权码，耐心等待一会即可(1-2分钟)
复制代码
复制代码

Press [Enter] when you are done
a288f3d775fa905a6911692a0808f6a8
Authorizing, please be patient, it may take upto None seconds...
Authorizing/refreshing with the OpenShift server ...
OpenShift server failed, authorizing/refreshing with the Heroku server ...
Successfully authorized
Quota: 2.015TB
Used: 740.493GB

复制代码
复制代码

授权成功。

 

测试上传和同步本地文件到云盘

由于百度PCS API权限限制，程序只能存取百度云端/apps/bypy目录下面的文件和目录。我们可以通过：

[root@ineedle ~]# bypy list
/apps/bypy ($t $f $s $m $d):

把本地当前目录下的文件同步到百度云盘：

# bypy upload

把云盘上的内容同步到本地:

# bypy downdir

比较本地当前目录和云盘根目录，看是否一致，来判断是否同步成功：

# bypy compare


```

参考文档：

https://www.cnblogs.com/chenliyang/p/6634673.html
