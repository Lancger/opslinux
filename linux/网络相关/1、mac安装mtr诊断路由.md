# 在Mac OS X中安装mtr诊断路由

```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

sudo chown -R $(whoami):staff $(brew --prefix)/*

或者
cd /usr/local
sudo chown -R <your-username>:<your-group-name> *

group name usually staff and don't forget the *  (staff 是mac经常用的分组)
```
```
如果本地安装了brew 的话，安装很方便了

brew install mtr

安装步骤
Kim-Pro:~ Kim$ brew install mtr
==> Downloading https://homebrew.bintray.com/bottles/mtr-0.86.yosemite.bottle.tar.gz
######################################################################## 100.0%
==> Pouring mtr-0.86.yosemite.bottle.tar.gz
==> Caveats
mtr requires root privileges so you will need to run `sudo mtr`.
You should be certain that you trust any software you grant root privileges.
==> Summary
  /usr/local/Cellar/mtr/0.86: 8 files, 148K

提示已经安装成功
运行mtr出现提示

-bash: mtr: command not found

解决方法：

alias mtr=/usr/local/sbin/mtr

然后运行还是会出现问题

mtr: unable to get raw sockets.

需要添加权限

sudo chown root mtr
sudo chmod u+s mtr

完了直接运行

mtr baidu.com 

```
参考文档：

http://www.fyhqy.com/post-373.html  在Mac OS X中安装mtr诊断路由

https://stackoverflow.com/questions/46459152/cant-chown-usr-local-for-homebrew-in-mac-os-x-10-13-high-sierra  
