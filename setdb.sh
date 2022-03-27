#!/usr/bin/env bash
find .env -type f -exec sed -i '' -e "/^DB_HOST=/s/=.*/=192.168.1.5/" {} \;
find .env -type f -exec sed -i '' -e "/^DB_DATABASE=/s/=.*/=firefly/" {} \;
find .env -type f -exec sed -i '' -e "/^DB_USERNAME=/s/=.*/=firefly/" {} \;
find .env -type f -exec sed -i '' -e "/^DB_PASSWORD=/s/=.*/=firefly/" {} \;
