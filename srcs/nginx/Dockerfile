FROM debian:12

RUN apt-get update && apt-get install -y --no-install-recommends nginx openssl gettext \
    && rm -rf /var/lib/apt/lists/*

RUN adduser --system --no-create-home --group nginx

COPY tools/nginx.conf /etc/nginx/nginx.conf
COPY tools/nginx.conf.template /tmp/nginx.conf.template
COPY tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]