ARG DOCKER_USERNAME
ARG ONEC_VERSION
ARG WS_USER_EN
ARG WS_USER_RU
ARG WS_PASSWORD

FROM $DOCKER_USERNAME/ws:$ONEC_VERSION

ARG WS_USER_EN
ARG WS_USER_RU
ARG WS_PASSWORD

COPY ./test/transmitter.dt /tmp/data.dt

COPY ./web/transmitter /var/www

RUN /opt/1cv8/current/webinst -apache24 -wsdir client -dir /var/www/client -descriptor /var/www/client-debug.vrd -connstr "Srvr=srv;Ref=transmitter;" \
    && /opt/1cv8/current/webinst -apache24 -wsdir api -dir /var/www/api -descriptor /var/www/api-debug.vrd -connstr "Srvr=srv;Ref=transmitter;usr=site;pwd=$WS_PASSWORD" \
    && /opt/1cv8/current/webinst -apache24 -wsdir api/en -dir /var/www/api/en -descriptor /var/www/api-debug.vrd -connstr "Srvr=srv;Ref=transmitter;usr=$WS_USER_EN;pwd=$WS_PASSWORD" \
    && /opt/1cv8/current/webinst -apache24 -wsdir api/ru -dir /var/www/api/ru -descriptor /var/www/api-debug.vrd -connstr "Srvr=srv;Ref=transmitter;usr=$WS_USER_RU;pwd=$WS_PASSWORD" \
    && chown -R usr1cv8:grp1cv8 /var/www/client /var/www/api

CMD ["apache2-foreground"]