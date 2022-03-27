#!/usr/bin/env bash

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
echo "= DB_HOSTNAME = $db_hostname"
echo "= DB_DATABASE = $db_name"
echo "= DB_USERNAME = $db_username"
echo "= DB_PASSWORD = $db_password"
echo "=============================="

find .env -type f -exec sed -i '' -e "/^DB_HOST=/s/=.*/=$db_hostname/" {} \;
find .env -type f -exec sed -i '' -e "/^DB_DATABASE=/s/=.*/=$db_name/" {} \;
find .env -type f -exec sed -i '' -e "/^DB_USERNAME=/s/=.*/=$db_username/" {} \;
find .env -type f -exec sed -i '' -e "/^DB_PASSWORD=/s/=.*/=$db_password/" {} \;
