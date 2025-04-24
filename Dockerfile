FROM zammad/zammad-docker-compose:6.4.1-49

# allow creation of customer articles in triggers
RUN sed -i "s/Ticket::Article::Sender.find_by(name: 'System')/Ticket::Article::Sender.find_by(name: note[:sender] || 'System')/" app/models/ticket/perform_changes/action/article_note.rb

COPY --chown=zammad:zammad ./config/nginx.conf /etc/nginx/sites-enabled/default
COPY --chown=zammad:zammad ./config/ops-backoffice-nginx-entrypoint.sh /opt/ops-backoffice-nginx-entrypoint.sh
COPY --chown=zammad:zammad ./config/zammad_init_and_nginx.sh /opt/zammad_init_and_nginx.sh

RUN mkdir hacks
COPY ./hacks/* ./hacks/.
RUN hacks/hacks.rb

COPY zammad ./

EXPOSE 3000
EXPOSE 6042

CMD [ "zammad-railsserver" ]
