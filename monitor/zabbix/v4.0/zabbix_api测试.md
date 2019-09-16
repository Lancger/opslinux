# 一、zabbix_api登录认证
```
测试
curl -s -X POST -H 'Content-Type:application/json' -d '{
    "jsonrpc": "2.0",
    "method": "user.login",
    "params": {
        "user": "Admin",
        "password": "123456"
    },
    "id": 1
}' http://192.168.52.100/zabbix/api_jsonrpc.php

结果
{"jsonrpc":"2.0","result":"3bbbf0714fec0ec75cc35d65277b88f2","id":1}
```

参考资料：

https://www.cnblogs.com/Peter2014/p/7657480.html  
