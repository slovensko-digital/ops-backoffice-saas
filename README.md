# OPS - BackOffice SaaS

```
staremesto-ba.ops.dev.slovensko.digital
magistrat-ba.ops.dev.slovensko.digital
```

## Deployment

Env `BACKOFFICE_PREFIX` must be set when running `kamal`. Possible prefixes are: `staremesto-ba` and `magistrat-ba`.

First time setup of staging `staremesto-ba`:
```
export BACKOFFICE_PREFIX=staremesto-ba
kamal build push -d staging
kamal accessory boot -d staging all
kamal zammad_init -d staging
kamal deploy -d staging
```
