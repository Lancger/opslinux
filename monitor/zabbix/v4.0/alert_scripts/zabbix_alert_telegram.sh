#!/usr/bin/python
# -*- coding: utf-8 -*-

import requests
import json
import sys

TOKEN="904193186:AAFan97mHMyZJUXR1hmynWt4nq7j1Y7YX4k"

def Send_Message(chat_id, Content):
    url="https://api.telegram.org/bot%s/sendMessage"%(TOKEN)
    data = {
            "chat_id": chat_id,
            "text": Content, 
            }
    res = requests.post(url,json=data)
    return res.text



if __name__ == '__main__':
    chat_id = sys.argv[1]
    Content = sys.argv[2]

    Send_Message(chat_id, Content)
