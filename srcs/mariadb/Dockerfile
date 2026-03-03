FROM debian:12

RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-server \
    mariadb-client \
    bash \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/mysql/* 

RUN mkdir -p /var/lib/mysql /run/mysqld && chown -R mysql:mysql /var/lib/mysql /run/mysqld


COPY tools/my.cnf /etc/mysql/conf.d/my.cnf

COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/entrypoint.sh"]

CMD ["mysqld", "--user=mysql", "--port=3306", "--bind-address=0.0.0.0"]