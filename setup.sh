#!/usr/bin/env bash

PROJECT_NAME="firefly-iii"
PROJECT_HOME="/usr/local/www"
PROJECT_PATH="$PROJECT_HOME/$PROJECT_NAME"
PROJECT_USER="www"
PROJECT_GROUP=$PROJECT_USER
AUTO_UPGRADE="N"

# Fetch the latest release version from GitHub API
RELEASE_VERSION=$(curl -s https://api.github.com/repos/firefly-iii/firefly-iii/releases/latest | grep 'tag_name' | cut -d\" -f4)
RELEASE_URL="https://github.com/firefly-iii/firefly-iii/releases/download/$RELEASE_VERSION/FireflyIII-$RELEASE_VERSION.tar.gz"
ARCHIVE_NAME="FireflyIII-$RELEASE_VERSION.tar.gz"

# Function to check the database connection
check_database_connection() {
    LOCAL_QUERY="SELECT 1;"

    if mysql -sN --host="${DB_HOSTNAME}" --user="${DB_USERNAME}" --password="${DB_PASSWORD}" --database="${DB_NAME}" -e "${LOCAL_QUERY}" > /dev/null; then
        echo "Database connection successful"
        return 0
    else
        echo "Error connecting to database: $?"
        return 1
    fi
}

echo "Preparing $PROJECT_NAME for Installation or Upgrade" 

if [ -d "$PROJECT_PATH" ]; then
    echo "Folder $PROJECT_NAME exists at $PROJECT_HOME. Auto Upgrade Available"
    echo "Moving the old installation to a temporary directory: $PROJECT_NAME-old"
    if [ -d "$PROJECT_PATH-old" ]; then
        rm -rf "$PROJECT_PATH-old"
    fi
    cd $PROJECT_PATH
    php artisan cache:clear
    php artisan view:clear
    cd
    mv $PROJECT_PATH $PROJECT_PATH-old
else
    echo "Folder $PROJECT_NAME does not exist at $PROJECT_HOME, Auto Upgrade Unavailable"
fi

mkdir -p "$PROJECT_PATH"

echo "Downloading the release archive: $RELEASE_VERSION"
fetch -o $ARCHIVE_NAME $RELEASE_URL

# Prompt the user for installation type
read -p "Do you want to install fresh (Y for fresh install, N for upgrade)? (yes/no): " -n 1 -r REPLY
echo 

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Extracting the archive to $PROJECT_PATH"
    tar -xf $ARCHIVE_NAME -C $PROJECT_PATH --strip-components=1

    cp $PROJECT_PATH/.env.example $PROJECT_PATH/.env

    # Prompt for database credentials
    echo "Enter Database Hostname or IP Address: "
    read -p ">>" DB_HOSTNAME
    echo "Enter Database Name: "
    read -p ">>" DB_NAME
    echo "Enter Database Username: "
    read -p ">>" DB_USERNAME
    echo "Enter Database Password: "
    read -p ">>" DB_PASSWORD

    echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    echo "Entered Details:"
    echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    echo "DB_HOSTNAME = ${DB_HOSTNAME}"
    echo "DB_DATABASE = ${DB_NAME}"
    echo "DB_USERNAME = ${DB_USERNAME}"
    echo "DB_PASSWORD = ${DB_PASSWORD}"
    echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

    # Update .env file with database credentials
    sed -i '' -e "/^DB_HOST=/s/=.*/=${DB_HOSTNAME}/" $PROJECT_PATH/.env
    sed -i '' -e "/^DB_DATABASE=/s/=.*/=${DB_NAME}/" $PROJECT_PATH/.env
    sed -i '' -e "/^DB_USERNAME=/s/=.*/=${DB_USERNAME}/" $PROJECT_PATH/.env
    sed -i '' -e "/^DB_PASSWORD=/s/=.*/=${DB_PASSWORD}/" $PROJECT_PATH/.env

    if ! check_database_connection; then
        echo "Error in database connection, exiting."
        exit 1
    else
        echo "Database connection established. Proceeding with database setup..."
        cd $PROJECT_PATH
        php artisan firefly-iii:upgrade-database
        php artisan firefly-iii:correct-database
        php artisan firefly-iii:report-integrity
        php artisan firefly-iii:laravel-passport-keys
    fi

    echo "Changing ownership to ${PROJECT_USER}"
    chown -R ${PROJECT_USER}:${PROJECT_GROUP} $PROJECT_PATH
    chmod -R 775 $PROJECT_PATH/storage

    echo "Cleaning up"
    rm $ARCHIVE_NAME

    echo "Installation complete."

else
    echo "Extracting the archive to $PROJECT_PATH"
    tar -xf $ARCHIVE_NAME -C $PROJECT_PATH --strip-components=1 --exclude='storage'

    if [ -d "$PROJECT_PATH-old" ]; then
        echo "Performing auto-upgrade with existing files"

        echo "Restoring .env file from the old version"
        cp $PROJECT_PATH-old/.env $PROJECT_PATH/.env

        echo "Restoring storage directory from the old version"
        cp -r $PROJECT_PATH-old/storage $PROJECT_PATH

        echo "Changing ownership to $PROJECT_USER"
        chown -R $PROJECT_USER:$PROJECT_GROUP $PROJECT_PATH
        chmod -R 775 $PROJECT_PATH/storage

        cd $PROJECT_PATH
        php artisan migrate --seed
        php artisan firefly-iii:decrypt-all
        php artisan cache:clear
        php artisan view:clear
        php artisan firefly-iii:upgrade-database
        php artisan firefly-iii:laravel-passport-keys

    else
        echo "Manual upgrade required. Please migrate the database and adjust files as needed."
        echo "Commands to run:"
        echo "php artisan migrate --seed"
        echo "php artisan firefly-iii:decrypt-all"
        echo "php artisan cache:clear"
        echo "php artisan view:clear"
        echo "php artisan firefly-iii:upgrade-database"
        echo "php artisan firefly-iii:laravel-passport-keys"
    fi
fi

echo "Cleaning up"
cd
rm $ARCHIVE_NAME
echo "Install / Upgrade complete."
