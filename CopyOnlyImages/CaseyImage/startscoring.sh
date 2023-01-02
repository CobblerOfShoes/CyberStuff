#! /bin/bash

sleep 10
sudo apt install git
sudo apt install shc
sudo apt install gcc
git clone -b misc https://github.com/GreenLightning07/MadagascarLAMP.git
chmod +x MadagascarLAMP/changes.sh
chmod +x MadagascarLAMP/scorebot.sh
mv MadagascarLAMP/scorebot.sh /var/local/scorebot.sh
mv MadagascarLAMP/ScoreReport.html /home/skipper/Desktop/ScoreReport.html
mv MadagascarLAMP/README.html /home/skipper/Desktop/README.html
mv MadagascarLAMP/Contact.html /home/skipper/Desktop/Contact.html
chown skipper:skipper /home/skipper/Desktop/ScoreReport.html
chown skipper:skipper /home/skipper/Desktop/README.html
chown skipper:skipper /home/skipper/Desktop/Contact.html
MadagascarLAMP/changes.sh
shc -f /var/local/scorebot.sh
rm /var/local/scorebot.sh
sudo /var/local/scorebot.sh.x
