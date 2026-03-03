#!/bin/sh

mkdir -p secrets

DB_PASSWORD="dbpassword1234"
DB_ROOT_PASSWORD="rootpassword1234"
WP_ADMIN_PASSWORD="adminpassword1234"
WP_USER_PASSWORD="userpassword1234"

echo "$DB_PASSWORD" > secrets/db_password.txt
echo "$DB_ROOT_PASSWORD" > secrets/db_root_password.txt
echo "$WP_ADMIN_PASSWORD" > secrets/db_admin_password.txt
echo "$WP_USER_PASSWORD" > secrets/db_user_password.txt

chmod 600 secrets/*.txt