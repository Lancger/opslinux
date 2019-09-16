#!/usr/local/bin/python
# coding: utf-8

import os
import sys
import pexpect
import MySQLdb
import struct
import fcntl
import termios
import signal

opt = sys.argv
if len(opt) == 1:
    print '''
    ----------------------------
    'Useage: ./zssh.py ServerIP'
    ----------------------------
    '''
    sys.exit(2)

def sigwinch_passthrough (sig, data):
    winsize = getwinsize()
    global foo
    foo.setwinsize(winsize[0],winsize[1])

def getwinsize():
    if 'TIOCGWINSZ' in dir(termios):
        TIOCGWINSZ = termios.TIOCGWINSZ
    else:
        TIOCGWINSZ = 1074295912L # Assume
    s = struct.pack('HHHH', 0, 0, 0, 0)
    x = fcntl.ioctl(sys.stdout.fileno(), TIOCGWINSZ, s)
    return struct.unpack('HHHH', x)[0:2]

ip = opt[1]
conn = MySQLdb.connect(host='localhost', user='root', passwd='1Qaz2Wsx3Edc', db='sa')
cursor = conn.cursor()

cursor.execute('select muser,mpass,rpass from password where ip=%s', (ip,))
result = cursor.fetchall()

if len(result) == 0:
    muser = raw_input('输入用户名: ')
    mpass = raw_input('输入 %s 用户密码: '% muser)
    rpass = raw_input('输入 root 密码: ')
    cursor.execute('insert into password values (%s,%s,%s,%s)', (ip, muser, mpass, rpass))
    conn.commit()
elif len(result) == 1:
    muser = result[0][0]
    mpass = result[0][1]
    rpass = result[0][2]
    

foo = pexpect.spawn('ssh %s@%s' % (muser,ip))
while True:
    index = foo.expect(['continue', 'assword', pexpect.EOF, pexpect.TIMEOUT],timeout=10)
    if index == 0:
        foo.sendline('yes')
        continue
    elif index == 1:
        foo.sendline(mpass)
        index2 = foo.expect(['password', ']\$'])
        if index2 == 1:
            print '%s 登录成功' % muser
            break
        elif index2 == 0:
            while True:
                mpass = raw_input('用户 %s 密码不对,重新输入: ' % muser)
                foo.sendline(mpass)
                index3 = foo.expect([']\$', 'assword'], timeout=5)
                if index3 == 0:
                    cursor.execute('update sa.password set muser=%s, mpass=%s where ip=%s ', (muser, mpass, ip))
                    conn.commit()
                    foo.sendline('')
                    break
                else:
                    continue
    else:
        print '连接超时' 
    break

while True:
    foo.sendline('su - root')
    foo.sendline(rpass)
    index5 = foo.expect(['\]#', 'failure', pexpect.EOF, pexpect.TIMEOUT], timeout=5)
    if index5  == 0:
        foo.sendline('')
        print 'root 登录成功'
        break
    elif index5 == 1:
        while True:
            rpass = raw_input('root 密码不对,请输入: ')
            foo.sendline('su - root')
            foo.sendline(rpass)
            index7 = foo.expect(['\]#', 'failure', pexpect.EOF, pexpect.TIMEOUT], timeout=5)
            if index7 == 0:
                cursor.execute('update sa.password set rpass=%s where ip=%s', (rpass, ip))
                conn.commit()
                break
            elif index7 == 1:
                continue
            else:
                print 'error'
    else:
        print 'error'

signal.signal(signal.SIGWINCH, sigwinch_passthrough)
size = getwinsize()
foo.setwinsize(size[0], size[1])

foo.interact()
pass
