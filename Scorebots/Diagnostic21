#!/usr/bin/env python3
#~~~~~~~~~~~~~~~~~~~~~~~SETUP~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
import os
import sys
import time
import pwd
import grp
import subprocess
from pylab import *
from matplotlib.ticker import *
import _datetime
from multiprocessing import Process
import numpy as np
import matplotlib.pyplot as plt
import urllib.request as urllib2
import re
mainUser = 'cyber' #the place to install ScoringEngine
today = _datetime.date.today()
plt.ioff()
scoreInterval = 30 #seconds between scoring
#~~~~~~~~~~~~~~~~Create Classes~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
class Service:
	def __init__(self,name,port):
		self.port = port
		self.name = name
	def getPort(self):
		return self.port
	def getName(self):
		return self.name
	def isDown(self):	
		if os.system('''netstat -tulpn | grep ''' + str(self.getPort()))  == 0:
			return False
		return True
class User:
	def __init__(self,name):
			self.name=name
	def getName(self):
			return self.name	
	def works(self):
		try:
			pwd.getpwnam(self.getName())
			return True
		except KeyError:
			return False
class Group:
	def __init__(self,name):
			self.name=name
	def getName(self):
			return self.name
	def exists(self):
		try:
			grp.getgrnam(self.getName())
			return True
		except KeyError:
			return False

class Task:
	def __init__(self,level, desc, val, boolean): #constructor
		self.desc = desc
		self.boolean = boolean
		self.val = val
		self.level = level

	#returns the point value of the task
	def getValue(self):
		return self.val
	#returns the description of the task
	def getLevel(self):
		return self.level
	#returns the level of the task
	def getDescription(self):
		return self.desc

	#returns true if the boolean criterion is met
	def isFixed(self):
		if os.system(self.boolean) == 0: 
		#runs the linux boolean command to see the result
			return True
		else:
			return False
#~~~~~~~~~~~~~~~~~~~~~~THINGS TO SCORE~~~~~~~~~~~~~~~~~~~~~~~~~#
users = [User(mainUser), User('shoeman'), User('aterry'), User('joneill')] #If a user is deleted, you get a penalty
services = [Service('ssh',22), Service('apache2',80), Service('mysql',3306)] #If a service is down, you get a penalty
allTasks = [
		#0-50 for beginners, 50-75 for returners, 75-100 for advanced
		#Forensics-Beginner
	Task('Beginner','Beginner Forensics 1', 5, '[ "$(grep 66c307d3bcd35df04b7d913fcb8c39a4 /home/'+ mainUser + '/Desktop/ForensicsB1)" ]'),
	Task('Beginner','Beginner Forensics 2', 5, '[ "$(grep /home/cyber/Downloads/potionseller.mp4 /home/'+ mainUser + '/Desktop/ForensicsB2)" ]'),
		#Forensics-Returner
	Task('Returner','Returner Forensics 1', 5, '[ "$(grep "This was a scam. I do not give points for being deleted. I am sorry for lying." /home/'+ mainUser + '/Desktop/ForensicsR1)" ]'),
	Task('Returner','Returner Forensics 2', 5, '[ "$(grep "86c2629c-7a2d-44cd-914e-62d97c9b75b1" /home/'+ mainUser + '/Desktop/ForensicsR2)" ]'),
		#Forensics-Advanced
	Task('Advanced','Advanced Forensics 1', 5, '[ "$(grep "Trick question, last names are a fabricated social construct and do not actually exist." /home/'+ mainUser + '/Desktop/ForensicsA1)" ]'),
	Task('Advanced','Advanced Forensics 2', 5, '[ "$(grep 5120 /home/'+ mainUser + '/Desktop/ForensicsA2)" ]'),
	Task('Advanced','Halfway there! Say, Das M sounds like a cool name for a STEGosaurus', 0, '[ "$(egrep -e "Das M" -e "das m" /home/'+ mainUser + '/Desktop/ForensicsA1)" ]'),
		#Users-Beginner
	Task('Beginner','Removed unauthorized user erdie', 1, '[ ! "$(grep erdie /etc/passwd)" ]'), #! ##
	Task('Beginner','Removed unauthorized admin rocky', 1, '[ ! "$(grep -e admin -e sudo /etc/group | grep rocky)" ]'), #!
	Task('Beginner','Fixed insecure password for shoeman', 1, '[ ! "$(grep shoeman /etc/shadow | grep $6$qNRUkogj$ZcTXD9YJKcVEUIDNrik2VTuWpNC6w4ECTemhNXdcaGUYw6RpZRQPNqcB3twOtSjFF04J3Pis.6eoO6K.9NcRX1)" ]'), #!
	Task('Beginner','Gave theguy a password', 1, '[ ! "$(grep theguy /etc/shadow | grep ::0)" ]'), #!
	Task('Beginner','Added user greenie', 1, '[ "$(grep greenie /etc/passwd)" ]'), #!
		#Users-Returner
	Task('Returner','admn group does not have sudo access', 2, '[ ! "$(grep admn /etc/sudoers)" ]'), #!
		#Users-Advanced
		#Services-Beginner
	Task('Beginner','Ubuntu updated to 18.04', 5, '[ "$(lsb_release -a | grep 18.04)" ]'), #!
	Task('Beginner','ssh running on port 22', 3, '[ "$(grep 22 /etc/ssh/sshd_config)" ]'), #!
	Task('Beginner','Removed samba', 3, '[ ! "$(dpkg -l | grep samba)" ]'), #!
	Task('Beginner','Password complexity enforced', 3, '[ "$(grep "minlen=8" /etc/pam.d/common-password)" ]'), #!
	Task('Beginner','ssh uses protocol 2', 3, '[ "$(grep protocol /etc/ssh/sshd_config | grep 2)" ]'), #!
	Task('Beginner','ssh disables root login', 3, '[ "$(grep root /etc/ssh/sshd_config | grep NO)" ]'), #!
	Task('Beginner','ufw enabled', 3, '[ ! "$(ufw status | grep inactive)" ]'), #!
		#Services-Returner
	Task('Returner','mySQL using correct port', 2, '[ "$(netstat -tulpn | grep 3306)" ]'), #!
	Task('Returner','apache2 servertokens give minimal information', 2, '[ "$(grep "ServerTokens Prod" /etc/apache2/conf-available/security.conf)" ]'), #!
		#Services-Advanced
		#Malware-Beginner
	Task('Beginner','Uninstalled netcat', 3, '[ ! "$(dpkg -l | grep netcat)" ]'), #!
	Task('Beginner','Uninstalled nmap', 3, '[ ! "$(dpkg -l | grep nmap)" ]'), #!
		#Malware-Returner
	Task('Beginner','Removed funny crontab prank (you just walked the prank)(just pretend it was working)', 3, '[ ! "$(grep aterry /etc/crontab)" ]'), #!
		#Malware-Advanced
	Task('Advanced','Super ultra mega secret netcat backdoor (it now works!!!) removed', 5, '[ ! "$(grep netstat /root/.bashrc)" ]'), #! ##
		#Files-Beginner
	Task('Beginner','Removed insecure sudoers.d configuration', 3, '[ ! "$(grep NOPASSWD /etc/sudoers.d/README)" ]'), #! ##
	Task('Beginner','Removed passwords file', 3, '[ ! "$(grep meadows /home/rocky/ThisFileDoesNotContainMyPassword.txt)" ]'), #!
		#Files-Returner
	Task('Returner','Fixed improper passwd permissions', 2, '[ "$(stat -c "%a %n" /etc/passwd | grep 644)" ]'), #!
	Task('Returner','Fixed improper shadow permissions', 2, '[ "$(stat -c "%a %n" /etc/shadow | grep 600)" ]'), #!
	Task('Returner','Removed credit card numbers from apache server', 2, '[ ! "$(grep 9 /var/www/html/money.txt)" ]'), #!
	Task('Returner','IPV4 forwarding disabled', 2, '[ "$(grep "forward = 0" /etc/sysctl.conf)" ]'), #!
		#Files-Advanced
	Task('Advanced','Proper umask in root .bashrc', 5, '[ "$(grep umask /root/.profile | grep 022)" ]'), #!
	Task('Advanced','Bad clear alias', 5, '[ ! "$(grep clear /root/.bashrc)" ]'), #!
	]
