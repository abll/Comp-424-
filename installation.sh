#!/bin/bash

#this part is used to install the tools used for the LAMP stack and its security 
#update
sudo apt-get update
sudo apt-get upgrade -y

#give the root password when prompted during the mysql-server install
sudo deconf-set-selections <<< 'mysql-server mysql-server/root_password password QWERasdf1234'

#give the root password when prompted again during the mysql-server install
sudo deconf-set-selections <<< 'mysql-server mysql-server/root_password_again password QWERasdf1234'

#install Apache, MYSQL, PHP
sudo apt-get -y install lamp-server^

#make sure that firewall rules are applied when the server boots
sudo apt-get install iptables-persistent

#pulling scripts from github repo
sudo apt-get install git
git clone https://github.com/abll/Comp-424-.git
#get Website branch on git or copy and paste the ZIP to desktop
cd ~/Desktop/Comp-424-
git fetch
git checkout Website
cd Website
sudo mv "424 Site" /var/www/html

#buiding SQL database
mysql -u root -p < "Comp-424-/Website/424 Database/userdatabaseUpdated.sql"

#changing hostname of server
sudo hostname comp424server
sudo sed -i 's/ubuntu/comp424server/' /etc/hosts
sudo sed -i 's/ubuntu/comp424server/' /etc/hostname

#SSL portion
sudo cp -p /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf.old
sudo apt-get install openssl
sudo mkdir /etc/apache2/ssl
sudo openssl genrsa -out "/etc/apache2/ssl/424.key" 2048
sudo openssl req -new -key "/etc/apache2/ssl/424.key" \
                 -out "/etc/apache2/ssl/424.csr"
sudo openssl x509 -req -days 365 -in "/etc/apache2/ssl/424.csr" \
                  -signkey "/etc/apache2/ssl/424.key"  \
                  -out "/etc/apache2/ssl/424.crt"
sudo a2enmod ssl
sudo a2enmod rewrite
sudo service apache2 restart

echo "<VirtualHost *:80>
ServerAdmin webmaster@yourdomain.com
DocumentRoot "/var/www/html/424 Site"
ServerName comp424server
DirectoryIndex "login page.html"
ErrorLog /var/log/apache2/error.log
<Location />
RewriteEngine on
RewriteCond %{HTTPS} off
RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R]
</Location>
</VirtualHost>

<VirtualHost *:443>
ServerAdmin webmaster@yourdomain.com
DocumentRoot "/var/www/html/424 Site"
ServerName comp424server
DirectoryIndex "login page.html"
ErrorLog /var/log/apache2/error.log
CustomLog /var/log/apache2/access.log combined
SSLEngine On
SSLCertificateFile /etc/apache2/ssl/424.crt
SSLCertificateKeyFile /etc/apache2/ssl/424.key
<Location />
SSLRequireSSL On
SSLVerifyClient optional
SSLVerifyDepth 1
SSLOptions +StdEnvVars +StrictRequire
</Location>
</VirtualHost>" | sudo tee -a /etc/apache2/apache2.conf

sudo service apache2 reload
sudo service apache2 restart

#this part is used to install snort, openSSH, pulledpork and splunk along with it's dependencies 

echo "[+] Installing OpenSSH..."
sudo apt-get install -y openssh-server

#network card config so that packets won't be resambled before reaching snort service
echo "[+] Installing snort prereqs..."
sudo apt-get install -y ethtool
sudo ethtool -K eth0 gro off
sudo ethtool -K eth0 lro off
sudo apt-get install -y build-essential
sudo apt-get install -y libpcap-dev libpcre3-dev libdumbnet-dev
mkdir ~/snort_src
cd ~/snort_src
sudo apt-get install -y bison flex
wget https://www.snort.org/downloads/snort/daq-2.0.4.tar.gz
tar -xvzf daq-2.0.4.tar.gz
cd daq-2.0.4
./configure
make 
sudo make install 

echo "[+] Installing Snort..."
sudo apt-get install -y zlib1g-dev
cd ~/snort_src
wget https://www.snort.org/downloads/snort/snort-2.9.7.2.tar.gz
tar -xvzf snort-2.9.7.2.tar.gz
cd snort-2.9.7.2
./configure --enable-sourcefire
make
sudo make install
sudo ldconfig
sudo ln -s /usr/local/bin/snort /usr/sbin/snort
snort -V
echo "[*] Done installing Snort."

echo "[+] Installing PulledPork prereqs..."
sudo apt-get install -y libcrypt-ssleay-perl liblwp-useragent-determined-perl
echo "[+] Installing PulledPork..."
cd ~/snort_src
wget https://pulledpork.googlecode.com/files/pulledpork-0.7.0.tar.gz
tar xvfvz pulledpork-0.7.0.tar.gz
cd pulledpork-0.7.0/
sudo cp pulledpork.pl /usr/local/bin
sudo chmod ug+x /usr/local/bin/pulledpork.pl
sudo cp etc/*.conf /etc/snort
sudo mkdir /etc/snort/rules/iplists
sudo touch /etc/snort/rules/iplists/default.blacklist

echo "[*] Checking that PulledPork has been installed..."
/usr/local/bin/pulledpork.pl -V
sleep 2

echo "[+] Installing Splunk..."
wget -O splunklight-6.2.2-255606-linux-2.6-amd64.deb 'http://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=Linux&version=6.2.2&product=splunk_light&filename=splunklight-6.2.2-255606-linux-2.6-amd64.deb&wget=true'
sudo dpkg -i splunklight-6.2.2-255606-linux-2.6-amd64.deb
cd /opt/splunk/bin
sudo ./splunk start --accept-license
echo "[i] Default username is: admin"
echo "[i] Default password is: changeme"
echo "[i] Use this for now, but change later!"
echo "[*] Adding in file inputs."
sudo ./splunk add monitor /var/log/syslog
sudo ./splunk add monitor /var/log/snort/
sudo ./splunk add monitor /var/log/auth.log
sudo ./splunk add monitor /var/log/dmesg
sudo ./splunk add monitor /var/log/mysql.err
sudo ./splunk add monitor /var/log/mysql.log
sudo ./splunk add monitor /var/log/mysql/error.log
sudo ./splunk add monitor /var/log/apache2/error.log
sudo ./splunk add monitor /var/log/apache2/acess.log
sudo ./splunk add monitor /var/log/apache2/other_vhosts_access.log
sudo ./splunk enable boot-start


#Enabling all services to autostart on boot
echo "[*] Creating startup script to ensure all services run at machine startup!"
echo $'description "Snort NIDS Service"
stop on runlevel [!2345]
start on runlevel [2345]
script
     exec /usr/local/bin/snort -q -u snort -g snort -c /etc/snort/snort.conf -i eth0 -D
end script' | sudo tee -a /etc/init/snort.conf

sudo chmod ug+x /etc/init/snort.conf
echo "[*] Checking if snort service exists..."
sudo initctl list | grep snort

echo "[*] Making cron for PulledPork..."
crontab -l > crontablist
echo "01 04 * * * /usr/local/bin/pulledpork.pl -c /etc/snort/pulledpork.conf -l" >> crontablist
crontab crontablist

echo "Rebooting machine..."
echo "Check that the snort and splunk services are running on startup."
sleep 2
#securing shared memory 
echo "tmpfs     /dev/shm     tmpfs     defaults,noexec,nosuid     0     0" >> /etc/fstab
sudo reboot