#!/bin/bash

sudo apt update -y
sudo apt install -y lsb-release ca-certificates apt-transport-https software-properties-common

# Add PHP repository
sudo add-apt-repository ppa:ondrej/php -y

# Update package lists again after adding the new repository
sudo apt update -y

# Install PHP 8.2 and necessary extensions
sudo apt install -y nginx php8.2 php8.2-fpm php8.2-mysql php-common php8.2-cli php8.2-common php8.2-opcache php8.2-readline php8.2-mbstring php8.2-xml php8.2-gd php8.2-curl php8.2-imagick php8.2-redis php8.2-memcached php8.2-zip php8.2-bcmath

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

# Cài đặt CSF
cd /usr/src
sudo rm -fv csf.tgz
sudo wget https://download.configserver.com/csf.tgz
sudo tar -xzf csf.tgz
cd csf
sudo sh install.sh

# Cấu hình CSF (ConfigServer Firewall)

# Tắt chế độ TESTING để CSF hoạt động thực tế (0 = tắt chế độ test, 1 = bật chế độ test)
sudo sed -i 's/TESTING = "1"/TESTING = "0"/' /etc/csf/csf.conf

# Giới hạn truy cập syslog (3 = chỉ cho phép localhost truy cập)
sudo sed -i 's/RESTRICT_SYSLOG = "0"/RESTRICT_SYSLOG = "3"/' /etc/csf/csf.conf

# Kiểm tra syslog mỗi 300 giây để phát hiện các mối đe dọa
sudo sed -i 's/SYSLOG_CHECK = "0"/SYSLOG_CHECK = "300"/' /etc/csf/csf.conf

# Bật giám sát cho tất cả người dùng (1 = bật, 0 = tắt)
sudo sed -i 's/PT_ALL_USERS = "0"/PT_ALL_USERS = "1"/' /etc/csf/csf.conf

# Giới hạn bộ nhớ tối đa cho mỗi người dùng (250MB)
sudo sed -i 's/PT_USERMEM = "200"/PT_USERMEM = "250"/' /etc/csf/csf.conf

# Giới hạn thời gian chạy tối đa cho mỗi tiến trình (900 giây = 15 phút)
sudo sed -i 's/PT_USERTIME = "1800"/PT_USERTIME = "900"/' /etc/csf/csf.conf

# Tắt tính năng tự động kill tiến trình của người dùng (0 = tắt, 1 = bật)
sudo sed -i 's/PT_USERKILL = "1"/PT_USERKILL = "0"/' /etc/csf/csf.conf

# Giới hạn tải hệ thống tối đa (30)
sudo sed -i 's/PT_LOAD = "30"/PT_LOAD = "30"/' /etc/csf/csf.conf

# Số lõi CPU được tính trong giới hạn tải (5)
sudo sed -i 's/PT_LOAD_AVG = "5"/PT_LOAD_AVG = "5"/' /etc/csf/csf.conf

# Khoảng thời gian kiểm tra tải hệ thống (300 giây = 5 phút)
sudo sed -i 's/PT_INTERVAL = "60"/PT_INTERVAL = "300"/' /etc/csf/csf.conf

# Tắt tính năng phát hiện deadlock (0 = tắt, 1 = bật)
sudo sed -i 's/PT_DEADLOCK = "1"/PT_DEADLOCK = "0"/' /etc/csf/csf.conf

# Mức độ tải hệ thống để kích hoạt cảnh báo (6)
sudo sed -i 's/PT_LOAD_LEVEL = "6"/PT_LOAD_LEVEL = "6"/' /etc/csf/csf.conf

# Bỏ qua kiểm tra tải trong 15 phút sau khi khởi động lại
sudo sed -i 's/PT_LOAD_SKIP = "15"/PT_LOAD_SKIP = "15"/' /etc/csf/csf.conf

# Bỏ qua swap khi tính toán tải hệ thống
sudo sed -i 's/PT_LOAD_IGNORE = "swap"/PT_LOAD_IGNORE = "swap"/' /etc/csf/csf.conf

# Bật báo cáo mở rộng (1 = bật, 0 = tắt)
sudo sed -i 's/PT_EXT_REPORT = "0"/PT_EXT_REPORT = "1"/' /etc/csf/csf.conf

# Giới hạn số tiến trình tối đa cho mỗi người dùng (10)
sudo sed -i 's/PT_USERPROC = "10"/PT_USERPROC = "10"/' /etc/csf/csf.conf


# Cấu hình ports cho các dịch vụ
sudo sed -i 's/TCP_IN = "20,21,22,25,53,80,110,143,443,465,587,993,995,2222,2022,2023"/TCP_IN = "20,21,22,25,53,80,110,143,443,465,587,993,995,2222,2022,2023"/' /etc/csf/csf.conf
sudo sed -i 's/TCP_OUT = "20,21,22,25,53,80,110,113,443,587,993,995,2222,2022,2023"/TCP_OUT = "20,21,22,25,53,80,110,113,443,587,993,995,2222,2022,2023"/' /etc/csf/csf.conf

# Khởi động CSF
sudo csf -r

# Cài đặt fail2ban
sudo apt install fail2ban -y
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Cấu hình fail2ban
sudo tee /etc/fail2ban/jail.local > /dev/null <<EOL
[sshd]
enabled  = true
filter   = sshd
action   = csf
logpath  = /var/log/auth.log
maxretry = 5
bantime  = 3600

[nginx-http-auth]
enabled  = true
filter   = nginx-http-auth
action   = csf
logpath  = /home/fastpod.net/logs/nginx_error.log
maxretry = 5
bantime  = 3600
EOL

sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Cài đặt phpMyAdmin
sudo apt install phpmyadmin -y
sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# Cấu hình Nginx cho phpMyAdmin
my_ip=$(curl -s https://api64.ipify.org)
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
                fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                include fastcgi_params;
            }

            location ~ /\. {
                    deny all;
            }
        }
EOL

sudo ln -s /etc/nginx/sites-available/phpmyadmin /etc/nginx/sites-enabled/
sudo systemctl restart nginx

# Cài đặt Python 3.9
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt install python3.9 -y

# Cài đặt Node.js 20
sudo curl -sL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt install nodejs -y

# Cài đặt Composer
sudo apt install php-cli unzip -y
cd ~
curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
HASH=`curl -sS https://composer.github.io/installer.sig`
php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer