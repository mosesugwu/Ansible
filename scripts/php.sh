
#!/bin/bash
set -x

Repository="https://github.com/mosesugwu/terraform-projects.git"
path="/mnt/c/Users/UGWU MOSES C/Desktop/TSR-ASSIGNMENTS/Cloud-Engineer-Cohort-September-2023/Ansible/php-mysql-app*"
db_user="root"
db_secrets="mosesugwu"
db_name="demo"
php_path="/var/www/html"
linux_user="mosesugwu"

if [ -z "$Repository" ] || [ -z "$path" ] || [ -z "$db_user" ] || [ -z "$db_secrets" ] || [ -z "$db_name" ] || [ -z "$php_path" ] || [ -z "$linux_user" ];then
   echo "All expected variables have not be declared, Please pass the values for the variables"
   exit 1
fi

# Install software
sudo apt -y update
sudo apt-get -y install expect
sudo apt -y install php libapache2-mod-php php-mysql

until sudo apt install -y apache2; do
  echo "Installation failed, But trying again in 5sec"
  sleep 5
done
echo "Apache service successfully installed"

until sudo apt install -y mysql-server; do
  echo "Installation failed, But trying again in 5sec"
  sleep 5
done
echo "MySQL service successfully installed"

export MYSQL_PWD='$db_secrets'
sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$db_secrets';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON data.* TO 'root'@'localhost';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"
unset MYSQL_PWD

# Change permissions
sudo chown -R $linux_user:$linux_user /var/www/html/*
sudo find /var/www -type d -exec chmod 755 {} \;

# Start Services
echo "Starting Apache Web app & MySQL DB"
sudo systemctl start apache2  && sudo systemctl start mysql.service 

echo "Using Expect to run MySQL secure installations"
set timeout 120
expect << EOF
spawn sudo mysql_secure_installation
expect "Enter password for user root: "
send "$db_secrets\r"

expect "Would you like to setup VALIDATE PASSWORD component?"
send "y\r"

expect "Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG: "
send "1\r"

expect "Change the password for root ?"
send "n\r"

expect "Remove anonymous users?"
send "y\r"

expect "Disallow root login remotely?"
send "y\r"

expect "Remove test database and access to it?"
send "y\r"

expect "Reload privilege tables now?"
send "y\r"
EOF

git clone $Repository
sudo cp -r $path $php_path && sudo chown $linux_user:$linux_user -R $php_path && cd $php_path
sed -i '1i\create database demo; \nuse demo;' database.sql
sed -i 's/username/db_user/g' db.php
sed -i 's/password/db_secrets/g' db.php
sed -i 's/database/db_name/g' db.php
sudo mysql -u "$db_user" "-p$db_secrets" < "database.sql"

sudo rm /etc/apache2/sites-available/000-default.conf && sudo rm /etc/apache2/sites-available/default-ssl.conf
sudo mv /tmp/moluskatopnotch.link.crt /etc/ssl/certs/ssl-cert-moluskatopnotch.link.crt
sudo mv /tmp/moluskatopnotch.link_key.txt /etc/ssl/private/ssl-cert-moluskatopnotch.link.key

# Update certificate in Apache server
echo "Updating certificate for HTTPS"
sudo bash -c 'cat > /etc/apache2/sites-available/moluskatopnotch.conf <<EOF
  <VirtualHost *:80>
    ServerName moluskatopnotch.link
    ServerAlias *.moluskatopnotch.link
    Redirect permanent / https://www.moluskatopnotch.link/
  </VirtualHost>

  <VirtualHost *:443>
    DocumentRoot /var/www/html/
    ServerName www.moluskatopnotch.link
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/ssl-cert-moluskatopnotch.link.crt
    SSLCertificateKeyFile /etc/ssl/private/ssl-cert-moluskatopnotch.link.key
  </VirtualHost>
EOF'

# Enable HTTPS
cd /etc/apache2/sites-available/
sudo a2ensite moluskatopnotch.conf
sudo a2enmod ssl
sudo apache2ctl configtest
sudo systemctl reload apache2
sudo systemctl restart mysql