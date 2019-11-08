```
1、Create a bot
2、Gets its API token (via @BotFather)
3、Get the ID of the chat
4、Add your bot to the chat
Fetch bot updates and look for the chat id:

curl https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/getUpdates | jq .message.chat.id

OR, run bot.rb and @-mention your bot in the chat. The chat id will appear in bot.rb's output.
The bot may need temporary message access: @BotFather > Bot Settings > Group Privacy > Turn off #注意需要打开这个权限

Send a message via their HTTP API: https://core.telegram.org/bots/api#sendmessage

curl -X POST \
     -H 'Content-Type: application/json' \
     -d '{"chat_id": "123456789", "text": "This is a test from curl", "disable_notification": true}' \
     https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage

https://api.telegram.org/bot817459097:AAEoDoo6Ck_xv_JYF22UdmPrU5nbQtAAx34/getUpdates

#组告警
curl -X POST "https://api.telegram.org/bot817459097:AAEoDoo6Ck_xv_JYF22UdmPrU5nbQtAAx34/sendMessage" -d "chat_id=-393954337&text=my sample text"
```

# 电报通知
```
cat > /usr/local/bin/telegram.py << \EOF
#!/usr/bin/python
# -*- coding: utf-8 -*-

import requests
import json
import sys


def Send_Message(chat_id, Content):
    url = "https://api.telegram.org/bot817459097:AAEoDoo6Ck_xv_JYF22UdmPrU5nbQtAAx34/sendMessage"
    data = {
            "chat_id": chat_id,
            "text": Content, 
            }
    res = requests.post(url,json=data)
    return res.text



if __name__ == '__main__':
    chat_id = sys.argv[1]
    Content = sys.argv[2]

    print Send_Message(chat_id, Content)
EOF

测试
python telegram.py -393954337 test
```

# 电报设置代理

  ![电报代理](https://github.com/Lancger/opslinux/blob/master/images/telegram.png)


参考文档：

https://blog.51cto.com/yangshufan/2392609?source=drh    配置zabbix+telegram告警


https://gist.github.com/dideler/85de4d64f66c1966788c1b2304b9caf1  json参数传递
