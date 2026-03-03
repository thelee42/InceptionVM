#!/bin/sh

mkdir -p /etc/nginx/ssl etc/nginx/conf.d

if [ ! -f /etc/nginx/ssl/nginx.crt ] || [ ! -f /etc/nginx/ssl/nginx.key ]; then
		echo "Generating SSL certificate...";
		apt-get install -y --no-install-recommends openssl;
        openssl req -x509 -nodes -days 365 \
			-newkey rsa:2048 \
			-keyout /etc/nginx/ssl/nginx.key \
			-out /etc/nginx/ssl/nginx.crt \
			-subj "/CN=$HOST_NAME"
fi

chown -R www-data:www-data /etc/nginx/ssl

VARS='$HOST_NAME $PORT'
envsubst "$VARS" < /tmp/nginx.conf.template > /etc/nginx/conf.d/default.conf

exec '$@'