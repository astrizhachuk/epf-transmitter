ARG DOCKER_USERNAME
ARG ONEC_VERSION

FROM ${DOCKER_USERNAME}/ws:${ONEC_VERSION}

COPY ./test/receiver/db /home/usr1cv8/db

CMD ["apache2-foreground"]