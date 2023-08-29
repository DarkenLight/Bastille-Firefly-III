#!/usr/bin/env bash

project_name="firefly-iii"
project_home="/usr/local/www"
envfile_path="$project_home/$project_name/.env"
project_user="www"
project_group=$project_user

echo "Installing $project_name at $project_home"

cd $project_home/
composer create-project grumpydictator/firefly-iii --no-dev --prefer-dist $project_name 6.0.20
echo "Installation Successful"

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
echo
echo

read -p "Do you want to Install the Database server as well?? Enter \"N\" if you have database server running." -n 1 -r
echo  # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo  "WILL BE ADDED IN THE FUTURE"
fi

echo "Enter Database Hostname or IP Address: "
read -p ">>" db_hostname
echo "Enter Database Name: "
read -p ">>" db_name
echo "Enter Database Username: "
read -p ">>" db_username
echo "Enter Database Password: "
read -p ">>" db_password

echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo "Entered Details are Below"
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo "DB_HOSTNAME = $db_hostname"
echo "DB_DATABASE = $db_name"
echo "DB_USERNAME = $db_username"
echo "DB_PASSWORD = $db_password"
echo "DB_PASSWORD = $app_key"
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

find $envfile_path -type f -exec sed -i '' -e "/^DB_HOST=/s/=.*/=$db_hostname/" {} \;
find $envfile_path -type f -exec sed -i '' -e "/^DB_DATABASE=/s/=.*/=$db_name/" {} \;
find $envfile_path -type f -exec sed -i '' -e "/^DB_USERNAME=/s/=.*/=$db_username/" {} \;
find $envfile_path -type f -exec sed -i '' -e "/^DB_PASSWORD=/s/=.*/=$db_password/" {} \;
echo "Database Connection Complete"
echo

read -p "Do you want to initialize the Database Now??" -n 1 -r
echo  # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
  read -p "This will Erase all the data from the Database? Are you Sure?" -n 1 -r
  echo  # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]
    then
    cd $project_name
    php artisan migrate:refresh --seed
    php artisan firefly-iii:upgrade-database
    php artisan passport:install
    fi
else
  echo "Enter API KEY: "
  read -p ">>" app_key
  echo "DB_PASSWORD = $app_key"
  find $envfile_path -type f -exec sed -i '' -e "/^APP_KEY=/s/=.*/=$app_key/" {} \;
  cd $project_name
  composer update
fi
chown -R $project_user:$project_group $project_home/$project_name
echo "Setup complete"
