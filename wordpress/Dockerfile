FROM debian:12

RUN mkdir -p /run/php

RUN apt-get update && apt-get install -y --no-install-recommends \
    php php-fpm php-mysql php-gd php-curl php-xml \
    php-mbstring php-zip \
    bash \
    curl \
    unzip \
    mariadb-client \
    ca-certificates \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

RUN curl -fsSL https://wordpress.org/latest.tar.gz -o /tmp/wp.tar.gz

RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|g' /etc/php/8.2/fpm/pool.d/www.conf

EXPOSE 9000

COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/sbin/php-fpm8.2", "-F"]