# python 手册

```
cat > /tmp/1.py << \EOF
#!/usr/bin/env python
# -*- coding: utf-8 -*- 

import requests
#请求地址
url = "http://127.0.0.1:6381/status"

#发送get请求
r = requests.get(url)

#获取返回的json数据
print(r.json())
EOF

python /tmp/1.py
```
