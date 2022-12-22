#!/bin/bash

sudo apt-get update 
sudo apt -y install apache2 php libapache2-mod-php


echo '<!doctype html><html><body><h1>If you see this apache running successfully!</h1></body></html>' | sudo tee /var/www/html/index.html

sudo apt install wget unzip
latest=$(curl --silent https://www.phpmyadmin.net/ | grep href | grep files | head -n 1 | sed 's/.*href=//g; s/"//g' |  awk '{ print $1 }')
wget $latest
unzip phpMyAdmin*
rm -rf phpMyAdmin*.zip
sudo mv phpMyAdmin* /usr/share/phpmyadmin
sudo chown -R www-data:www-data /usr/share/phpmyadmin

sudo apt install -y php-imagick php-phpseclib php-php-gettext php7.3-common php7.3-gd php7.3-imap php7.3-json php7.3-curl php7.3-zip php7.3-xml php7.3-mbstring php7.3-bz2 php7.3-intl php7.3-gmp

cd /etc/apache2/conf-available/
sudo a2disconf phpmyadmin.conf 
sleep 2
sudo systemctl reload apache2
echo "# phpMyAdmin default Apache configuration
Alias /phpmyadmin /usr/share/phpmyadmin
<Directory /usr/share/phpmyadmin>
    Options SymLinksIfOwnerMatch
    DirectoryIndex index.php
    <IfModule mod_php5.c>
        <IfModule mod_mime.c>
            AddType application/x-httpd-php .php
        </IfModule>
        <FilesMatch ".+\.php$">
            SetHandler application/x-httpd-php
        </FilesMatch>
        php_value include_path .
        php_admin_value upload_tmp_dir /var/lib/phpmyadmin/tmp
        php_admin_value open_basedir /usr/share/phpmyadmin/:/etc/phpmyadmin/:/var/lib/phpmyadmin/:/usr/share/php/php-gettext/:/usr/share/php/php-php-gettext/:/usr/share/javascript/:/usr/share/php/tcpdf/:/usr/share/doc/phpmyadmin/:/usr/share/php/phpseclib/
        php_admin_value mbstring.func_overload 0
    </IfModule>
    <IfModule mod_php.c>
        <IfModule mod_mime.c>
            AddType application/x-httpd-php .php
        </IfModule>
        <FilesMatch ".+\.php$">
            SetHandler application/x-httpd-php
        </FilesMatch>
        php_value include_path .
        php_admin_value upload_tmp_dir /var/lib/phpmyadmin/tmp
        php_admin_value open_basedir /usr/share/phpmyadmin/:/etc/phpmyadmin/:/var/lib/phpmyadmin/:/usr/share/php/php-gettext/:/usr/share/php/php-php-gettext/:/usr/share/javascript/:/usr/share/php/tcpdf/:/usr/share/doc/phpmyadmin/:/usr/share/php/phpseclib/
        php_admin_value mbstring.func_overload 0
    </IfModule>
</Directory>
# Disallow web access to directories that don't need it
<Directory /usr/share/phpmyadmin/templates>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/libraries>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/setup/lib>
    Require all denied
</Directory>" | sudo tee /etc/apache2/conf-available/phpmyadmin.conf

# Create temp folder.
sudo mkdir -p /var/lib/phpmyadmin/tmp
sudo chown www-data:www-data /var/lib/phpmyadmin/tmp
sudo cp /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php 

sudo apt-get update -y
sudo apt-get install -y htop mariadb-server php php-mysql

sudo systemctl start mariadb
sudo systemctl enable mariadb

sudo mysql<<EOF
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
CREATE USER 'dbuser'@'localhost' IDENTIFIED BY '12345678Qw!';
GRANT ALL PRIVILEGES ON *.* TO 'dbuser'@'localhost' IDENTIFIED BY '12345678Qw!';
DELETE FROM mysql.user WHERE User='';
FLUSH PRIVILEGES;
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
FLUSH PRIVILEGES;
EOF

sudo tee -a /etc/mysql/my.cnf <<EOF
[mysqld]
bind-address = 0.0.0.0
EOF

sudo systemctl restart mariadb

sudo sed -i "s/;extension=mysqli/extension=mysqli/" /etc/php/7.3/apache2/php.ini

cd /etc/apache2/conf-available/
sudo a2enconf phpmyadmin.conf 
sleep 2
sudo systemctl reload apache2