# Odkaz pre starostu - BackOffice - SaaS

## How to run it

```
docker compose up -d --build
```

App should be available on [http://localhost:8081](http://localhost:8081) after about 30 seconds initially. Default login is:

```
example@example.org
PASSword123
```

Default ENVs are in `.env.sample`. Copy them to `.env` and customize if needed.

### Development

If you want to apply changes to the containers, run this again:

```
docker compose up -d --build
```

Wait untill `ops-backoffice-saas-zammad-init` container is done.


## Deployments in the wild

### DEV

- [staremesto-ba.ops.dev.slovensko.digital](https://staremesto-ba.ops.dev.slovensko.digital)
- [magistrat-ba.ops.dev.slovensko.digital](https://magistrat-ba.ops.dev.slovensko.digital)
- [malacky.ops.dev.slovensko.digital](https://malacky.ops.dev.slovensko.digital)
- [stupava.ops.dev.slovensko.digital](https://stupava.ops.dev.slovensko.digital)


### PROD

IP: `88.99.99.215`:
- [malacky.odkazprestarostu.sk](https://malacky.odkazprestarostu.sk)


## Available kamal aliases

```
kamal console -d dev_staremesto_ba          # rails console in primary web container
kamal shell -d dev_staremesto_ba            # bash in primary web container
kamal logs -d dev_staremesto_ba             # logs of primary web container
kamal reindex_elastic -d dev_staremesto_ba  # reindex to elasticsearch
```

## Deploy action

All environments are deployed via manual `workflow_dispatch` on their GitHub actions. See `Actions` -> `(left menu)` -> `(corresponding deploy action)` -> `Run workflow` -> `Run workflow`.

PROD deployments can only be triggered on the `main` branch. DEV deployments can be run on any branch.


## New deployment

We are using Kamal for deployment. Each deployment needs its own `destination`. File `config/deploy.<destination>.yml` must be created - take other existing configs as example. To make deploy possible from github action, create also `.github/workflows/<env>_<destination>_deploy.yml`.

### GitHub Environment secrets and variables

For each destination create GitHub Environment and setup secrets and variables in it.

Variables:

```
ADMIN_EMAIL                     # email address of the first admin user created at initialization
MONITORING_TOKEN                # secret token that is used to call zammad's healthcheck
```

Secrets:

```
RAILS_MASTER_KEY                # generate random
POSTGRES_PASSWORD               # generate random and set in postgres, see below
ZAMMAD_ELASTICSEARCH_PASSWORD   # generate random and set in triage elastic, see below
API_TOKEN                       # generate random and set in Connector::Tenant in OPS portal app
WEBHOOK_SECRET                  # generate random and set in Connector::Tenant in OPS portal app
ADMIN_PASSWORD
```

Optional secrets:

```
NOTIFICATION_SMTP_PASSWORD      # Password for notification email
S3_URL                          # Database storage will be used if not provided
GOOGLE_OAUTH2_CLIENT_ID         #
GOOGLE_OAUTH2_CLIENT_SECRET     # redirect URI: /auth/google_oauth2/callback
```

Destination `staremesto_ba` is used in the rest of the readme.

Note: *Some vaule in the config must be named with underscores, some with dashes.*

### PostgreSQL

Setup Postgres user and database on server:
```
CREATE USER ops_backoffice_staremesto_ba WITH PASSWORD '...';
CREATE DATABASE ops_backoffice_staremesto_ba_staging WITH OWNER ops_backoffice_staremesto_ba;
```

Add entry to `pg_hba.conf`:
```
host    ops_backoffice_staremesto_ba_staging ops_backoffice_staremesto_ba 172.17.0.0/16 scram-sha-256
host    ops_backoffice_staremesto_ba_staging ops_backoffice_staremesto_ba 172.18.0.0/16 scram-sha-256
```

Reload pg conf:
```
SELECT pg_reload_conf();
```

### Elasticsearch

Elasticsearch instance is running as `kamal accessory` in [`ops-triage-zammad`](https://github.com/slovensko-digital/ops-triage-zammad) deployment. To setup elasticsearch user and role for backoffice, use helper in the triage repository:

```
kamal elastic_add_backoffice -d dev_staremesto_ba
user: staremesto_ba         # you will be prompted to enter username
password:                   # you will be prompted to enter - hidden
Done!
```

### Portal Connector::Tenant

See [ops repository](https://github.com/slovensko-digital/ops) on how to create `Connector::Tenant` and thus connect the backoffice instance to the app.

```
new_backoffice_data = {
  name: "MÚ Staré Mesto",
  url: "https://ops.dev.slovensko.digital/connector/webhook",
  connector_zammad_url: "https://staremesto-ba.ops.dev.slovensko.digital/",
  receive_customer_activities: true,
  connector_zammad_api_token: "<API_TOKEN>",
  connector_zammad_webhook_secret: "<WEBHOOK_SECRET>"
}
```

### Deploy!

Use the created GitHub action to deploy to the new destination.

Note: *workflow_dispatch GitHub Action is only available if it is located in the main branch.*

### Reindex Elastic

From local computer use `kamal reindex_elastic -d dev_staremesto_ba` to set up the elastisearch indexes for the first time.


## Zammad NGINX reverse proxy hack

As long as kamal-proxy's `path-prefix` setting is not presnt in kamal, zammad's `railsserver` and `websocket` must be deployed as kamal accessory. Thus, nginx reverse proxy is dpeloyed as the main `web` container. We must use custom and dynamically edited `nginx.conf` to specify the upstreams. The upstreams need to be set differently for each `destination` as we are deploying multiple `destinations` on the same server. Hostnames in docker network would collide otherwise.
