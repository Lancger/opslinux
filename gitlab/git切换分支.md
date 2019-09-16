 # 一、git命令－切换分支
 Git一般有很多分支，我们clone到本地的时候一般都是master分支，那么如何切换到其他分支呢？主要命令如下：
 
### 1. 查看远程分支
```bash
git branch -a 
```
我在mxnet根目录下运行以上命令：
```bash
~/mxnet$ git branch -a
* master
  remotes/origin/HEAD -> origin/master
  remotes/origin/master
  remotes/origin/nnvm
  remotes/origin/piiswrong-patch-1
  remotes/origin/v0.9rc1
```
可以看到，我们现在在master分支下

### 2. 查看本地分支
```bash
~/mxnet$ git branch
* master
```
### 3. 切换分支
```bash
$ git checkout -b v0.9rc1 origin/v0.9rc1
Branch v0.9rc1 set up to track remote branch v0.9rc1 from origin.
Switched to a new branch 'v0.9rc1'
```
### 已经切换到v0.9rc1分支了
```bash
$ git branch
  master
* v0.9rc1
```
### 切换回master分支
```bash
$ git checkout master
Switched to branch 'master'
Your branch is up-to-date with 'origin/master'.
```

参考资料： https://www.cnblogs.com/smiler/p/6924583.html
