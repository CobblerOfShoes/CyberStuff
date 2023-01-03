#! /bin/bash

sleep 10
sudo dnf install git
sudo dnf install shc
sudo dnf install gcc
git clone -b misc https://github.com/GreenLightning07/MadagascarLAMP.git
chmod +x MadagascarLAMP/scorebot.sh
mv CyberStuff/CopyOnlyImages/CaseyImage/scorebot.sh /var/local/scorebot.sh
mv CyberStuff/CopyOnlyImages/CaseyImage/ScoreReport.html /home/cyber/Desktop/ScoreReport.html
mv CyberStuff/CopyOnlyImages/CaseyImage/README.html /home/cyber/Desktop/README.html
mv CyberStuff/CopyOnlyImages/CaseyImage/Contact.html /home/cyber/Desktop/Contact.html
chown cyber:cyber /home/cyber/Desktop/ScoreReport.html
chown cyber:cyber /home/cyber/Desktop/README.html
chown cyber:cyber /home/cyber/Desktop/Contact.html
shc -f /var/local/scorebot.sh
rm /var/local/scorebot.sh
sudo /var/local/scorebot.sh.x
