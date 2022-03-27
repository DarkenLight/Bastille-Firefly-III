#!/usr/bin/env bash

project_home="/usr/local/www"
envfile_path="$project_home/firefly-iii/.env"

clear
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo "  ______  _____  _____   ______  ______  _   __     __     _____  _____  _____ "
echo " |  ____||_   _||  __ \ |  ____||  ____|| |  \ \   / /    |_   _||_   _||_   _|"
echo " | |__     | |  | |__) || |__   | |__   | |   \ \_/ /______ | |    | |    | |  "
echo " |  __|    | |  |  _  / |  __|  |  __|  | |    \   /|______|| |    | |    | |  "
echo " | |      _| |_ | | \ \ | |____ | |     | |____ | |        _| |_  _| |_  _| |_ "
echo " |_|     |_____||_|  \_\|______||_|     |______||_|       |_____||_____||_____|"
echo "                                                                               "
echo "                                                                               "
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo "                 MANAGE THE FIREFLY-III DATABASE CREDENTIALS                   "
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

echo "Enter Database Hostname or IP Address: "
read db_hostname
echo "Enter Database Name: "
read db_name
echo "Enter Database Username: "
read db_username
echo "Enter Database Password: "
read db_password

echo "Entered Details are Below"
echo "=============================="
echo "DB_HOSTNAME = $db_hostname"
echo "DB_DATABASE = $db_name"
echo "DB_USERNAME = $db_username"
echo "DB_PASSWORD = $db_password"
echo "=============================="

find /usr/local/www/firefly-iii/.env -type f -exec sed -i '' -e "/^DB_HOST=/s/=.*/=$db_hostname/" {} \;
find /usr/local/www/firefly-iii/.env -type f -exec sed -i '' -e "/^DB_DATABASE=/s/=.*/=$db_name/" {} \;
find /usr/local/www/firefly-iii/.env -type f -exec sed -i '' -e "/^DB_USERNAME=/s/=.*/=$db_username/" {} \;
find /usr/local/www/firefly-iii/.env -type f -exec sed -i '' -e "/^DB_PASSWORD=/s/=.*/=$db_password/" {} \;
