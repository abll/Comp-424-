#!/bin/bash

<<implemntationscript
#######LAMP Config####
#configure the Apache server to not give an error on start
echo "ServerName localhost" | sudo tee /etc/apache2/conf-available/fqdn.conf && sudo a2enconf fqdn

#uncomment the following line if you want the info.php to display
#echo "<?php phpinfo();?>" > /var/www/html/info.php

#restart the server to apply changes
sudo service apache2 restart

#######IPtables#######
#for IPtables a white listing approach will be used.

#clear existing rules
sudo iptables -F

#prevent port scan by forcing syn packets on new connections ""source: http://ketan.lithiumfox.com/doku.php/iptables
#sudo iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP

#prevent DOS attack ""source: http://www.thegeekstuff.com/2011/06/iptables-rules-examples/
sudo iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT

#allow DNS traffic out ""source: http://www.thegeekstuff.com/2011/06/iptables-rules-examples/
sudo iptables -A OUTPUT -p udp --dport 53 -j ACCEPT

#allow DNS traffic in ""source: http://www.thegeekstuff.com/2011/06/iptables-rules-examples/
sudo iptables -A INPUT -p udp --sport 53 -j ACCEPT

#allow loopback traffic in ""source: http://www.thegeekstuff.com/2011/06/iptables-rules-examples/
sudo iptables -A INPUT -i lo -j ACCEPT

#allow loopback traffic out ""source: http://www.thegeekstuff.com/2011/06/iptables-rules-examples/
sudo iptables -A OUTPUT -o lo -j ACCEPT

#Limit the number of incoming tcp connections to prevent syn-flood; the following 8 commands are from ""source: http://www.cyberciti.biz/tips/howto-limit-linux-syn-attacks.html
#call new rule syn_flood
sudo iptables -N syn_flood

#in syn comes in send to syn_flood
sudo iptables -A INPUT -p tcp --syn -j syn_flood

#Allows only one syn per secound, if more than limit sent notification for the first three times
sudo iptables -A syn_flood -m limit --limit 1/s --limit-burst 3 -j RETURN

#drops all packets after limit exceeded
sudo iptables -A syn_flood -j DROP

#Limiting the incoming icmp ping request:
sudo iptables -A INPUT -p icmp -m limit --limit  1/s --limit-burst 1 -j ACCEPT

#log the excessive icmp 
sudo iptables -A INPUT -p icmp -m limit --limit 1/s --limit-burst 1 -j LOG --log-prefix PING-DROP:

#drop the icmp packets that break limit
sudo iptables -A INPUT -p icmp -j DROP

#allow out going ping packets
sudo iptables -A OUTPUT -p icmp -j ACCEPT

#the following 6 rules drop XMAS packets and log the scan ""source: https://techhelplist.com/index.php/tech-tutorials/43-linux-adventures/120-nmap-linux-iptables-xmas-packets
#log the all flags xmas-packets
sudo iptables -A INPUT -p tcp --tcp-flags ALL ALL -j LOG --log-prefix "XMAS A: "

#drop the all flags xmas-packets
sudo iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

#log the nmap xmas-packets
sudo iptables -A INPUT -p tcp --tcp-flags ALL FIN,PSH,URG -j LOG --log-prefix "XMAS B: "

#drop the nmap xmas-packets
sudo iptables -A INPUT -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP

#log a third kind xmas-packets
sudo iptables -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG --log-prefix "XMAS C: "

#drop a third kind xmas-packets
sudo iptables -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP

#allow ssh traffic !! I commented the following line because the five rules after it should take care of ssh
#sudo iptables -A INPUT -p tcp --dport ssh -j ACCEPT

#the following 5 rules prevent ssh brute force ""source: http://ketan.lithiumfox.com/doku.php/iptables
#set up a new chaing called brtblk
sudo iptables -N BRTBLK

#send ssh traffic to new chain
sudo iptables -A INPUT -p tcp --dport 22 -m state --state NEW -j BRTBLK

#mark ssh traffic
sudo iptables -A BRTBLK -m recent --set --name SSH

#log bad ip address
sudo iptables -A BRTBLK -m recent --update --seconds 45 --hitcount 5 --name SSH -j LOG --log-level info --log-prefix "Bad IP : "

#if the ip address has more than 4 login attempts in the past 45 secound it is dropped
sudo iptables -A BRTBLK -m recent --update --seconds 45 --hitcount 5 --name SSH -j DROP

#allow traffic web server
sudo iptables -A INPUT -p tcp --sport 80 -j ACCEPT

#allow https traffic
sudo iptables -A INPUT -p tcp --sport 443 -j ACCEPT

