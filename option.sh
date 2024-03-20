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
    mkdir -p /home/$domain/logs/
    mkdir -p /home/$domain/public_html/
    sudo tee /etc/nginx/conf.d/$domain.conf > /dev/null <<EOF
server {
  listen 80;
  server_name www.$domain;
  rewrite ^(.*) http://$domain$1 permanent;
}

server {
    listen 80;
    add_header Access-Control-Allow-Origin '*' always;
    add_header Access-Control-Allow-Credentials 'true';
    add_header Access-Control-Allow-Methods 'GET, POST, OPTIONS, PUT, DELETE';
    add_header Access-Control-Allow-Headers "*";
    client_max_body_size 30M;  

    # access_log off;
    access_log /home/$domain/logs/access.log;
    # error_log off;
    error_log /home/$domain/logs/error.log;

    root /home/$domain/public_html/public;
    index index.php index.html index.htm;
    server_name $domain;
  
  
    location / {
        try_files $uri $uri/ /index.php?$args;
    }
 
      location ~ \.php$ {
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
          include /etc/nginx/fastcgi_params;
          fastcgi_pass unix:/run/php/php8.1-fpm.sock;
          fastcgi_index index.php;
          fastcgi_connect_timeout 300;
          fastcgi_send_timeout 300;
          fastcgi_read_timeout 300;
          fastcgi_buffer_size 32k;
          fastcgi_buffers 8 16k;
          fastcgi_busy_buffers_size 32k;
          fastcgi_temp_file_write_size 32k;
          fastcgi_intercept_errors on;
          fastcgi_param SCRIPT_FILENAME /home/$domain/public_html/public$fastcgi_script_name;
      }
  
        location ~ /\.(?!well-known).* {
          deny all;
          access_log off;
          log_not_found off;
        }
  
        location = /favicon.ico {
          log_not_found off;
          access_log off;
        }
  
        location = /robots.txt {
          allow all;
          log_not_found off;
          access_log off;
        }
  
        location ~* \.(3gp|gif|jpg|jpeg|png|ico|wmv|avi|asf|asx|mpg|mpeg|mp4|pls|mp3|mid|wav|swf|flv|exe|zip|tar|rar|gz|tgz|bz2|uha|7z|doc|docx|xls|xlsx|pdf|iso|eot|svg|ttf|woff)$ {
          gzip_static off;
          add_header Pragma public;
          add_header Cache-Control "public, must-revalidate, proxy-revalidate";
          access_log off;
          expires 30d;
          break;
        }

        location ~* \.(txt|js|css)$ {
          add_header Pragma public;
          add_header Cache-Control "public, must-revalidate, proxy-revalidate";
          access_log off;
          expires 30d;
          break;
        }
}

EOF
    
    sudo systemctl restart nginx
    echo "Da tao xong domain $domain"
    echo "Thu muc chua code: /home/$domain/public_html"
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
            sudo rm -rf /home/$domain
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
    mkdir -p /home/$domain/logs/
    mkdir -p /home/$domain/public_html/
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
    access_log /home/$domain/logs/access.log;
    error_log /home/$domain/logs/error.log;

    root /home/$domain/public_html;
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
    
    echo "Thu muc chua code: /home/$domain/public_html"
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