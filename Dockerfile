FROM zammad/zammad-docker-compose:6.4.1-49

RUN sed -i 's/config.log_level = :info/config.log_level = ENV.fetch("LOG_LEVEL", "info")/' /opt/zammad/config/environments/production.rb

COPY --chown=zammad:zammad ./config/nginx.conf /etc/nginx/sites-enabled/default
COPY --chown=zammad:zammad ./config/ops-backoffice-nginx-entrypoint.sh /opt/ops-backoffice-nginx-entrypoint.sh
COPY --chown=zammad:zammad ./config/zammad_init_and_nginx.sh /opt/zammad_init_and_nginx.sh

COPY ./db/migrate/* ./db/migrate/.
COPY ./lib/tasks/ops/backoffice.rake ./lib/tasks/ops/backoffice.rake

EXPOSE 3000
EXPOSE 6042

CMD [ "zammad-railsserver" ]
