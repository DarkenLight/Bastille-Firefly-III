#!/usr/bin/env bash

project_home="/usr/local/www"
envfile_path="$project_home/firefly-iii/.env"

echo "Installing Firefly-III at $project_home"
cd $project_home/
composer create-project grumpydictator/firefly-iii --no-dev --prefer-dist firefly-iii

clear
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo "  ______  _____  _____   ______  ______  _   __     __     _____  _____  _____ "
echo " |  ____||_   _||  __ \ |  ____||  ____|| |  \ \   / /    |_   _||_   _||_   _|"
echo " | |__     | |  | |__) || |__   | |__   | |   \ \_/ /______ | |    | |    | |  "
echo " |  __|    | |  |  _  / |  __|  |  __|  | |    \   /|______|| |    | |    | |  "
echo " | |      _| |_ | | \ \ | |____ | |     | |____ | |        _| |_  _| |_  _| |_ "
echo " |_|     |_____||_|  \_\|______||_|     |______||_|       |_____||_____||_____|"
echo "                                                                               "
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo "                    MANAGED FIREFLY-III SCRIPTED INSTALLER                     "
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

echo "Enter Database Hostname or IP Address: "
read db_hostname
echo "Enter Database Name: "
read db_name
echo "Enter Database Username: "
read db_username
echo "Enter Database Password: "
read db_password

echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo "Entered Details are Below"
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo "DB_HOSTNAME = $db_hostname"
echo "DB_DATABASE = $db_name"
echo "DB_USERNAME = $db_username"
echo "DB_PASSWORD = $db_password"
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

find $envfile_path -type f -exec sed -i '' -e "/^DB_HOST=/s/=.*/=$db_hostname/" {} \;
find $envfile_path -type f -exec sed -i '' -e "/^DB_DATABASE=/s/=.*/=$db_name/" {} \;
find $envfile_path -type f -exec sed -i '' -e "/^DB_USERNAME=/s/=.*/=$db_username/" {} \;
find $envfile_path -type f -exec sed -i '' -e "/^DB_PASSWORD=/s/=.*/=$db_password/" {} \;

echo "Installation Successful"
echo ""
echo "Setting Up Database"
php artisan migrate:refresh --seed
php artisan firefly-iii:upgrade-database
php artisan passport:install
