# Odkaz pre starostu - BackOffice - SaaS

## Local development

### Next to the local portal

Run one Backoffice per PRO responsible subject of the local portal, e.g. Malacky and Trnava, to click through a hand-off from one Backoffice to the other. The portal's `bin/activate-seeded-municipalities` activates them as PRO and prints the command that starts each one, see "Local Backoffice" in the [ops-portal README](https://github.com/slovensko-digital/ops-portal#local-backoffice):

```
dev/up malacky 1 Malacky 22 1 <api token> <webhook secret>
```

`dev/up <instance> <slot> ...` writes the values to `.env.<instance>` and starts the docker compose project `ops-backoffice-<instance>` with its own containers and volumes:

| Slot | Backoffice | Mailpit |
|---|---|---|
| 1 | http://malacky.localhost:8081 | http://localhost:8026 |
| 2 | http://trnava.localhost:8082 | http://localhost:8027 |

- Login `example@example.org` / `PASSword123`. Each Backoffice has a host name of its own: cookies ignore ports, so Backoffices (and Triage on `localhost:8080`) on the same host name log each other out. Chrome and Firefox resolve `*.localhost` without any setup.
- The first start runs `zammad-init` and takes a few minutes.
- Then `dev/compose <instance> ...` runs docker compose for it: `dev/compose malacky up -d` every day, `dev/compose malacky down -v` to wipe it.
- The Backoffice calls the portal on the host at `http://host.docker.internal:3000`.

### On its own

```
docker compose up -d --build
```

Backoffice on http://127.0.0.1:8081 and Mailpit on http://localhost:8026, the same ports as slot 1. Settings come from `.env.sample`, put local overrides into `.env`. After changing `.env`, run `docker compose up -d --force-recreate`, the init sets the webhooks again with the new values.

### Both ways

- Mailpit: every email the Backoffice sends lands here, never in a real inbox (`dev/mail_catcher.rb`, mounted by `docker-compose.yml` only).
- `zammad-dev-setup` gives the portal's tech account all groups right away (`dev/setup.rb`), so subtasks work without waiting for the 15-minute scheduler.
- To apply code changes, run `docker compose up -d --build` (or `dev/compose <instance> up -d --build`) again.
- Each Zammad needs about 1.5 GB of Docker Desktop memory, Triage and two Backoffices about 4.5 GB (Settings → Resources). When memory runs out, Zammad containers exit with code 137.


## Available kamal aliases

```
kamal console -d dev_staremesto_ba          # rails console in primary web container
kamal shell -d dev_staremesto_ba            # bash in primary web container
kamal logs -d dev_staremesto_ba             # logs of primary web container
kamal reindex_elastic -d dev_staremesto_ba  # reindex to elasticsearch
```

## Run command in all destinations

```
./exec_all.sh -d dev -c maintenance_on
```

```
./exec_all.sh -d dev --shell -c "date"
```

See `./exec_all.sh --help`


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

Optional variables:

```
NOTIFICATION_SMTP_HOST          # SMTP server for notification email, defaults to smtp.m1.websupport.sk
NOTIFICATION_SMTP_PORT          # defaults to 587
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
NOTIFICATION_SMTP_USER          # SMTP login for notification email, defaults to NOTIFICATION_SENDER_EMAIL from the deploy config
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
