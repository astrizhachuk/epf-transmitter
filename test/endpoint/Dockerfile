ARG DOCKER_USERNAME
ARG ONEC_VERSION

FROM ${DOCKER_USERNAME}/ws:${ONEC_VERSION}

COPY ./test/endpoint/data.dt /tmp/data.dt
COPY ./test/endpoint/web /var/www

RUN /opt/1cv8/current/ibcmd infobase --db-path=/home/usr1cv8/db create --create-database --restore=/tmp/data.dt

RUN /opt/1cv8/current/webinst -apache24 -wsdir client -dir /var/www/client -descriptor /var/www/client.vrd -connstr 'File=/home/usr1cv8/db' \
    && /opt/1cv8/current/webinst -apache24 -wsdir api -dir /var/www/api -descriptor /var/www/api.vrd -connstr 'File=/home/usr1cv8/db' \
    && chown -R usr1cv8:grp1cv8 /var/www/client /var/www/api /home/usr1cv8/db

VOLUME [ "/home/usr1cv8/db" ]

CMD ["apache2-foreground"]