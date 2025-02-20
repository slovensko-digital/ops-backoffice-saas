# OPS - BackOffice SaaS

```
staremesto-ba.ops.dev.slovensko.digital
magistrat-ba.ops.dev.slovensko.digital
```

## Deployment

Env `BACKOFFICE_PREFIX` must be set when running `kamal`. Possible prefixes are: `staremesto-ba` and `magistrat-ba`.

Prepare `.env.<environment>.<BACKOFFICE_PREFIX>` file. (E.g. `.env.staging.staremesto-ba`)

Setup Postgres user and database on server:
```
CREATE USER ops_backoffice_staremesto_ba WITH PASSWORD '...';
CREATE DATABASE ops_backoffice_staremesto_ba_staging WITH OWNER ops_backoffice_staremesto_ba;
```

Add entry to `pg_hba.conf`:
```
host    ops_backoffice_staremesto_ba_staging ops_backoffice_staremesto_ba 172.16.0.0/12 scram-sha-256
```

Reload pg conf:
```
SELECT pg_reload_conf();
```

First time setup of staging `staremesto-ba`:
```
export BACKOFFICE_PREFIX=staremesto-ba
kamal build push -d staging
kamal accessory boot -d staging all
kamal zammad_init -d staging
kamal deploy -d staging
```
