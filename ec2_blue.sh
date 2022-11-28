#!/bin/bash

# sleep until instance is ready
#until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
#  sleep 1
#done

# install nginx
sudo apt-get -y update
sudo apt-get -y install nginx
sudo touch /var/www/html/simple-site/index.html
sudo mkdir -p /var/www/html/blue
echo 'Welcome to Blue Instance' >> /var/www/html/simple-site/index.html
sudo cp /var/www/html/simple-site/index.html /var/www/html/index.html
#sudo aws s3 cp s3://${aws_s3_bucket.my-s3-bucket.id}/blue/index.html  /var/www/html/index.html

# make sure nginx is started
sudo service nginx start

#my_ip=$(wget -qO - eth0.me)

#cat > default <<EOF
#server {
#        listen 80 default_server;
#        listen [::]:80 default_server;

#        root /var/www/html;

        # Add index.php to the list if you are using PHP
#        index index.html index.htm index.nginx-debian.html;

#        server_name _;

#        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
#                try_files $uri $uri/ =404;
#        }
#        location /blue {
#        }
#}
#EOF
#sudo cp default /etc/nginx/sites-available/default

sudo service nginx restart 