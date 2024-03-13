#!/bin/bash

# Function to show the menu
show_menu() {
    echo "Choose an option:"
    echo "1) Them moi domain backend Laravel"
    echo "2) Xoa domain khoi server"
    echo "3) Them domain frontend"
    echo "4) Exit"
}

# Function for option 1
addDomainBackend() {
    echo "Nhap ten mien di:"
    read -p "Ten mien: " domain
    # Insert your command for option 1 here
    mkdir -p /var/www/$domain/logs/
    mkdir -p /var/www/$domain/public_html/
    sudo tee /etc/nginx/conf.d/$domain.conf > /dev/null <<EOF
server {
    listen 80;
    server_name $domain;
    access_log /var/www/$domain/logs/access.log;
    error_log /var/www/$domain/logs/error.log;

    root /var/www/$domain/public_html/public;
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
EOF
    
    sudo systemctl restart nginx
    echo "Da tao xong domain $domain"
    echo "Thu muc chua code: /var/www/$domain/public_html"
}

# Function for option 2
deleteDomain() {
    echo "Ten mien muon xoa:"
    read -p "Ten mien: " domain
    echo "Muon xoa that chu:"
    read -p "Ban muon xoa: (Y/y)" confirm
    case $confirm in
        [Yy]* )
            sudo rm /etc/nginx/conf.d/$domain.conf
            sudo systemctl restart nginx
            sudo rm -rf /var/www/$domain
            echo "Da xoa xong domain $domain"
        ;;
        * )
            echo "Quá trình bị hủy."
            exit 1
        ;;
    esac
    
}

# Function for option 3
addDomainFrontend() {
    echo "Nhap ten mien di:"
    read -p "Ten mien: " domain
    mkdir -p /var/www/$domain/logs/
    mkdir -p /var/www/$domain/public_html/
    # Insert your command for option 1 here
    sudo tee /etc/nginx/conf.d/$domain.conf > /dev/null <<EOF
server {
  listen 80;
  server_name www.$domain;
  rewrite ^(.*) http://$domain$1 permanent;
}


server {
    listen 80;
    server_name $domain;
    access_log /var/www/$domain/logs/access.log;
    error_log /var/www/$domain/logs/error.log;

    root /var/www/$domain/public_html;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.html?$args;
    }
    
    location @rewrites {
        rewrite ^(.+)$ /index.html last;
    }
}

EOF
    sudo systemctl restart nginx
    echo "Da tao xong domain $domain"
    
    echo "Thu muc chua code: /var/www/$domain/public_html"
    # Insert your command for option 3 here
}

# Main loop
while true; do
    show_menu
    read -p "Enter your choice [1-4]: " choice
    case "$choice" in
        1) addDomainBackend ;;
        2) deleteDomain ;;
        3) addDomainFrontend ;;
        4) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid option: $choice";;
    esac
done