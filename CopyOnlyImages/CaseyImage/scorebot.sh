#!/bin/bash

total_found=0
total_percent=""
total_pen=0

pam_configed=false
encrypt_set=false

score_report="/home/cyber/Desktop/ScoreReport.html"

function update-found
{
	#updates vuln found counts in score report
	total_percent=$(awk -vn=$total_found 'BEGIN{print(n*1.538461538)}')
	echo $total_percent
        sed -i "s/id=\"total_found\".*/id=\"total_found\">$total_found\/65<\/h3>/g" $score_report
        sed -i "s/id=\"total_percent\".*/id=\"total_percent\">$total_percent%<\/h3>/g" $score_report
	
	echo $total_pen
	
	if [ $total_pen == 0 ]; then
		sed -i "s/id=\"p0\"style=\"display:none\"/id=\"p0\"style=\"display:block\"/g" $score_report
	else
		sed -i "s/id=\"p0\"style=\"display:block\"/id=\"p0\"style=\"display:none\"/g" $score_report
	fi
}

function show-vuln()
{
	#allows vuln name to be seen in score report
	sed -i "s/id=\"$1\"style=\"display:none\"/id=\"$1\"style=\"display:block\"/g" $score_report
	((total_found+=$4))
	#replaces placeholder name with actual vuln name (obfuscation)
	sed -i "s/$2/$3/g" $score_report
	sudo -u skipper DISPLAY=:0.0 notify-send "Congrats!" "You Gained Points"
}

function hide-vuln()
{
	#hides vuln name from score report
	sed -i "s/id=\"$1\"style=\"display:block\"/id=\"$1\"style=\"display:none\"/g" $score_report
	((total_found-=$4))
	#replaces placeholder name (people should keep their own notes on the points they've gained)
	sed -i "s/$2/$3/g" $score_report
	sudo -u skipper DISPLAY=:0.0 notify-send "Uh Oh!" "You Lost Points"
}

function penalty()
{
	sed -i "s/id=\"$1\"style=\"display:none\"/id=\"$1\"style=\"display:block\"/g" $score_report
	((total_found-=$4))
	((total_pen+=1))
		
        #replaces placeholder name (people should keep their own notes on the points they've gained)
        sed -i "s/$2/$3/g" $score_report
        sudo -u skipper DISPLAY=:0.0 notify-send "Uh Oh!" "You Lost Points"
}

function remove-penalty()
{
	#allows vuln name to be seen in score report
        sed -i "s/id=\"$1\"style=\"display:block\"/id=\"$1\"style=\"display:none\"/g" $score_report
        ((total_found+=$4))
	((total_pen-1))
	
        #replaces placeholder name with actual vuln name (obfuscation)
        sed -i "s/$2/$3/g" $score_report
        sudo -u skipper DISPLAY=:0.0 notify-send "Congrats!" "You Gained Points"
}

function check()
{
	if ( eval $1 ); then
		if ( cat $score_report | grep "id=\"$2\"" | grep "display:none" ); then
			show-vuln "$2" "Vuln$2;" "$3" "$4"
		fi
	elif ( cat $score_report | grep "id=\"$2\"" | grep "display:block" ); then
		hide-vuln "$2" "$3" "Vuln$2;" "$4"
	fi
}

function check-pen()
{
	if ( eval $1 ); then
		if ( cat $score_report | grep "id=\"$2\"" | grep "display:none" ); then
			penalty "$2" "$2;" "$3" "$4"
		fi
	elif ( cat $score_report | grep "id=\"$2\"" | grep "display:block" ); then
		remove-penalty "$2" "$3" "$2;" "$4"
	fi
}

update-found

while true
do
	update-found
	
	#Forensics
	check 'cat /home/cyber/Desktop/Forensics1 | grep -E "httpd|mariadb|php"' '1' 'Forensics 1 Correct +5' '5' ###
	check 'cat /home/cyber/Desktop/Forensics2 | grep "ens160"' '2' 'Forensics 2 Correct +5' '5' ###
	check 'cat /home/cyber/Desktop/Forensics3 | grep "boot"' '3' 'Forensics 3 Correct +5' '5' ###
	
	#Vulns
	check '! cat /etc/group | grep "sudo" | grep "germ"' '4' 'User germ is not an admin +2' '2' ###
	check '! cat /etc/passwd | grep "forensicsthree"' '5' 'Unauthorized user forensicsthree removed +2' '2' ###
	check '! cat /etc/shadow | grep skipper | grep "\$y\$j9T\$Jz0F23Stn6RsiqChH9z1z"' '6' 'Insecure password on skipper changed +2' '2'
	check '! cat /etc/shadow | grep "motomoto"' '7' 'Hidden user motomoto removed +4' '4'
	check 'cat /etc/group | grep "sudo" | grep "private"' '8' 'User private is an administrator +1' '1'
	check 'ls -al /etc/shadow | grep "\-rw-r-----" || ls -al /etc/shadow | grep "\-rw-------"' '9' 'Correct file permissions set on \/etc\/shadow +3' '3'
	check 'ls -al /var/ | grep "www" | grep "dr--r--r--"' '10' 'Correct file permissions set on \/var\/www\/ +3' '3' 
	check 'ls -al /etc/passwd | cut -d " " -f3 | grep "root"' '11' 'Correct owner set on \/etc\/passwd +3' '3'
	check 'cat /etc/sysctl.conf | grep ^"net.ipv4.conf.all.log_martians" | grep "1"' '12' 'Logging martian packets enabled +2' '2'
	check 'cat /etc/sysctl.conf | grep ^"kernel.randomize_va_space" | grep "1"' '13' 'ASLR is enabled +2' '2'
	check 'cat /etc/login.defs | grep "PASS_MAX_DAYS" | grep "90"' '14' 'Max password days set to 90 +2' '2'
	check 'cat /etc/security/pwquality.conf | grep "minlen" | grep "16"' '15' 'Password minimum legnth set to 16 +3' '3'
	check '! ls -al /var/www/ | grep "\.\.\." | grep "\->"' '16' 'Symbolic link to \/ directory in \/var\/www\/ removed +4' '4'
	check 'cat /etc/apache2/conf-available/security.conf | grep "FileEtag" | grep -iF "none"' '17' 'ETag headers are disabled +3' '3'
	check '! mysql -u root -e "use db; show tables;" | grep "cards"' '18' 'MySql database containing credit card information removed +4' '4'
	check 'cat /etc/mysql/mysql.conf.d/mysqld.cnf | grep "local-infile" | grep "0"' '19' 'Local infile set to 0 +2' '2'
	check 'cat /etc/php.ini | grep "display_errors = Off"' '20' 'PHP does not display error messages on client side +1' '1' ###
	check 'cat /etc/php.ini | grep "file_uploads = Off"' '21' 'PHP file uploads are disabled +3' '3' ###
	check '! find /etc/cron.d | grep "firefox"' '22' 'Malicious crontab script removed +5' '5'
	
	#penalties
	check-pen '! netstat -tulpn | grep apache2 | cut -d " " -f15 | grep ":80"$' 'p1' 'Apache2 is Disabled or Running on Wrong Port -10' '10'
	check-pen '! netstat -tulpn | grep mysql | cut -d " " -f16 | grep ":3306"$' 'p2' 'MySQL is Disabled or Running on Wrong Port -10' '10'
	check-pen '! cat /etc/group | grep "wheel:x:" | grep "cyber"' 'p3' 'cyber is Not an Admin -5' '5'
	check-pen '! cat /etc/group | grep "wheel:x:" | grep "stefan"' 'p4' 'stefan is Not an Admin -5' '5'
	check-pen '! cat /etc/passwd | grep "edsheeran"' 'p5' 'User edsheeran was Removed -3' '3'
	check-pen '! cat /etc/passwd | grep "cyber"' 'p6' 'User cyber was Removed -3' '3'
	check-pen '! cat /etc/passwd | grep "stefan"' 'p7' 'User stefan was Removed -3' '3'
	check-pen '! cat /etc/passwd | grep "germ"' 'p8' 'User germ was Removed -3' '3'
	
	#wait 10 seconds
	sleep 10
done
