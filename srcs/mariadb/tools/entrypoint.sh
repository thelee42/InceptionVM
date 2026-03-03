#!/bin/sh

# Read database password from files
if [ -f "$MYSQL_ROOT_PASSWORD_FILE" ]; then
    MYSQL_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
else
    echo "Error: MYSQL_ROOT_PASSWORD_FILE is not set or file does not exist."
    exit 1
fi

if [ -f "$MYSQL_PASSWORD_FILE" ]; then
    MYSQL_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")
else
    echo "Error: MYSQL_PASSWORD_FILE is not set or file does not exist."
    exit 1
fi

#initialize database
if [ ! -f "/var/lib/mysql/ibdata1" ]; then
    echo ">>> Starting DB initialization..."
    
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null
    echo ">>> install-db done"
    
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
    pid="$!"
    echo ">>> mysqld started with pid $pid"

    until mysqladmin ping --silent; do
        echo "Waiting for database..."
        sleep 2
    done
    echo ">>> DB is up"

    mysql -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;" && echo ">>> DB created" || echo ">>> DB create FAILED"
    mysql -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';" && echo ">>> User created" || echo ">>> User create FAILED"
    mysql -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';" && echo ">>> Grant done" || echo ">>> Grant FAILED"
    mysql -e "FLUSH PRIVILEGES;" && echo ">>> Flush done" || echo ">>> Flush FAILED"
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';" && echo ">>> Root pw set" || echo ">>> Root pw FAILED"

    kill $pid
    wait $pid
    echo ">>> Initialization complete"
else
    echo ">>> ibdata1 found, skipping initialization"
fi

exec '$@'