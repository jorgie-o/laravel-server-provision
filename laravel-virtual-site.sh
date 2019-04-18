#!/bin/bash

domain=$1
www_folder="/var/www/"
root="$www_folder$domain"
block="/etc/nginx/sites-available/$domain"
uri="uri"
query_string="query_string"
ip="127.0.0.1"
host_line="$ip\t$domain"
etc_hosts=/etc/hosts


# Create the Document Root directory
# sudo mkdir -p $root
sudo mkdir -p $root
# Assign ownership to your www-data user
sudo chown -R www-data:www-data "$www_folder$domain"

# Create the Nginx server block file:
sudo tee $block > /dev/null <<EOF

server {
        listen 80;
        listen [::]:80;

        root $root/public;

        # Add index.php to the list if you are using PHP
        index index.html index.htm index.nginx-debian.html index.php;

        server_name $domain;

        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                try_files \$$uri \$$uri/ /index.php?\$$query_string;
        }

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                # With php7.0-cgi alone:
                fastcgi_pass 127.0.0.1:9000;
                # With php7.0-fpm:
                # fastcgi_pass unix:/run/php/php7.0-fpm.sock;
        }

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        location ~ /\.ht {
                deny all;
        }
}


EOF

#Adding hostname entry to hosts file /etc/hosts

    if [ -n "$(grep $domain /etc/hosts)" ]
        then
            echo "$domain already exists : $(grep $domain $etc_hosts)"
        else
            echo "Adding $domain to your $etc_hosts";
            sudo -- sh -c -e "echo '$host_line' >> /etc/hosts";

            if [ -n "$(grep $domain /etc/hosts)" ]
                then
                    echo "$domain was added succesfully";
                else
                    echo "Failed to Add $domain, Try again!";
            fi
    fi

# Link to make it available
sudo ln -s $block /etc/nginx/sites-enabled/

# Test configuration and reload if successful
sudo nginx -t && sudo service nginx reload