groups = [] #groups that must exist, or else a penalty
#~~~~~~~~~~~~~~~CREATE THE WEBSITE/CALCULATE POINTS~~~~~~~~~~~~~#
def update():
	percent = str(round(currentPoints / totalPoints * 100, 1)) + '%'
	score = str(currentPoints) + " out of " + str(totalPoints) + " total points"
	questionsAnswered = str(numFixedVulns) + " out of " + str(len(allTasks)) + " total tasks completed"
	BeginnerSolved = 0
	BeginnerTotal = 0
	returnerSolved = 0
	returnerTotal = 0
	advancedSolved = 0
	advancedTotal = 0

	for t in allTasks:
			if t.getLevel() == 'Beginner':
				BeginnerTotal = BeginnerTotal + 1
			if t.getLevel() == 'Returner':
				returnerTotal = returnerTotal + 1
			if t.getLevel() == 'Advanced':
				advancedTotal = advancedTotal + 1
	h = open('/home/cyber/Desktop/ScoreReport.html','w')
	h.write('<!DOCTYPE html> <html> <head> <meta name="viewport" content="width=device-width, initial-scale=1"> <style> * { box-sizing: border-box; } .column { float: left; padding: 10px; height: 1500px; } .left, .right { width: 25%; } .middle { width: 50%; } .row:after { content: ""; display: table; clear: both; }</style> </head> <body><div class="row"> <div class="column left" style="background-color:#0d60bf;"></div> <div class="row"> <div class="column middle" style="background-color:#fff;"><h1 style="text-align: center;"><span style="font-family: arial, helvetica, sans-serif;">Score Report</span></h1><h2 style="text-align: center;"><br /><span style="font-family: arial, helvetica, sans-serif;">' + percent + ' completed</span></h2><p> </p>')
	h.write('<p><span style="font-family: arial, helvetica, sans-serif; text-align: center;"><strong>' + "Report Generated at: " + str(today) + '. </strong></span></p>')
	h.write('<p><span style=color:red;"font-family: arial, helvetica, sans-serif;"><strong>' + str(penalties) + ' Points in Scoring Penalties</strong></span></p>')
	h.write('<p><span style="font-family: arial, helvetica, sans-serif;"><strong>' + str(score) + '. </strong></span></p>')
	h.write('<p><span style="font-family: arial, helvetica, sans-serif;"><strong>' + str(questionsAnswered) + '. </strong></span></p>')
	h.write('<style> div { background-image: url(https://i.pinimg.com/originals/15/79/25/157925e28f33c43a30973791b2f787f4.jpg); background-blend-mode: lighten; } </style>')
	h.write('<hr class="line2"><br>')

	for u in users:
		if not u.works():
			h.write('<p><span style=color:red;"font-size: 10pt;  font-family: arial, helvetica, sans-serif;">'
                         + u.getName()
                        + ' is NOT functional: - 5 points</span></p>')
	for s in services:
		if s.isDown():
				h.write('<p><span style=color:red;color:red;"font-size: 10pt;  font-family: arial, helvetica, sans-serif;">'
                         + s.getName()
                        + ' is NOT functional or Using wrong port: - 5 points</span></p>')
	for g in groups:
		if not g.exists():
				h.write('<p><span style=color:red;"font-size: 10pt;  font-family: arial, helvetica, sans-serif;">'
                         + g.getName()
                        + ' is NOT created: - 5 points</span></p>')
	for t in allTasks:
		if t.isFixed() and t.getLevel() == 'Beginner':
			BeginnerSolved = BeginnerSolved + 1
			h.write('<p><span style="font-size: 10pt; font-family: arial, helvetica, sans-serif;">'
			+ '<span style="color:green;">Beginner</span>' + ' ' + t.getDescription() + ' '
			+ str(t.getValue()) + ' points</span></p>')

		if t.isFixed() and t.getLevel() == 'Returner':
			returnerSolved = returnerSolved + 1
			h.write('<p><span style="font-size: 10pt; font-family: arial, helvetica, sans-serif;">'
			+ '<span style="color:blue;">Returner</span>' + ' ' + t.getDescription() + ' '
			+ str(t.getValue()) + ' points</span></p>')

		if t.isFixed() and t.getLevel() == 'Advanced':
			advancedSolved = advancedSolved + 1
			h.write('<p><span style="font-size: 10pt; font-family: arial, helvetica, sans-serif;">'
			+ '<span style="color:purple;">Advanced</span>' + ' ' + t.getDescription() + ' '
			+ str(t.getValue()) + ' points</span></p>')

	bS = str(BeginnerSolved) + " out of " + str(BeginnerTotal) + " Beginner tasks completed"
	rS = str(returnerSolved) + " out of " + str(returnerTotal) + " returner tasks completed"
	aS = str(advancedSolved) + " out of " + str(advancedTotal) + " advanced tasks completed"
	h.write('<p><span style="font-family: arial, helvetica, sans-serif;"><strong>' + str(bS) + '. </strong></span></p>')
	h.write('<p><span style="font-family: arial, helvetica, sans-serif;"><strong>' + str(rS) + '. </strong></span></p>')
	h.write('<p><span style="font-family: arial, helvetica, sans-serif;"><strong>' + str(aS) + '. </strong></span></p>')
	h.write('<img src=".graph.png" alt="Graph" width="350" height="250">')
	h.write('</div> <div class="row"> <div class="column right" style="background-color:#0d60bf;"></div> </body>')
	h.write('<meta http-equiv="refresh" content="20">')
	h.write('<footer><h6>Cyber Club</h6></footer>')

#~~~~~~~~~~~~~~~~~~~~~Make a bar popup on screen when you get points~~~~~~~~~~~~~~~~~~~~~~~#
def notify(ph):
	#Creates a popup on the screen
	icon_path = "/usr/bin/scorebot/scoring.png"
	if (ph[-1] > ph[-2]):
		os.system('notify-send -i ' + icon_path + ' \'You Earned Points!\' ')

	if (ph[-1] < ph[-2]):
		os.system('notify-send -i ' + icon_path + ' \'You Lost Points!\' ')
#~~~~~~~~~~~~~~~~~~~~Send data to server~~~~~~~~~~~~~~~~~~~~~~~~~~#
pointHistory = [0,0,0] #list containing the history of points, add 3 0's so chart looks better
HasEnteredTeamInfo = False #Have they put in info in the GUI created by TeamInfo.py(example: none:single:none:none)
dUSR = ""
dMode = ""
dServIP = ""
key = "cool" #secret key so people can't just send data to the server to get points
while True:
	##Have array of previous points every 5 seconds and send the array to the returnScore.py
	currentPoints = 0 #The amount of points you currently have
	lastPoints = 0 #the previous current points
	penalties = 0 #Number of penalties
	numFixedVulns = 0
	totalPoints = 0

	for i in services:
		if i.isDown():
			penalties = penalties + 5
	for i in groups:
		if not i.exists():
			penalties = penalties + 5
	for i in users:
		if not i.works():
			penalties = penalties + 5
	for i in allTasks:
		totalPoints = totalPoints + i.getValue()
		if i.isFixed():
				numFixedVulns = numFixedVulns + 1
				currentPoints = currentPoints + i.getValue()
	currentPoints = currentPoints - penalties
	pointHistory.append(currentPoints)
	notify(pointHistory)

	while (not HasEnteredTeamInfo):
		print("enter team Info")
		os.system("python3 /home/"+mainUser+"/Desktop/TeamInfo.py")
		TeamInfo = os.popen("head -n1 /etc/scorebot/.usr.dat").read()
		#print("Team Info is: " + str(TeamInfo))
		dUSR = str(TeamInfo.split(":")[0])
		print("dusr is:" + dUSR)
		dMode = str(TeamInfo.split(":")[1])
		dServIP = str(TeamInfo.split(":")[2] + ":" + str(TeamInfo.split(":")[3]))
		HasEnteredTeamInfo = True
		print ("dMode is now: " + dMode)

	if (dMode == "server" ):
		data = str(dUSR) + ":" + str(currentPoints) + ":" + str(int((time.time() / 60))) + ":" + str(key) 
		os.system("curl -X POST -d " + data + " http://" + dServIP)

#~~~~~~~~~~~~~~Create a graph to add to the .html webpage~~~~~~~~~~~~~~~~~~~~~~~~#
	pltOneValues = pointHistory
	figure, axis = plt.subplots(2,1)
	axis[0].plot(pltOneValues, linewidth=4, color="red")
	axis[0].set_title("Points")
	axis[0].yaxis.set_major_locator(MaxNLocator(integer=True))
	axis[0].axhline(y=0, color="black")
	axis[0].set_xlabel("Time (Intervals of " + str(scoreInterval) + " seconds)")
	axis[0].set_ylabel("Points")
	#
	labels = ["Solved", "Unsolved"]
	pltTwoValues = [numFixedVulns, len(allTasks) - numFixedVulns] 
	explode = (0,0.1)
	axis[1].pie(pltTwoValues, explode=explode, labels=labels, autopct='%1.1f%%',
    shadow=True, startangle=90)
	axis[1].axis('equal')
	plt.savefig('.graph.png',bbox='tight')
	plt.close()
	update()
	time.sleep(scoreInterval)
	
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~DEBUG~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#Delete all processes with a name
	#ps -ef | grep 'scorebot.py' | grep -v grep | awk '{print $2}' | xargs -r kill -9
#fix apt command locked
#sudo killall apt apt-get
#sudo rm /var/lib/apt/lists/lock
#sudo rm /var/cache/apt/archives/lock
#sudo rm /var/lib/dpkg/lock*
#sudo dpkg --configure -a
