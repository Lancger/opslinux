申请的https证书越多，管理起来越容易出问题，因此有必要添加定期巡检的脚本（当然，首先要把https证书的申请权限收口到运维侧统一管理，不然还是无法根治问题）

```
#!/bin/bash
# 检测https证书有效期

source /etc/profile

while read line; do
    echo "====================================================================================="
    
    echo "当前检测的域名：" $line
    end_time=$(echo | timeout 1 openssl s_client -servername $line -connect $line:443 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | awk -F '=' '{print $2}' )
    ([ $? -ne 0 ] || [[ $end_time == '' ]]) &&  exit 10
    
    end_times=`date -d "$end_time" +%s `
    current_times=`date -d "$(date -u '+%b %d %T %Y GMT') " +%s `
    
    let left_time=$end_times-$current_times
    days=`expr $left_time / 86400`
    echo "剩余天数: " $days
    
    [ $days -lt 30 ] && echo "https 证书有效期少于30天，存在风险" 
    
done < /root/https_list
```

cat /root/https_list  内容类似如下：
```
www.baidu.com 
www.qq.com
```

脚本的执行后效果如下。 另外，我们可以在脚本的判断条件里面，将echo改成email告警或者调公司内部的告警平台。

参考资料：

https://blog.51cto.com/lee90/2410670  shell脚本检测https证书有效期
