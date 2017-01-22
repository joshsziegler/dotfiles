sudo apt install apache2
sudo mkdir -p /var/www/zglr.org/
sudo chown -R josh:josh /var/www/zglr.org/ # Allow non-root to write to this directory
sudo chmod -R 755 /var/www # Allow others to list this directory
echo 'Hello World!' > /var/www/zglr.org/index.html # Test file
#<VirtualHost *:80>
#ServerAdmin webmaster@localhost
#ServerName zglr.org
#ServerAlias www.zglr.org
#DocumentRoot /var/www/zglr.org/
#ErrorLog ${APACHE_LOG_DIR}/error.log
#CustomLog ${APACHE_LOG_DIR}/access.log combined
#</VirtualHost>
sudo vim /etc/apache2/sites-available/zglr.org.conf 
sudo a2ensite zglr.org.conf # Enable the new site config
sudo service apache2 reload 

sudo apt install python-letsencrypt-apache
sudo letsencrypt --apache -d zglr.org 
sudo vim /etc/apache2/sites-available/zglr.org.conf 
sudo vim /etc/apache2/sites-available/zglr.org-le-ssl.conf 
sudo crontab -e
sudo letsencrypt renew

# Setup Secure Dir Using Basic Auth and File Backend
sudo apt install apache2-utils
# Setup your new password file (leave off the -c to add a user to an existing
# file)
sudo htpasswd -c /etc/apache2/.htpasswd josh
# The following needs to go into the apache config for your secure dir
#<Directory "/var/www/zglr.org/s/">
#AuthType Basic
#AuthName "Restricted Content"
#AuthUserFile /etc/apache2/.htpasswd
#Require valid-user # alternatively, specify exact users
#</Directory>
sudo vim /etc/apache2/sites-available/zglr.org-le-ssl.conf
sudo apache2ctl configtest
sudo systemctl restart apache2

