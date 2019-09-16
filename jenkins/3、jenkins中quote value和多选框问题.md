## 一、背景
jenkins自带的参数化不支持多选框，不过有插件支持：Extended Choice Parameter Plug-In

插件地址： https://plugins.jenkins.io/extended-choice-parameter

## 二、使用教程

Name -- 定义变量名

Parameter Type -- check boxes 复选框

  ![jenkins——quote](https://github.com/Lancger/opslinux/blob/master/images/check_boxes.png)


设置好，展示如下：

  ![jenkins——quote](https://github.com/Lancger/opslinux/blob/master/images/check_boxes1.png)


在后续操作中如果要使用这个多选框的话，使用${emails}

这里注意的是：不要勾选Quote Value

# 案例一
勾选了quote value的话，echo ${emails} 显示 <"test@111.com">

不勾选的话，echo ${emails} 显示 test@111.com ，没有<>和“”


# 案例二
勾选了会导致发布失败
勾选了的效果，主机名多了'""'---导致发布失败

ansible '"test062"' -m synchronize -a 'src=/var/lib/jenkins/workspace/uat-test-com/ dest=/data/www/uat-test-com owner=no group=no mode=push'

这才是正常的 主机名没有'""'

ansible '"test062"' -m synchronize -a 'src=/var/lib/jenkins/workspace/uat-test-com/ dest=/data/www/uat-test-com owner=no group=no mode=push'

当然勾选了肯定其他用途，暂时不知道怎么使用

参考资料：

https://cloud.tencent.com/developer/article/1027980  jenkins 多选框
