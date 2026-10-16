# ops-backoffice-saas

Backoffice: one Zammad per PRO municipality, where its staff work issues that
arrive from Triage through the portal Connector. Customisations live in
`zammad/` (migrations, seeds, `lib/ops/*` patches, `lib/tasks/ops/backoffice.rake`,
jobs) and `hacks/`.

## How it works docs

The flows between the portal, Triage and Backoffice are documented in
[`ops-portal/docs/how-it-works/`](https://github.com/slovensko-digital/ops-portal/tree/main/docs/how-it-works),
mostly `07-backoffice-connector.md`. When you change a flow here (triggers,
webhooks, core workflows, schedulers, subtasks, roles, article patches), open a
PR in `ops-portal` that updates it. Changes made in the Zammad admin UI count
too: they are not in this repo, so the docs are their only record.
