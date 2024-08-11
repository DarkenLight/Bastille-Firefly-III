#!/usr/bin/env bash

PROJECT_NAME="firefly-iii"
PROJECT_HOME="/usr/local/www"
PROJECT_PATH="$PROJECT_HOME/$PROJECT_NAME"
PROJECT_USER="www"
PROJECT_GROUP=$PROJECT_USER

# Get the latest release version from GitHub API
RELEASE_VERSION=$(curl -s https://api.github.com/repos/firefly-iii/firefly-iii/releases/latest | grep 'tag_name' | cut -d\" -f4)
RELEASE_URL="https://github.com/firefly-iii/firefly-iii/releases/download/$RELEASE_VERSION/FireflyIII-$RELEASE_VERSION.tar.gz"
ARCHIVE_NAME="FireflyIII-$RELEASE_VERSION.tar.gz"

echo "Installing $PROJECT_NAME at $PROJECT_HOME"

if [ -d "$PROJECT_PATH" ]; then
  echo "Folder $PROJECT_NAME exists at $PROJECT_HOME, deleting..."
  rm -rf "$PROJECT_PATH"
else
  echo "Folder $PROJECT_NAME does not exist at $PROJECT_HOME, creating..."
  mkdir -p "$PROJECT_PATH"
fi

echo "Installing by pulling the remote repository $PROJECT_NAME $RELEASE_VERSION"
fetch -o $ARCHIVE_NAME $RELEASE_URL

echo "Extracting the archive with the new release at $PROJECT_PATH"
tar -xvf $ARCHIVE_NAME -C $PROJECT_PATH --strip-components=1 --exclude='storage'

echo "Copying config & Storage from the old version"
echo "Copying .env file"
cp $PROJECT_PATH-old/.env $PROJECT_PATH/.env


# Prompt the user for input
read -p "Do you want to install the database server as well? (yes/no): " -n 1 -r REPLY
echo  # (optional) move to a new line

# Check if the user wants to install the database server
if [[ $REPLY =~ ^[Yy]$ ]]; then
  # If yes, print a message indicating that it will be added in the future
  echo "WILL BE ADDED IN THE FUTURE"
fi

# Prompt the user for database credentials
echo "Enter Database Hostname or IP Address: "
read -p ">>" DB_HOSTNAME
echo "Enter Database Name: "
read -p ">>" DB_NAME
echo "Enter Database Username: "
read -p ">>" DB_USERNAME
echo "Enter Database Password: "
read -p ">>" DB_PASSWORD

# Print a confirmation message with the entered credentials
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo "Entered Details are Below"
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo "DB_HOSTNAME = ${DB_HOSTNAME}"
echo "DB_DATABASE = ${DB_NAME}"
echo "DB_USERNAME = ${DB_USERNAME}"
echo "DB_PASSWORD = ${DB_PASSWORD}"
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

# Function to check database connection
check_database_connection() {
  # Define a query to test the database connection
  LOCAL_QUERY="SELECT 1;"

  # Attempt to connect to the database using the provided credentials
  if mysql -sN --host="${DB_HOSTNAME}" --user="${DB_USERNAME}" --password="${DB_PASSWORD}" --database="${DB_NAME}" -e ${LOCAL_QUERY}" > /dev/null; then
    # If the connection is successful, print a success message and return 0 (true)
    echo "Database connection successful"
    return 0
  else
    # If the connection fails, print an error message with the exit status code and return 1 (false)
    echo "Error connecting to database: $?"
    return 1
  fi
}


# Check the database connection using the provided credentials
if ! check_database_connection; then
  # If the connection fails, print an error message and exit with a non-zero status code
  echo "Error in database connection, Exiting"
  exit 1
fi

# Print a success message indicating that the database connection is established
echo "Database connection established. Proceeding with script execution..."

# Create a .env file and store the credentials
cp $PROJECT_PATH/.env.example $PROJECT_PATH/.env

# Update the .env files to include the provided database credentials
find $PROJECT_PATH/.env -type f -exec sed -i '' -e "/^DB_HOST=/s/=.*/=${DB_HOSTNAME}/" {} \;
find $PROJECT_PATH/.env -type f -exec sed -i '' -e "/^DB_DATABASE=/s/=.*/=${DB_NAME}/" {} \;
find $PROJECT_PATH/.env -type f -exec sed -i '' -e "/^DB_USERNAME=/s/=.*/=${DB_USERNAME}/" {} \;
find $PROJECT_PATH/.env -type f -exec sed -i '' -e "/^DB_PASSWORD=/s/=.*/=${DB_PASSWORD}/" {} \;

# Initialize the database using the provided commands
echo "Initializing the Database"
cd $PROJECT_PATH
php artisan firefly-iii:upgrade-database
php artisan firefly-iii:correct-database
php artisan firefly-iii:report-integrity
php artisan firefly-iii:laravel-passport-keys

# Transfer ownership to the specified user and group
echo "Transferring the ownership to ${PROJECT_USER}"
chown -R ${PROJECT_USER}:${PROJECT_GROUP} $PROJECT_PATH
chmod -R 775 $PROJECT_PATH/storage

# Clean up by removing the archive file
cd
echo "Cleaning up"
rm ${ARCHIVE_NAME}

# Print a success message indicating that the installation is complete
echo "Installation Complete"
