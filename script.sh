#!/bin/bash
sleep 60
sudo apt update -y
sudo apt install apache2 unzip -y
sudo systemctl enable apache2
wget "https://www.tooplate.com/zip-templates/2129_crispy_kitchen.zip"
unzip 2129_crispy_kitchen.zip
sudo cp -r 2129_crispy_kitchen/* /var/www/html/