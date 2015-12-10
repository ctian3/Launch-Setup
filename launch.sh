#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y apache2 git php5 php5-curl mysql-client curl php5-mysql php5-imagick

git clone https://github.com/ctian3/Application-Setup.git

mv ./Application-Setup/images /var/www/html/images
mv ./Application-Setup/index.html /var/www/html
mv ./Application-Setup/page2.html /var/www/html
mv ./Application-Setup/*.php /var/www/html

curl -sS https://getcomposer.org/installer | sudo php &> /tmp/getcomposer.txt

sudo php composer.phar require aws/aws-sdk-php &> /tmp/runcomposer.txt

sudo mv vendor /var/www/html &> /tmp/movevendor.txt

sudo php /var/www/html/setup.php &> /tmp/database-setup.txt

sudo php ./setup.php

sudo chmod 755 ./setup.php

echo "Hello!" > /tmp/hello.txt
