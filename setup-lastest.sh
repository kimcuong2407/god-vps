#!/bin/bash

# Function to generate a random password
generate_password() {
    openssl rand -base64 16
}

# Capture the server IP
server_ip=$(curl -s https://api.ipify.org)

# Create a new setup overview file
setup_overview_file="overview_setup.txt"
echo "Setup Overview" > "$setup_overview_file"
echo "===============" >> "$setup_overview_file"
echo "Server IP Address: $server_ip" >> "$setup_overview_file"
echo "" >> "$setup_overview_file"

# Modules to be installed
declare -A modules=(
    ["PHP 8.1 and Nginx"]="install_php_nginx"
    ["MariaDB (MySQL)"]="install_mysql"
    ["phpMyAdmin"]="install_phpmyadmin"
    ["Python 3.9"]="install_python"
    ["Node.js 20"]="install_nodejs"
    ["Redis"]="install_redis"
    ["Memcached"]="install_memcached"
    ["Fail2Ban (security)"]="install_fail2ban"
)

# Prompt user for each module
for module in "${!modules[@]}"; do
    read -p "Do you want to install $module? (y/n): " ${modules[$module]}
done

# Display selected modules and confirm
echo -e "\nYou have selected the following modules to install:"
for module in "${!modules[@]}"; do
    [ "${!modules[$module]}" = "y" ] && echo " - $module"
done

read -p "Do you want to proceed with the installation? (y/n): " confirm_install
if [ "$confirm_install" != "y" ]; then
    echo "Installation cancelled."
    exit 0
fi

# Update and upgrade packages
sudo apt update -y && sudo apt upgrade -y

# Remove Apache2 to avoid conflicts with Nginx
echo "Removing Apache2 to avoid conflicts with Nginx..."
sudo systemctl stop apache2
sudo systemctl disable apache2
sudo apt remove apache2 -y
sudo apt purge apache2 -y
sudo apt autoremove -y

# Install prerequisites
sudo apt install software-properties-common curl -y

# Add PHP PPA repository for PHP 8.1
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update -y

# Install selected modules

# PHP 8.1 and Nginx
if [ "$install_php_nginx" = "y" ]; then
    echo "Installing PHP 8.1 and Nginx..."
    sudo apt install nginx php8.1 php8.1-fpm php8.1-{mysql,cli,common,opcache,readline,mbstring,xml,gd,curl,imagick,redis,memcached,zip,intl,bcmath} imagemagick -y

    # Set PHP 8.1 as the default version
    sudo update-alternatives --set php /usr/bin/php8.1

    # Install Composer
    echo "Installing Composer..."
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

    # Configure Cloudflare IP forwarding in Nginx
    sudo tee /etc/nginx/conf.d/cloudflare.conf > /dev/null <<EOL
real_ip_header CF-Connecting-IP;

set_real_ip_from 173.245.48.0/20;
set_real_ip_from 103.21.244.0/22;
set_real_ip_from 103.22.200.0/22;
set_real_ip_from 103.31.4.0/22;
set_real_ip_from 141.101.64.0/18;
set_real_ip_from 108.162.192.0/18;
set_real_ip_from 190.93.240.0/20;
set_real_ip_from 188.114.96.0/20;
set_real_ip_from 197.234.240.0/22;
set_real_ip_from 198.41.128.0/17;
set_real_ip_from 162.158.0.0/15;
set_real_ip_from 104.16.0.0/13;
set_real_ip_from 104.24.0.0/14;
set_real_ip_from 172.64.0.0/13;
set_real_ip_from 131.0.72.0/22;
EOL

    # Restart PHP-FPM and Nginx to apply configurations
    sudo systemctl restart php8.1-fpm nginx
    sudo systemctl enable php8.1-fpm

    echo "PHP 8.1, Nginx, Composer, and Cloudflare IP forwarding configured."
fi

# MariaDB (MySQL)
if [ "$install_mysql" = "y" ]; then
    echo "Installing MariaDB (MySQL)..."
    sudo apt install mariadb-server mariadb-client -y

    # Start and enable MariaDB
    sudo systemctl start mariadb
    sudo systemctl enable mariadb

    # Generate a random password for the MariaDB root user
    root_password=$(generate_password)

    # Set the random password for the root user
    sudo mysql --user=root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY "$root_password";
FLUSH PRIVILEGES;
EOF

    # Add MySQL root password to the overview file
    echo "MySQL root password: $root_password" >> "$setup_overview_file"
    echo "" >> "$setup_overview_file"

    echo "MariaDB installed. Root password set to: $root_password"
    echo "Please save this password securely."
fi

# phpMyAdmin
if [ "$install_phpmyadmin" = "y" ]; then
    echo "Installing phpMyAdmin..."
    sudo apt install phpmyadmin -y
    sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

    # Generate a random password for Basic Auth
    basic_auth_password=$(generate_password)

    # Add phpMyAdmin access link and Basic Auth password to the overview file
    echo "phpMyAdmin access link: http://$server_ip:2023" >> "$setup_overview_file"
    echo "phpMyAdmin Basic Auth password for 'admin': $basic_auth_password" >> "$setup_overview_file"
    echo "" >> "$setup_overview_file"

    # Configure phpMyAdmin in Nginx
    sudo tee /etc/nginx/sites-available/phpmyadmin > /dev/null <<EOL
server {
    listen 2023;
    access_log off;
    log_not_found off;
    root /usr/share/phpmyadmin;
    index index.php index.html index.htm;

    location / {
        auth_basic "Restricted Access";
        auth_basic_user_file /etc/nginx/.htpasswd;
        autoindex on;
        try_files \$uri \$uri/ /index.php;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        include /etc/nginx/fastcgi_params;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    location ~ /\. {
        deny all;
    }
}
EOL

    # Create Basic Auth password file with the generated password for 'admin'
    sudo htpasswd -cb /etc/nginx/.htpasswd admin "$basic_auth_password"

    # Enable the phpMyAdmin configuration and restart Nginx
    sudo ln -s /etc/nginx/sites-available/phpmyadmin /etc/nginx/sites-enabled/
    sudo systemctl restart nginx

    echo "phpMyAdmin installed and configured. Access it at http://$server_ip:2023"
fi

# Python 3.9
[ "$install_python" = "y" ] && sudo apt install python3.9 python3.9-venv python3.9-dev -y && echo "Python 3.9 installed."

# Node.js 20
if [ "$install_nodejs" = "y" ]; then
    echo "Installing Node.js 20..."
    curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install nodejs -y
    echo "Node.js 20 installed."
fi

# Redis
[ "$install_redis" = "y" ] && sudo apt install redis-server -y && sudo systemctl enable redis-server && echo "Redis installed and enabled."

# Memcached
[ "$install_memcached" = "y" ] && sudo apt install memcached -y && sudo systemctl enable memcached && echo "Memcached installed and enabled."

# Fail2Ban
if [ "$install_fail2ban" = "y" ]; then
    echo "Installing Fail2Ban..."
    sudo apt install fail2ban -y
    sudo tee /etc/fail2ban/jail.local > /dev/null <<EOL
[sshd]
enabled  = true
port     = ssh
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 5
bantime  = 3600

[nginx-http-auth]
enabled  = true
filter   = nginx-http-auth
port     = http,https
logpath  = /var/log/nginx/error.log
maxretry = 5
bantime  = 3600
EOL
    sudo systemctl restart fail2ban
    sudo systemctl enable fail2ban
    echo "Fail2Ban installed and configured for SSH and Nginx."
fi

# Install and configure UFW
echo "Installing UFW..."
sudo apt install ufw -y

# Allow necessary ports
echo "Configuring UFW..."
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
[ "$install_mysql" = "y" ] && sudo ufw allow 3306
[ "$install_phpmyadmin" = "y" ] && sudo ufw allow 2023
[ "$install_nodejs" = "y" ] && sudo ufw allow 3000
sudo ufw enable

echo "UFW installed and configured."

echo "Setup completed. Overview available in $setup_overview_file"

# Reinstall option
echo -e "\nTo reinstall, please run this script again with the appropriate modules selected."
