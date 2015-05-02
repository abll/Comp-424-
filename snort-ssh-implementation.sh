#!/bin/bash

#SSH config edits
#creating back up of ssh config file
echo "[*] Configuring SSH configs..."
sudo cp -p /etc/ssh/sshd_config /etc/ssh/sshd_config.default
sudo chmod a-w /etc/ssh/sshd_config.default
## wanted to set up key auth for ssh server but would take too much user interaction ##
#editing ssh config
sudo sed -i '28s/.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i '64s/.*/X11Forwarding no/' /etc/ssh/sshd_config

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
echo "Done with configurations."