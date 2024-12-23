#!/bin/bash


sudo apt update -y
sudo apt install -y lsb-release ca-certificates apt-transport-https software-properties-common

# Add PHP repository
sudo add-apt-repository ppa:ondrej/php -y

# Update package lists again after adding the new repository
sudo apt update -y

# Install PHP 8.2 and necessary extensions
sudo apt install -y nginx php8.2 php8.2-fpm php8.2-mysql php-common php8.2-cli php8.2-common php8.2-opcache php8.2-readline php8.2-mbstring php8.2-xml php8.2-gd php8.2-curl php8.2-imagick php8.2-redis php8.2-memcached

# Define the configuration file path
php_ini_path="/etc/php/8.2/fpm/php.ini"

# Define the new values
new_upload_max_filesize="200M"
new_post_max_size="48M"
new_memory_limit="2048M"
new_max_execution_time="600"
new_max_input_vars="3000"
new_max_input_time="1000"

# Use sed to replace values in the PHP configuration file
sudo sed -i "s/^upload_max_filesize = .*/upload_max_filesize = $new_upload_max_filesize/" $php_ini_path
sudo sed -i "s/^post_max_size = .*/post_max_size = $new_post_max_size/" $php_ini_path
sudo sed -i "s/^memory_limit = .*/memory_limit = $new_memory_limit/" $php_ini_path
sudo sed -i "s/^max_execution_time = .*/max_execution_time = $new_max_execution_time/" $php_ini_path
sudo sed -i "s/^max_input_vars = .*/max_input_vars = $new_max_input_vars/" $php_ini_path
sudo sed -i "s/^max_input_time = .*/max_input_time = $new_max_input_time/" $php_ini_path

# Restart PHP-FPM service
sudo systemctl restart php8.2-fpm

# Enable PHP-FPM to start on boot
sudo systemctl enable php8.2-fpm

# Check the status of PHP-FPM
sudo systemctl status php8.2-fpm


curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
sudo bash mariadb_repo_setup --os-type=ubuntu --os-version="jammy" --mariadb-server-version=10.6 -y
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt install mariadb-server mariadb-client -y

sudo systemctl start mariadb
sudo systemctl enable mariadb

# Allow Nginx traffic
sudo ufw allow 'Nginx Full'



# Install UFW (if not already installed)
sudo apt-get install ufw -y

# Enable UFW
sudo ufw enable

# Allow SSH traffic on the default port (optional, if not already allowed)
sudo ufw allow ssh

# Change the SSH port to 2222
sudo sed -i 's/#Port .*/Port 2222/' /etc/ssh/sshd_config

# Allow SSH traffic on the new port
sudo ufw allow 2222

# Reload UFW to apply the changes
sudo ufw reload

# Restart the SSH service to apply the new port


sudo apt install fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local

sudo systemctl enable fail2ban
sudo systemctl start fail2ban



#!/bin/bash

# Define the Fail2Ban configuration file path
fail2ban_config="/etc/fail2ban/jail.local"

# Create the Fail2Ban configuration
sudo tee $fail2ban_config > /dev/null <<EOL
[sshd]
enabled  = true
filter   = sshd
action   = ufw
logpath  = /var/log/auth.log
maxretry = 5
bantime  = 3600

[nginx-http-auth]
enabled  = true
filter   = nginx-http-auth
action   = ufw
logpath  = /home/fastpod.net/logs/nginx_error.log
maxretry = 5
bantime  = 3600
EOL

# Enable UFW rules for SSH and Nginx ports
sudo ufw allow 2222/tcp
sudo ufw allow 2022/tcp
sudo ufw reload

# Restart Fail2Ban to apply the changes
sudo systemctl restart fail2ban

echo "Fail2Ban has been configured successfully with UFW!"

sudo apt install phpmyadmin -y

# Create a symbolic link to the phpMyAdmin installation directory
sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# Get the server's public IP address using curl
my_ip=$(curl -s https://api64.ipify.org)

# Set the obtained IP address in the Nginx configuration
sudo tee /etc/nginx/sites-available/phpmyadmin > /dev/null <<EOL
    server {
            listen 2023;
            access_log /var/log/nginx/phpmyadmin/access.log;
            error_log /var/log/nginx/phpmyadmin/error.log;



            root /usr/share/phpmyadmin;
            index index.php index.html index.htm;


            location / {
                        try_files $uri $uri/ /index.php?$args;
            }

                location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                include fastcgi_params;
            }



            location ~ /\. {
                    deny all;
            }
        }
EOL

# Create a symbolic link to enable the new configuration
sudo ln -s /etc/nginx/sites-available/phpmyadmin /etc/nginx/sites-enabled/

# Restart Nginx to apply the changes
sudo systemctl restart nginx

echo "phpMyAdmin has been installed and configured. Access it at http://$my_ip/phpmyadmin"


sudo systemctl restart ssh

# install python
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt install python3.9 -y

#install node 20
sudo curl -sL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt install nodejs

// install composer
sudo apt install php-cli unzip
cd ~
curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
HASH=`curl -sS https://composer.github.io/installer.sig`
php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer