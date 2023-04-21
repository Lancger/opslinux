## 一、手册
- [Mysql手册](https://github.com/Lancger/opslinux/blob/master/mysql/README.md)
- [Linux手册](https://github.com/Lancger/opslinux/blob/master/linux/README.md)
- [Python手册](https://github.com/Lancger/opslinux/blob/master/python/README.md)
- [Node手册](https://github.com/Lancger/opslinux/blob/master/node/README.md)
- [Git手册](https://github.com/Lancger/opslinux/blob/master/gitlab/git%E5%88%87%E6%8D%A2%E5%88%86%E6%94%AF.md)
- [Zabbix手册](https://github.com/Lancger/opslinux/blob/master/zabbix/v4.0/README.md)
- [Elasticsearch手册](https://github.com/Lancger/opslinux/blob/master/ELFK/elasticsearch/%E6%90%9C%E7%B4%A2%E5%BC%95%E6%93%8E%E7%B3%BB%E5%88%97%E6%96%87%E6%A1%A3.md)


## 二、git 初始化

```
1.初始化版本库：

git init    

2.添加文件到版本库（只是添加到缓存区），.代表添加文件夹下所有文件 

git add .

git status

3.把添加的文件提交到版本库，并填写提交备注(必不可少)

git commit -m "update readme"

到目前为止，我们完成了代码库的初始化，但代码是在本地，还没有提交到远程服务器，要提交到就远程代码服务器，进行以下两步：

4.把本地库与远程库关联

git remote add origin 你的远程库地址

例如：git remote add origin https://github.com/Lancger/opslinux.git

5.第一次推送（提交）代码时：

git push -u origin master 

第一次推送后，直接使用该命令即可推送修改

git push origin master 

6.git删除文件并推送
git rm * -r

git commit -m "clear"

git push origin master

7.git重命名文件夹(例如我想把Zabbix目录改成zabbix,不能直接git mv Zabbix zabbix, 可以使用中转方式，先改成临时的一个目录，然后再改回zabbix)
git config core.ignorecase false  #关闭git忽略大小写配置，即可检测到大小写名称更改
git mv -f Zabbix tmpfolder
git mv -f tmpfolder zabbix
git add -u zabbix  #(-u选项会更新已经追踪的文件和文件夹)
git commit -m "changed the Zabbix to zabbix"

8.Git 设置和取消代理
#全局代理
git config --global http.proxy 'socks5://127.0.0.1:1080'
git config --global https.proxy 'socks5://127.0.0.1:1080'

#还有针对 github.com 的单独配置
git config --global http.https://github.com.proxy socks5://127.0.0.1:1080

#取消代理
git config --global --unset http.https://github.com.proxy

#取消代理
git config --global --unset http.proxy
git config --global --unset https.proxy

git config --global --unset http.https.proxy

#查看git配置
git config -l

9.Linux下git clone加速
例如：这是你要克隆的那个链接
https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git
将其中的github.com替换为github.com.cnpmjs.org
地址也就变成了这样：https://github.com.cnpmjs.org/ROBOTIS-GIT/turtlebot3_simulations.git
然后git clone 
boom！网速提升了几十倍！

https://www.bilibili.com/read/cv7701558
```

参考：http://blog.csdn.net/liang0000zai/article/details/50724632


## 二、初次提交需要执行下面配置

```
git config --global user.email "1151980610@qq.com"
  
git config --global user.name "Lancger"

git add *   (如果是目录的，则需要改成git add test/)
  
git commit -m "项目更新"

git push origin master
  
#新增的目录需要新建文件，才可以提交上来
```

## 三、git push 总是要输入账号密码解决办法
```
1、先cd到根目录，执行git config –global credential.helper store命令
[root@linux-node1 ~]# git config --global credential.helper store

2、执行之后打开 .gitconfig 文件可以看到
[root@linux-node1 ~]# cat .gitconfig
[user]
	email = 1151980610@qq.com
	name = Lancger
[credential]
	helper = store
  
3、重新push 提交 输入用户名密码。

4、下次就可以直接提交了

git 重置账号和密码
git config --system --unset credential.helper

// 如果需要更大的范围
git config --global --unset credential.helper

https://blog.csdn.net/weixin_34403976/article/details/104652347  git 重置账号和密码
```

## 四、Git更新远程仓库代码到本地 git fetch
```
1、查看远程分支
[root@linux-node1 opslinux]#  git remote -v
origin	https://github.com/Lancger/opslinux.git (fetch)
origin	https://github.com/Lancger/opslinux.git (push)

2、从远程获取最新版本到本地
#使用如下命令可以在本地新建一个temp分支，并将远程origin仓库的master分支代码下载到本地temp分支
[root@linux-node1 opslinux]#  git fetch origin master:temp
remote: Enumerating objects: 17, done.
remote: Counting objects: 100% (17/17), done.
remote: Compressing objects: 100% (15/15), done.
remote: Total 15 (delta 10), reused 0 (delta 0), pack-reused 0
Unpacking objects: 100% (15/15), done.
From https://github.com/Lancger/opslinux
 * [new branch]      master     -> temp
 
 
3、比较本地仓库与下载的temp分支
[root@linux-node1 opslinux]# git diff temp
diff --git a/index.md b/index.md
deleted file mode 100644
index ff6da49..0000000
--- a/index.md
+++ /dev/null
@@ -1,109 +0,0 @@
...........

4、合并temp分支到本地的master分支
[root@linux-node1 opslinux]# git merge temp
对比区别之后，如果觉得没有问题，可以使用如下命令进行代码合并：
[root@linux-node1 opslinux]# git merge temp
Already up-to-date.

5、删除temp分支
[root@linux-node1 opslinux]# git branch -d temp
Deleted branch temp (was 7eb97aa).

如果该分支的代码之前没有merge到本地，那么删除该分支会报错，可以使用git branch -D temp强制删除该分支。
 
6、然后再执行

git add *
  
git commit -m "项目更新"

git push origin master
  
#解决了冲突合并了，才可以提交上来
```

# 五、Git 回退版本
```
查看所有的历史版本，获取你git的某个历史版本的id
git log

恢复到历史版本
git reset --hard fae6966548e3ae76cfa7f38a461c438cf75ba965

把修改推到远程服务器
git push -f -u origin master

git reset (–mixed) HEAD~1
回退一个版本,且会将暂存区的内容和本地已提交的内容全部恢复到未暂存的状态,不影响原来本地文件(未提交的也
不受影响)
git reset –soft HEAD~1
回退一个版本,不清空暂存区,将已提交的内容恢复到暂存区,不影响原来本地的文件(未提交的也不受影响)
git reset –hard HEAD~1
回退一个版本,清空暂存区,将已提交的内容的版本恢复到本地,本地的文件也将被恢复的版本替换
```

# 六、Git 查看切换分支和tag
```
#查看所有分支
git branch -a
* master
  remotes/origin/HEAD -> origin/master
  remotes/origin/master
  remotes/origin/nnvm
  remotes/origin/piiswrong-patch-1
  remotes/origin/v0.9rc1
  
#查看本地分支
git branch

#切换分支
git checkout -b v0.9rc1 origin/v0.9rc1

#查看tag
git tag

#切换tag
git checkout vuex-state_getter
```
参考：https://blog.csdn.net/liang0000zai/article/details/50724632

# 七、git上传大文件

```bash
remote: error: GH001: Large files detected. You may want to try Git Large File Storage - https://git-lfs.github.com.

yum install git-lfs -y

git lfs install
git lfs track "jdk-8u251-linux-x64.tar.gz"
git add .gitattributes
git add *
git commit -m "大文件上传"
git push

git push origin master 

https://www.jianshu.com/p/3f25cd20e392  Github如何上传超过100M的大文件
```

# 七、linux cp 隐藏文件和删除隐藏文件
```
显示所有文件，包含隐藏文件
ls -la   

cp -rp vue-element-admin/. /opt/mysite/frontend     一定要有这个 . 才能完整复制隐藏文件
cp -a vue-element-admin/. /opt/mysite/frontend
cp -rf vue-element-admin/. /opt/mysite/frontend

rm -rf .*   删除隐藏文件
```

# 八、临时edu邮箱申请

```bash
https://wangdalao.com/page/2?s=edu&type=post

https://51.ruyo.net/
```

https://templates.office.com/zh-cn/%E9%A1%B9%E7%9B%AE%E9%87%8C%E7%A8%8B%E7%A2%91%E6%97%B6%E9%97%B4%E7%BA%BF-tm34333053  项目里程碑时间线

https://blog.csdn.net/zhaoyanjun6/article/details/72284974 GitHub 实现多人协同提交代码并且权限分组管理

https://www.thinbug.com/q/41863484  清除git本地缓存

https://blog.csdn.net/csj50/article/details/112917855  github取消密码验证，改成token验证

# 九、免费网盘

以下是一些不需要注册即可使用的免费网盘：

WeTransfer: WeTransfer是一种简单的方式，可以将文件（最大2GB）上传到云中并将其发送给其他人。您可以通过电子邮件发送文件或使用下载链接。

Firefox Send: Firefox Send是Mozilla Firefox的服务，它允许用户将文件上传到云中并生成一个加密链接。链接可以设置有效期和下载次数，并且可以最多上传1GB的文件。

File.io: File.io是另一个简单易用的文件共享平台。它允许用户将文件上传到云中，生成一个加密链接，并且可以最多上传5GB的文件。文件在下载或到期后自动删除。

SendGB: SendGB是一个免费的文件传输和存储服务，允许用户最多上传4GB的文件。它还提供加密和密码保护选项。

请注意，这些网盘可能会有一些限制，如文件大小限制、文件过期时间、下载次数等。如果您需要更高级的功能，可能需要注册一个付费账户。

```bash
curl -LJO https://file.io/WM4ejgN2zvUh
```

此命令将使用-L标志跟随重定向并下载文件。-J标志将使用服务器端提供的文件名来命名下载的文件。-O标志将使用服务器端提供的文件名在当前目录中下载文件。

## Stargazers over time

[![Stargazers over time](https://starchart.cc/Lancger/opslinux.svg)](https://starchart.cc/Lancger/opslinux)