#allow mysql traffic in ""source:http://www.cyberciti.biz/tips/linux-iptables-18-allow-mysql-server-incoming-request.html
sudo iptables -A INPUT -p tcp --dport 3306 -m state --state NEW,ESTABLISHED -j ACCEPT

#allow mysql traffic out ""source:http://www.cyberciti.biz/tips/linux-iptables-18-allow-mysql-server-incoming-request.html
sudo iptables -A OUTPUT-p tcp --sport 3306 -m state --state ESTABLISHED -j ACCEPT

#allowing splunk server to run
sudo iptables -A INPUT -p tcp --sport 8000 -s $NETADDR -j ACCEPT
sudo iptables -A INPUT -p tcp --sport 8089 -s $NETADDR -j ACCEPT

#drop all other kinds of traffic
sudo iptables -A INPUT -j DROP

#log dropped packets; source: http://www.thegeekstuff.com/2012/08/iptables-log-packets/
iptables -N LOGGING
iptables -A OUTPUT -j LOGGING
iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables-Dropped: " --log-level 4
iptables -A LOGGING -j DROP

#list the rules
sudo iptables -L

#give write permission to file for save
sudo mkdir /etc/iptables
sudo touch /etc/iptables/rules.v4

#save the rules
sudo iptables-save | sudo tee -a /etc/iptables/rules.v4

##SNORT-SSH-SPLUNK-PULLEDPORK config##

#SSH config edits
#creating back up of ssh config file
echo "[*] Configuring SSH configs..."
sudo cp -p /etc/ssh/sshd_config /etc/ssh/sshd_config.default
sudo chmod a-w /etc/ssh/sshd_config.default
## wanted to set up key auth for ssh server but would take too much user interaction ##
#editing ssh config
sudo sed -i '28s/.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i '64s/.*/X11Forwarding no/' /etc/ssh/sshd_config
echo "UseDNS no" | sudo tee -a /etc/ssh/sshd_config

#configuring snort
# making new user and group so snort won't run under root
echo "[*] Configuring snort."
sudo groupadd snort
sudo useradd snort -r -s /sbin/nologin -c SNORT_IDS -g snort

# making directory for snort rulesets 
sudo mkdir /etc/snort
sudo mkdir /etc/snort/rules
sudo mkdir /etc/snort/preproc_rules
sudo touch /etc/snort/rules/white_list.rules /etc/snort/rules/black_list.rules /etc/snort/rules/local.rules

sudo mkdir /var/log/snort
sudo mkdir /usr/local/lib/snort_dynamicrules

# chaning permissions on snort directories and user ownership
sudo chmod -R 5775 /etc/snort
sudo chmod -R 5775 /var/log/snort
sudo chmod -R 5775 /usr/local/lib/snort_dynamicrules
sudo chown -R snort:snort /etc/snort
sudo chown -R snort:snort /var/log/snort
sudo chown -R snort:snort /usr/local/lib/snort_dynamicrules

# coping config files to the new snort directory
sudo cp ~/snort_src/snort-2.9.7.2/etc/*.conf* /etc/snort
sudo cp ~/snort_src/snort-2.9.7.2/etc/*.map /etc/snort

# editting snort config file
echo "[*] Editing snort config files..."
sudo cp -p /etc/snort/snort.conf /etc/snort/snort.conf.default
SNORTCONFPATH=/etc/snort/snort.conf
#comments out all ruleset file specs because pulled pork will be managing this instead
sudo sed -i 's/include \$RULE\_PATH/#include \$RULE\_PATH/' $SNORTCONFPATH
#subituting default ip addr
#grabs ipaddress from ifconfig, changes host portion of IP to 0 and adds /24 at end
IPADD=$(ifconfig eth0 | grep "inet addr:" | awk -F ":" '{print $2}' | awk '{print $1}')
NETADDR=$(echo $IPADD | sed -e 's/\.[^\.]*$/\.0\/24/')
#replacing any for network ip address variable value
sudo sed -i "s@ipvar HOME_NET any@ipvar HOME_NET $NETADDR@" $SNORTCONFPATH
sudo sed -i 's/ipvar EXTERNAL_NET any/ipvar EXTERNAL_NET \!\$HOME_NET/' $SNORTCONFPATH
#inserting rule path, black and white list paths 
sudo sed -i 's/var RULE_PATH \.\.\/rules/var RULE_PATH \/etc\/snort\/rules/' $SNORTCONFPATH
sudo sed -i 's/var SO_RULE_PATH \.\.\/so_rules/var SO_RULE_PATH \/etc\/snort\/so_rules/' $SNORTCONFPATH
sudo sed -i 's/var PREPROC_RULE_PATH \.\.\/preproc_rules/var PREPRCOC_RULE_PATH \/etc\/snort\/preproc_rules/' $SNORTCONFPATH
sudo sed -i 's/var WHITE_LIST_PATH \.\.\/rules/var WHITE_LIST_PATH \/etc\/snort\/rules/' $SNORTCONFPATH
sudo sed -i 's/var BLACK_LIST_PATH \.\.\/rules/var BLACK_LIST_PATH \/etc\/snort\/rules/' $SNORTCONFPATH

# testing snort config file
function test_config() {
	validation=false
	while [ "$validation" == false ]; do
		$1
		echo "[*] Shouldn't have any errors!"
		echo "If so, press N and edit the config file."
		echo "If successful, press Y and installation will continue."
		read answer
			if [ "$answer" == "Y" ]; then
				validation=true
				echo "[+] Continuing with installation!"
			else 
				echo "[!] Re-edit config file."
				echo "[*] Hit Y when done."
				read editing
				if [ "$editing" == "Y" ]; then
					continue
				fi
			fi
	done
}
test_config 'sudo snort -T -c /etc/snort/snort.conf'

# creating default local rules
#have to be root to edit the rule files due to 't' sticky bit in permissions
echo "alert icmp any any -> $HOME_NET any (msg:"ICMP test"; sid:10000001; rev:001;)" | sudo tee -a /etc/snort/rules/local.rules
test_config 'sudo snort -T -c /etc/snort/snort.conf'

echo "[*] Now editing PulledPork config file..."
#hardcoded oinkcode
OINKCODE=89fc4e97200946e53c217ecfe7fd252220900475
PULLEDPORKPATH=/etc/snort/pulledpork.conf
sudo cp -p /etc/snort/pulledpork.conf /etc/snort/pulledpork.conf.default
#updates root certificates for pulledpork to have access to rules
sudo update-ca-certificates

#inserting oinkcode/API code where needed
sudo sed -i "s@<oinkcode>@$OINKCODE@" $PULLEDPORKPATH
#changing paths to rulesets and configuration files
sudo sed -i '72s/.*/rule_path\=\/etc\/snort\/rules\/snort\.rules/' $PULLEDPORKPATH
sudo sed -i '87s/.*/local_rules\=\/etc\/snort\/rules\/local\.rules/' $PULLEDPORKPATH
sudo sed -i '90s/.*/sid_msg\=\/etc\/snort\/sid\-msg\.map/' $PULLEDPORKPATH
sudo sed -i '117s/.*/config_path\=\/etc\/snort\/snort\.conf/' $PULLEDPORKPATH
sudo sed -i '131s/.*/distro\=Ubuntu\-10\-4/' $PULLEDPORKPATH
sudo sed -i '139s/.*/black_list\=\/etc\/snort\/rules\/iplists\/default\.blacklist/' $PULLEDPORKPATH
sudo sed -i '148s/.*/IPRVersion\=\/etc\/snort\/rules\/iplists/' $PULLEDPORKPATH
sudo sed -i '194s/.*/enablesid\=\/etc\/snort\/enablesid\.conf/' $PULLEDPORKPATH
sudo sed -i '195s/.*/dropsid\=\/etc\/snort\/dropsid\.conf/' $PULLEDPORKPATH
sudo sed -i '196s/.*/disablesid\=\/etc\/snort\/disablesid\.conf/' $PULLEDPORKPATH
sudo sed -i '197s/.*/modifysid\=\/etc\/snort\/modifysid\.conf/' $PULLEDPORKPATH

echo "[*] Checking that PulledPork is configured properly..."
test_config 'sudo /usr/local/bin/pulledpork.pl -c /etc/snort/pulledpork.conf -l'
echo "include \$RULE_PATH/snort.rules" | sudo tee -a /etc/snort/snort.conf

echo "Restarting Snort..."
sudo service snort restart

#apache conf edits
echo "ServerSignature Off" | sudo tee -a /etc/apache2/apache2.conf
echo "ServerTokens Prod" | sudo tee -a /etc/apache2/apache2.conf
#ssl config edit
sudo sed -i 's/SSLProtocol all \-SSLv2/SSLProtocol all \-SSLv2 \-SSLv3/' /etc/apache2/mods-available/ssl.conf
#host conf edit
sudo sed -i 's/order hosts\,bind/order bind\,hosts/' /etc/host.conf
sudo echo "nospoof on" >> /etc/host.conf
#php conf edits
echo "expose_php = Off" | sudo tee -a /etc/php5/apache2/php.ini
sudo service apache2 restart
echo "Done with configurations."

implemntationscript