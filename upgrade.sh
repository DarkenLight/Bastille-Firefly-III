#!/usr/bin/env bash

project_name="firefly-iii"
project_home="/usr/local/www"
project_path="$project_home/$project_name"
envfile_path="$project_path/.env"
project_user="www"
project_group=$project_user

# Get the latest release version from GitHub API
release_version=$(curl -s https://api.github.com/repos/firefly-iii/firefly-iii/releases/latest | grep 'tag_name' | cut -d\" -f4)
release_url="https://github.com/firefly-iii/firefly-iii/releases/download/$release_version/FireflyIII-$release_version.tar.gz"
archive_name="FireflyIII-$release_version.tar.gz"

echo "Preparing $project_name for upgrade"
cd $project_path
php artisan cache:clear
php artisan view:clear
cd

echo "Upgrading by pulling the remote repository $project_name"
fetch -o $archive_name $release_url

echo "Moving the old installation to a temporary directory, ie $project_name-old"
if [ -d "$project_path-old" ]; then
    rm -rf "$project_path-old"
fi
mv $project_path $project_path-old

echo "Extracting the archive with the new release at $project_path"
mkdir $project_path
tar -xvf $archive_name -C $project_path --strip-components=1 --exclude='storage'

echo "Copying config & Storage from the old version"
echo "Copying .env file"
cp $project_path-old/.env $project_path/.env

echo "Copying the storage directory"
cp -r $project_path-old/storage $project_path

echo "Transferring the ownership to $project_user"
chown -R $project_user:$project_group $project_path
chmod -R 775 $project_path/storage

echo "Upgrading the Database"
cd $project_path
php artisan migrate --seed
php artisan firefly-iii:decrypt-all
php artisan firefly-iii:upgrade-database
php artisan firefly-iii:laravel-passport-keys
php artisan cache:clear
php artisan view:clear

echo "Cleaning up"
cd
rm $archive_name

echo "Upgrade Complete"
