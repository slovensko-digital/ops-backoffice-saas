FROM zammad/zammad-docker-compose:6.4.1-49

# RUN sed -i 's/config.log_level = :info/config.log_level = :debug/' /opt/zammad/config/environments/production.rb

COPY ./config/nginx.conf /etc/nginx/sites-enabled/default
COPY ./config/ops-backoffice-nginx-entrypoint.sh /ops-backoffice-nginx-entrypoint.sh

EXPOSE 3000
EXPOSE 6042

CMD [ "zammad-railsserver" ]
